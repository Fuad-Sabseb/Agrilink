import { RouteCorridor } from '../models/RouteCorridor.js';
import { CheckpointTariff } from '../models/CheckpointTariff.js';
import { VillageCollector } from '../models/VillageCollector.js';
import { VehicleFleet } from '../models/VehicleFleet.js';
import { LogisticsService } from '../services/logisticsService.js';

export class LogisticsController {
  /**
   * List transport route corridors
   */
  static async listCorridors(req, res, next) {
    try {
      const corridors = await RouteCorridor.find({ isActive: true }).sort({ distanceKm: 1 });
      return res.status(200).json({
        success: true,
        count: corridors.length,
        corridors: corridors.map((c) => c.toJSON()),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * List crowd-verified checkpoints and tariffs (Kellaa Ledger)
   */
  static async listCheckpoints(req, res, next) {
    try {
      const { woreda, status } = req.query;
      const filter = { isActive: true };
      if (woreda) filter.locationWoreda = new RegExp(woreda, 'i');
      if (status) filter.currentStatus = status;

      const checkpoints = await CheckpointTariff.find(filter).sort({ upvotes: -1, currentLiveFeeETB: -1 });

      return res.status(200).json({
        success: true,
        count: checkpoints.length,
        checkpoints: checkpoints.map((c) => c.toJSON()),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Transporter submits crowd-sourced fee report for a checkpoint
   */
  static async reportCheckpointTariff(req, res, next) {
    try {
      const { code } = req.params;
      const {
        reportedFeeETB,
        delayMinutes,
        congestionLevel,
        comment,
        vehicleType,
      } = req.body;

      if (reportedFeeETB === undefined || isNaN(Number(reportedFeeETB))) {
        return res.status(400).json({
          success: false,
          error: 'reportedFeeETB is required and must be a number',
        });
      }

      const updated = await LogisticsService.reportCheckpoint({
        checkpointCode: code,
        transporterId: req.user?.id || 'user_transporter_haile',
        transporterName: req.user?.fullName || 'Haile Gebrselassie',
        vehicleType: vehicleType || 'isuzu_npr',
        reportedFeeETB: Number(reportedFeeETB),
        delayMinutes: Number(delayMinutes) || 15,
        congestionLevel: congestionLevel || 'active_moderate_delay',
        comment: comment || '',
      });

      return res.status(200).json({
        success: true,
        message: `Kellaa fee report recorded for ${updated.name}`,
        checkpoint: updated,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Transporter confirms / upvotes checkpoint report
   */
  static async confirmCheckpointReport(req, res, next) {
    try {
      const { code } = req.params;
      const updated = await LogisticsService.confirmCheckpointReport(code);

      return res.status(200).json({
        success: true,
        message: 'Checkpoint report confirmed and upvoted',
        checkpoint: updated,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Flagship Landed-Cost Route Estimator
   */
  static async estimateLandedCost(req, res, next) {
    try {
      const {
        originWoreda,
        destinationWoreda,
        cropName,
        quantityKg,
        farmgatePricePerKg,
        preferredCarrierType,
      } = req.body;

      const estimation = await LogisticsService.estimateLandedCost({
        originWoreda,
        destinationWoreda,
        cropName,
        quantityKg,
        farmgatePricePerKg,
        preferredCarrierType,
      });

      return res.status(200).json(estimation);
    } catch (error) {
      next(error);
    }
  }

  /**
   * List Verified Village Collectors (Aggregators)
   */
  static async listVillageCollectors(req, res, next) {
    try {
      const { woreda, crop } = req.query;
      const filter = { isVerified: true, zone: 'Jimma' };
      if (woreda) filter.woreda = new RegExp(woreda, 'i');
      if (crop) filter.supportedCrops = new RegExp(crop, 'i');

      const collectors = await VillageCollector.find(filter).sort({ rating: -1, totalTransactions: -1 });

      return res.status(200).json({
        success: true,
        count: collectors.length,
        collectors: collectors.map((c) => c.toJSON()),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Register as a Village Collector
   */
  static async createVillageCollector(req, res, next) {
    try {
      const {
        name,
        nameAfaanOromoo,
        contactPerson,
        phone,
        woreda,
        kebele,
        warehouseLocation,
        storageCapacityQuintals,
        commissionRateType = 'percentage',
        commissionRateValue = 2.5,
        supportedCrops,
      } = req.body;

      if (!name || !contactPerson || !phone || !woreda) {
        return res.status(400).json({
          success: false,
          error: 'Name, contactPerson, phone, and woreda are required',
        });
      }

      const collector = await VillageCollector.create({
        collectorCode: `COL-${woreda.slice(0, 3).toUpperCase()}-${Date.now().toString().slice(-4)}`,
        name,
        nameAfaanOromoo: nameAfaanOromoo || name,
        contactPerson,
        phone,
        zone: 'Jimma',
        woreda,
        kebele: kebele || '',
        warehouseLocation: warehouseLocation || `${woreda} Village Center`,
        storageCapacityQuintals: Number(storageCapacityQuintals) || 500,
        serviceCommissionRate: {
          rateType: commissionRateType,
          value: Number(commissionRateValue),
        },
        supportedCrops: supportedCrops || ['Coffee', 'Maize', 'Teff'],
        verificationBadge: 'bureau_certified',
        isVerified: true,
      });

      return res.status(201).json({
        success: true,
        message: 'Village collector registered successfully',
        collector: collector.toJSON(),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * List Transporter Vehicle Fleet
   */
  static async listFleet(req, res, next) {
    try {
      const { carrierType, availabilityStatus, woreda } = req.query;
      const filter = {};
      if (carrierType) filter.carrierType = carrierType;
      if (availabilityStatus) filter.availabilityStatus = availabilityStatus;
      if (woreda) filter.baseWoreda = new RegExp(woreda, 'i');

      const fleet = await VehicleFleet.find(filter).sort({ maxPayloadKg: 1 });

      return res.status(200).json({
        success: true,
        count: fleet.length,
        fleet: fleet.map((v) => v.toJSON()),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Match available vehicle fleet for shipment
   */
  static async matchFleet(req, res, next) {
    try {
      const {
        originWoreda,
        destinationWoreda,
        weightKg,
        cropName,
        isPerishable,
      } = req.body;

      const matched = await LogisticsService.matchFleet({
        originWoreda,
        destinationWoreda,
        weightKg,
        cropName,
        isPerishable,
      });

      return res.status(200).json(matched);
    } catch (error) {
      next(error);
    }
  }
}
