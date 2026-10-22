import axios from 'axios';

const BASE_URL = 'http://localhost:5001/api/v1';

console.log('===============================================================');
console.log('    AGROLINK PHASE 3: BUYER MARKETPLACE & MATCHING SUITE       ');
console.log('                  JIMMA ZONE, OROMIA                           ');
console.log('===============================================================\n');

let testsPassed = 0;
let totalTests = 0;

function assert(condition, message) {
  totalTests++;
  if (condition) {
    console.log(`  ✅ [PASS] ${message}`);
    testsPassed++;
  } else {
    console.error(`  ❌ [FAIL] ${message}`);
    throw new Error(`Assertion failed: ${message}`);
  }
}

async function runTests() {
  try {
    // 1. Health check
    console.log('--- 1. Testing Server Health ---');
    const healthRes = await axios.get(`${BASE_URL}/health`);
    assert(healthRes.status === 200 && healthRes.data.status === 'ok', 'Server is healthy');

    // 2. List all buyer demands
    console.log('\n--- 2. Testing List Demands & Filtering ---');
    const demandsRes = await axios.get(`${BASE_URL}/marketplace/demands`);
    assert(demandsRes.status === 200, 'GET /marketplace/demands returned 200');
    assert(demandsRes.data.demands.length >= 8, `Returned ${demandsRes.data.demands.length} demands (expected >= 8)`);

    // Verify all demands are strictly within Jimma Zone
    const allInJimma = demandsRes.data.demands.every((d) => d.pickupZone === 'Jimma');
    assert(allInJimma, 'All buyer demands are strictly within Jimma Zone, Oromia');

    // Filter by crop (Maize / Boqqolloo)
    const maizeRes = await axios.get(`${BASE_URL}/marketplace/demands?cropName=Maize`);
    assert(maizeRes.data.demands.length >= 2, `Found ${maizeRes.data.demands.length} Maize demands`);
    assert(maizeRes.data.demands.every((d) => d.cropName === 'Maize'), 'All filtered demands are Maize');

    // Filter by buyerType (local_collector)
    const collectorRes = await axios.get(`${BASE_URL}/marketplace/demands?buyerType=local_collector`);
    assert(collectorRes.data.demands.length >= 2, `Found ${collectorRes.data.demands.length} local collector demands`);
    assert(
      collectorRes.data.demands.every((d) => d.buyer.buyerType === 'local_collector'),
      'All filtered demands belong to local collectors'
    );

    // 3. Live "Buying Now" stream
    console.log('\n--- 3. Testing Live "Buying Now" Real-Time Stream ---');
    const buyingNowRes = await axios.get(`${BASE_URL}/marketplace/demands/buying-now`);
    assert(buyingNowRes.status === 200, 'GET /marketplace/demands/buying-now returned 200');
    assert(buyingNowRes.data.count > 0, `Returned ${buyingNowRes.data.count} active buying merchants today`);
    assert(buyingNowRes.data.zone === 'Jimma Zone, Oromia', 'Buying Now stream bounded to Jimma Zone');
    
    const sampleActive = buyingNowRes.data.activeMerchantsToday[0];
    assert(!!sampleActive.buyingPostLocation, `Active merchant has physical location: ${sampleActive.buyingPostLocation}`);
    assert(!!sampleActive.operatingHoursToday, `Active merchant has operating hours: ${sampleActive.operatingHoursToday}`);

    // 4. Flagship Farmer Matching Engine
    console.log('\n--- 4. Testing Farmer Produce Matching Engine ---');
    // Test Case A: Farmer in Seka Chekorsa selling 1,500 kg Maize (Boqqolloo)
    const matchA = await axios.post(`${BASE_URL}/marketplace/match`, {
      cropName: 'Boqqolloo',
      quantityKg: 1500,
      originWoreda: 'Seka Chekorsa',
    });
    assert(matchA.status === 200, 'POST /marketplace/match returned 200');
    assert(matchA.data.matches.length >= 2, `Found ${matchA.data.matches.length} buyer matches for Boqqolloo`);
    assert(!!matchA.data.bestMatch, 'Engine selected bestMatch recommendation');
    assert(matchA.data.bestMatch.isRecommended === true, 'Best match has isRecommended: true');
    assert(matchA.data.bestMatch.netTakeHome > 0, `Net take-home calculated: ${matchA.data.bestMatch.netTakeHome} ETB`);
    console.log(`     Match A Best: ${matchA.data.bestMatch.buyer.businessName} -> Net: ${matchA.data.bestMatch.netTakeHome.toLocaleString()} ETB (Gross: ${matchA.data.bestMatch.grossRevenue.toLocaleString()} ETB, Transport: ${matchA.data.bestMatch.transportDeduction} ETB)`);

    // Test Case B: Farmer in Mana selling 200 kg Coffee (Buna)
    const matchB = await axios.post(`${BASE_URL}/marketplace/match`, {
      cropName: 'Buna',
      quantityKg: 200,
      originWoreda: 'Mana',
    });
    assert(matchB.data.matches.length >= 1, `Found ${matchB.data.matches.length} Coffee buyer match`);
    assert(matchB.data.bestMatch.cropNameAfaanOromoo === 'Buna', 'Matches Afaan Oromoo crop name "Buna"');
    assert(matchB.data.bestMatch.priceOfferPerKg === 460, 'Coffee price offer is 460 ETB/kg');
    console.log(`     Match B Coffee: ${matchB.data.bestMatch.buyer.businessName} -> Net: ${matchB.data.bestMatch.netTakeHome.toLocaleString()} ETB`);

    // Test Case C: Farmer in Jimma Town selling 1,000 kg Tomatoes (Timaatima) to Processor
    const matchC = await axios.post(`${BASE_URL}/marketplace/match`, {
      cropName: 'Tomato',
      quantityKg: 1000,
      originWoreda: 'Jimma Town',
    });
    assert(matchC.data.matches.length >= 1, 'Found Tomato processor match');
    assert(matchC.data.bestMatch.buyer.buyerType === 'processor', 'Matched with processor tier buyer');
    console.log(`     Match C Tomato: ${matchC.data.bestMatch.buyer.businessName} at ${matchC.data.bestMatch.buyingPostLocation}`);

    // 5. Connect Farmer to Buyer
    console.log('\n--- 5. Testing Farmer Connect Action ---');
    const targetDemand = demandsRes.data.demands[0];
    const targetId = targetDemand.id || targetDemand._id;
    const connectRes = await axios.post(`${BASE_URL}/marketplace/demands/${targetId}/connect`, {
      farmerName: 'Abebe Bikila',
      farmerPhone: '+251911223344',
      quantityKg: 500,
      notes: 'Ready for pickup in Mana Woreda',
    });
    assert(connectRes.status === 200, 'POST /marketplace/demands/:id/connect returned 200');
    assert(!!connectRes.data.buyerContact.phone, `Buyer contact phone returned: ${connectRes.data.buyerContact.phone}`);
    assert(!!connectRes.data.buyerContact.postLocation, `Buyer post location returned: ${connectRes.data.buyerContact.postLocation}`);

    // 6. Verified Buyers Directory
    console.log('\n--- 6. Testing Verified Buyers Directory & Multi-Tier Classification ---');
    const buyersRes = await axios.get(`${BASE_URL}/marketplace/buyers`);
    assert(buyersRes.status === 200, 'GET /marketplace/buyers returned 200');
    assert(buyersRes.data.buyers.length >= 4, `Returned ${buyersRes.data.buyers.length} verified buyers`);

    const tiersFound = new Set(buyersRes.data.buyers.map((b) => b.buyerType));
    assert(tiersFound.has('wholesaler'), 'Directory includes wholesalers');
    assert(tiersFound.has('exporter'), 'Directory includes exporters');
    assert(tiersFound.has('local_collector'), 'Directory includes local collectors');
    assert(tiersFound.has('processor'), 'Directory includes processors');

    // Check reliability and no-show fields
    const sampleBuyer = buyersRes.data.buyers[0];
    assert(typeof sampleBuyer.reliabilityPercentage === 'number', `Reliability percentage tracked: ${sampleBuyer.reliabilityPercentage}%`);
    assert(typeof sampleBuyer.noShowCount === 'number', `No-show count tracked: ${sampleBuyer.noShowCount}`);

    console.log('\n===============================================================');
    console.log(`  ALL PHASE 3 BACKEND TESTS PASSED: ${testsPassed}/${totalTests} TESTS!`);
    console.log('===============================================================\n');
  } catch (error) {
    console.error('Test execution failed:', error.response?.data || error.message);
    process.exit(1);
  }
}

runTests();
