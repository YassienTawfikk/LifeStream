# 🚀 LifeStream - Complete Project Documentation

This document consolidates all project information for **LifeStream**, a professional, modular, and production-ready Flutter starter application.

## ✨ Project Summary

**LifeStream** is a real-time personal safety platform streaming vitals, motion data, and SOS alerts from a smart wearable. The starter app is built following modern best practices and Material 3 design principles, complete and ready for development.

| Detail | Status/Value | Source File |
| :--- | :--- | :--- |
| **Build Date** | December 1, 2025 | BUILD_COMPLETE.md |
| **Flutter SDK** | ^3.10.1 | BUILD_COMPLETE.md |
| **Status** | ✅ Complete & Ready for Development | BUILD_COMPLETE.md |
| **Purpose** | Real-time personal safety platform | README.md |
| **Total Dart Files** | 33 | BUILD_COMPLETE.md, FEATURE_CHECKLIST.md |
| **Lines of Code** | ~3,500+ | BUILD_COMPLETE.md, FEATURE_CHECKLIST.md |
| **Total Pages** | 9 complete pages | BUILD_COMPLETE.md, FEATURE_CHECKLIST.md |

---

## 🛠️ Key Technologies & Dependencies

| Category | Technology | Version |
| :--- | :--- | :--- |
| **Framework** | Flutter | 3.10.1+ |
| **State Management** | Riverpod | 2.6.1 |
| **Navigation** | GoRouter | 14.0.0 |
| **HTTP Client** | Dio | 5.4.0 |
| **Storage** | SharedPreferences | 2.2.3 |
| **UI Framework** | Material 3 | Built-in |

---

## 📁 Project Architecture and Features

The app features a modular structure with a clear separation of concerns, utilizing **Riverpod** for state management and **GoRouter** for navigation.

### Project Structure (lib/)

The structure is organized for scalability and long-term maintenance:

* `main.dart`: App entry point
* `app.dart`: Root app widget configuration
* `constants/`: Centralized colors, text styles, and app constants
* `models/`: Data models for User, Item, and Notification with JSON support
* `services/`: API (Dio-based) and Storage (SharedPreferences wrapper) services
* `providers/`: Riverpod providers for Auth, Theme, API, and Storage state
* `routes/`: GoRouter configuration and route definitions
* `utils/`: Theme data utilities
* `widgets/`: Reusable components (Buttons, TextFields, Cards)
* `pages/`: All feature pages (Splash, Auth, Home, List, Detail, Search, Notifications, Profile, Settings)

### Completed Pages (9+)

* **Splash/Onboarding Page**: Animated splash with Material 3 design and auto-navigation.
* **Authentication Flow**: Login, Signup, and Forgot Password pages with built-in form validation.
* **Home/Dashboard Page**: Featured items carousel and quick action cards.
* **List & Detail Pages**: Grid/List views, filters, and full item detail views with a collapsible app bar.
* **Search Page**: Search bar, recent searches, and popular categories.
* **Notifications Page**: Type-based notification list with read/unread indicators.
* **Profile & Settings Pages**: Editable user profile and settings for theme switching, account, and privacy.

---

## 🐛 `LateInitializationError` Fix Migration Guide

The app previously threw a `LateInitializationError` because `SharedPreferences` (`_prefs`) was not initialized before being used, due to incorrect storage initialization timing.

The fix involved changing the pattern from **synchronous-with-async-init** to **fully async** using `FutureProvider`.

### The Fix in Riverpod

| Status | Before (Broken) | After (Fixed) |
| :--- | :--- | :--- |
| **Storage Provider** | `Provider<StorageService>` (Returns uninitialized service) | `FutureProvider<StorageService>` (Fully initializes before returning) |
| **Initialization** | `init()` happens **after** provider already exists | `init()` happens **during** provider creation |
| **Access Pattern** | `ref.read(storageServiceProvider)` | `await ref.read(storageServiceProvider.future)` |

### Key Takeaways

1. **Never mix sync and async initialization** - Fully initialize before returning from a provider.
2. **Use `FutureProvider` for async dependencies** (like `SharedPreferences`).
3. **Always await async operations** - Use the `.future` suffix to access `FutureProvider` values.
4. **Initialize early** - Do all setup in `main()` before creating `ProviderScope`.

---

## 🚀 Getting Started

Follow these steps to set up the project locally.

### Prerequisites

* **Flutter SDK**: Version 3.10.1 or higher.
* **Dart SDK**: Version 3.0.0 or higher.
* **Git**: For cloning the repository.
* **Google Cloud Console Account**: To generate Google Maps API keys.
* **Firebase Project**: To generate configuration files.

### ⚙️ Setup & Configuration

#### 1. Clone the Repository

```bash
git clone https://github.com/YassienTawfikk/LifeStream.git
cd LifeStream
```

#### 2. Install Dependencies

```bash
flutter pub get
```

#### 3. Android Configuration (API Keys)

The project uses `local.properties` to securely store the Google Maps API key for Android. This file is ignored by Git.

1. Navigate to the `android` directory.
2. Create or edit the `local.properties` file.
3. Add your Google Maps API key:

    ```properties
    flutter.sdk=/path/to/flutter
    google.maps.key=YOUR_ANDROID_API_KEY_HERE
    ```

#### 4. iOS Configuration (API Keys)

The project uses a `Secrets.xcconfig` file to securely store the Google Maps API key for iOS. This file is ignored by Git.

1. Navigate to `ios/Flutter/`.
2. Create a file named `Secrets.xcconfig`.
3. Add your Google Maps API key:

    ```xcconfig
    GOOGLE_MAPS_KEY=YOUR_IOS_API_KEY_HERE
    ```

#### 5. Firebase Configuration

You need to add the Firebase configuration files to the project.

* **Android**: Download `google-services.json` from your Firebase console and place it in `android/app/`.
* **iOS/macOS**: Download `GoogleService-Info.plist` from your Firebase console and place it in `ios/Runner/` and `macos/Runner/`.

### ▶️ Running the App

#### Run on Android

```bash
flutter run -d android
```

#### Run on iOS

```bash
cd ios
pod install
cd ..
flutter run -d ios
```

#### Run on Web

```bash
flutter run -d chrome
```

### 🛠️ Development Commands

| Action | Command |
| :--- | :--- |
| Analyze code | `flutter analyze` |
| Format code | `dart format lib/` |
| Build for web | `flutter build web --release` |
| Build for Android | `flutter build apk --release` |

### Customization

* **Change App Name**: Edit `lib/constants/app_constants.dart`.
* **Change Primary Color**: Edit `lib/constants/app_colors.dart`.
* **Configure API Base URL**: Update `lib/constants/app_constants.dart`.

---

## 🎯 Next Steps for Development

The app is **Production Ready** but has several enhancement phases planned:

| Phase | Key Tasks |
| :--- | :--- |
| **Phase 1: Backend Integration** | Connect to real API endpoints, implement proper JWT authentication, and handle refresh tokens. |
| **Phase 2: Advanced Features** | Implement Push Notifications, Image upload, Offline support (Hive/Isar), and social features. |
| **Phase 3: Performance & Optimization** | Implement Image caching, Lazy loading pagination, and Code splitting. |
| **Phase 5: Testing** | Implement Unit, Widget, and Integration tests to achieve over 80% test coverage. |

Would you like to explore any of these sections in more detail, such as reviewing the file list or the steps for backend integration?
