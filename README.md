# 🚀 LifeStream - Personal Safety & Health Monitoring Platform

**LifeStream** is a cutting-edge mobile application designed for real-time personal safety and health monitoring. It integrates smart wearable data (heart rate) with location services to provide SOS alerts, real-time tracking, and automated emergency responses.

---

## ✨ Key Features

* **❤️ Real-time Heart Rate Monitoring**: Streams BPM data from wearable devices.
* **🆘 SOS Emergency System**: One-tap SOS activation that alerts trusted contacts.
* **📍 Live Location Tracking**: Real-time map shared with emergency contacts during an SOS.
* **👥 Contact Management**: Add and manage trusted contacts and friends.
* **🔔 Smart Notifications**: Alerts for friend requests, SOS triggers, and health anomalies.
* **📱 Modern UI**: Built with Material 3 design principles for a smooth, intuitive experience.

---

## 🛠️ Technology Stack

* **Framework**: [Flutter](https://flutter.dev/) (v3.10.1+)
* **Language**: Dart (v3.0.0+)
* **State Management**: [Riverpod](https://riverpod.dev/) (v2.0+)
* **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
* **Backend & Cloud**:
  * **Firebase Auth**: Secure user authentication.
  * **Firebase Realtime Database**: Low-latency data syncing (Heart Rate, Location).
  * **Firebase Storage**: Profile picture and asset storage.
* **Maps**: Google Maps SDK (Android & iOS).

---

## 🔐 Data Security & Encryption

The app implements **AES-256 Encryption** to secure sensitive user data stored locally on the device.

### 🛡️ Implementation Details

* **Algorithm**: AES with a 256-bit key.

* **Library**: `encrypt` package.
* **Storage**: Encrypted data is stored in `SharedPreferences`.

### 🔒 Encrypted Data Points

1. **Auth Token**: The session token used for API/Firebase authentication.
2. **User Profile**: cached user details (Name, Email, ID).

> [!NOTE]
> **Educational/Starter Project Note**:
> For this starter version, the encryption key is **hardcoded** in the source code (`lib/services/storage_service.dart`). In a production environment, you should use the device's secure hardware (iOS Keychain / Android Keystore) via packages like `flutter_secure_storage` to store the encryption key.

---

## 📂 Project Structure

This project follows a feature-first and modular architecture to ensure scalability.

```bash
lib/
├── main.dart               # 🏁 Application Entry Point
├── app.dart               # 📱 Root Widget & Config
├── firebase_options.dart  # ⚙️ Firebase Configuration (Auto-generated)
├── constants/             # 🎨 App Colors, Strings, and Dimensions
├── models/                # 📦 Data Models
│   ├── user.dart          # User Profile Data
│   ├── notification.dart  # Notification Structure
│   ├── emergency_contact.dart # Contact Info
│   └── ...
├── pages/                 # 🖼️ UI Screens
│   ├── auth/              # Login, Signup, Forgot Password
│   ├── home/              # Main Dashboard
│   ├── map/               # Live Location Map
│   ├── sos/               # SOS Activation Screen
│   ├── profile/           # User Settings & Profile
│   └── ...
├── providers/             # ⚡ State Management (Riverpod)
│   ├── auth_provider.dart      # User Session State
│   ├── location_provider.dart  # GPS Location State
│   ├── pulse_provider.dart    # Heart Rate Data Stream
│   └── ...
├── services/              # 🔌 External Services & APIs
│   ├── api_service.dart
│   ├── storage_service.dart
│   └── heart_rate_simulator.dart # Simulates BLE device data
├── widgets/               # 🧩 Reusable UI Components
└── utils/                 # 🛠️ Helper Functions
```

---

## 🚀 Getting Started

Follow these instructions to set up the project on your local machine.

### 1️⃣ Prerequisites

Before you begin, ensure you have the following installed:

* **Flutter SDK**: [Install here](https://docs.flutter.dev/get-started/install)
* **Git**: [Install here](https://git-scm.com/downloads)
* **VS Code** or **Android Studio**: Recommended IDEs.
* **Firebase Account**: Required for backend services.
* **Google Cloud Account**: Required for Maps API.

### 2️⃣ Installation & Setup

**Step 1: Clone the Repository**
Open your terminal and run:

```bash
git clone https://github.com/YassienTawfikk/LifeStream.git
cd LifeStream
```

**Step 2: Install Dependencies**
Download all required Flutter packages:

```bash
flutter pub get
```

### 3️⃣ Configuration (Critical Steps)

The app relies on API keys for Google Maps and Firebase. You need to configure these manually as they are secrets and not tracked in Git.

#### 🗺️ Google Maps Setup

**For Android:**

1. Go to `android/` directory (inside the project).
2. Create a file named `local.properties` (if it doesn't exist).
3. Open it and add your Google Maps API Key:

    ```properties
    sdk.dir=/Users/YOUR_USERNAME/Library/Android/sdk
    flutter.sdk=/Users/YOUR_USERNAME/development/flutter
    google.maps.key=YOUR_ANDROID_MAPS_API_KEY
    ```

    *(Note: Replace `YOUR_USERNAME` and paths with your actual system paths. `sdk.dir` is usually auto-generated if you open the project in Android Studio).*

**For iOS:**

1. Go to `ios/Flutter/` directory.
2. Create a file named `Secrets.xcconfig`.
3. Add your API Key:

    ```xcconfig
    GOOGLE_MAPS_KEY=YOUR_IOS_MAPS_API_KEY
    ```

#### 🔥 Firebase Setup

**Option A: Using CLI (Recommended)**
If you have the FlutterFire CLI installed, simply run:

```bash
flutterfire configure
```

Follow the prompts to select your project and platforms. This will automatically generate `lib/firebase_options.dart` and update native files.

**Option B: Manual Setup**

1. **Android**: Download `google-services.json` from Firebase Console -> Project Settings -> Android App. Place it in:
    `android/app/google-services.json`
2. **iOS**: Download `GoogleService-Info.plist` from Firebase Console -> Project Settings -> iOS App. Place it in:
    `ios/Runner/GoogleService-Info.plist`

---

## ▶️ How to Run

### 🤖 Run on Android Emulator/Device

1. Launch your Android Emulator or connect a physical device (ensure USB Debugging is ON).
2. Run the command:

    ```bash
    flutter run
    ```

### 🍎 Run on iOS Simulator/Device (Mac Only)

1. Navigate to the iOS folder to install native pods:

    ```bash
    cd ios
    pod install
    cd ..
    ```

2. Launch an iOS Simulator.
3. Run the command:

    ```bash
    flutter run
    ```

---

## ❓ Troubleshooting

### "SDK location not found" (Android)

* **Cause**: The `local.properties` file is missing or points to the wrong Android SDK path.
* **Fix**: Open the project in Android Studio (specifically the `android` folder) and let it sync. It will automatically create `local.properties` with the correct `sdk.dir`. Then add your `google.maps.key` line manually.

### "CocoaPods not installed" or Pod errors (iOS)

* **Cause**: Missing CocoaPods dependency manager.
* **Fix**:

    ```bash
    sudo gem install cocoapods
    cd ios
    pod install
    pod update
    ```
