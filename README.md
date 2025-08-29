# 🐾 Intelligent Pet Feeder IoT System

An IoT-based smart pet feeding system built with **ESP32, MQTT, Supabase, and Flutter**.  
This project automates food and water dispensing for pets (e.g., cats 🐱, dogs 🐶) and allows remote control and monitoring via a mobile app.

---

## 🚀 Features
- 📱 **Flutter Mobile App** – Control and monitor feeding schedules.
- 🍲 **Automated Food Dispenser** – Set number of meals, portion size (grams), and meal intervals.
- 💧 **Water Control** – Dispense and track water in milliliters.
- 🌐 **MQTT Integration** – Real-time communication between app and ESP32.
- 🗄 **Supabase Database** – Store feeding schedules and logs.
- 🔔 **Notifications & Dashboard** – Monitor status and receive updates.

---

## 🛠 Tech Stack
- **Hardware**: ESP32, Servo Motor, IR Sensor, LDR, Buzzer, Push Button, LCD
- **IoT Protocol**: MQTT (HiveMQ)
- **Backend**: Supabase (PostgreSQL + Auth)
- **Mobile App**: Flutter
- **Cloud Services**: HiveMQ Cloud, Supabase

---

## 📂 Project Structure
```bash
Pet_Care_System-IOT/
│── esp32_code/          # ESP32 Arduino/PlatformIO code
│── flutter_app/         # Flutter mobile app
│── docs/                # Documentation, diagrams, schematics
│── README.md            # Project description
