import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for family member
class FamilyMember {
  final String id;
  final String userId; // Primary user who manages this family member
  final String name;
  final String relationship;
  final String info; // Additional info like age, etc.
  final String? profilePicture;
  final bool isPrimary; // If this is the primary account holder
  final DateTime createdAt;
  final DateTime updatedAt;

  FamilyMember({
    required this.id,
    required this.userId,
    required this.name,
    required this.relationship,
    required this.info,
    this.profilePicture,
    this.isPrimary = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create FamilyMember from Firestore document
  factory FamilyMember.fromFirestore(Map<String, dynamic> data, String id) {
    return FamilyMember(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      relationship: data['relationship'] ?? '',
      info: data['info'] ?? '',
      profilePicture: data['profilePicture'],
      isPrimary: data['isPrimary'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert FamilyMember to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'relationship': relationship,
      'info': info,
      'profilePicture': profilePicture,
      'isPrimary': isPrimary,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Create a copy of FamilyMember with updated fields
  FamilyMember copyWith({
    String? id,
    String? userId,
    String? name,
    String? relationship,
    String? info,
    String? profilePicture,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      info: info ?? this.info,
      profilePicture: profilePicture ?? this.profilePicture,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
