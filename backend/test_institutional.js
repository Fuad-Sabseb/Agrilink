import fetch from 'node-fetch';

const BASE_URL = 'http://localhost:5001/api/v1';

async function runTests() {
  console.log('🧪 Starting Phase 7 Integration Tests: Institutional Agricultural Intelligence Dashboard...\n');
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
    // 1. Regional Macro Overview KPIs
    console.log('1. Testing GET /institutional/overview...');
    const overviewRes = await fetch(`${BASE_URL}/institutional/overview`);
    const overviewData = await overviewRes.json();
    assert(overviewRes.status === 200, 'Status is 200');
    assert(overviewData.success === true, 'Success flag is true');
    assert(overviewData.zone === 'Jimma Zone, Oromia', 'Strictly bounded to Jimma Zone, Oromia');
    assert(overviewData.zoneAfaanOromoo === 'Godina Jimmaa, Oromiyaa', 'Afaan Oromoo localization: Godina Jimmaa');
    assert(overviewData.kpis.totalCultivatedHectares > 0, `Total cultivated hectares: ${overviewData.kpis.totalCultivatedHectares} ha`);
    assert(overviewData.kpis.totalCultivatedQadaa === Number((overviewData.kpis.totalCultivatedHectares * 4).toFixed(2)), 'Dual measurement verified: Hectares * 4 = Qadaa');
    assert(overviewData.kpis.totalProjectedOutputQuintals > 0, `Projected output: ${overviewData.kpis.totalProjectedOutputQuintals} Qtl`);
    assert(overviewData.kpis.totalActiveFarms >= 2, `Active registered farms: ${overviewData.kpis.totalActiveFarms}`);
    assert(overviewData.kpis.totalFarmingHouseholds > 100000, `Farming households monitored: ${overviewData.kpis.totalFarmingHouseholds}`);
    assert(overviewData.kpis.activeAlertsCount >= 3, `Active early-warning alerts: ${overviewData.kpis.activeAlertsCount}`);
    assert(overviewData.kpis.criticalAlertsCount >= 1, `Critical alerts: ${overviewData.kpis.criticalAlertsCount}`);
    assert(overviewData.woredasMonitoredCount >= 9, `Monitors ${overviewData.woredasMonitoredCount} woredas in Jimma Zone`);
    assert(overviewData.cropBreakdown.some((c) => c.cropName === 'Coffee' && c.cropNameAfaanOromoo === 'Buna'), 'Crop breakdown includes Coffee (Buna)');

    // 2. Supply vs Demand Heatmap & Surplus/Deficit Matrix
    console.log('\n2. Testing GET /institutional/heatmap...');
    const heatmapRes = await fetch(`${BASE_URL}/institutional/heatmap`);
    const heatmapData = await heatmapRes.json();
    assert(heatmapRes.status === 200, 'Status is 200');
    assert(heatmapData.success === true, 'Success flag is true');
    assert(heatmapData.heatmap.length >= 9, `Returns heatmap matrix for ${heatmapData.heatmap.length} woredas`);
    
    const sekaWoreda = heatmapData.heatmap.find((w) => w.woreda === 'Seka Chekorsa');
    assert(!!sekaWoreda, 'Found Seka Chekorsa in heatmap');
    assert(sekaWoreda.metrics.balanceStatus === 'deficit', `Seka Chekorsa status: ${sekaWoreda.metrics.balanceStatus} (${sekaWoreda.metrics.netBalanceQuintals} Qtl)`);
    assert(sekaWoreda.coordinates.latitude > 7.0 && sekaWoreda.coordinates.longitude > 36.0, 'GIS coordinates present for visual map plotting');

    const manaWoreda = heatmapData.heatmap.find((w) => w.woreda === 'Mana');
    assert(!!manaWoreda, 'Found Mana woreda in heatmap');
    assert(manaWoreda.dominantSoil === 'nitisol_red_clay', 'Mana dominant soil is Red Nitisol');

    // Filter heatmap by crop: Coffee
    console.log('\n2b. Testing GET /institutional/heatmap?crop=Coffee...');
    const coffeeHeatmapRes = await fetch(`${BASE_URL}/institutional/heatmap?crop=Coffee`);
    const coffeeHeatmapData = await coffeeHeatmapRes.json();
    assert(coffeeHeatmapRes.status === 200, 'Status is 200');
    assert(coffeeHeatmapData.cropFilter === 'Coffee', 'Filtered by Coffee');

    // 3. Price Volatility & Market Surveillance Engine
    console.log('\n3. Testing GET /institutional/volatility...');
    const volRes = await fetch(`${BASE_URL}/institutional/volatility`);
    const volData = await volRes.json();
    assert(volRes.status === 200, 'Status is 200');
    assert(volData.success === true, 'Success flag is true');
    assert(volData.monitoredMarketsCount === 4, 'Monitors 4 benchmark commodity markets in Jimma Zone');
    assert(volData.volatilityReport.length >= 7, `Analyzed price volatility across ${volData.volatilityReport.length} crops`);
    
    const teffVol = volData.volatilityReport.find((v) => v.cropName === 'Teff');
    assert(!!teffVol, 'Found Teff in volatility surveillance');
    assert(teffVol.volatilityPercentage > 0, `Teff Volatility: ${teffVol.volatilityPercentage}% (Spread: ${teffVol.priceSpreadETB} ETB)`);
    assert(teffVol.marketBreakdown.length === 4, 'Includes price breakdown across all 4 markets');

    // 4. Production, Yield & Soil Distribution Analytics
    console.log('\n4. Testing GET /institutional/production...');
    const prodRes = await fetch(`${BASE_URL}/institutional/production`);
    const prodData = await prodRes.json();
    assert(prodRes.status === 200, 'Status is 200');
    assert(prodData.cropYields.length >= 2, `Computed yield data for ${prodData.cropYields.length} crops`);
    assert(prodData.soilAnalytics.nitisolRedClay.hectares > 0, 'Aggregates Red Nitisol hectares');
    assert(prodData.soilAnalytics.vertisolBlackClay.hectares > 0, 'Aggregates Black Vertisol hectares');
    assert(prodData.growthStagePipelineQuintals.flowering !== undefined, 'Tracks crop growth stage pipeline');

    // 5. Early Warning & Food Security Alerts
    console.log('\n5. Testing GET /institutional/alerts...');
    const alertsRes = await fetch(`${BASE_URL}/institutional/alerts`);
    const alertsData = await alertsRes.json();
    assert(alertsRes.status === 200, 'Status is 200');
    assert(alertsData.count >= 3, `Returned ${alertsData.count} active institutional alerts`);
    
    const critAlert = alertsData.alerts.find((a) => a.severity === 'critical');
    assert(!!critAlert, 'Found critical food security deficit alert');
    assert(critAlert.targetWoredas.includes('Seka Chekorsa'), 'Critical alert targets Seka Chekorsa');
    assert(critAlert.metricPayload.deficitQuintals === 3200, 'Deficit quantified: 3,200 Quintals');

    // 6. Institutional User Issues a New Alert
    console.log('\n6. Testing POST /institutional/alerts...');
    const newAlertRes = await fetch(`${BASE_URL}/institutional/alerts`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        title: 'Fertilizer Transit Congestion at Agaro Checkpoint',
        titleAfaanOromoo: 'Cufama Geejjiba Xaa\'oo Kellaa Aggaaroo Irratti',
        alertType: 'logistics_bottleneck',
        severity: 'warning',
        targetWoredas: ['Gomma', 'Mana'],
        targetCrop: 'Maize',
        description: 'Heavy truck inspection delays at Agaro checkpoint slowing NPSB fertilizer dispatch to farming kebeles.',
        descriptionAfaanOromoo: 'Turtii kellaa Aggaaroo xaa\'oo NPSB qonnaan bultootaaf dhiyaatu tursaera.',
        recommendedAction: 'Open dedicated green lane for agricultural input carriers during morning dispatch window.',
        recommendedActionAfaanOromoo: 'Konkolaattota xaa\'oo baatan daandii addaa saffisaan akka dabarsan gochuu.',
        metricPayload: {
          affectedHouseholds: 5400,
          confidencePercent: 95,
        },
      }),
    });
    const newAlertData = await newAlertRes.json();
    assert(newAlertRes.status === 201, 'Status is 201');
    assert(newAlertData.success === true, 'Created new alert successfully');
    assert(newAlertData.alert.alertCode.startsWith('ALT-JIMMA-'), `Generated code: ${newAlertData.alert.alertCode}`);
    const createdAlertCode = newAlertData.alert.alertCode;

    // 7. Bureau Official Resolves the Alert
    console.log('\n7. Testing PATCH /institutional/alerts/:code/resolve...');
    const resolveRes = await fetch(`${BASE_URL}/institutional/alerts/${createdAlertCode}/resolve`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        resolutionNotes: 'Dedicated agricultural freight green lane established at Agaro terminal; congestion resolved.',
      }),
    });
    const resolveData = await resolveRes.json();
    assert(resolveRes.status === 200, 'Status is 200');
    assert(resolveData.alert.status === 'resolved', 'Alert status updated to resolved');
    assert(!!resolveData.alert.resolvedAt, 'Resolved timestamp recorded');

    // 8. Executive Intelligence Brief Export
    console.log('\n8. Testing GET /institutional/export-report...');
    const reportRes = await fetch(`${BASE_URL}/institutional/export-report`);
    const reportData = await reportRes.json();
    assert(reportRes.status === 200, 'Status is 200');
    assert(reportData.reportTitle.includes('Jimma Zone'), 'Report title references Jimma Zone');
    assert(reportData.academicPartner.includes('JUCAVM'), 'Cites academic partner JUCAVM (Jimma University)');
    assert(reportData.topDeficitWoredas.length > 0, 'Includes prioritized deficit woredas for intervention');

    // 9. Woreda Baseline Profiles
    console.log('\n9. Testing GET /institutional/woredas...');
    const woredaRes = await fetch(`${BASE_URL}/institutional/woredas`);
    const woredaData = await woredaRes.json();
    assert(woredaRes.status === 200, 'Status is 200');
    assert(woredaData.count >= 9, `Retrieved ${woredaData.count} Jimma woreda baselines`);
    assert(woredaData.woredas.every((w) => w.zone === 'Jimma'), 'All woredas strictly belong to Jimma Zone');

    console.log('\n====================================================');
    console.log(`Phase 7 Test Results: ${passed} passed, ${failed} failed`);
    console.log('====================================================');
    if (failed > 0) {
      process.exit(1);
    }
  } catch (error) {
    console.error('Test execution failed:', error);
    process.exit(1);
  }
}

runTests();
