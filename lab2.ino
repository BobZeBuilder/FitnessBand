#include <Arduino.h>

#define ECG_PIN      A0   // AD8232 Output (Heart Rate)
#define FSR_PIN      A1   // Force Sensitive Resistor (Respiration)
#define LO_PLUS_PIN  10   // ECG Lead-off detection (+)
#define LO_MINUS_PIN 11   // ECG Lead-off detection (-)

const int sampleRate = 10; // Sampling every 10ms
const int peakThreshold = 620;  // ECG threshold for heartbeat detection
const int breathThreshold = 200; // FSR threshold for respiration detection

int lastPeakTime = 0, bpm = 0;
int lastBreathTime = 0, breathRate = 0;
int inhaleDuration = 0, exhaleDuration = 0;
bool inhaling = false;

String mode = "Fitness";  // Default mode

void setup() {
  Serial.begin(115200);
  pinMode(LO_PLUS_PIN, INPUT);
  pinMode(LO_MINUS_PIN, INPUT);
}

void loop() {
  bool loPlus = digitalRead(LO_PLUS_PIN);
  bool loMinus = digitalRead(LO_MINUS_PIN);

  if (loPlus || loMinus) {
    Serial.println("WARNING: ECG leads are disconnected!");
  } else {
    int ecgVal = analogRead(ECG_PIN);
    int fsrVal = analogRead(FSR_PIN);
    
    // 1️⃣ ECG Heart Rate Detection
    static int lastECG = 0;
    int currentTime = millis();

    if (ecgVal > peakThreshold && lastECG <= peakThreshold) {
      if (lastPeakTime > 0) {
        int interval = currentTime - lastPeakTime;
        bpm = 60000 / interval;  // Convert ms to BPM
      }
      lastPeakTime = currentTime;
    }
    lastECG = ecgVal;

    // 2️⃣ FSR Respiratory Rate Detection
    if (fsrVal > breathThreshold && !inhaling) {
      inhaling = true;
      inhaleDuration = currentTime - lastBreathTime;
    } else if (fsrVal < breathThreshold && inhaling) {
      inhaling = false;
      exhaleDuration = currentTime - (lastBreathTime + inhaleDuration);
      breathRate = 60000 / (inhaleDuration + exhaleDuration);
      lastBreathTime = currentTime;
    }

    // 3️⃣ Send Data to Processing
    Serial.print("BPM:");
    Serial.print(bpm);
    Serial.print(", Respiratory Rate:");
    Serial.print(breathRate);
    Serial.print(", Inhale Time:");
    Serial.print(inhaleDuration);
    Serial.print(", Exhale Time:");
    Serial.println(exhaleDuration);
  }

  // 4️⃣ Handle Incoming Mode Change from Processing
  if (Serial.available() > 0) {
    String received = Serial.readStringUntil('\n');
    received.trim();
    if (received.equals("FITNESS")) mode = "Fitness";
    else if (received.equals("STRESS")) mode = "Stress";
    else if (received.equals("MEDITATION")) mode = "Meditation";
    Serial.print("Mode changed to: ");
    Serial.println(mode);
  }

  delay(10);
}