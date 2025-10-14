# 🩷 MAMA APP (Medical Adherence Maternal Application)

A comprehensive maternal health and medication adherence platform designed to help mothers and caregivers manage medicines, track adherence, and connect with health professionals.

## Features

### 🤖 Core Features
- **AI Health Assistant** - Virtual health companion with personalized recommendations
- **Multi-User Access** - Manage medications for family members
- **Offline Access** - Key features available without internet connection

### 💊 Main Features
1. **MedInfo Hub** - Medication education in English, Filipino, and Cebuano
2. **Smart MedGuide** - Interactive learning and adherence tracking
3. **Personalized Medication Schedule** - Organized daily timeline
4. **Reward & Motivation System** - Gamified adherence with points and badges
5. **Secure Chat & Messaging** - Connect with health workers
6. **Virtual Consultation** - Video/audio calls with professionals
7. **Prescription Verification** - Upload and verify prescriptions
8. **Adherence Tracker** - Timely reminders and progress tracking
9. **Drug Interaction Checker** - Safety alerts
10. **Health Record Integration** - Store medical documents
11. **Symptom & Side Effect Tracker** - Log and monitor symptoms
12. **Medication Refill Locator** - Find nearby pharmacies
13. **Emergency Guidance** - Quick access to emergency help
14. **Voice-Assisted Navigation** - Hands-free operation
15. **Daily Health Journal** - Track symptoms, moods, and meals
16. **Health Milestone Tracker** - Monitor maternal and baby progress

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── utils/                    # Utilities and constants
│   ├── colors.dart          # Color palette
│   ├── constants.dart       # App constants
│   └── theme.dart           # Theme configuration
├── widgets/                  # Reusable widgets
│   ├── custom_app_bar.dart
│   ├── custom_button.dart
│   ├── custom_card.dart
│   ├── medication_card.dart
│   ├── feature_card.dart
│   ├── stat_card.dart
│   ├── empty_state.dart
│   └── loading_indicator.dart
├── screens/                  # App screens
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── auth/                # Authentication screens
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home/                # Home and dashboard
│   │   └── home_screen.dart
│   ├── features/            # Feature screens
│   │   ├── medinfo_hub_screen.dart
│   │   ├── smart_medguide_screen.dart
│   │   ├── ai_assistant_screen.dart
│   │   ├── consultation_screen.dart
│   │   ├── rewards_screen.dart
│   │   ├── symptom_tracker_screen.dart
│   │   ├── health_journal_screen.dart
│   │   ├── pharmacy_locator_screen.dart
│   │   ├── emergency_screen.dart
│   │   ├── multi_user_screen.dart
│   │   ├── health_records_screen.dart
│   │   └── milestone_tracker_screen.dart
│   └── profile/             # Profile screens
│       └── profile_screen.dart
└── services/                # Business logic services
    ├── api_service.dart
    ├── auth_service.dart
    ├── notification_service.dart
    └── storage_service.dart
```

## Color Theme

The app uses a warm, maternal color palette:
- **Primary**: Warm pink (#FF6B9D) - Maternal warmth
- **Secondary**: Calming purple (#9C27B0) - Trust and care
- **Accent**: Vibrant pink (#FF4081) - Energy and action
- **Background**: Soft pink (#FFF5F7) - Comfort

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- iOS/Android device or emulator

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd Mama-App
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## Next Steps (Backend Integration)

The UI is complete. To make the app functional, implement:

1. **API Integration** - Connect to backend services
2. **Authentication** - User login/signup with Firebase or custom backend
3. **Database** - Store user data, medications, and health records
4. **Notifications** - Local notifications for medication reminders
5. **AI Integration** - Connect AI assistant to health API
6. **Video Calling** - Implement consultation video/audio calls
7. **Maps Integration** - Add pharmacy location services
8. **Offline Storage** - Implement local data caching

## Dependencies to Add

Add these to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.0.0
  
  # Networking
  http: ^1.1.0
  dio: ^5.0.0
  
  # Local Storage
  shared_preferences: ^2.2.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Notifications
  flutter_local_notifications: ^16.0.0
  
  # UI Components
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  
  # Maps & Location
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  
  # Video Calling
  agora_rtc_engine: ^6.3.0
  
  # Utils
  intl: ^0.18.0
  url_launcher: ^6.2.0
```

## License

This project is licensed under the MIT License.

## Support

For support, contact the development team or open an issue in the repository.
