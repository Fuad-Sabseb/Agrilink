# AgriLink — Architecture

## Stack (per proposal §10.1 — not changed)
- **Web**: Next.js 14 (App Router), TypeScript, Tailwind CSS
- **API**: NestJS (Node.js/TypeScript), modular per-domain modules
- **Database**: MySQL 8, TypeORM, migration-based schema (no `synchronize: true` beyond local dev)
- **Auth**: JWT (access + refresh), bcrypt password hashing, role guards
- **Geospatial/routing**: pluggable `DistanceProvider` interface — MVP default is a static
  admin-configured distance/rate table; Mapbox/OSM implementation is an extension point
  (Module boundary, not built Day 1)
- **AI assistant, payments, intelligence dashboard**: not built. Extension points only:
  `apps/api/src/modules/_deferred/` documents the intended module boundary and interface
  each would implement, so Modules 5–7 can be added without touching Modules 1–4.

## Monorepo layout
```
agrilink/
  apps/
    api/     NestJS backend
    web/     Next.js frontend
  docs/      requirements, architecture, design system, phase map
  docker-compose.yml   MySQL + api + web for local/prod-like run
  PROGRESS.md
```

## Backend module boundaries (mirrors proposal §7 modules 1:1)
```
src/
  auth/            JWT strategy, guards, register/login
  users/           base User entity + roles (FARMER, BUYER, TRANSPORTER, ADMIN)
  farmers/         Farmer profile + Farm registry + Crop records   (Module 1)
  market-intel/    Market, Crop master data, Price Observation      (Module 2)
  marketplace/     Buyer, Demand Posting, matching, reliability     (Module 3)
  logistics/       Transporter, Vehicle, Transport Request, Shipment (Module 4)
  recommendation/  "Where Should I Sell?" engine                    (Module 8 in proposal)
  transactions/    Transaction ledger tying the workflow together
  notifications/   In-app notifications + SMS/push abstraction
  admin/           Admin CRUD surface across the above
  common/          guards, interceptors, pipes, decorators
  config/          env validation, typed config
  database/        TypeORM data source + migrations
```

## Why these decisions
- **MySQL over swapping to Postgres/Mongo**: proposal specifies MySQL explicitly for
  relational integrity on the transaction chain (§10.1) — not changed without cause, per rule 7.
- **Money as integer minor units (ETB cents)**: avoids floating-point drift in
  Gross/Net Revenue calculations that the recommendation engine and transactions both depend on.
- **Static distance/rate table before live routing API**: the proposal itself describes the
  transport-cost layer as starting from "rule-of-thumb ETB/km/ton by route type" (§8) — a live
  Mapbox integration is real, but not required to ship an explainable, correct MVP, and adding
  it later is additive (swap the `DistanceProvider` implementation) rather than a rewrite.
- **Explainability as a first-class API contract**: the recommendation endpoint returns the
  full breakdown (price source + date, gross, transport cost, net, rank) — not just a winner —
  because proposal rule 11 requires the engine to be explainable, not a black box.

## Environments
- `.env` per app (see `.env.example`), validated at boot (`class-validator`-backed config
  schema) — the API refuses to start with missing/invalid required config rather than failing
  silently later (Definition of Done: no error leakage, fail fast).
