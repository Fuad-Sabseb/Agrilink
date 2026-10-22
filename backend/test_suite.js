import axios from 'axios';
import fs from 'fs';
import path from 'path';

const API_BASE = 'http://localhost:5001/api/v1';

const results = [];

const logTest = (name, passed, detail = '') => {
  results.push({ name, passed, detail });
  const icon = passed ? '✅' : '❌';
  console.log(`${icon} [${passed ? 'PASS' : 'FAIL'}] ${name} ${detail ? `(${detail})` : ''}`);
};

const runSuite = async () => {
  console.log('\n======================================================');
  console.log('🧪 RUNNING AGROLINK BACKEND END-TO-END TEST SUITE 🧪');
  console.log('======================================================\n');

  let farmerToken = '';
  let buyerToken = '';
  let transporterToken = '';
  let bureauToken = '';
  let createdProduceId = '';
  let createdOrderId = '';
  let createdTripId = '';
  let createdInspectionId = '';

  try {
    // TEST 1: Health Check
    const healthRes = await axios.get(`${API_BASE}/health`);
    logTest(
      'Server Health Check & Gateways Active',
      healthRes.status === 200 && healthRes.data.status === 'ok',
      `DB: ${healthRes.data.database}`
    );

    // TEST 2: Ethio Telecom SMS OTP Dispatch
    const otpSendRes = await axios.post(`${API_BASE}/auth/send-otp`, {
      phone: '+251911223344',
      purpose: 'login',
    });
    logTest(
      'Ethio Telecom SMS OTP Dispatch Gateway',
      otpSendRes.data.success === true,
      `OTP generated for +251911223344`
    );

    // TEST 3: Farmer Authentication & JWT Token Issuance
    const farmerLoginRes = await axios.post(`${API_BASE}/auth/login`, {
      phone: '+251911223344',
      password: 'password123',
    });
    farmerToken = farmerLoginRes.data.tokens.accessToken;
    logTest(
      'Farmer Login & JWT Rotation (Abebe Bikila)',
      farmerLoginRes.status === 200 && !!farmerToken,
      `Role: ${farmerLoginRes.data.user.role}`
    );

    // TEST 4: Buyer Authentication (Almaz Ayana)
    const buyerLoginRes = await axios.post(`${API_BASE}/auth/login`, {
      phone: '+251922334455',
      password: 'password123',
    });
    buyerToken = buyerLoginRes.data.tokens.accessToken;
    logTest(
      'Buyer Login & JWT Issuance (Almaz Ayana)',
      buyerLoginRes.status === 200 && !!buyerToken,
      `Role: ${buyerLoginRes.data.user.role}`
    );

    // TEST 5: Transporter Authentication (Haile Gebrselassie)
    const transporterLoginRes = await axios.post(`${API_BASE}/auth/login`, {
      phone: '+251933445566',
      password: 'password123',
    });
    transporterToken = transporterLoginRes.data.tokens.accessToken;
    logTest(
      'Transporter Login & JWT Issuance (Haile Gebrselassie)',
      transporterLoginRes.status === 200 && !!transporterToken,
      `Role: ${transporterLoginRes.data.user.role}`
    );

    // TEST 6: Bureau Officer Authentication (Derartu Tulu)
    const bureauLoginRes = await axios.post(`${API_BASE}/auth/login`, {
      phone: '+251944556677',
      password: 'password123',
    });
    bureauToken = bureauLoginRes.data.tokens.accessToken;
    logTest(
      'Bureau Officer Login & JWT Issuance (Derartu Tulu)',
      bureauLoginRes.status === 200 && !!bureauToken,
      `Role: ${bureauLoginRes.data.user.role}`
    );

    // TEST 7: User Profile Endpoint (Protected by JWT)
    const profileRes = await axios.get(`${API_BASE}/user/profile`, {
      headers: { Authorization: `Bearer ${farmerToken}` },
    });
    logTest(
      'Protected User Profile Retrieval',
      profileRes.data.success === true && profileRes.data.user.phone === '+251911223344',
      `User: ${profileRes.data.user.fullName}`
    );

    // TEST 8: Produce Listing (Public Browse)
    const produceListRes = await axios.get(`${API_BASE}/produce`);
    logTest(
      'Public Produce Listing Retrieval',
      produceListRes.data.success === true && produceListRes.data.produce.length >= 5,
      `Total items: ${produceListRes.data.count}`
    );

    // TEST 9: Farmer Creates New Crop Listing
    const newProduceRes = await axios.post(
      `${API_BASE}/produce`,
      {
        cropName: 'Barley (Holker Malting)',
        cropType: 'Grain',
        quantity: 800,
        unit: 'kg',
        pricePerUnit: 72.0,
        currency: 'ETB',
        description: 'Prime malting barley from Arsi highlands with high germination purity.',
        location: 'Assela, Arsi',
        woreda: 'Tiyo',
        qualityGrade: 'Grade 1',
      },
      {
        headers: { Authorization: `Bearer ${farmerToken}` },
      }
    );
    createdProduceId = newProduceRes.data.produce.id;
    logTest(
      'Farmer Creates New Produce (MongoDB Write)',
      newProduceRes.status === 201 && !!createdProduceId,
      `Crop: ${newProduceRes.data.produce.cropName}`
    );

    // TEST 10: Buyer Places Order (MongoDB Document + Farmer Push Notification)
    const orderRes = await axios.post(
      `${API_BASE}/orders`,
      {
        produceId: createdProduceId,
        quantity: 200,
        deliveryAddress: 'Hermata Grain Market, Jimma Town, Jimma Zone',
        paymentMethod: 'telebirr',
        notes: 'Please pack in 50kg standard grain sacks.',
      },
      {
        headers: { Authorization: `Bearer ${buyerToken}` },
      }
    );
    createdOrderId = orderRes.data.order.id;
    logTest(
      'Buyer Places Order with Auto Inventory Deduction',
      orderRes.status === 201 && orderRes.data.order.totalPrice === 14400,
      `Order: ${createdOrderId}, Total: ${orderRes.data.order.totalPrice} ETB`
    );

    // TEST 11: Telebirr Payment Initiation
    const telebirrInitRes = await axios.post(
      `${API_BASE}/payments/telebirr/initiate`,
      {
        orderId: createdOrderId,
        amount: 14400,
        title: 'Payment for 200kg Barley',
      },
      {
        headers: { Authorization: `Bearer ${buyerToken}` },
      }
    );
    const { outTradeNo, checkoutUrl } = telebirrInitRes.data;
    logTest(
      'Telebirr Mobile Money Checkout Initiation',
      telebirrInitRes.status === 200 && !!outTradeNo,
      `Trade No: ${outTradeNo}`
    );

    // TEST 12: Telebirr Webhook Callback (Payment Confirmation & Ledger Update)
    const webhookRes = await axios.post(`${API_BASE}/payments/telebirr/callback`, {
      outTradeNo,
      tradeNo: `TEL_${Date.now()}`,
      totalAmount: '14400',
      tradeStatus: 'Completed',
    });
    logTest(
      'Telebirr Instant Payment Webhook Callback',
      webhookRes.status === 200 && webhookRes.data.code === 0,
      `Order updated to paid & confirmed`
    );

    // TEST 13: Query Payment Status Verification
    const queryPayRes = await axios.get(`${API_BASE}/payments/telebirr/query/${createdOrderId}`, {
      headers: { Authorization: `Bearer ${buyerToken}` },
    });
    logTest(
      'Payment Status Ledger Query',
      queryPayRes.data.payment.status === 'completed' && queryPayRes.data.orderStatus === 'confirmed',
      `Payment: ${queryPayRes.data.payment.status}, Order: ${queryPayRes.data.orderStatus}`
    );

    // TEST 14: Transport Requests (Transporter Dispatch)
    const transReqRes = await axios.get(`${API_BASE}/transport/requests`, {
      headers: { Authorization: `Bearer ${transporterToken}` },
    });
    const foundReq = transReqRes.data.requests.find((r) => r.orderId === createdOrderId);
    logTest(
      'Transport Request Marketplace Discovery',
      transReqRes.status === 200 && !!foundReq,
      `Discovered delivery for order ${createdOrderId}`
    );

    // TEST 15: Transporter Accepts Trip (Intra-Jimma Zone)
    const tripRes = await axios.post(
      `${API_BASE}/transport/trips`,
      {
        orderId: createdOrderId,
        distanceKm: 25,
        earnings: 650.0,
      },
      {
        headers: { Authorization: `Bearer ${transporterToken}` },
      }
    );
    createdTripId = tripRes.data.trip.id;
    logTest(
      'Transporter Accepts Intra-Jimma Delivery Trip',
      tripRes.status === 201 && !!createdTripId,
      `Trip ID: ${createdTripId} (25 km within Jimma)`
    );

    // TEST 16: Transporter Updates Status to In-Transit
    const tripStatusRes = await axios.patch(
      `${API_BASE}/transport/trips/${createdTripId}/status`,
      { status: 'in_transit' },
      {
        headers: { Authorization: `Bearer ${transporterToken}` },
      }
    );
    logTest(
      'Trip In-Transit Status Progression',
      tripStatusRes.data.trip.status === 'in_transit',
      `Status: ${tripStatusRes.data.trip.status}`
    );

    // TEST 17: Transporter Submits Proof of Delivery (POD)
    const podRes = await axios.post(
      `${API_BASE}/transport/trips/${createdTripId}/pod`,
      {
        recipientName: 'Almaz Ayana',
        photoUrl: 'http://localhost:5001/uploads/images/sample_delivery_proof.jpg',
        signatureUrl: 'http://localhost:5001/uploads/signatures/buyer_signature.png',
        notes: 'All bags verified, undamaged and dry at Hermata Market depot.',
      },
      {
        headers: { Authorization: `Bearer ${transporterToken}` },
      }
    );
    logTest(
      'Proof of Delivery (POD) Verification & Completion',
      podRes.data.trip.status === 'delivered',
      `Recipient: ${podRes.data.trip.proofOfDelivery.recipientName}`
    );

    // TEST 18: Bureau of Agriculture Inspection Creation (Mana Woreda, Jimma Zone)
    const inspRes = await axios.post(
      `${API_BASE}/bureau/inspections`,
      {
        woredaName: 'Mana Woreda',
        targetType: 'farm',
        farmName: 'Bikila Coffee & Grain Farm, Mana, Jimma',
        type: 'quality_certification',
        notes: 'Jimma Zone agricultural standards and organic compliance certification.',
      },
      {
        headers: { Authorization: `Bearer ${bureauToken}` },
      }
    );
    createdInspectionId = inspRes.data.inspection.id;
    logTest(
      'Agricultural Bureau Inspection Creation (Jimma Zone)',
      inspRes.status === 201 && !!createdInspectionId,
      `Woreda: ${inspRes.data.inspection.woredaName}`
    );

    // TEST 19: Bureau Officer Adds Finding
    const findingRes = await axios.post(
      `${API_BASE}/bureau/inspections/${createdInspectionId}/findings`,
      {
        title: 'Moisture Level 11.8% Compliant',
        severity: 'low',
        description: 'Moisture content conforms with Jimma Zone Coffee & Grain Standards.',
      },
      {
        headers: { Authorization: `Bearer ${bureauToken}` },
      }
    );
    logTest(
      'Inspection Finding & Compliance Recording',
      findingRes.data.inspection.findings.length === 1,
      `Finding: ${findingRes.data.inspection.findings[0].title}`
    );

    // TEST 20: Bureau Officer Digital Signature
    const signRes = await axios.post(
      `${API_BASE}/bureau/inspections/${createdInspectionId}/signature`,
      {
        signatureUrl: 'http://localhost:5001/uploads/signatures/bureau_officer_sig.png',
      },
      {
        headers: { Authorization: `Bearer ${bureauToken}` },
      }
    );
    logTest(
      'Bureau Digital Signature & Completion',
      signRes.data.inspection.status === 'completed' && !!signRes.data.inspection.signatureUrl,
      `Signed by Officer Derartu Tulu (Jimma Zone Bureau)`
    );

    // TEST 21: Commodity Regional Market Data (Jimma Zone)
    const marketRes = await axios.get(`${API_BASE}/markets`);
    const allJimma = marketRes.data.markets.every((m) => m.zone === 'Jimma Zone');
    logTest(
      'Jimma Zone Commodity Market Price Feed',
      marketRes.data.success === true && marketRes.data.markets.length === 4 && allJimma,
      `Markets: ${marketRes.data.markets.map((m) => m.name).join(', ')}`
    );

    // TEST 22: Multipart File Upload
    const dummyFilePath = path.resolve('test_upload_sample.jpg');
    fs.writeFileSync(dummyFilePath, Buffer.from('FAKE_JPEG_IMAGE_BINARY_DATA_FOR_TESTING'));

    const formData = new FormData();
    const fileBlob = new Blob([fs.readFileSync(dummyFilePath)], { type: 'image/jpeg' });
    formData.append('file', fileBlob, 'sample_produce.jpg');

    const uploadResponse = await fetch(`${API_BASE}/upload/image`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${farmerToken}`,
      },
      body: formData,
    });
    const uploadData = await uploadResponse.json();

    logTest(
      'Cloud Storage Multipart File Upload',
      uploadResponse.status === 200 && !!uploadData.url,
      `Served at: ${uploadData.url}`
    );

    if (fs.existsSync(dummyFilePath)) {
      fs.unlinkSync(dummyFilePath);
    }

    // =========================================================================
    // PHASE 1: "WHERE SHOULD I SELL?" DECISION INTELLIGENCE ENGINE TESTS (JIMMA ZONE ONLY)
    // =========================================================================

    // TEST 23: Decision Engine - List Benchmark Markets strictly within Jimma Zone
    const marketsRes = await axios.get(`${API_BASE}/decision-engine/markets`);
    const allMarketsInJimma = marketsRes.data.markets.every((m) => m.zone === 'Jimma');
    logTest(
      'Decision Engine Benchmark Markets Query (Strictly Jimma Zone)',
      marketsRes.status === 200 && marketsRes.data.markets.length === 4 && allMarketsInJimma,
      `Jimma Markets: ${marketsRes.data.markets.map((m) => m.marketCode).join(', ')}`
    );

    // TEST 24: Decision Engine - Priority Crops Overview in Jimma Zone
    const cropsRes = await axios.get(`${API_BASE}/decision-engine/crops`);
    logTest(
      'Decision Engine Priority Crops Price Feed',
      cropsRes.status === 200 && cropsRes.data.crops.length >= 7,
      `Supported crops: ${cropsRes.data.crops.map((c) => c.cropName).join(', ')}`
    );

    // TEST 25: Decision Engine - 5,000 kg Potato Net-Revenue Proof in Jimma Zone
    const potatoDecisionRes = await axios.post(`${API_BASE}/decision-engine/recommend`, {
      cropName: 'Potato',
      quantity: 5000,
      unit: 'kg',
      originWoreda: 'Mana',
    });

    const potData = potatoDecisionRes.data;
    const comparisonsAllJimma = potData.comparisons.every((c) => c.zone === 'Jimma');
    const hasAfaanOromoo = !!potData.explanations.afaanOromoo.recommendation;

    logTest(
      'Flagship "Where Should I Sell?" Potato Net-Revenue Ranking (Jimma Zone)',
      comparisonsAllJimma && hasAfaanOromoo && potData.comparisons.length === 4,
      `Optimal: ${potData.summary.recommendedMarket} (Net: ${potData.summary.bestNetRevenue} ETB vs Local: ${potData.summary.bestNetRevenue - potData.summary.netUpliftVsLocal} ETB)`
    );

    // TEST 26: Decision Engine - Bilingual Afaan Oromoo & English Explanation
    logTest(
      'Bilingual Decision Insights Generation (Afaan Oromoo & English)',
      !!potData.explanations.afaanOromoo.headline && !!potData.explanations.english.headline,
      `AO: "${potData.explanations.afaanOromoo.headline}"`
    );

    // TEST 27: Decision Engine - Afaan Oromoo Crop Alias & Unit Conversion (Quintals)
    const teffDecisionRes = await axios.post(`${API_BASE}/decision-engine/recommend`, {
      cropName: 'Xaafii', // Afaan Oromoo for Teff
      quantity: 20,       // 20 quintals = 2,000 kg
      unit: 'quintal',
      originWoreda: 'Jimma',
    });
    logTest(
      'Afaan Oromoo Query ("Xaafii") & Quintal Conversion',
      teffDecisionRes.data.success === true && teffDecisionRes.data.query.weightKg === 2000,
      `20 Quintals normalized to 2,000 kg for crop: ${teffDecisionRes.data.query.crop}`
    );

    // TEST 28: Decision Engine - Price Feed Update (Bureau / Admin Role)
    const updatePriceRes = await axios.post(
      `${API_BASE}/decision-engine/prices`,
      {
        marketCode: 'MKT_JIMMA',
        cropName: 'Tomato',
        pricePerKg: 49.5,
        trend: '+10.0%',
      },
      {
        headers: { Authorization: `Bearer ${bureauToken}` },
      }
    );
    logTest(
      'Agricultural Bureau Commodity Price Update (Jimma Central)',
      updatePriceRes.status === 200 && updatePriceRes.data.success === true,
      `Updated Jimma Central Tomato benchmark to 49.5 ETB/kg`
    );
  } catch (err) {
    console.error('❌ Exception during test suite:', err.response?.data || err.message);
    logTest('Test Suite Exception', false, err.message);
  }

  console.log('\n======================================================');
  const passedCount = results.filter((r) => r.passed).length;
  const totalCount = results.length;
  console.log(`📊 FINAL RESULT: ${passedCount}/${totalCount} TESTS PASSED (${((passedCount / totalCount) * 100).toFixed(0)}%)`);
  console.log('======================================================\n');
};

runSuite();
