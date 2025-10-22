import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

/// Service to initialize default rewards and achievements in Firestore
class RewardsInitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();

  /// Initialize default rewards and achievements
  Future<void> initializeDefaultRewards() async {
    try {
      // Check if rewards collection is empty
      QuerySnapshot existingRewards =
          await _firestore.collection('rewards').get();
      if (existingRewards.docs.isEmpty) {
        await _createDefaultRewards();
      }

      // Check if achievements collection is empty
      QuerySnapshot existingAchievements =
          await _firestore.collection('achievements').get();
      if (existingAchievements.docs.isEmpty) {
        await _createDefaultAchievements();
      }
    } catch (e) {
      print('Error initializing rewards: $e');
    }
  }

  /// Create default rewards
  Future<void> _createDefaultRewards() async {
    List<Map<String, dynamic>> defaultRewards = [
      {
        'title': 'Wellness Guide',
        'description': 'Digital wellness and nutrition guide',
        'category': 'Digital',
        'pointsRequired': 300,
        'imageUrl': 'assets/images/rewards/wellness_guide.jpg',
        'isActive': true,
        'translationFilipino': 'Gabay sa Kalusugan',
        'translationCebuano': 'Giya sa Kalusugan',
      },
      {
        'title': 'Health Kit',
        'description': 'Basic health monitoring kit',
        'category': 'Physical',
        'pointsRequired': 1000,
        'imageUrl': 'assets/images/rewards/health_kit.jpg',
        'isActive': true,
        'translationFilipino': 'Kit sa Kalusugan',
        'translationCebuano': 'Kit sa Kalusugan',
      },
      {
        'title': 'Prenatal Yoga Session',
        'description': 'Online prenatal yoga class voucher',
        'category': 'Service',
        'pointsRequired': 500,
        'imageUrl': 'assets/images/rewards/yoga_session.jpg',
        'isActive': true,
        'translationFilipino': 'Session ng Prenatal Yoga',
        'translationCebuano': 'Session sa Prenatal Yoga',
      },
      {
        'title': 'Nutrition Consultation',
        'description': 'One-on-one nutritionist consultation',
        'category': 'Service',
        'pointsRequired': 750,
        'imageUrl': 'assets/images/rewards/nutrition_consult.jpg',
        'isActive': true,
        'translationFilipino': 'Konsultasyon sa Nutrisyon',
        'translationCebuano': 'Konsultasyon sa Nutrisyon',
      },
      {
        'title': 'Baby Care Package',
        'description': 'Essential baby care items bundle',
        'category': 'Physical',
        'pointsRequired': 1500,
        'imageUrl': 'assets/images/rewards/baby_care_package.jpg',
        'isActive': true,
        'translationFilipino': 'Package ng Pangangalaga sa Sanggol',
        'translationCebuano': 'Package sa Pag-ato sa Bata',
      },
    ];

    for (var reward in defaultRewards) {
      await _firestore.collection('rewards').add({
        ...reward,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Create default achievements
  Future<void> _createDefaultAchievements() async {
    List<Map<String, dynamic>> defaultAchievements = [
      {
        'title': 'Perfect Week',
        'description': 'Complete all medications for 7 days',
        'type': 'streak_days',
        'requiredValue': 7,
        'pointsAwarded': 50,
        'icon': 'calendar_today',
        'color': 'success',
        'isActive': true,
        'translationFilipino': 'Perpektong Linggo',
        'translationCebuano': 'Perpektong Semana',
      },
      {
        'title': 'Early Bird',
        'description': 'Take morning medications on time for 5 days',
        'type': 'streak_days',
        'requiredValue': 5,
        'pointsAwarded': 30,
        'icon': 'wb_sunny',
        'color': 'warning',
        'isActive': true,
        'translationFilipino': 'Maagang Ibon',
        'translationCebuano': 'Sayop sa Manok',
      },
      {
        'title': 'Consistent Care',
        'description': 'Maintain 90% adherence for a month',
        'type': 'adherence_rate',
        'requiredValue': 90,
        'pointsAwarded': 100,
        'icon': 'favorite',
        'color': 'primary',
        'isActive': true,
        'translationFilipino': 'Matatag na Pag-aalaga',
        'translationCebuano': 'Tinubdan sa Pag-amping',
      },
      {
        'title': 'Health Champion',
        'description': 'Complete 100 medication doses',
        'type': 'total_doses',
        'requiredValue': 100,
        'pointsAwarded': 75,
        'icon': 'emoji_events',
        'color': 'reward',
        'isActive': true,
        'translationFilipino': 'Kampeon sa Kalusugan',
        'translationCebuano': 'Kampeyon sa Kalusugan',
      },
      {
        'title': 'Wellness Warrior',
        'description': 'Use the app for 30 consecutive days',
        'type': 'streak_days',
        'requiredValue': 30,
        'pointsAwarded': 150,
        'icon': 'shield',
        'color': 'secondary',
        'isActive': true,
        'translationFilipino': 'Mandirigma sa Kalusugan',
        'translationCebuano': 'Mandirigma sa Kalusugan',
      },
      {
        'title': 'Point Collector',
        'description': 'Earn 500 points',
        'type': 'total_points',
        'requiredValue': 500,
        'pointsAwarded': 25,
        'icon': 'stars',
        'color': 'reward',
        'isActive': true,
        'translationFilipino': 'Mangolekta ng Puntos',
        'translationCebuano': 'Mangolekta sa Puntos',
      },
      {
        'title': 'Medication Master',
        'description': 'Complete 200 medication doses',
        'type': 'total_doses',
        'requiredValue': 200,
        'pointsAwarded': 125,
        'icon': 'medical_services',
        'color': 'primary',
        'isActive': true,
        'translationFilipino': 'Master sa Gamot',
        'translationCebuano': 'Master sa Tambal',
      },
      {
        'title': 'Perfect Month',
        'description': 'Maintain 100% adherence for a month',
        'type': 'adherence_rate',
        'requiredValue': 100,
        'pointsAwarded': 200,
        'icon': 'stars',
        'color': 'success',
        'isActive': true,
        'translationFilipino': 'Perpektong Buwan',
        'translationCebuano': 'Perpektong Bulan',
      },
    ];

    for (var achievement in defaultAchievements) {
      await _firestore.collection('achievements').add({
        ...achievement,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
