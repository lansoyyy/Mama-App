import 'package:flutter/material.dart';
import '../utils/colors.dart';

class MedicationModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final List<String> uses;
  final List<String> dosage;
  final List<String> sideEffects;
  final List<String> precautions;
  final String imageUrl;
  final bool isSafeForPregnancy;
  final String pregnancyCategory;
  final String? translationFilipino;
  final String? translationCebuano;

  MedicationModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.uses,
    required this.dosage,
    required this.sideEffects,
    required this.precautions,
    required this.imageUrl,
    required this.isSafeForPregnancy,
    required this.pregnancyCategory,
    this.translationFilipino,
    this.translationCebuano,
  });
}

class MedicationCategory {
  final String id;
  final String name;
  final String description;
  final IconData iconData;
  final Color color;
  final String? translationFilipino;
  final String? translationCebuano;

  MedicationCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconData,
    required this.color,
    this.translationFilipino,
    this.translationCebuano,
  });
}

// Hardcoded medication data
List<MedicationCategory> getMedicationCategories() {
  List<MedicationCategory> categories = [
    MedicationCategory(
      id: '1',
      name: 'Prenatal Vitamins',
      description: 'Essential vitamins for pregnancy',
      iconData: Icons.medical_services,
      color: AppColors.primary,
      translationFilipino: 'Bitalaminang Prenatal',
      translationCebuano: 'Bitaminang Prenatal',
    ),
    MedicationCategory(
      id: '2',
      name: 'Iron Supplements',
      description: 'Prevent anemia during pregnancy',
      iconData: Icons.bloodtype,
      color: AppColors.error,
      translationFilipino: 'Suplemento sa Bakal',
      translationCebuano: 'Suplemento sa Bakal',
    ),
    MedicationCategory(
      id: '3',
      name: 'Folic Acid',
      description: 'Important for baby development',
      iconData: Icons.favorite,
      color: AppColors.secondary,
      translationFilipino: 'Asido na Foliko',
      translationCebuano: 'Asido nga Foliko',
    ),
    MedicationCategory(
      id: '4',
      name: 'Calcium',
      description: 'Strengthen bones and teeth',
      iconData: Icons.health_and_safety,
      color: AppColors.info,
      translationFilipino: 'Kalsyo',
      translationCebuano: 'Kalsyo',
    ),
    MedicationCategory(
      id: '5',
      name: 'Pain Relief',
      description: 'Safe pain management options',
      iconData: Icons.healing,
      color: AppColors.warning,
      translationFilipino: 'Panlipas sa Sakit',
      translationCebuano: 'Panasakit',
    ),
    MedicationCategory(
      id: '6',
      name: 'Antibiotics',
      description: 'Understanding safe antibiotics',
      iconData: Icons.medication_liquid,
      color: AppColors.success,
      translationFilipino: 'Antibyotiko',
      translationCebuano: 'Antibyotiko',
    ),
  ];
  
  // Sort categories alphabetically by name
  categories.sort((a, b) => a.name.compareTo(b.name));
  return categories;
}

List<MedicationModel> getMedicationsByCategory(String categoryId) {
  List<MedicationModel> medications;
  
  switch (categoryId) {
    case '1': // Prenatal Vitamins
      medications = [
        MedicationModel(
          id: 'p1',
          name: 'Materna',
          category: 'Prenatal Vitamins',
          description: 'Complete prenatal multivitamin with DHA',
          uses: [
            'Supports fetal brain development',
            'Prevents birth defects',
            'Reduces risk of preterm birth',
            'Supports maternal health'
          ],
          dosage: [
            'Take one tablet daily with food',
            'Best taken in the morning',
            'Continue throughout pregnancy and breastfeeding'
          ],
          sideEffects: ['Mild nausea', 'Constipation', 'Dark-colored stools'],
          precautions: [
            'Do not exceed recommended dosage',
            'Consult doctor if allergic to any ingredient',
            'Keep out of reach of children'
          ],
          imageUrl: 'assets/images/medications/materna.jpg',
          isSafeForPregnancy: true,
          pregnancyCategory: 'A',
          translationFilipino: 'Materna',
          translationCebuano: 'Materna',
        ),
        MedicationModel(
          id: 'p2',
          name: 'Obimin',
          category: 'Prenatal Vitamins',
          description:
              'Prenatal supplement with essential vitamins and minerals',
          uses: [
            'Provides essential nutrients for pregnancy',
            'Supports baby growth and development',
            'Prevents nutritional deficiencies',
            'Boosts maternal energy'
          ],
          dosage: [
            'Take one capsule daily',
            'Preferably with meals',
            'Continue as prescribed by doctor'
          ],
          sideEffects: ['Stomach upset', 'Headache', 'Changes in urine color'],
          precautions: [
            'Take with food to reduce stomach upset',
            'Inform doctor about other medications',
            'Store in cool, dry place'
          ],
          imageUrl: 'assets/images/medications/obimin.jpg',
          isSafeForPregnancy: true,
          pregnancyCategory: 'A',
          translationFilipino: 'Obimin',
          translationCebuano: 'Obimin',
        ),
      ];
      break;
    case '2': // Iron Supplements
      medications = [
        MedicationModel(
          id: 'i1',
          name: 'Ferrous Sulfate',
          category: 'Iron Supplements',
          description: 'Iron supplement for preventing and treating anemia',
          uses: [
            'Treats iron deficiency anemia',
            'Prevents anemia during pregnancy',
            'Increases hemoglobin levels',
            'Reduces fatigue and weakness'
          ],
          dosage: [
            'One tablet daily',
            'Take on empty stomach for better absorption',
            'Take with Vitamin C to enhance absorption'
          ],
          sideEffects: [
            'Constipation',
            'Stomach cramps',
            'Dark stools',
            'Nausea'
          ],
          precautions: [
            'Do not take with antacids',
            'Avoid taking with milk or dairy products',
            'May cause black stools (normal)'
          ],
          imageUrl: 'assets/images/medications/ferrous_sulfate.jpg',
          isSafeForPregnancy: true,
          pregnancyCategory: 'A',
          translationFilipino: 'Ferrous Sulfate',
          translationCebuano: 'Ferrous Sulfate',
        ),
        MedicationModel(
          id: 'i2',
          name: 'Irofol',
          category: 'Iron Supplements',
          description: 'Iron with folic acid supplement',
          uses: [
            'Prevents iron and folic acid deficiency',
            'Supports red blood cell formation',
            'Reduces risk of neural tube defects',
            'Treats anemia in pregnancy'
          ],
          dosage: [
            'One capsule daily',
            'Take with meals to reduce stomach upset',
            'Continue throughout pregnancy as prescribed'
          ],
          sideEffects: [
            'Nausea',
            'Constipation',
            'Diarrhea',
            'Stomach discomfort'
          ],
          precautions: [
            'Take with food if stomach upset occurs',
            'Inform doctor if you have stomach ulcers',
            'Do not exceed recommended dose'
          ],
          imageUrl: 'assets/images/medications/irofol.jpg',
          isSafeForPregnancy: true,
          pregnancyCategory: 'A',
          translationFilipino: 'Irofol',
          translationCebuano: 'Irofol',
        ),
      ];
      break;
    case '3': // Folic Acid
      medications = [
        MedicationModel(
          id: 'f1',
          name: 'Folart',
          category: 'Folic Acid',
          description: 'Folic acid supplement for pregnancy',
          uses: [
            'Prevents neural tube defects',
            'Supports fetal brain development',
            'Aids in DNA synthesis',
            'Reduces risk of birth defects'
          ],
          dosage: [
            'One tablet daily',
            'Start before pregnancy if possible',
            'Continue through first trimester'
          ],
          sideEffects: [
            'Generally well tolerated',
            'Rarely causes skin rash',
            'Minimal side effects'
          ],
          precautions: [
            'Take at the same time each day',
            'Do not skip doses',
            'Store away from light and moisture'
          ],
          imageUrl: 'assets/images/medications/folart.jpg',
          isSafeForPregnancy: true,
          pregnancyCategory: 'A',
          translationFilipino: 'Folart',
          translationCebuano: 'Folart',
        ),
      ];
      break;
    case '4': // Calcium
      medications = [
        MedicationModel(
          id: 'c1',
          name: 'Calcium Carbonate',
          category: 'Calcium',
          description: 'Calcium supplement for bone health',
          uses: [
            'Strengthens maternal bones',
            'Supports fetal bone development',
            'Prevents osteoporosis',
            'Reduces risk of pre-eclampsia'
          ],
          dosage: [
            'One tablet twice daily',
            'Take with meals',
            'Take with Vitamin D for better absorption'
          ],
          sideEffects: [
            'Constipation',
            'Gas',
            'Bloating',
            'Kidney stones (rare)'
          ],
          precautions: [
            'Drink plenty of water',
            'Do not exceed recommended dose',
            'Consult doctor if kidney problems'
          ],
          imageUrl: 'assets/images/medications/calcium_carbonate.jpg',
          isSafeForPregnancy: true,
          pregnancyCategory: 'A',
          translationFilipino: 'Kalsyo Karbonato',
          translationCebuano: 'Kalsyo Karbonato',
        ),
      ];
      break;
    case '5': // Pain Relief
      medications = [
        MedicationModel(
          id: 'pr1',
          name: 'Paracetamol',
          category: 'Pain Relief',
          description: 'Safe pain reliever for pregnancy',
          uses: [
            'Relieves mild to moderate pain',
            'Reduces fever',
            'Alleviates headaches',
            'Treats muscle aches'
          ],
          dosage: [
            '500mg every 4-6 hours as needed',
            'Do not exceed 4g in 24 hours',
            'Take with food if stomach upset'
          ],
          sideEffects: [
            'Generally safe when used as directed',
            'Rarely causes allergic reactions',
            'Liver damage with overdose'
          ],
          precautions: [
            'Do not exceed recommended dose',
            'Avoid with alcohol',
            'Consult doctor for prolonged use'
          ],
          imageUrl: 'assets/images/medications/paracetamol.jpg',
          isSafeForPregnancy: true,
          pregnancyCategory: 'B',
          translationFilipino: 'Paracetamol',
          translationCebuano: 'Paracetamol',
        ),
      ];
      break;
    case '6': // Antibiotics
      medications = [
        MedicationModel(
          id: 'a1',
          name: 'Amoxicillin',
          category: 'Antibiotics',
          description: 'Penicillin-type antibiotic',
          uses: [
            'Treats bacterial infections',
            'Respiratory infections',
            'Urinary tract infections',
            'Skin infections'
          ],
          dosage: [
            '500mg every 8 hours',
            'Complete full course',
            'Take with or without food'
          ],
          sideEffects: [
            'Nausea',
            'Diarrhea',
            'Yeast infections',
            'Allergic reactions (rare)'
          ],
          precautions: [
            'Complete full course of treatment',
            'Inform doctor of allergies',
            'May reduce effectiveness of birth control'
          ],
          imageUrl: 'assets/images/medications/amoxicillin.jpg',
          isSafeForPregnancy: true,
          pregnancyCategory: 'B',
          translationFilipino: 'Amoxicillin',
          translationCebuano: 'Amoxicillin',
        ),
      ];
      break;
    default:
      medications = [];
      break;
  }
  
  // Sort medications alphabetically by name
  medications.sort((a, b) => a.name.compareTo(b.name));
  return medications;
}
