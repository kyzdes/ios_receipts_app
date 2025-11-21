# Quick Start Guide - Recipe Manager Android App

Get the Recipe Manager Android app running in **5 minutes**! ⚡

## Prerequisites ✅

- Android Studio installed
- Backend server running (see backend README)
- Android device or emulator

## Steps

### 1. Configure API URL (1 minute)

Open `android/app/build.gradle` and update the API URL:

**For Android Emulator:**
```gradle
buildConfigField "String", "API_BASE_URL", "\"http://10.0.2.2:3000/api/v1\""
```
(Already configured - no changes needed if backend runs on port 3000)

**For Physical Device:**
```gradle
buildConfigField "String", "API_BASE_URL", "\"http://YOUR_COMPUTER_IP:3000/api/v1\""
```

Find your computer's IP:
- **Windows**: `ipconfig` → Look for IPv4 Address
- **Mac/Linux**: `ifconfig` or `ip addr` → Look for inet address

### 2. Open Project (1 minute)

1. Launch Android Studio
2. **Open → Select `android` folder**
3. Wait for Gradle sync to complete (~1-2 minutes first time)

### 3. Build & Run (2 minutes)

#### Option A: Using Android Studio (Easiest)
1. Select an emulator or connected device from the dropdown
2. Click the green **Run** button (▶️) or press `Shift + F10`
3. App will build and launch automatically!

#### Option B: Command Line (Fastest)
```bash
cd android
./gradlew installDebug
adb shell am start -n com.recipemanager/.MainActivity
```

### 4. Test the App (1 minute)

1. **Register** a new account:
   - Email: `test@example.com`
   - Password: `password123`
   - Username: `TestUser`

2. **Browse recipes** on the home screen
3. **Add a recipe** using the FAB button
4. **Search** for recipes
5. **View details** by clicking a recipe

## Troubleshooting 🔧

### Cannot connect to backend?

**Emulator:**
- Backend URL should be `http://10.0.2.2:3000/api/v1`
- Make sure backend is running on `http://localhost:3000`

**Physical Device:**
- Use your computer's local IP (e.g., `http://192.168.1.100:3000/api/v1`)
- Ensure device and computer are on the same network
- Disable firewall temporarily to test

**Check backend is running:**
```bash
curl http://localhost:3000/api/v1/categories
```

### Gradle sync failed?
```bash
cd android
./gradlew clean
```
Then sync again in Android Studio.

### App crashes on launch?
Check Logcat in Android Studio:
```
View → Tool Windows → Logcat
```
Filter by "RecipeManager" to see app logs.

## Building Release APK 📦

For a production-ready APK:

### Quick Release (No Signing)
```bash
cd android
./gradlew assembleRelease
```
Output: `app/build/outputs/apk/release/app-release-unsigned.apk`

### Signed Release (Recommended)

1. **Generate keystore** (first time only):
```bash
keytool -genkey -v -keystore recipe-manager.jks -alias recipe-manager \
  -keyalg RSA -keysize 2048 -validity 10000
```

2. **Update `app/build.gradle`**:
```gradle
signingConfigs {
    release {
        storeFile file("../recipe-manager.jks")
        storePassword "your_password"
        keyAlias "recipe-manager"
        keyPassword "your_password"
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
        // ... rest of config
    }
}
```

3. **Build**:
```bash
./gradlew assembleRelease
```
Output: `app/build/outputs/apk/release/app-release.apk`

4. **Install on device**:
```bash
adb install app/build/outputs/apk/release/app-release.apk
```

## Next Steps 🚀

- **Customize**: Update app name in `app/src/main/res/values/strings.xml`
- **Icon**: Replace launcher icons in `app/src/main/res/mipmap-*/`
- **Production API**: Update API_BASE_URL to your production server
- **Publish**: Build AAB and upload to Google Play Store

## Key Features 🎯

✅ Material Design 3 UI
✅ Dark mode support
✅ Offline authentication
✅ Image loading with caching
✅ Search functionality
✅ Favorite recipes
✅ Recipe of the day
✅ Categories

## File Sizes 📊

- Debug APK: ~10-12 MB
- Release APK (minified): ~8-10 MB

## Support 💬

Issues? Check the full [README.md](./README.md) for detailed documentation.

---

**Built with ❤️ using Kotlin & Jetpack Compose**
