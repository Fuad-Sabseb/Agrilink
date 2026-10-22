import { DecisionEngineService } from '../services/decisionEngineService.js';
import { MarketBenchmark } from '../models/MarketBenchmark.js';

export class DecisionEngineController {
  /**
   * Flagship recommendation: "Where Should I Sell?"
   * Computes Net Revenue = (Market Price * Volume) - Transport Cost
   */
  static async getRecommendation(req, res, next) {
    try {
      const cropName = req.body.cropName || req.query.cropName || req.query.crop;
      const quantity = req.body.quantity || req.query.quantity || req.query.volume;
      const unit = req.body.unit || req.query.unit || 'kg';
      const originWoreda = req.body.originWoreda || req.query.originWoreda || req.query.woreda || req.user?.woreda || 'Jimma';

      if (!cropName || !quantity) {
        return res.status(400).json({
          success: false,
          error: 'cropName and quantity are required to calculate where to sell.',
        });
      }

      const result = await DecisionEngineService.evaluateSellingOptions({
        cropName,
        quantity,
        unit,
        originWoreda,
      });

      return res.status(200).json({
        success: true,
        message: 'Where Should I Sell decision computed successfully',
        ...result,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * List all benchmark markets and distance matrices
   */
  static async listMarkets(req, res, next) {
    try {
      const markets = await MarketBenchmark.find({ isActive: true }).sort({ defaultDistanceKm: 1 });

      return res.status(200).json({
        success: true,
        count: markets.length,
        markets: markets.map((m) => m.toJSON()),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Cross-market price overview for all priority crops
   */
  static async getCropsOverview(req, res, next) {
    try {
      const crops = await DecisionEngineService.getCropPriceOverview();

      return res.status(200).json({
        success: true,
        count: crops.length,
        crops,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update or insert benchmark price for a crop in a market (Bureau / Admin)
   */
  static async updateMarketPrice(req, res, next) {
    try {
      const { marketCode, cropName, pricePerKg, qualityGrade, trend } = req.body;

      if (!marketCode || !cropName || pricePerKg === undefined) {
        return res.status(400).json({
          success: false,
          error: 'marketCode, cropName, and pricePerKg are required',
        });
      }

      const market = await MarketBenchmark.findOne({ marketCode: marketCode.toUpperCase() });
      if (!market) {
        return res.status(404).json({
          success: false,
          error: `Market with code ${marketCode} not found`,
        });
      }

      const cropEntry = market.commodityPrices.find(
        (c) => c.cropName.toLowerCase() === cropName.toLowerCase()
      );

      if (cropEntry) {
        cropEntry.pricePerKg = parseFloat(pricePerKg);
        if (qualityGrade) cropEntry.qualityGrade = qualityGrade;
        if (trend) cropEntry.trend = trend;
        cropEntry.updatedAt = new Date();
      } else {
        const cropDict = DecisionEngineService.CROP_DICTIONARY[cropName.toLowerCase()] || {
          name: cropName,
          oromoo: cropName,
          type: 'Grain',
        };

        market.commodityPrices.push({
          cropName: cropDict.name,
          cropNameAfaanOromoo: cropDict.oromoo,
          cropType: cropDict.type,
          pricePerKg: parseFloat(pricePerKg),
          qualityGrade: qualityGrade || 'Grade 1',
          trend: trend || '0.0%',
          updatedAt: new Date(),
        });
      }

      await market.save();

      return res.status(200).json({
        success: true,
        message: `Price for ${cropName} in ${market.name} updated successfully`,
        market: market.toJSON(),
      });
    } catch (error) {
      next(error);
    }
  }
}
