# PecheTech SuperApp

## 📝 Overview
The PecheTech SuperApp is the main user-facing mobile application. Built with Flutter, it aggregates the functionalities of all backend services (Benefits, Fuel, Weather, etc.) into a unified, cross-platform mobile experience.

## 🛠 Tech Stack
- **Framework:** Flutter
- **Language:** Dart
- **Architecture:** Feature-first / Clean Architecture

## 📂 Project Structure
- `/lib`: Main source code
  - `/core`: Core utilities, networking, and generic services
  - `/features`: Feature-based modules (each containing its UI and logic)
  - `/shared`: Shared UI components and widgets
  - `/local_storage`: Local database and caching logic
- `/assets`: Static resources (images, icons, translations)
- `/test`: Unit and widget tests
- `/docs`: App architecture documentation

## ⚙️ Prerequisites
- Flutter SDK
- Android Studio / Xcode
- Dart SDK

## 🚀 Setup & Installation
1. Fetch dependencies:
   ```bash
   flutter pub get
   ```

## 🏃‍♂️ Running the Application
Run the app on a connected device or emulator:
```bash
flutter run
```

## 🧪 Testing
```bash
flutter test
```
