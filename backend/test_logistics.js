import fetch from 'node-fetch';

const BASE_URL = 'http://localhost:5001/api/v1';

async function runTests() {
  console.log('🧪 Starting Phase 5 Integration Tests: AgriLogistics & Route Transit Fee Transparency...\n');
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
    // 1. Corridors & Road Quality Ledger
    console.log('1. Testing GET /logistics/corridors...');
    const corrRes = await fetch(`${BASE_URL}/logistics/corridors`);
    const corrData = await corrRes.json();
    assert(corrRes.status === 200, 'Status is 200');
    assert(corrData.count >= 6, `Returned ${corrData.count} corridors in Jimma Zone`);
    const agaroCorr = corrData.corridors.find((c) => c.corridorCode === 'CORR_JIMMA_AGARO');
    assert(!!agaroCorr, 'Found Jimma–Agaro Corridor');
    assert(agaroCorr.distanceKm === 45, 'Distance is 45 km');
    assert(agaroCorr.roadCondition === 'asphalt_good', `Road condition: ${agaroCorr.roadCondition}`);
    assert(agaroCorr.roadConditionMultiplier === 1.05, `Multiplier: ${agaroCorr.roadConditionMultiplier}x`);

    const addisGateway = corrData.corridors.find((c) => c.corridorCode === 'CORR_JIMMA_ADDIS_GATEWAY');
    assert(!!addisGateway, 'Found Jimma Gateway – Addis Corridor');

    // 2. Checkpoints & Kellaa Live Ledger
    console.log('\n2. Testing GET /logistics/checkpoints (Live Kellaa Ledger)...');
    const chkRes = await fetch(`${BASE_URL}/logistics/checkpoints`);
    const chkData = await chkRes.json();
    assert(chkRes.status === 200, 'Status is 200');
    assert(chkData.count >= 7, `Returned ${chkData.count} verified checkpoints`);
    const manaKella = chkData.checkpoints.find((k) => k.checkpointCode === 'KEL_MANA_YABU');
    assert(!!manaKella, 'Found Mana/Yabu Checkpoint');
    assert(manaKella.currentLiveFeeETB > 0, `Live Fee: ${manaKella.currentLiveFeeETB} ETB`);
    assert(manaKella.upvotes >= 10, `Transporter confirmations: ${manaKella.upvotes} upvotes`);
    assert(!!manaKella.currentStatus, `Live status: ${manaKella.currentStatus}`);

    // 3. Transporter Reports Live Kellaa Fee
    console.log('\n3. Testing POST /logistics/checkpoints/:code/report...');
    const reportRes = await fetch(`${BASE_URL}/logistics/checkpoints/KEL_MANA_YABU/report`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        reportedFeeETB: 140,
        delayMinutes: 25,
        congestionLevel: 'active_moderate_delay',
        comment: 'Market day backup near Yabu junction; 140 ETB collected.',
        vehicleType: 'isuzu_npr',
      }),
    });
    const reportData = await reportRes.json();
    assert(reportRes.status === 200, 'Status is 200');
    assert(reportData.checkpoint.currentLiveFeeETB === 140, `Updated live fee to ${reportData.checkpoint.currentLiveFeeETB} ETB`);
    assert(reportData.checkpoint.delayMinutesAvg === 25, 'Updated delay to 25 min');

    // 4. Confirm / Upvote Checkpoint Tariff
    console.log('\n4. Testing POST /logistics/checkpoints/:code/confirm...');
    const confirmRes = await fetch(`${BASE_URL}/logistics/checkpoints/KEL_MANA_YABU/confirm`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
    });
    const confirmData = await confirmRes.json();
    assert(confirmRes.status === 200, 'Status is 200');
    assert(confirmData.checkpoint.upvotes === manaKella.upvotes + 1, `Upvotes incremented to ${confirmData.checkpoint.upvotes}`);

    // 5. Flagship Landed-Cost Route Estimator
    console.log('\n5. Testing POST /logistics/estimate-landed-cost (Flagship Estimator)...');
    const estRes = await fetch(`${BASE_URL}/logistics/estimate-landed-cost`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        originWoreda: 'Mana',
        destinationWoreda: 'Jimma Town',
        cropName: 'Maize',
        quantityKg: 3000,
        farmgatePricePerKg: 38.0,
      }),
    });
    const estData = await estRes.json();
    assert(estRes.status === 200, 'Status is 200');
    assert(estData.parameters.quantityQuintals === 30, `Converted 3,000 kg to 30 Quintals`);
    assert(estData.costBreakdown.baseFreightETB > 0, `Base Freight: ${estData.costBreakdown.baseFreightETB} ETB`);
    assert(estData.costBreakdown.checkpointTariffsETB > 0, `Checkpoints Tariffs included: ${estData.costBreakdown.checkpointTariffsETB} ETB`);
    assert(estData.costBreakdown.handlingFeeETB > 0, `Handling fee: ${estData.costBreakdown.handlingFeeETB} ETB`);
    assert(estData.costBreakdown.totalLogisticsCostETB > 0, `Total Logistics: ${estData.costBreakdown.totalLogisticsCostETB.toLocaleString()} ETB`);
    assert(estData.costBreakdown.logisticsCostPerKg > 0, `Logistics Cost: ${estData.costBreakdown.logisticsCostPerKg} ETB/kg`);
    assert(estData.costBreakdown.landedCostPerKg > estData.parameters.farmgatePricePerKg, `Landed Cost: ${estData.costBreakdown.landedCostPerKg} ETB/kg (Farmgate: 38 ETB/kg)`);
    assert(estData.checkpoints.length >= 1, `Route passes through ${estData.checkpoints.length} intermediate checkpoints`);
    assert(!!estData.advisory.afaanOromoo, `Afaan Oromoo advice generated: "${estData.advisory.afaanOromoo.slice(0, 50)}..."`);
    assert(!!estData.advisory.english, 'English advice generated');

    // 6. Test Estimator with Perishable Produce & Pickup Carrier
    console.log('\n6. Testing Estimator with Perishable Tomatoes on Pickup...');
    const tomatoEstRes = await fetch(`${BASE_URL}/logistics/estimate-landed-cost`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        originWoreda: 'Seka Chekorsa',
        destinationWoreda: 'Jimma Town',
        cropName: 'Tomato',
        quantityKg: 1200,
        farmgatePricePerKg: 42.0,
        preferredCarrierType: 'pickup',
      }),
    });
    const tomatoEst = await tomatoEstRes.json();
    assert(tomatoEstRes.status === 200, 'Status is 200');
    assert(tomatoEst.parameters.carrierType === 'pickup', 'Selected Pickup carrier for 1,200 kg tomatoes');
    assert(tomatoEst.costBreakdown.landedCostPerKg > 42.0, `Tomato landed cost: ${tomatoEst.costBreakdown.landedCostPerKg} ETB/kg`);

    // 7. Verified Village Collectors (Aggregators)
    console.log('\n7. Testing GET /logistics/collectors...');
    const colRes = await fetch(`${BASE_URL}/logistics/collectors`);
    const colData = await colRes.json();
    assert(colRes.status === 200, 'Status is 200');
    assert(colData.count >= 5, `Listed ${colData.count} certified village aggregators`);
    const yabuCol = colData.collectors.find((c) => c.collectorCode === 'COL-MANA-01');
    assert(!!yabuCol, 'Found Yabu Smallholder Aggregator');
    assert(yabuCol.serviceCommissionRate.value === 2.5, `Disclosed commission rate: ${yabuCol.serviceCommissionRate.value}%`);
    assert(yabuCol.storageCapacityQuintals === 800, `Storage capacity: ${yabuCol.storageCapacityQuintals} Qtl`);
    assert(yabuCol.supportedCrops.includes('Coffee'), 'Collects Coffee');

    // 8. Register New Village Collector
    console.log('\n8. Testing POST /logistics/collectors...');
    const newColRes = await fetch(`${BASE_URL}/logistics/collectors`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: 'Kersa Community Grain Aggregator',
        nameAfaanOromoo: 'Walitti Qabaa Midhaan Hawaasa Qarsaa',
        contactPerson: 'Mulugeta Bekele',
        phone: '+251917990011',
        woreda: 'Kersa',
        kebele: 'Kersa Central',
        warehouseLocation: 'Kersa Highway Depot #1',
        storageCapacityQuintals: 700,
        commissionRateType: 'percentage',
        commissionRateValue: 2.2,
        supportedCrops: ['Maize', 'Wheat', 'Teff'],
      }),
    });
    const newColData = await newColRes.json();
    assert(newColRes.status === 201, 'Status is 201');
    assert(newColData.collector.name.includes('Kersa'), 'Registered Kersa collector');
    assert(newColData.collector.zone === 'Jimma', 'Collector strictly bounded to Jimma Zone');

    // 9. Transporter Vehicle Fleet & Carrier Types
    console.log('\n9. Testing GET /logistics/fleet...');
    const fleetRes = await fetch(`${BASE_URL}/logistics/fleet`);
    const fleetData = await fleetRes.json();
    assert(fleetRes.status === 200, 'Status is 200');
    assert(fleetData.count >= 5, `Listed ${fleetData.count} fleet vehicles`);
    const nprTruck = fleetData.fleet.find((v) => v.carrierType === 'isuzu_npr');
    assert(!!nprTruck, 'Found Isuzu NPR carrier');
    assert(nprTruck.maxPayloadQuintals === 45, `Payload capacity: ${nprTruck.maxPayloadQuintals} Quintals`);
    assert(nprTruck.perKmBaseRateETB > 0, `Base rate: ${nprTruck.perKmBaseRateETB} ETB/km`);

    // 10. Vehicle Fleet Matching Engine
    console.log('\n10. Testing POST /logistics/fleet/match...');
    const matchRes = await fetch(`${BASE_URL}/logistics/fleet/match`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        originWoreda: 'Mana',
        destinationWoreda: 'Jimma Town',
        weightKg: 4000,
        cropName: 'Maize',
      }),
    });
    const matchData = await matchRes.json();
    assert(matchRes.status === 200, 'Status is 200');
    assert(matchData.matchedVehiclesCount >= 1, `Matched ${matchData.matchedVehiclesCount} compatible vehicles for 4,000 kg shipment`);
    const bestFit = matchData.matches[0];
    assert(bestFit.totalCostETB > 0, `Estimated Freight + Handling: ${bestFit.totalCostETB} ETB`);
    assert(bestFit.costPerKg > 0, `Cost per kg: ${bestFit.costPerKg} ETB/kg`);

    console.log(`\n======================================================`);
    console.log(`Phase 5 Backend Test Summary: ${passed} PASSED, ${failed} FAILED`);
    console.log(`======================================================`);

    if (failed > 0) process.exit(1);
    process.exit(0);
  } catch (err) {
    console.error('Test execution error:', err);
    process.exit(1);
  }
}

runTests();
