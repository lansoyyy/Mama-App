import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

/// Firestore Service for managing user data
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _medicationsCollection =>
      _firestore.collection('medications');
  CollectionReference get _medicationLogsCollection =>
      _firestore.collection('medication_logs');
  CollectionReference get _healthRecordsCollection =>
      _firestore.collection('health_records');
  CollectionReference get _appointmentsCollection =>
      _firestore.collection('appointments');
  CollectionReference get _rewardsCollection =>
      _firestore.collection('rewards');
  CollectionReference get _userRewardsCollection =>
      _firestore.collection('user_rewards');
  CollectionReference get _achievementsCollection =>
      _firestore.collection('achievements');
  CollectionReference get _userAchievementsCollection =>
      _firestore.collection('user_achievements');
  CollectionReference get _symptomLogsCollection =>
      _firestore.collection('symptom_logs');
  CollectionReference get _healthJournalCollection =>
      _firestore.collection('health_journal');
  CollectionReference get _familyMembersCollection =>
      _firestore.collection('family_members');
  CollectionReference get _notificationsCollection =>
      _firestore.collection('notifications');
  CollectionReference get _bloodPressureCollection =>
      _firestore.collection('blood_pressure');

  /// Create user document
  Future<void> createUser({
    required String uid,
    required String email,
    required String fullName,
    required String userType,
    String? phoneNumber,
  }) async {
    try {
      await _usersCollection.doc(uid).set({
        'uid': uid,
        'email': email,
        'fullName': fullName,
        'userType': userType,
        'phoneNumber': phoneNumber ?? '',
        'profilePicture': '',
        'dateOfBirth': null,
        'bloodType': '',
        'address': '',
        'emergencyContact': '',
        'allergies': '',
        'chronicConditions': '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'adherenceRate': 0,
        'streakDays': 0,
        'rewardPoints': 0,
      });

      // Generate welcome notification
      await generateWelcomeNotification(
        userId: uid,
        userName: fullName,
      );
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  /// Get user data
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

  /// Get user data stream
  Stream<DocumentSnapshot> getUserStream(String uid) {
    return _usersCollection.doc(uid).snapshots();
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? fullName,
    String? phoneNumber,
    String? dateOfBirth,
    String? bloodType,
    String? address,
    String? emergencyContact,
    String? userType,
  }) async {
    try {
      Map<String, dynamic> updates = {};

      if (fullName != null) updates['fullName'] = fullName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (dateOfBirth != null) updates['dateOfBirth'] = dateOfBirth;
      if (bloodType != null) updates['bloodType'] = bloodType;
      if (address != null) updates['address'] = address;
      if (emergencyContact != null)
        updates['emergencyContact'] = emergencyContact;
      if (userType != null) updates['userType'] = userType;

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _usersCollection.doc(uid).update(updates);
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }

  /// Update medical information
  Future<void> updateMedicalInfo({
    required String uid,
    String? allergies,
    String? chronicConditions,
  }) async {
    try {
      Map<String, dynamic> updates = {};

      if (allergies != null) updates['allergies'] = allergies;
      if (chronicConditions != null)
        updates['chronicConditions'] = chronicConditions;

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _usersCollection.doc(uid).update(updates);
    } catch (e) {
      throw Exception('Error updating medical info: $e');
    }
  }

  /// Update profile picture URL
  Future<void> updateProfilePicture(String uid, String pictureUrl) async {
    try {
      await _usersCollection.doc(uid).update({
        'profilePicture': pictureUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error updating profile picture: $e');
    }
  }

  /// Update last login time
  Future<void> updateLastLogin(String uid) async {
    try {
      await _usersCollection.doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error updating last login: $e');
    }
  }

  /// Update adherence stats
  Future<void> updateAdherenceStats({
    required String uid,
    int? adherenceRate,
    int? streakDays,
    int? rewardPoints,
  }) async {
    try {
      Map<String, dynamic> updates = {};

      if (adherenceRate != null) updates['adherenceRate'] = adherenceRate;
      if (streakDays != null) updates['streakDays'] = streakDays;
      if (rewardPoints != null) updates['rewardPoints'] = rewardPoints;

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _usersCollection.doc(uid).update(updates);
    } catch (e) {
      throw Exception('Error updating adherence stats: $e');
    }
  }

  /// Delete user and all associated data
  Future<void> deleteUser(String uid) async {
    try {
      // Delete user medications
      QuerySnapshot medications =
          await _medicationsCollection.where('userId', isEqualTo: uid).get();
      for (var doc in medications.docs) {
        await doc.reference.delete();
      }

      // Delete user health records
      QuerySnapshot healthRecords =
          await _healthRecordsCollection.where('userId', isEqualTo: uid).get();
      for (var doc in healthRecords.docs) {
        await doc.reference.delete();
      }

      // Delete user document
      await _usersCollection.doc(uid).delete();
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  /// Add medication
  Future<String> addMedication({
    required String userId,
    required String name,
    required String dosage,
    required String frequency,
    required String time,
    String? notes,
  }) async {
    try {
      DocumentReference doc = await _medicationsCollection.add({
        'userId': userId,
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'time': time,
        'notes': notes ?? '',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      throw Exception('Error adding medication: $e');
    }
  }

  /// Get user medications
  Stream<QuerySnapshot> getUserMedications(String userId) {
    return _medicationsCollection
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Update medication
  Future<void> updateMedication({
    required String medicationId,
    String? name,
    String? dosage,
    String? frequency,
    String? time,
    String? notes,
    bool? isActive,
  }) async {
    try {
      Map<String, dynamic> updates = {};

      if (name != null) updates['name'] = name;
      if (dosage != null) updates['dosage'] = dosage;
      if (frequency != null) updates['frequency'] = frequency;
      if (time != null) updates['time'] = time;
      if (notes != null) updates['notes'] = notes;
      if (isActive != null) updates['isActive'] = isActive;

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _medicationsCollection.doc(medicationId).update(updates);
    } catch (e) {
      throw Exception('Error updating medication: $e');
    }
  }

  /// Delete medication
  Future<void> deleteMedication(String medicationId) async {
    try {
      await _medicationsCollection.doc(medicationId).delete();
    } catch (e) {
      throw Exception('Error deleting medication: $e');
    }
  }

  /// Add health record
  Future<String> addHealthRecord({
    required String userId,
    required String type,
    required String title,
    required String provider,
    required String date,
    String? notes,
    String? fileUrl,
  }) async {
    try {
      DocumentReference doc = await _healthRecordsCollection.add({
        'userId': userId,
        'type': type,
        'title': title,
        'provider': provider,
        'date': date,
        'notes': notes ?? '',
        'fileUrl': fileUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      throw Exception('Error adding health record: $e');
    }
  }

  /// Get user health records
  Stream<QuerySnapshot> getUserHealthRecords(String userId) {
    return _healthRecordsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  /// Delete health record
  Future<void> deleteHealthRecord(String recordId) async {
    try {
      await _healthRecordsCollection.doc(recordId).delete();
    } catch (e) {
      throw Exception('Error deleting health record: $e');
    }
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      QuerySnapshot query = await _usersCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error checking email: $e');
    }
  }

  /// Update user adherence stats
  Future<void> updateUserAdherenceStats(String userId) async {
    try {
      // Get current user stats
      DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) return;

      int currentPoints = userDoc.get('rewardPoints') ?? 0;
      int currentStreak = userDoc.get('streakDays') ?? 0;

      // Add points for taking medication
      int newPoints = currentPoints + AppConstants.pointsPerDose;

      // Check if streak should be updated
      DateTime now = DateTime.now();
      DateTime yesterday = now.subtract(const Duration(days: 1));
      DateTime startOfYesterday =
          DateTime(yesterday.year, yesterday.month, yesterday.day);
      DateTime endOfYesterday = startOfYesterday.add(const Duration(days: 1));

      // Check if user took any medications yesterday
      QuerySnapshot yesterdayLogs = await _medicationLogsCollection
          .where('userId', isEqualTo: userId)
          .where('scheduledDate', isGreaterThanOrEqualTo: startOfYesterday)
          .where('scheduledDate', isLessThan: endOfYesterday)
          .where('status', isEqualTo: 'taken')
          .get();

      int newStreak = currentStreak;
      if (yesterdayLogs.docs.isNotEmpty) {
        // User took medications yesterday, increment streak
        newStreak = currentStreak + 1;
      } else {
        // Reset streak if no medications taken yesterday
        newStreak = 1;
      }

      // Update user stats
      await _usersCollection.doc(userId).update({
        'rewardPoints': newPoints,
        'streakDays': newStreak,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Generate notifications for achievements
      if (newStreak > currentStreak && newStreak > 1) {
        await generateStreakAchievementNotification(
          userId: userId,
          streakDays: newStreak,
        );
      }

      if (newPoints > currentPoints) {
        await generateRewardEarnedNotification(
          userId: userId,
          points: newPoints - currentPoints,
          reason: 'medication adherence',
        );
      }
    } catch (e) {
      print('Error updating user adherence stats: $e');
    }
  }

  /// Get today's medication logs for a user
  Stream<QuerySnapshot> getTodayMedicationLogs(String userId) {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    return _medicationLogsCollection
        .where('userId', isEqualTo: userId)
        .where('scheduledDate', isGreaterThanOrEqualTo: startOfDay)
        .where('scheduledDate', isLessThan: endOfDay)
        .orderBy('scheduledDate')
        .snapshots();
  }

  /// Log medication intake
  Future<String> logMedicationIntake({
    required String userId,
    required String medicationId,
    required String medicationName,
    required String dosage,
    required DateTime scheduledDate,
    required String status,
    String? notes,
  }) async {
    try {
      DocumentReference doc = await _medicationLogsCollection.add({
        'userId': userId,
        'medicationId': medicationId,
        'medicationName': medicationName,
        'dosage': dosage,
        'scheduledDate': scheduledDate,
        'takenDate': status == 'taken' ? FieldValue.serverTimestamp() : null,
        'status': status,
        'notes': notes ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update user adherence stats if medication was taken
      if (status == 'taken') {
        updateUserAdherenceStats(userId);
      }

      return doc.id;
    } catch (e) {
      throw Exception('Error logging medication intake: $e');
    }
  }

  /// Update medication intake status
  Future<void> updateMedicationIntakeStatus({
    required String logId,
    required String status,
    String? notes,
  }) async {
    try {
      Map<String, dynamic> updates = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status == 'taken') {
        updates['takenDate'] = FieldValue.serverTimestamp();
      }

      if (notes != null) {
        updates['notes'] = notes;
      }

      await _medicationLogsCollection.doc(logId).update(updates);

      // Get the log to find userId for stats update
      DocumentSnapshot logDoc =
          await _medicationLogsCollection.doc(logId).get();
      if (logDoc.exists) {
        String userId = logDoc.get('userId');
        String medicationName = logDoc.get('medicationName') ?? 'Medication';
        String dosage = logDoc.get('dosage') ?? 'Unknown dosage';

        if (status == 'taken') {
          updateUserAdherenceStats(userId);
          await generateMedicationTakenNotification(
            userId: userId,
            medicationName: medicationName,
            dosage: dosage,
          );
        } else if (status == 'missed') {
          await generateMedicationMissedNotification(
            userId: userId,
            medicationName: medicationName,
            dosage: dosage,
          );
        }
      }
    } catch (e) {
      throw Exception('Error updating medication intake status: $e');
    }
  }

  /// Get medication adherence statistics for a user
  Future<Map<String, dynamic>> getMedicationStats(String userId) async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));
      DateTime weekAgo = now.subtract(const Duration(days: 7));

      // Get today's scheduled doses
      QuerySnapshot todayLogs = await _medicationLogsCollection
          .where('userId', isEqualTo: userId)
          .where('scheduledDate', isGreaterThanOrEqualTo: startOfDay)
          .where('scheduledDate', isLessThan: endOfDay)
          .get();

      // Get this week's logs for adherence calculation
      QuerySnapshot weekLogs = await _medicationLogsCollection
          .where('userId', isEqualTo: userId)
          .where('scheduledDate', isGreaterThanOrEqualTo: weekAgo)
          .get();

      // Get all active medications
      QuerySnapshot activeMeds = await _medicationsCollection
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      int totalScheduled = todayLogs.docs.length;
      int totalTaken = 0;
      int totalMissed = 0;
      int totalPending = 0;

      for (var doc in todayLogs.docs) {
        String status = doc.get('status');
        if (status == 'taken') {
          totalTaken++;
        } else if (status == 'missed') {
          totalMissed++;
        } else if (status == 'pending') {
          totalPending++;
        }
      }

      // Calculate adherence rate for the week
      int weekTotal = weekLogs.docs.length;
      int weekTaken = 0;
      for (var doc in weekLogs.docs) {
        if (doc.get('status') == 'taken') {
          weekTaken++;
        }
      }

      double adherenceRate =
          weekTotal > 0 ? (weekTaken / weekTotal) * 100 : 0.0;

      // Get user stats
      DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();
      int streakDays = 0;
      int rewardPoints = 0;

      if (userDoc.exists) {
        streakDays = userDoc.get('streakDays') ?? 0;
        rewardPoints = userDoc.get('rewardPoints') ?? 0;
      }

      return {
        'totalScheduled': totalScheduled,
        'totalTaken': totalTaken,
        'totalMissed': totalMissed,
        'totalPending': totalPending,
        'adherenceRate': adherenceRate.round(),
        'activeMedications': activeMeds.docs.length,
        'streakDays': streakDays,
        'rewardPoints': rewardPoints,
      };
    } catch (e) {
      throw Exception('Error getting medication stats: $e');
    }
  }

  /// Generate medication logs for the day
  Future<void> generateDailyMedicationLogs(String userId) async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      // Get all active medications for the user
      QuerySnapshot medications = await _medicationsCollection
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      // Check if logs already exist for today
      QuerySnapshot existingLogs = await _medicationLogsCollection
          .where('userId', isEqualTo: userId)
          .where('scheduledDate', isGreaterThanOrEqualTo: startOfDay)
          .where('scheduledDate', isLessThan: endOfDay)
          .get();

      // If logs already exist, don't generate new ones
      if (existingLogs.docs.isNotEmpty) return;

      // Generate logs for each medication based on frequency
      for (var medDoc in medications.docs) {
        Map<String, dynamic> medication = medDoc.data() as Map<String, dynamic>;
        String medicationId = medDoc.id;
        String name = medication['name'];
        String dosage = medication['dosage'];
        String frequency = medication['frequency'];
        String timeStr = medication['time'];

        // Parse time
        List<String> timeParts = timeStr.split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1].split(' ')[0]);
        String period =
            timeParts.length > 1 ? timeParts[1].split(' ')[1] : 'AM';

        // Convert to 24-hour format
        if (period == 'PM' && hour < 12) {
          hour += 12;
        } else if (period == 'AM' && hour == 12) {
          hour = 0;
        }

        // Create scheduled date for today
        DateTime scheduledDate =
            DateTime(now.year, now.month, now.day, hour, minute);

        // If time has passed for today, schedule for tomorrow
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        // Create medication log based on frequency
        if (frequency == 'Daily') {
          await _medicationLogsCollection.add({
            'userId': userId,
            'medicationId': medicationId,
            'medicationName': name,
            'dosage': dosage,
            'scheduledDate': scheduledDate,
            'status': 'pending',
            'notes': '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else if (frequency == 'Twice Daily') {
          // Create two logs: one for morning (8 AM) and one for evening (8 PM)
          DateTime morningDate = DateTime(now.year, now.month, now.day, 8, 0);
          DateTime eveningDate = DateTime(now.year, now.month, now.day, 20, 0);

          // If times have passed, schedule for tomorrow
          if (morningDate.isBefore(now)) {
            morningDate = morningDate.add(const Duration(days: 1));
          }
          if (eveningDate.isBefore(now)) {
            eveningDate = eveningDate.add(const Duration(days: 1));
          }

          await _medicationLogsCollection.add({
            'userId': userId,
            'medicationId': medicationId,
            'medicationName': name,
            'dosage': dosage,
            'scheduledDate': morningDate,
            'status': 'pending',
            'notes': '',
            'createdAt': FieldValue.serverTimestamp(),
          });

          await _medicationLogsCollection.add({
            'userId': userId,
            'medicationId': medicationId,
            'medicationName': name,
            'dosage': dosage,
            'scheduledDate': eveningDate,
            'status': 'pending',
            'notes': '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else if (frequency == 'Three Times Daily') {
          // Create three logs: morning (8 AM), afternoon (2 PM), and evening (8 PM)
          DateTime morningDate = DateTime(now.year, now.month, now.day, 8, 0);
          DateTime afternoonDate =
              DateTime(now.year, now.month, now.day, 14, 0);
          DateTime eveningDate = DateTime(now.year, now.month, now.day, 20, 0);

          // If times have passed, schedule for tomorrow
          if (morningDate.isBefore(now)) {
            morningDate = morningDate.add(const Duration(days: 1));
          }
          if (afternoonDate.isBefore(now)) {
            afternoonDate = afternoonDate.add(const Duration(days: 1));
          }
          if (eveningDate.isBefore(now)) {
            eveningDate = eveningDate.add(const Duration(days: 1));
          }

          await _medicationLogsCollection.add({
            'userId': userId,
            'medicationId': medicationId,
            'medicationName': name,
            'dosage': dosage,
            'scheduledDate': morningDate,
            'status': 'pending',
            'notes': '',
            'createdAt': FieldValue.serverTimestamp(),
          });

          await _medicationLogsCollection.add({
            'userId': userId,
            'medicationId': medicationId,
            'medicationName': name,
            'dosage': dosage,
            'scheduledDate': afternoonDate,
            'status': 'pending',
            'notes': '',
            'createdAt': FieldValue.serverTimestamp(),
          });

          await _medicationLogsCollection.add({
            'userId': userId,
            'medicationId': medicationId,
            'medicationName': name,
            'dosage': dosage,
            'scheduledDate': eveningDate,
            'status': 'pending',
            'notes': '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else if (frequency == 'Weekly') {
          // Create one log for today
          await _medicationLogsCollection.add({
            'userId': userId,
            'medicationId': medicationId,
            'medicationName': name,
            'dosage': dosage,
            'scheduledDate': scheduledDate,
            'status': 'pending',
            'notes': '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      throw Exception('Error generating daily medication logs: $e');
    }
  }

  /// Book appointment
  Future<String> bookAppointment({
    required String userId,
    required String professionalId,
    required String professionalName,
    required String professionalSpecialty,
    required String mobileNumber,
    required DateTime dateTime,
    required String notes,
  }) async {
    try {
      DocumentReference doc = await _appointmentsCollection.add({
        'userId': userId,
        'professionalId': professionalId,
        'professionalName': professionalName,
        'professionalSpecialty': professionalSpecialty,
        'mobileNumber': mobileNumber,
        'dateTime': dateTime,
        'status': 'upcoming',
        'consultationType': 'call',
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      throw Exception('Error booking appointment: $e');
    }
  }

  /// Get user appointments
  Stream<QuerySnapshot> getUserAppointments(String userId) {
    return _appointmentsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('dateTime', descending: true)
        .snapshots();
  }

  /// Get upcoming appointments for a user
  Stream<QuerySnapshot> getUpcomingAppointments(String userId) {
    DateTime now = DateTime.now();
    return _appointmentsCollection
        .where('userId', isEqualTo: userId)
        .where('dateTime', isGreaterThan: now)
        .where('status', isEqualTo: 'upcoming')
        .orderBy('dateTime')
        .snapshots();
  }

  /// Get past appointments for a user
  Stream<QuerySnapshot> getPastAppointments(String userId) {
    DateTime now = DateTime.now();
    return _appointmentsCollection
        .where('userId', isEqualTo: userId)
        .where('dateTime', isLessThan: now)
        .orderBy('dateTime', descending: true)
        .snapshots();
  }

  /// Update appointment status
  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  }) async {
    try {
      await _appointmentsCollection.doc(appointmentId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error updating appointment status: $e');
    }
  }

  /// Cancel appointment
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await updateAppointmentStatus(
        appointmentId: appointmentId,
        status: 'cancelled',
      );
    } catch (e) {
      throw Exception('Error cancelling appointment: $e');
    }
  }

  /// Complete appointment
  Future<void> completeAppointment(String appointmentId) async {
    try {
      await updateAppointmentStatus(
        appointmentId: appointmentId,
        status: 'completed',
      );
    } catch (e) {
      throw Exception('Error completing appointment: $e');
    }
  }

  /// Delete appointment
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _appointmentsCollection.doc(appointmentId).delete();
    } catch (e) {
      throw Exception('Error deleting appointment: $e');
    }
  }

  /// Get appointment details
  Future<Map<String, dynamic>?> getAppointment(String appointmentId) async {
    try {
      DocumentSnapshot doc =
          await _appointmentsCollection.doc(appointmentId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw Exception('Error getting appointment: $e');
    }
  }

  /// Get all available rewards
  Stream<QuerySnapshot> getAvailableRewards() {
    return _rewardsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('pointsRequired')
        .snapshots();
  }

  /// Get user's redeemed rewards
  Stream<QuerySnapshot> getUserRewards(String userId) {
    return _userRewardsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('redeemedAt', descending: true)
        .snapshots();
  }

  /// Redeem a reward
  Future<void> redeemReward({
    required String userId,
    required String rewardId,
    required int pointsRequired,
  }) async {
    try {
      // Get user current points
      DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      int currentPoints = userDoc.get('rewardPoints') ?? 0;

      if (currentPoints < pointsRequired) {
        throw Exception('Insufficient points');
      }

      // Deduct points
      await _usersCollection.doc(userId).update({
        'rewardPoints': currentPoints - pointsRequired,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add to user rewards
      await _userRewardsCollection.add({
        'userId': userId,
        'rewardId': rewardId,
        'pointsUsed': pointsRequired,
        'redeemedAt': FieldValue.serverTimestamp(),
        'status': 'redeemed',
      });
    } catch (e) {
      throw Exception('Error redeeming reward: $e');
    }
  }

  /// Get all available achievements
  Stream<QuerySnapshot> getAvailableAchievements() {
    return _achievementsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('pointsAwarded', descending: true)
        .snapshots();
  }

  /// Get user's achievements
  Stream<QuerySnapshot> getUserAchievements(String userId) {
    return _userAchievementsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('earnedAt', descending: true)
        .snapshots();
  }

  /// Check and award achievements based on user stats
  Future<void> checkAndAwardAchievements(String userId) async {
    try {
      // Get user stats
      DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) return;

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      int streakDays = userData['streakDays'] ?? 0;
      int rewardPoints = userData['rewardPoints'] ?? 0;

      // Get medication stats
      Map<String, dynamic> medStats = await getMedicationStats(userId);
      int totalTaken = medStats['totalTaken'] ?? 0;
      double adherenceRate = (medStats['adherenceRate'] ?? 0).toDouble();

      // Get all available achievements
      QuerySnapshot achievements = await _achievementsCollection
          .where('isActive', isEqualTo: true)
          .get();

      // Get user's already earned achievements
      QuerySnapshot userAchievements = await _userAchievementsCollection
          .where('userId', isEqualTo: userId)
          .get();

      Set<String> earnedAchievementIds = userAchievements.docs
          .map((doc) => doc.get('achievementId').toString())
          .toSet();

      // Check each achievement
      for (var achievementDoc in achievements.docs) {
        Map<String, dynamic> achievement =
            achievementDoc.data() as Map<String, dynamic>;
        String achievementId = achievementDoc.id;

        // Skip if already earned
        if (earnedAchievementIds.contains(achievementId)) continue;

        String type = achievement['type'];
        bool criteriaMet = false;

        // Check achievement criteria
        switch (type) {
          case 'streak_days':
            int requiredDays = achievement['requiredValue'];
            criteriaMet = streakDays >= requiredDays;
            break;
          case 'total_points':
            int requiredPoints = achievement['requiredValue'];
            criteriaMet = rewardPoints >= requiredPoints;
            break;
          case 'total_doses':
            int requiredDoses = achievement['requiredValue'];
            criteriaMet = totalTaken >= requiredDoses;
            break;
          case 'adherence_rate':
            double requiredRate = achievement['requiredValue'].toDouble();
            criteriaMet = adherenceRate >= requiredRate;
            break;
        }

        // Award achievement if criteria met
        if (criteriaMet) {
          await _userAchievementsCollection.add({
            'userId': userId,
            'achievementId': achievementId,
            'earnedAt': FieldValue.serverTimestamp(),
            'pointsAwarded': achievement['pointsAwarded'],
          });

          // Add points to user
          int pointsAwarded = achievement['pointsAwarded'];
          await _usersCollection.doc(userId).update({
            'rewardPoints': rewardPoints + pointsAwarded,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Generate achievement notification
          await generateAchievementUnlockedNotification(
            userId: userId,
            achievementName: achievement['name'] ?? 'Achievement',
            pointsAwarded: pointsAwarded,
          );
        }
      }
    } catch (e) {
      print('Error checking achievements: $e');
    }
  }

  /// Get user's achievement progress
  Future<Map<String, dynamic>> getAchievementProgress(String userId) async {
    try {
      // Get user stats
      DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) return {};

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      int streakDays = userData['streakDays'] ?? 0;
      int rewardPoints = userData['rewardPoints'] ?? 0;

      // Get medication stats
      Map<String, dynamic> medStats = await getMedicationStats(userId);
      int totalTaken = medStats['totalTaken'] ?? 0;
      double adherenceRate = (medStats['adherenceRate'] ?? 0).toDouble();

      // Get user's achievements
      QuerySnapshot userAchievements = await _userAchievementsCollection
          .where('userId', isEqualTo: userId)
          .get();

      Set<String> earnedAchievementIds = userAchievements.docs
          .map((doc) => doc.get('achievementId').toString())
          .toSet();

      return {
        'streakDays': streakDays,
        'totalPoints': rewardPoints,
        'totalDoses': totalTaken,
        'adherenceRate': adherenceRate,
        'earnedAchievements': earnedAchievementIds.length,
        'earnedAchievementIds': earnedAchievementIds,
      };
    } catch (e) {
      throw Exception('Error getting achievement progress: $e');
    }
  }

  /// Add symptom log
  Future<String> addSymptomLog({
    required String userId,
    required List<String> symptoms,
    required String severity,
    required String notes,
    required DateTime timestamp,
  }) async {
    try {
      DocumentReference doc = await _symptomLogsCollection.add({
        'userId': userId,
        'symptoms': symptoms,
        'severity': severity,
        'notes': notes,
        'timestamp': timestamp,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      throw Exception('Error adding symptom log: $e');
    }
  }

  /// Get user symptom logs
  Stream<QuerySnapshot> getUserSymptomLogs(String userId) {
    return _symptomLogsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Get recent symptom logs for a user (last 7 days)
  Stream<QuerySnapshot> getRecentSymptomLogs(String userId) {
    DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return _symptomLogsCollection
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: sevenDaysAgo)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Get symptom logs for a specific date range
  Stream<QuerySnapshot> getSymptomLogsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _symptomLogsCollection
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Update symptom log
  Future<void> updateSymptomLog({
    required String logId,
    List<String>? symptoms,
    String? severity,
    String? notes,
    DateTime? timestamp,
  }) async {
    try {
      Map<String, dynamic> updates = {};

      if (symptoms != null) updates['symptoms'] = symptoms;
      if (severity != null) updates['severity'] = severity;
      if (notes != null) updates['notes'] = notes;
      if (timestamp != null) updates['timestamp'] = timestamp;

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _symptomLogsCollection.doc(logId).update(updates);
    } catch (e) {
      throw Exception('Error updating symptom log: $e');
    }
  }

  /// Delete symptom log
  Future<void> deleteSymptomLog(String logId) async {
    try {
      await _symptomLogsCollection.doc(logId).delete();
    } catch (e) {
      throw Exception('Error deleting symptom log: $e');
    }
  }

  /// Get symptom statistics for a user
  Future<Map<String, dynamic>> getSymptomStats(String userId) async {
    try {
      DateTime thirtyDaysAgo =
          DateTime.now().subtract(const Duration(days: 30));

      QuerySnapshot logs = await _symptomLogsCollection
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: thirtyDaysAgo)
          .get();

      Map<String, int> symptomFrequency = {};
      Map<String, int> severityCount = {
        'Mild': 0,
        'Moderate': 0,
        'Severe': 0,
      };

      int totalLogs = logs.docs.length;

      for (var doc in logs.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Count severity
        String severity = data['severity'] ?? '';
        if (severityCount.containsKey(severity)) {
          severityCount[severity] = (severityCount[severity] ?? 0) + 1;
        }

        // Count symptom frequency
        List<String> symptoms = List<String>.from(data['symptoms'] ?? []);
        for (String symptom in symptoms) {
          symptomFrequency[symptom] = (symptomFrequency[symptom] ?? 0) + 1;
        }
      }

      // Get most common symptoms
      List<Map<String, dynamic>> topSymptoms = symptomFrequency.entries
          .map((e) => {'symptom': e.key, 'count': e.value})
          .toList()
        ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      if (topSymptoms.length > 5) {
        topSymptoms = topSymptoms.take(5).toList();
      }

      return {
        'totalLogs': totalLogs,
        'severityCount': severityCount,
        'topSymptoms': topSymptoms,
        'dateRange': 'Last 30 days',
      };
    } catch (e) {
      throw Exception('Error getting symptom stats: $e');
    }
  }

  /// Add health journal entry
  Future<String> addHealthJournalEntry({
    required String userId,
    required String date,
    required String time,
    required String content,
    required List<String> tags,
    required String mood,
    required String energyLevel,
    required DateTime timestamp,
  }) async {
    try {
      DocumentReference doc = await _healthJournalCollection.add({
        'userId': userId,
        'date': date,
        'time': time,
        'content': content,
        'tags': tags,
        'mood': mood,
        'energyLevel': energyLevel,
        'timestamp': timestamp,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      throw Exception('Error adding health journal entry: $e');
    }
  }

  /// Get user health journal entries
  Stream<QuerySnapshot> getUserHealthJournalEntries(String userId) {
    return _healthJournalCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Get recent health journal entries for a user (last 7 days)
  Stream<QuerySnapshot> getRecentHealthJournalEntries(String userId) {
    DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return _healthJournalCollection
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: sevenDaysAgo)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Get today's health journal entry for a user
  Future<Map<String, dynamic>?> getTodayHealthJournalEntry(
      String userId) async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      QuerySnapshot query = await _healthJournalCollection
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThan: endOfDay)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw Exception('Error getting today\'s journal entry: $e');
    }
  }

  /// Update health journal entry
  Future<void> updateHealthJournalEntry({
    required String entryId,
    String? date,
    String? time,
    String? content,
    List<String>? tags,
    String? mood,
    String? energyLevel,
    DateTime? timestamp,
  }) async {
    try {
      Map<String, dynamic> updates = {};

      if (date != null) updates['date'] = date;
      if (time != null) updates['time'] = time;
      if (content != null) updates['content'] = content;
      if (tags != null) updates['tags'] = tags;
      if (mood != null) updates['mood'] = mood;
      if (energyLevel != null) updates['energyLevel'] = energyLevel;
      if (timestamp != null) updates['timestamp'] = timestamp;

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _healthJournalCollection.doc(entryId).update(updates);
    } catch (e) {
      throw Exception('Error updating health journal entry: $e');
    }
  }

  /// Delete health journal entry
  Future<void> deleteHealthJournalEntry(String entryId) async {
    try {
      await _healthJournalCollection.doc(entryId).delete();
    } catch (e) {
      throw Exception('Error deleting health journal entry: $e');
    }
  }

  /// Get health journal statistics for a user
  Future<Map<String, dynamic>> getHealthJournalStats(String userId) async {
    try {
      DateTime thirtyDaysAgo =
          DateTime.now().subtract(const Duration(days: 30));

      QuerySnapshot entries = await _healthJournalCollection
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: thirtyDaysAgo)
          .get();

      Map<String, int> moodCount = {
        'Great': 0,
        'Good': 0,
        'Okay': 0,
        'Not Good': 0,
        'Bad': 0,
      };

      Map<String, int> energyCount = {
        'High': 0,
        'Medium': 0,
        'Low': 0,
      };

      int totalEntries = entries.docs.length;

      for (var doc in entries.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Count mood
        String mood = data['mood'] ?? '';
        if (moodCount.containsKey(mood)) {
          moodCount[mood] = (moodCount[mood] ?? 0) + 1;
        }

        // Count energy level
        String energyLevel = data['energyLevel'] ?? '';
        if (energyCount.containsKey(energyLevel)) {
          energyCount[energyLevel] = (energyCount[energyLevel] ?? 0) + 1;
        }
      }

      // Find most common mood and energy level
      String mostCommonMood = 'Good';
      String mostCommonEnergy = 'Medium';
      int maxMoodCount = 0;
      int maxEnergyCount = 0;

      moodCount.forEach((mood, count) {
        if (count > maxMoodCount) {
          maxMoodCount = count;
          mostCommonMood = mood;
        }
      });

      energyCount.forEach((energy, count) {
        if (count > maxEnergyCount) {
          maxEnergyCount = count;
          mostCommonEnergy = energy;
        }
      });

      return {
        'totalEntries': totalEntries,
        'moodCount': moodCount,
        'energyCount': energyCount,
        'mostCommonMood': mostCommonMood,
        'mostCommonEnergy': mostCommonEnergy,
        'dateRange': 'Last 30 days',
      };
    } catch (e) {
      throw Exception('Error getting health journal stats: $e');
    }
  }

  /// Add family member
  Future<String> addFamilyMember({
    required String userId,
    required String name,
    required String relationship,
    required String info,
    String? profilePicture,
    bool isPrimary = false,
  }) async {
    try {
      DocumentReference doc = await _familyMembersCollection.add({
        'userId': userId,
        'name': name,
        'relationship': relationship,
        'info': info,
        'profilePicture': profilePicture ?? '',
        'isPrimary': isPrimary,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      throw Exception('Error adding family member: $e');
    }
  }

  /// Get family members for a user
  Stream<QuerySnapshot> getFamilyMembers(String userId) {
    return _familyMembersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('isPrimary', descending: true)
        .orderBy('createdAt')
        .snapshots();
  }

  /// Get family member by ID
  Future<Map<String, dynamic>?> getFamilyMember(String memberId) async {
    try {
      DocumentSnapshot doc = await _familyMembersCollection.doc(memberId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw Exception('Error getting family member: $e');
    }
  }

  /// Update family member
  Future<void> updateFamilyMember({
    required String memberId,
    String? name,
    String? relationship,
    String? info,
    String? profilePicture,
    bool? isPrimary,
  }) async {
    try {
      Map<String, dynamic> updates = {};

      if (name != null) updates['name'] = name;
      if (relationship != null) updates['relationship'] = relationship;
      if (info != null) updates['info'] = info;
      if (profilePicture != null) updates['profilePicture'] = profilePicture;
      if (isPrimary != null) updates['isPrimary'] = isPrimary;

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _familyMembersCollection.doc(memberId).update(updates);
    } catch (e) {
      throw Exception('Error updating family member: $e');
    }
  }

  /// Delete family member
  Future<void> deleteFamilyMember(String memberId) async {
    try {
      await _familyMembersCollection.doc(memberId).delete();
    } catch (e) {
      throw Exception('Error deleting family member: $e');
    }
  }

  /// Get primary user for a family member
  Future<Map<String, dynamic>?> getPrimaryUser(String userId) async {
    try {
      // First check if the user is primary
      DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }

      // If not, check if they are a family member
      QuerySnapshot familyMemberQuery = await _familyMembersCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (familyMemberQuery.docs.isNotEmpty) {
        String primaryUserId = familyMemberQuery.docs.first.get('userId');
        DocumentSnapshot primaryUserDoc =
            await _usersCollection.doc(primaryUserId).get();
        if (primaryUserDoc.exists) {
          return primaryUserDoc.data() as Map<String, dynamic>?;
        }
      }

      return null;
    } catch (e) {
      throw Exception('Error getting primary user: $e');
    }
  }

  /// Get user's postpartum recovery progress
  Future<Map<String, dynamic>> getPostpartumProgress(String userId) async {
    try {
      DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        return {
          'deliveryDate': null,
          'weeksPassed': 0,
          'recoveryProgress': 0.0,
          'isCompleted': false,
        };
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      Timestamp? deliveryDateTimestamp = userData['deliveryDate'];

      if (deliveryDateTimestamp == null) {
        return {
          'deliveryDate': null,
          'weeksPassed': 0,
          'recoveryProgress': 0.0,
          'isCompleted': false,
        };
      }

      DateTime deliveryDate = deliveryDateTimestamp.toDate();
      DateTime now = DateTime.now();
      Duration difference = now.difference(deliveryDate);
      int weeksPassed = (difference.inDays / 7).floor();

      // 6 weeks = 42 days for full recovery
      double recoveryProgress =
          (difference.inDays / 42 * 100).clamp(0.0, 100.0);
      bool isCompleted = weeksPassed >= 6;

      return {
        'deliveryDate': deliveryDate,
        'weeksPassed': weeksPassed,
        'recoveryProgress': recoveryProgress,
        'isCompleted': isCompleted,
      };
    } catch (e) {
      throw Exception('Error getting postpartum progress: $e');
    }
  }

  /// Update user's delivery date
  Future<void> updateDeliveryDate(String userId, DateTime deliveryDate) async {
    try {
      await _usersCollection.doc(userId).update({
        'deliveryDate': deliveryDate,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error updating delivery date: $e');
    }
  }

  /// Get user's vaccination records
  Future<Map<String, dynamic>> getVaccinationProgress(String userId) async {
    try {
      QuerySnapshot vaccinationRecords = await _healthRecordsCollection
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'Vaccination')
          .get();

      int completedVaccinations = vaccinationRecords.docs.length;
      int totalVaccinations = 8; // Standard vaccination schedule

      double progress =
          (completedVaccinations / totalVaccinations * 100).clamp(0.0, 100.0);
      bool isCompleted = completedVaccinations >= totalVaccinations;

      return {
        'completedVaccinations': completedVaccinations,
        'totalVaccinations': totalVaccinations,
        'progress': progress,
        'isCompleted': isCompleted,
      };
    } catch (e) {
      throw Exception('Error getting vaccination progress: $e');
    }
  }

  /// Get user's weight tracking progress
  Future<Map<String, dynamic>> getWeightTrackingProgress(String userId) async {
    try {
      DateTime thirtyDaysAgo =
          DateTime.now().subtract(const Duration(days: 30));

      QuerySnapshot healthRecords = await _healthRecordsCollection
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'Weight')
          .where('date', isGreaterThanOrEqualTo: thirtyDaysAgo)
          .get();

      int weightEntries = healthRecords.docs.length;
      int targetEntries = 4; // Weekly tracking for a month

      double progress = (weightEntries / targetEntries * 100).clamp(0.0, 100.0);
      bool isCompleted = weightEntries >= targetEntries;

      return {
        'weightEntries': weightEntries,
        'targetEntries': targetEntries,
        'progress': progress,
        'isCompleted': isCompleted,
      };
    } catch (e) {
      throw Exception('Error getting weight tracking progress: $e');
    }
  }

  /// Get user's health journal progress
  Future<Map<String, dynamic>> getJournalProgress(
      String userId, int targetCount) async {
    try {
      QuerySnapshot journalEntries = await _healthJournalCollection
          .where('userId', isEqualTo: userId)
          .get();

      int entryCount = journalEntries.docs.length;
      double progress = (entryCount / targetCount * 100).clamp(0.0, 100.0);
      bool isCompleted = entryCount >= targetCount;

      return {
        'entryCount': entryCount,
        'targetCount': targetCount,
        'progress': progress,
        'isCompleted': isCompleted,
      };
    } catch (e) {
      throw Exception('Error getting journal progress: $e');
    }
  }

  /// Get user's symptom tracking progress
  Future<Map<String, dynamic>> getSymptomProgress(
      String userId, int targetCount) async {
    try {
      QuerySnapshot symptomLogs =
          await _symptomLogsCollection.where('userId', isEqualTo: userId).get();

      int logCount = symptomLogs.docs.length;
      double progress = (logCount / targetCount * 100).clamp(0.0, 100.0);
      bool isCompleted = logCount >= targetCount;

      return {
        'logCount': logCount,
        'targetCount': targetCount,
        'progress': progress,
        'isCompleted': isCompleted,
      };
    } catch (e) {
      throw Exception('Error getting symptom progress: $e');
    }
  }

  /// Add notification
  Future<String> addNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      DocumentReference doc = await _notificationsCollection.add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'data': data ?? {},
      });
      return doc.id;
    } catch (e) {
      throw Exception('Error adding notification: $e');
    }
  }

  /// Get user notifications
  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Get unread notifications count for a user
  Stream<int> getUnreadNotificationsCount(String userId) {
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({
        'isRead': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      QuerySnapshot unreadNotifications = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in unreadNotifications.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Error marking all notifications as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).delete();
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }

  /// Delete old notifications (older than 30 days)
  Future<void> deleteOldNotifications(String userId) async {
    try {
      DateTime thirtyDaysAgo =
          DateTime.now().subtract(const Duration(days: 30));
      QuerySnapshot oldNotifications = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('timestamp', isLessThan: thirtyDaysAgo)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in oldNotifications.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Error deleting old notifications: $e');
    }
  }

  /// Generate medication reminder notification
  Future<void> generateMedicationReminder({
    required String userId,
    required String medicationName,
    required String dosage,
    required DateTime scheduledTime,
  }) async {
    await addNotification(
      userId: userId,
      title: 'Medication Reminder',
      message: 'Time to take your $medicationName ($dosage)',
      type: 'medication_reminder',
      data: {
        'medicationName': medicationName,
        'dosage': dosage,
        'scheduledTime': scheduledTime.toIso8601String(),
      },
    );
  }

  /// Generate medication taken notification
  Future<void> generateMedicationTakenNotification({
    required String userId,
    required String medicationName,
    required String dosage,
  }) async {
    await addNotification(
      userId: userId,
      title: 'Medication Taken',
      message: 'You successfully took $medicationName ($dosage)',
      type: 'medication_taken',
      data: {
        'medicationName': medicationName,
        'dosage': dosage,
      },
    );
  }

  /// Generate medication missed notification
  Future<void> generateMedicationMissedNotification({
    required String userId,
    required String medicationName,
    required String dosage,
  }) async {
    await addNotification(
      userId: userId,
      title: 'Medication Missed',
      message: 'You missed your dose of $medicationName ($dosage)',
      type: 'medication_missed',
      data: {
        'medicationName': medicationName,
        'dosage': dosage,
      },
    );
  }

  /// Generate streak achievement notification
  Future<void> generateStreakAchievementNotification({
    required String userId,
    required int streakDays,
  }) async {
    await addNotification(
      userId: userId,
      title: 'Streak Achievement! 🔥',
      message:
          'Congratulations! You\'ve maintained a ${streakDays}-day streak!',
      type: 'streak_achievement',
      data: {
        'streakDays': streakDays,
      },
    );
  }

  /// Generate reward earned notification
  Future<void> generateRewardEarnedNotification({
    required String userId,
    required int points,
    required String reason,
  }) async {
    await addNotification(
      userId: userId,
      title: 'Reward Earned',
      message: 'You earned $points points for $reason!',
      type: 'reward_earned',
      data: {
        'points': points,
        'reason': reason,
      },
    );
  }

  /// Generate appointment reminder notification
  Future<void> generateAppointmentReminderNotification({
    required String userId,
    required String professionalName,
    required DateTime appointmentTime,
  }) async {
    await addNotification(
      userId: userId,
      title: 'Upcoming Consultation',
      message:
          'Your appointment with $professionalName is tomorrow at ${appointmentTime.hour}:${appointmentTime.minute.toString().padLeft(2, '0')} ${appointmentTime.hour >= 12 ? 'PM' : 'AM'}',
      type: 'appointment_reminder',
      data: {
        'professionalName': professionalName,
        'appointmentTime': appointmentTime.toIso8601String(),
      },
    );
  }

  /// Generate achievement unlocked notification
  Future<void> generateAchievementUnlockedNotification({
    required String userId,
    required String achievementName,
    required int pointsAwarded,
  }) async {
    await addNotification(
      userId: userId,
      title: 'Achievement Unlocked! 🏆',
      message:
          'You\'ve unlocked the "$achievementName" achievement and earned $pointsAwarded points!',
      type: 'achievement_unlocked',
      data: {
        'achievementName': achievementName,
        'pointsAwarded': pointsAwarded,
      },
    );
  }

  /// Generate health tip notification
  Future<void> generateHealthTipNotification({
    required String userId,
    required String tip,
  }) async {
    await addNotification(
      userId: userId,
      title: 'Health Tip',
      message: tip,
      type: 'health_tip',
      data: {
        'tip': tip,
      },
    );
  }

  /// Generate welcome notification
  Future<void> generateWelcomeNotification({
    required String userId,
    required String userName,
  }) async {
    await addNotification(
      userId: userId,
      title: 'Welcome to MAMA! 👋',
      message:
          'Welcome $userName! We\'re here to support your maternal health journey.',
      type: 'welcome',
      data: {
        'userName': userName,
      },
    );
  }

  /// Add blood pressure reading
  Future<String> addBloodPressureReading({
    required String userId,
    required int systolic,
    required int diastolic,
    required int heartRate,
    required DateTime timestamp,
    String notes = '',
    String position = 'Sitting',
    String arm = 'Left',
    String device = '',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      DocumentReference doc = await _bloodPressureCollection.add({
        'userId': userId,
        'systolic': systolic,
        'diastolic': diastolic,
        'heartRate': heartRate,
        'timestamp': timestamp,
        'notes': notes,
        'position': position,
        'arm': arm,
        'device': device,
        'additionalData': additionalData ?? {},
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Generate notification for abnormal readings
      if (systolic >= 140 || diastolic >= 90) {
        await addNotification(
          userId: userId,
          title: 'High Blood Pressure Detected',
          message:
              'Your recent blood pressure reading ($systolic/$diastolic) is elevated. Please consult your healthcare provider.',
          type: 'health_alert',
          data: {
            'type': 'blood_pressure',
            'systolic': systolic,
            'diastolic': diastolic,
            'timestamp': timestamp.toIso8601String(),
          },
        );
      }

      return doc.id;
    } catch (e) {
      throw Exception('Error adding blood pressure reading: $e');
    }
  }

  /// Get user blood pressure readings
  Stream<QuerySnapshot> getUserBloodPressureReadings(String userId) {
    return _bloodPressureCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Get recent blood pressure readings for a user (last 7 days)
  Stream<QuerySnapshot> getRecentBloodPressureReadings(String userId) {
    DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return _bloodPressureCollection
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: sevenDaysAgo)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Get blood pressure readings for a specific date range
  Stream<QuerySnapshot> getBloodPressureReadingsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _bloodPressureCollection
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Update blood pressure reading
  Future<void> updateBloodPressureReading({
    required String readingId,
    int? systolic,
    int? diastolic,
    int? heartRate,
    DateTime? timestamp,
    String? notes,
    String? position,
    String? arm,
    String? device,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      Map<String, dynamic> updates = {};

      if (systolic != null) updates['systolic'] = systolic;
      if (diastolic != null) updates['diastolic'] = diastolic;
      if (heartRate != null) updates['heartRate'] = heartRate;
      if (timestamp != null) updates['timestamp'] = timestamp;
      if (notes != null) updates['notes'] = notes;
      if (position != null) updates['position'] = position;
      if (arm != null) updates['arm'] = arm;
      if (device != null) updates['device'] = device;
      if (additionalData != null) updates['additionalData'] = additionalData;

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _bloodPressureCollection.doc(readingId).update(updates);
    } catch (e) {
      throw Exception('Error updating blood pressure reading: $e');
    }
  }

  /// Delete blood pressure reading
  Future<void> deleteBloodPressureReading(String readingId) async {
    try {
      await _bloodPressureCollection.doc(readingId).delete();
    } catch (e) {
      throw Exception('Error deleting blood pressure reading: $e');
    }
  }

  /// Get blood pressure statistics for a user
  Future<Map<String, dynamic>> getBloodPressureStats(String userId) async {
    try {
      DateTime thirtyDaysAgo =
          DateTime.now().subtract(const Duration(days: 30));

      QuerySnapshot readings = await _bloodPressureCollection
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: thirtyDaysAgo)
          .get();

      if (readings.docs.isEmpty) {
        return {
          'totalReadings': 0,
          'averageSystolic': 0,
          'averageDiastolic': 0,
          'averageHeartRate': 0,
          'highestSystolic': 0,
          'highestDiastolic': 0,
          'lowestSystolic': 0,
          'lowestDiastolic': 0,
          'normalReadings': 0,
          'elevatedReadings': 0,
          'highReadings': 0,
          'crisisReadings': 0,
          'dateRange': 'Last 30 days',
        };
      }

      int totalReadings = readings.docs.length;
      int totalSystolic = 0;
      int totalDiastolic = 0;
      int totalHeartRate = 0;
      int highestSystolic = 0;
      int highestDiastolic = 0;
      int lowestSystolic = 999;
      int lowestDiastolic = 999;

      int normalReadings = 0;
      int elevatedReadings = 0;
      int highReadings = 0;
      int crisisReadings = 0;

      for (var doc in readings.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        int systolic = data['systolic'] ?? 0;
        int diastolic = data['diastolic'] ?? 0;
        int heartRate = data['heartRate'] ?? 0;

        totalSystolic += systolic;
        totalDiastolic += diastolic;
        totalHeartRate += heartRate;

        if (systolic > highestSystolic) highestSystolic = systolic;
        if (diastolic > highestDiastolic) highestDiastolic = diastolic;
        if (systolic < lowestSystolic) lowestSystolic = systolic;
        if (diastolic < lowestDiastolic) lowestDiastolic = diastolic;

        // Categorize readings
        if (systolic < 120 && diastolic < 80) {
          normalReadings++;
        } else if (systolic >= 120 && systolic < 130 && diastolic < 80) {
          elevatedReadings++;
        } else if (systolic >= 130 && systolic < 140 ||
            diastolic >= 80 && diastolic < 90) {
          highReadings++;
        } else if (systolic >= 140 || diastolic >= 90) {
          if (systolic > 180 || diastolic > 120) {
            crisisReadings++;
          } else {
            highReadings++;
          }
        }
      }

      return {
        'totalReadings': totalReadings,
        'averageSystolic': (totalSystolic / totalReadings).round(),
        'averageDiastolic': (totalDiastolic / totalReadings).round(),
        'averageHeartRate': (totalHeartRate / totalReadings).round(),
        'highestSystolic': highestSystolic,
        'highestDiastolic': highestDiastolic,
        'lowestSystolic': lowestSystolic == 999 ? 0 : lowestSystolic,
        'lowestDiastolic': lowestDiastolic == 999 ? 0 : lowestDiastolic,
        'normalReadings': normalReadings,
        'elevatedReadings': elevatedReadings,
        'highReadings': highReadings,
        'crisisReadings': crisisReadings,
        'dateRange': 'Last 30 days',
      };
    } catch (e) {
      throw Exception('Error getting blood pressure stats: $e');
    }
  }

  /// Get latest blood pressure reading for a user
  Future<Map<String, dynamic>?> getLatestBloodPressureReading(
      String userId) async {
    try {
      QuerySnapshot query = await _bloodPressureCollection
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        Map<String, dynamic> data =
            query.docs.first.data() as Map<String, dynamic>;
        data['id'] = query.docs.first.id;
        return data;
      }
      return null;
    } catch (e) {
      throw Exception('Error getting latest blood pressure reading: $e');
    }
  }
}
