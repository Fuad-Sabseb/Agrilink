import { Farm } from '../models/Farm.js';
import { CropCycle } from '../models/CropCycle.js';
import { BuyerDemand } from '../models/BuyerDemand.js';
import { MarketBenchmark } from '../models/MarketBenchmark.js';
import { Produce } from '../models/Produce.js';
import { Cooperative } from '../models/Cooperative.js';
import { WoredaAgriculturalProfile } from '../models/WoredaAgriculturalProfile.js';
import { InstitutionalAlert } from '../models/InstitutionalAlert.js';

const AFAN_OROMOO_CROPS = {
  Coffee: 'Buna',
  Maize: 'Boqqolloo',
  Teff: 'Xaafii',
  Wheat: 'Qamadii',
  Potato: 'Dinnicha',
  Tomato: 'Timaatima',
  Carrot: 'Kaarotii',
};

export class InstitutionalService {
  /**
   * 1. Macro-Level Regional Agricultural Overview
   */
  static async getMacroDashboardOverview() {
    const [farms, cropCycles, demands, alerts, woredas, cooperatives] =
      await Promise.all([
        Farm.find({ zone: 'Jimma' }),
        CropCycle.find({}),
        BuyerDemand.find({ status: 'buying_now' }),
        InstitutionalAlert.find({ status: { $in: ['active', 'monitoring'] } }),
        WoredaAgriculturalProfile.find({ zone: 'Jimma' }),
        Cooperative.find({ zone: 'Jimma' }),
      ]);

    // Calculate total cultivated land
    let totalCultivatedHectares = 0;
    for (const f of farms) {
      totalCultivatedHectares += f.sizeHectares || 0;
    }

    // Calculate total projected output (Quintals)
    let totalProjectedOutputQuintals = 0;
    const cropDistribution = {};

    for (const cc of cropCycles) {
      const qtl = cc.expectedYieldQuintals || cc.projectedYieldQuintals || Number(((cc.expectedYieldKg || 0) / 100).toFixed(2));
      totalProjectedOutputQuintals += qtl;

      const crop = cc.cropName || 'Other';
      if (!cropDistribution[crop]) {
        cropDistribution[crop] = {
          cropName: crop,
          cropNameAfaanOromoo: cc.cropNameAfaanOromoo || AFAN_OROMOO_CROPS[crop] || crop,
          areaHectares: 0,
          areaQadaa: 0,
          projectedQuintals: 0,
          plotsCount: 0,
        };
      }
      cropDistribution[crop].areaHectares += cc.areaHectares || 0;
      cropDistribution[crop].areaQadaa += cc.areaQadaa || (cc.areaHectares || 0) * 4;
      cropDistribution[crop].projectedQuintals += qtl;
      cropDistribution[crop].plotsCount += 1;
    }

    // Buyer Demand trade volume in ETB
    let totalTradeDemandETB = 0;
    for (const d of demands) {
      const kg = d.targetQuantityKg || d.minimumQuantityKg || 1000;
      totalTradeDemandETB += (d.priceOfferPerKg || 0) * kg;
    }

    // Total estimated farming households across Jimma Zone
    let totalHouseholds = 0;
    let totalArableHectaresWoredaBaseline = 0;
    for (const w of woredas) {
      totalHouseholds += w.farmingHouseholds || 0;
      totalArableHectaresWoredaBaseline += w.arableLandHectares || 0;
    }

    const criticalAlertsCount = alerts.filter((a) => a.severity === 'critical').length;

    return {
      success: true,
      timestamp: new Date().toISOString(),
      zone: 'Jimma Zone, Oromia',
      zoneAfaanOromoo: 'Godina Jimmaa, Oromiyaa',
      kpis: {
        totalCultivatedHectares: Number(totalCultivatedHectares.toFixed(2)),
        totalCultivatedQadaa: Number((totalCultivatedHectares * 4).toFixed(2)),
        totalRegionalArableHectares: totalArableHectaresWoredaBaseline,
        totalProjectedOutputQuintals: Math.round(totalProjectedOutputQuintals),
        totalActiveFarms: farms.length,
        totalFarmingHouseholds: totalHouseholds,
        activeCooperativesCount: cooperatives.length,
        activeBuyerDemandsCount: demands.length,
        totalTradeDemandETB: Math.round(totalTradeDemandETB),
        activeAlertsCount: alerts.length,
        criticalAlertsCount,
      },
      cropBreakdown: Object.values(cropDistribution).map((c) => ({
        ...c,
        areaHectares: Number(c.areaHectares.toFixed(2)),
        areaQadaa: Number(c.areaQadaa.toFixed(2)),
        projectedQuintals: Math.round(c.projectedQuintals),
      })),
      woredasMonitoredCount: woredas.length,
      woredas: woredas.map((w) => ({
        woreda: w.woreda,
        woredaAfaanOromoo: w.woredaAfaanOromoo,
        dominantSoil: w.dominantSoil,
        foodSecurityStatus: w.foodSecurityVulnerability,
      })),
    };
  }

  /**
   * 2. Regional Supply vs. Demand Heatmap (Woreda Surplus / Deficit Matrix)
   */
  static async getSupplyDemandHeatmap({ crop = 'All' } = {}) {
    const [woredas, farms, cropCycles, demands, produces] = await Promise.all([
      WoredaAgriculturalProfile.find({ zone: 'Jimma' }),
      Farm.find({ zone: 'Jimma' }),
      CropCycle.find({}),
      BuyerDemand.find({ status: 'buying_now' }),
      Produce.find({ status: 'available' }),
    ]);

    // Map farmId to woreda
    const farmWoredaMap = {};
    for (const f of farms) {
      farmWoredaMap[f._id] = f.woreda;
    }

    const heatmap = woredas.map((w) => {
      let supplyQuintals = 0;
      let supplyValueETB = 0;
      let demandQuintals = 0;
      let demandValueETB = 0;

      // Filter crop cycles in this woreda
      const woredaCycles = cropCycles.filter((cc) => {
        const matchesWoreda = farmWoredaMap[cc.farmId] === w.woreda;
        if (!matchesWoreda) return false;
        if (crop !== 'All' && cc.cropName.toLowerCase() !== crop.toLowerCase()) return false;
        return true;
      });

      for (const cc of woredaCycles) {
        supplyQuintals += cc.expectedYieldQuintals || cc.projectedYieldQuintals || Number(((cc.expectedYieldKg || 0) / 100).toFixed(2));
      }

      // Add actual listed produce stock
      const woredaProduce = produces.filter((p) => {
        const matchesWoreda = p.location?.includes(w.woreda);
        if (!matchesWoreda) return false;
        if (crop !== 'All' && p.cropName?.toLowerCase() !== crop.toLowerCase()) return false;
        return true;
      });

      for (const p of woredaProduce) {
        const qtl = (p.quantityKg || 0) / 100;
        supplyQuintals += qtl;
        supplyValueETB += (p.pricePerKg || 40) * (p.quantityKg || 0);
      }

      // Buyer demand in this woreda
      const woredaDemands = demands.filter((d) => {
        const matchesWoreda =
          d.buyingPostLocation?.toLowerCase().includes(w.woreda.toLowerCase()) ||
          d.buyer?.businessName?.toLowerCase().includes(w.woreda.toLowerCase());
        if (crop !== 'All' && d.cropName?.toLowerCase() !== crop.toLowerCase()) return false;
        return matchesWoreda;
      });

      for (const d of woredaDemands) {
        const qtl = (d.targetQuantityKg || d.minimumQuantityKg || 1000) / 100;
        demandQuintals += qtl;
        demandValueETB += (d.priceOfferPerKg || 40) * qtl * 100;
      }

      // Factor in demographic local consumption baseline
      // Staple crops (Maize, Teff, Wheat, Potato) have mandatory local food security demand
      const isStapleCrop = ['Maize', 'Teff', 'Wheat', 'Potato', 'All'].includes(crop);
      const demographicBaseDemand = isStapleCrop
        ? Math.round(w.annualStapleDemandQuintals / 12) // monthly baseline
        : 150;

      demandQuintals += demographicBaseDemand;

      // Net Balance
      const netBalanceQuintals = Math.round(supplyQuintals - demandQuintals);
      let balanceStatus = 'balanced';
      let riskLevel = 'low';

      if (netBalanceQuintals > 50) {
        balanceStatus = 'surplus';
        riskLevel = 'optimal_export';
      } else if (netBalanceQuintals < -100) {
        balanceStatus = 'deficit';
        riskLevel = netBalanceQuintals < -500 ? 'critical_deficit' : 'moderate_deficit';
      }

      return {
        woreda: w.woreda,
        woredaAfaanOromoo: w.woredaAfaanOromoo,
        coordinates: w.coordinates,
        agroEcologicalZone: w.agroEcologicalZone,
        dominantSoil: w.dominantSoil,
        population: w.estimatedPopulation,
        farmingHouseholds: w.farmingHouseholds,
        cropFiltered: crop,
        metrics: {
          supplyQuintals: Math.round(supplyQuintals),
          demandQuintals: Math.round(demandQuintals),
          netBalanceQuintals,
          balanceStatus, // 'surplus' | 'balanced' | 'deficit'
          riskLevel,
          surplusOpportunityETB:
            netBalanceQuintals > 0 ? Math.round(netBalanceQuintals * 100 * 45) : 0,
        },
      };
    });

    // Sort by largest deficit to highlight early-warning vulnerability first
    heatmap.sort((a, b) => a.metrics.netBalanceQuintals - b.metrics.netBalanceQuintals);

    const totalSurplusQtl = heatmap
      .filter((h) => h.metrics.netBalanceQuintals > 0)
      .reduce((sum, h) => sum + h.metrics.netBalanceQuintals, 0);

    const totalDeficitQtl = heatmap
      .filter((h) => h.metrics.netBalanceQuintals < 0)
      .reduce((sum, h) => sum + Math.abs(h.metrics.netBalanceQuintals), 0);

    return {
      success: true,
      cropFilter: crop,
      summary: {
        totalSurplusQuintals: totalSurplusQtl,
        totalDeficitQuintals: totalDeficitQtl,
        netRegionalBalanceQuintals: totalSurplusQtl - totalDeficitQtl,
        woredasInDeficitCount: heatmap.filter((h) => h.metrics.balanceStatus === 'deficit').length,
        woredasInSurplusCount: heatmap.filter((h) => h.metrics.balanceStatus === 'surplus').length,
      },
      heatmap,
    };
  }

  /**
   * 3. Price Volatility & Market Surveillance Engine
   */
  static async getPriceVolatilityAnalytics() {
    const markets = await MarketBenchmark.find({ isActive: true });

    // Aggregate prices per crop across all Jimma Zone benchmark markets
    const cropMarketMap = {};

    for (const m of markets) {
      for (const cp of m.commodityPrices) {
        const cName = cp.cropName;
        if (!cropMarketMap[cName]) {
          cropMarketMap[cName] = {
            cropName: cName,
            cropNameAfaanOromoo: cp.cropNameAfaanOromoo || AFAN_OROMOO_CROPS[cName] || cName,
            prices: [],
          };
        }
        cropMarketMap[cName].prices.push({
          marketName: m.name,
          marketNameAfaanOromoo: m.nameAfaanOromoo,
          marketCode: m.marketCode,
          woreda: m.woreda,
          pricePerKg: cp.pricePerKg,
          trend: cp.trend,
        });
      }
    }

    const volatilityReport = [];

    for (const [crop, data] of Object.entries(cropMarketMap)) {
      const priceList = data.prices.map((p) => p.pricePerKg);
      if (priceList.length === 0) continue;

      const minPrice = Math.min(...priceList);
      const maxPrice = Math.max(...priceList);
      const avgPrice = Number((priceList.reduce((a, b) => a + b, 0) / priceList.length).toFixed(2));
      const priceSpreadETB = Number((maxPrice - minPrice).toFixed(2));
      const volatilityPercentage = Number(((priceSpreadETB / avgPrice) * 100).toFixed(1));

      let volatilityTier = 'low_stable';
      let earlyWarningFlag = false;
      let advisoryMessage = '';

      if (volatilityPercentage >= 15.0) {
        volatilityTier = 'high_volatile';
        earlyWarningFlag = true;
        advisoryMessage = `High spatial price dispersion (${volatilityPercentage}%): Recommend targeted supply routing to lower-cost deficit centers.`;
      } else if (volatilityPercentage >= 8.0) {
        volatilityTier = 'moderate';
        advisoryMessage = 'Moderate seasonal fluctuation across Jimma woredas.';
      } else {
        advisoryMessage = 'Normal integrated commodity pricing.';
      }

      volatilityReport.push({
        cropName: crop,
        cropNameAfaanOromoo: data.cropNameAfaanOromoo,
        minPrice,
        maxPrice,
        avgPrice,
        priceSpreadETB,
        volatilityPercentage,
        volatilityTier,
        earlyWarningFlag,
        advisoryMessage,
        marketBreakdown: data.prices,
      });
    }

    // Sort descending by volatility percentage
    volatilityReport.sort((a, b) => b.volatilityPercentage - a.volatilityPercentage);

    return {
      success: true,
      monitoredMarketsCount: markets.length,
      markets: markets.map((m) => ({
        marketCode: m.marketCode,
        name: m.name,
        nameAfaanOromoo: m.nameAfaanOromoo,
        woreda: m.woreda,
      })),
      volatilityReport,
      flaggedCropsCount: volatilityReport.filter((v) => v.earlyWarningFlag).length,
    };
  }

  /**
   * 4. Regional Production, Soil Type & Yield Analytics
   */
  static async getProductionAndYieldAnalytics() {
    const [cropCycles, farms] = await Promise.all([
      CropCycle.find({}),
      Farm.find({ zone: 'Jimma' }),
    ]);

    const farmMap = {};
    for (const f of farms) {
      farmMap[f._id] = f;
    }

    const cropYields = {};
    const soilAnalytics = {
      nitisol_red_clay: {
        name: 'Red Nitisol (Biyyee Diimaa)',
        hectares: 0,
        quintals: 0,
        crops: {},
      },
      vertisol_black_clay: {
        name: 'Black Vertisol (Koticha)',
        hectares: 0,
        quintals: 0,
        crops: {},
      },
    };

    const growthStages = {
      seedling: 0,
      vegetative: 0,
      flowering: 0,
      maturation: 0,
      harvest_ready: 0,
      harvested: 0,
    };

    for (const cc of cropCycles) {
      const crop = cc.cropName || 'Other';
      const qtl = cc.expectedYieldQuintals || cc.projectedYieldQuintals || Number(((cc.expectedYieldKg || 0) / 100).toFixed(2));
      const ha = cc.areaHectares || 0;

      if (!cropYields[crop]) {
        cropYields[crop] = {
          cropName: crop,
          cropNameAfaanOromoo: cc.cropNameAfaanOromoo || AFAN_OROMOO_CROPS[crop] || crop,
          totalHectares: 0,
          totalQuintals: 0,
          avgYieldQtlPerHa: 0,
        };
      }
      cropYields[crop].totalHectares += ha;
      cropYields[crop].totalQuintals += qtl;

      // Soil type correlation
      const farm = farmMap[cc.farmId];
      const soilType = farm?.soilType === 'vertisol_black_clay' ? 'vertisol_black_clay' : 'nitisol_red_clay';
      soilAnalytics[soilType].hectares += ha;
      soilAnalytics[soilType].quintals += qtl;
      soilAnalytics[soilType].crops[crop] = (soilAnalytics[soilType].crops[crop] || 0) + qtl;

      // Growth stage pipeline
      const stage = cc.growthStage || 'vegetative';
      if (growthStages[stage] !== undefined) {
        growthStages[stage] += qtl;
      }
    }

    // Compute average yields
    const cropYieldArray = Object.values(cropYields).map((c) => ({
      ...c,
      totalHectares: Number(c.totalHectares.toFixed(2)),
      totalQuintals: Math.round(c.totalQuintals),
      avgYieldQtlPerHa:
        c.totalHectares > 0
          ? Number((c.totalQuintals / c.totalHectares).toFixed(2))
          : 0,
    }));

    return {
      success: true,
      cropYields: cropYieldArray,
      soilAnalytics: {
        nitisolRedClay: {
          ...soilAnalytics.nitisol_red_clay,
          hectares: Number(soilAnalytics.nitisol_red_clay.hectares.toFixed(2)),
          quintals: Math.round(soilAnalytics.nitisol_red_clay.quintals),
        },
        vertisolBlackClay: {
          ...soilAnalytics.vertisol_black_clay,
          hectares: Number(soilAnalytics.vertisol_black_clay.hectares.toFixed(2)),
          quintals: Math.round(soilAnalytics.vertisol_black_clay.quintals),
        },
      },
      growthStagePipelineQuintals: growthStages,
    };
  }

  /**
   * 5. Early Warning & Food Security Alert Management
   */
  static async getAlerts({ status = 'active', severity, alertType } = {}) {
    const filter = {};
    if (status && status !== 'all') filter.status = status;
    if (severity) filter.severity = severity;
    if (alertType) filter.alertType = alertType;

    const alerts = await InstitutionalAlert.find(filter).sort({
      createdAt: -1,
    });

    return {
      success: true,
      count: alerts.length,
      alerts: alerts.map((a) => a.toJSON()),
    };
  }

  /**
   * Create an Institutional Alert
   */
  static async createAlert(data, user) {
    const count = await InstitutionalAlert.countDocuments();
    const alertCode = `ALT-JIMMA-${(count + 1).toString().padStart(4, '0')}`;

    const newAlert = await InstitutionalAlert.create({
      alertCode,
      alertType: data.alertType,
      severity: data.severity || 'warning',
      title: data.title,
      titleAfaanOromoo: data.titleAfaanOromoo,
      targetWoredas: Array.isArray(data.targetWoredas) ? data.targetWoredas : [data.targetWoredas],
      targetCrop: data.targetCrop || 'General',
      description: data.description,
      descriptionAfaanOromoo: data.descriptionAfaanOromoo,
      recommendedAction: data.recommendedAction,
      recommendedActionAfaanOromoo: data.recommendedActionAfaanOromoo,
      issuedBy: {
        userId: user?.id || 'user_bureau_derartu',
        name: user?.fullName || 'Jimma Zone Agriculture Bureau Early Warning Dept',
        role: user?.role || 'bureau',
        institution: 'Jimma Zone Agriculture & Rural Development Bureau',
      },
      metricPayload: data.metricPayload || {},
      status: 'active',
    });

    return {
      success: true,
      alert: newAlert.toJSON(),
    };
  }

  /**
   * Resolve an alert
   */
  static async resolveAlert(alertCode, { resolutionNotes }, user) {
    const alert = await InstitutionalAlert.findOne({ alertCode });
    if (!alert) {
      throw new Error(`Alert with code ${alertCode} not found.`);
    }

    alert.status = 'resolved';
    alert.resolvedAt = new Date();
    alert.resolutionNotes = resolutionNotes || 'Resolved following market intervention.';
    alert.resolvedBy = user?.fullName || 'Jimma Zone Bureau Official';
    await alert.save();

    return {
      success: true,
      message: 'Alert resolved successfully.',
      alert: alert.toJSON(),
    };
  }

  /**
   * 6. Executive Briefing Export
   */
  static async exportExecutiveReport() {
    const [overview, heatmap, volatility, production] = await Promise.all([
      this.getMacroDashboardOverview(),
      this.getSupplyDemandHeatmap(),
      this.getPriceVolatilityAnalytics(),
      this.getProductionAndYieldAnalytics(),
    ]);

    return {
      success: true,
      generatedAt: new Date().toISOString(),
      reportTitle: 'Jimma Zone Agricultural Value Chain & Food Security Intelligence Brief',
      reportTitleAfaanOromoo: 'Gabaasa Qorannoo fi Eegumsa Midhaan Nyaataa Godina Jimmaa',
      executiveAuthority: 'Jimma Zone Agriculture & Rural Development Bureau',
      academicPartner: 'Jimma University College of Agriculture and Veterinary Medicine (JUCAVM)',
      overview,
      heatmapSummary: heatmap.summary,
      topDeficitWoredas: heatmap.heatmap.filter((h) => h.metrics.balanceStatus === 'deficit').slice(0, 3),
      topSurplusWoredas: heatmap.heatmap.filter((h) => h.metrics.balanceStatus === 'surplus').slice(0, 3),
      volatility: volatility.volatilityReport,
      productionBreakdown: production.cropYields,
    };
  }
}
