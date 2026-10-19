# AgriLink Design System
Visual/UX language adapted from LaoAgroLink reference screens. Zero LaoAgroLink content,
copy, geography, currency, or business logic is reused — see checklist at bottom.

## What was extracted from LaoAgroLink (visual/UX pattern only)
- Deep forest-green background with a subtle photographic/textured overlay
- Rounded, semi-translucent "glass" cards floating over the background
- Pill-shaped inputs and buttons; high-contrast single primary CTA per screen
- Step-dot progress indicator for multi-step registration
- Green circular success/checkmark badge for completed steps
- Bottom-anchored primary action button pattern on mobile
- Language switcher pinned top-left; theme toggle top-right

## AgriLink tokens (original, Ethiopia/Jimma-appropriate)
- **Primary green** `#1B5E3A` (deep agricultural green — canopy, not LaoAgroLink's teal-green)
- **Primary green, dark bg** `#0E2A1C`
- **Accent gold** `#C99A2E` (Ethiopian coffee/harvest gold, warmer/more amber than LaoAgroLink's
  mustard, used for the single primary CTA — "sell" actions, confirm, recommend)
- **Success** `#2E9E5B` · **Warning/Stale-data** `#D97706` · **Error** `#C0392B`
- **Neutral surface (card)** `rgba(255,255,255,0.06)` over dark bg, `#FFFFFF` on light bg
- **Typography**: system font stack + Noto Sans Ethiopic fallback for Amharic glyphs, Noto
  Sans for Afaan Oromoo (Latin script, uses ë/ç-type extended Latin) — never bake text into
  images (proposal rule: language must be able to expand/translate freely)
- **Radius**: cards 20px, inputs/buttons full-pill (999px) on primary actions, 12px on
  secondary controls
- **Data-freshness badges** (AgriLink-specific, no LaoAgroLink equivalent): `VERIFIED` (green),
  `ESTIMATED` (gold outline), `STALE` (amber solid), `DEMO DATA` (grey, always visible — proposal
  rule 5)

## Content replacements (Lao → AgriLink) — content rule check
| LaoAgroLink | AgriLink |
|---|---|
| Ministry of Agriculture and Environment (Laos) | — removed; AgriLink is an independent platform, not a ministry system |
| Lao PDR · MAF Digital Platform | Jimma Zone · Oromia, Ethiopia |
| +856 phone prefix | +251 phone prefix |
| Lao province/district/village hierarchy | Ethiopian Zone → Woreda → Kebele hierarchy |
| Lao script labels | Afaan Oromoo (default) / Amharic / English, selectable |
| Generic crop icons | Maize, Teff, Wheat, Potato, Coffee (proposal Stage-1 crop list) |
| Kip currency | ETB |

## Design-consistency self-test (proposal §18) — applied to every screen built
Same design family as reference (Y/N) · Matches AgriLink proposal function (Y/N) · Ethiopia-
appropriate content (Y/N) · Jimma/Oromia geography (Y/N) · Ethiopian ag terminology (Y/N) ·
ETB currency (Y/N) · Afaan-Oromoo-ready layout (Y/N) · Mobile-first (Y/N) · Correct workflow
(Y/N) · Any accidental Lao content (must be N). Recorded per screen in that screen's PR/commit,
not duplicated here.
