#!/bin/bash

# Firebase Configuration Check Script
# This script verifies that Firebase configuration files are properly set up

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔍 Checking Firebase Configuration..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ANDROID_CONFIG="${PROJECT_ROOT}/android/app/google-services.json"
IOS_CONFIG="${PROJECT_ROOT}/ios/Runner/GoogleService-Info.plist"

ERRORS=0
WARNINGS=0

# Check Android configuration
echo "📱 Checking Android Configuration..."
if [ -f "$ANDROID_CONFIG" ]; then
    echo -e "${GREEN}✅ google-services.json found${NC}"
    
    # Check if it's not a template
    if grep -q "YOUR_PROJECT_NUMBER" "$ANDROID_CONFIG"; then
        echo -e "${RED}❌ google-services.json contains placeholder values${NC}"
        echo -e "   Please download the real file from Firebase Console"
        ERRORS=$((ERRORS + 1))
    else
        # Check package name
        PACKAGE_NAME=$(grep -o '"package_name"[[:space:]]*:[[:space:]]*"[^"]*"' "$ANDROID_CONFIG" | head -1 | sed 's/.*: *"\(.*\)".*/\1/')
        if [ "$PACKAGE_NAME" = "com.yourcompany.agrolink" ]; then
            echo -e "${GREEN}✅ Package name is correct: $PACKAGE_NAME${NC}"
        else
            echo -e "${YELLOW}⚠️  Package name: $PACKAGE_NAME${NC}"
            echo -e "   Expected: com.yourcompany.agrolink"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
else
    echo -e "${RED}❌ google-services.json NOT found${NC}"
    echo -e "   Expected location: $ANDROID_CONFIG"
    echo -e "   See FIREBASE_SETUP.md for instructions"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Check iOS configuration
echo "🍎 Checking iOS Configuration..."
if [ -f "$IOS_CONFIG" ]; then
    echo -e "${GREEN}✅ GoogleService-Info.plist found${NC}"
    
    # Check if it's not a template
    if grep -q "YOUR_API_KEY" "$IOS_CONFIG"; then
        echo -e "${RED}❌ GoogleService-Info.plist contains placeholder values${NC}"
        echo -e "   Please download the real file from Firebase Console"
        ERRORS=$((ERRORS + 1))
    else
        # Check bundle ID
        BUNDLE_ID=$(grep -A 1 "BUNDLE_ID" "$IOS_CONFIG" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')
        if [ "$BUNDLE_ID" = "com.yourcompany.agrolink" ]; then
            echo -e "${GREEN}✅ Bundle ID is correct: $BUNDLE_ID${NC}"
        else
            echo -e "${YELLOW}⚠️  Bundle ID: $BUNDLE_ID${NC}"
            echo -e "   Expected: com.yourcompany.agrolink"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
else
    echo -e "${RED}❌ GoogleService-Info.plist NOT found${NC}"
    echo -e "   Expected location: $IOS_CONFIG"
    echo -e "   See FIREBASE_SETUP.md for instructions"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Check .gitignore
echo "🔒 Checking .gitignore..."
GITIGNORE="${PROJECT_ROOT}/.gitignore"
if grep -q "google-services.json" "$GITIGNORE" && grep -q "GoogleService-Info.plist" "$GITIGNORE"; then
    echo -e "${GREEN}✅ Firebase files are in .gitignore${NC}"
else
    echo -e "${YELLOW}⚠️  Firebase files may not be properly excluded from git${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ All Firebase configuration checks passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Run: flutter pub get"
    echo "2. Run: flutter run"
    echo "3. Check console for Firebase initialization messages"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Configuration complete with $WARNINGS warning(s)${NC}"
    echo ""
    echo "You can proceed, but please review the warnings above."
    exit 0
else
    echo -e "${RED}❌ Configuration incomplete: $ERRORS error(s), $WARNINGS warning(s)${NC}"
    echo ""
    echo "Please fix the errors above before running the app."
    echo "See FIREBASE_SETUP.md for detailed instructions."
    exit 1
fi
