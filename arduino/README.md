# Arduino BPM Sender

This directory contains the Arduino code for the LifeStream project.
The main sketch is located in **`LifeStream_BPM_Sender/LifeStream_BPM_Sender.ino`**.

## Integration with Firebase

The code is configured to:

1. Connect to WiFi.
2. Authenticate with Firebase using email/password (hardcoded in the sketch).
3. **Automatically detect the User ID (UID)** from the authentication.
4. Send BPM data to `users/{UID}/bpm/value`.

## Usage

1. Open `LifeStream_BPM_Sender/LifeStream_BPM_Sender.ino` in the Arduino IDE.
2. Install the required libraries:
    * `Firebase Arduino Client Library for ESP8266 and ESP32` by Mobizt
3. Update the `WIFI_SSID` and `WIFI_PASSWORD` if needed.
4. Upload to your ESP32.
