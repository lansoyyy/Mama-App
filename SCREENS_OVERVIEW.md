# Mama App - Screens Overview

## Authentication Screens

### 1. Splash Screen (`splash_screen.dart`)
- Animated app logo and name
- Auto-navigates to onboarding or home

### 2. Onboarding Screen (`onboarding_screen.dart`)
- 4-page introduction to app features
- Swipeable pages with skip option
- Features: Medication management, reminders, AI assistant, consultations

### 3. Login Screen (`auth/login_screen.dart`)
- Email and password login
- Forgot password link
- Sign up navigation

### 4. Signup Screen (`auth/signup_screen.dart`)
- User registration with user type selection (Mother, Caregiver, Health Worker)
- Form validation
- Password confirmation

## Main Navigation

### 5. Home Screen (`home/home_screen.dart`)
- Bottom navigation with 4 tabs: Home, Medications, Features, Profile
- Dashboard with:
  - Adherence statistics
  - Today's medication schedule
  - Quick action buttons (AI Assistant, Consultation, Emergency, Pharmacy)
  - Streak and reward points

## Feature Screens

### 6. MedInfo Hub (`features/medinfo_hub_screen.dart`)
- Medication education center
- Multi-language support (English, Filipino, Cebuano)
- Search functionality
- Categories: Prenatal vitamins, Iron, Folic acid, Calcium, Pain relief, Antibiotics

### 7. Smart MedGuide (`features/smart_medguide_screen.dart`)
- 3 tabs: Today, Schedule, History
- Today's progress with circular indicator
- Medication list with status (taken/pending/missed)
- Weekly schedule view
- Adherence history and statistics

### 8. AI Health Assistant (`features/ai_assistant_screen.dart`)
- Chat interface with AI
- Quick action chips for common queries
- Voice input option
- Real-time messaging

### 9. Virtual Consultation (`features/consultation_screen.dart`)
- 2 tabs: Book Consultation, My Appointments
- List of available health professionals
- Video/audio call options
- Appointment management

### 10. Rewards Screen (`features/rewards_screen.dart`)
- Points display with progress bar
- Current streak counter
- Achievement badges (earned and locked)
- Redeemable rewards catalog

### 11. Symptom Tracker (`features/symptom_tracker_screen.dart`)
- Symptom selection chips
- Severity level selector (Mild, Moderate, Severe)
- Notes field
- Recent symptom logs

### 12. Health Journal (`features/health_journal_screen.dart`)
- Daily journal entries
- Mood and energy tracking
- Recent entries list
- Add entry dialog

### 13. Pharmacy Locator (`features/pharmacy_locator_screen.dart`)
- Search by location
- Filter options (Open now, 24 hours, Nearby)
- Pharmacy cards with:
  - Distance, rating, hours
  - Call and directions buttons

### 14. Emergency Screen (`features/emergency_screen.dart`)
- Emergency hotline (911)
- Quick access to:
  - Ambulance (117)
  - Fire Department (160)
  - Police (166)

### 15. Multi-User Management (`features/multi_user_screen.dart`)
- Family member list
- Add family member option
- User profiles with roles (Mother, Child, Elderly)

### 16. Health Records (`features/health_records_screen.dart`)
- 3 tabs: Prescriptions, Lab Results, Vaccinations
- Document upload capability
- Record history with dates

### 17. Milestone Tracker (`features/milestone_tracker_screen.dart`)
- Maternal milestones (postpartum recovery, breastfeeding)
- Baby milestones (weight gain, vaccinations)
- Progress bars for each milestone

### 18. Profile Screen (`profile/profile_screen.dart`)
- User information display
- Settings menu:
  - Notifications
  - Language
  - Theme
  - Privacy & Security
  - Help & Support
  - About
  - Logout

## Reusable Widgets

- **CustomAppBar**: Consistent app bar across screens
- **CustomButton**: Primary, secondary, outlined, and text button variants
- **CustomCard**: Flexible card component with gradient support
- **MedicationCard**: Specialized card for medication display
- **FeatureCard**: Card for feature navigation
- **StatCard**: Statistics display card
- **EmptyState**: Empty state placeholder
- **LoadingIndicator**: Loading spinner with optional message

## Theme & Colors

**Color Palette:**
- Primary: Warm Pink (#FF6B9D)
- Secondary: Purple (#9C27B0)
- Accent: Vibrant Pink (#FF4081)
- Background: Soft Pink (#FFF5F7)
- Status colors for medication tracking

**Typography:**
- Material Design 3 text styles
- Custom font sizes for consistency
- Proper hierarchy and readability

## Navigation Routes

All screens are registered in `main.dart` with named routes:
- `/` - Splash
- `/onboarding` - Onboarding
- `/login` - Login
- `/signup` - Signup
- `/home` - Home Dashboard
- `/medinfo-hub` - MedInfo Hub
- `/smart-medguide` - Smart MedGuide
- `/ai-assistant` - AI Assistant
- `/consultation` - Virtual Consultation
- `/rewards` - Rewards
- `/symptom-tracker` - Symptom Tracker
- `/health-journal` - Health Journal
- `/pharmacy-locator` - Pharmacy Locator
- `/emergency` - Emergency
- `/multi-user` - Multi-User Management
- `/health-records` - Health Records
- `/milestone-tracker` - Milestone Tracker

## Total Screens Created: 18
## Total Widgets Created: 8
## Total Utility Files: 3
## Total Service Files: 4
