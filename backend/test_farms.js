import fetch from 'node-fetch';

const BASE_URL = 'http://localhost:5001/api/v1';

async function runTests() {
  console.log('🧪 Starting Phase 4 Integration Tests: Farm Registry, Crop Cycles & Cooperatives...\n');
  let passed = 0;
  let failed = 0;

  function assert(condition, message) {
    if (condition) {
      console.log(`  ✅ PASS: ${message}`);
      passed++;
    } else {
      console.error(`  ❌ FAIL: ${message}`);
      failed++;
    }
  }

  try {
    // 1. List Farms
    console.log('1. Testing GET /farms...');
    const farmsRes = await fetch(`${BASE_URL}/farms`);
    const farms = await farmsRes.json();
    assert(farmsRes.status === 200, 'Status is 200');
    assert(Array.isArray(farms) && farms.length >= 2, `Returned ${farms.length} farms for Abebe Bikila`);
    const firstFarm = farms[0];
    assert(firstFarm.zone === 'Jimma', `Farm strictly located in Jimma Zone (found: ${firstFarm.zone})`);
    assert(Number(firstFarm.sizeQadaa) === Number(firstFarm.sizeHectares) * 4, `Dual unit verified: ${firstFarm.sizeHectares} ha = ${firstFarm.sizeQadaa} qadaa`);
    assert(!!firstFarm.soilType, `Soil type recorded: ${firstFarm.soilType}`);

    // 2. Get Farm by ID
    console.log('\n2. Testing GET /farms/:id...');
    const farmDetailRes = await fetch(`${BASE_URL}/farms/${firstFarm.id}`);
    const farmDetail = await farmDetailRes.json();
    assert(farmDetailRes.status === 200, 'Status is 200');
    assert(farmDetail.name === firstFarm.name, `Retrieved farm "${farmDetail.name}"`);
    assert(Array.isArray(farmDetail.crops), `Farm crops populated (${farmDetail.crops.length} plots)`);

    // 3. Test Geographic Boundary Enforcement (Reject non-Jimma zone)
    console.log('\n3. Testing Boundary Enforcement (Prevent non-Jimma farms)...');
    const invalidFarmRes = await fetch(`${BASE_URL}/farms`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: 'Illegal Plot in Adama',
        sizeHectares: 2.0,
        zone: 'East Shewa',
        woreda: 'Adama',
      }),
    });
    assert(invalidFarmRes.status === 400, `Rejected non-Jimma zone with HTTP ${invalidFarmRes.status}`);

    const invalidWoredaRes = await fetch(`${BASE_URL}/farms`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: 'Invalid Woreda Farm',
        sizeHectares: 1.5,
        zone: 'Jimma',
        woreda: 'Bishoftu', // Invalid woreda
      }),
    });
    assert(invalidWoredaRes.status === 400, `Rejected invalid woreda in Jimma with HTTP ${invalidWoredaRes.status}`);

    // 4. Create New Valid Farm in Jimma Zone
    console.log('\n4. Testing POST /farms (Valid Jimma plot in Gomma Woreda)...');
    const newFarmRes = await fetch(`${BASE_URL}/farms`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: 'Abebe Gomma Specialty Coffee Plot',
        sizeHectares: 1.5,
        zone: 'Jimma',
        woreda: 'Gomma',
        kebele: 'Choche',
        altitudeMeters: 2050,
        soilType: 'nitisol_red_clay',
        agroEcology: 'midland_weyna_dega',
        waterSource: 'rainfed',
      }),
    });
    const newFarm = await newFarmRes.json();
    assert(newFarmRes.status === 201, 'Created farm with HTTP 201');
    assert(Number(newFarm.sizeQadaa) === 6.0, `Auto-calculated sizeQadaa: ${newFarm.sizeQadaa} qadaa (1.5 ha * 4)`);

    // 5. List Crop Cycle Projections
    console.log('\n5. Testing GET /farms/:farmId/crops...');
    const cropsRes = await fetch(`${BASE_URL}/farms/farm_mana_highland/crops`);
    const cropRecords = await cropsRes.json();
    assert(cropsRes.status === 200, 'Status is 200');
    assert(cropRecords.length >= 3, `Found ${cropRecords.length} crop cycles on farm_mana_highland`);
    const coffeePlot = cropRecords.find((c) => c.cropName === 'Coffee');
    assert(!!coffeePlot, 'Contains Coffee plot');
    assert(coffeePlot.cropNameAfaanOromoo === 'Buna', `Afaan Oromoo name localized: ${coffeePlot.cropNameAfaanOromoo}`);
    assert(coffeePlot.growthStage === 'flowering', `Growth stage tracked: ${coffeePlot.growthStage}`);
    assert(Number(coffeePlot.expectedYieldQuintals) === 12.0, `Quintals calculated: ${coffeePlot.expectedYieldQuintals} Qtl`);

    // 6. Create New Crop Cycle Projection
    console.log('\n6. Testing POST /farms/:farmId/crops...');
    const newCropRes = await fetch(`${BASE_URL}/farms/${newFarm.id}/crops`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        cropName: 'Coffee',
        cropNameAfaanOromoo: 'Buna',
        variety: 'Gomma Washed Specialty',
        areaHectares: 1.0,
        expectedYieldKg: 1500,
        growthStage: 'vegetative',
        expectedQualityGrade: 'Grade 1 (Export)',
      }),
    });
    const newCrop = await newCropRes.json();
    assert(newCropRes.status === 201, 'Status is 201');
    assert(Number(newCrop.areaQadaa) === 4.0, `Auto-calculated areaQadaa: ${newCrop.areaQadaa}`);
    assert(Number(newCrop.expectedYieldQuintals) === 15.0, `Auto-calculated quintals: ${newCrop.expectedYieldQuintals} Qtl`);

    // 7. List Cooperatives
    console.log('\n7. Testing GET /cooperatives...');
    const coopsRes = await fetch(`${BASE_URL}/cooperatives`);
    const coopsData = await coopsRes.json();
    assert(coopsRes.status === 200, 'Status is 200');
    assert(coopsData.cooperatives?.length >= 5, `Listed ${coopsData.cooperatives?.length} Jimma cooperatives`);
    const ketaMuduga = coopsData.cooperatives.find((c) => c.coopCode === 'KMU-01');
    assert(!!ketaMuduga, 'Found Keta Muduga Union in Agaro');
    assert(ketaMuduga.type === 'union', 'Type is union');

    // 8. Link Farm to Cooperative
    console.log('\n8. Testing POST /farms/:farmId/link-cooperative...');
    const linkRes = await fetch(`${BASE_URL}/farms/${newFarm.id}/link-cooperative`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        cooperativeId: ketaMuduga.id || ketaMuduga._id,
        membershipNumber: 'MBR-KM-9921',
      }),
    });
    const linkData = await linkRes.json();
    assert(linkRes.status === 200, `Status is 200 (got: ${linkRes.status}, msg: ${linkData.message})`);
    assert(linkData.farm?.cooperativeName === ketaMuduga.name, `Farm linked to ${linkData.farm?.cooperativeName}`);


    // 9. Get Farmer Dashboard
    console.log('\n9. Testing GET /farmers/me/dashboard...');
    const dashboardRes = await fetch(`${BASE_URL}/farmers/me/dashboard`);
    const dashboard = await dashboardRes.json();
    assert(dashboardRes.status === 200, 'Status is 200');
    assert(dashboard.farmsCount >= 3, `Farms count: ${dashboard.farmsCount}`);
    assert(dashboard.totalHectares > 0, `Total land: ${dashboard.totalHectares} ha (${dashboard.totalQadaa} qadaa)`);
    assert(dashboard.cropsSummary?.length > 0, `Crops summary aggregates ${dashboard.cropsSummary.length} crops`);

    // 10. Flagship 4.4: Digital Creditworthiness Profile
    console.log('\n10. Testing GET /farmers/me/creditworthiness (Flagship 4.4)...');
    const creditRes = await fetch(`${BASE_URL}/farmers/me/creditworthiness`);
    const credit = await creditRes.json();
    assert(creditRes.status === 200, 'Status is 200');
    assert(credit.creditScore >= 70 && credit.creditScore <= 100, `Credit score computed: ${credit.creditScore}/100`);
    assert(!!credit.grade, `Credit rating grade: ${credit.grade}`);
    assert(!!credit.riskTier, `Risk tier: ${credit.riskTier}`);
    assert(credit.maxLoanEligibilityETB >= 50000, `Max loan eligibility: ${credit.maxLoanEligibilityETB.toLocaleString()} ETB`);
    assert(!!credit.scoreBreakdown.landholdingVerification, 'Breakdown includes landholding score');
    assert(!!credit.scoreBreakdown.cropCyclesAndYield, 'Breakdown includes crop projection score');
    assert(!!credit.scoreBreakdown.cooperativeMembership, 'Breakdown includes cooperative standing');
    assert(!!credit.scoreBreakdown.verifiedSalesLedger, 'Breakdown includes verified sales ledger');
    assert(credit.eligibleLenders.some((l) => l.name.includes('Sinqee')), 'Includes Sinqee Bank as eligible partner');
    assert(credit.eligibleLenders.some((l) => l.name.includes('Coopbank')), 'Includes Cooperative Bank of Oromia');
    assert(!!credit.digitalVerificationCode, `Digital verification code generated: ${credit.digitalVerificationCode}`);

    console.log(`\n======================================================`);
    console.log(`Phase 4 Backend Test Summary: ${passed} PASSED, ${failed} FAILED`);
    console.log(`======================================================`);

    if (failed > 0) process.exit(1);
    process.exit(0);
  } catch (err) {
    console.error('Test execution error:', err);
    process.exit(1);
  }
}

runTests();
