import fetch from 'node-fetch';

const BASE_URL = 'http://localhost:5001/api/v1';

async function runTests() {
  console.log('🧪 Starting Phase 6 Integration Tests: AgriAI Conversational Assistant (Afaan Oromoo)...\n');
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
    // 1. Afaan Oromoo Market Price Query with Grounded RAG
    console.log('1. Testing POST /ai/chat: Afaan Oromoo Market Price Query...');
    const priceRes = await fetch(`${BASE_URL}/ai/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        query: 'Buna Jimmaatti meeqaan gurgurama? Gabaa kamtu caala?',
        language: 'om',
      }),
    });
    const priceData = await priceRes.json();
    assert(priceRes.status === 200, 'Status is 200');
    assert(priceData.success === true, 'Success flag is true');
    assert(priceData.language === 'om', 'Detected/handled language is Afaan Oromoo (om)');
    assert(priceData.intent === 'market_price', 'Intent identified as market_price');
    assert(priceData.citations && priceData.citations.length > 0, `Generated ${priceData.citations.length} verified benchmark citations`);
    assert(priceData.response.includes('Gatii Gabaa Buna'), 'Response includes Afaan Oromoo coffee market header');
    assert(!!priceData.audioScript, 'Audio readout script generated for voice synthesis');
    console.log(`     Excerpt: ${priceData.response.slice(0, 110)}...`);

    // 2. Strict Hallucination Guardrail: Non-Jimma Geographic Query Rejection
    console.log('\n2. Testing POST /ai/chat: Non-Jimma Geographic Guardrail Rejection...');
    const guardrailRes = await fetch(`${BASE_URL}/ai/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        query: 'What is the price of teff in Addis Ababa Merkato?',
        language: 'en',
      }),
    });
    const guardrailData = await guardrailRes.json();
    assert(guardrailRes.status === 200, 'Status is 200');
    assert(guardrailData.intent === 'out_of_boundary_guardrail', 'Intent identified as out_of_boundary_guardrail');
    assert(guardrailData.response.includes('strictly') || guardrailData.response.includes('exclusively within Jimma Zone'), 'Politely refused non-Jimma market');
    assert(!guardrailData.response.includes('Merkato price: 9000'), 'Zero fabricated data hallucinated for Addis Ababa');

    // 3. Afaan Oromoo Buyer Demand Query
    console.log('\n3. Testing POST /ai/chat: Live "Buying Now" Buyer Demand Query...');
    const buyerRes = await fetch(`${BASE_URL}/ai/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        query: 'Buna eenyutu bitaa jira Jimma keessatti?',
        language: 'om',
      }),
    });
    const buyerData = await buyerRes.json();
    assert(buyerRes.status === 200, 'Status is 200');
    assert(buyerData.intent === 'buyer_demand', 'Intent identified as buyer_demand');
    assert(buyerData.citations.some(c => c.source === 'BuyerDemand'), 'Cites verified BuyerDemand collection');
    assert(buyerData.response.includes('Dhiyeessii Bittaa Bunaa'), 'Contains Afaan Oromoo buyer listing');

    // 4. Logistics and Transit Checkpoint Query
    console.log('\n4. Testing POST /ai/chat: Logistics & Road Corridor Transit Query...');
    const logRes = await fetch(`${BASE_URL}/ai/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        query: 'Baasii geejjibaa fi kellaa Jimmaa irraa gara Aggaaroo meeqa?',
        language: 'om',
      }),
    });
    const logData = await logRes.json();
    assert(logRes.status === 200, 'Status is 200');
    assert(logData.intent === 'logistics_transit', 'Intent identified as logistics_transit');
    assert(logData.citations.some(c => c.source === 'RouteCorridor'), 'Cites RouteCorridor ledger');
    assert(logData.response.includes('Geejjiba Daandii'), 'Provides transit cost breakdown');

    // 5. Agronomy & Soil Management Query
    console.log('\n5. Testing POST /ai/chat: Jimma Zone Soil Health & Agronomy Query...');
    const soilRes = await fetch(`${BASE_URL}/ai/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        query: 'Fayyaa biyyee diimaa fi kotichaa akkamitti eegna?',
        language: 'om',
      }),
    });
    const soilData = await soilRes.json();
    assert(soilRes.status === 200, 'Status is 200');
    assert(soilData.intent === 'farm_and_soil', 'Intent identified as farm_and_soil');
    assert(soilData.response.includes('Biyyee Diimaa') || soilData.response.includes('Nitisols'), 'Identified Jimma Nitisols/Vertisols');
    assert(soilData.citations.some(c => c.label.includes('JARC') || c.source === 'AgriKnowledgeBase'), 'Cites JARC Soil Knowledge Base');

    // 6. Conversational Plant Pathology Query
    console.log('\n6. Testing POST /ai/chat: Coffee Leaf Rust Pathology Query...');
    const pathRes = await fetch(`${BASE_URL}/ai/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        query: 'Dhukkuba waaqoo bunaa akkamitti ittisuu danda\'ama?',
        language: 'om',
      }),
    });
    const pathData = await pathRes.json();
    assert(pathRes.status === 200, 'Status is 200');
    assert(pathData.intent === 'plant_disease', 'Intent identified as plant_disease');
    assert(pathData.response.includes('Waaqoo') || pathData.response.includes('Hemileia'), 'Identified Coffee Leaf Rust');
    assert(pathData.response.includes('74110') || pathData.response.includes('74112'), 'Recommends JARC certified resistant varieties');

    // 7. Flagship Plant Disease Screening: Coffee Leaf Rust
    console.log('\n7. Testing POST /ai/screen-disease: Coffee Leaf Rust Screening...');
    const screenRustRes = await fetch(`${BASE_URL}/ai/screen-disease`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        cropHint: 'Coffee',
        diseaseHint: 'rust',
        symptomDescription: 'Orange powdery pustules underneath coffee leaves',
      }),
    });
    const screenRust = await screenRustRes.json();
    assert(screenRustRes.status === 200, 'Status is 200');
    assert(screenRust.success === true, 'Screening succeeded');
    assert(screenRust.confidencePercentage >= 90, `Confidence is ${screenRust.confidencePercentage}%`);
    assert(screenRust.diagnosis.diseaseName.includes('Coffee Leaf Rust'), 'Diagnosed Coffee Leaf Rust');
    assert(screenRust.diagnosis.diseaseNameAfaanOromoo.includes('Waaqoo'), 'Diagnosed Afaan Oromoo name: Waaqoo Baala Bunaa');
    assert(screenRust.diagnosis.scientificName === 'Hemileia vastatrix', 'Scientific name Hemileia vastatrix verified');
    assert(screenRust.treatmentProtocol.cultural.om.length > 10, 'Cultural treatment provided in Afaan Oromoo');
    assert(screenRust.treatmentProtocol.organic.om.length > 10, 'Organic remedy provided in Afaan Oromoo');
    assert(screenRust.treatmentProtocol.chemicalApproved.en.includes('Copper'), 'Approved chemical remedy specified');
    assert(screenRust.recommendedResistantVarieties.cultivars.includes('74110'), 'JARC cultivars (74110) listed');
    assert(!!screenRust.audioReadout.afaanOromoo, 'Afaan Oromoo audio readout provided');

    // 8. Plant Disease Screening: Coffee Berry Disease (CBD)
    console.log('\n8. Testing POST /ai/screen-disease: Coffee Berry Disease (CBD)...');
    const screenCbdRes = await fetch(`${BASE_URL}/ai/screen-disease`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        cropHint: 'Coffee',
        diseaseHint: 'cbd black sunken berry spots',
        symptomDescription: 'Dark anthracnose sunken spots on green expanding cherries',
      }),
    });
    const screenCbd = await screenCbdRes.json();
    assert(screenCbdRes.status === 200, 'Status is 200');
    assert(screenCbd.diagnosis.diseaseName.includes('Berry Disease'), 'Diagnosed Coffee Berry Disease');
    assert(screenCbd.diagnosis.scientificName === 'Colletotrichum kahawae', 'Scientific name Colletotrichum kahawae');
    assert(screenCbd.confidencePercentage >= 95, `Confidence: ${screenCbd.confidencePercentage}%`);

    // 9. Plant Disease Screening: Maize Lethal Necrosis (MLN)
    console.log('\n9. Testing POST /ai/screen-disease: Maize Lethal Necrosis...');
    const screenMlnRes = await fetch(`${BASE_URL}/ai/screen-disease`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        cropHint: 'Maize',
        diseaseHint: 'mln chlorotic stripe necrosis',
        symptomDescription: 'Chlorotic mottling and drying leaf margins on maize in Dedo',
      }),
    });
    const screenMln = await screenMlnRes.json();
    assert(screenMlnRes.status === 200, 'Status is 200');
    assert(screenMln.diagnosis.diseaseName.includes('Maize Lethal Necrosis'), 'Diagnosed Maize Lethal Necrosis');
    assert(screenMln.recommendedResistantVarieties.cultivars.includes('BH-661'), 'Cultivars include BH-661');

    // 10. Plant Disease Screening: Potato Late Blight
    console.log('\n10. Testing POST /ai/screen-disease: Potato Late Blight...');
    const screenBlightRes = await fetch(`${BASE_URL}/ai/screen-disease`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        cropHint: 'Potato',
        diseaseHint: 'late blight black water lesions',
        symptomDescription: 'Water soaked spots on potato leaves in Gera',
      }),
    });
    const screenBlight = await screenBlightRes.json();
    assert(screenBlightRes.status === 200, 'Status is 200');
    assert(screenBlight.diagnosis.diseaseName.includes('Late Blight'), 'Diagnosed Late Blight');
    assert(screenBlight.recommendedResistantVarieties.cultivars.includes('Belete'), 'Cultivars include Belete');

    // 11. Agronomic Knowledge Base endpoints
    console.log('\n11. Testing GET /ai/knowledge...');
    const kbRes = await fetch(`${BASE_URL}/ai/knowledge`);
    const kbData = await kbRes.json();
    assert(kbRes.status === 200, 'Status is 200');
    assert(kbData.count >= 6, `Knowledge base returned ${kbData.count} topics`);

    console.log('\n12. Testing GET /ai/knowledge/:topicId (coffee_leaf_rust)...');
    const topicRes = await fetch(`${BASE_URL}/ai/knowledge/coffee_leaf_rust`);
    const topicData = await topicRes.json();
    assert(topicRes.status === 200, 'Status is 200');
    assert(topicData.topic.topicId === 'coffee_leaf_rust', 'Retrieved topic coffee_leaf_rust');
    assert(topicData.topic.isVerifiedByJARC === true, 'Verified by JARC / EIAR');

    console.log('\n====================================================');
    console.log(`Phase 6 Test Results: ${passed} passed, ${failed} failed`);
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
