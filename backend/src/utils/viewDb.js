import mongoose from 'mongoose';
import { config } from '../config/env.js';
import { User } from '../models/User.js';
import { Produce } from '../models/Produce.js';
import { Order } from '../models/Order.js';
import { Payment } from '../models/Payment.js';
import { Trip } from '../models/Trip.js';
import { Inspection } from '../models/Inspection.js';
import { MarketBenchmark } from '../models/MarketBenchmark.js';
import { BuyerProfile } from '../models/BuyerProfile.js';
import { BuyerDemand } from '../models/BuyerDemand.js';
import { Cooperative } from '../models/Cooperative.js';
import { Farm } from '../models/Farm.js';
import { CropCycle } from '../models/CropCycle.js';
import { RouteCorridor } from '../models/RouteCorridor.js';
import { CheckpointTariff } from '../models/CheckpointTariff.js';
import { VillageCollector } from '../models/VillageCollector.js';
import { VehicleFleet } from '../models/VehicleFleet.js';



const viewDatabase = async () => {
  try {
    await mongoose.connect(config.mongoUri);
    console.log(`\n======================================================`);
    console.log(`📦 AGROLINK DATABASE VIEWER (Database: agrolink)`);
    console.log(`======================================================\n`);

    // 1. Users
    const users = await User.find({}).lean();
    console.log(`👥 USERS COLLECTION (${users.length} records):`);
    console.table(
      users.map((u) => ({
        ID: u._id,
        Name: u.fullName,
        Phone: u.phone,
        Role: u.role,
        Location: u.location,
        Verified: u.isVerified,
      }))
    );

    // 2. Produce Listings
    const produce = await Produce.find({}).lean();
    console.log(`\n🌾 PRODUCE COLLECTION (${produce.length} records):`);
    console.table(
      produce.map((p) => ({
        ID: p._id,
        Crop: p.cropName,
        Farmer: p.farmerName,
        Qty: `${p.quantity} ${p.unit}`,
        Price: `${p.pricePerUnit} ${p.currency}/${p.unit}`,
        Grade: p.qualityGrade,
        Status: p.status,
      }))
    );

    // 3. Orders
    const orders = await Order.find({}).lean();
    console.log(`\n🛒 ORDERS COLLECTION (${orders.length} records):`);
    if (orders.length === 0) {
      console.log('  (No orders yet)');
    } else {
      console.table(
        orders.map((o) => ({
          ID: o._id,
          Buyer: o.buyerName,
          Crop: o.cropName,
          Qty: `${o.quantity} ${o.unit}`,
          Total: `${o.totalPrice} ${o.currency}`,
          Status: o.status,
          Payment: o.paymentStatus,
        }))
      );
    }

    // 4. Payments
    const payments = await Payment.find({}).lean();
    console.log(`\n💳 PAYMENTS COLLECTION (${payments.length} records):`);
    if (payments.length === 0) {
      console.log('  (No payments recorded yet)');
    } else {
      console.table(
        payments.map((py) => ({
          ID: py._id,
          Order: py.orderId,
          TradeNo: py.tradeNo || py.outTradeNo,
          Amount: `${py.amount} ${py.currency}`,
          Method: py.paymentMethod,
          Status: py.status,
        }))
      );
    }

    // 5. Logistics Trips
    const trips = await Trip.find({}).lean();
    console.log(`\n🚚 TRIPS / LOGISTICS COLLECTION (${trips.length} records):`);
    if (trips.length === 0) {
      console.log('  (No trips yet)');
    } else {
      console.table(
        trips.map((t) => ({
          ID: t._id,
          Transporter: t.transporterName,
          From: t.pickupLocation,
          To: t.dropoffLocation,
          Distance: `${t.distanceKm} km`,
          Earnings: `${t.earnings} ETB`,
          Status: t.status,
        }))
      );
    }

    // 6. Inspections
    const inspections = await Inspection.find({}).lean();
    console.log(`\n🏛️ BUREAU INSPECTIONS COLLECTION (${inspections.length} records):`);
    if (inspections.length === 0) {
      console.log('  (No inspections yet)');
    } else {
      console.table(
        inspections.map((i) => ({
          ID: i._id,
          Officer: i.officerName,
          Woreda: i.woredaName,
          Target: i.farmName || i.cooperativeName || i.targetType,
          Status: i.status,
          Issues: i.issueCount,
          Signed: !!i.signatureUrl,
        }))
      );
    }

    // 7. Benchmark Markets & Decision Engine Prices
    const benchmarks = await MarketBenchmark.find({}).lean();
    console.log(`\n🎯 BENCHMARK MARKETS COLLECTION (${benchmarks.length} markets):`);
    console.table(
      benchmarks.map((b) => ({
        Code: b.marketCode,
        Market: b.name,
        Oromoo: b.nameAfaanOromoo,
        Region: b.region,
        DefaultDist: `${b.defaultDistanceKm} km`,
        TransitFee: `${b.baseTransitFee} ETB`,
        CropsCount: b.commodityPrices?.length || 0,
      }))
    );

    // 8. Buyer Profiles (Verified Multi-Tier Merchants)
    const buyers = await BuyerProfile.find({}).lean();
    console.log(`\n🏬 BUYER PROFILES COLLECTION (${buyers.length} verified buyers):`);
    console.table(
      buyers.map((b) => ({
        Business: b.businessName,
        Tier: b.buyerType,
        Woreda: b.woreda,
        Reliability: `${b.reliabilityPercentage}% (${b.reliabilityScore}★)`,
        Deals: b.completedDeals,
        NoShows: b.noShowCount,
        BuyingNow: b.isBuyingNow ? '🟢 LIVE' : '⚪ Idle',
        OperatingHours: b.todayOperatingHours,
      }))
    );

    // 9. Buyer Demands ("Wanted to Buy" Listings)
    const demands = await BuyerDemand.find({}).lean();
    console.log(`\n📢 BUYER DEMANDS / WANTED TO BUY (${demands.length} listings):`);
    console.table(
      demands.map((d) => ({
        Crop: `${d.cropName} (${d.cropNameAfaanOromoo})`,
        Buyer: d.buyer.businessName,
        Tier: d.buyer.buyerType,
        OfferPrice: `${d.priceOfferPerKg} ETB/kg`,
        Volume: `${d.minimumQuantityKg}-${d.maximumQuantityKg} kg`,
        Location: d.buyingPostLocation,
        Transport: d.transportProvided ? 'Buyer Picks Up' : 'Farmer Delivers',
        Status: d.isBuyingNow ? '🟢 BUYING NOW' : d.status,
      }))
    );

    // 10. Jimma Zone Cooperatives & Unions
    const coops = await Cooperative.find({}).lean();
    console.log(`\n🏛️ JIMMA ZONE COOPERATIVES & UNIONS (${coops.length} registered):`);
    console.table(
      coops.map((c) => ({
        Code: c.coopCode,
        Name: c.name,
        AfaanOromoo: c.nameAfaanOromoo,
        Type: c.type,
        Woreda: c.woreda,
        Members: c.totalMembers,
        AggregatedVolume: `${(c.aggregatedVolumeKg / 1000).toLocaleString()} Tons`,
        Services: c.servicesOffered?.slice(0, 2).join(', '),
      }))
    );

    // 11. Farm Landholding Registry
    const farms = await Farm.find({}).lean();
    console.log(`\n🌱 FARM LANDHOLDINGS REGISTRY (${farms.length} farms):`);
    console.table(
      farms.map((f) => ({
        ID: f._id,
        FarmName: f.name,
        Farmer: f.farmerName,
        SizeHectares: `${f.sizeHectares} ha`,
        SizeQadaa: `${f.sizeQadaa} qadaa`,
        Woreda: f.woreda,
        Kebele: f.kebele,
        Altitude: `${f.altitudeMeters}m`,
        Soil: f.soilType,
        Cooperative: f.cooperativeName || 'None',
      }))
    );

    // 12. Plot Crop Cycles & Harvest Projections
    const cropCycles = await CropCycle.find({}).lean();
    console.log(`\n📅 CROP CYCLES & HARVEST PROJECTIONS (${cropCycles.length} plots):`);
    console.table(
      cropCycles.map((c) => ({
        PlotID: c._id,
        Crop: `${c.cropName} (${c.cropNameAfaanOromoo})`,
        Variety: c.variety,
        Area: `${c.areaHectares} ha (${c.areaQadaa} qadaa)`,
        Stage: c.growthStage,
        ExpectedHarvest: `${new Date(c.expectedHarvestStart).toLocaleDateString()} - ${new Date(c.expectedHarvestEnd).toLocaleDateString()}`,
        ExpectedYield: `${c.expectedYieldKg} kg (${c.expectedYieldQuintals} Qtl)`,
        Grade: c.expectedQualityGrade,
      }))
    );

    // 13. Route Corridors & Road Condition Multipliers
    const corridors = await RouteCorridor.find({}).lean();
    console.log(`\n🛣️ TRANSPORT CORRIDORS & ROAD CONDITIONS (${corridors.length} corridors):`);
    console.table(
      corridors.map((cr) => ({
        Code: cr.corridorCode,
        Route: cr.name,
        AfaanOromoo: cr.nameAfaanOromoo,
        Distance: `${cr.distanceKm} km`,
        Surface: cr.roadCondition,
        Multiplier: `${cr.roadConditionMultiplier}x`,
        EstHours: `${cr.averageTransitHours} hrs`,
        Checkpoints: cr.checkpointsCount,
      }))
    );

    // 14. Checkpoint Tariffs (Live Kellaa Ledger)
    const checkpoints = await CheckpointTariff.find({}).lean();
    console.log(`\n🛑 CHECKPOINT TARIFFS & KELLAA LIVE LEDGER (${checkpoints.length} checkpoints):`);
    console.table(
      checkpoints.map((k) => ({
        Code: k.checkpointCode,
        Checkpoint: k.name,
        Woreda: k.locationWoreda,
        Type: k.checkpointType,
        Official: `${k.officialTariffETB} ETB`,
        LiveFee: `${k.currentLiveFeeETB} ETB`,
        Status: k.currentStatus,
        Delay: `${k.delayMinutesAvg} min`,
        Reports: k.crowdReportsCount,
        Upvotes: `👍 ${k.upvotes}`,
      }))
    );

    // 15. Verified Village Collectors (Aggregators)
    const collectors = await VillageCollector.find({}).lean();
    console.log(`\n🏡 VERIFIED VILLAGE COLLECTORS (${collectors.length} registered):`);
    console.table(
      collectors.map((col) => ({
        Code: col.collectorCode,
        CollectorName: col.name,
        Contact: `${col.contactPerson} (${col.phone})`,
        Location: `${col.woreda} · ${col.kebele}`,
        Capacity: `${col.storageCapacityQuintals} Qtl`,
        Stored: `${col.currentStoredQuintals} Qtl`,
        Commission: `${col.serviceCommissionRate.value}${col.serviceCommissionRate.rateType === 'percentage' ? '%' : ' ETB/Qtl'}`,
        Rating: `${col.rating}★`,
        Status: col.operatingStatus,
      }))
    );

    // 16. Transporter Vehicle Fleet & Carrier Types
    const fleet = await VehicleFleet.find({}).lean();
    console.log(`\n🚚 TRANSPORTER VEHICLE FLEET & CARRIER TYPES (${fleet.length} registered carriers):`);
    console.table(
      fleet.map((v) => ({
        Plate: v.plateNumber,
        CarrierType: v.carrierTypeName,
        Transporter: v.transporterName,
        BaseWoreda: v.baseWoreda,
        MaxPayload: `${v.maxPayloadKg} kg (${v.maxPayloadQuintals} Qtl)`,
        RatePerKm: `${v.perKmBaseRateETB} ETB/km`,
        HandlingPerQtl: `${v.perQuintalHandlingRateETB} ETB/Qtl`,
        Status: v.availabilityStatus === 'available' ? '🟢 Available' : '⚪ Busy',
        Rating: `${v.rating}★`,
      }))
    );



    console.log(`\n======================================================\n`);
    process.exit(0);
  } catch (error) {
    console.error('Error viewing database:', error);
    process.exit(1);
  }
};

viewDatabase();
