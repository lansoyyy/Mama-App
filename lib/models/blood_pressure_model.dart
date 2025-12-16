import 'package:cloud_firestore/cloud_firestore.dart';

class BloodPressureModel {
  final String id;
  final String userId;
  final int systolic; // Upper value (e.g., 120)
  final int diastolic; // Lower value (e.g., 80)
  final int heartRate; // Beats per minute
  final DateTime timestamp;
  final String notes;
  final String position; // Sitting, Standing, Lying down
  final String arm; // Left, Right
  final String device; // Device used for measurement
  final Map<String, dynamic>? additionalData;

  BloodPressureModel({
    required this.id,
    required this.userId,
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
    required this.timestamp,
    this.notes = '',
    this.position = 'Sitting',
    this.arm = 'Left',
    this.device = '',
    this.additionalData,
  });

  // Factory constructor to create from Firestore document
  factory BloodPressureModel.fromFirestore(
      String id, Map<String, dynamic> data) {
    return BloodPressureModel(
      id: id,
      userId: data['userId'] ?? '',
      systolic: data['systolic'] ?? 0,
      diastolic: data['diastolic'] ?? 0,
      heartRate: data['heartRate'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      notes: data['notes'] ?? '',
      position: data['position'] ?? 'Sitting',
      arm: data['arm'] ?? 'Left',
      device: data['device'] ?? '',
      additionalData: data['additionalData'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'systolic': systolic,
      'diastolic': diastolic,
      'heartRate': heartRate,
      'timestamp': Timestamp.fromDate(timestamp),
      'notes': notes,
      'position': position,
      'arm': arm,
      'device': device,
      'additionalData': additionalData ?? {},
    };
  }

  bool get hasSymptoms => additionalData?['hasSymptoms'] == true;

  String getBloodPressureCategory() {
    if (systolic > 180 || diastolic > 120) {
      return hasSymptoms ? 'Hypertensive Emergency' : 'Severe Hypertension';
    }

    if (systolic >= 140 || diastolic >= 90) {
      return 'Stage 2 Hypertension';
    }

    if ((systolic >= 130 && systolic <= 139) ||
        (diastolic >= 80 && diastolic <= 89)) {
      return 'Stage 1 Hypertension';
    }

    if (systolic >= 120 && systolic <= 129 && diastolic < 80) {
      return 'Elevated';
    }

    if (systolic < 120 && diastolic < 80) {
      return 'Normal';
    }

    return 'Unknown';
  }

  String getBloodPressureColor() {
    String category = getBloodPressureCategory();
    switch (category) {
      case 'Normal':
        return '#8BC34A';
      case 'Elevated':
        return '#FFEB3B';
      case 'Stage 1 Hypertension':
        return '#FF9800';
      case 'Stage 2 Hypertension':
        return '#BF360C';
      case 'Severe Hypertension':
        return '#8B0000';
      case 'Hypertensive Emergency':
        return '#6A1B9A';
      default:
        return '#9E9E9E';
    }
  }

  // Get formatted date string
  String getFormattedDate() {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  // Get formatted time string
  String getFormattedTime() {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // Get formatted date and time string
  String getFormattedDateTime() {
    return '${getFormattedDate()} ${getFormattedTime()}';
  }

  // Check if reading is abnormal (requires attention)
  bool isAbnormal() {
    String category = getBloodPressureCategory();
    return category == 'Stage 2 Hypertension' ||
        category == 'Severe Hypertension' ||
        category == 'Hypertensive Emergency';
  }

  // Check if reading is elevated (moderate concern)
  bool isElevated() {
    String category = getBloodPressureCategory();
    return category == 'Elevated' || category == 'Stage 1 Hypertension';
  }

  // Get heart rate category
  String getHeartRateCategory() {
    if (heartRate < 60) {
      return 'Low';
    } else if (heartRate >= 60 && heartRate <= 100) {
      return 'Normal';
    } else {
      return 'High';
    }
  }

  // Get heart rate color
  String getHeartRateColor() {
    String category = getHeartRateCategory();
    switch (category) {
      case 'Normal':
        return '#4CAF50'; // Green
      case 'Low':
      case 'High':
        return '#FF9800'; // Orange
      default:
        return '#9E9E9E'; // Grey
    }
  }
}
