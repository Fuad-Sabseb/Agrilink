<<<<<<< HEAD
# AgriLink 🌾

**Digital Market Intelligence & Agricultural Value-Chain Platform**  
*For Jimma Zone, Oromia Regional State, Ethiopia*

![Flutter](https://img.shields.io/badge/Flutter-3.10.1+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-Proprietary-red)
![Phase](https://img.shields.io/badge/Phase-2_Complete-success)

---

## 📖 About AgriLink

AgriLink is a mobile-first agricultural platform connecting **smallholder farmers** in Jimma Zone with real-time market intelligence, verified buyers, logistics providers, and agricultural services. 

Rather than functioning as a simple listings marketplace, AgriLink is designed as a **decision-intelligence system**: it tells a farmer not just what a crop is worth, but **where selling it will generate the greatest net return** once transport and logistics costs are factored in.

### Key Features (Planned)

🎯 **"Where Should I Sell?"** - Net-revenue calculator with transport-aware pricing  
📊 **Market Intelligence** - Real-time price tracking across Jimma Zone markets  
🤝 **Buyer Marketplace** - Connect with verified buyers and post demand  
🚚 **AgriLogistics** - Match transporters with shipment requests  
🌐 **Multi-Language** - Afaan Oromoo, Amharic, and English support  

### Target Users

- **Qotee Bulaa (Farmers)** - Smallholder producers of coffee, maize, teff, wheat, potato
- **Daldalaa (Buyers)** - Wholesalers, processors, retailers, cooperatives, exporters
- **Geessaa (Transporters)** - Truck and pickup owner-operators
- **Biiroo Qonnaa (Bureau Officers)** - Zonal agriculture bureau staff

---

## 🚀 Current Status: Phase 2 Complete ✅

**Delivered:** October 6, 2026  
**Version:** 0.2.0 (Core Features)

### What's Working Now

✅ **Module 1: Farmer & Farm Registry**
   - Farmer profile management
   - Farm registration with GPS coordinates
   - Crop plot tracking (hectares, planting/harvest dates)
   - Farm management UI (add, edit, view)

✅ **Module 2: Market Intelligence**
   - 3 markets: Jimma Town, Nekemte (150km), Agaro (55km)
   - Real-time price tracking (30+ prices across 5 crops)
   - Price freshness indicators (24h, 48h, 7 days)
   - Price trend analysis (increasing, stable, decreasing)

✅ **"Where Should I Sell?" Flagship Feature**
   - Net revenue calculator (Price × Qty - Transport - Fees)
   - Transport cost formula (base + per-ton-km)
   - Route-specific checkpoint fees
   - Ranked market recommendations
   - Revenue breakdown display

✅ **Complete Design System**
   - Emerald green theme matching Lao Agrolink
   - High-contrast, accessibility-first typography
   - Material 3 component theming

✅ **Multi-Language Support**
   - Afaan Oromoo (om) - Primary
   - Amharic (am) - Secondary
   - English (en) - Fallback

✅ **Navigation Shell**
   - 5-section bottom navigation
   - Home, Market Intelligence, Marketplace, Orders, Profile

✅ **Dashboard**
   - Dynamic role badge (Farmer/Buyer/Transporter/Bureau)
   - Woreda selector
   - Notification bell
   - Price carousel (5 commodities)
   - 2x4 action grid

✅ **Responsive Layout**
   - Optimized for entry-level Android devices
   - Portrait orientation
   - Touch targets 44px+

### What's Coming Next (Phase 2)

🔄 **State Management** - Provider + Hive local storage  
📡 **Backend Integration** - API layer and authentication  
🧮 **Market Intelligence** - Price comparison and net-revenue engine  
🏪 **Marketplace Features** - Buyer listings and demand posting  
📦 **Orders & Tracking** - Transaction history and logistics  

---

## 🏗️ Technical Architecture

### Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Flutter 3.10.1+ | Cross-platform mobile UI |
| **State Management** | Provider 6.1.1 | App-wide state |
| **Local Storage** | Hive 2.2.3 | Offline-first data |
| **Backend (Phase 2)** | NestJS (Node.js) | RESTful API |
| **Database (Phase 2)** | MySQL | Relational + geospatial |
| **Maps (Phase 2)** | Mapbox / OpenStreetMap | Distance & routing |

### Project Structure

```
lib/
├── core/                      # Shared infrastructure
│   ├── localization/         # om, am, en translations ✅
│   ├── navigation/           # Bottom nav shell ✅
│   ├── theme/                # Colors, typography, theme ✅
│   └── widgets/              # Reusable components ✅
├── features/                 # Feature modules
│   ├── home/                 # Dashboard ✅
│   ├── market/               # Market intelligence ⏳
│   ├── marketplace/          # Buyer-seller matching ⏳
│   ├── orders/               # Transaction tracking ⏳
│   └── profile/              # User settings ⏳
└── main.dart                 # App entry point ✅
```

---

## 🎨 Design Language

### Color Palette

**Primary:**  
🟢 Emerald Green: `#1E7E34`  
🟢 Forest Green: `#155724`  
🟢 Light Emerald: `#28A745`

**Accent:**  
🟡 Gold: `#FFC107`  
🟠 Amber: `#FFB300`

**Background:**  
⚪ Soft Slate: `#F4F6F8`  
⚪ White Surface: `#FFFFFF`

### Typography

**Font:** Noto Sans (via Google Fonts)  
**Scale:** Display (32sp) → Headline (22sp) → Title (16sp) → Body (14sp) → Label (12sp)  
**Weights:** Regular (400), Medium (500), SemiBold (600), Bold (700)

### Design Reference

AgriLink matches the UI/UX pattern of **Lao Agrolink** (com.aidc.argolink):
- Clean emerald green agricultural theme
- Role-based dynamic dashboard
- Action grid with colored icon containers
- Transport-aware price intelligence

---

## 📱 Getting Started

### Prerequisites

- Flutter 3.10.1 or higher
- Dart 3.0 or higher
- Android Studio / Xcode
- Git

### Installation

```bash
# Clone repository
git clone https://github.com/yourusername/agrolink.git
cd agrolink

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Or run on specific device
flutter run -d <device-id>
```

### First Time Setup

1. **Check Flutter version:**
   ```bash
   flutter --version
   # Should be 3.10.1 or higher
   ```

2. **Configure Firebase (Phase 3 - Required for notifications):**
   ```bash
   # See detailed instructions in FIREBASE_SETUP.md
   # Quick check:
   ./scripts/check_firebase_config.sh
   ```
   
   **Note:** Firebase configuration is required for Phase 3 features (push notifications and location services). For Phase 1-2 features, you can skip this step.

3. **List available devices:**
   ```bash
   flutter devices
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

5. **Change language (optional):**
   - Edit `lib/main.dart`
   - Change `locale: const Locale('om')` to `'am'` or `'en'`
   - Hot restart: Press `R` in terminal

---

## 📚 Documentation

| Document | Description | Lines |
|----------|-------------|-------|
| [FIREBASE_SETUP.md](./FIREBASE_SETUP.md) | Firebase configuration guide | 400+ |
| [PHASE1_COMPLETE.md](./PHASE1_COMPLETE.md) | Technical specifications | 529 |
| [QUICK_START.md](./QUICK_START.md) | Developer quick start guide | 355 |
| [PHASE1_DELIVERY_REPORT.md](./PHASE1_DELIVERY_REPORT.md) | Delivery report | 900+ |
| [assets/ASSETS_GUIDE.md](./assets/ASSETS_GUIDE.md) | Asset requirements | 400+ |

---

## 🧪 Testing

### Manual Testing Checklist

```bash
✓ Test bottom navigation (all 5 sections)
✓ Test dashboard header (role badge, woreda selector, notifications)
✓ Test price carousel (horizontal scroll)
✓ Test action grid (tap all 8 items)
✓ Test language switching (modify main.dart, restart)
✓ Test responsive layout (different screen sizes)
```

### Run Tests (Future)

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter drive --target=test_driver/app.dart
```

---

## � Building for Release

### Android APK

```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK (for distribution)
flutter build apk --release

# App Bundle (for Google Play)
flutter build appbundle --release
```

### iOS IPA

```bash
# Release build
flutter build ios --release

# Open in Xcode for signing
open ios/Runner.xcworkspace
```

---

## 🌍 Localization

### Supported Languages

| Language | Code | Status | Native Name |
|----------|------|--------|-------------|
| Afaan Oromoo | `om` | ✅ Primary | Afaan Oromoo |
| Amharic | `am` | ✅ Full | አማርኛ |
| English | `en` | ✅ Fallback | English |

### Adding Translations

Edit `lib/core/localization/app_localizations.dart`:

```dart
// Add to _om map (Afaan Oromoo)
'my_key': 'Afaan Oromoo Translation',

// Add to _am map (Amharic)
'my_key': 'የአማርኛ ትርጉም',

// Add to _en map (English)
'my_key': 'English Translation',

// Use in code
Text(AppLocalizations.of(context).translate('my_key'))
```

---

## 🤝 Contributing

### Development Workflow

1. **Create feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make changes and commit:**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

3. **Push and create PR:**
   ```bash
   git push origin feature/your-feature-name
   ```

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter format lib/` before committing
- Run `flutter analyze` to check for issues
- Add comments for complex logic
- Keep files under 500 lines

---

## 📦 Dependencies

### Core Dependencies

```yaml
flutter_localizations: SDK
google_fonts: ^6.2.1
provider: ^6.1.1
shared_preferences: ^2.2.2
hive: ^2.2.3
hive_flutter: ^1.1.0
intl: ^0.20.2
uuid: ^4.5.3
```

### Dev Dependencies

```yaml
flutter_lints: ^6.0.0
hive_generator: ^2.0.1
build_runner: ^2.4.13
```

---

## 🎯 Roadmap

### Phase 1: Foundation ✅ (Completed Jan 7, 2025)
- [x] Theme system (Lao Agrolink design language)
- [x] Multi-language support (om, am, en)
- [x] Navigation shell (5 sections)
- [x] Dashboard with action grid
- [x] Responsive layout

### Phase 2: Core Features (Jan 10-31, 2025)
- [ ] State management (Provider + Hive)
- [ ] Market Intelligence module
- [ ] "Where Should I Sell?" calculator
- [ ] Marketplace module (buyer listings)
- [ ] Orders & tracking

### Phase 3: Pilot (Feb 2025)
- [ ] Backend API integration
- [ ] Authentication & user profiles
- [ ] Real price data ingestion
- [ ] Jimma Zone pilot deployment
- [ ] 500+ farmer onboarding

### Phase 4: Scale (Mar 2025+)
- [ ] Expand to adjacent zones
- [ ] Financial services integration
- [ ] AgriAI conversational assistant
- [ ] Oromia-wide rollout

---

## � Project Metrics

### Code Statistics (Phase 1)

| Metric | Value |
|--------|-------|
| Production Code | 2,614 lines |
| Documentation | 1,784 lines |
| Total Files | 17 Dart files |
| Test Coverage | TBD (Phase 2) |
| Languages | 3 (om, am, en) |
| Translations | 50+ keys |

### Performance Targets

- Launch time: <3 seconds (cold start)
- Frame rate: 60 FPS (smooth scrolling)
- APK size: <25 MB (release build)
- Memory usage: <200 MB (entry-level devices)

---

## 🐛 Known Issues

### Phase 1 Limitations (By Design)

1. **Mock Data Only** - All prices and activity are hardcoded (Phase 2)
2. **No Backend** - No authentication or data sync (Phase 2)
3. **Limited Interactions** - Most buttons show "Coming soon" (Phase 2)
4. **No Persistent State** - Settings not saved (Phase 2)
5. **Placeholder Screens** - 4/5 navigation screens incomplete (Phase 2)

These are **intentional scope boundaries** for Phase 1.

---

## � License

**Proprietary Software**

Copyright © 2025 AgriLink Development Team. All rights reserved.

This software is the property of the AgriLink project team and the Oromia Agriculture Bureau. Unauthorized copying, distribution, or use is strictly prohibited.

---

## 👥 Team

**Developer:** Fuad Sabseb (Software Engineering)  
**Project:** AgriLink  
**Target Region:** Jimma Zone, Oromia Regional State, Ethiopia

---

## 📞 Contact & Support

**Technical Questions:**  
📧 Email: [developer email]  
💬 Slack: [workspace link]

**Project Management:**  
📧 Email: [PM email]  
📅 Meeting: [calendar link]

**Documentation:**  
📖 Docs: See `docs/` directory  
🎓 Training: [training materials link]

---

## 🙏 Acknowledgments

### Research & Design Inspiration
- **Lao Agrolink** - UI/UX design reference
- **Ethiopian Commodity Exchange (ECX)** - Price data model
- **OpenAgriNet Initiative** - Digital agriculture infrastructure
- **8028 Farmer Hotline** - IVR/SMS pattern reference

### Open Source Tools
- Flutter by Google
- Noto Sans font by Google Fonts
- Material Icons by Google
- Hive by Isar
- Provider by Remi Rousselet

---

## 📈 Success Metrics (Planned)

### Pilot Phase (Phase 3)
- 500+ registered farmers
- 50+ verified buyers/transporters
- 300+ facilitated transactions
- Measurable net revenue uplift vs. baseline

### Scale Phase (Phase 4+)
- Oromia-wide coverage
- 10,000+ active users
- Integration with OpenAgriNet
- Partnership with cooperatives and financial services

---

## 🔗 Quick Links

- [Project Proposal](./AgriLink.pdf) - Original project specification
- [Phase 1 Complete](./PHASE1_COMPLETE.md) - Technical deep-dive
- [Quick Start Guide](./QUICK_START.md) - Developer setup
- [Delivery Report](./PHASE1_DELIVERY_REPORT.md) - Phase 1 sign-off
- [Assets Guide](./assets/ASSETS_GUIDE.md) - Design asset requirements

---

<p align="center">
  <strong>AgriLink</strong><br>
  <em>Eessatti Gurguruu Qaba? (Where Should I Sell?)</em><br><br>
  🌾 Building digital infrastructure for smallholder farmers in Oromia 🌾
</p>

---

**Last Updated:** January 7, 2025  
**Status:** Phase 1 Complete ✅ | Phase 2 Ready to Start 🚀
=======
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
>>>>>>> origin/main
