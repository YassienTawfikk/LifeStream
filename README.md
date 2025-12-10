# LifeStream

![Application Overview](https://github.com/user-attachments/assets/eb1e40a7-ed4f-4ad9-9b31-8aa658e2ed8d)

## Overview

LifeStream is a comprehensive mobile application and hardware ecosystem designed to monitor user health in real-time and provide immediate safety mechanisms in emergency situations. By integrating with a custom ESP32-based wearable device, the system continuously tracks heart rate variability and synchronizes this data with a cloud backend. The mobile application serves as the command center, offering real-time visualization of health metrics, live location tracking, and an automated SOS alerting system that notifies trusted contacts with critical data (Location + Heart Rate) when triggered.

This project utilizes a modern technology stack including Flutter for the cross-platform mobile interface, Firebase for real-time data synchronization and authentication, and OpenStreetMap for privacy-focused location services.

---

## Key Features

### Health Monitoring

![Main Dashboard](https://github.com/user-attachments/assets/2e1be7c4-67ae-4931-b3bf-c6aa8dbcb30e)

* **Real-time Heart Rate Streaming**: Connects to a custom ESP32 wearable device to receive and display Pulse/BPM data with low latency using Firebase Realtime Database.
* **Live ECG-Style Visualization**: The application renders incoming heart rate data as a continuous, dynamic waveform, providing users with immediate visual feedback on their heart rhythm.
* **Anomaly Detection**: Monitors heart rate thresholds and can trigger local alerts if the BPM falls outside safe ranges (configurable).

---

### Safety & Emergency Response (SOS)

![SOS Page](https://github.com/user-attachments/assets/28a6bb58-1f09-41ba-9654-8ee5635e9e55)

* **One-Tap SOS Activation**: A prominent emergency button is accessible from the main dashboard, designed for quick activation in distress situations.
* **Context-Aware Alerts**: When SOS is triggered, the system automatically compiles a comprehensive alert package containing:

  * **Precise Location**: Current Latitude and Longitude.
  * **Physiological State**: The user's current Heart Rate (BPM) at the time of the alert.
* **Emergency Contact Notification**: Trusted contacts receive instant notifications. Tapping the notification automatically copies the distress coordinates to the clipboard for quick sharing with emergency services or navigation.
* **Live Tracking Mode**: Activating SOS enables a real-time location stream, allowing emergency contacts to track the user's movement on an interactive map.

![Live Location](https://github.com/user-attachments/assets/ea253c1e-0901-4e7b-96ac-917bafd34ded)

---

### Connectivity & Social

![Friends-List](https://github.com/user-attachments/assets/28b0de5e-13b4-47df-89f6-5de99a1179bb)

* **Friend & Contact Management**: Users can search for and add friends via email. The system handles friend requests with a secure accept/reject workflow.
* **Profile Synchronization**: User profiles, including profile pictures, are synchronized in real-time across devices using Firebase Storage and Realtime Database. Updating a profile picture instantly reflects on friends' devices.
* **Status Indicators**: View the online/offline status and safety state of connected friends.

![Notifications](https://github.com/user-attachments/assets/bee686ee-217f-43d3-aab5-078c868a9209)

---

### Security & Privacy

* **Local Data Encryption**: Sensitive user data stored on the device (authentication tokens, cached profile information) is protected using AES-256 encryption.
* **Secure Authentication**: powered by Firebase Authentication, supporting email/password login with secure session management.

---

## System Architecture

### Mobile Application (Flutter)

* **Architecture**: Feature-first, clean architecture using Riverpod for reliable state management.
* **Navigation**: GoRouter for deep linking and stack management.
* **Maps**: Integrated OpenStreetMap implementation for rendering live location data without requiring proprietary API keys.

### Hardware (Wearable Prototype)

* **Controller**: ESP32 / ESP8266 Microcontroller with WiFi capabilities.
* **Sensors**: Analog Pulse Sensor (reading PPG data).
* **Communication**: Direct WiFi connection to Firebase Realtime Database for pushing processed BPM values.
### Hardware (Wearable Prototype)

* **Controller**: ESP32 / ESP8266 Microcontroller with WiFi capabilities.
* **Sensors**: Analog Pulse Sensor (reading PPG data).
* **Communication**: Direct WiFi connection to Firebase Realtime Database for pushing processed BPM values.

## Installation & Setup Guide

### Part 1: Mobile Application Setup

**Prerequisites**

* Flutter SDK (3.10.1 or higher)
* Android Studio / VS Code with Flutter extensions
* Git

**Steps**

1. **Clone the Repository**

    ```bash
    git clone https://github.com/YassienTawfikk/LifeStream.git
    cd LifeStream
    ```

2. **Install Dependencies**

    ```bash
    flutter pub get
    ```

3. **Firebase Configuration**
    * Create a project in the Firebase Console.
    * **Android**: Download `google-services.json` and place it in `android/app/`.
    * **iOS**: Download `GoogleService-Info.plist` and place it in `ios/Runner/`.
    * **Services**: Enable Authentication (Email/Password), Realtime Database (Rules: ensure read/write access for auth users), and Storage.

4. **Run the Application**
    * **Android (Emulator/Physical)**:

        ```bash
        flutter run
        ```

    * **iOS (Simulator/Physical - Mac only)**:

        ```bash
        cd ios
        pod install
        cd ..
        flutter run
        ```

### Part 2: Wearable Hardware Setup

**Prerequisites**

* Arduino IDE
* ESP32 or ESP8266 Board Support Package installed in Arduino IDE
* **Libraries**:
  * `Firebase ESP Client` by Mobizt
  * `WiFi` (Built-in)

**Steps**

1. **Hardware Wiring**
    * **Signal Output** of Heart Rate Sensor -> **Pin 14** (or analog pin A0 on ESP8266, check code definition).
    * **VCC** -> 3.3V or 5V (depending on sensor specs).
    * **GND** -> GND.

2. **Firmware Configuration**
    * Open `arduino/LifeStream_BPM_Sender/LifeStream_BPM_Sender.ino`.
    * Update the following constants with your specific configuration:

        ```cpp
        // WiFi Credentials
        #define WIFI_SSID "YOUR_WIFI_NAME"
        #define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"

        // Firebase Credentials
        #define API_KEY "YOUR_FIREBASE_WEB_API_KEY"
        #define DATABASE_URL "YOUR_FIREBASE_DATABASE_URL"

        // User Mapping (The user who owns this device)
        #define USER_EMAIL "user@example.com"
        #define USER_PASSWORD "user_password"
        ```

3. **Upload**
    * Connect your ESP32/ESP8266 via USB.
    * Select the correct Board and Port in Arduino IDE.
    * Click **Upload**.
    * Open **Serial Monitor** (115200 baud) to verify connection and BPM readings.

## Usage Guide

1. **Registration**: Open the mobile app and create a new account.
2. **Hardware Connection**: Power on the wearable device. Ensure it is connected to WiFi (LED indicator or Serial output).
3. **Visualization**: Navigate to the Home Dashboard. The heart rate graph should begin tracking automatically once the device filters a stable pulse.
4. **Testing SOS**: Long-press or Tap the SOS button (depending on settings) to enter Emergency Mode. Check the 'Map' tab to see live tracking activation.
5. **Adding Contacts**: Go to the Profile/Contacts section and search for another registered user email to send a friend request.

## Contributors


<div>
    <table align="center">
        <tr>
            <td align="center">
                <a href="https://github.com/YassienTawfikk" target="_blank">
                    <img src="https://avatars.githubusercontent.com/u/126521373?v=4" width="150px;"
                         alt="Yassien Tawfik"/>
                    <br/>
                    <sub><b>Yassien Tawfik</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/madonna-mosaad" target="_blank">
                    <img src="https://avatars.githubusercontent.com/u/127048836?v=4" width="150px;"
                         alt="Madonna Mosaad"/>
                    <br/>
                    <sub><b>Madonna Mosaad</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/Seiftaha" target="_blank">
                    <img src="https://avatars.githubusercontent.com/u/127027353?v=4" width="150px;" alt="Seif Taha"/>
                    <br/>
                    <sub><b>Seif Taha</b></sub>
                </a>
            </td>         
            <td align="center">
                <a href="https://github.com/Mazenmarwan023" target="_blank">
                    <img src="https://avatars.githubusercontent.com/u/127551364?v=4" width="150px;" alt="Mazen Marwan"/>
                    <br/>
                    <sub><b>Mazen Marwan</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/nancymahmoud1" target="_blank">
                    <img src="https://avatars.githubusercontent.com/u/125357872?v=4" width="150px;"
                         alt="Nancy Mahmoud"/>
                    <br/>
                    <sub><b>Nancy Mahmoud</b></sub>
                </a>
            </td>
            </td>
            <td align="center">
                <a href="https://github.com/mohamedddyasserr" target="_blank">
                    <img src="https://avatars.githubusercontent.com/u/126451832?v=4" width="150px;"
                         alt="Mohamed Yasser"/>
                    <br/>
                    <sub><b>Mohamed Yasser</b></sub>
                </a>
            </td>
        </tr>
    </table>
</div>

---
*LifeStream - Protecting Lives through Technology.*
