import 'package:cloud_firestore/cloud_firestore.dart';

class HealthJournalModel {
  final String id;
  final String userId;
  final String date;
  final String time;
  final String content;
  final List<String> tags;
  final String mood;
  final String energyLevel;
  final DateTime timestamp;
  final DateTime createdAt;

  HealthJournalModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.time,
    required this.content,
    required this.tags,
    required this.mood,
    required this.energyLevel,
    required this.timestamp,
    required this.createdAt,
  });

  factory HealthJournalModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return HealthJournalModel(
      id: id,
      userId: data['userId'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      content: data['content'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      mood: data['mood'] ?? '',
      energyLevel: data['energyLevel'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': date,
      'time': time,
      'content': content,
      'tags': tags,
      'mood': mood,
      'energyLevel': energyLevel,
      'timestamp': timestamp,
      'createdAt': createdAt,
    };
  }

  HealthJournalModel copyWith({
    String? id,
    String? userId,
    String? date,
    String? time,
    String? content,
    List<String>? tags,
    String? mood,
    String? energyLevel,
    DateTime? timestamp,
    DateTime? createdAt,
  }) {
    return HealthJournalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      time: time ?? this.time,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      mood: mood ?? this.mood,
      energyLevel: energyLevel ?? this.energyLevel,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MoodOptions {
  static const String great = 'Great';
  static const String good = 'Good';
  static const String okay = 'Okay';
  static const String notGood = 'Not Good';
  static const String bad = 'Bad';

  static List<String> getAll() {
    return [great, good, okay, notGood, bad];
  }

  static String getEmoji(String mood) {
    switch (mood) {
      case great:
        return '😄';
      case good:
        return '😊';
      case okay:
        return '😐';
      case notGood:
        return '😔';
      case bad:
        return '😢';
      default:
        return '😐';
    }
  }

  static String getDisplayName(String mood) {
    switch (mood) {
      case great:
        return 'Great';
      case good:
        return 'Good';
      case okay:
        return 'Okay';
      case notGood:
        return 'Not Good';
      case bad:
        return 'Bad';
      default:
        return 'Unknown';
    }
  }
}

class EnergyLevelOptions {
  static const String high = 'High';
  static const String medium = 'Medium';
  static const String low = 'Low';

  static List<String> getAll() {
    return [high, medium, low];
  }

  static String getEmoji(String energyLevel) {
    switch (energyLevel) {
      case high:
        return '⚡';
      case medium:
        return '🔋';
      case low:
        return '🪫';
      default:
        return '🔋';
    }
  }

  static String getDisplayName(String energyLevel) {
    switch (energyLevel) {
      case high:
        return 'High';
      case medium:
        return 'Medium';
      case low:
        return 'Low';
      default:
        return 'Unknown';
    }
  }
}

class CommonJournalTags {
  static const List<String> tags = [
    'Good Mood',
    'High Energy',
    'Healthy Eating',
    'Exercise',
    'Good Sleep',
    'Stress',
    'Anxiety',
    'Fatigue',
    'Headache',
    'Nausea',
    'Medication Taken',
    'Checkup',
    'Good News',
    'Happy',
    'Rested',
    'Mild Headache',
    'Cramps',
    'Bloating',
    'Back Pain',
    'Dizziness',
    'Other',
  ];
}
