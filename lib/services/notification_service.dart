import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';
import 'auth_service.dart';

/// Service for managing automated notifications
class NotificationService {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  /// Check for due medication reminders and generate notifications
  Future<void> checkMedicationReminders() async {
    try {
      // Get all users with active medications
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('rewardPoints',
              isGreaterThanOrEqualTo: 0) // Basic filter to get users
          .get();

      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;
        await _checkUserMedicationReminders(userId);
      }
    } catch (e) {
      print('Error checking medication reminders: $e');
    }
  }

  /// Check medication reminders for a specific user
  Future<void> _checkUserMedicationReminders(String userId) async {
    try {
      DateTime now = DateTime.now();
      DateTime fifteenMinutesFromNow = now.add(const Duration(minutes: 15));
      DateTime oneHourAgo = now.subtract(const Duration(hours: 1));

      // Get today's medication logs that are pending and within reminder window
      QuerySnapshot pendingLogs = await FirebaseFirestore.instance
          .collection('medication_logs')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .where('scheduledDate', isGreaterThanOrEqualTo: oneHourAgo)
          .where('scheduledDate', isLessThanOrEqualTo: fifteenMinutesFromNow)
          .get();

      // Check if we already sent a reminder for these medications today
      for (var logDoc in pendingLogs.docs) {
        Map<String, dynamic> logData = logDoc.data() as Map<String, dynamic>;
        String medicationId = logData['medicationId'] ?? '';
        DateTime scheduledDate =
            (logData['scheduledDate'] as Timestamp).toDate();
        String medicationName = logData['medicationName'] ?? 'Medication';
        String dosage = logData['dosage'] ?? 'Unknown dosage';

        // Check if we already sent a reminder for this specific dose
        bool alreadyReminded =
            await _checkIfReminderExists(userId, medicationId, scheduledDate);

        if (!alreadyReminded) {
          await _firestoreService.generateMedicationReminder(
            userId: userId,
            medicationName: medicationName,
            dosage: dosage,
            scheduledTime: scheduledDate,
          );
        }
      }
    } catch (e) {
      print('Error checking user medication reminders: $e');
    }
  }

  /// Check if a reminder notification already exists for this medication dose
  Future<bool> _checkIfReminderExists(
      String userId, String medicationId, DateTime scheduledDate) async {
    try {
      // Check for existing reminder notification for this specific dose
      QuerySnapshot existingNotifications = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'medication_reminder')
          .where('data.medicationId', isEqualTo: medicationId)
          .where('timestamp',
              isGreaterThan: scheduledDate.subtract(const Duration(hours: 2)))
          .where('timestamp',
              isLessThan: scheduledDate.add(const Duration(minutes: 30)))
          .limit(1)
          .get();

      return existingNotifications.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if reminder exists: $e');
      return false;
    }
  }

  /// Generate daily health tips
  Future<void> generateDailyHealthTips() async {
    try {
      List<String> healthTips = [
        'Remember to stay hydrated! Drink at least 8 glasses of water daily.',
        'Take short walks to improve circulation and reduce swelling.',
        'Practice deep breathing exercises to reduce stress.',
        'Eat a balanced diet rich in fruits and vegetables.',
        'Get adequate rest - aim for 7-9 hours of sleep.',
        'Do gentle stretches to relieve back pain.',
        'Monitor your blood pressure regularly.',
        'Keep track of fetal movements daily.',
        'Avoid standing for long periods to reduce swelling.',
        'Wear comfortable shoes with good support.',
      ];

      DateTime now = DateTime.now();
      int dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
      String todayTip = healthTips[dayOfYear % healthTips.length];

      // Get all users
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;

        // Check if we already sent a health tip today
        bool alreadySent = await _checkIfHealthTipSentToday(userId);

        if (!alreadySent) {
          await _firestoreService.generateHealthTipNotification(
            userId: userId,
            tip: todayTip,
          );
        }
      }
    } catch (e) {
      print('Error generating daily health tips: $e');
    }
  }

  /// Check if a health tip was already sent today
  Future<bool> _checkIfHealthTipSentToday(String userId) async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      QuerySnapshot existingTips = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'health_tip')
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThan: endOfDay)
          .limit(1)
          .get();

      return existingTips.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if health tip was sent today: $e');
      return false;
    }
  }

  /// Check for upcoming appointments and send reminders
  Future<void> checkAppointmentReminders() async {
    try {
      DateTime now = DateTime.now();
      DateTime tomorrow = now.add(const Duration(days: 1));
      DateTime startOfTomorrow =
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      DateTime endOfTomorrow = startOfTomorrow.add(const Duration(days: 1));

      // Get all upcoming appointments for tomorrow
      QuerySnapshot upcomingAppointments = await FirebaseFirestore.instance
          .collection('appointments')
          .where('dateTime', isGreaterThanOrEqualTo: startOfTomorrow)
          .where('dateTime', isLessThan: endOfTomorrow)
          .where('status', isEqualTo: 'upcoming')
          .get();

      for (var appointmentDoc in upcomingAppointments.docs) {
        Map<String, dynamic> appointmentData =
            appointmentDoc.data() as Map<String, dynamic>;
        String userId = appointmentData['userId'] ?? '';
        String professionalName =
            appointmentData['professionalName'] ?? 'Healthcare Provider';
        DateTime appointmentTime =
            (appointmentData['dateTime'] as Timestamp).toDate();

        // Check if we already sent a reminder for this appointment
        bool alreadyReminded =
            await _checkIfAppointmentReminderExists(userId, appointmentDoc.id);

        if (!alreadyReminded) {
          await _firestoreService.generateAppointmentReminderNotification(
            userId: userId,
            professionalName: professionalName,
            appointmentTime: appointmentTime,
          );
        }
      }
    } catch (e) {
      print('Error checking appointment reminders: $e');
    }
  }

  /// Check if an appointment reminder already exists
  Future<bool> _checkIfAppointmentReminderExists(
      String userId, String appointmentId) async {
    try {
      DateTime now = DateTime.now();
      DateTime twentyFourHoursAgo = now.subtract(const Duration(hours: 24));

      QuerySnapshot existingReminders = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'appointment_reminder')
          .where('data.appointmentId', isEqualTo: appointmentId)
          .where('timestamp', isGreaterThan: twentyFourHoursAgo)
          .limit(1)
          .get();

      return existingReminders.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if appointment reminder exists: $e');
      return false;
    }
  }

  /// Clean up old notifications and generate new ones
  Future<void> performDailyNotificationMaintenance() async {
    try {
      // Get all users
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;

        // Delete old notifications (older than 30 days)
        await _firestoreService.deleteOldNotifications(userId);
      }

      // Generate new notifications
      await checkMedicationReminders();
      await generateDailyHealthTips();
      await checkAppointmentReminders();
    } catch (e) {
      print('Error performing daily notification maintenance: $e');
    }
  }

  /// Generate a test notification for development purposes
  Future<void> generateTestNotification(String type) async {
    try {
      String userId = _authService.currentUserId ?? '';
      if (userId.isEmpty) return;

      switch (type) {
        case 'medication_reminder':
          await _firestoreService.generateMedicationReminder(
            userId: userId,
            medicationName: 'Test Medication',
            dosage: '1 tablet',
            scheduledTime: DateTime.now(),
          );
          break;
        case 'streak_achievement':
          await _firestoreService.generateStreakAchievementNotification(
            userId: userId,
            streakDays: 7,
          );
          break;
        case 'reward_earned':
          await _firestoreService.generateRewardEarnedNotification(
            userId: userId,
            points: 50,
            reason: 'test notification',
          );
          break;
        case 'health_tip':
          await _firestoreService.generateHealthTipNotification(
            userId: userId,
            tip: 'This is a test health tip notification.',
          );
          break;
      }
    } catch (e) {
      print('Error generating test notification: $e');
    }
  }
}
