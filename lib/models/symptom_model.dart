import 'package:cloud_firestore/cloud_firestore.dart';

class SymptomModel {
  final String id;
  final String userId;
  final List<String> symptoms;
  final String severity;
  final String notes;
  final DateTime timestamp;
  final DateTime createdAt;

  SymptomModel({
    required this.id,
    required this.userId,
    required this.symptoms,
    required this.severity,
    required this.notes,
    required this.timestamp,
    required this.createdAt,
  });

  factory SymptomModel.fromFirestore(Map<String, dynamic> data, String id) {
    return SymptomModel(
      id: id,
      userId: data['userId'] ?? '',
      symptoms: List<String>.from(data['symptoms'] ?? []),
      severity: data['severity'] ?? '',
      notes: data['notes'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'symptoms': symptoms,
      'severity': severity,
      'notes': notes,
      'timestamp': timestamp,
      'createdAt': createdAt,
    };
  }

  SymptomModel copyWith({
    String? id,
    String? userId,
    List<String>? symptoms,
    String? severity,
    String? notes,
    DateTime? timestamp,
    DateTime? createdAt,
  }) {
    return SymptomModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      symptoms: symptoms ?? this.symptoms,
      severity: severity ?? this.severity,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SymptomSeverity {
  static const String mild = 'Mild';
  static const String moderate = 'Moderate';
  static const String severe = 'Severe';

  static List<String> getAll() {
    return [mild, moderate, severe];
  }

  static String getDisplayName(String severity) {
    switch (severity) {
      case mild:
        return 'Mild';
      case moderate:
        return 'Moderate';
      case severe:
        return 'Severe';
      default:
        return 'Unknown';
    }
  }
}

class CommonSymptoms {
  static const List<String> symptoms = [
    'Nausea',
    'Headache',
    'Fatigue',
    'Dizziness',
    'Stomach Pain',
    'Vomiting',
    'Fever',
    'Rash',
    'Swelling',
    'Difficulty Breathing',
    'Chest Pain',
    'Back Pain',
    'Cramps',
    'Bloating',
    'Constipation',
    'Diarrhea',
    'Heartburn',
    'Insomnia',
    'Anxiety',
    'Mood Swings',
    'Other',
  ];
}
