# 🌊 TideUp

**Gamified beach cleanup app with crypto rewards**

TideUp transforms beach cleanups into an engaging mobile game where volunteers earn XP, level up, and convert in-app coins to Solana (SOL) cryptocurrency.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Solana](https://img.shields.io/badge/Solana-9945FF?style=for-the-badge&logo=solana&logoColor=white)
![Gemini](https://img.shields.io/badge/Google%20Gemini-4285F4?style=for-the-badge&logo=google&logoColor=white)

## ✨ Features

### For Players
- 🗺️ Browse and join cleanup missions on an interactive map
- 📸 Check in with before/after photos
- ⭐ Earn XP and level up (20 levels: Beach Newbie → Ocean Legend)
- 💰 Convert coins to Solana cryptocurrency
- 🏆 Compete on leaderboards
- 🎖️ Unlock achievements
- 🤖 AI chat assistant for tips and help

### For Organizations
- 📋 Create and manage cleanup missions
- 📍 Set custom locations with Google Maps
- 🤖 AI-powered photo verification (Gemini)
- 📊 Track volunteer impact metrics

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Auth, Firestore, Storage)
- **AI:** Google Gemini 2.5 Flash
- **Blockchain:** Solana (devnet)
- **Maps:** Google Maps API
- **State Management:** Riverpod

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Android Studio or VS Code
- Firebase account
- Google Cloud account (for Maps & Gemini APIs)

### Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/sudarshan-sridhar/tideup.git
   cd tideup
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Keys**

   Copy the example files and add your keys:
   
   ```bash
   # Gemini API key
   cp lib/core/config/env.dart.example lib/core/config/env.dart
   # Edit env.dart and add your Gemini API key
   
   # Google Maps API key
   cp android/app/src/main/AndroidManifest.xml.example android/app/src/main/AndroidManifest.xml
   # Edit AndroidManifest.xml and add your Google Maps API key
   ```

4. **Firebase Setup**
   
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable Authentication, Firestore, and Storage
   - Run `flutterfire configure` to generate `firebase_options.dart`
   - Add `google-services.json` to `android/app/`

5. **Run the app**
   ```bash
   flutter run
   ```

## 🔑 API Keys Required

| Service | Where to Get | Used For |
|---------|--------------|----------|
| Gemini API | [Google AI Studio](https://makersuite.google.com/app/apikey) | Photo verification, AI chat |
| Google Maps | [Cloud Console](https://console.cloud.google.com/apis/credentials) | Mission locations map |
| Firebase | [Firebase Console](https://console.firebase.google.com) | Auth, database, storage |

## 📱 Demo Accounts

For testing without creating an account:

| Role | Email | Password |
|------|-------|----------|
| Player | demo.player@tideup.app | demo123456 |
| Organization | demo.org@tideup.app | demo123456 |

## 📁 Project Structure

```
lib/
├── core/
│   ├── config/         # Environment config (API keys)
│   ├── constants/      # App constants
│   ├── theme/          # Colors, themes
│   └── widgets/        # Shared widgets
├── features/
│   ├── auth/           # Login, registration
│   ├── home/           # Main screens, providers
│   ├── missions/       # Mission CRUD, check-ins
│   ├── community/      # Posts, social features
│   ├── profile/        # Player & org profiles
│   ├── wallet/         # Solana integration
│   ├── leaderboard/    # Rankings
│   └── ai_assistant/   # Gemini chat
└── services/
    ├── firebase/       # Firebase service
    ├── gemini/         # Gemini AI service
    └── solana/         # Blockchain service
```

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first.

## 📄 License

[MIT](LICENSE)

## 👥 Team

Built for the Solana Hackathon

---

*Clean beaches. Earn crypto. Save oceans.* 🌊🐢♻️
