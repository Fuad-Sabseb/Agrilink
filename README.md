# AgriLink

Digital Market Intelligence & Agricultural Value-Chain Platform for Jimma Zone, Oromia, Ethiopia.

See `docs/` for the requirements extraction, architecture decisions, design system, and the
40-phase execution map. `PROGRESS.md` is the live build log.

## Local development

### Prereqs
- Node.js 20+
- MySQL 8 (or run everything via `docker compose up`)

### API
```
cd apps/api
cp .env.example .env   # then fill in real secrets
npm install
npm run start:dev
```
Health check: `GET http://localhost:3001/api/v1/health`

### Web
```
cd apps/web
npm install
npm run dev
```
App: `http://localhost:3000`

### Everything via Docker
```
docker compose up --build
```

## Creating an admin account

Admin accounts cannot self-register through the public API (by design — see `PROGRESS.md`
Day 2). To create the first admin account, run this from `apps/api` after the database
migrations have been applied:

```
npm run create-admin -- --phone=+251911223344 --name="Ops Admin" --password="a-real-password"
```

Log in with that phone number and password via the normal `POST /api/v1/auth/login` endpoint.
There is no admin UI yet (that's Phase 32) — admin operations are done via the `/admin/*` API
endpoints directly (crop catalog, market catalog, price observations as of Day 6).
