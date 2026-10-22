import { RouteCorridor } from '../models/RouteCorridor.js';
import { CheckpointTariff } from '../models/CheckpointTariff.js';
import { VehicleFleet } from '../models/VehicleFleet.js';
import { VillageCollector } from '../models/VillageCollector.js';

// Intra-Jimma Zone distance matrix (in km from Jimma Town center)
const JIMMA_DISTANCE_MATRIX_KM = {
  'Jimma Town': 0,
  Mana: 18,
  'Seka Chekorsa': 25,
  Gomma: 45,
  Agaro: 45,
  'Limmu Kosa': 62,
  Kersa: 22,
  Dedo: 32,
  'Omo Nada': 55,
  Gera: 85,
  'Shebe Senbo': 60,
  'Tiro Afeta': 68,
  'Chora Botor': 95,
};

const CARRIER_SPECS = {
  pickup: {
    name: 'Pickup (Hilux / D-Max)',
    nameAfaanOromoo: 'Konkolaataa Xiqqaa (Pickup)',
    maxPayloadKg: 1500,
    perKmRateETB: 18.0,
    handlingPerQuintalETB: 10.0,
    bestFor: 'Perishables, rapid small delivery (up to 15 Qtl)',
  },
  isuzu_npr: {
    name: 'Isuzu NPR (Short Truck)',
    nameAfaanOromoo: 'Isuzuu Gabaabaa (NPR)',
    maxPayloadKg: 5000,
    perKmRateETB: 28.0,
    handlingPerQuintalETB: 12.0,
    bestFor: 'General grain, coffee lots (up to 50 Qtl)',
  },
  fsr_truck: {
    name: 'FSR Truck (Long Isuzu)',
    nameAfaanOromoo: 'Isuzuu Dheeraa (FSR)',
    maxPayloadKg: 10000,
    perKmRateETB: 42.0,
    handlingPerQuintalETB: 14.0,
    bestFor: 'Medium bulk inter-woreda haulage (up to 100 Qtl)',
  },
  heavy_truck: {
    name: 'Heavy Freight Truck (Iveco / Sino)',
    nameAfaanOromoo: 'Konkolaataa Guddicha (Heavy)',
    maxPayloadKg: 25000,
    perKmRateETB: 68.0,
    handlingPerQuintalETB: 15.0,
    bestFor: 'Large cooperative union aggregation (up to 250 Qtl)',
  },
};

export class LogisticsService {
  /**
   * Determine suitable carrier type based on payload
   */
  static selectBestCarrierType(weightKg) {
    if (weightKg <= 1500) return 'pickup';
    if (weightKg <= 5000) return 'isuzu_npr';
    if (weightKg <= 10000) return 'fsr_truck';
    return 'heavy_truck';
  }

  /**
   * Calculate distance between two points in or connected to Jimma Zone
   */
  static calculateDistanceKm(origin, destination) {
    const origKm = JIMMA_DISTANCE_MATRIX_KM[origin] ?? 25;
    const destKm = JIMMA_DISTANCE_MATRIX_KM[destination] ?? 0;

    if (origin === destination) return 10; // Local intra-woreda distribution
    if (destKm === 0) return origKm; // Origin to Jimma Town
    if (origKm === 0) return destKm; // Jimma Town to Destination
    return origKm + destKm; // Woreda to Woreda via Jimma transit hub
  }

  /**
   * Flagship Landed-Cost Route Estimator
   */
  static async estimateLandedCost({
    originWoreda = 'Mana',
    destinationWoreda = 'Jimma Town',
    cropName = 'Maize',
    quantityKg = 3000,
    farmgatePricePerKg = 38.0,
    preferredCarrierType,
  }) {
    const weight = Math.max(Number(quantityKg) || 100, 10);
    const farmgatePerKg = Number(farmgatePricePerKg) || 35.0;
    const weightQuintals = Number((weight / 100).toFixed(2));

    // 1. Identify Corridor or Distance
    let corridor = await RouteCorridor.findOne({
      'origin.woreda': new RegExp(originWoreda, 'i'),
      'destination.woreda': new RegExp(destinationWoreda, 'i'),
      isActive: true,
    });

    let distanceKm = corridor?.distanceKm;
    let roadMultiplier = corridor?.roadConditionMultiplier ?? 1.15;
    let roadCondition = corridor?.roadCondition ?? 'gravel_compacted';

    if (!distanceKm) {
      distanceKm = this.calculateDistanceKm(originWoreda, destinationWoreda);
    }

    // 2. Carrier Fleet Selection
    const carrierKey = preferredCarrierType || this.selectBestCarrierType(weight);
    const carrierSpec = CARRIER_SPECS[carrierKey] || CARRIER_SPECS.isuzu_npr;

    // 3. Compute Base Freight Cost
    const baseFreightETB = Math.round(distanceKm * carrierSpec.perKmRateETB * roadMultiplier);

    // 4. Retrieve Checkpoint Tariffs (Kellaa Ledger) along Corridor
    const checkpoints = await CheckpointTariff.find({
      isActive: true,
      $or: [
        { locationWoreda: new RegExp(originWoreda, 'i') },
        { locationWoreda: new RegExp(destinationWoreda, 'i') },
        { locationWoreda: 'Jimma Town' },
      ],
    });

    let checkpointFeesTotalETB = 0;
    const checkpointsBreakdown = checkpoints.map((chk) => {
      let fee = chk.currentLiveFeeETB || chk.officialTariffETB;
      if (chk.feeUnit === 'per_quintal') {
        fee = Math.round(fee * weightQuintals);
      }
      checkpointFeesTotalETB += fee;
      return {
        code: chk.checkpointCode,
        name: chk.name,
        nameAfaanOromoo: chk.nameAfaanOromoo,
        woreda: chk.locationWoreda,
        type: chk.checkpointType,
        tariffETB: fee,
        unit: chk.feeUnit,
        status: chk.currentStatus,
        delayMinutes: chk.delayMinutesAvg,
      };
    });

    // 5. Handling Costs (Loading/Unloading)
    const handlingFeeETB = Math.round(weightQuintals * carrierSpec.handlingPerQuintalETB);

    // 6. Aggregate Total Logistics & Landed Cost
    const totalLogisticsCostETB = baseFreightETB + checkpointFeesTotalETB + handlingFeeETB;
    const logisticsCostPerKg = Number((totalLogisticsCostETB / weight).toFixed(2));
    const logisticsCostPerQuintal = Math.round(totalLogisticsCostETB / weightQuintals);

    const farmgateTotalETB = Math.round(weight * farmgatePerKg);
    const totalLandedCostETB = farmgateTotalETB + totalLogisticsCostETB;
    const landedCostPerKg = Number((totalLandedCostETB / weight).toFixed(2));
    const logisticsSharePercent = Number(((totalLogisticsCostETB / totalLandedCostETB) * 100).toFixed(1));

    // Localized advice string (Afaan Oromoo)
    const oromooAdvice = `Geejjibni ${originWoreda} irraa gara ${destinationWoreda}tti ${weight} kg (${weightQuintals} Qtl) ${cropName} konkolaataa ${carrierSpec.nameAfaanOromoo || carrierSpec.name}tiif baasii waliigalaa ${totalLogisticsCostETB.toLocaleString()} ETB (kiiloo tokkotti ${logisticsCostPerKg} ETB) ta'a.`;
    const englishAdvice = `Logistics for ${weight.toLocaleString()} kg (${weightQuintals} Qtl) of ${cropName} from ${originWoreda} to ${destinationWoreda} with ${carrierSpec.name} totals ${totalLogisticsCostETB.toLocaleString()} ETB (${logisticsCostPerKg} ETB/kg), yielding a final landed cost of ${landedCostPerKg} ETB/kg.`;

    return {
      success: true,
      parameters: {
        originWoreda,
        destinationWoreda,
        cropName,
        quantityKg: weight,
        quantityQuintals: weightQuintals,
        farmgatePricePerKg: farmgatePerKg,
        carrierType: carrierKey,
        carrierName: carrierSpec.name,
      },
      route: {
        distanceKm,
        roadCondition,
        roadMultiplier,
        estimatedTransitMinutes: Math.round((distanceKm / 40) * 60 + checkpointsBreakdown.reduce((sum, c) => sum + c.delayMinutes, 0)),
      },
      costBreakdown: {
        baseFreightETB,
        checkpointTariffsETB: checkpointFeesTotalETB,
        handlingFeeETB,
        totalLogisticsCostETB,
        logisticsCostPerKg,
        logisticsCostPerQuintal,
        farmgateTotalETB,
        totalLandedCostETB,
        landedCostPerKg,
        logisticsSharePercent,
      },
      checkpoints: checkpointsBreakdown,
      advisory: {
        afaanOromoo: oromooAdvice,
        english: englishAdvice,
      },
      calculatedAt: new Date().toISOString(),
    };
  }

  /**
   * Submit crowd-verified checkpoint report
   */
  static async reportCheckpoint({
    checkpointCode,
    transporterId,
    transporterName,
    vehicleType,
    reportedFeeETB,
    delayMinutes = 15,
    congestionLevel = 'active_moderate_delay',
    comment = '',
  }) {
    const chk = await CheckpointTariff.findOne({ checkpointCode: checkpointCode.toUpperCase() });
    if (!chk) {
      throw new Error(`Checkpoint ${checkpointCode} not found in Jimma Zone.`);
    }

    const report = {
      transporterId: transporterId || 'user_transporter_haile',
      transporterName: transporterName || 'Haile Gebrselassie',
      vehicleType: vehicleType || 'isuzu_npr',
      reportedFeeETB: Number(reportedFeeETB),
      delayMinutes: Number(delayMinutes) || 15,
      congestionLevel,
      comment: comment || '',
      reportedAt: new Date(),
    };

    chk.recentReports.unshift(report);
    if (chk.recentReports.length > 20) chk.recentReports.pop();

    chk.currentLiveFeeETB = Number(reportedFeeETB);
    chk.currentStatus = congestionLevel;
    chk.delayMinutesAvg = Number(delayMinutes);
    chk.crowdReportsCount += 1;
    chk.lastReportedAt = new Date();

    await chk.save();
    return chk.toJSON();
  }

  /**
   * Confirm / Upvote Checkpoint Tariff report
   */
  static async confirmCheckpointReport(checkpointCode) {
    const chk = await CheckpointTariff.findOne({ checkpointCode: checkpointCode.toUpperCase() });
    if (!chk) {
      throw new Error(`Checkpoint ${checkpointCode} not found.`);
    }

    chk.upvotes += 1;
    await chk.save();
    return chk.toJSON();
  }

  /**
   * Match available vehicle fleet for shipment
   */
  static async matchFleet({
    originWoreda = 'Mana',
    destinationWoreda = 'Jimma Town',
    weightKg = 3000,
    cropName = 'Maize',
    isPerishable = false,
  }) {
    const weight = Number(weightKg) || 1000;
    const filter = {
      availabilityStatus: 'available',
      maxPayloadKg: { $gte: weight },
    };

    if (isPerishable) {
      // Prefer vehicles suitable for perishables or refrigerated
    }

    const vehicles = await VehicleFleet.find(filter).sort({ maxPayloadKg: 1, rating: -1 });

    const distanceKm = this.calculateDistanceKm(originWoreda, destinationWoreda);

    const matches = vehicles.map((v) => {
      const estimatedFreight = Math.round(distanceKm * v.perKmBaseRateETB);
      const handlingFee = Math.round((weight / 100) * v.perQuintalHandlingRateETB);
      const totalEstimatedETB = estimatedFreight + handlingFee;

      return {
        vehicle: v.toJSON(),
        estimatedFreightETB: estimatedFreight,
        handlingFeeETB: handlingFee,
        totalCostETB: totalEstimatedETB,
        costPerKg: Number((totalEstimatedETB / weight).toFixed(2)),
        isOptimalFit: v.maxPayloadKg <= weight * 1.5,
        locationMatch: v.baseWoreda.toLowerCase() === originWoreda.toLowerCase(),
      };
    });

    return {
      success: true,
      query: { originWoreda, destinationWoreda, weightKg: weight, cropName },
      distanceKm,
      matchedVehiclesCount: matches.length,
      matches,
    };
  }
}
