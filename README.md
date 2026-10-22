# AgriLink 🌾

**Digital Market Intelligence & Agricultural Value-Chain Platform**  
*Jimma Zone, Oromia Regional State, Ethiopia*

[![Flutter](https://img.shields.io/badge/Flutter-3.10.1+-02569B?logo=flutter)](https://flutter.dev)
[![NestJS](https://img.shields.io/badge/NestJS-Node.js_20+-E0234E?logo=nestjs)](https://nestjs.com)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?logo=mysql)](https://www.mysql.com)
[![License](https://img.shields.io/badge/License-Proprietary-red)](#license)

AgriLink is a mobile-first decision-intelligence platform connecting smallholder farmers (*Qotee Bulaa*), buyers (*Daldalaa*), transporters (*Geessaa*), and agriculture officials across Jimma Zone. Its flagship engine, **"Where Should I Sell?"**, calculates net revenue by factoring in market prices, transport tariffs, and route checkpoint fees across regional trade hubs.

---

## ⚡ Core Features

- **"Where Should I Sell?" Engine:** Net-revenue optimization ($Price \times Qty - Transport - Fees$).
- **Market Intelligence:** Live price tracking and freshness trends across Jimma Town, Nekemte, and Agaro.
- **Logistics & Matching:** Direct connection with verified buyers, cooperatives, and local transporters.
- **Offline-First & Localized:** Multi-language UI (Afaan Oromoo, Amharic, English) backed by local storage.

---

## 🏗️ Architecture
agrilink/
├── apps/
│   ├── api/             # NestJS backend API (Node.js 20+, MySQL)
│   └── web/             # Next.js web application
└── lib/                 # Flutter mobile application
├── core/            # Localization (om, am, en), themes, shared widgets
│   └── widgets/     # Reusable UI components (see Component Usage Guide)
└── features/        # Home, Market Intel, Marketplace, Orders, Profile


---

## 🎨 UI Components & Design System

AgriLink follows the **Agricultural Earth-Tone Design System** with reusable components:

### Available Components
- **AgriButton** - Primary, secondary, and text button variants
- **DashboardCard** - Cards for dashboard items with icons and subtitles
- **ActionCard** - Highlighted action cards for primary user tasks
- **StatisticCard** - Metric cards with trend indicators
- **AgriTextField** - Form inputs with validation
- **AgriDropdown** - Dropdown selectors with validation
- **RoleBadge** - Role-specific color-coded badges

### Component Examples & Demo

All components include usage examples and comprehensive documentation:

```dart
// View all components in action
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ComponentsDemoScreen(),
  ),
);
```

**Documentation:**
- **Component Usage Guide:** `lib/core/widgets/COMPONENT_USAGE_GUIDE.md`
- **Example Files:** Each component has a corresponding `*_example.dart` file
- **Demo Screen:** `lib/core/widgets/components_demo_screen.dart`

---

## 🚀 Quick Start

### 1. Backend & Web Services

```bash
# Option A: Run everything with Docker
docker compose up --build

# Option B: Run API manually (requires Node 20+ & MySQL 8)
cd apps/api
cp .env.example .env
npm install
npm run start:dev
# Health check: http://localhost:3001/api/v1/health

# Run Web App
cd ../web
npm install
npm run dev
# App URL: http://localhost:3000
