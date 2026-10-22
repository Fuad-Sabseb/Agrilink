import { MarketBenchmark } from '../models/MarketBenchmark.js';
import { User } from '../models/User.js';

export class DecisionEngineService {
  /**
   * Crop dictionary mapping English, Afaan Oromoo, and common aliases
   */
  static CROP_DICTIONARY = {
    potato: { name: 'Potato', oromoo: 'Dinnicha', type: 'Tuber' },
    dinnicha: { name: 'Potato', oromoo: 'Dinnicha', type: 'Tuber' },
    coffee: { name: 'Coffee', oromoo: 'Buna', type: 'Cash Crop' },
    buna: { name: 'Coffee', oromoo: 'Buna', type: 'Cash Crop' },
    maize: { name: 'Maize', oromoo: 'Boqqolloo', type: 'Grain' },
    boqqolloo: { name: 'Maize', oromoo: 'Boqqolloo', type: 'Grain' },
    teff: { name: 'Teff', oromoo: 'Xaafii', type: 'Grain' },
    xaafii: { name: 'Teff', oromoo: 'Xaafii', type: 'Grain' },
    wheat: { name: 'Wheat', oromoo: 'Qamadii', type: 'Grain' },
    qamadii: { name: 'Wheat', oromoo: 'Qamadii', type: 'Grain' },
    tomato: { name: 'Tomato', oromoo: 'Timaatima', type: 'Vegetable' },
    timaatima: { name: 'Tomato', oromoo: 'Timaatima', type: 'Vegetable' },
    carrot: { name: 'Carrot', oromoo: 'Kaarotii', type: 'Vegetable' },
    kaarotii: { name: 'Carrot', oromoo: 'Kaarotii', type: 'Vegetable' },
  };

  /**
   * Calculate realistic freight and transit cost based on volume, distance, road factors, and tolls
   * Calibrated against Ethiopian freight benchmarks (Table 2 AgriLink Proposal)
   */
  static calculateTransportCost(distanceKm, weightKg, roadQualityFactor = 1.0, baseTransitFee = 0) {
    const tons = Math.max(0.1, weightKg / 1000.0);
    const dist = Math.max(1, distanceKm);

    // Minimum base vehicle dispatch & handling fee based on volume
    let baseDispatchFee = 0;
    if (tons <= 1.0) {
      baseDispatchFee = 400; // Small pickup / shared
    } else if (tons <= 3.5) {
      baseDispatchFee = 1200; // Light Isuzu
    } else {
      baseDispatchFee = 1800; // 5-ton / Medium truck
    }

    // Tiered freight rate per km per ton within Jimma Zone corridors
    let ratePerKmPerTon = 8.0;
    if (dist > 60) {
      ratePerKmPerTon = 14.0; // Distant Jimma woredas across mountain corridors (e.g., Limmu Kosa / Setema)
    } else if (dist > 25) {
      ratePerKmPerTon = 10.0; // Inter-woreda arterial transit (e.g., Jimma - Agaro corridor)
    } else {
      ratePerKmPerTon = 7.0; // Short local intra-woreda haul
    }

    // Mileage haulage cost
    const mileageHaulCost = dist * tons * ratePerKmPerTon * roadQualityFactor;

    // Checkpoint / municipality transit fees
    const checkpointFee = baseTransitFee || 0;

    const totalCost = Math.round(baseDispatchFee + mileageHaulCost + checkpointFee);

    return {
      totalCost,
      breakdown: {
        baseDispatchFee,
        mileageHaulCost: Math.round(mileageHaulCost),
        checkpointFee,
        distanceKm: dist,
        tonnage: parseFloat(tons.toFixed(2)),
        ratePerKmPerTon,
      },
    };
  }

  /**
   * Core Decision Engine: Evaluate markets and return ranked net-revenue recommendations
   */
  static async evaluateSellingOptions({ cropName, quantity, unit = 'kg', originWoreda = 'Jimma' }) {
    if (!cropName || !quantity) {
      throw new Error('Both cropName and quantity are required to calculate net revenue.');
    }

    // 1. Normalize quantity into Kilograms
    let weightKg = parseFloat(quantity);
    if (unit.toLowerCase() === 'quintal' || unit.toLowerCase() === 'kuntal') {
      weightKg = weightKg * 100.0;
    } else if (unit.toLowerCase() === 'ton') {
      weightKg = weightKg * 1000.0;
    }

    if (weightKg <= 0) {
      throw new Error('Quantity must be greater than zero.');
    }

    // 2. Normalize Crop Name
    const lookupKey = cropName.trim().toLowerCase();
    const cropMeta = this.CROP_DICTIONARY[lookupKey] || {
      name: cropName.trim(),
      oromoo: cropName.trim(),
      type: 'Agricultural Produce',
    };

    // 3. Query all active Benchmark Markets from MongoDB
    const markets = await MarketBenchmark.find({ isActive: true });
    if (!markets || markets.length === 0) {
      throw new Error('No benchmark markets found in database. Please run seeder.');
    }

    const normalizedOrigin = originWoreda.trim().toLowerCase();

    // 4. Compute Net Revenue for every candidate market
    const comparisons = [];

    for (const market of markets) {
      // Find commodity price for requested crop
      const commodity = market.commodityPrices.find(
        (c) => c.cropName.toLowerCase() === cropMeta.name.toLowerCase()
      );

      if (!commodity) continue;

      // Determine road distance from farmer's origin woreda
      let distanceKm = market.defaultDistanceKm;
      if (market.distanceMatrixKm && market.distanceMatrixKm.size > 0) {
        for (const [woredaKey, dist] of market.distanceMatrixKm.entries()) {
          if (normalizedOrigin.includes(woredaKey.toLowerCase())) {
            distanceKm = dist;
            break;
          }
        }
      }

      const grossRevenue = parseFloat((commodity.pricePerKg * weightKg).toFixed(2));
      const transportCostObj = this.calculateTransportCost(
        distanceKm,
        weightKg,
        market.roadQualityFactor,
        market.baseTransitFee
      );
      const transportCost = transportCostObj.totalCost;
      const netRevenue = parseFloat((grossRevenue - transportCost).toFixed(2));
      const netPricePerKg = parseFloat((netRevenue / weightKg).toFixed(2));

      comparisons.push({
        marketId: market.id,
        marketCode: market.marketCode,
        marketName: market.name,
        marketNameAfaanOromoo: market.nameAfaanOromoo,
        region: market.region,
        zone: market.zone,
        isPrimaryLocalMarket: market.isPrimaryLocalMarket,
        distanceKm,
        cropName: cropMeta.name,
        cropNameAfaanOromoo: cropMeta.oromoo,
        qualityGrade: commodity.qualityGrade,
        nominalPricePerKg: commodity.pricePerKg,
        grossRevenue,
        transportCost,
        transportCostBreakdown: transportCostObj.breakdown,
        netRevenue,
        netPricePerKg,
        priceTrend: commodity.trend,
        lastPriceUpdated: commodity.updatedAt,
      });
    }

    if (comparisons.length === 0) {
      throw new Error(`No market prices recorded for crop: ${cropMeta.name}`);
    }

    // 5. Rank candidate markets by Net Revenue (Descending)
    comparisons.sort((a, b) => b.netRevenue - a.netRevenue);

    // 6. Tag best market and rank positions
    comparisons.forEach((item, index) => {
      item.rank = index + 1;
      item.isRecommended = index === 0;
    });

    const recommended = comparisons[0];

    // 7. Baseline comparison against local primary market
    const localMarket = comparisons.find((c) => c.isPrimaryLocalMarket) || comparisons[comparisons.length - 1];
    const netUpliftVsLocal = parseFloat((recommended.netRevenue - localMarket.netRevenue).toFixed(2));
    const upliftPercentage = localMarket.netRevenue > 0
      ? parseFloat(((netUpliftVsLocal / localMarket.netRevenue) * 100).toFixed(1))
      : 0;

    // 8. Generate Bilingual Decision Explanations (English & Afaan Oromoo)
    const explanations = this.generateExplanations({
      cropMeta,
      weightKg,
      recommended,
      localMarket,
      netUpliftVsLocal,
      upliftPercentage,
      allComparisons: comparisons,
    });

    // 9. Query active buyers in the recommended target destination
    const activeBuyers = await User.find({
      role: 'buyer',
      location: new RegExp(recommended.marketName.split(' ')[0], 'i'),
    })
      .select('fullName phone location')
      .limit(3)
      .lean();

    return {
      query: {
        crop: cropMeta.name,
        cropAfaanOromoo: cropMeta.oromoo,
        quantityRequested: parseFloat(quantity),
        unitRequested: unit,
        weightKg,
        originWoreda,
      },
      summary: {
        recommendedMarket: recommended.marketName,
        recommendedMarketAfaanOromoo: recommended.marketNameAfaanOromoo,
        bestNetRevenue: recommended.netRevenue,
        bestNetPricePerKg: recommended.netPricePerKg,
        nominalPriceAtBestMarket: recommended.nominalPricePerKg,
        transportCostToBestMarket: recommended.transportCost,
        netUpliftVsLocal,
        upliftPercentage,
      },
      explanations,
      activeBuyers: activeBuyers.map((b) => ({
        id: b._id,
        name: b.fullName,
        phone: b.phone,
        location: b.location,
      })),
      comparisons,
    };
  }

  /**
   * Generate human-understandable economic explanations in English and Afaan Oromoo
   */
  static generateExplanations({
    cropMeta,
    weightKg,
    recommended,
    localMarket,
    netUpliftVsLocal,
    upliftPercentage,
    allComparisons,
  }) {
    // Find highest nominal price market (often Addis Ababa) to show comparison
    const highestNominal = [...allComparisons].sort((a, b) => b.nominalPricePerKg - a.nominalPricePerKg)[0];

    let enInsight = '';
    let orInsight = '';

    if (highestNominal.marketCode !== recommended.marketCode) {
      enInsight = `Even though ${highestNominal.marketName} has the highest nominal price (${highestNominal.nominalPricePerKg} ETB/kg), high transportation costs (${highestNominal.transportCost.toLocaleString()} ETB) erode your profit. Selling at ${recommended.marketName} delivers the highest net take-home revenue of ${recommended.netRevenue.toLocaleString()} ETB (${(recommended.netRevenue - highestNominal.netRevenue).toLocaleString()} ETB more than ${highestNominal.marketName}).`;

      orInsight = `Gatiin ${highestNominal.marketNameAfaanOromoo} ol’aanaa (${highestNominal.nominalPricePerKg} ETB/kg) ta'us, baasiin geejjibaa guddaan (${highestNominal.transportCost.toLocaleString()} ETB) bu'aa keessan hir'isa. ${recommended.marketNameAfaanOromoo}tti gurguruun galii qulqulluu ${recommended.netRevenue.toLocaleString()} ETB isa caalu isiniif kenna (${highestNominal.marketNameAfaanOromoo} irra ${(recommended.netRevenue - highestNominal.netRevenue).toLocaleString()} ETB caala).`;
    } else {
      enInsight = `${recommended.marketName} provides the best net return for your ${weightKg} kg of ${cropMeta.name}, generating ${recommended.netRevenue.toLocaleString()} ETB in pocket after deducting ${recommended.transportCost.toLocaleString()} ETB in transport fees.`;

      orInsight = `${recommended.marketNameAfaanOromoo} ${cropMeta.oromoo} kiiloo ${weightKg} keessaniif baasii geejjibaa ${recommended.transportCost.toLocaleString()} ETB erga hir'iseen booda galii qulqulluu ${recommended.netRevenue.toLocaleString()} ETB isa gaarii kenna.`;
    }

    let enUplift = '';
    let orUplift = '';
    if (recommended.marketCode !== localMarket.marketCode && netUpliftVsLocal > 0) {
      enUplift = `Choosing ${recommended.marketName} instead of your nearest market (${localMarket.marketName}) increases your profit by ${netUpliftVsLocal.toLocaleString()} ETB (+${upliftPercentage}%).`;
      orUplift = `Gabaa dhiyoo (${localMarket.marketNameAfaanOromoo}) dhiistanii ${recommended.marketNameAfaanOromoo} filachuun bu'aa keessan ${netUpliftVsLocal.toLocaleString()} ETB (+%${upliftPercentage}) dabala.`;
    } else {
      enUplift = `Selling locally at ${localMarket.marketName} is your most profitable choice because transporting further would cost more than the price difference.`;
      orUplift = `Gabaa dhiyoo ${localMarket.marketNameAfaanOromoo}tti gurguruun filannoo caalmaa dha, sababiin isaas fageenyatti fe'uun gatii dabalu caalaa baasii qabaata.`;
    }

    return {
      english: {
        headline: `Sell at ${recommended.marketName} for Highest Profit`,
        recommendation: enInsight,
        upliftSummary: enUplift,
      },
      afaanOromoo: {
        headline: `Bu'aa Ol'aanaaf ${recommended.marketNameAfaanOromoo}tti Gurguraa`,
        recommendation: orInsight,
        upliftSummary: orUplift,
      },
    };
  }

  /**
   * Retrieve all supported priority crops with cross-market prices
   */
  static async getCropPriceOverview() {
    const markets = await MarketBenchmark.find({ isActive: true }).lean();
    const cropMap = {};

    for (const market of markets) {
      for (const commodity of market.commodityPrices) {
        if (!cropMap[commodity.cropName]) {
          cropMap[commodity.cropName] = {
            cropName: commodity.cropName,
            cropNameAfaanOromoo: commodity.cropNameAfaanOromoo,
            cropType: commodity.cropType,
            qualityGrade: commodity.qualityGrade,
            markets: [],
          };
        }

        cropMap[commodity.cropName].markets.push({
          marketId: market._id,
          marketCode: market.marketCode,
          marketName: market.name,
          pricePerKg: commodity.pricePerKg,
          trend: commodity.trend,
        });
      }
    }

    return Object.values(cropMap);
  }
}
