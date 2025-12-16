import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mama_app/screens/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../services/local_notification_service.dart';

/// Auth Wrapper - Handles automatic login based on Firebase Auth state
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? _lastSyncedUserId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is logged in, show home screen
        if (snapshot.hasData && snapshot.data != null) {
          final uid = snapshot.data!.uid;
          if (_lastSyncedUserId != uid) {
            _lastSyncedUserId = uid;
            Future.microtask(() async {
              await LocalNotificationService.instance
                  .syncUserMedicationReminders(uid);
            });
          }
          return const HomeScreen();
        }

        // If user is not logged in, show login screen
        _lastSyncedUserId = null;
        return const OnboardingScreen();
      },
    );
  }
}
