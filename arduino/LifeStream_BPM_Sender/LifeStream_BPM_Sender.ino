#include <Firebase_ESP_Client.h>
#include <WiFi.h>

// WiFi
#define WIFI_SSID "Yassien"
#define WIFI_PASSWORD "Yyyyy124"

// Firebase
#define API_KEY "AIzaSyCQhwEA6Ral7EsLh4Z1ZQODJqciy1z4bX4"
#define DATABASE_URL "https://braceletlifesaver-default-rtdb.firebaseio.com/"

// User Credentials
#define USER_EMAIL "yassien.tawfik@gmail.com"
#define USER_PASSWORD "12345678"

// Provide the token generation process info.
#include <addons/TokenHelper.h>
// Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

const int pulsePin = 14;
int pulseSignal = 0;

unsigned long lastBeatTime = 0;
int bpm = 0;

const int threshold = 2500; // around middle of your 0–4095 range
bool pulseDetected = false;

bool signupOK = false;
String uid = "";

void setup() {
  Serial.begin(115200);

  // WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.println("\nConnected!");

  // Firebase config
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  // IMPORTANT: Update these credentials to the user who will own this Bracelet
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback =
      tokenStatusCallback; // see addons/TokenHelper.h

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  Firebase.RTDB.setReadTimeout(&fbdo, 10000);

  Serial.println("Firebase Initialized");
}

void loop() {
  // Ensure Firebase is ready
  if (Firebase.ready() && !signupOK) {
    signupOK = true;
    uid = auth.token.uid.c_str();
    Serial.print("User UID: ");
    Serial.println(uid);
  }

  pulseSignal = analogRead(pulsePin);

  unsigned long currentTime = millis();

  // Simple peak detection
  if (pulseSignal > threshold && !pulseDetected) {
    pulseDetected = true;

    if (lastBeatTime > 0) {
      unsigned long rrInterval = currentTime - lastBeatTime; // ms between beats
      bpm = (60000 / rrInterval) * 3;                        // convert to BPM
    }

    lastBeatTime = currentTime;
  }

  if (pulseSignal < threshold) {
    pulseDetected = false;
  }

  // Only send data if we have a valid BPM and Firebase is ready
  if (Firebase.ready() && signupOK &&
      (millis() % 200 == 0)) { // Limit send rate slightly or send on beat
    // Note: Sending too frequently might hit write limits or lag.
    // For this example, we keep the original logic but update the path.

    // Path: users/{uid}/bpm/value
    String pathBPM = "/users/" + uid + "/bpm/value";

    Serial.print("BPM: ");
    Serial.print(bpm);
    Serial.print(" -> ");
    Serial.println(pathBPM);

    // Check if BPM is valid range before sending to avoid noise
    if (bpm > 40 && bpm < 200) {
      if (Firebase.RTDB.setInt(&fbdo, pathBPM, bpm)) {
        // Success
      } else {
        Serial.println("FAILED: " + fbdo.errorReason());
      }
    }
  }

  delay(20); // Small delay for stability
}
