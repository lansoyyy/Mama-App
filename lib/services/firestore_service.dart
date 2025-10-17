import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore Service for managing user data
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _medicationsCollection => _firestore.collection('medications');
  CollectionReference get _healthRecordsCollection => _firestore.collection('health_records');

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
      if (emergencyContact != null) updates['emergencyContact'] = emergencyContact;
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
      if (chronicConditions != null) updates['chronicConditions'] = chronicConditions;
      
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
      QuerySnapshot medications = await _medicationsCollection
          .where('userId', isEqualTo: uid)
          .get();
      for (var doc in medications.docs) {
        await doc.reference.delete();
      }

      // Delete user health records
      QuerySnapshot healthRecords = await _healthRecordsCollection
          .where('userId', isEqualTo: uid)
          .get();
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
}
