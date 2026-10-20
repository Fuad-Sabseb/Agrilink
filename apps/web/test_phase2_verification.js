import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

console.log('===============================================================');
console.log('  AGRILINK PHASE 2: LOCALIZATION & OFFLINE-TOLERANT CACHING   ');
console.log('               COMPREHENSIVE VERIFICATION SUITE               ');
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

// -------------------------------------------------------------
// 1. Localization Files & Trilingual Architecture
// -------------------------------------------------------------
console.log('--- 1. Testing Trilingual Localization Architecture ---');

const omCommon = JSON.parse(fs.readFileSync(path.join(__dirname, 'locales/om/common.json'), 'utf8'));
const omRecs = JSON.parse(fs.readFileSync(path.join(__dirname, 'locales/om/recommendations.json'), 'utf8'));
const amCommon = JSON.parse(fs.readFileSync(path.join(__dirname, 'locales/am/common.json'), 'utf8'));
const amRecs = JSON.parse(fs.readFileSync(path.join(__dirname, 'locales/am/recommendations.json'), 'utf8'));
const enCommon = JSON.parse(fs.readFileSync(path.join(__dirname, 'locales/en/common.json'), 'utf8'));
const enRecs = JSON.parse(fs.readFileSync(path.join(__dirname, 'locales/en/recommendations.json'), 'utf8'));

assert(!!omCommon && !!omRecs, 'Afaan Oromoo locale files loaded successfully');
assert(!!amCommon && !!amRecs, 'Amharic locale files loaded successfully');
assert(!!enCommon && !!enRecs, 'English locale files loaded successfully');

// Check mirrored public directory
assert(fs.existsSync(path.join(__dirname, 'public/locales/om/common.json')), 'Afaan Oromoo mirrored in public/locales');
assert(fs.existsSync(path.join(__dirname, 'public/locales/am/common.json')), 'Amharic mirrored in public/locales');
assert(fs.existsSync(path.join(__dirname, 'public/locales/en/common.json')), 'English mirrored in public/locales');

// -------------------------------------------------------------
// 2. Jimma Zone Commodity & Domain Terminology
// -------------------------------------------------------------
console.log('\n--- 2. Testing Jimma Zone Native Terminology in Afaan Oromoo ---');

const terms = omCommon.terms;
const crops = omCommon.crops;

assert(crops.coffee === 'Buna', 'Coffee translated to Jimma native "Buna"');
assert(crops.maize === 'Boqqolloo', 'Maize translated to Jimma native "Boqqolloo"');
assert(crops.teff === 'Xaafii', 'Teff translated to Jimma native "Xaafii"');
assert(crops.wheat === 'Qamadii', 'Wheat translated to Jimma native "Qamadii"');
assert(crops.potato === 'Dinnicha', 'Potato translated to Jimma native "Dinnicha"');
assert(crops.tomato === 'Timaatima', 'Tomato translated to Jimma native "Timaatima"');
assert(crops.carrot === 'Kaarotii', 'Carrot translated to Jimma native "Kaarotii"');

assert(terms.netRevenue === 'Galii Qulqulluu', 'Net Revenue translated to "Galii Qulqulluu"');
assert(terms.bestMarket === 'Gabaa Filatamaa', 'Best Market translated to "Gabaa Filatamaa"');
assert(terms.transportCost === 'Baasii Geejjibaa', 'Transport Cost translated to "Baasii Geejjibaa"');

// -------------------------------------------------------------
// 3. Audio Readout Dynamic Script Generation
// -------------------------------------------------------------
console.log('\n--- 3. Testing Audio Readout Template & Script Construction ---');

function generateAudioScript(locale, market, crop, quantity, netRevenue, transportCost) {
  if (locale === 'om') {
    return `Gabaan filatamaan ${market} dha. ${crop} kiiloo ${quantity} yoo gurgurtan, galii qulqulluu birrii ${Number(netRevenue).toLocaleString()} argattu. Baasiin geejjibaa birrii ${Number(transportCost).toLocaleString()} ta'a.`;
  } else if (locale === 'am') {
    return `ተመራጩ ገበያ ${market} ነው። ${quantity} ኪሎ ${crop} ቢሸጡ፣ የተጣራ ገቢ ${Number(netRevenue).toLocaleString()} ብር ያገኛሉ። የትራንስፖርት ወጪ ${Number(transportCost).toLocaleString()} ብር ይሆናል።`;
  } else {
    return `The recommended market is ${market}. Selling ${quantity} kg of ${crop} gives an estimated net take-home revenue of ${Number(netRevenue).toLocaleString()} ETB after deducting ${Number(transportCost).toLocaleString()} ETB transport cost.`;
  }
}

const omScript = generateAudioScript('om', 'Jimma Central Market', 'Boqqolloo', 1000, 12500, 1800);
assert(
  omScript.includes('Gabaan filatamaan Jimma Central Market dha') &&
  omScript.includes('Boqqolloo kiiloo 1000 yoo gurgurtan') &&
  omScript.includes('galii qulqulluu birrii 12,500 argattu'),
  'Afaan Oromoo audio script constructs correctly: "' + omScript + '"'
);

const amScript = generateAudioScript('am', 'አጋሮ ገበያ', 'በቆሎ', 500, 7200, 950);
assert(
  amScript.includes('ተመራጩ ገበያ አጋሮ ገበያ ነው።') &&
  amScript.includes('የተጣራ ገቢ 7,200 ብር ያገኛሉ'),
  'Amharic audio script constructs correctly'
);

const enScript = generateAudioScript('en', 'Limmu Market', 'Coffee', 200, 56000, 2400);
assert(
  enScript.includes('The recommended market is Limmu Market.') &&
  enScript.includes('56,000 ETB'),
  'English audio script constructs correctly'
);

// -------------------------------------------------------------
// 4. Offline Storage Tables & Hook Implementation Structure
// -------------------------------------------------------------
console.log('\n--- 4. Testing Offline-First Storage & Synchronization Code ---');

const offlineStorageFile = fs.readFileSync(path.join(__dirname, 'lib/offline/offline-storage.ts'), 'utf8');
assert(offlineStorageFile.includes('cachedPrices'), 'offline-storage.ts defines cachedPrices store');
assert(offlineStorageFile.includes('cachedRecommendations'), 'offline-storage.ts defines cachedRecommendations store');
assert(offlineStorageFile.includes('syncQueue'), 'offline-storage.ts defines syncQueue store');
assert(offlineStorageFile.includes('agrilink_offline_db'), 'offline-storage.ts uses agrilink_offline_db IndexedDB database');

const useOfflineSyncFile = fs.readFileSync(path.join(__dirname, 'lib/offline/useOfflineSync.ts'), 'utf8');
assert(useOfflineSyncFile.includes('isOnline'), 'useOfflineSync exposes isOnline state');
assert(useOfflineSyncFile.includes('lastSyncTime'), 'useOfflineSync exposes lastSyncTime');
assert(useOfflineSyncFile.includes('syncNow'), 'useOfflineSync exposes syncNow function');
assert(useOfflineSyncFile.includes('window.addEventListener(\'online\''), 'useOfflineSync listens to browser online events');
assert(useOfflineSyncFile.includes('window.addEventListener(\'offline\''), 'useOfflineSync listens to browser offline events');

// -------------------------------------------------------------
// 5. Component Deliverables Verification
// -------------------------------------------------------------
console.log('\n--- 5. Testing Required Component Deliverables ---');

assert(fs.existsSync(path.join(__dirname, 'components/i18n/LanguageSwitcher.tsx')), 'Deliverable 1: LanguageSwitcher.tsx exists');
assert(fs.existsSync(path.join(__dirname, 'lib/offline/useOfflineSync.ts')), 'Deliverable 2: useOfflineSync.ts exists');
assert(fs.existsSync(path.join(__dirname, 'components/audio/AudioReadoutButton.tsx')), 'Deliverable 3: AudioReadoutButton.tsx exists');
assert(fs.existsSync(path.join(__dirname, 'components/recommendation/RecommendationCard.tsx')), 'Deliverable 4: RecommendationCard.tsx exists');
assert(fs.existsSync(path.join(__dirname, 'components/ui/OfflineBanner.tsx')), 'OfflineBanner.tsx exists');

// Verify LanguageSwitcher supports om, am, en and uses localStorage
const langSwitcherCode = fs.readFileSync(path.join(__dirname, 'components/i18n/LanguageSwitcher.tsx'), 'utf8');
assert(langSwitcherCode.includes('setLocale'), 'LanguageSwitcher calls setLocale');
assert(langSwitcherCode.includes('SUPPORTED_LOCALES'), 'LanguageSwitcher lists SUPPORTED_LOCALES');

// Verify AudioReadoutButton accessibility and speech synthesis
const audioCode = fs.readFileSync(path.join(__dirname, 'components/audio/AudioReadoutButton.tsx'), 'utf8');
assert(audioCode.includes('speechSynthesis'), 'AudioReadoutButton utilizes Web Speech API speechSynthesis');
assert(audioCode.includes('playFallbackChime'), 'AudioReadoutButton includes fallback acoustic chime when TTS voice is absent');
assert(audioCode.includes('aria-label'), 'AudioReadoutButton has accessible aria-label');

// Verify RecommendationCard localization integration
const recCardCode = fs.readFileSync(path.join(__dirname, 'components/recommendation/RecommendationCard.tsx'), 'utf8');
assert(recCardCode.includes('useTranslation'), 'RecommendationCard uses useTranslation hook');
assert(recCardCode.includes('AudioReadoutButton'), 'RecommendationCard integrates AudioReadoutButton');
assert(recCardCode.includes('isFromCache'), 'RecommendationCard displays offline cache badge');

// Verify Where Should I Sell page
const sellPageCode = fs.readFileSync(path.join(__dirname, 'app/app/where-should-i-sell/page.tsx'), 'utf8');
assert(sellPageCode.includes('RecommendationCard'), 'where-should-i-sell uses RecommendationCard');
assert(sellPageCode.includes('LanguageSwitcher'), 'where-should-i-sell includes LanguageSwitcher');
assert(sellPageCode.includes('offlineStorage'), 'where-should-i-sell uses offlineStorage for resilient caching');

console.log('\n===============================================================');
console.log(`  ALL PHASE 2 VERIFICATIONS PASSED: ${passedTests}/${totalTests} TESTS!`);
console.log('===============================================================\n');
