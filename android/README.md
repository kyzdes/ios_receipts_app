# Recipe Manager - Android App

A beautiful native Android application built with Kotlin and Jetpack Compose for managing your recipes.

## Features

- 🔐 User authentication (login/register)
- 📱 Material Design 3 UI
- 🍳 Browse and search recipes
- ⭐ Favorite recipes
- 📝 Add new recipes with ingredients and instructions
- 🎯 Recipe of the day
- 🏷️ Category organization
- 📸 Recipe images with Coil image loading
- 🔄 Offline-first with DataStore for auth tokens

## Tech Stack

- **Language**: Kotlin
- **UI**: Jetpack Compose with Material 3
- **Architecture**: MVVM (Model-View-ViewModel)
- **Networking**: Retrofit + OkHttp
- **Image Loading**: Coil
- **Navigation**: Jetpack Navigation Compose
- **State Management**: Kotlin Flow & StateFlow
- **Data Persistence**: DataStore Preferences
- **Async**: Kotlin Coroutines
- **Build System**: Gradle

## Prerequisites

Before you begin, ensure you have the following installed:

- **Android Studio**: Hedgehog (2023.1.1) or later
- **JDK**: 17 or later
- **Minimum Android SDK**: 24 (Android 7.0)
- **Target Android SDK**: 34 (Android 14)
- **Gradle**: 8.1.4 (via wrapper)

## Project Structure

```
android/
├── app/
│   ├── src/
│   │   └── main/
│   │       ├── java/com/recipemanager/
│   │       │   ├── data/
│   │       │   │   ├── model/         # Data models
│   │       │   │   ├── remote/        # API service & client
│   │       │   │   └── repository/    # Repository layer
│   │       │   ├── ui/
│   │       │   │   ├── components/    # Reusable UI components
│   │       │   │   ├── screens/       # App screens
│   │       │   │   └── theme/         # Material 3 theme
│   │       │   ├── viewmodel/         # ViewModels
│   │       │   ├── navigation/        # Navigation setup
│   │       │   ├── MainActivity.kt
│   │       │   └── RecipeApplication.kt
│   │       ├── res/                   # Android resources
│   │       └── AndroidManifest.xml
│   ├── build.gradle                   # App-level build config
│   └── proguard-rules.pro            # ProGuard rules
├── build.gradle                       # Project-level build config
└── settings.gradle
```

## Configuration

### API Configuration

The app is configured to connect to your backend API. Update the API base URL in `app/build.gradle`:

**For Development (Android Emulator):**
```gradle
buildConfigField "String", "API_BASE_URL", "\"http://10.0.2.2:3000/api/v1\""
```

**For Production:**
```gradle
buildConfigField "String", "API_BASE_URL", "\"https://your-api.com/api/v1\""
```

> Note: `10.0.2.2` is a special IP that Android emulator uses to access `localhost` on your development machine.

**For Physical Device Testing:**
Replace `10.0.2.2` with your computer's local IP address (e.g., `192.168.1.100:3000`).

## Building the App

### 1. Open Project in Android Studio

1. Launch Android Studio
2. Click "Open" and select the `android` folder
3. Wait for Gradle sync to complete

### 2. Build Debug APK

#### Option A: Using Android Studio
1. Go to **Build → Build Bundle(s) / APK(s) → Build APK(s)**
2. Once complete, click "locate" to find the APK
3. APK location: `app/build/outputs/apk/debug/app-debug.apk`

#### Option B: Using Command Line
```bash
cd android
./gradlew assembleDebug
```

Output: `app/build/outputs/apk/debug/app-debug.apk`

### 3. Build Release APK

#### Generate Signing Key (First Time Only)

```bash
keytool -genkey -v -keystore recipe-manager.jks -alias recipe-manager-key \
  -keyalg RSA -keysize 2048 -validity 10000
```

This creates a `recipe-manager.jks` keystore file. Keep this file secure!

#### Configure Signing

Update `app/build.gradle` signingConfigs section:

```gradle
signingConfigs {
    release {
        storeFile file("path/to/recipe-manager.jks")
        storePassword "your_store_password"
        keyAlias "recipe-manager-key"
        keyPassword "your_key_password"
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        buildConfigField "String", "API_BASE_URL", "\"https://your-api.com/api/v1\""
    }
}
```

**Best Practice**: Use environment variables for sensitive data:

```gradle
signingConfigs {
    release {
        storeFile file(System.getenv("KEYSTORE_PATH") ?: "recipe-manager.jks")
        storePassword System.getenv("KEYSTORE_PASSWORD")
        keyAlias System.getenv("KEY_ALIAS")
        keyPassword System.getenv("KEY_PASSWORD")
    }
}
```

Then export environment variables before building:

```bash
export KEYSTORE_PATH=/path/to/recipe-manager.jks
export KEYSTORE_PASSWORD=your_store_password
export KEY_ALIAS=recipe-manager-key
export KEY_PASSWORD=your_key_password
```

#### Build Release APK

```bash
./gradlew assembleRelease
```

Output: `app/build/outputs/apk/release/app-release.apk`

The release APK will be:
- Signed with your keystore
- Minified with ProGuard/R8
- Optimized for size and performance

### 4. Build Android App Bundle (AAB) for Play Store

```bash
./gradlew bundleRelease
```

Output: `app/build/outputs/bundle/release/app-release.aab`

## Installation

### Install on Emulator

1. Start an Android emulator from Android Studio (AVD Manager)
2. Run the app:
   ```bash
   ./gradlew installDebug
   ```

### Install on Physical Device

1. Enable **Developer Options** on your Android device
2. Enable **USB Debugging**
3. Connect device via USB
4. Verify device connection:
   ```bash
   adb devices
   ```
5. Install APK:
   ```bash
   adb install app/build/outputs/apk/debug/app-debug.apk
   # or
   ./gradlew installDebug
   ```

### Install APK Manually

Transfer the APK to your device and:
1. Open the APK file
2. Allow installation from unknown sources if prompted
3. Tap Install

## Running the App

### From Android Studio
1. Select a device/emulator from the dropdown
2. Click the green "Run" button or press `Shift + F10`

### From Command Line
```bash
./gradlew installDebug
adb shell am start -n com.recipemanager/.MainActivity
```

## Testing

### Run Unit Tests
```bash
./gradlew test
```

### Run Instrumented Tests (requires emulator/device)
```bash
./gradlew connectedAndroidTest
```

## Debugging

### View Logs
```bash
adb logcat | grep "RecipeManager"
```

### Debug Network Requests

The app uses OkHttp Logging Interceptor. In debug builds, all network requests are logged to Logcat.

```bash
adb logcat | grep "OkHttp"
```

## API Configuration for Different Environments

### Development (Local Backend)

**Android Emulator:**
```gradle
buildConfigField "String", "API_BASE_URL", "\"http://10.0.2.2:3000/api/v1\""
```

**Physical Device:**
```gradle
buildConfigField "String", "API_BASE_URL", "\"http://192.168.1.100:3000/api/v1\""
```

### Production
```gradle
buildConfigField "String", "API_BASE_URL", "\"https://api.yourserver.com/api/v1\""
```

## Common Issues & Solutions

### 1. Gradle Sync Failed
- Ensure you have JDK 17 installed
- Clear Gradle cache: `./gradlew clean`
- Invalidate caches: **File → Invalidate Caches → Invalidate and Restart**

### 2. Cannot Connect to Backend
- Verify backend is running
- Check API_BASE_URL configuration
- For emulator: Use `10.0.2.2` instead of `localhost`
- For physical device: Use your computer's local IP
- Ensure `android:usesCleartextTraffic="true"` in AndroidManifest.xml (for HTTP in development)

### 3. Build Fails with "Out of Memory"
Add to `gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=512m
```

### 4. APK Too Large
- Ensure minification is enabled in release build
- Check ProGuard rules are properly configured
- Use APK Analyzer: **Build → Analyze APK**

## Performance Optimization

The release build includes:
- **ProGuard/R8**: Code shrinking and obfuscation
- **Resource Shrinking**: Removes unused resources
- **Image Optimization**: Coil handles image caching
- **Lazy Loading**: RecyclerView with Compose LazyColumn

## Security Features

- JWT tokens stored securely in DataStore
- Auth tokens excluded from backups
- HTTPS enforced in production
- ProGuard obfuscation in release builds
- Cleartext traffic disabled in production

## App Size

- Debug APK: ~10-15 MB
- Release APK (minified): ~8-12 MB
- AAB for Play Store: ~7-10 MB

## Version Management

Update version in `app/build.gradle`:

```gradle
defaultConfig {
    versionCode 2       // Increment for each release
    versionName "1.1.0" // Semantic versioning
}
```

## Publishing to Google Play Store

1. Build release AAB: `./gradlew bundleRelease`
2. Create a Google Play Console account
3. Create a new app
4. Upload `app-release.aab`
5. Complete store listing (description, screenshots, etc.)
6. Submit for review

## Continuous Integration

### GitHub Actions Example

```yaml
name: Android CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
    - name: Grant execute permission for gradlew
      run: chmod +x gradlew
      working-directory: ./android
    - name: Build with Gradle
      run: ./gradlew assembleDebug
      working-directory: ./android
    - name: Run tests
      run: ./gradlew test
      working-directory: ./android
```

## License

This project is part of the Recipe Manager full-stack application.

## Support

For issues or questions, please open an issue on the repository.

---

**Happy Cooking! 🍳**
