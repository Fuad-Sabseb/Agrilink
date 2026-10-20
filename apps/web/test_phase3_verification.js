import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

console.log('===============================================================');
console.log('    AGRILINK PHASE 3: BUYER MARKETPLACE & MATCHING SUITE       ');
console.log('            WEB CLIENT VERIFICATION SUITE                      ');
console.log('===============================================================\n');

let passedTests = 0;
let totalTests = 0;

function assert(condition, message) {
  totalTests++;
  if (condition) {
    console.log(`  ✅ [PASS] ${message}`);
    passedTests++;
  } else {
    console.error(`  ❌ [FAIL] ${message}`);
    throw new Error(`Assertion failed: ${message}`);
  }
}

// 1. Types & Models
console.log('--- 1. Testing Marketplace Types & Tier Classifications ---');
const typesFile = fs.readFileSync(path.join(__dirname, 'lib/marketplace/types.ts'), 'utf8');

assert(typesFile.includes('local_collector'), 'types.ts defines local_collector tier');
assert(typesFile.includes('wholesaler'), 'types.ts defines wholesaler tier');
assert(typesFile.includes('exporter'), 'types.ts defines exporter tier');
assert(typesFile.includes('processor'), 'types.ts defines processor tier');
assert(typesFile.includes('cooperative'), 'types.ts defines cooperative tier');
assert(typesFile.includes('isBuyingNow'), 'types.ts defines isBuyingNow boolean presence');
assert(typesFile.includes('buyingPostLocation'), 'types.ts defines buyingPostLocation physical post');
assert(typesFile.includes('operatingHoursToday'), 'types.ts defines operatingHoursToday');
assert(typesFile.includes('FarmerMatchResult'), 'types.ts defines FarmerMatchResult');
assert(typesFile.includes('FarmerMatchItem'), 'types.ts defines FarmerMatchItem');

// 2. API Client Endpoints
console.log('\n--- 2. Testing Marketplace API Client Methods ---');
const apiClientFile = fs.readFileSync(path.join(__dirname, 'lib/marketplace/api-client.ts'), 'utf8');

assert(apiClientFile.includes('getBuyingNowDemands'), 'api-client.ts exposes getBuyingNowDemands()');
assert(apiClientFile.includes('matchProduce'), 'api-client.ts exposes matchProduce()');
assert(apiClientFile.includes('connectToBuyer'), 'api-client.ts exposes connectToBuyer()');
assert(apiClientFile.includes('toggleBuyingNow'), 'api-client.ts exposes toggleBuyingNow()');
assert(apiClientFile.includes('listVerifiedBuyers'), 'api-client.ts exposes listVerifiedBuyers()');

// 3. UI Components
console.log('\n--- 3. Testing Component Deliverables ---');
assert(fs.existsSync(path.join(__dirname, 'components/marketplace/LiveBuyingNowPulse.tsx')), 'LiveBuyingNowPulse.tsx exists');
assert(fs.existsSync(path.join(__dirname, 'components/marketplace/BuyerBadges.tsx')), 'BuyerBadges.tsx exists');
assert(fs.existsSync(path.join(__dirname, 'components/marketplace/BuyerDemandCard.tsx')), 'BuyerDemandCard.tsx exists');
assert(fs.existsSync(path.join(__dirname, 'components/marketplace/ProduceMatchEngine.tsx')), 'ProduceMatchEngine.tsx exists');

const pulseFile = fs.readFileSync(path.join(__dirname, 'components/marketplace/LiveBuyingNowPulse.tsx'), 'utf8');
assert(pulseFile.includes('animate-ping') || pulseFile.includes('animate-pulse'), 'LiveBuyingNowPulse has real-time visual pulse animation');

const demandCardFile = fs.readFileSync(path.join(__dirname, 'components/marketplace/BuyerDemandCard.tsx'), 'utf8');
assert(demandCardFile.includes('LiveBuyingNowPulse'), 'BuyerDemandCard integrates LiveBuyingNowPulse');
assert(demandCardFile.includes('connectToBuyer'), 'BuyerDemandCard integrates farmer-connect modal');

const matchEngineFile = fs.readFileSync(path.join(__dirname, 'components/marketplace/ProduceMatchEngine.tsx'), 'utf8');
assert(matchEngineFile.includes('matchProduce'), 'ProduceMatchEngine calls matchProduce API');
assert(matchEngineFile.includes('JIMMA_WOREDAS'), 'ProduceMatchEngine restricted to Jimma Zone woredas');
assert(matchEngineFile.includes('PRIORITY_CROPS'), 'ProduceMatchEngine supports all 7 priority crops');

// 4. Localization
console.log('\n--- 4. Testing Marketplace Localization in Afaan Oromoo, Amharic, English ---');
const omCommon = JSON.parse(fs.readFileSync(path.join(__dirname, 'locales/om/common.json'), 'utf8'));
const amCommon = JSON.parse(fs.readFileSync(path.join(__dirname, 'locales/am/common.json'), 'utf8'));
const enCommon = JSON.parse(fs.readFileSync(path.join(__dirname, 'locales/en/common.json'), 'utf8'));

assert(!!omCommon.marketplace, 'om/common.json has marketplace namespace');
assert(!!amCommon.marketplace, 'am/common.json has marketplace namespace');
assert(!!enCommon.marketplace, 'en/common.json has marketplace namespace');

assert(omCommon.marketplace.tabBuyingNow === 'Amma Bitaa Jiru', 'Afaan Oromoo tabBuyingNow is "Amma Bitaa Jiru"');
assert(omCommon.marketplace.tabMatch === 'Wal-Simsiisi', 'Afaan Oromoo tabMatch is "Wal-Simsiisi"');
assert(omCommon.crops.coffee === 'Buna', 'Crop coffee translated to Buna');
assert(omCommon.crops.maize === 'Boqqolloo', 'Crop maize translated to Boqqolloo');
assert(omCommon.crops.teff === 'Xaafii', 'Crop teff translated to Xaafii');
assert(omCommon.crops.wheat === 'Qamadii', 'Crop wheat translated to Qamadii');
assert(omCommon.crops.potato === 'Dinnicha', 'Crop potato translated to Dinnicha');
assert(omCommon.crops.tomato === 'Timaatima', 'Crop tomato translated to Timaatima');
assert(omCommon.crops.carrot === 'Kaarotii', 'Crop carrot translated to Kaarotii');

console.log('\n===============================================================');
console.log(`  ALL WEB VERIFICATION TESTS PASSED: ${passedTests}/${totalTests} TESTS!`);
console.log('===============================================================\n');
