import { BuyerDemand } from '../models/BuyerDemand.js';
import { BuyerProfile } from '../models/BuyerProfile.js';
import { MarketBenchmark } from '../models/MarketBenchmark.js';
import { Notification } from '../models/Notification.js';

// Distance matrix from Jimma Zone woredas to key market towns (km)
const WOREDA_MARKET_DISTANCES = {
  'Seka Chekorsa': { 'Jimma Town': 20, 'Agaro': 65, 'Limmu Kosa': 105, 'Seka Chekorsa': 2 },
  'Mana': { 'Jimma Town': 18, 'Agaro': 28, 'Limmu Kosa': 75, 'Seka Chekorsa': 35 },
  'Gomma': { 'Jimma Town': 50, 'Agaro': 8, 'Limmu Kosa': 60, 'Seka Chekorsa': 68 },
  'Limmu Kosa': { 'Jimma Town': 85, 'Agaro': 55, 'Limmu Kosa': 3, 'Seka Chekorsa': 102 },
  'Kersa': { 'Jimma Town': 22, 'Agaro': 68, 'Limmu Kosa': 90, 'Seka Chekorsa': 38 },
  'Dedo': { 'Jimma Town': 25, 'Agaro': 70, 'Limmu Kosa': 110, 'Seka Chekorsa': 30 },
  'Omo Nada': { 'Jimma Town': 55, 'Agaro': 100, 'Limmu Kosa': 140, 'Seka Chekorsa': 70 },
  'Jimma Town': { 'Jimma Town': 2, 'Agaro': 45, 'Limmu Kosa': 85, 'Seka Chekorsa': 20 },
  'Agaro': { 'Jimma Town': 45, 'Agaro': 2, 'Limmu Kosa': 55, 'Seka Chekorsa': 65 },
};

/**
 * Estimate road transport cost within Jimma Zone
 */
function estimateJimmaTransportCost(originWoreda, destTown, quantityKg) {
  const woredaDistances = WOREDA_MARKET_DISTANCES[originWoreda] || WOREDA_MARKET_DISTANCES['Jimma Town'];
  const distanceKm = woredaDistances[destTown] || 25;
  
  const baseTariff = 350; // ETB base handling & checkpoint fee
  const ratePerTonKm = 4.5; // ETB per ton-km along Jimma Zone roads
  const tonnage = Math.max(quantityKg / 1000, 0.1);

  const cost = baseTariff + (distanceKm * ratePerTonKm * tonnage);
  return {
    distanceKm,
    estimatedCost: Math.round(cost),
  };
}

/**
 * List all buyer demands with search and filter
 */
export const listDemands = async (req, res) => {
  try {
    const {
      cropId,
      cropName,
      woreda,
      buyerType,
      isBuyingNow,
      verifiedOnly,
      status,
      limit = 50,
      page = 1,
    } = req.query;

    const filter = {};

    if (cropId) filter.cropId = cropId;
    if (cropName) {
      filter.$or = [
        { cropName: new RegExp(cropName, 'i') },
        { cropNameAfaanOromoo: new RegExp(cropName, 'i') },
      ];
    }
    if (woreda) filter.pickupWoreda = woreda;
    if (buyerType) filter['buyer.buyerType'] = buyerType;
    if (verifiedOnly === 'true' || verifiedOnly === true) filter['buyer.isVerified'] = true;
    if (isBuyingNow === 'true' || isBuyingNow === true) filter.isBuyingNow = true;

    if (status) {
      filter.status = status;
    } else {
      filter.status = { $in: ['buying_now', 'active'] };
    }

    const skip = (Number(page) - 1) * Number(limit);
    const total = await BuyerDemand.countDocuments(filter);
    const demands = await BuyerDemand.find(filter)
      .sort({ isBuyingNow: -1, createdAt: -1 })
      .skip(skip)
      .limit(Number(limit));

    res.status(200).json({
      success: true,
      count: demands.length,
      total,
      page: Number(page),
      demands,
    });
  } catch (error) {
    console.error('Error listing demands:', error);
    res.status(500).json({ success: false, message: 'Server error listing demands', error: error.message });
  }
};

/**
 * Get live "Buying Now" stream for Jimma Zone
 */
export const getBuyingNowStream = async (req, res) => {
  try {
    const demands = await BuyerDemand.find({
      isBuyingNow: true,
      status: 'buying_now',
    }).sort({ updatedAt: -1 });

    res.status(200).json({
      success: true,
      zone: 'Jimma Zone, Oromia',
      count: demands.length,
      activeMerchantsToday: demands.map((d) => ({
        demandId: d._id,
        businessName: d.buyer.businessName,
        businessNameAfaanOromoo: d.buyer.businessNameAfaanOromoo,
        buyerType: d.buyer.buyerType,
        cropName: d.cropName,
        cropNameAfaanOromoo: d.cropNameAfaanOromoo,
        priceOfferPerKg: d.priceOfferPerKg,
        buyingPostLocation: d.buyingPostLocation,
        pickupWoreda: d.pickupWoreda,
        operatingHoursToday: d.operatingHoursToday,
        reliabilityScore: d.buyer.reliabilityScore,
        isVerified: d.buyer.isVerified,
        updatedAt: d.updatedAt,
      })),
      demands,
    });
  } catch (error) {
    console.error('Error fetching Buying Now stream:', error);
    res.status(500).json({ success: false, message: 'Error fetching Buying Now stream', error: error.message });
  }
};

/**
 * Get demand by ID
 */
export const getDemandById = async (req, res) => {
  try {
    const demand = await BuyerDemand.findById(req.params.id);
    if (!demand) {
      return res.status(404).json({ success: false, message: 'Demand posting not found' });
    }

    // Increment view count asynchronously
    demand.viewCount += 1;
    await demand.save();

    res.status(200).json({ success: true, demand });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching demand', error: error.message });
  }
};

/**
 * Create a new "Wanted to Buy" demand
 */
export const createDemand = async (req, res) => {
  try {
    const {
      cropId,
      cropName,
      cropNameAfaanOromoo,
      preferredGrade,
      minimumQuantityKg,
      maximumQuantityKg,
      priceOfferPerKg,
      buyingPostLocation,
      pickupWoreda,
      transportProvided,
      disclosedFeePercent,
      operatingHoursToday,
      neededBy,
      additionalNotes,
      additionalNotesAfaanOromoo,
      isBuyingNow = true,
    } = req.body;

    const buyerId = req.user?.id || req.body.buyerId;

    // Check or find BuyerProfile
    let profile = await BuyerProfile.findOne({ userId: buyerId });
    if (!profile) {
      profile = await BuyerProfile.create({
        userId: buyerId,
        businessName: req.body.businessName || req.user?.fullName || 'Jimma Merchant',
        businessNameAfaanOromoo: req.body.businessNameAfaanOromoo || req.body.businessName,
        buyerType: req.body.buyerType || 'wholesaler',
        contactPhone: req.user?.phone || req.body.contactPhone || '+251911000000',
        zone: 'Jimma',
        woreda: pickupWoreda || 'Jimma Town',
        specificLocation: buyingPostLocation || 'Jimma Central Market',
        isVerified: true,
      });
    }

    const demand = await BuyerDemand.create({
      buyerId,
      buyerProfileId: profile._id,
      buyer: {
        businessName: profile.businessName,
        businessNameAfaanOromoo: profile.businessNameAfaanOromoo,
        contactPhone: profile.contactPhone,
        buyerType: profile.buyerType,
        isVerified: profile.isVerified,
        verificationBadge: profile.verificationBadge,
        reliabilityScore: profile.reliabilityScore,
        reliabilityPercentage: profile.reliabilityPercentage,
        noShowCount: profile.noShowCount,
        disclosedFeePercent: profile.disclosedFeePercent || disclosedFeePercent || 0.0,
      },
      cropId,
      cropName,
      cropNameAfaanOromoo: cropNameAfaanOromoo || cropName,
      preferredGrade: preferredGrade || 'Grade 1 (Export)',
      minimumQuantityKg: Number(minimumQuantityKg) || 50,
      maximumQuantityKg: Number(maximumQuantityKg) || 1000,
      priceOfferPerKg: Number(priceOfferPerKg),
      status: isBuyingNow ? 'buying_now' : 'active',
      isBuyingNow: Boolean(isBuyingNow),
      buyingPostLocation: buyingPostLocation || profile.specificLocation,
      pickupZone: 'Jimma',
      pickupWoreda: pickupWoreda || profile.woreda,
      transportProvided: Boolean(transportProvided),
      disclosedFeePercent: Number(disclosedFeePercent) || 0.0,
      operatingHoursToday: operatingHoursToday || '8:00 AM - 5:00 PM',
      neededBy: neededBy ? new Date(neededBy) : new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      additionalNotes,
      additionalNotesAfaanOromoo,
    });

    res.status(201).json({ success: true, message: 'Demand posting created successfully', demand });
  } catch (error) {
    console.error('Error creating demand:', error);
    res.status(500).json({ success: false, message: 'Error creating demand posting', error: error.message });
  }
};

/**
 * Toggle live "Buying Now" status and update buying post location
 */
export const toggleBuyingNow = async (req, res) => {
  try {
    const demand = await BuyerDemand.findById(req.params.id);
    if (!demand) {
      return res.status(404).json({ success: false, message: 'Demand posting not found' });
    }

    const { isBuyingNow, buyingPostLocation, operatingHoursToday } = req.body;
    
    demand.isBuyingNow = isBuyingNow !== undefined ? Boolean(isBuyingNow) : !demand.isBuyingNow;
    demand.status = demand.isBuyingNow ? 'buying_now' : 'active';
    if (buyingPostLocation) demand.buyingPostLocation = buyingPostLocation;
    if (operatingHoursToday) demand.operatingHoursToday = operatingHoursToday;
    
    await demand.save();

    // Also update BuyerProfile if available
    if (demand.buyerProfileId) {
      await BuyerProfile.findByIdAndUpdate(demand.buyerProfileId, {
        isBuyingNow: demand.isBuyingNow,
        activeBuyingLocation: demand.buyingPostLocation,
        todayOperatingHours: demand.operatingHoursToday,
        lastActiveAt: new Date(),
      });
    }

    res.status(200).json({
      success: true,
      message: `Status updated to ${demand.isBuyingNow ? 'BUYING NOW (Active today)' : 'Active (Scheduled)'}`,
      demand,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error toggling Buying Now status', error: error.message });
  }
};

/**
 * Close/fulfill demand
 */
export const closeDemand = async (req, res) => {
  try {
    const demand = await BuyerDemand.findById(req.params.id);
    if (!demand) {
      return res.status(404).json({ success: false, message: 'Demand posting not found' });
    }

    demand.status = 'closed';
    demand.isBuyingNow = false;
    await demand.save();

    res.status(200).json({ success: true, message: 'Demand closed successfully', demand });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error closing demand', error: error.message });
  }
};

/**
 * Flagship Matching Engine: Match Farmer's Produce with Live Buyers in Jimma Zone
 */
export const matchFarmerProduce = async (req, res) => {
  try {
    const { cropName, cropId, quantityKg, originWoreda = 'Jimma Town' } = req.body;

    if (!quantityKg || Number(quantityKg) <= 0) {
      return res.status(400).json({ success: false, message: 'Valid quantityKg is required' });
    }

    const qty = Number(quantityKg);
    const filter = {
      status: { $in: ['buying_now', 'active'] },
    };

    if (cropId) {
      filter.cropId = cropId;
    } else if (cropName) {
      filter.$or = [
        { cropName: new RegExp(cropName, 'i') },
        { cropNameAfaanOromoo: new RegExp(cropName, 'i') },
      ];
    }

    const candidateDemands = await BuyerDemand.find(filter);

    // Compute net returns for each candidate buyer
    const matches = candidateDemands.map((demand) => {
      const grossRevenue = Math.round(qty * demand.priceOfferPerKg);

      let transportDeduction = 0;
      let transportNote = '';
      let distanceKm = 0;

      if (demand.transportProvided) {
        // Buyer picks up directly at farm gate / village center
        const commission = demand.disclosedFeePercent ? Math.round((demand.disclosedFeePercent / 100) * grossRevenue) : 0;
        transportDeduction = commission;
        transportNote = demand.disclosedFeePercent > 0
          ? `Gabaan kun manatti isiniif dhufe bitata. Kaffaltiin tajaajilaa %${demand.disclosedFeePercent} (${commission.toLocaleString()} ETB) qofa.`
          : 'Gabaan kun manatti isiniif dhufe bitata. Baasiin geejjibaa hin jiru (Zero transport burden).';
      } else {
        // Farmer transports produce to buyer's station in town
        const transportCalc = estimateJimmaTransportCost(originWoreda, demand.pickupWoreda, qty);
        transportDeduction = transportCalc.estimatedCost;
        distanceKm = transportCalc.distanceKm;
        transportNote = `Gabaa ${demand.pickupWoreda} tti geejjibsiisuuf gara tilmaama ${transportDeduction.toLocaleString()} ETB (${distanceKm} km) baasa.`;
      }

      const netTakeHome = Math.max(grossRevenue - transportDeduction, 0);
      const netPerKg = Number((netTakeHome / qty).toFixed(2));

      return {
        demandId: demand._id,
        buyer: demand.buyer,
        cropName: demand.cropName,
        cropNameAfaanOromoo: demand.cropNameAfaanOromoo,
        priceOfferPerKg: demand.priceOfferPerKg,
        preferredGrade: demand.preferredGrade,
        pickupWoreda: demand.pickupWoreda,
        buyingPostLocation: demand.buyingPostLocation,
        operatingHoursToday: demand.operatingHoursToday,
        isBuyingNow: demand.isBuyingNow,
        transportProvided: demand.transportProvided,
        disclosedFeePercent: demand.disclosedFeePercent,
        grossRevenue,
        transportDeduction,
        netTakeHome,
        netPerKg,
        distanceKm,
        transportNote,
        isRecommended: false,
      };
    });

    // Sort by highest net take-home return, prioritizing active "Buying Now" buyers
    matches.sort((a, b) => {
      if (a.isBuyingNow !== b.isBuyingNow) {
        return a.isBuyingNow ? -1 : 1;
      }
      return b.netTakeHome - a.netTakeHome;
    });

    if (matches.length > 0) {
      matches[0].isRecommended = true;
    }

    res.status(200).json({
      success: true,
      query: {
        cropName,
        cropId,
        quantityKg: qty,
        originWoreda,
        zone: 'Jimma Zone, Oromia',
      },
      matchCount: matches.length,
      bestMatch: matches[0] || null,
      matches,
    });
  } catch (error) {
    console.error('Error matching farmer produce:', error);
    res.status(500).json({ success: false, message: 'Error matching produce with buyers', error: error.message });
  }
};

/**
 * Farmer connects / sells to buyer
 */
export const connectToBuyer = async (req, res) => {
  try {
    const demand = await BuyerDemand.findById(req.params.id);
    if (!demand) {
      return res.status(404).json({ success: false, message: 'Demand posting not found' });
    }

    const { farmerName = 'Farmer', farmerPhone = '+251911000000', quantityKg, notes } = req.body;

    demand.responseCount += 1;
    await demand.save();

    // Create Notification for buyer
    await Notification.create({
      userId: demand.buyerId,
      title: 'Qonnan Bulaan Gurguraaf Qophiidha!',
      body: `${farmerName} (${farmerPhone}) kiiloo ${quantityKg || demand.minimumQuantityKg} midhaan ${demand.cropNameAfaanOromoo || demand.cropName} gurguruu barbaada.`,
      type: 'demand_match',
      data: {
        demandId: demand._id,
        farmerName,
        farmerPhone,
        quantityKg,
      },
    });

    res.status(200).json({
      success: true,
      message: 'Wal-qunnamtiin milkaa\'inaan dhiyaateera. Daldalaan hatattamaan isin qunnama.',
      buyerContact: {
        businessName: demand.buyer.businessName,
        phone: demand.buyer.contactPhone,
        postLocation: demand.buyingPostLocation,
        operatingHours: demand.operatingHoursToday,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error connecting to buyer', error: error.message });
  }
};

/**
 * List verified Jimma Zone buyers
 */
export const listBuyers = async (req, res) => {
  try {
    const { woreda, buyerType } = req.query;
    const filter = { isVerified: true };
    if (woreda) filter.woreda = woreda;
    if (buyerType) filter.buyerType = buyerType;

    const buyers = await BuyerProfile.find(filter).sort({ reliabilityScore: -1, isBuyingNow: -1 });
    res.status(200).json({ success: true, count: buyers.length, buyers });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching buyers', error: error.message });
  }
};

/**
 * Get current buyer's profile
 */
export const getMyBuyerProfile = async (req, res) => {
  try {
    const userId = req.user?.id;
    let profile = await BuyerProfile.findOne({ userId });
    if (!profile) {
      profile = await BuyerProfile.create({
        userId,
        businessName: req.user?.fullName || 'Jimma Merchant',
        businessNameAfaanOromoo: req.user?.fullName,
        contactPhone: req.user?.phone || '+251911000000',
        zone: 'Jimma',
        woreda: 'Jimma Town',
        specificLocation: 'Jimma Central Market',
      });
    }

    const myDemands = await BuyerDemand.find({ buyerId: userId }).sort({ createdAt: -1 });

    res.status(200).json({ success: true, profile, demands: myDemands });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching buyer profile', error: error.message });
  }
};
