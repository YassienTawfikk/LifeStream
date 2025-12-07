# LifeStream Arduino BPM Sender

This component is responsible for reading real-time Heart Rate (BPM) data from a Pulse Sensor and transmitting it to the LifeStream Firebase Realtime Database.

## 📋 Overview

The ESP32 microcontroller acts as a bridge between the analog Pulse Sensor and the cloud. It performs the following operations:

1. **Reads Analog Signal**: Continuously samples the analog voltage from the Pulse Sensor.
2. **Detects Beats**: Implements a peak detection algorithm to identify heartbeats.
3. **Calculates BPM**: Computes the Beats Per Minute based on the time interval between beats (IBI).
4. **Authenticates**: Logs into Firebase using Email/Password authentication.
5. **Syncs Data**: Pushes the calculated BPM to the specific User's path in the Realtime Database.

## 🛠 Hardware Requirements

| Component | Description | Notes |
| :--- | :--- | :--- |
| **ESP32 Dev Board** | Microcontroller with WiFi | Any standard ESP32 dev kit (e.g., DOIT ESP32 DEVKIT V1) |
| **Pulse Sensor** | Analog Heart Rate Sensor | "Pulse Sensor Amped" or generic optical heart rate sensor |
| **Jumper Wires** | For connections | Female-to-Male or Male-to-Male |
| **Micro USB Cable** | Power & Programming | Data-capable cable required |

## 🔌 Wiring Diagram

Connect the Pulse Sensor to the ESP32 as follows:

| Pulse Sensor Pin | ESP32 Pin | Description |
| :--- | :--- | :--- |
| **S** (Signal) | **GPIO 14** | Analog Input (ADC2_CH6) |
| **+** (VCC) | **3.3V** or **5V** | Power (Check your sensor's spec, usually 3.3V is safer for ESP32) |
| **-** (GND) | **GND** | Ground |

> **⚠️ Important**: The code uses `const int pulsePin = 14;`. If you use a different pin, you must update this line in the sketch.

## 💻 Software Setup

### 1. Development Environment

You can use either **Arduino IDE** or **VS Code with Arduino Extension**.

* **Board Manager**: Ensure `esp32` by Espressif Systems is installed.
* **Select Board**: Tools > Board > ESP32 Arduino > **DOIT ESP32 DEVKIT V1** (or your specific board).

### 2. Required Libraries

Install the following library via the Library Manager:

* **Name**: `Firebase Arduino Client Library for ESP8266 and ESP32`
* **Author**: Mobizt
* **Purpose**: Handles authentication and Realtime Database operations.

### 3. Configuration

Open `LifeStream_BPM_Sender/LifeStream_BPM_Sender.ino` and configure the following macros at the top of the file:

#### WiFi Settings

```cpp
#define WIFI_SSID "Your_WiFi_Name"
#define WIFI_PASSWORD "Your_WiFi_Password"
```

#### Firebase Settings

```cpp
// From Firebase Console > Project Settings > General > Web API Key
#define API_KEY "AIzaSy..." 

// From Firebase Console > Realtime Database > Data tab URL
#define DATABASE_URL "https://your-project-id.firebaseio.com/"
```

#### User Credentials

This device simulates a specific user's bracelet. Enter the email/password of the account this bracelet belongs to.

```cpp
#define USER_EMAIL "user@example.com"
#define USER_PASSWORD "user_password"
```

## 🚀 How to Run

1. **Connect ESP32**: Plug the specific ESP32 into your computer via USB.
2. **Select Port**: Choose the correct Serial Port in your IDE.
3. **Upload**: Click the Upload button. The ESP32 usually requires holding the **BOOT** button when "Connecting..." appears in the console.
4. **Monitor**: Open the **Serial Monitor** (Baud Rate: **115200**).

### expected Output

```text
Connecting to WiFi...
Connected!
Firebase Initialized
User UID: Py7... (This is your User ID)
BPM: 72 -> /users/Py7.../bpm/value
```

## 🔍 Troubleshooting

* **Compilation Error**: *"expected exactly one compiler job"* - This usually means there are conflicting files. Ensure you only have `LifeStream_BPM_Sender.ino` and no extra `.h` or `.ino` files in the directory that redefine the same variables.
* **WiFi Connection Failed**: check your SSID and Password. ensure the ESP32 is within range of a 2.4GHz network (ESP32 does not support 5GHz).
* **Firebase Initialized but no Data**: Check if the `USER_EMAIL` and `USER_PASSWORD` are valid. Ensure the database rules allow writes.
* **Erratice BPM**: The sensor is sensitive to movement and ambient light. Ensure it is placed firmly against the skin (finger or earlobe) and shielded from bright light.

## 📂 Project Structure

```text
arduino/
└── LifeStream_BPM_Sender/
    └── LifeStream_BPM_Sender.ino  # Main application logic
```
