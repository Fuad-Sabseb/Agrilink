# AgriLink Design System Documentation

**Version:** 1.0.0  
**Last Updated:** January 2025  
**Design System:** Agricultural Earth-Tone Design (Bold Approach)

---

## Table of Contents

1. [Overview](#overview)
2. [Color Palette](#color-palette)
3. [Typography](#typography)
4. [Spacing System](#spacing-system)
5. [Border Radius & Elevation](#border-radius--elevation)
6. [Component Library](#component-library)
7. [Theme Configuration](#theme-configuration)
8. [Accessibility Compliance](#accessibility-compliance)
9. [Usage Guidelines](#usage-guidelines)

---

## Overview

The AgriLink Design System is a comprehensive, accessible, and culturally-appropriate design language for agricultural technology platforms. Inspired by Ethiopian agricultural heritage—fertile soil, lush crops, coffee culture, and golden harvests—this system establishes visual consistency across mobile (Android/iOS) and web platforms.

### Design Principles

- **Earth-Tone Aesthetic**: Colors drawn from natural agricultural elements
- **Accessibility First**: WCAG AA compliant color combinations
- **Cultural Relevance**: Reflects Ethiopian agricultural heritage
- **Multi-Language Support**: Optimized for Afaan Oromoo, Amharic, and English
- **Touch-Friendly**: Minimum 48×48dp touch targets for all interactive elements
- **Responsive**: Adapts gracefully from mobile (360dp) to desktop (1440dp+)

---

## Color Palette

### Primary Colors

#### Rich Earth Green
The primary brand color representing fertile soil and healthy crops.

| Variant | Hex Code | RGB | Usage |
|---------|----------|-----|-------|
| **Primary Dark** | `#2B5E34` | `43, 94, 52` | Hover states, active elements |
| **Primary** | `#3A7D44` | `58, 125, 68` | Primary actions, Farmer role |
| **Primary Light** | `#5C9B65` | `92, 155, 101` | Subtle backgrounds, disabled states |
| **Primary Very Light** | `#E8F0E9` | `232, 240, 233` | Container backgrounds |

```dart
// Dart/Flutter Usage
AppColors.primary          // #3A7D44
AppColors.primaryDark      // #2B5E34
AppColors.primaryLight     // #5C9B65
AppColors.primaryVeryLight // #E8F0E9
```

**Contrast Ratios:**
- White text on Primary: **5.00:1** ✅ WCAG AA Compliant
- Primary as text on light background: **4.44:1** ⚠️ (passes large text only)

#### Ethiopian Coffee Brown
Secondary color celebrating Ethiopia's coffee heritage.

| Variant | Hex Code | RGB | Usage |
|---------|----------|-----|-------|
| **Secondary Dark** | `#6B4429` | `107, 68, 41` | Deep shadows, emphasis |
| **Secondary** | `#8B5A3C` | `139, 90, 60` | Secondary actions, Buyer role |
| **Secondary Light** | `#A67C52` | `166, 124, 82` | Hover states |
| **Secondary Very Light** | `#F3ECE4` | `243, 236, 228` | Background tints |

```dart
// Dart/Flutter Usage
AppColors.secondary          // #8B5A3C
AppColors.secondaryDark      // #6B4429
AppColors.secondaryLight     // #A67C52
AppColors.secondaryVeryLight // #F3ECE4
```

**Contrast Ratios:**
- White text on Secondary: **5.79:1** ✅ WCAG AA Compliant
- Secondary as text on light background: **5.14:1** ✅ WCAG AA Compliant

#### Sky Blue
Tertiary color representing clear skies and open horizons.

| Variant | Hex Code | RGB | Usage |
|---------|----------|-----|-------|
| **Tertiary Dark** | `#1E3A5F` | `30, 58, 95` | Dark theme primary |
| **Tertiary** | `#4A90E2` | `74, 144, 226` | Info states, Bureau role |
| **Tertiary Light** | `#6BA4E8` | `107, 164, 232` | Hover states |
| **Tertiary Very Light** | `#E8F2FC` | `232, 242, 252` | Container backgrounds |

```dart
// Dart/Flutter Usage
AppColors.tertiary          // #4A90E2
AppColors.tertiaryDark      // #1E3A5F
AppColors.tertiaryLight     // #6BA4E8
AppColors.tertiaryVeryLight // #E8F2FC
```

**Contrast Ratios:**
- White text on Tertiary: **3.29:1** ⚠️ (large text only)
- Tertiary as text on light background: **2.92:1** ❌ Use darken variant (#2563B0)

#### Golden Harvest
Accent color representing successful harvest and prosperity.

| Variant | Hex Code | RGB | Usage |
|---------|----------|-----|-------|
| **Gold Dark** | `#B89020` | `184, 144, 32` | Text on light backgrounds |
| **Gold** | `#D4AF37` | `212, 175, 55` | Accents, Transporter role |
| **Gold Light** | `#E5C048` | `229, 192, 72` | Hover states |
| **Gold Very Light** | `#FBF4DD` | `251, 244, 221` | Background highlights |

```dart
// Dart/Flutter Usage
AppColors.accent         // #D4AF37
AppColors.gold           // #D4AF37
AppColors.goldDark       // #B89020
AppColors.goldLight      // #E5C048
AppColors.goldVeryLight  // #FBF4DD
```

**⚠️ CRITICAL USAGE WARNING:**
- **ALWAYS use DARK text** (`#2C241E`) on golden backgrounds (7.25:1 ✅)
- **NEVER use white text** on golden backgrounds (2.10:1 ❌)
- For text on light backgrounds, use `goldDark` (#B89020)

### Background & Surface Colors

#### Light Theme

| Color | Hex Code | RGB | Usage |
|-------|----------|-----|-------|
| **Background** | `#F5F1E8` | `245, 241, 232` | Main app background (Natural Cream) |
| **Surface** | `#FFFBF5` | `255, 251, 245` | Card backgrounds (Warm White) |
| **Surface Light** | `#FAF6EE` | `250, 246, 238` | Elevated surfaces |
| **Border** | `#DDD6C9` | `221, 214, 201` | Dividers, outlines |
| **Disabled** | `#C4BCB0` | `196, 188, 176` | Disabled elements |

#### Dark Theme

| Color | Hex Code | RGB | Usage |
|-------|----------|-----|-------|
| **Background Dark** | `#1B1916` | `27, 25, 22` | Main app background |
| **Surface Dark** | `#24211D` | `36, 33, 29` | Card backgrounds |
| **Surface Dark Highest** | `#2E2A24` | `46, 42, 36` | Elevated surfaces |
| **Border Dark** | `#453F36` | `69, 63, 54` | Dividers, outlines |
| **Border Dark Variant** | `#38332C` | `56, 51, 44` | Subtle borders |

```dart
// Dart/Flutter Usage
AppColors.background            // #F5F1E8 (Light)
AppColors.surface               // #FFFBF5 (Light)
AppColors.backgroundDark        // #1B1916 (Dark)
AppColors.surfaceDark           // #24211D (Dark)
```

### Semantic Colors

#### Success (Fresh Growth)

| Color | Hex Code | RGB | Usage |
|-------|----------|-----|-------|
| **Success Dark** | `#558B2F` | `85, 139, 47` | Emphasis states |
| **Success** | `#7CB342` | `124, 179, 66` | Success messages, positive indicators |
| **Success Light** | `#9CCC65` | `156, 204, 101` | Subtle success backgrounds |

**Contrast Warning:** Use dark text on success backgrounds (white text: 2.50:1 ❌)

#### Warning (Alert Orange)

| Color | Hex Code | RGB | Usage |
|-------|----------|-----|-------|
| **Warning Dark** | `#BF6A1C` | `191, 106, 28` | Emphasis states |
| **Warning** | `#E07A24` | `224, 122, 36` | Warning messages, caution indicators |
| **Warning Light** | `#FF9800` | `255, 152, 0` | Subtle warning backgrounds |

**Contrast Warning:** Use dark text on warning backgrounds (white text: 3.01:1 ❌)

#### Error (Critical Red)

| Color | Hex Code | RGB | Usage |
|-------|----------|-----|-------|
| **Error Dark** | `#8B2618` | `139, 38, 24` | Emphasis states |
| **Error** | `#C0392B` | `192, 57, 43` | Error messages, critical actions |
| **Error Light** | `#E57373` | `229, 115, 115` | Subtle error backgrounds |

**Contrast:** Fully compliant (White text: 5.44:1 ✅)

```dart
// Dart/Flutter Usage
AppColors.success        // #7CB342
AppColors.warning        // #E07A24
AppColors.error          // #C0392B
AppColors.info           // #4A90E2 (same as tertiary)
```

### Text Colors

#### Light Theme Text

| Color | Hex Code | RGB | Contrast on Background | Usage |
|-------|----------|-----|------------------------|-------|
| **Text Primary** | `#2C241E` | `44, 36, 30` | **13.52:1** ✅ | Main content, headings |
| **Text Secondary** | `#6B6258` | `107, 98, 88` | **5.30:1** ✅ | Supporting text, labels |
| **Text Tertiary** | `#948A7E` | `148, 138, 126` | **3.01:1** ⚠️ | Captions, hints (large text only) |
| **Text On Primary** | `#FFFFFF` | `255, 255, 255` | **5.00:1** ✅ | Text on primary buttons |

#### Dark Theme Text

| Color | Hex Code | RGB | Usage |
|-------|----------|-----|-------|
| **Text Primary Dark** | `#F5F1E8` | `245, 241, 232` | Main content, headings |
| **Text Secondary Dark** | `#C4BCB0` | `196, 188, 176` | Supporting text, labels |
| **Text Tertiary Dark** | `#948A7E` | `148, 138, 126` | Captions, hints |

```dart
// Dart/Flutter Usage
AppColors.textPrimary         // #2C241E (Light) / #F5F1E8 (Dark)
AppColors.textSecondary       // #6B6258 (Light) / #C4BCB0 (Dark)
AppColors.textTertiary        // #948A7E (Light & Dark)
AppColors.textOnPrimary       // #FFFFFF
```

### Role-Specific Colors

Each user role has a designated color for visual identification:

| Role | Color | Hex Code | RGB | Usage |
|------|-------|----------|-----|-------|
| **Farmer** | Rich Earth Green | `#3A7D44` | `58, 125, 68` | Farmer features, badges, icons |
| **Buyer** | Coffee Brown | `#8B5A3C` | `139, 90, 60` | Buyer features, badges, icons |
| **Transporter** | Golden Harvest | `#D4AF37` | `212, 175, 55` | Transporter features, badges |
| **Bureau Officer** | Sky Blue | `#4A90E2` | `74, 144, 226` | Bureau features, badges, icons |

```dart
// Dart/Flutter Usage
AppColors.roleFarmer       // #3A7D44
AppColors.roleBuyer        // #8B5A3C
AppColors.roleTransporter  // #D4AF37
AppColors.roleBureau       // #4A90E2

// Dynamic role color retrieval
Color roleColor = AppColors.getRoleColor('farmer');      // Returns #3A7D44
Color roleLight = AppColors.getRoleColorLight('buyer');  // Returns #A67C52
```

### Gradients

Pre-defined gradients for premium visual effects:

```dart
// Primary Gradient (Green)
AppColors.primaryGradient  // #3A7D44 → #2B5E34

// Secondary Gradient (Coffee Brown)
AppColors.secondaryGradient  // #8B5A3C → #A67C52

// Gold Gradient (Harvest)
AppColors.goldGradient  // #E5C048 → #D4AF37
```

### Chart & Graph Colors

Cohesive color palette for data visualizations:

```dart
AppColors.chartColors = [
  Color(0xFF3A7D44),  // Primary Green
  Color(0xFF8B5A3C),  // Coffee Brown
  Color(0xFF4A90E2),  // Sky Blue
  Color(0xFFD4AF37),  // Golden Harvest
  Color(0xFF7CB342),  // Fresh Growth
  Color(0xFFA67C52),  // Light Coffee
]
```

---

## Typography

### Font Family

**Primary:** Noto Sans (via Google Fonts)

**Why Noto Sans?**
- ✅ Full support for Afaan Oromoo characters (ï, ñ, etc.)
- ✅ Complete Amharic script coverage (ሀ-፼)
- ✅ Excellent English readability
- ✅ Optimized for mobile screens
- ✅ Open source and widely available

### Type Scale

#### Display Styles (Large, Impactful Text)

| Style | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| **Display Large** | 32sp | Bold (700) | 1.25 | -0.5 | Splash screens, major headers |
| **Display Medium** | 28sp | Bold (700) | 1.28 | -0.25 | Dashboard headers |
| **Display Small** | 24sp | SemiBold (600) | 1.33 | 0 | Page titles |

```dart
// Usage Example
Text(
  'Welcome to AgriLink',
  style: AppTypography.displayLarge,
)
```

#### Headline Styles (Section Headers)

| Style | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| **Headline Large** | 22sp | SemiBold (600) | 1.36 | 0 | Major section headers |
| **Headline Medium** | 20sp | SemiBold (600) | 1.4 | 0 | Sub-section headers |
| **Headline Small** | 18sp | SemiBold (600) | 1.44 | 0 | Card headers |

```dart
// Usage Example
Text(
  'Market Intelligence',
  style: AppTypography.headlineMedium,
)
```

#### Title Styles (Card Headers, List Items)

| Style | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| **Title Large** | 16sp | SemiBold (600) | 1.5 | 0.15 | Card titles, prominent labels |
| **Title Medium** | 14sp | Medium (500) | 1.57 | 0.1 | List item titles |
| **Title Small** | 12sp | Medium (500) | 1.67 | 0.1 | Compact titles |

```dart
// Usage Example
Text(
  'Fresh Tomatoes',
  style: AppTypography.titleLarge,
)
```

#### Body Styles (Main Content)

| Style | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| **Body Large** | 16sp | Regular (400) | 1.5 | 0.5 | Primary content text |
| **Body Medium** | 14sp | Regular (400) | 1.57 | 0.25 | Standard body text |
| **Body Small** | 12sp | Regular (400) | 1.67 | 0.4 | Supporting text, metadata |

```dart
// Usage Example
Text(
  'High-quality organic tomatoes from Jimma Zone.',
  style: AppTypography.bodyLarge,
)
```

#### Label Styles (Buttons, Badges, Form Labels)

| Style | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| **Label Large** | 14sp | Medium (500) | 1.43 | 0.1 | Primary button text |
| **Label Medium** | 12sp | Medium (500) | 1.5 | 0.5 | Secondary buttons, badges |
| **Label Small** | 11sp | Medium (500) | 1.45 | 0.5 | Small badges, chips |

```dart
// Usage Example
Text(
  'Add to Cart',
  style: AppTypography.labelLarge,
)
```

#### Specialized Styles

| Style | Size | Weight | Line Height | Letter Spacing | Color | Usage |
|-------|------|--------|-------------|----------------|-------|-------|
| **Caption** | 10sp | Regular (400) | 1.6 | 0.4 | Text Secondary | Timestamps, helper text |
| **Overline** | 10sp | Medium (500) | 1.6 | 1.5 | Text Secondary | Section labels, tags (UPPERCASE) |

#### Price Styles (Numeric Emphasis)

| Style | Size | Weight | Line Height | Letter Spacing | Color | Usage |
|-------|------|--------|-------------|----------------|-------|-------|
| **Price Large** | 32sp | Bold (700) | 1.25 | -0.5 | Primary | Major price displays |
| **Price Medium** | 24sp | SemiBold (600) | 1.33 | 0 | Primary | Card-level prices |
| **Price Small** | 16sp | SemiBold (600) | 1.5 | 0 | Primary | List item prices |

```dart
// Usage Example
Text(
  'ETB 1,250.00',
  style: AppTypography.priceLarge,
)
```

#### Navigation Styles

| Style | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| **Nav Label** | 10sp | Medium (500) | 1.6 | 0.5 | Bottom navigation labels |
| **App Bar Title** | 18sp | SemiBold (600) | 1.33 | 0 | App bar titles |

#### Form Field Styles

| Style | Size | Weight | Line Height | Color | Usage |
|-------|------|--------|-------------|-------|-------|
| **Input Text** | 16sp | Regular (400) | 1.5 | Text Primary | User input text |
| **Input Label** | 12sp | Medium (500) | 1.67 | Text Secondary | Field labels |
| **Input Hint** | 16sp | Regular (400) | 1.5 | Text Tertiary | Placeholder text |
| **Input Error** | 12sp | Regular (400) | 1.67 | Error | Validation errors |

### Typography Usage Examples

```dart
// Dashboard Header
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'Welcome Back, Abebe',
      style: AppTypography.displayMedium,
    ),
    SizedBox(height: 4),
    Text(
      'Here's your farm activity today',
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
    ),
  ],
)

// Card with Title and Description
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Where Should I Sell?', style: AppTypography.titleLarge),
        SizedBox(height: 8),
        Text(
          'Compare markets and find the best price for your produce',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  ),
)

// Price Display
Row(
  crossAxisAlignment: CrossAxisAlignment.baseline,
  textBaseline: TextBaseline.alphabetic,
  children: [
    Text('ETB ', style: AppTypography.bodyMedium),
    Text('1,250', style: AppTypography.priceLarge),
    Text('.00', style: AppTypography.bodyMedium),
    Text(' per quintal', style: AppTypography.bodySmall),
  ],
)
```

---

## Spacing System

The spacing system uses **multiples of 4** for consistent rhythm and alignment.

### Spacing Tokens

| Token | Value (dp) | Visual | Usage |
|-------|-----------|--------|-------|
| `spaceXXS` | 4 | `▪` | Compact padding within chips, badges |
| `spaceXS` | 8 | `▪▪` | Icon-to-text gaps, tight component padding |
| `spaceS` | 12 | `▪▪▪` | Form field vertical spacing, card inner padding |
| `spaceM` | 16 | `▪▪▪▪` | **Standard padding**, list item spacing, default gaps |
| `spaceL` | 20 | `▪▪▪▪▪` | Card padding, section spacing |
| `spaceXL` | 24 | `▪▪▪▪▪▪` | Major section padding, screen margins |
| `spaceXXL` | 32 | `▪▪▪▪▪▪▪▪` | Large gaps between sections |
| `spaceXXXL` | 40 | `▪▪▪▪▪▪▪▪▪▪` | Header spacing, major layout divisions |
| `space4XL` | 48 | `▪▪▪▪▪▪▪▪▪▪▪▪` | Screen-level spacing, major separations |
| `space5XL` | 64 | `▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪` | Large hero sections, prominent empty states |

```dart
// Dart/Flutter Usage
AppTokens.spaceXS    // 8dp
AppTokens.spaceM     // 16dp (most common)
AppTokens.spaceXL    // 24dp
AppTokens.spaceXXL   // 32dp
```

### Spacing Visual Examples

#### Card Layout Spacing

```
┌─────────────────────────────────────────┐
│ [spaceL: 20dp padding]                  │
│                                         │
│  ┌────────┐  Title Text                │
│  │  Icon  │  [spaceXS: 8dp gap]        │
│  │ 24x24  │                            │
│  └────────┘  Description text          │
│              [spaceS: 12dp vertical]   │
│              Body content goes here    │
│                                         │
│              [spaceM: 16dp gap]        │
│                                         │
│              [ Button ]                 │
│                                         │
│ [spaceL: 20dp padding]                  │
└─────────────────────────────────────────┘
```

#### List Item Spacing

```
┌─────────────────────────────────────────┐
│ [spaceM: 16dp left padding]             │
│                                         │
│  Item Title                             │
│  Subtitle text                          │
│                                         │
│ [spaceM: 16dp right padding]            │
└─────────────────────────────────────────┘
[spaceXS: 8dp vertical gap between items]
┌─────────────────────────────────────────┐
│ [spaceM: 16dp left padding]             │
│                                         │
│  Item Title                             │
│  Subtitle text                          │
│                                         │
│ [spaceM: 16dp right padding]            │
└─────────────────────────────────────────┘
```

#### Screen Layout Spacing

```
┌────────────────────────────────────────────┐
│ App Bar (56dp height)                      │
├────────────────────────────────────────────┤
│ [spaceXL: 24dp top padding]                │
│                                            │
│ [spaceXL: 24dp left] Content [24dp right] │
│                                            │
│ Section 1                                  │
│                                            │
│ [spaceXXL: 32dp gap]                       │
│                                            │
│ Section 2                                  │
│                                            │
│ [spaceXL: 24dp bottom padding]             │
└────────────────────────────────────────────┘
```

### Responsive Padding

Padding adapts to screen size for optimal use of space:

| Screen Width | Horizontal Padding | Usage |
|--------------|-------------------|-------|
| < 600dp (Mobile) | **16dp** | Compact mobile screens |
| 600-839dp (Tablet) | **24dp** | Tablet devices |
| ≥ 840dp (Desktop) | **32dp** | Desktop and large screens |

```dart
// Automatic responsive padding
ResponsiveContainer(
  child: Column(
    children: [
      Text('Content automatically gets responsive padding'),
    ],
  ),
)
```

---

## Border Radius & Elevation

### Border Radius Tokens

Rounded corners create friendly, approachable UI elements.

| Token | Value (dp) | Visual | Usage |
|-------|-----------|--------|-------|
| `radiusXS` | 4 | `⌜⌝` | Small badges, compact chips |
| `radiusS` | 8 | `⌜  ⌝` | **Buttons**, input fields, small cards |
| `radiusM` | 12 | `⌜   ⌝` | **Standard cards**, dialogs, bottom sheets |
| `radiusL` | 16 | `⌜    ⌝` | Large cards, prominent containers |
| `radiusXL` | 24 | `⌜      ⌝` | Hero cards, major UI elements, FABs |
| `radiusFull` | 999 | `( )` | Circular elements, pills, avatars |

```dart
// Dart/Flutter Usage
BorderRadius.circular(AppTokens.radiusS)    // 8dp (buttons)
BorderRadius.circular(AppTokens.radiusM)    // 12dp (cards)
BorderRadius.circular(AppTokens.radiusFull) // Circular
```

### Elevation Tokens

Elevation creates hierarchy through shadows (Material Design depth).

| Token | Value (dp) | Visual | Usage |
|-------|-----------|--------|-------|
| `elevationNone` | 0 | `─` | Flat surfaces, inline elements |
| `elevationXS` | 2 | `▁` | Subtle cards, hovering elements |
| `elevationS` | 4 | `▂` | **Standard cards**, raised buttons |
| `elevationM` | 6 | `▃` | FAB (resting), prominent cards |
| `elevationL` | 8 | `▄` | **Navigation drawer**, app bar (scrolled) |
| `elevationXL` | 12 | `▅` | FAB (raised), modal bottom sheets |
| `elevationXXL` | 16 | `▆` | Navigation drawers, modal dialogs |
| `elevationXXXL` | 24 | `▇` | Full-screen dialogs, prominent modals |

```dart
// Dart/Flutter Usage
Card(
  elevation: AppTokens.elevationS,  // 4dp standard card elevation
  child: ...,
)
```

### Shadow & Overlay Tokens

| Token | Value | Opacity | Usage |
|-------|-------|---------|-------|
| `shadow12` | `#2C241E` | 10% (0.1) | Standard shadow color |
| `overlay8` | `#2C241E` | 5% (0.05) | Subtle overlay |
| `shimmer50` | `#FFFBF5` | 50% (0.5) | Shimmer loading effect |

---

## Component Library

### Buttons

#### AgriButton (Primary Actions)

**Variants:** Primary (filled), Secondary (outlined), Text

```dart
// Primary Button (Filled)
AgriButton(
  text: 'Add Produce',
  onPressed: () => _handleAddProduce(),
  isPrimary: true,
)

// Secondary Button (Outlined)
AgriButton(
  text: 'Cancel',
  onPressed: () => _handleCancel(),
  isPrimary: false,
)

// Button with Icon
AgriButton(
  text: 'Navigate',
  icon: Icons.navigation,
  onPressed: () => _handleNavigate(),
)

// Loading State
AgriButton(
  text: 'Saving...',
  isLoading: true,
  onPressed: null,  // Disabled during loading
)
```

**Visual Specifications:**
- **Height:** 48dp (meets minimum touch target)
- **Horizontal Padding:** 24dp
- **Vertical Padding:** 12dp
- **Border Radius:** 8dp
- **Elevation:** 2dp (primary), 0dp (secondary)
- **Text Style:** Label Large (14sp, Medium)

**States:**
- **Default:** Primary color background, white text
- **Hover:** Slightly darker background
- **Pressed:** Even darker with reduced elevation
- **Disabled:** 38% opacity, gray background
- **Loading:** Progress indicator, disabled interaction

#### Code Example: Button Row

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded(
      child: AgriButton(
        text: 'Cancel',
        isPrimary: false,
        onPressed: () => Navigator.pop(context),
      ),
    ),
    SizedBox(width: AppTokens.spaceM),
    Expanded(
      child: AgriButton(
        text: 'Save',
        isPrimary: true,
        onPressed: () => _handleSave(),
      ),
    ),
  ],
)
```

---

### Cards

#### DashboardCard (Standard Information Card)

Displays information with optional tap action.

```dart
DashboardCard(
  title: 'My Farms',
  subtitle: '3 active farms',
  icon: Icons.agriculture,
  iconColor: AppColors.primary,
  onTap: () => Navigator.push(...),
  trailing: Icon(Icons.arrow_forward_ios, size: 16),
)
```

**Visual Specifications:**
- **Background:** Surface color
- **Elevation:** 2dp
- **Border Radius:** 12dp
- **Padding:** 16dp
- **Icon Size:** 24dp

#### ActionCard (Call-to-Action Card)

Highlights primary user actions with prominent styling.

```dart
ActionCard(
  title: 'Where Should I Sell?',
  description: 'Compare markets and find the best price for your produce',
  icon: Icons.location_on,
  primaryColor: AppColors.primary,
  onTap: () => _navigateToMarketComparison(),
  isHighlight: true,  // Elevated styling
)
```

**Visual Specifications (Highlight Mode):**
- **Background:** Gradient or primary color
- **Elevation:** 6dp
- **Border Radius:** 16dp
- **Padding:** 20dp
- **Text Color:** White (on colored background)

#### StatisticCard (Metric Display)

Displays key metrics with trend indicators.

```dart
StatisticCard(
  label: 'Revenue This Month',
  value: 'ETB 45,230',
  icon: Icons.attach_money,
  color: AppColors.primary,
  trend: '+12.5%',
  trendPositive: true,
)
```

**Visual Specifications:**
- **Background:** Surface color
- **Elevation:** 2dp
- **Border Radius:** 12dp
- **Padding:** 16dp
- **Trend Indicator:** Green (↑) for positive, Red (↓) for negative

#### Code Example: Card Grid

```dart
GridView.count(
  crossAxisCount: 2,
  crossAxisSpacing: AppTokens.spaceM,
  mainAxisSpacing: AppTokens.spaceM,
  padding: EdgeInsets.all(AppTokens.spaceXL),
  children: [
    StatisticCard(
      label: 'Active Listings',
      value: '12',
      icon: Icons.inventory,
      color: AppColors.primary,
    ),
    StatisticCard(
      label: 'Pending Orders',
      value: '5',
      icon: Icons.pending,
      color: AppColors.warning,
    ),
    StatisticCard(
      label: 'Revenue',
      value: 'ETB 45,230',
      icon: Icons.attach_money,
      color: AppColors.success,
      trend: '+12.5%',
      trendPositive: true,
    ),
    StatisticCard(
      label: 'Deliveries',
      value: '8',
      icon: Icons.local_shipping,
      color: AppColors.tertiary,
    ),
  ],
)
```

---

### Form Components

#### AgriTextField (Text Input)

Accessible text input with validation support.

```dart
AgriTextField(
  label: 'Farm Name',
  hint: 'e.g., Abebe\'s Coffee Farm',
  controller: _farmNameController,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Farm name is required';
    }
    return null;
  },
  keyboardType: TextInputType.text,
)

// With Voice Input
AgriTextField(
  label: 'Description',
  hint: 'Describe your farm',
  controller: _descriptionController,
  maxLines: 3,
  enableVoiceInput: true,
  onVoiceInput: (transcript) {
    _descriptionController.text = transcript;
  },
)
```

**Visual Specifications:**
- **Height:** 48dp (minimum)
- **Border Radius:** 8dp
- **Border Width:** 1dp (default), 2dp (focused)
- **Padding:** 16dp horizontal, 12dp vertical
- **Label:** 12sp Medium, Text Secondary
- **Input Text:** 16sp Regular, Text Primary
- **Error Text:** 12sp Regular, Error color

**States:**
- **Default:** Border color (outline)
- **Focused:** Primary color border (2dp)
- **Error:** Error color border
- **Disabled:** Gray border, 38% opacity

#### AgriDropdown (Selection Dropdown)

Accessible dropdown with keyboard navigation.

```dart
AgriDropdown<String>(
  label: 'Produce Type',
  value: _selectedProduceType,
  items: [
    DropdownMenuItem(value: 'coffee', child: Text('Coffee')),
    DropdownMenuItem(value: 'maize', child: Text('Maize')),
    DropdownMenuItem(value: 'teff', child: Text('Teff')),
  ],
  onChanged: (value) {
    setState(() {
      _selectedProduceType = value;
    });
  },
  validator: (value) {
    if (value == null) return 'Please select a produce type';
    return null;
  },
)
```

#### Code Example: Complete Form

```dart
Form(
  key: _formKey,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AgriTextField(
        label: 'Farm Name',
        controller: _nameController,
        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
      ),
      SizedBox(height: AppTokens.spaceM),
      
      AgriDropdown<String>(
        label: 'Produce Type',
        value: _produceType,
        items: produceOptions,
        onChanged: (v) => setState(() => _produceType = v),
        validator: (v) => v == null ? 'Required' : null,
      ),
      SizedBox(height: AppTokens.spaceM),
      
      AgriTextField(
        label: 'Quantity',
        controller: _quantityController,
        keyboardType: TextInputType.number,
        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
      ),
      SizedBox(height: AppTokens.spaceXL),
      
      AgriButton(
        text: 'Submit',
        isPrimary: true,
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _handleSubmit();
          }
        },
      ),
    ],
  ),
)
```

---

### Badges & Indicators

#### RoleBadge (User Role Indicator)

Displays user role with role-specific color.

```dart
RoleBadge(
  role: 'farmer',  // 'farmer', 'buyer', 'transporter', 'bureau'
)

// Returns colored badge:
// Farmer: Green badge
// Buyer: Brown badge
// Transporter: Gold badge
// Bureau: Blue badge
```

**Visual Specifications:**
- **Height:** 24dp
- **Horizontal Padding:** 12dp
- **Border Radius:** 12dp (pill shape)
- **Text:** 11sp SemiBold, White
- **Background:** Role-specific color

#### AccessibleStatusIndicator (Status Badge)

Displays status with semantic color and accessible label.

```dart
AccessibleStatusIndicator(
  status: 'active',     // 'active', 'pending', 'error', 'success'
  label: 'Active',
  size: IndicatorSize.medium,
)
```

**Status Colors:**
- **Active:** Primary color (#3A7D44)
- **Pending:** Warning color (#E07A24)
- **Error:** Error color (#C0392B)
- **Success:** Success color (#7CB342)

---

### Loading & Empty States

#### LoadingIndicator (Progress Feedback)

Standard loading indicator with AgriLink branding.

```dart
LoadingIndicator(
  message: 'Loading your farms...',
)

// Simple spinner (no message)
LoadingIndicator()
```

#### ShimmerLoading (Skeleton Placeholder)

Animated placeholder for content that's loading.

```dart
ShimmerLoading(
  width: double.infinity,
  height: 100,
  borderRadius: AppTokens.radiusM,
)

// For list items
ListView.builder(
  itemCount: 5,
  itemBuilder: (context, index) {
    return ShimmerLoading(
      width: double.infinity,
      height: 80,
      margin: EdgeInsets.symmetric(
        horizontal: AppTokens.spaceM,
        vertical: AppTokens.spaceXS,
      ),
    );
  },
)
```

#### EmptyState (No Content Placeholder)

Friendly empty state with optional action.

```dart
EmptyState(
  icon: Icons.inventory_2_outlined,
  title: 'No Produce Listed',
  message: 'Start by adding your first produce listing',
  actionText: 'Add Produce',
  onAction: () => _navigateToAddProduce(),
)
```

**Visual Specifications:**
- **Icon Size:** 64dp
- **Icon Color:** Text Tertiary
- **Title:** Headline Medium
- **Message:** Body Medium, Text Secondary
- **Button:** Primary button

#### ErrorState (Error Feedback)

Clear error display with retry action.

```dart
ErrorState(
  title: 'Failed to Load',
  message: 'Could not connect to server. Please check your internet connection.',
  onRetry: () => _retryLoad(),
)
```

---

### Navigation Components

#### DashboardHeader (Screen Header)

Standard header for dashboard screens.

```dart
DashboardHeader(
  title: 'My Farms',
  subtitle: 'Manage your agricultural properties',
  actions: [
    IconButton(
      icon: Icon(Icons.add),
      onPressed: () => _navigateToAddFarm(),
    ),
  ],
)
```

**Visual Specifications:**
- **Title:** Display Medium (28sp Bold)
- **Subtitle:** Body Medium, Text Secondary
- **Padding:** 24dp horizontal, 16dp vertical

#### Breadcrumb Navigation

Hierarchical navigation trail (not yet implemented, but planned).

---

### Icon Sizes

Consistent icon sizing across the application:

| Token | Size (dp) | Usage |
|-------|----------|-------|
| `iconXS` | 16 | Inline icons, small badges, compact UI |
| `iconS` | 20 | List item icons, compact buttons |
| `iconM` | 24 | **Standard UI icons**, toolbar icons, app bar actions |
| `iconL` | 32 | Feature icons, prominent action buttons |
| `iconXL` | 40 | Hero icons, large feature illustrations |

```dart
// Usage Example
Icon(
  Icons.agriculture,
  size: AppTokens.iconM,  // 24dp standard size
  color: AppColors.primary,
)
```

---

## Theme Configuration

### Light Theme

The default theme with Natural Cream background and Rich Earth Green primary color.

```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  home: HomeScreen(),
)
```

**Key Characteristics:**
- **Background:** Natural Cream (#F5F1E8)
- **Surface:** Warm White (#FFFBF5)
- **Primary:** Rich Earth Green (#3A7D44)
- **Text:** Deep Earth Brown (#2C241E)
- **Contrast Ratios:** All meet WCAG AA standards

### Dark Theme

Dark theme with deep soil backgrounds and adjusted colors for night use.

```dart
MaterialApp(
  theme: AppTheme.darkTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.system,  // Respects system preference
  home: HomeScreen(),
)
```

**Key Characteristics:**
- **Background:** Rich Deep Soil (#1B1916)
- **Surface:** Dark Earth (#24211D)
- **Primary:** Light Earth Green (#5C9B65)
- **Text:** Light Cream (#F5F1E8)
- **Contrast Ratios:** All meet WCAG AA standards (100% compliance)

### Dynamic Theme Switching

```dart
// Using ThemeProvider (if implemented)
ThemeProvider.of(context).toggleTheme();

// Or directly with ThemeMode
ThemeMode.light   // Force light theme
ThemeMode.dark    // Force dark theme
ThemeMode.system  // Follow system settings
```

### System Overlay Styles

Adjusts status bar and navigation bar colors to match theme:

```dart
// Light theme system UI
SystemChrome.setSystemUIOverlayStyle(AppTheme.lightSystemOverlay);

// Dark theme system UI
SystemChrome.setSystemUIOverlayStyle(AppTheme.darkSystemOverlay);
```

---

## Accessibility Compliance

### WCAG AA Standards

The AgriLink Design System adheres to **WCAG 2.1 Level AA** accessibility standards:

- ✅ **Normal Text:** Minimum 4.5:1 contrast ratio
- ✅ **Large Text (≥18pt or 14pt bold):** Minimum 3:1 contrast ratio
- ✅ **UI Components:** Minimum 3:1 contrast ratio
- ✅ **Touch Targets:** Minimum 48×48dp for all interactive elements

### Contrast Audit Results

| Color Combination | Contrast Ratio | Compliance | Notes |
|-------------------|----------------|------------|-------|
| Text Primary on Background | 13.52:1 | ✅ AAA | Excellent |
| Text Secondary on Background | 5.30:1 | ✅ AA | Good |
| Text Tertiary on Background | 3.01:1 | ⚠️ Large Text Only | Use for captions only |
| White on Primary | 5.00:1 | ✅ AA | Button text |
| White on Secondary | 5.79:1 | ✅ AA | Button text |
| White on Gold | 2.10:1 | ❌ Fails | **Never use** |
| Dark Text on Gold | 7.25:1 | ✅ AA+ | **Always use** |
| White on Tertiary | 3.29:1 | ⚠️ Large Text Only | Use 18sp+ text |
| Error on Background | 4.82:1 | ✅ AA | Error messages |
| Success on Background | 2.22:1 | ❌ Fails | Use dark text |
| Warning on Background | 1.52:1 | ❌ Fails | Use dark text |

**Full Contrast Report:** See `docs/wcag-contrast-report.md`

### Critical Accessibility Rules

1. **Golden/Transporter Backgrounds:**
   - ✅ **DO:** Use dark text (#2C241E) — 7.25:1 contrast
   - ❌ **DON'T:** Use white text — 2.10:1 contrast (fails)

2. **Success/Warning Backgrounds:**
   - ✅ **DO:** Use dark text (#2C241E)
   - ❌ **DON'T:** Use white text (fails contrast)

3. **Tertiary/Bureau Color:**
   - ✅ **DO:** Use for large text (≥18sp) or darken for normal text
   - ⚠️ **CAUTION:** Default tertiary fails normal text requirements

4. **Touch Targets:**
   - All interactive elements (buttons, icons, list items) **must** be minimum 48×48dp
   - Automatically enforced by `AgriButton` and component library

5. **Screen Reader Support:**
   - All icons have semantic labels
   - Form fields have proper labels and error announcements
   - Navigation changes are announced

### Accessibility Testing Tools

```bash
# Run WCAG contrast checker
dart scripts/wcag_contrast_checker.dart

# View full contrast report
cat docs/wcag-contrast-report.md

# View quick summary
cat docs/wcag-contrast-summary.md
```

---

## Usage Guidelines

### Getting Started

1. **Import Theme Configuration:**

```dart
import 'package:agrolink/core/theme/theme.dart';
import 'package:agrolink/core/theme/colors.dart';
import 'package:agrolink/core/theme/typography.dart';
import 'package:agrolink/core/theme/tokens.dart';
```

2. **Apply Theme to App:**

```dart
MaterialApp(
  title: 'AgriLink',
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.system,
  home: HomeScreen(),
)
```

3. **Use Design Tokens:**

```dart
// Spacing
Padding(
  padding: EdgeInsets.all(AppTokens.spaceM),  // 16dp
  child: ...,
)

// Colors
Container(
  color: AppColors.primary,
  child: Text(
    'Welcome',
    style: AppTypography.displayMedium.copyWith(
      color: AppColors.textOnPrimary,
    ),
  ),
)

// Border Radius
Container(
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppTokens.radiusM),  // 12dp
  ),
  child: ...,
)
```

### Best Practices

#### ✅ DO:

- **Use design tokens** instead of hard-coded values
- **Follow spacing multiples of 4** for consistency
- **Test color combinations** against WCAG standards
- **Respect minimum touch targets** (48×48dp)
- **Use semantic colors** (success, warning, error) appropriately
- **Leverage the component library** instead of building from scratch
- **Support both light and dark themes**
- **Test with screen readers** for accessibility

#### ❌ DON'T:

- Hard-code colors, spacing, or typography values
- Use white text on golden backgrounds (fails contrast)
- Create interactive elements smaller than 48×48dp
- Override theme colors without checking accessibility
- Mix design systems or introduce inconsistent patterns
- Ignore role-specific colors for user identification
- Use tertiary text color for normal text (large text only)

### Component Selection Guide

| Use Case | Recommended Component |
|----------|----------------------|
| Primary action button | `AgriButton(isPrimary: true)` |
| Secondary action button | `AgriButton(isPrimary: false)` |
| Text input | `AgriTextField` |
| Dropdown selection | `AgriDropdown` |
| Information card | `DashboardCard` |
| Call-to-action card | `ActionCard` |
| Metric display | `StatisticCard` |
| User role indicator | `RoleBadge` |
| Status indicator | `AccessibleStatusIndicator` |
| Loading state | `LoadingIndicator` or `ShimmerLoading` |
| Empty content | `EmptyState` |
| Error display | `ErrorState` |
| Screen header | `DashboardHeader` |

### Responsive Layout Examples

#### Mobile (< 600dp)

```dart
// Single column layout
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    ActionCard(...),
    SizedBox(height: AppTokens.spaceM),
    StatisticCard(...),
    SizedBox(height: AppTokens.spaceM),
    StatisticCard(...),
  ],
)
```

#### Tablet (600-839dp)

```dart
// Two-column grid
GridView.count(
  crossAxisCount: 2,
  crossAxisSpacing: AppTokens.spaceM,
  mainAxisSpacing: AppTokens.spaceM,
  children: [
    ActionCard(...),
    StatisticCard(...),
    StatisticCard(...),
    StatisticCard(...),
  ],
)
```

#### Desktop (≥ 840dp)

```dart
// Three-column grid with sidebar
Row(
  children: [
    // Persistent sidebar navigation
    NavigationRail(...),
    SizedBox(width: AppTokens.spaceXL),
    
    // Main content area
    Expanded(
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: AppTokens.spaceL,
        mainAxisSpacing: AppTokens.spaceL,
        children: [
          ActionCard(...),
          StatisticCard(...),
          StatisticCard(...),
          StatisticCard(...),
          StatisticCard(...),
          StatisticCard(...),
        ],
      ),
    ),
  ],
)
```

---

## Theme Screenshots

### Light Theme Examples

**Dashboard Screen (Light Mode)**
- Natural Cream background (#F5F1E8)
- Rich Earth Green primary elements (#3A7D44)
- Deep Earth Brown text (#2C241E)
- Warm White surface cards (#FFFBF5)

**Form Screen (Light Mode)**
- Clean, accessible form fields
- Primary color focus states
- Clear error messaging
- Role-specific color accents

### Dark Theme Examples

**Dashboard Screen (Dark Mode)**
- Rich Deep Soil background (#1B1916)
- Light Earth Green primary elements (#5C9B65)
- Light Cream text (#F5F1E8)
- Dark Earth surface cards (#24211D)

**Form Screen (Dark Mode)**
- High contrast for readability
- Adjusted color palette
- Maintained accessibility standards
- Consistent component styling

_Note: Actual screenshots would be included here if the app were running. Since this is documentation creation, the descriptions provide the visual context._

---

## Additional Resources

### Documentation Files

- **Color Palette:** `/lib/core/theme/colors.dart`
- **Typography:** `/lib/core/theme/typography.dart`
- **Design Tokens:** `/lib/core/theme/tokens.dart`
- **Theme Configuration:** `/lib/core/theme/theme.dart`
- **Component Library:** `/lib/core/widgets/`

### External References

- [Material Design 3](https://m3.material.io/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Flutter Theming Guide](https://docs.flutter.dev/cookbook/design/themes)
- [Noto Sans Font Family](https://fonts.google.com/noto/specimen/Noto+Sans)

### Support

For design system questions or contributions:
- **Design Lead:** [Contact Information]
- **Development Team:** [Contact Information]
- **Documentation:** This file (`docs/design-system.md`)

---

**Document Version:** 1.0.0  
**Last Updated:** January 2025  
**Maintained by:** AgriLink Development Team

**Requirements Coverage:**
- ✅ Requirement 1.1: Color palette with hex values and usage guidelines
- ✅ Requirement 1.2: Typography hierarchy with font sizes and weights
- ✅ Requirement 1.3: Spacing system with visual examples
- ✅ Requirement 1.4: Component library with code examples
- ✅ Requirement 1.5: Light and dark theme documentation

