# MAMA App - Navigation Guide

## Overview
All screens now have proper navigation implemented with the Urbanist font family configured.

## Font Configuration
- **Regular**: Urbanist-Regular.ttf (body text)
- **Medium**: Urbanist-Medium.ttf (labels, titles)
- **Bold**: Urbanist-Bold.ttf (headings, display text)

## Navigation Flow

### Authentication Flow
1. **Splash Screen** → Auto-navigates to Onboarding after 3 seconds
2. **Onboarding Screen** → 
   - Skip button → Login Screen
   - Get Started button → Login Screen
3. **Login Screen** → 
   - Sign Up link → Signup Screen
   - Successful login → Home Screen
4. **Signup Screen** → 
   - Login link → Back to Login
   - Successful signup → Home Screen

### Main Navigation (Bottom Nav Bar)
- **Home Tab**: Dashboard with quick actions
- **Medications Tab**: Redirects to Smart MedGuide
- **Features Tab**: Shows all available features
- **Profile Tab**: User profile and settings

### Home Screen Quick Actions
- **AI Assistant** → AI Assistant Screen
- **Consultation** → Virtual Consultation Screen
- **Emergency** → Emergency Screen
- **Find Pharmacy** → Pharmacy Locator Screen
- **View All Medications** → Smart MedGuide Screen

### Features Screen Navigation
All features accessible from the Features tab:
1. MedInfo Hub → `/medinfo-hub`
2. Smart MedGuide → `/smart-medguide`
3. AI Health Assistant → `/ai-assistant`
4. Virtual Consultation → `/consultation`
5. Rewards & Achievements → `/rewards`
6. Symptom Tracker → `/symptom-tracker`
7. Health Journal → `/health-journal`
8. Find Pharmacy → `/pharmacy-locator`
9. Emergency Help → `/emergency`
10. Family Management → `/multi-user`
11. Health Records → `/health-records`
12. Milestone Tracker → `/milestone-tracker`

### Profile Screen Actions
- **Edit Profile** → Coming soon (snackbar)
- **Notifications** → Coming soon (snackbar)
- **Language** → Shows language selection dialog (English, Filipino, Cebuano)
- **Theme** → Coming soon (snackbar)
- **Privacy & Security** → Coming soon (snackbar)
- **Help & Support** → Coming soon (snackbar)
- **About** → Shows app information dialog
- **Logout** → Confirmation dialog → Login Screen

### Feature-Specific Navigation

#### MedInfo Hub
- Category cards → Show "coming soon" snackbar
- Search → Placeholder (no action yet)
- Language selector → Changes display language

#### Smart MedGuide
- Today/Schedule/History tabs → View different medication data
- Schedule cards → Show day details (snackbar)
- Add medication FAB → Coming soon (snackbar)

#### AI Assistant
- Quick action chips → Auto-fills message
- Voice input → Coming soon (snackbar)
- Send message → Simulates AI response

#### Virtual Consultation
- Professional cards → Shows booking dialog
- Book consultation → Video/Audio call selection
- Join appointment → Coming soon (snackbar)
- Cancel appointment → Coming soon (snackbar)

#### Rewards Screen
- Badges → Display only (no navigation)
- Redeem rewards → Shows redeem action

#### Symptom Tracker
- Symptom chips → Select/deselect symptoms
- Severity cards → Select severity level
- Log symptoms → Saves and shows success snackbar

#### Health Journal
- Add entry FAB → Shows entry dialog
- Quick stats → Display only
- Journal entries → Display only

#### Pharmacy Locator
- Search → Placeholder
- Location button → Coming soon (snackbar)
- Filter chips → Toggle filters
- Call button → Shows calling snackbar
- Directions button → Shows directions snackbar

#### Emergency Screen
- Call 911 → Shows calling snackbar
- Emergency contacts → Shows calling snackbar

#### Multi-User Management
- User cards → Shows profile (snackbar)
- Add family member → Coming soon (snackbar)

#### Health Records
- Record cards → Shows details (snackbar)
- Upload document FAB → Coming soon (snackbar)
- Tabs → Switch between Prescriptions/Lab Results/Vaccinations

#### Milestone Tracker
- Milestone cards → Display progress only

## Route Names
All routes are defined in `main.dart`:

```dart
'/' - SplashScreen
'/onboarding' - OnboardingScreen
'/login' - LoginScreen
'/signup' - SignupScreen
'/home' - HomeScreen
'/medinfo-hub' - MedInfoHubScreen
'/smart-medguide' - SmartMedGuideScreen
'/ai-assistant' - AIAssistantScreen
'/consultation' - ConsultationScreen
'/rewards' - RewardsScreen
'/symptom-tracker' - SymptomTrackerScreen
'/health-journal' - HealthJournalScreen
'/pharmacy-locator' - PharmacyLocatorScreen
'/emergency' - EmergencyScreen
'/multi-user' - MultiUserScreen
'/health-records' - HealthRecordsScreen
'/milestone-tracker' - MilestoneTrackerScreen
```

## Navigation Methods Used

### Push (keeps previous screen in stack)
```dart
Navigator.pushNamed(context, '/route-name');
```

### Push Replacement (removes previous screen)
```dart
Navigator.pushReplacementNamed(context, '/route-name');
```

### Push and Remove All (clears entire stack)
```dart
Navigator.pushNamedAndRemoveUntil(context, '/route-name', (route) => false);
```

### Pop (go back)
```dart
Navigator.pop(context);
```

## Snackbar Messages
Many features show "coming soon" snackbars for functionality that requires backend integration:
- Add medication
- Upload documents
- Video calls
- Phone calls
- Notifications
- Theme settings
- And more...

## Next Steps for Full Navigation
To complete the navigation system:
1. Implement backend API integration
2. Add state management (Provider/Riverpod)
3. Implement actual phone calling functionality
4. Add video call integration
5. Implement document upload
6. Add notification system
7. Implement search functionality
8. Add map integration for pharmacy locator
