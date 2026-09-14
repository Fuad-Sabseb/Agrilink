# Requirements Extracted from AgriLink Proposal

## Product vision
Decision-intelligence platform for smallholder farmers in Jimma Zone, Oromia — not a listings
marketplace. Core output: where to sell a specific harvest for the highest **net** revenue after
transport cost, delivered Afaan-Oromoo-first. (§4.1, §4.3)

## Problem statement
Information asymmetry across distant markets, thin extension coverage, fragmented buyer
access via middlemen, opaque/undigitized logistics and informal transit fees, and
language/interface exclusion for Afaan Oromoo speakers. (§2.2)

## Target users (§6)
- **Farmers** (primary): smallholder producers of maize, teff, wheat, potato, coffee; mixed
  literacy; feature phone → entry Android. Core need: "where should I sell, and to whom?"
- **Buyers**: wholesalers, processors, retailers, cooperatives, exporters, restaurants.
- **Transporters**: truck/pickup owner-operators.
- **Institutional**: cooperatives/unions, Jimma University/Bureau of Agriculture, ATI/ECX/OpenAgriNet, NGOs/donors — not app users in MVP, but architecture should not preclude future integration (§10.5).

## MVP modules (in scope) — §7.1–7.4, §8
1. **Farmer Profile & Farm Registry** — registration (name, phone/ID, location, cooperative
   membership); farm records (land size, GPS, crops, harvest periods, production capacity);
   transaction history (future creditworthiness signal).
2. **Market Intelligence Engine** — current/historical prices by crop, market, quality grade;
   trend visualization + simple forecasting; cross-market comparison feeding "Where Should I Sell?".
3. **Buyer Marketplace** — demand posting (crop, quality, quantity, location, price offered);
   search/matching; in-app negotiation/agreement flow; buyer verification; **multi-tier buyer
   visibility** (local collector-merchant vs. city merchant); **live "buying now" status**;
   **merchant reliability signals** (response time, no-show history).
4. **AgriLogistics** — transporter registry (vehicle type, capacity, coverage area); transport
   request creation + route/price matching; shipment status (REQUESTED → CONFIRMED →
   IN_TRANSIT → DELIVERED); **transit fee transparency** (incl. informal/checkpoint fees);
   **verified collector role** (legitimate registration with disclosed fee).
5. **"Where Should I Sell?" recommendation** (§8, flagship): for each candidate market,
   `Gross Revenue = Price/kg × Quantity`; `Est. Total Cost = Transport + configured
   logistics/transit costs`; `Est. Net Revenue = Gross − Est. Total Cost`. Rank markets by net
   revenue. Must show the math (explainable, not a black box) — worked example: 5,000 kg
   potatoes, Jimma/Nekemte/Addis Ababa, Nekemte wins despite lower headline price (§8).

## Explicitly deferred (NOT MVP) — build extension points only
- **Module 5 — AgriAI**: Afaan Oromoo conversational assistant, farming calendar/agronomic
  advice, image-based crop disease ID. (§7.5)
- **Module 6 — Financial Services**: payments, savings, insurance, credit scoring, input
  financing — needs PSP licensing/bank partnerships, explicitly out of MVP. (§7.6)
- **Module 7 — Agricultural Intelligence Dashboard**: aggregated view for
  cooperatives/govt/NGOs; depends on Modules 1–3 data density. (§7.7)

## Localization & connectivity (§2.2, §10.4)
- Afaan Oromoo first; Amharic and English also supported.
- Tiered access: full app (smartphone/data) → lightweight low-bandwidth web view →
  SMS/USSD/IVR for feature phones. Build an SMS/USSD **abstraction layer** now; do not
  build the telco integration itself in MVP unless trivial.
- Offline-tolerant mobile: cache recent prices/farm records, background sync.

## Security requirements (implicit + §13 risk table + general SaaS baseline)
- Backend-enforced authorization (never client-only).
- Password hashing, JWT/session strategy, input validation, rate limiting, CORS, secrets
  management, no error leakage, no privilege escalation, guarded API surface.
- AI/data-integrity constraint: never fabricate market prices; all price data must be
  attributable (source + observation date) and its freshness must be visible in the UI
  (verified / estimated / stale / demo).

## Technical architecture (§10.1–10.3)
| Layer | Choice |
|---|---|
| Web | Next.js (React) |
| Mobile | React Native/Expo (post-MVP; MVP ships responsive web first) |
| Backend | NestJS (Node.js), modular services aligned to the 7 modules |
| Database | MySQL (relational integrity for transactions; geospatial queries for markets/routing) |
| Maps/Geospatial | Mapbox or OpenStreetMap for distance/route estimation |
| AI/Conversational | LLM API + curated knowledge base — **deferred module**, extension point only |
| Payments | Licensed Ethiopian PSPs — **deferred module** |
| Notifications | SMS gateway + push; SMS as feature-phone fallback |
| Infra | Cloud hosting, CDN edge, low-bandwidth optimization |

### Core data model (§10.3)
`Farmer → Farm(s) → Crop Records` · `Market → Price Observation` · `Buyer → Demand Posting`
· `Transport Provider → Transport Request → Shipment` · `Transaction` (links Farmer, Buyer,
Market, optional Shipment, final price, status).

## Rollout strategy (§9)
Stage 1: Jimma Zone only — crops: maize, teff, wheat, potato, coffee (tomato/carrot flagged
provisional pending field validation of perishables). Markets: Jimma town + 2–4 secondary
markets (e.g. Nekemte, Agaro — placeholders, confirm via admin-managed market data, not
hardcoded). Stage 2 (Oromia) and Stage 3 (National) are out of scope for this build.

## KPIs (§14) — informs what the system must be able to report, not what to build as features
Registered farmers/buyers/transporters, completed transactions, net-revenue uplift, WSIS
queries/user/month, SMS/USSD usage share, trust survey score, price-data freshness (≤7 days
target), spoilage reduction, merchant reliability rate, verified-collector adoption rate. These
map to fields the data model must capture (timestamps, status history, source), not a
dashboard we build in MVP (that's Module 7, deferred).

## Explicit ambiguities → assumptions taken
1. **"Existing repository/codebase"** referenced in the mega-prompt: none was uploaded.
   Assumption: this is a greenfield build; PROGRESS.md documents that plainly rather than
   fabricating a prior audit.
2. **Currency**: ETB, 2 decimal places, stored as integer minor units (cents) to avoid float
   errors in financial calculations.
3. **"Where Should I Sell?" transit/logistics cost**: proposal describes it as
   rule-of-thumb ETB/km/ton by route type initially (§8, "Underlying requirements"). Modeled
   as an admin-configurable `TransportCostRule` (origin zone, destination market, rate basis)
   rather than a live routing API in MVP, with Mapbox/OSM distance lookup as an extension
   point — avoids a hard external dependency blocking the recommendation engine.
4. **Perishable crops (tomato/avocado)**: proposal itself flags these as provisional (§9).
   Assumption: ship MVP with the five storable crops from §6.1/Table 1 (maize, teff, wheat,
   potato, coffee); model `Crop.perishability` as a field now so adding tomato/avocado later
   is a data change, not a schema change.
5. **Multi-tier buyer / live "buying now" / reliability signals** (§7.3): real functional
   requirements, not decoration — included in the Buyer Marketplace phase (Day 11–12), not
   deferred, since the proposal states them as MVP marketplace behavior.
