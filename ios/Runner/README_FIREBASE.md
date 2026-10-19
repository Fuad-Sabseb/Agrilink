# Firebase Configuration for iOS

## Required File: GoogleService-Info.plist

This directory needs a `GoogleService-Info.plist` file to enable Firebase services.

### Setup Instructions

1. **Follow the main Firebase setup guide**: See `FIREBASE_SETUP.md` in the project root
2. **Download from Firebase Console**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project
   - Go to Project Settings → General
   - Scroll to "Your apps" section
   - Click on the iOS app
   - Click "Download GoogleService-Info.plist"
3. **Place the file here**: `ios/Runner/GoogleService-Info.plist`
4. **Add to Xcode project**:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Right-click on `Runner` folder in Project Navigator
   - Select "Add Files to Runner..."
   - Select `GoogleService-Info.plist`
   - Ensure "Copy items if needed" is checked
   - Click "Add"

### Using the Template

A template file `GoogleService-Info.plist.template` is provided as reference. **DO NOT use the template as-is** - it contains placeholder values.

### Verification

After placing the file, verify:
- ✅ File is named exactly `GoogleService-Info.plist`
- ✅ File is in `ios/Runner/` directory
- ✅ File is added to Xcode project (visible in Project Navigator)
- ✅ Bundle ID is `com.yourcompany.agrolink`
- ✅ File contains real values (not YOUR_API_KEY, etc.)

### Security

⚠️ **This file contains sensitive API keys and should NOT be committed to version control.**

The file is already listed in `.gitignore` to prevent accidental commits.

### Troubleshooting

**Build error: "GoogleService-Info.plist not found"**
- Ensure the file exists in this directory
- Verify the file is added to the Xcode project (appears in Project Navigator)
- Check the file name is exactly `GoogleService-Info.plist` (no .template extension)

**Runtime error: "FirebaseApp.configure() was not called"**
- Ensure Firebase is initialized in `AppDelegate.swift`
- Verify the bundle identifier in the plist matches your app's bundle ID
- Clean build folder in Xcode (Product → Clean Build Folder)

**Push notifications not working**
- Ensure you've uploaded APNs certificate or key in Firebase Console
- Go to Project Settings → Cloud Messaging → iOS app configuration
- Enable Push Notifications capability in Xcode:
  - Select Runner target
  - Go to "Signing & Capabilities"
  - Click "+ Capability"
  - Add "Push Notifications"

For more help, see `FIREBASE_SETUP.md` in the project root.
