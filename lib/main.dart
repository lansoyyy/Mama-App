import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mama_app/firebase_options.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/features/medinfo_hub_screen.dart';
import 'screens/features/smart_medguide_screen.dart';
import 'screens/features/ai_assistant_screen.dart';
import 'screens/features/consultation_screen.dart';
import 'screens/features/rewards_screen.dart';
import 'screens/features/symptom_tracker_screen.dart';
import 'screens/features/health_journal_screen.dart';
import 'screens/features/pharmacy_locator_screen.dart';
import 'screens/features/emergency_screen.dart';
import 'screens/features/multi_user_screen.dart';
import 'screens/features/health_records_screen.dart';
import 'screens/features/milestone_tracker_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/auth/forgot_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'mama-app-7bce7',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MamaApp());
}

class MamaApp extends StatelessWidget {
  const MamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Initial route
      initialRoute: '/',

      // Routes
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/medinfo-hub': (context) => const MedInfoHubScreen(),
        '/smart-medguide': (context) => const SmartMedGuideScreen(),
        '/ai-assistant': (context) => const AIAssistantScreen(),
        '/consultation': (context) => const ConsultationScreen(),
        '/rewards': (context) => const RewardsScreen(),
        '/symptom-tracker': (context) => const SymptomTrackerScreen(),
        '/health-journal': (context) => const HealthJournalScreen(),
        '/pharmacy-locator': (context) => const PharmacyLocatorScreen(),
        '/emergency': (context) => const EmergencyScreen(),
        '/multi-user': (context) => const MultiUserScreen(),
        '/health-records': (context) => const HealthRecordsScreen(),
        '/milestone-tracker': (context) => const MilestoneTrackerScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}
