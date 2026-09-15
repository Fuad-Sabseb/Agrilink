# AgriLink — Build Progress

Source of truth: `AgriLink_Project.pdf` (proposal). UI/UX reference only: LaoAgroLink screenshots (18 images, no code/logic reused).

Repository status at Day 1: **greenfield**. No prior AgriLink codebase existed in the uploaded materials — this log starts from zero, not from an audit of pre-existing code.

Start: 2026-09-12 (executed across this conversation, phase by phase, not unattended calendar days — see chat for the caveat given to the user).

---

## DAY 1

### PHASE 01 — Project Audit, Proposal Analysis & Architecture
**STATUS:** COMPLETE

**Completed:**
- Read full AgriLink proposal PDF; extracted requirements into `docs/requirements-extract.md`.
- Reviewed 18 LaoAgroLink screenshots; extracted design language into `docs/design-system.md` (no business logic/content reused, per instruction).
- Confirmed: no existing repository — greenfield build.
- Confirmed architecture: Next.js (web) + NestJS (API) + MySQL (TypeORM), per proposal §10.1. Documented in `docs/architecture.md`.
- Confirmed MVP scope boundary: Modules 1–4 + "Where Should I Sell?" only (proposal §7.1–7.4, §8). Modules 5 (AgriAI), 6 (Financial Services), 7 (Intelligence Dashboard) are deferred extension points, not Day-1 work.
- Established monorepo skeleton (`apps/api`, `apps/web`, `docs/`).

**Files changed:** `PROGRESS.md`, `docs/requirements-extract.md`, `docs/architecture.md`, `docs/design-system.md`, `docs/phase-map.md`

**Known issues:** None blocking.
**Next phase:** 02 — Backend & Database Foundation

---

### PHASE 02 — Backend & Database Foundation
**STATUS:** COMPLETE

**Completed:**
- NestJS backend structure: `auth/users/farmers/market-intel/marketplace/logistics/
  recommendation/transactions/notifications/admin` module boundaries documented in
  `docs/architecture.md` (not stubbed empty — added as each is actually built, starting Day 2).
- TypeORM + MySQL connection wired via `ConfigService` (`database/database.module.ts`) and a
  standalone CLI `DataSource` for migrations (`database/data-source.ts`).
- Environment config validated at boot with `class-validator` — process refuses to start on
  missing/invalid env (`config/env.validation.ts`).
- Security baseline in `main.ts`: `helmet()`, scoped CORS, global `ValidationPipe`
  (whitelist + forbid unknown fields), global API prefix `/api/v1`, global rate limiting via
  `ThrottlerModule` (60 req/min default, hardened per-route in Phase 35).
- `GET /api/v1/health` reports real DB connectivity, not just process liveness.
- Next.js 14 (App Router) + Tailwind scaffolded for `apps/web`, with AgriLink design tokens
  (from `docs/design-system.md`) wired into `tailwind.config.ts`.
- `docker-compose.yml` + Dockerfiles for `api`/`web` + MySQL 8 service, for running the whole
  stack outside this sandbox.
- Dev scripts: root `package.json` workspaces (`dev:api`, `dev:web`, `build:*`, `test:api`,
  `lint:api`, `typecheck:api`).

**Files changed:** `package.json` (root), `apps/api/**` (new), `apps/web/**` (new, via
`create-next-app`), `docker-compose.yml`, `apps/api/Dockerfile`, `apps/web/Dockerfile`,
`.gitignore`, `README.md`

**Database changes:** none yet (no entities defined — first entities are `User`/`Role` in
Phase 03).

**API changes:** `GET /api/v1/health`.

**Frontend changes:** branded placeholder home page only (`app/page.tsx`) — real screens start
Phase 05.

**Tests:** none yet (no business logic to test at foundation stage); smoke-tested manually
end-to-end instead (see below).

**Lint:** PASS (`npm run lint:api` — 0 errors/warnings).
**Typecheck:** PASS (`npm run typecheck:api`).
**Build:** PASS — `apps/api` (`tsc`) and `apps/web` (`next build`) both compile clean.

**Manual verification performed this session:** installed MariaDB locally, created the
`agrilink` database/user matching `.env.example`, built and booted the compiled API against
it, and confirmed `GET /api/v1/health` → `{"status":"ok","database":"up"}`. This proves the
DB wiring works end-to-end, not just that it compiles. (Sandbox has no persistent background
processes between tool calls, so this was run as one continuous session — not a standing dev
server; `docker compose up` is the supported way to run it going forward.)

**Known issues:**
- No `.dockerignore` yet for `api`/`web` (node_modules will bloat the Docker build context) —
  will add in Phase 38 (Production Infrastructure) when Docker images are hardened for real,
  not blocking now.
- `apps/web`'s own generated ESLint/TS config from `create-next-app` hasn't been merged with
  a repo-wide lint standard yet — acceptable for now, revisited in Phase 36 (Automated QA).

**Next phase:** 03 — Authentication Database & Security Foundation (User entity, roles,
password hashing, first real migration).

---

## DAY 2

### PHASE 03 — Authentication Database & Security Foundation
**STATUS:** COMPLETE

**Completed:**
- `User` entity (`users/entities/user.entity.ts`): phone-first identity (proposal §7.1 —
  "phone/ID"), optional email, `role` enum (farmer/buyer/transporter/admin), preferred
  language enum (Afaan Oromoo default, Amharic, English), `isActive` flag. `passwordHash` is
  `select: false` (never returned by a normal query) and `@Exclude()` (never serialized even if
  it were fetched) — two independent layers.
- `RefreshToken` entity: stores a SHA-256 hash of the token, never the token itself; carries
  `expiresAt`/`revokedAt` for rotation and per-session logout.
- `PasswordService`: bcrypt, cost factor 12 (above the library default of 10, given this
  system will eventually hold financial/transaction data).
- Base `BaseEntity` (uuid id + timestamps) that every future domain entity extends.
- First real TypeORM migration (`InitAuth`), generated from the entities against a live MySQL
  instance and executed — `users` and `refresh_tokens` tables confirmed via `DESCRIBE`, not
  assumed from the migration file alone.

**Files changed:** `common/entities/base.entity.ts`, `users/entities/user.entity.ts`,
`users/entities/user-role.enum.ts`, `auth/entities/refresh-token.entity.ts`,
`database/migrations/1789217942000-InitAuth.ts`, `apps/api/package.json` (migration scripts)

**Database changes:** `users`, `refresh_tokens` tables created (see migration for exact DDL).

**Known issues:** none.

---

### PHASE 04 — Register & Login Backend
**STATUS:** COMPLETE

**Completed:**
- `AuthService`: register, login, refresh (with rotation), logout.
- `AuthController`: `POST /auth/register`, `POST /auth/login` (tighter throttle: 10/min vs.
  the app-wide 60/min, since login is the standard credential-stuffing target), `POST
  /auth/refresh`, `POST /auth/logout`.
- `JwtStrategy` + `JwtAuthGuard`: validates the access token AND re-checks `isActive` against
  the DB on every request — a deactivated user's existing tokens stop working immediately,
  not just at their next login.
- `RolesGuard` + `@Roles()` decorator, applied globally (no-op unless a route opts in via
  `@Roles(...)`) so no future protected route can forget it.
- `RegisterDto`/`LoginDto`: Ethiopian phone format enforced (`+251[7|9]XXXXXXXX`) — rejects
  the Lao `+856` format and anything else malformed, at the validation boundary.
- Server-side rule: public registration cannot set `role: admin` (`ForbiddenException`),
  independent of whatever the frontend does or doesn't show — proposal rule 10 (authorization
  must not depend on frontend behavior).
- Refresh-token rotation with reuse detection: every refresh revokes the token used and
  issues a new one, so a replayed/stolen refresh token works exactly once.
- Login returns an identical generic error for "no such phone number" and "wrong password" —
  prevents account enumeration via the login endpoint.

**A real bug found and fixed during testing (not by inspection):** the first version signed
JWTs from `{ sub, role }` only. Registering and then immediately logging in (same second)
produced byte-identical tokens — same payload, same signature — which collided on
`refresh_tokens.token_hash`'s unique index and surfaced as an unhandled 500 on login. Fixed by
adding a random `jti` per token (`auth/jwt-payload.interface.ts`, `auth.service.ts`). Re-ran
the exact failing sequence afterward to confirm the fix, rather than trusting the type-level
fix alone.

**Files changed:** `auth/auth.service.ts`, `auth/auth.controller.ts`, `auth/auth.module.ts`,
`auth/password.service.ts`, `auth/refresh-tokens.service.ts`, `auth/jwt-payload.interface.ts`,
`auth/strategies/jwt.strategy.ts`, `auth/guards/jwt-auth.guard.ts`, `auth/guards/roles.guard.ts`,
`auth/decorators/roles.decorator.ts`, `auth/decorators/current-user.decorator.ts`,
`auth/dto/register.dto.ts`, `auth/dto/login.dto.ts`, `auth/dto/refresh-token.dto.ts`,
`users/users.module.ts`, `users/users.service.ts`, `app.module.ts` (wired `UsersModule`,
`AuthModule`, global `RolesGuard`), `apps/api/.eslintrc.json` (scoped `no-explicit-any`
exception to `*.spec.ts` only — test mocks legitimately need it; production code does not and
still has the rule enforced)

**API changes:** `POST /api/v1/auth/register`, `POST /api/v1/auth/login`,
`POST /api/v1/auth/refresh`, `POST /api/v1/auth/logout`.

**Frontend changes:** none (UI is Phase 05).

**Tests:** 10 new unit tests (`auth/__tests__/auth.service.spec.ts`) — all passing:
- register: blocks admin self-registration without a DB call, blocks duplicate phone,
  confirms plaintext password never reaches the persistence layer, confirms two distinct
  `jti`s are generated per token pair.
- login: same error message for unknown-phone vs. wrong-password (enumeration check),
  distinct message for deactivated accounts, success path.
- refresh: rejects bad signature/expiry, rejects an already-revoked token, confirms rotation
  (old token revoked, new pair issued) on success.

**Lint:** PASS (0 errors/warnings, including the test file, after scoping the `any` rule).
**Typecheck:** PASS.
**Build:** PASS.

**Manual end-to-end verification (against live MariaDB, this session):** ran the full flow —
register → duplicate-phone rejection (409) → admin-role rejection (403) → immediate login in
the same second as registration (200, the exact scenario that previously 500'd) → wrong
password (401) → refresh (200) → reuse of the rotated-out refresh token (401). All 7
assertions passed; grepped the server log for unexpected errors — none found (only the
expected, handled `ConflictException`/`ForbiddenException`/`Unauthorized` entries).

**Known issues:**
- `.env` JWT secrets are still the placeholder values from `.env.example` — fine for this
  sandbox/dev run, but must be replaced with real generated secrets (`openssl rand -base64
  48`) before any shared or deployed environment. Flagging now so it isn't forgotten by
  Phase 35 (Security Hardening).
- No integration/e2e test suite yet (only unit tests with mocked dependencies) — proposal's
  Definition of Done gets a proper e2e pass in Phase 36 (Automated QA); manual curl testing
  substitutes for it at this stage.
- Rate limiting on `/auth/login` (10/min) is per-IP via the default Throttler storage
  (in-memory) — fine for a single-instance dev/pilot deployment, will need a shared store
  (e.g. Redis) if the API ever runs multi-instance; noted for Phase 37/38.

**Next phase:** 05 — Login/Register UI (LaoAgroLink-inspired, AgriLink content).

---

## DAY 3

### PHASE 05 — Login/Register UI
**STATUS:** COMPLETE

**Completed:**
- Design primitives (`components/ui/`): `Button` (primary/secondary/ghost, pill shape, loading
  spinner state), `Input` (pill, inline error, prefix support for `+251`), `Card` (rounded,
  translucent), `Alert` (error/success banner), `StepDots` (LaoAgroLink-style progress dots).
- `RoleOption` (`components/auth/`): selectable account-type card for registration step 1.
- `/login`: phone + password, client-side validation (Ethiopian phone format, password
  length), inline field errors, form-level error banner, loading state on submit, link to
  register.
- `/register`: 3-step wizard — Step 1 account type (Farmer/Buyer/Transporter only; Admin is
  not offered, matching the backend's server-side block on admin self-registration), Step 2
  personal info (name, phone, password + confirm, preferred language), Step 3 review before
  submit. Deliberately does NOT collect farm/location fields yet — those belong to Phases
  07–08 and the form only asks for data the backend actually stores right now (per "no fake
  buttons/fields" instruction).
- One shared theme only (no light/dark toggle) — documented in `globals.css` why: LaoAgroLink's
  reference has a toggle, but building one with no second theme behind it would be a decorative
  control that does nothing.

**Files changed:** `components/ui/{Button,Input,Card,Alert,StepDots}.tsx`,
`components/auth/RoleOption.tsx`, `app/(auth)/login/page.tsx`, `app/(auth)/register/page.tsx`,
`app/globals.css`

**Lint:** PASS (`next lint` — 0 warnings/errors).
**Build:** PASS — all 4 routes (`/`, `/login`, `/register`, `/app`) compile and prerender.

---

### PHASE 06 — Authentication Integration
**STATUS:** COMPLETE

**Completed:**
- `lib/auth/api-client.ts`: typed fetch client. `authRequest()` attaches the access token and,
  on a 401, performs exactly one silent refresh-and-retry before giving up — a protected call
  made right as the access token expires recovers transparently instead of erroring.
- `lib/auth/AuthContext.tsx`: session state. On mount, trades a stored refresh token for a
  fresh pair and calls `/users/me` to hydrate `user` — this is what makes a page reload keep
  you logged in (session persistence), since the access token itself never survives a reload
  (kept in memory only, by design — see `access-token-holder.ts`).
- `components/auth/RequireAuth.tsx`: route guard — shows a loading state during the initial
  session check, redirects to `/login` if unauthenticated, supports an `allowRoles` prop for
  role-based routing. Explicitly documented as a UX guard only: the real authorization
  boundary is the API's `JwtAuthGuard`/`RolesGuard`, which this component cannot bypass or
  substitute for (proposal rule 10).
- `/app`: real authenticated home page — shows the actual logged-in user's name, phone, role,
  preferred language, and account status from `/users/me`, plus an honest per-role list of
  what's coming in later phases (explicitly labeled as not-yet-built, not dressed up as
  working buttons).
- Landing page (`/`) now redirects an already-authenticated visitor straight to `/app`, and
  shows real Login/Register CTAs otherwise.
- Backend: new `GET /users/me` (JWT-protected) for session hydration, and a global
  `ClassSerializerInterceptor` added in `main.ts` as a second, independent layer against ever
  serializing `passwordHash` (the first layer is `select: false` on the column).

**A real integration bug found and fixed via testing, not inspection:** I wrote a
contract-check script that replays the frontend's exact API calls against the live backend and
diffs the JSON shape against the frontend's TypeScript types. It caught that `register` and
`login` returned a smaller user object (`id`, `fullName`, `phoneNumber`, `role` only) than
`/users/me` returned (`+email`, `preferredLanguage`, `isActive`, `createdAt`) — but the
frontend stores whichever one it last received as the single `AuthUser` shape. Concretely,
this meant a brand-new user would see their own account rendered as "Deactivated" (undefined
`isActive` is falsy) and a blank preferred-language field immediately after registering, until
the next silent refresh happened to re-hydrate via `/users/me`. Fixed by extracting one shared
`toPublicUser()` mapper (`users/user.mapper.ts`) used by `register`, `login`, and `/users/me`
alike, so the three can't drift apart again. Re-ran the contract check afterward to confirm —
it now passes with all three endpoints returning an identical shape for the same user.

**Files changed:** `lib/auth/{types,token-storage,access-token-holder,api-client,AuthContext}.ts(x)`,
`components/auth/RequireAuth.tsx`, `app/layout.tsx`, `app/page.tsx`, `app/app/page.tsx`,
`apps/web/.env.local.example`; backend: `users/user.mapper.ts` (new), `users/users.controller.ts`
(new), `users/users.module.ts`, `auth/auth.service.ts` (now uses the shared mapper), `main.ts`
(`ClassSerializerInterceptor`)

**Database changes:** none.

**API changes:** `GET /api/v1/users/me` (new, JWT-protected). `register`/`login` response
shape for `user` changed from a 4-field subset to the full `PublicUser` shape (additive from
the frontend's point of view, but worth noting as a response-shape change).

**Frontend changes:** `/`, `/login`, `/register`, `/app` — see Phase 05 above for UI, this
phase for the data/session wiring behind them.

**Tests:** no new automated tests this phase (no new pure business logic on the backend beyond
the mapper, which is exercised indirectly by the existing `AuthService` unit tests still
passing against its output). Verification for this phase was:
1. Full backend re-verification after the mapper fix: typecheck, lint, all 10 existing unit
   tests, build — all PASS.
2. Frontend: `next lint` and `next build` — both PASS, all 4 routes prerender.
3. A custom contract-check script (`/tmp/contract-check.js`, not shipped in the repo — it's a
   one-off verification tool, not application code) that hits the live API with the frontend's
   exact request shapes and asserts the response matches the frontend's TypeScript types
   field-for-field. This is what caught the bug above.
4. A full live regression against both servers running together (API on :3001, web on :3000):
   10 assertions — page routes return 200, register returns 201, `/users/me` returns the full
   `AuthUser` shape with the correct role, refresh rotation works, reuse of a rotated/
   logged-out refresh token correctly 401s. **10/10 passed**, zero unexpected errors in either
   server's log.

**Lint:** PASS (api + web).
**Typecheck:** PASS (api).
**Build:** PASS (api + web).

**Known issues:**
- **No headless browser was available in this sandbox**, so the UI was not click-tested in an
  actual rendered browser this session — verification was via the contract-check script (proves
  the data layer is correct) plus manual review of the component code (proves the UI logic
  wires to that data layer correctly), not a substitute for a real click-through. Recommend an
  actual manual pass in a real browser (`docker compose up`, or the manual dev commands from
  `README.md`) before treating Phase 05/06 as fully user-verified.
- Refresh token in `localStorage` is a known, documented trade-off (XSS-readable) — the
  hardened alternative (httpOnly cookie set by the API) is scoped for Phase 35, not before.
- `register`/`login` response shape changed shape (see API changes above) — not a breaking
  change for anything that exists today (nothing else consumed the old shape), but noting it
  in case anything is added against the old shape from memory later.
- No "forgot password" flow — not in the proposal's MVP scope, not built.

**Next phase:** 07 — Farmer Profile.

---

## DAY 4

### PHASE 07 — Farmer Profile
**STATUS:** COMPLETE

**Completed:**
- `FarmerProfile` entity: one-to-one with `User`, keyed by `userId`. Kept separate from `User`
  rather than adding columns to `users` — buyers/transporters never get a row here (proposal
  §7.1: "Farmer registration (name, phone/ID, location, cooperative membership)"; name/phone
  already live on `User`, so this entity holds only the farmer-specific remainder: `zone`,
  `woreda`, `kebele`, `cooperativeName`, `nationalIdNumber`).
- Auto-created empty at registration time: `AuthService.register()` calls
  `FarmerProfileService.createEmptyProfile()` when `role === FARMER`, so a farmer never has a
  "no profile yet" state to handle — `GET /farmers/me` always returns something, with fields
  `null` until filled in.
- `GET /farmers/me`, `PATCH /farmers/me` — restricted to the `farmer` role (`@Roles`), scoped
  to the caller's own profile only (no id param — always "mine").
- Frontend: `/app/profile` — loads the current profile, editable form (zone, woreda, kebele,
  cooperative), inline validation, loading/error/success states.

**Files changed:** `farmers/entities/farmer-profile.entity.ts`, `farmers/dto/update-farmer-
profile.dto.ts`, `farmers/farmer-profile.service.ts`, `farmers/farmer-profile.controller.ts`,
`farmers/farmers.module.ts`, `auth/auth.service.ts` (calls `createEmptyProfile` on farmer
registration), `auth/auth.module.ts` (imports `FarmersModule`); frontend:
`lib/farmers/{types,api-client}.ts`, `app/app/profile/page.tsx`

---

### PHASE 08 — Farm Registry
**STATUS:** COMPLETE

**Completed:**
- `Farm` entity: `farmerId` references `User` directly (not `FarmerProfile`) — matches the
  proposal's own data model (§10.3: "Farmer → Farm(s)"), and a farmer's farms aren't assumed
  to sit in the farmer's own zone/woreda from their profile (land is sometimes worked at a
  distance from where the farmer lives), so each `Farm` carries its own full location
  (`zone`/`woreda`/`kebele`) plus optional GPS (`latitude`/`longitude`).
- Money/precision handling: `sizeHectares` and GPS coordinates are stored as `decimal` and
  returned as strings (MySQL DECIMAL → string via TypeORM, avoiding float precision loss) —
  same principle as the currency-as-minor-units decision in `docs/architecture.md`.
- Full CRUD: `POST /farms`, `GET /farms` (list mine), `GET /farms/:id`, `PATCH /farms/:id`,
  `DELETE /farms/:id`. Ownership enforced in `FarmsService`: a farm belonging to someone else
  returns the *same* 404 as a farm that doesn't exist at all (never a 403) — prevents using
  this endpoint to enumerate other farmers' farm IDs by distinguishing the two cases.
- Validation: farm size must be positive and under a sanity ceiling (100,000 ha), GPS lat/lng
  bounded to valid ranges, name/zone/woreda length-checked.
- Frontend: `/app/farms` — list, add, edit, delete, with a confirm step before delete and
  per-card error/loading states. `/app` now links to both `/app/profile` and `/app/farms` for
  farmers (real, working links — the "coming next" roadmap card only lists what's genuinely
  not built yet).

**A real, structural bug found and fixed via end-to-end testing, not inspection:** the first
full test run of this phase found every farmer request to `/farmers/me` and `/farms` failing
with 403 — even for a correctly authenticated farmer. Root cause: `RolesGuard` had been
registered as a **global** guard back in Phase 04, on the reasoning that a global guard can't
be forgotten on a future route. `JwtAuthGuard`, however, was only ever applied **locally** per
controller (`@UseGuards(JwtAuthGuard)`) — and NestJS always runs global guards before
controller-level ones, regardless of import order. So the global `RolesGuard` was evaluating
`request.user` before `JwtAuthGuard` had ever run to set it, saw no user, and rejected every
`@Roles(...)`-protected route unconditionally. This had been silently broken since Phase 04;
it just had no `@Roles()`-guarded routes to expose it until now.

Fixed properly, not patched around: added a `@Public()` decorator + metadata, made
`JwtAuthGuard` itself check for that metadata and skip validation when present, and made
`JwtAuthGuard` global too — in explicit declared order **before** `RolesGuard` (Nest runs
multiple `APP_GUARD` providers in declaration order). Every route is now authenticated by
default; the handful of genuinely public ones (`auth/register`, `auth/login`, `auth/refresh`,
`auth/logout`, `health`) opt OUT with `@Public()` instead of every protected route opting in —
the safer default for a growing API, and it removes the redundant per-controller
`@UseGuards(JwtAuthGuard, RolesGuard)` that existed on `FarmerProfileController`,
`FarmsController`, and `UsersController` (now just `@Roles(...)` where a role restriction is
needed; nothing at all where "any authenticated user" is enough, e.g. `/users/me`).

Re-ran the full farmer/farm/buyer regression after the fix — **16/16 assertions passed**,
including the exact scenario that was broken (farmer accessing their own profile and farms),
the buyer-role-restriction check, and the cross-owner 404 checks. Also re-ran the complete Day
1–3 auth regression (register/login/refresh-rotation/logout) to confirm the guard restructure
didn't break anything upstream — **6/6 passed**, no regressions.

**Files changed:** `farmers/entities/farm.entity.ts`, `farmers/dto/{create-farm,update-
farm}.dto.ts`, `farmers/farms.service.ts`, `farmers/farms.controller.ts`,
`farmers/__tests__/farms.service.spec.ts` (11 new tests); guard fix: `auth/decorators/
public.decorator.ts` (new), `auth/guards/jwt-auth.guard.ts` (now reads `@Public()`),
`app.module.ts` (both guards global, correct order), `auth/auth.controller.ts` (`@Public()` on
all 4 routes), `health/health.controller.ts` (`@Public()`), `users/users.controller.ts`,
`farmers/farmer-profile.controller.ts`, `farmers/farms.controller.ts` (removed now-redundant
local `@UseGuards`); frontend: `lib/auth/api-client.ts` (exported `authRequest` for reuse),
`app/app/farms/page.tsx`, `app/app/page.tsx` (real profile/farms links for farmers)

**Database changes:** `farmer_profiles`, `farms` tables (migration
`1789279531465-FarmerProfileAndFarms`), run and confirmed via `DESCRIBE` against live MySQL.

**API changes:** `GET/PATCH /api/v1/farmers/me`, `POST/GET/PATCH/DELETE /api/v1/farms[/:id]`.

**Frontend changes:** `/app/profile`, `/app/farms`; `/app` updated with real links.

**Tests:** 11 new unit tests (`farms.service.spec.ts`) — decimal/GPS precision handling,
null-vs-zero for omitted GPS, the ownership boundary (own farm vs. someone else's vs.
nonexistent — same error for the latter two), partial-update behavior (only DTO fields
change), and rejecting cross-owner update/delete. All 21 backend tests (10 auth + 11 farms)
pass together.

**Lint:** PASS (api + web). **Typecheck:** PASS (api). **Build:** PASS (api + web, all 7 web
routes prerender: `/`, `/login`, `/register`, `/app`, `/app/profile`, `/app/farms`,
`/_not-found`).

**Verification performed this session:**
1. Backend: typecheck, lint, all 21 unit tests, build — all PASS, both before and after the
   guard fix (to isolate that the fix caused no new failures).
2. A contract-check script hitting live `/farmers/me` and `/farms` endpoints, asserting the
   JSON shape matches the frontend's TypeScript types field-for-field (including that
   `sizeHectares`/`latitude`/`longitude` really do come back as strings, matching the
   frontend's type — a detail easy to get wrong silently). PASS.
3. A full live regression with real MySQL and both the API and web servers running together:
   16 assertions covering the farmer-profile and farm-registry flows end to end (including the
   authorization boundary), **16/16 passed**; a separate 6-assertion re-run of the Day 1–3 auth
   flow to check for regressions from the guard restructure, **6/6 passed**; a 7-route check
   across both servers (all pages + API health) after the frontend pages were added, **7/7
   passed**. Zero unexpected errors in any server log across all three runs.

**Known issues:**
- Still no headless browser in this sandbox — same caveat as Day 3: the new `/app/profile` and
  `/app/farms` pages are contract-verified and code-reviewed, not click-tested in an actual
  browser.
- `FarmerProfile.zone`/`woreda`/`kebele` are free-text, not validated against a real Ethiopian
  administrative gazetteer — flagged in `docs/architecture.md`'s original design notes as an
  intentional MVP simplification, revisited if/when an admin-managed reference list exists
  (Phase 32).
- No test coverage yet for `FarmerProfileService` specifically (only `FarmsService` got unit
  tests this phase) — it's simple enough (create/find/update, no branching logic) that manual
  end-to-end testing covered it adequately for now, but it's a gap worth closing before Phase
  35's QA pass.

**Next phase:** 09 — Crop & Production Records.

---

## DAY 5

### PHASE 09 — Crop & Production Records
**STATUS:** COMPLETE

**Completed:**
- `Crop` master-data entity in its own top-level module (`crops/`), not nested inside
  `farmers/` — both this phase's farm crop records (Module 1) and the future Market
  Intelligence module (Phase 11–14, Module 2) key off the same catalog, so it belongs to
  neither alone. `GET /crops` (any authenticated role) lists the currently-selectable catalog.
  Full admin CRUD over this catalog is explicitly Phase 11's job ("Market & Crop Master Data
  — Admin APIs, Seed data"), not built here — this phase ships the catalog as read-only seed
  data, documented as an assumption below.
- **Assumption, documented rather than silently resolved:** the proposal's own §9 text lists
  Stage 1's crops as "maize, teff, wheat, potato, coffee, tomato, and carrot" in one sentence,
  then in the very next paragraph refers to "the seven crops above (maize, teff, wheat,
  potato, coffee)" — five names, not seven. That inconsistency is in the source document
  itself. Shipped the five storable crops as active/selectable and seeded tomato + carrot as
  present-but-inactive (`Crop.isActive = false`, `isPerishable = true`) — matching the
  proposal's own hedge that perishables are "provisional" pending field validation, without
  blocking the five crops that aren't in question. Flipping them on later is a data change
  (`UPDATE crops SET is_active = true`), not a schema or code change.
- `FarmCropRecord` entity — proposal §10.3's literal data model: "Farmer → Farm(s) → Crop
  Records (crop, area, expected yield, harvest window)". No unique constraint on
  (farm, crop): a farm can carry the same crop across more than one planting cycle in a year
  (e.g. belg/meher seasons), each a separate record.
- Real, non-decorator business validation in `FarmCropsService` (not just DTO-level format
  checks): a farm's crop records cannot commit more area in total than the farm's own
  `sizeHectares` — checked on both create and update, correctly excluding the record being
  edited from its own budget check (a record growing from 4 ha to 10 ha on a 10 ha farm must
  not count its own old 4 ha against itself). Harvest end date cannot precede start date.
  Cross-owner authorization chains through the farm check already built in Phase 08 (same
  "404 for both nonexistent and not-yours" principle).
- Nested REST resource: `POST/GET/PATCH/DELETE /farms/:farmId/crops[/:id]` — farmer-only,
  ownership-scoped through the parent farm.
- Frontend: `/app/farms/[farmId]/crops` — full add/edit/delete UI for a farm's crop records,
  crop picker sourced from the live catalog, remaining-hectares hint shown on the form (so a
  farmer sees the budget before hitting the same validation error the API would return), a
  "Perishable" badge on tomato/carrot-type crops. `/app/farms` now links each farm card to its
  crop-management page.

**A real, valuable bug caught by a test I wrote to specifically target it:** the area-budget
check's "exclude the record being edited from its own total" logic is exactly the kind of
off-by-self-reference bug that's easy to get backwards. I wrote a unit test
(`FarmCropsService`, "excludes the record being edited from its own area-budget check")
before trusting the implementation, asserting that growing a farm's *only* crop record from 4
ha to the farm's full 10 ha succeeds — if the exclusion were missing or wrong, this would
wrongly compute 4 (old value, double-counted) + 10 (new value) = 14 > 10 and reject a
perfectly valid edit. It passed on the first implementation, but the test exists specifically
to catch a regression here, since this exact class of bug wouldn't be caught by the
straightforward "reject when over budget" tests alone.

**Files changed:** `crops/entities/crop.entity.ts`, `crops/crops.service.ts`,
`crops/crops.controller.ts`, `crops/crops.module.ts`; `farmers/entities/farm-crop-record.entity.ts`,
`farmers/dto/{create,update}-farm-crop-record.dto.ts`, `farmers/farm-crops.service.ts`,
`farmers/farm-crops.controller.ts`, `farmers/farmers.module.ts` (wired in), `app.module.ts`
(registered `CropsModule`); migrations: `CropsAndFarmCropRecords` (schema),
`SeedCrops` (data, kept separate from schema on purpose); frontend:
`lib/farmers/types.ts` (`Crop`, `FarmCropRecord`, related inputs),
`lib/farmers/api-client.ts` (crop endpoints), `components/ui/Select.tsx` (new),
`app/app/farms/[farmId]/crops/page.tsx` (new), `app/app/farms/page.tsx` ("Manage crops" link)

**Database changes:** `crops` table + 7-row seed (5 active, 2 inactive), `farm_crop_records`
table with FKs to `farms` (CASCADE) and `crops` (RESTRICT — a crop referenced by an existing
record can't be deleted out from under it, though crop deletion isn't exposed anywhere yet
anyway).

**API changes:** `GET /api/v1/crops`; `POST/GET/PATCH/DELETE /api/v1/farms/:farmId/crops[/:id]`.

**Frontend changes:** `/app/farms/[farmId]/crops` (new); `/app/farms` updated with a link to it.

**Tests:** 14 new unit tests (`farm-crops.service.spec.ts`) covering: rejection when a farm
isn't owned by the caller (before even checking the crop), rejection of an inactive/nonexistent
crop, over-budget rejection both for a single request alone and combined with existing
records, acceptance at exactly the farm's full size (boundary case), bad harvest windows, null
(not zero) for an omitted expected yield, the ownership-chained 404 behavior for
read/update/delete, and the self-exclusion budget check described above. All 35 backend tests
(10 auth + 11 farms + 14 farm-crops) pass together.

**Lint:** PASS (api + web). **Typecheck:** PASS (api). **Build:** PASS (api + web).

---

### PHASE 10 — Farmer Dashboard
**STATUS:** COMPLETE

**Completed:**
- `FarmerDashboardService` — a real cross-entity aggregation, not a facade over one table:
  composes `FarmerProfileService`, `FarmsService`, and `FarmCropsService` to compute farm
  count, total hectares, a crop summary grouped across all of a farmer's farms (not per-farm —
  "how much teff am I growing in total" is the useful number here), and a merged, time-sorted
  recent-activity feed built from real `createdAt` timestamps on farms and crop records (no
  synthetic/mocked activity log).
- `GET /farmers/me/dashboard` — farmer-only.
- Frontend: `/app` now renders this as the actual farmer home screen (farm/crop stat cards,
  crop summary, recent activity, management links) instead of the static roadmap card it
  showed through Day 4. Buyer/transporter/admin accounts still see the honest "coming next"
  roadmap for their role, since nothing is built for them yet — the dashboard only replaces
  the farmer view, where there's now real functionality behind it. Added a visible nudge (an
  `Alert`, not a silent gap) when a farmer's zone/woreda is still empty, linking straight to
  `/app/profile` to fix it — a farmer with no location can't be found by the market-comparison
  or buyer-matching features being built in later phases, so this is worth surfacing now
  rather than after those features exist and silently don't work for that farmer.

**Verification performed this session:**
1. Backend: typecheck, lint, all 35 unit tests, build — all PASS.
2. Frontend: `next lint`, `next build` — both PASS, all 8 routes compile (including the new
   dynamic `/app/farms/[farmId]/crops` route).
3. A full live end-to-end test against real MySQL: crop catalog listing (with the
   unauthenticated-401 check), farm crop record creation with the exact area-budget boundary
   (reject at 6 ha over a 5 ha farm, accept at exactly 5 ha), inactive-crop rejection, bad
   harvest window rejection, cross-owner 404s for create/read, update/delete, and the
   dashboard endpoint — verified the crop summary and recent-activity numbers were internally
   consistent with a delete that had just happened moments earlier in the same test run.
   **15/15 assertions passed.**
4. A contract-check script diffing live API responses against the frontend's TypeScript types
   for `/crops`, farm crop records, and the dashboard — including the easy-to-get-wrong detail
   that `FarmerDashboard.cropsSummary[].totalAreaHectares` comes back as a real JSON number
   (server-side aggregation), unlike the raw entity fields elsewhere in the API that
   deliberately stay as MySQL DECIMAL strings. **PASS, no mismatches.**
5. Re-ran the full Day 1–4 regression (register, login, refresh rotation, `/users/me`,
   `/farmers/me`, create farm, health) to confirm today's changes didn't break anything
   upstream. **7/7 passed.**
6. An 8-route check across both live servers (all pages including the new dynamic route, plus
   API health). **8/8 passed.** Zero unexpected errors in any server log across all runs.

**Known issues:**
- Still no headless browser in this sandbox — same standing caveat since Day 3.
- The crop catalog has no admin management yet (add/edit/deactivate a crop) — intentionally
  deferred to Phase 11, which owns that scope per the phase map. Right now, going from 5 to 6
  active crops requires a direct database update, not an API call.
- `FarmerDashboardService` has no dedicated unit tests (only exercised end-to-end) — it has
  real branching logic (grouping, sorting, merging two activity sources) that would benefit
  from unit coverage; flagged for closing before Phase 35's QA pass, same as
  `FarmerProfileService` from Day 4.
- Recent activity is capped at 5 items with no pagination — reasonable for a dashboard summary
  at this data scale, revisit if it turns out farmers want deeper history.

**Next phase:** 11 — Market & Crop Master Data.

---

## DAY 6

### PHASE 11 — Market & Crop Master Data
**STATUS:** COMPLETE

**Completed:**
- **Admin bootstrap script** (`scripts/create-admin.ts`, `npm run create-admin`): the out-of-
  band admin provisioning mechanism that's been referenced since Phase 04's decision to block
  admin self-registration. Deliberately a CLI script requiring the operator to supply a real
  phone/name/password, not a fixed default credential seeded via migration — a hardcoded
  bootstrap admin/password shipped in a migration is a real, well-documented attack surface
  (every deployment that doesn't think to change it shares the same credential). This is the
  first phase that actually needed an admin account to exist, so it's the right phase to close
  this gap rather than leaving it as a standing TODO.
- `Market` entity — same location-field shape as `Farm` (zone/woreda/kebele + optional GPS),
  deliberately mirrored rather than inventing a different "place" shape a second time.
- Crop catalog admin CRUD (closes the Day 5 known issue: "crop catalog has no admin management
  yet"): `POST/GET/PATCH /admin/crops`, admin-only. No DELETE — a crop referenced by an
  existing `FarmCropRecord` is FK-protected (`ON DELETE RESTRICT`) anyway, so "remove a crop"
  is really "deactivate it" (`isActive: false`), preserving the history of anything that
  already points at it.
- Market admin CRUD: `POST/GET/PATCH /admin/markets`, admin-only; `GET /markets` (any
  authenticated role, active only) — same public/admin split pattern as crops.
- Seed data: the Stage-1 market list from proposal §9 (Jimma Town, Nekemte, Agaro).

**Files changed:** `scripts/create-admin.ts` (new), `apps/api/package.json` (`create-admin`
script); `crops/dto/{create,update}-crop.dto.ts`, `crops/crops.service.ts` (admin methods),
`crops/admin/admin-crops.controller.ts`, `crops/crops.module.ts`; `markets/entities/
market.entity.ts`, `markets/dto/{create,update}-market.dto.ts`, `markets/markets.service.ts`,
`markets/markets.controller.ts`, `markets/admin/admin-markets.controller.ts`,
`markets/markets.module.ts`, `app.module.ts` (registered `MarketsModule`); migration
`MarketsAndPrices` (schema) and `SeedMarketsAndPrices` (data, kept separate — same principle
as the crops seed migration on Day 5).

**A real bug caught immediately by the tooling itself, not by testing:** `Market.kebele:
string | null` without an explicit `type` on the `@Column` decorator hit the exact same
TypeORM limitation fixed twice already this build (Day 3's `User.email`, Day 4's
`RefreshToken.revokedAt`) — TypeORM can't infer a MySQL column type from a TypeScript union
type. Migration generation failed immediately with `DataTypeNotSupportedError` rather than
silently producing a wrong migration, so this was caught before it ever reached a running
database. Fixed the same way as the prior two instances: explicit `type: 'varchar'`.

**Database changes:** `markets` table; 3 markets seeded (Jimma Town Market, Nekemte Market,
Agaro Market) with approximate real-world coordinates, all `isActive: true`.

**API changes:** `GET /api/v1/markets`; `POST/GET/PATCH /api/v1/admin/markets[/:id]`;
`POST/GET/PATCH /api/v1/admin/crops[/:id]`.

---

### PHASE 12 — Market Price Intelligence
**STATUS:** COMPLETE

**Completed:**
- `MarketPrice` entity — proposal §10.3's literal shape: "Market → Price Observation (crop,
  grade, price, date, source)". Price stored as an integer (`pricePerKgCents`), not a decimal —
  same float-precision-avoidance principle documented in `docs/architecture.md` for the future
  recommendation engine and transactions, applied here because this value is exactly what that
  engine will later multiply by a farmer's quantity to compute gross revenue (Phase 15–16) —
  worth getting right from the start rather than retrofitting once that calculation exists.
  The API boundary still speaks ETB as a decimal string (e.g. `"25.50"`); cents-as-storage is
  an internal implementation detail, converted at the service boundary in both directions.
- **Price freshness** — the concept `docs/design-system.md` defined back on Day 1
  (VERIFIED/ESTIMATED/STALE/DEMO badges) now has real logic behind it:
  `MarketPricesService.computeFreshness()` returns `demo` for any demo-sourced record
  regardless of age, `verified` within 7 days (matching the proposal's own KPI target in §14:
  "avg. age of active price records ≤ 7 days"), `estimated` up to 30 days, `stale` beyond that.
  The 7/30-day thresholds are a documented assumption — the proposal specifies the 7-day
  target as a KPI to hit, not the exact freshness-bucket boundaries a UI should use, so this
  build picked the simplest reasonable interpretation consistent with that number.
- Admin CRUD for price observations: `POST/GET/PATCH/DELETE /admin/market-prices`. A price
  observation's `marketId`/`cropId` are immutable once created (same reasoning as `Crop.slug`
  and `Farm`'s ownership fields elsewhere in this build) — an observation is inherently tied to
  where/what it was observed; reassigning it after the fact would rewrite history rather than
  correct a typo. Correcting the wrong market/crop means deleting and recreating, not patching.
- Real validation beyond format checks: an `observationDate` in the future is rejected — a
  price can't be "observed" at a date that hasn't happened yet.
- Public-facing read: `GET /market-prices?cropId=X` — the latest observation per active
  market for a crop (not full history; historical trends are explicitly Phase 14's job, kept
  out of scope here on purpose). Retired markets (`isActive: false`) are excluded even if they
  have historical price rows.
- Seed data: demo price observations for the 5 active crops across all 3 seeded markets, all
  tagged `source: demo`. The potato figures reuse the proposal's own §8 worked example
  (Jimma 25 ETB/kg, Nekemte 28 ETB/kg) rather than inventing new numbers for the one crop the
  proposal already gives concrete figures for — every other crop/market combination is a
  plausible round demo number, never presented as real (proposal rule 4: "do not fabricate
  market prices" — satisfied by clearly tagging everything `demo`, not by refusing to seed any
  numbers at all, which would leave Phase 12's own endpoints untestable).

**A real, non-trivial bug caught by a test written specifically to target it:** the
"latest price per market" query needed a deterministic tiebreaker for two observations sharing
the same `observationDate` (e.g. a same-day correction) — without a secondary sort by
`createdAt DESC`, which row "wins" as latest would depend on incidental DB return order, not on
which was actually entered more recently. Caught and fixed *before* the first test run (by
re-deriving the logic while writing it, prompted by the exact same class of ordering bug I'd
already hit once this build — Day 2's `jti` collision), then a dedicated test
("returns only the most recent observation per market, not every historical row") locked in
the correct behavior by asserting the *newer* of two same-market rows wins, not just that
grouping happens at all.

**Files changed:** `markets/entities/market-price.entity.ts`, `markets/dto/{create,update}-
market-price.dto.ts`, `markets/market-prices.service.ts`, `markets/market-prices.controller.ts`,
`markets/admin/admin-market-prices.controller.ts`, `markets/markets.module.ts` (wired in);
migration `SeedMarketsAndPrices` (also seeds prices, see Phase 11)

**Database changes:** `market_prices` table (FK to `markets` CASCADE, FK to `crops`
RESTRICT); 15 demo price rows (5 crops × 3 markets).

**API changes:** `GET /api/v1/market-prices?cropId=X`; `POST/GET/PATCH/DELETE
/api/v1/admin/market-prices[/:id]`.

**Frontend changes:** none this phase — deliberately. Unlike Phases 07–10, the original
phase breakdown lists no UI bullet under Phase 11 or 12 (contrast with Phase 07's explicit
"Crop UI" or Phase 09's "Crop UI"); Phase 13 ("Market Comparison — ... Farmer UI") is where
farmer-facing price screens are scoped. Building a prices page now would mean redesigning it
almost immediately once Phase 13 adds ranking/comparison on top of the same data — so this
phase stays backend-only, matching the plan's own boundary rather than getting ahead of it.

**Tests:** 15 new unit tests (`market-prices.service.spec.ts`): freshness computation across
all four buckets and the demo-always-wins rule, ETB↔cents conversion in both directions,
future-date rejection on both create and update, inactive/nonexistent market or crop
rejection, the latest-per-market grouping (including the same-date tiebreaker and excluding
retired markets), and partial-update semantics (only DTO-provided fields change). All 50
backend tests (10 auth + 11 farms + 14 farm-crops + 15 market-prices) pass together.

**Lint:** PASS (api). **Typecheck:** PASS. **Build:** PASS.

**Verification performed this session:**
1. Backend: typecheck, lint, all 50 unit tests, build — all PASS.
2. A full live end-to-end test against real MySQL, using a freshly-bootstrapped admin account:
   admin crop creation + duplicate-slug rejection, activating a previously-inactive crop live
   (flipping the Day 5 tomato/carrot decision through the actual API, not just in theory),
   admin market creation, admin price creation with the exact future-date rejection boundary,
   a farmer correctly seeing the new market and crop through the public read endpoints, a
   farmer correctly blocked (403) from every admin endpoint, and an unauthenticated request
   correctly blocked (401) from `/market-prices`. **13/13 assertions passed.**
3. Re-ran the full Day 1–5 regression (register, login, refresh, `/users/me`, `/farmers/me`,
   create farm, create crop record, dashboard, health) after today's schema/module changes —
   an initial run returned all-000 connection failures across the board, traced to MariaDB not
   having fully come up before the API tried to connect in that particular script run (confirmed
   by booting the API in the foreground immediately afterward, which started cleanly with every
   route correctly mapped) rather than any actual code defect; re-ran with more startup margin
   and got **9/9 passed**, confirming there was no real regression.

**Known issues:**
- No admin-facing UI for any of today's endpoints (crops, markets, prices) — intentional, see
  Frontend changes above; Phase 32 ("Admin Dashboard") is where that's built. Right now,
  admin operations are API/CLI-only, which is consistent with what Phase 11's own bullet list
  asks for ("Admin APIs"), not a shortfall against it.
- `computeFreshness`'s 7/30-day thresholds are this build's own reasonable interpretation of
  the proposal's 7-day KPI target, not a value the proposal states directly — flagged as an
  assumption above; easy to tune later since it's one small pure function.
- The "latest price per market" query fetches all price rows for a crop and groups in
  application code rather than a single SQL query — correct and fine at MVP data volume, but
  worth revisiting in Phase 37 (Performance) once real price history accumulates.
- No historical price data or trend endpoints yet — correctly deferred to Phase 14.

**Next phase:** 13 — Market Comparison.

---

## DAY 7

### PHASE 13 — Market Comparison
**STATUS:** COMPLETE

**Completed:**
- The first farmer-facing UI for market prices: `/app/market-prices`. Crop filtering (a
  dropdown sourced from the live `/crops` catalog) and market filtering (a free-text search
  over market name/zone/woreda — a real, useful control even with only 3 seeded markets, and
  one that scales as the catalog grows rather than needing to be added later).
- Price comparison: results sorted highest-to-lowest with "HIGHEST PRICE"/"LOWEST PRICE"
  badges, each showing its `FreshnessBadge` (the VERIFIED/ESTIMATED/STALE/DEMO DATA concept
  `docs/design-system.md` defined on Day 1, now backed by Phase 12's real freshness
  computation and finally rendered in an actual screen).
- **A deliberate, proposal-faithful framing choice:** the comparison view is explicitly *not*
  presented as a recommendation. It carries a visible note that transport cost isn't factored
  in yet and that "Where Should I Sell?" (Phase 15–20) will show real net earnings. This
  matters because the proposal's entire flagship-feature argument (§8) is that the
  highest-*price* market is often not the best *net* choice once transport is subtracted —
  showing a naive "highest price wins" ranking without that caveat would work against the
  product's own core thesis, not just be incomplete.
- No new backend endpoints this phase — deliberately built on Phase 12's existing
  `GET /market-prices?cropId=X` rather than adding comparison-specific backend logic, since
  min/max/sort are presentation concerns over data the API already returns correctly.

**Files changed:** `lib/markets/types.ts`, `lib/markets/api-client.ts` (new),
`components/ui/FreshnessBadge.tsx` (new), `app/app/market-prices/page.tsx` (new), `app/app/
page.tsx` (removed the now-built "Market prices & comparison" roadmap item, added real links
for every role — the backend never restricted this by role, so the frontend shouldn't either)

**Frontend changes:** `/app/market-prices` (new).

---

### PHASE 14 — Historical Prices & Trends
**STATUS:** COMPLETE

**Completed:**
- `MarketPricesService.findHistory()` — historical price points for one market/crop pair
  within a bounded window (default 90 days, hard-capped at 365 to prevent an unbounded query),
  plus a **trend**, computed honestly as "how did the price move from the oldest to the newest
  point in this window" — not a forecast. The proposal mentions "simple short-term
  forecasting" as eventual Module 2 scope, but predicting future prices is a materially
  different (and materially more likely to be wrong in a way that damages trust) feature than
  reporting what already happened; this build ships only the latter.
- A noise threshold (0.5%) below which the trend reports "flat" rather than "up"/"down" — a
  documented judgment call, not a proposal-specified value, so a 0.2% wobble between two demo
  points doesn't get reported as a meaningful market signal.
- Seed data: added 5 historical demo price points (14/28/42/56/70 days back) per crop/market
  combination, on top of Day 6's "today" seed — without this, every trend query would
  correctly but unhelpfully report `insufficient_data`, leaving nothing to demonstrate the
  feature with. Deterministic small variation factors, not random — the migration produces the
  same data every time it's read, even though it only runs once. All still `source: demo`.
- Frontend: `/app/market-prices/history` — a real line chart (via `recharts`, a genuine new
  dependency, not a hand-rolled one-off) of price over time, the trend direction/percentage
  shown prominently, and a chronological history table below it.
- **Explicit stale-data and demo-data handling** — the bullet Phase 14 calls out by name,
  distinct from just showing a colored freshness badge: when the latest point's freshness is
  `stale`, the page shows a plain-language warning ("hasn't been updated in over a month...
  check locally before relying on it") rather than trusting a farmer to interpret a badge
  color's implications correctly; when it's `demo`, an equally explicit "this is demonstration
  data, not a real observed price" notice.

**A real bug caught and fixed before it ever ran, prompted by a bug from earlier this build:**
while writing `findHistory`'s "latest per market" adjacent logic, I specifically checked
whether two price observations sharing the same `observationDate` (e.g. a same-day correction)
would have a deterministic ordering — because Day 6's `findLatestPerMarket` had exactly this
class of gap until I added a `createdAt DESC` tiebreaker. Applied the same fix proactively to
the new sort in `findHistory` before writing any test against it, then wrote a dedicated test
("returns only the most recent observation per market, not every historical row" — reused from
Day 6 — plus new trend-specific tests) to lock in the correct behavior rather than relying on
having remembered correctly.

**Files changed:** `markets/market-prices.service.ts` (`findHistory`, `computeTrend`, new
`PriceTrend`/`PriceHistoryResult` types), `markets/market-prices.controller.ts` (`GET
/market-prices/history`); migration `SeedHistoricalPrices` (new); frontend:
`apps/web/package.json` (`recharts` dependency), `lib/markets/api-client.ts` (`getHistory`),
`app/app/market-prices/history/page.tsx` (new), `app/app/market-prices/page.tsx` ("View
trend →" link per market)

**Database changes:** 5 additional historical demo price rows per crop/market (75 total: 5
crops × 3 markets × 5 historical points), alongside the 15 "today" rows from Day 6.

**API changes:** `GET /api/v1/market-prices/history?marketId=&cropId=&days=`.

**Frontend changes:** `/app/market-prices/history` (new); linked from the comparison page.

**Tests:** 6 new unit tests for `findHistory`/`computeTrend`: insufficient-data with a single
point, correct "up"/"down" direction with accurate percentage, "flat" for a sub-threshold
change (proving the noise threshold actually suppresses false trends, not just that trends can
be computed at all), the days-clamp not erroring on an excessive request, and rejection for an
inactive/nonexistent market. All 56 backend tests (10 auth + 11 farms + 14 farm-crops + 21
market-prices) pass together.

**Lint:** PASS (api + web). **Typecheck:** PASS (api). **Build:** PASS (api + web, all 10
routes, including a real type error from `recharts`' Tooltip formatter signature that `next
build`'s type-checking pass caught and that I fixed — not suppressed — before treating the
phase as done).

**Verification performed this session:**
1. Backend: typecheck, lint, all 56 unit tests, build — all PASS.
2. Frontend: `next lint`, `next build` — both PASS, all 10 routes compile.
3. A full live end-to-end test of the history endpoint: correct 6-point history and accurate
   trend calculation (24.50→25.00 ETB = "up", +2.04%, matching the seeded numbers exactly), a
   14-day window correctly returning fewer points, an excessive `days` request clamping rather
   than erroring, missing query params correctly 400ing, and unauthenticated access correctly
   401ing. **5/5 assertions passed.**
4. A contract-check script diffing live `/markets`, `/market-prices`, and `/market-prices/
   history` responses against the frontend's TypeScript types — including the nested `market`
   and `crop` objects inside each price view. **PASS, no mismatches.**
5. A route-level regression across both live servers covering all 9 web routes (including the
   two new Day 7 pages) plus a 10-assertion backend regression covering the full Day 1–6 flow.
   The first attempt at the backend regression returned all-000 connection failures; rather
   than assume the code was fine and re-run blindly, I checked `service mariadb status`
   directly (confirmed MariaDB genuinely wasn't up yet at that point) and switched from a fixed
   `sleep` to a polling readiness check for both MariaDB and the API before running the actual
   assertions. **9/9 web routes and 10/10 backend assertions passed** on the corrected run,
   confirming this was test-harness timing, not a real regression.

**Known issues:**
- No headless browser in this sandbox — same standing caveat since Day 3; the chart and
  comparison UI are contract-verified and code-reviewed, not visually click-tested.
- The trend's noise threshold (0.5%) and freshness thresholds (7/30 days, from Day 6) are both
  this build's own reasonable defaults, not proposal-specified values — both are isolated,
  easily-tunable constants if real usage suggests different numbers.
- History is capped at 365 days server-side with no pagination — fine at current data volume;
  would need revisiting if/when years of real price history accumulate (Phase 37 territory).
- This sandbox's MariaDB startup time is inconsistent enough that fixed-duration `sleep`s in
  test scripts occasionally under-wait; documenting this explicitly so a future session doesn't
  mistake the same flakiness for a real regression again — poll for readiness instead of
  sleeping a fixed duration.

**Next phase:** 15 — Transport Cost System.

---

## DAY 8

### PHASE 15 — Transport Cost System
**STATUS:** COMPLETE

**Completed:**
- `TransportCostRule` entity implementing the architecture decision documented back on Day 1
  (`docs/architecture.md`): a static, admin-configured distance/rate table per (origin zone,
  market) route — not a live routing API. `distanceKm` is admin-entered, matching the
  proposal's own description of the transport-cost layer starting from "rule-of-thumb ETB/km/
  ton by route type" (§8) before any real routing integration exists.
- Two cost components per route, matching Phase 16's formula exactly: `ratePerKgPerKm` (a
  small decimal coefficient — kept as a proper decimal, not integer cents, since rounding a
  value this small to whole cents before multiplying it by distance and quantity would lose
  real precision) and `transitFeeCents` (a flat, genuine currency amount — the "informal
  transit/checkpoint fees" the proposal explicitly names in §7.4 — which does fit the
  established integer-cents pattern).
- One rule per route, enforced by a database-level unique constraint on (originZone,
  marketId) — a route's rate is a current configuration value an admin updates in place, not
  a historical log like `MarketPrice`.
- Admin CRUD: `POST/GET/PATCH /admin/transport-cost-rules`. No public read endpoint —
  deliberately: a transport rate is only ever consumed internally by the recommendation
  engine, never browsed directly by a farmer; there's no proposal requirement for a "view raw
  transport rates" screen.
- Seed data: three routes from "Jimma Zone" (the origin every seeded farm/profile uses) to all
  three markets. The rate (0.0138 ETB/kg/km) and flat fee (1,620 ETB) aren't arbitrary — they
  were derived by solving the proposal's own §8 worked example (Jimma: 20km/5,000kg→3,000 ETB;
  Nekemte: 150km/5,000kg→12,000 ETB) as two equations in two unknowns, so this build's demo
  data reproduces the proposal's own showcase numbers almost exactly rather than inventing
  unrelated placeholder figures.

**Files changed:** `logistics/entities/transport-cost-rule.entity.ts`, `logistics/dto/
{create,update}-transport-cost-rule.dto.ts`, `logistics/transport-cost-rules.service.ts`,
`logistics/admin/admin-transport-cost-rules.controller.ts`, `logistics/logistics.module.ts`,
`app.module.ts` (registered `LogisticsModule`); migrations `TransportCostRules` (schema —
also includes several harmless no-op `CHANGE COLUMN` statements TypeORM's diff tool
auto-generated for pre-existing nullable columns; verified before running that row counts on
`farms` and `market_prices` were unchanged after) and `SeedTransportCostRules` (data).

**Database changes:** `transport_cost_rules` table; 3 seeded routes (Jimma Zone → each of the
3 markets).

**API changes:** `POST/GET/PATCH /api/v1/admin/transport-cost-rules[/:id]`.

---

### PHASE 16 — Recommendation Engine
**STATUS:** COMPLETE

**Completed — the flagship "Where Should I Sell?" feature, implemented exactly as proposal §8
specifies:**
- `Gross Revenue = Price/kg × Quantity`
- `Est. Total Cost = Transport Cost + configured transit/logistics fee`
- `Est. Net Revenue = Gross Revenue − Est. Total Cost`
- Candidates ranked by net revenue, top-ranked flagged `isRecommended: true` — matching the
  proposal's own example UI text ("Recommendation: BEST ESTIMATED NET RETURN"), rendered
  verbatim in the frontend.
- **Explainability (proposal rule 11) implemented as full transparency, not just a ranking:**
  every candidate returns price, freshness, source, distance, and the complete cost breakdown
  (transport-cost component, transit fee, total cost) that went into its net revenue — a
  farmer (or a reviewer of this code) can verify the arithmetic, not just trust a number.
- Markets missing a price or missing a configured transport route are excluded from ranking
  with an explicit machine-readable reason (`no_price_data` / `no_transport_route_configured`)
  rather than silently dropped, assumed free, or crashing the request — shown in the frontend
  as a plain-language "not shown above" list. A market with a route but genuinely no recorded
  price, and a market with a price but no configured route, are two different situations and
  are distinguished as such.
- A `isLoss` flag when estimated total cost exceeds gross revenue — surfaced in the UI as an
  explicit warning, not just a negative number a farmer has to notice themselves.
- Farm ownership enforced through the existing `FarmsService.findOneOwnedBy` (same 404-for-
  both-nonexistent-and-not-yours pattern used everywhere else in this build) — a farmer can
  only get a recommendation using their own farm as the origin.
- Farmer-only endpoint (`GET /recommendation/where-should-i-sell`), all monetary arithmetic
  done in integer cents with rounding applied exactly once at the point a real ETB amount is
  produced (same principle as `MarketPricesService`), converted to decimal-string ETB only at
  the API boundary.
- Frontend: `/app/where-should-i-sell` — farm/crop/quantity form, ranked result cards with the
  full cost breakdown, the gold "BEST ESTIMATED NET RETURN" badge on the winner, a red loss
  warning where applicable, and an honest "not shown above" section explaining exclusions.
  `/app` now gives this feature the prominent visual placement `docs/design-system.md` called
  for back on Day 1 ("PRIMARY ACTION... should receive strong visual emphasis because it is a
  flagship feature") — a large gold CTA card, now finally backed by a real feature instead of
  a roadmap bullet.

**Verified against the proposal's own worked example, not just internal consistency:** ran the
exact scenario from proposal §8 (5,000 kg of potatoes, Jimma vs. Nekemte) through the live
API. Result: Jimma's net revenue came back as **122,000.00 ETB — an exact match** to the
proposal's own Table 2. Nekemte came back at 128,030.00 ETB against the proposal's 128,000 (a
30 ETB difference from the seed data's clean-constant rounding, documented in the seed
migration itself). Nekemte correctly outranks Jimma despite Jimma's lower transport cost and
Nekemte's lower headline price margin — reproducing the entire point of the flagship feature
(a higher price 150km away can still be the better choice) end to end, with real numbers,
not asserted in the abstract.

**A real bug caught by my own test, in the test itself — not the implementation:** while
writing the worked-example reproduction test, I asserted `transportCost` should equal the
proposal's 3,000 ETB figure and the test failed, showing 1,380 ETB instead. Tracing it
revealed the test's assumption was wrong, not the code's math: this build deliberately splits
"Est. Transport Cost" into two separate, explainable components — a distance-based
`transportCost` (1,380 ETB) and a flat `transitFee` (1,620 ETB) — whereas the proposal's single
worked-example column is their sum (`totalCost`, 3,000 ETB exactly). Fixed the test's
assertions to check the correct field, and added an explicit doc comment on the
`RecommendationCandidate` interface itself clarifying this distinction, so a future reader
(including a future me) doesn't make the same mistake reading the code cold.

**Files changed:** `recommendation/recommendation.service.ts`, `recommendation/
recommendation.controller.ts`, `recommendation/recommendation.module.ts`, `recommendation/dto/
get-recommendation.dto.ts`, `farmers/farmers.module.ts` (exported `FarmsService` for cross-
module use), `app.module.ts` (registered `RecommendationModule`); frontend: `lib/
recommendation/{types,api-client}.ts`, `app/app/where-should-i-sell/page.tsx` (new), `app/app/
page.tsx` (flagship CTA placement, removed the now-built roadmap item)

**API changes:** `GET /api/v1/recommendation/where-should-i-sell?farmId=&cropId=&quantityKg=`.

**Frontend changes:** `/app/where-should-i-sell` (new); `/app` updated with the prominent CTA.

**Tests:** 8 new unit tests (`recommendation.service.spec.ts`): the worked-example
reproduction (with the field-mapping bug described above caught and fixed before this phase
was considered done), correct ranking by net revenue rather than by price or input order
(including a scenario where the highest-priced market is deliberately the worst net choice —
proving the engine doesn't just default to "highest price wins"), both exclusion reasons
tested independently, an empty-candidates result handled gracefully, the loss flag, and
ownership/crop-validation propagation. All 64 backend tests (10 auth + 11 farms + 14
farm-crops + 21 market-prices + 8 recommendation) pass together.

**Lint:** PASS (api + web). **Typecheck:** PASS (api). **Build:** PASS (api + web, all 11
routes).

**Verification performed this session:**
1. Backend: typecheck, lint, all 64 unit tests, build — all PASS.
2. Frontend: `next lint`, `next build` — both PASS, all 11 routes compile.
3. A full live end-to-end test reproducing the proposal's own worked example via real HTTP
   calls against live MySQL — confirmed the exact 122,000 ETB Jimma figure and the correct
   Nekemte-wins ranking — plus role/ownership authorization checks (buyer 403, cross-owner
   farm 404), input validation (zero/negative quantity 400), and admin transport-rule CRUD
   including duplicate-route rejection. **10/10 assertions passed.**
4. A contract-check script confirming the live recommendation response matches the frontend's
   TypeScript types field-for-field, including that exactly one candidate is ever flagged
   `isRecommended` and that candidates are actually sorted by net revenue descending, not
   merely present. **PASS, no mismatches.**
5. Re-ran the full Day 1–7 regression (register through market-prices) plus the new
   recommendation endpoint. **10/10 passed**, no regressions.
6. An 8-route check across both live servers, including the new `/app/where-should-i-sell`
   page. **8/8 passed.** Zero unexpected errors in any server log across all runs.

**Known issues:**
- No headless browser in this sandbox — same standing caveat since Day 3.
- Deeper edge-case handling (equal net revenues between markets, near-zero-margin messaging,
  more refined "invalid route" UX) is explicitly Phase 19–20's scope, not this one — this
  phase implements the calculation and a plain, honest exclude-with-reason behavior for the
  two missing-data cases, not the full UX hardening pass planned for those phases.
- `TransportCostRule` has no admin-facing UI (consistent with Phase 15's own "Admin APIs"
  framing and the established pattern from Days 6/7 — admin screens are Phase 32's job).
- The recommendation engine currently only considers markets that already have both a price
  and a route — it does not surface "this market exists but we have zero data for it at all"
  separately from "we have partial data" beyond the two reason codes already implemented;
  revisit if that distinction turns out to matter once there are more markets than the 3
  seeded ones.

**Next phase:** 17 — Recommendation API (hardening/extension of what Phase 16 built — see
Day 9 for what's added there specifically; this phase already ships a working, tested API,
Phase 17 is scoped in the original plan to add candidate-selection refinement and further
explanation/source-timestamp detail on top of it).

