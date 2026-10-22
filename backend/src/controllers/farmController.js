import { Farm } from '../models/Farm.js';
import { CropCycle } from '../models/CropCycle.js';
import { Cooperative } from '../models/Cooperative.js';
import { Order } from '../models/Order.js';
import { Produce } from '../models/Produce.js';
import { User } from '../models/User.js';

// Valid woredas strictly within Jimma Zone, Oromia
const VALID_JIMMA_WOREDAS = [
  'Mana',
  'Seka Chekorsa',
  'Gomma',
  'Limmu Kosa',
  'Kersa',
  'Dedo',
  'Omo Nada',
  'Jimma Town',
  'Agaro',
  'Gera',
  'Shebe Senbo',
  'Tiro Afeta',
  'Chora Botor',
];

const CROP_NAME_AFAN_OROMOO = {
  Coffee: 'Buna',
  Maize: 'Boqqolloo',
  Teff: 'Xaafii',
  Wheat: 'Qamadii',
  Potato: 'Dinnicha',
  Tomato: 'Timaatima',
  Carrot: 'Kaarotii',
};

/**
 * List farmer's farms
 */
export const listFarms = async (req, res) => {
  try {
    const farmerId = req.user?.id || req.query.farmerId || 'user_farmer_abebe';
    const farms = await Farm.find({ farmerId }).sort({ createdAt: -1 });

    // Ensure sizeHectares formatted as string for web client
    const formatted = farms.map((f) => {
      const obj = f.toJSON();
      obj.sizeHectares = String(f.sizeHectares);
      return obj;
    });

    res.status(200).json(formatted);
  } catch (error) {
    console.error('Error listing farms:', error);
    res.status(500).json({ success: false, message: 'Server error listing farms', error: error.message });
  }
};

/**
 * Get farm by ID
 */
export const getFarmById = async (req, res) => {
  try {
    const farm = await Farm.findById(req.params.id);
    if (!farm) {
      return res.status(404).json({ success: false, message: 'Farm not found' });
    }

    const cropRecords = await CropCycle.find({ farmId: farm._id });
    const formatted = farm.toJSON();
    formatted.sizeHectares = String(farm.sizeHectares);
    formatted.crops = cropRecords;

    res.status(200).json(formatted);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching farm', error: error.message });
  }
};

/**
 * Create a new farm (Strictly in Jimma Zone)
 */
export const createFarm = async (req, res) => {
  try {
    const farmerId = req.user?.id || 'user_farmer_abebe';
    const farmer = await User.findById(farmerId);

    const {
      name,
      sizeHectares,
      zone = 'Jimma',
      woreda,
      kebele,
      latitude,
      longitude,
      altitudeMeters,
      soilType,
      agroEcology,
      waterSource,
      cooperativeId,
      cooperativeName,
      cooperativeMembershipId,
    } = req.body;

    if (!name || !sizeHectares || !woreda) {
      return res.status(400).json({
        success: false,
        message: 'Name, size in hectares, and woreda are required',
      });
    }

    // Geographic boundary check: Strictly Jimma Zone
    if (zone.toLowerCase() !== 'jimma') {
      return res.status(400).json({
        success: false,
        message: 'AgriLink is strictly bounded to Jimma Zone, Oromia.',
      });
    }

    // Validate woreda
    const isWoredaValid = VALID_JIMMA_WOREDAS.some(
      (w) => w.toLowerCase() === woreda.trim().toLowerCase()
    );
    if (!isWoredaValid) {
      return res.status(400).json({
        success: false,
        message: `Woreda "${woreda}" is not recognized within Jimma Zone. Recognized woredas: ${VALID_JIMMA_WOREDAS.join(', ')}`,
      });
    }

    // Lookup cooperative if cooperativeId provided
    let coopTitle = cooperativeName || '';
    if (cooperativeId) {
      const coop = await Cooperative.findById(cooperativeId);
      if (coop) coopTitle = coop.name;
    }

    const farm = await Farm.create({
      farmerId,
      farmerName: farmer?.fullName || 'Abebe Bikila',
      name,
      sizeHectares: Number(sizeHectares),
      zone: 'Jimma',
      woreda,
      kebele: kebele || '',
      latitude: Number(latitude) || 7.67,
      longitude: Number(longitude) || 36.83,
      altitudeMeters: Number(altitudeMeters) || 1950,
      soilType: soilType || 'nitisol_red_clay',
      agroEcology: agroEcology || 'midland_weyna_dega',
      waterSource: waterSource || 'rainfed',
      cooperativeId: cooperativeId || null,
      cooperativeName: coopTitle,
      cooperativeMembershipId: cooperativeMembershipId || '',
      isVerified: true,
    });

    const formatted = farm.toJSON();
    formatted.sizeHectares = String(farm.sizeHectares);
    res.status(201).json(formatted);
  } catch (error) {
    console.error('Error creating farm:', error);
    res.status(500).json({ success: false, message: 'Error creating farm', error: error.message });
  }
};

/**
 * Update farm
 */
export const updateFarm = async (req, res) => {
  try {
    const farm = await Farm.findById(req.params.id);
    if (!farm) {
      return res.status(404).json({ success: false, message: 'Farm not found' });
    }

    const updates = req.body;
    if (updates.sizeHectares) updates.sizeHectares = Number(updates.sizeHectares);
    if (updates.zone && updates.zone.toLowerCase() !== 'jimma') {
      return res.status(400).json({ success: false, message: 'Farm location must remain within Jimma Zone.' });
    }

    Object.assign(farm, updates);
    await farm.save();

    const formatted = farm.toJSON();
    formatted.sizeHectares = String(farm.sizeHectares);
    res.status(200).json(formatted);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error updating farm', error: error.message });
  }
};

/**
 * Delete farm
 */
export const deleteFarm = async (req, res) => {
  try {
    const farm = await Farm.findById(req.params.id);
    if (!farm) {
      return res.status(404).json({ success: false, message: 'Farm not found' });
    }

    await CropCycle.deleteMany({ farmId: farm._id });
    await farm.deleteOne();

    res.status(200).json({ success: true, message: 'Farm and associated crop records deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error deleting farm', error: error.message });
  }
};

/**
 * List crop cycle records for a farm
 */
export const listFarmCropRecords = async (req, res) => {
  try {
    const { farmId } = req.params;
    const records = await CropCycle.find({ farmId }).sort({ createdAt: -1 });

    const formatted = records.map((r) => {
      const json = r.toJSON();
      return {
        ...json,
        crop: {
          id: r.cropId,
          slug: r.cropName.toLowerCase().replace(/\s+/g, '-'),
          name: r.cropName,
          nameAfaanOromoo: r.cropNameAfaanOromoo,
          isPerishable: ['Tomato', 'Potato'].includes(r.cropName),
          isActive: true,
        },
      };
    });

    res.status(200).json(formatted);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error listing crop records', error: error.message });
  }
};

/**
 * Create a new crop cycle / harvest projection record
 */
export const createFarmCropRecord = async (req, res) => {
  try {
    const { farmId } = req.params;
    const farm = await Farm.findById(farmId);
    if (!farm) {
      return res.status(404).json({ success: false, message: 'Farm not found' });
    }

    const {
      cropId,
      cropName = 'Maize',
      cropNameAfaanOromoo,
      variety,
      areaHectares,
      expectedYieldKg,
      growthStage = 'vegetative',
      plantingDate,
      harvestStart,
      harvestEnd,
      expectedQualityGrade = 'Grade 1 (Export)',
      notes,
    } = req.body;

    const cropNameNorm = cropName || 'Maize';
    const oromooName = cropNameAfaanOromoo || CROP_NAME_AFAN_OROMOO[cropNameNorm] || cropNameNorm;

    const startDate = harvestStart ? new Date(harvestStart) : new Date(Date.now() + 60 * 24 * 60 * 60 * 1000);
    const endDate = harvestEnd ? new Date(harvestEnd) : new Date(Date.now() + 90 * 24 * 60 * 60 * 1000);

    const record = await CropCycle.create({
      farmId,
      farmerId: farm.farmerId,
      cropId: cropId || `crop_${cropNameNorm.toLowerCase()}`,
      cropName: cropNameNorm,
      cropNameAfaanOromoo: oromooName,
      variety: variety || 'Standard Regional Variety',
      areaHectares: Number(areaHectares),
      expectedYieldKg: Number(expectedYieldKg) || Number(areaHectares) * 2500,
      growthStage,
      plantingDate: plantingDate ? new Date(plantingDate) : new Date(),
      expectedHarvestStart: startDate,
      expectedHarvestEnd: endDate,
      expectedQualityGrade,
      notes: notes || '',
    });

    // Update farm plots count
    farm.plotsCount = await CropCycle.countDocuments({ farmId });
    await farm.save();

    const json = record.toJSON();
    res.status(201).json({
      ...json,
      crop: {
        id: record.cropId,
        slug: record.cropName.toLowerCase().replace(/\s+/g, '-'),
        name: record.cropName,
        nameAfaanOromoo: record.cropNameAfaanOromoo,
        isPerishable: ['Tomato', 'Potato'].includes(record.cropName),
        isActive: true,
      },
    });
  } catch (error) {
    console.error('Error creating crop cycle:', error);
    res.status(500).json({ success: false, message: 'Error creating crop record', error: error.message });
  }
};

/**
 * Update crop cycle record
 */
export const updateFarmCropRecord = async (req, res) => {
  try {
    const { id } = req.params;
    const record = await CropCycle.findById(id);
    if (!record) {
      return res.status(404).json({ success: false, message: 'Crop record not found' });
    }

    const updates = req.body;
    if (updates.areaHectares) updates.areaHectares = Number(updates.areaHectares);
    if (updates.expectedYieldKg) updates.expectedYieldKg = Number(updates.expectedYieldKg);
    if (updates.harvestStart) updates.expectedHarvestStart = new Date(updates.harvestStart);
    if (updates.harvestEnd) updates.expectedHarvestEnd = new Date(updates.harvestEnd);

    Object.assign(record, updates);
    await record.save();

    const json = record.toJSON();
    res.status(200).json({
      ...json,
      crop: {
        id: record.cropId,
        slug: record.cropName.toLowerCase().replace(/\s+/g, '-'),
        name: record.cropName,
        nameAfaanOromoo: record.cropNameAfaanOromoo,
        isPerishable: ['Tomato', 'Potato'].includes(record.cropName),
        isActive: true,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error updating crop record', error: error.message });
  }
};

/**
 * Delete crop cycle record
 */
export const deleteFarmCropRecord = async (req, res) => {
  try {
    const { farmId, id } = req.params;
    const record = await CropCycle.findById(id);
    if (!record) {
      return res.status(404).json({ success: false, message: 'Crop record not found' });
    }

    await record.deleteOne();

    // Update plots count on farm
    await Farm.findByIdAndUpdate(farmId, {
      plotsCount: await CropCycle.countDocuments({ farmId }),
    });

    res.status(200).json({ success: true, message: 'Crop record deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error deleting crop record', error: error.message });
  }
};

/**
 * List verified Cooperatives & Unions in Jimma Zone
 */
export const listCooperatives = async (req, res) => {
  try {
    const { woreda, type } = req.query;
    const filter = { isVerified: true, zone: 'Jimma' };
    if (woreda) filter.woreda = woreda;
    if (type) filter.type = type;

    const coops = await Cooperative.find(filter).sort({ totalMembers: -1 });
    res.status(200).json({ success: true, count: coops.length, cooperatives: coops });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching cooperatives', error: error.message });
  }
};

/**
 * Link Farm to a Cooperative / Union
 */
export const linkFarmToCooperative = async (req, res) => {
  try {
    const { farmId } = req.params;
    const { cooperativeId, membershipNumber } = req.body;

    const farm = await Farm.findById(farmId);
    if (!farm) {
      return res.status(404).json({ success: false, message: 'Farm not found' });
    }

    const coop = await Cooperative.findById(cooperativeId);
    if (!coop) {
      return res.status(404).json({ success: false, message: 'Cooperative not found in Jimma Zone' });
    }

    farm.cooperativeId = coop._id;
    farm.cooperativeName = coop.name;
    farm.cooperativeMembershipId = membershipNumber || `MBR-${Date.now().toString().slice(-6)}`;
    await farm.save();

    res.status(200).json({
      success: true,
      message: `Lafaa qonnaa milkaa'inaan ${coop.nameAfaanOromoo || coop.name} waliin wal-qabsiifameera.`,
      farm: farm.toJSON(),
      cooperative: coop,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error linking cooperative', error: error.message });
  }
};

/**
 * Comprehensive Farmer Dashboard
 */
export const getFarmerDashboard = async (req, res) => {
  try {
    const farmerId = req.user?.id || 'user_farmer_abebe';
    const farmer = await User.findById(farmerId);
    const farms = await Farm.find({ farmerId });

    const totalHectares = farms.reduce((sum, f) => sum + (f.sizeHectares || 0), 0);
    const totalQadaa = Number((totalHectares * 4).toFixed(2));

    const farmIds = farms.map((f) => f._id);
    const cropRecords = await CropCycle.find({ farmId: { $in: farmIds } });

    // Aggregate crops summary
    const cropSummaryMap = {};
    for (const cr of cropRecords) {
      if (!cropSummaryMap[cr.cropId]) {
        cropSummaryMap[cr.cropId] = {
          cropId: cr.cropId,
          cropName: cr.cropName,
          cropNameAfaanOromoo: cr.cropNameAfaanOromoo,
          recordCount: 0,
          totalAreaHectares: 0,
          totalExpectedYieldKg: 0,
          totalExpectedYieldQuintals: 0,
        };
      }
      cropSummaryMap[cr.cropId].recordCount += 1;
      cropSummaryMap[cr.cropId].totalAreaHectares += cr.areaHectares || 0;
      cropSummaryMap[cr.cropId].totalExpectedYieldKg += cr.expectedYieldKg || 0;
      cropSummaryMap[cr.cropId].totalExpectedYieldQuintals += cr.expectedYieldQuintals || 0;
    }

    const cropsSummary = Object.values(cropSummaryMap).map((cs) => ({
      ...cs,
      totalAreaHectares: Number(cs.totalAreaHectares.toFixed(2)),
      totalExpectedYieldKg: Math.round(cs.totalExpectedYieldKg),
      totalExpectedYieldQuintals: Number(cs.totalExpectedYieldQuintals.toFixed(1)),
    }));

    const recentActivity = [
      {
        type: 'farm_registered',
        description: `Farm "${farms[0]?.name || 'Jimma Highland Plot'}" registered in ${farms[0]?.woreda || 'Mana'} Woreda`,
        createdAt: farms[0]?.createdAt || new Date().toISOString(),
      },
    ];

    res.status(200).json({
      profile: {
        id: farmerId,
        userId: farmerId,
        fullName: farmer?.fullName || 'Abebe Bikila',
        phone: farmer?.phone || '+251911223344',
        zone: 'Jimma',
        woreda: farmer?.woreda || 'Mana',
        kebele: 'Yabu',
        cooperativeName: farms[0]?.cooperativeName || 'Mana Bilisummaa Cooperative',
      },
      farmsCount: farms.length,
      totalHectares: Number(totalHectares.toFixed(2)),
      totalQadaa,
      cropsSummary,
      recentActivity,
    });
  } catch (error) {
    console.error('Error generating farmer dashboard:', error);
    res.status(500).json({ success: false, message: 'Error generating dashboard', error: error.message });
  }
};

/**
 * Flagship Module 4.4: Digital Creditworthiness Profile
 * Evaluates landholdings, crop projections, verified sales, and cooperative membership
 */
export const getCreditworthinessProfile = async (req, res) => {
  try {
    const farmerId = req.user?.id || 'user_farmer_abebe';
    const farmer = await User.findById(farmerId);
    const farms = await Farm.find({ farmerId });
    const farmIds = farms.map((f) => f._id);
    const cropRecords = await CropCycle.find({ farmId: { $in: farmIds } });
    const orders = await Order.find({ status: { $in: ['confirmed', 'delivered'] } });

    // 1. Landholding score (Max 25 points)
    const totalHectares = farms.reduce((sum, f) => sum + (f.sizeHectares || 0), 0);
    const landScore = Math.min(Math.round(totalHectares * 10), 25);

    // 2. Crop diversity & projection score (Max 25 points)
    const cropCount = new Set(cropRecords.map((c) => c.cropId)).size;
    const totalExpectedYield = cropRecords.reduce((sum, c) => sum + (c.expectedYieldKg || 0), 0);
    const cropScore = Math.min(cropCount * 7 + (totalExpectedYield > 2000 ? 11 : 5), 25);

    // 3. Cooperative membership & standing (Max 20 points)
    const hasCoop = farms.some((f) => f.cooperativeId || f.cooperativeName);
    const coopScore = hasCoop ? 20 : 5;

    // 4. Verified sales & transactions history on AgriLink (Max 20 points)
    const verifiedSalesRevenue = orders.reduce((sum, o) => sum + (o.totalPrice || 0), 0);
    const transactionScore = Math.min(orders.length * 8 + (verifiedSalesRevenue > 10000 ? 4 : 0), 20);

    // 5. Verification status (Max 10 points)
    const verificationScore = farmer?.isVerified ? 10 : 5;

    const totalCreditScore = landScore + cropScore + coopScore + transactionScore + verificationScore;

    let grade = 'Grade B';
    let riskTier = 'Moderate Risk';
    let maxLoanEligibilityETB = 50000;

    if (totalCreditScore >= 90) {
      grade = 'Grade A+ (Prime)';
      riskTier = 'Very Low Risk';
      maxLoanEligibilityETB = 250000;
    } else if (totalCreditScore >= 80) {
      grade = 'Grade A (Excellent)';
      riskTier = 'Low Risk';
      maxLoanEligibilityETB = 150000;
    } else if (totalCreditScore >= 70) {
      grade = 'Grade B+ (Good)';
      riskTier = 'Moderate Risk';
      maxLoanEligibilityETB = 80000;
    }

    res.status(200).json({
      success: true,
      farmer: {
        id: farmerId,
        fullName: farmer?.fullName || 'Abebe Bikila',
        phone: farmer?.phone || '+251911223344',
        location: 'Jimma Zone, Oromia',
        isVerified: farmer?.isVerified || true,
      },
      creditScore: totalCreditScore,
      grade,
      riskTier,
      maxLoanEligibilityETB,
      scoreBreakdown: {
        landholdingVerification: { score: landScore, max: 25, totalHectares, totalQadaa: totalHectares * 4 },
        cropCyclesAndYield: { score: cropScore, max: 25, activePlots: cropRecords.length, totalExpectedYieldKg: totalExpectedYield },
        cooperativeMembership: { score: coopScore, max: 20, isLinked: hasCoop, cooperativeName: farms[0]?.cooperativeName || 'Mana Cooperative' },
        verifiedSalesLedger: { score: transactionScore, max: 20, completedDeals: orders.length, verifiedSalesETB: verifiedSalesRevenue },
        identityVerification: { score: verificationScore, max: 10, isVerified: farmer?.isVerified || true },
      },
      eligibleLenders: [
        { name: 'Sinqee Bank (Siinqee)', type: 'Microfinance & Commercial Bank', product: 'Agricultural Input & Fertilizer Loan' },
        { name: 'Oromia Credit & Saving SC (OCSSCO)', type: 'Microfinance Institution', product: 'Seasonal Crop Production Credit' },
        { name: 'Cooperative Bank of Oromia (Coopbank)', type: 'Cooperative Commercial Bank', product: 'Smallholder Group Guarantee Loan' },
      ],
      digitalVerificationCode: `AGRI-CR-${Date.now().toString().slice(-8)}`,
      certifiedAt: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Error calculating creditworthiness:', error);
    res.status(500).json({ success: false, message: 'Error calculating creditworthiness', error: error.message });
  }
};

/**
 * Get Farmer Profile (/api/v1/farmers/me)
 */
export const getFarmerProfile = async (req, res) => {
  try {
    const farmerId = req.user?.id || req.user?._id || 'user_farmer_abebe';
    const user = (await User.findById(farmerId)) || (await User.findOne({ role: 'farmer' }));
    const farm = await Farm.findOne({ farmerId });

    res.status(200).json({
      id: user?._id || farmerId,
      userId: user?._id || farmerId,
      fullName: user?.fullName || 'Abebe Bikila',
      phone: user?.phone || '+251911223344',
      zone: farm?.zone || 'Jimma',
      woreda: farm?.woreda || user?.woreda || 'Mana',
      kebele: farm?.kebele || 'Yabu',
      cooperativeName: farm?.cooperativeName || 'Mana Bilisummaa Cooperative',
      createdAt: user?.createdAt || new Date().toISOString(),
      updatedAt: user?.updatedAt || new Date().toISOString(),
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching farmer profile', error: error.message });
  }
};

/**
 * Update Farmer Profile (/api/v1/farmers/me)
 */
export const updateFarmerProfile = async (req, res) => {
  try {
    const farmerId = req.user?.id || req.user?._id || 'user_farmer_abebe';
    const { woreda, kebele, cooperativeName } = req.body;
    const user = await User.findById(farmerId);
    if (user) {
      if (woreda) user.woreda = woreda;
      await user.save();
    }
    const farm = await Farm.findOne({ farmerId });
    if (farm) {
      if (woreda) farm.woreda = woreda;
      if (kebele) farm.kebele = kebele;
      if (cooperativeName) farm.cooperativeName = cooperativeName;
      await farm.save();
    }
    res.status(200).json({
      id: user?._id || farmerId,
      userId: user?._id || farmerId,
      fullName: user?.fullName || 'Abebe Bikila',
      phone: user?.phone || '+251911223344',
      zone: 'Jimma',
      woreda: woreda || farm?.woreda || 'Mana',
      kebele: kebele || farm?.kebele || 'Yabu',
      cooperativeName: cooperativeName || farm?.cooperativeName || 'Mana Bilisummaa Cooperative',
      createdAt: user?.createdAt || new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error updating farmer profile', error: error.message });
  }
};

/**
 * List crop catalog (/api/v1/crops)
 */
export const listCropCatalog = async (req, res) => {
  const crops = [
    { id: 'crop_coffee', slug: 'coffee', name: 'Coffee (Buna)', isPerishable: false, isActive: true },
    { id: 'crop_maize', slug: 'maize', name: 'Maize (Boqqolloo)', isPerishable: false, isActive: true },
    { id: 'crop_teff', slug: 'teff', name: 'Teff (Xaafii)', isPerishable: false, isActive: true },
    { id: 'crop_wheat', slug: 'wheat', name: 'Wheat (Qamadii)', isPerishable: false, isActive: true },
    { id: 'crop_potato', slug: 'potato', name: 'Potato (Dinnicha)', isPerishable: true, isActive: true },
    { id: 'crop_tomato', slug: 'tomato', name: 'Tomato (Timaatima)', isPerishable: true, isActive: true },
    { id: 'crop_carrot', slug: 'carrot', name: 'Carrot (Kaarotii)', isPerishable: true, isActive: true },
  ];
  res.status(200).json(crops);
};

