import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { MoreThanOrEqual, Repository } from 'typeorm';
import { MarketPrice, PriceSource } from './entities/market-price.entity';
import { MarketsService } from './markets.service';
import { CropsService } from '../crops/crops.service';
import { CreateMarketPriceDto } from './dto/create-market-price.dto';
import { UpdateMarketPriceDto } from './dto/update-market-price.dto';

export type PriceFreshness = 'demo' | 'verified' | 'estimated' | 'stale';

// Thresholds are a documented assumption, not a proposal-specified value:
// the proposal's own KPI target (§14) is "avg. age of active price
// records ≤ 7 days for priority crops in pilot markets" — so "verified"
// (fresh enough to trust at face value) uses that same 7-day bar.
// "Estimated" (still probably close to reality, but say so) extends to 30
// days; beyond that, "stale" — a number this old is more likely wrong
// than right for a commodity price, and the UI must not present it as
// current.
const VERIFIED_MAX_AGE_DAYS = 7;
const ESTIMATED_MAX_AGE_DAYS = 30;

// Bounds for the history window a caller can request — a farmer's phone
// screen and a chart both become useless well before a year of daily
// noise, and an unbounded `days` param is also a cheap way to make the
// query scan far more rows than any real use case needs.
const DEFAULT_HISTORY_DAYS = 90;
const MAX_HISTORY_DAYS = 365;

// A trend needs to move by more than a rounding error to be worth calling
// "up" or "down" — a 0.2% wobble between two demo data points shouldn't
// read as a meaningful market signal. This threshold is a judgment call,
// not a value the proposal specifies.
const TREND_NOISE_THRESHOLD_PERCENT = 0.5;

export type TrendDirection = 'up' | 'down' | 'flat' | 'insufficient_data';

export interface PriceTrend {
  direction: TrendDirection;
  percentChange: number | null;
}

export interface PriceHistoryResult {
  points: MarketPriceView[];
  trend: PriceTrend;
}

export interface MarketPriceView {
  id: string;
  market: MarketPrice['market'];
  crop: MarketPrice['crop'];
  pricePerKg: string;
  grade: string;
  observationDate: string;
  source: PriceSource;
  freshness: PriceFreshness;
}

@Injectable()
export class MarketPricesService {
  constructor(
    @InjectRepository(MarketPrice)
    private readonly repo: Repository<MarketPrice>,
    private readonly marketsService: MarketsService,
    private readonly cropsService: CropsService,
  ) {}

  /**
   * Never presents demo data as real, and never presents old data as
   * current — this is the load-bearing function behind proposal rule 5
   * ("clearly distinguish real, estimated, stale, and demo data") and the
   * design system's freshness badges (docs/design-system.md).
   */
  computeFreshness(observationDate: string, source: PriceSource): PriceFreshness {
    if (source === PriceSource.DEMO) return 'demo';
    const ageDays = Math.floor(
      (Date.now() - new Date(observationDate).getTime()) / (1000 * 60 * 60 * 24),
    );
    if (ageDays <= VERIFIED_MAX_AGE_DAYS) return 'verified';
    if (ageDays <= ESTIMATED_MAX_AGE_DAYS) return 'estimated';
    return 'stale';
  }

  private toView(price: MarketPrice): MarketPriceView {
    return {
      id: price.id,
      market: price.market,
      crop: price.crop,
      pricePerKg: (price.pricePerKgCents / 100).toFixed(2),
      grade: price.grade,
      observationDate: price.observationDate,
      source: price.source,
      freshness: this.computeFreshness(price.observationDate, price.source),
    };
  }

  private validateNotFuture(observationDate: string) {
    const today = new Date().toISOString().slice(0, 10);
    if (observationDate > today) {
      throw new BadRequestException('observationDate cannot be in the future');
    }
  }

  async create(dto: CreateMarketPriceDto): Promise<MarketPriceView> {
    await this.marketsService.getActiveOrThrow(dto.marketId);
    await this.cropsService.getActiveOrThrow(dto.cropId);
    this.validateNotFuture(dto.observationDate);

    const entity = this.repo.create({
      marketId: dto.marketId,
      cropId: dto.cropId,
      pricePerKgCents: Math.round(dto.pricePerKg * 100),
      observationDate: dto.observationDate,
      source: dto.source ?? PriceSource.ADMIN_MANUAL,
      grade: dto.grade ?? 'standard',
    });
    const saved = await this.repo.save(entity);
    const withRelations = await this.repo.findOneOrFail({ where: { id: saved.id } });
    return this.toView(withRelations);
  }

  async findByIdForAdmin(id: string): Promise<MarketPrice> {
    const price = await this.repo.findOne({ where: { id } });
    if (!price) throw new NotFoundException('Price observation not found');
    return price;
  }

  async update(id: string, dto: UpdateMarketPriceDto): Promise<MarketPriceView> {
    const price = await this.findByIdForAdmin(id);
    if (dto.observationDate !== undefined) {
      this.validateNotFuture(dto.observationDate);
      price.observationDate = dto.observationDate;
    }
    if (dto.pricePerKg !== undefined) price.pricePerKgCents = Math.round(dto.pricePerKg * 100);
    if (dto.source !== undefined) price.source = dto.source;
    if (dto.grade !== undefined) price.grade = dto.grade;

    await this.repo.save(price);
    const withRelations = await this.repo.findOneOrFail({ where: { id } });
    return this.toView(withRelations);
  }

  async remove(id: string): Promise<void> {
    const price = await this.findByIdForAdmin(id);
    await this.repo.remove(price);
  }

  async findAllForAdmin(): Promise<MarketPriceView[]> {
    const prices = await this.repo.find({ order: { observationDate: 'DESC' } });
    return prices.map((p) => this.toView(p));
  }

  /**
   * The public-facing view: the single most recent observation per
   * active market for a given crop. Deliberately application-code (fetch
   * everything for the crop, group in JS) rather than a correlated SQL
   * subquery — at MVP data volumes (a handful of markets, a handful of
   * crops) this is simple and correct; revisit if/when Phase 37
   * (Performance) finds it's actually a bottleneck, which it won't be at
   * this scale.
   */
  async findLatestPerMarket(cropId: string): Promise<MarketPriceView[]> {
    await this.cropsService.getActiveOrThrow(cropId);

    const prices = await this.repo.find({
      where: { cropId },
      // Secondary sort by createdAt: two observations can share the same
      // observationDate (e.g. a same-day correction) — createdAt DESC
      // ensures the most-recently-entered one wins as "latest" in that
      // tie, not whichever the DB happens to return first.
      order: { observationDate: 'DESC', createdAt: 'DESC' },
    });

    const latestByMarket = new Map<string, MarketPrice>();
    for (const price of prices) {
      if (!price.market.isActive) continue; // never surface a retired market
      if (!latestByMarket.has(price.marketId)) {
        latestByMarket.set(price.marketId, price);
      }
    }

    return Array.from(latestByMarket.values())
      .map((p) => this.toView(p))
      .sort((a, b) => a.market.name.localeCompare(b.market.name));
  }

  /**
   * Phase 14: historical prices for one market/crop pair, plus a simple
   * trend (first vs. last point in the window) — not a forecast. The
   * proposal mentions "simple short-term forecasting" as part of Module
   * 2's eventual scope, but predicting future prices is a materially
   * different (and materially riskier to get wrong) feature than showing
   * "this went up/down over the period you asked about" — this build
   * ships the honest, already-happened trend only.
   *
   * Same "never surface a retired market/inactive crop" rule as
   * findLatestPerMarket, applied here too: a market or crop that's been
   * deactivated since a price was recorded shouldn't have its history
   * browsable through the farmer-facing view either.
   */
  async findHistory(
    marketId: string,
    cropId: string,
    requestedDays: number,
  ): Promise<PriceHistoryResult> {
    await this.marketsService.getActiveOrThrow(marketId);
    await this.cropsService.getActiveOrThrow(cropId);

    const days = Math.min(Math.max(requestedDays, 1), MAX_HISTORY_DAYS) || DEFAULT_HISTORY_DAYS;
    const cutoff = new Date();
    cutoff.setDate(cutoff.getDate() - days);
    const cutoffDate = cutoff.toISOString().slice(0, 10);

    const rows = await this.repo.find({
      where: { marketId, cropId, observationDate: MoreThanOrEqual(cutoffDate) },
      order: { observationDate: 'ASC', createdAt: 'ASC' },
    });

    const points = rows.map((p) => this.toView(p));
    const trend = this.computeTrend(points);

    return { points, trend };
  }

  private computeTrend(points: MarketPriceView[]): PriceTrend {
    if (points.length < 2) {
      return { direction: 'insufficient_data', percentChange: null };
    }
    const oldest = Number(points[0].pricePerKg);
    const newest = Number(points[points.length - 1].pricePerKg);
    const percentChange = ((newest - oldest) / oldest) * 100;

    let direction: TrendDirection;
    if (Math.abs(percentChange) < TREND_NOISE_THRESHOLD_PERCENT) {
      direction = 'flat';
    } else {
      direction = percentChange > 0 ? 'up' : 'down';
    }

    return { direction, percentChange: Math.round(percentChange * 100) / 100 };
  }
}
