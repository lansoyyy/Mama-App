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
  return [
    MedicationCategory(
      id: '1',
      name: 'Blood Pressure Medications',
      description: 'Medications for managing hypertension',
      iconData: Icons.favorite,
      color: Colors.red,
      translationFilipino: 'Gamot sa Presyon ng Dugo',
      translationCebuano: 'Tambal sa Presyon sa Dugo',
    ),
    // MedicationCategory(
    //   id: '2',
    //   name: 'Prenatal Vitamins',
    //   description: 'Essential vitamins for pregnancy',
    //   iconData: Icons.medical_services,
    //   color: AppColors.primary,
    //   translationFilipino: 'Bitalaminang Prenatal',
    //   translationCebuano: 'Bitaminang Prenatal',
    // ),
    // MedicationCategory(
    //   id: '3',
    //   name: 'Iron Supplements',
    //   description: 'Prevent anemia during pregnancy',
    //   iconData: Icons.bloodtype,
    //   color: AppColors.error,
    //   translationFilipino: 'Suplemento sa Bakal',
    //   translationCebuano: 'Suplemento sa Bakal',
    // ),
    // MedicationCategory(
    //   id: '4',
    //   name: 'Folic Acid',
    //   description: 'Important for baby development',
    //   iconData: Icons.favorite,
    //   color: AppColors.secondary,
    //   translationFilipino: 'Asido na Foliko',
    //   translationCebuano: 'Asido nga Foliko',
    // ),
    // MedicationCategory(
    //   id: '5',
    //   name: 'Calcium',
    //   description: 'Strengthen bones and teeth',
    //   iconData: Icons.health_and_safety,
    //   color: AppColors.info,
    //   translationFilipino: 'Kalsyo',
    //   translationCebuano: 'Kalsyo',
    // ),
    // MedicationCategory(
    //   id: '6',
    //   name: 'Pain Relief',
    //   description: 'Safe pain management options',
    //   iconData: Icons.healing,
    //   color: AppColors.warning,
    //   translationFilipino: 'Panlipas sa Sakit',
    //   translationCebuano: 'Panasakit',
    // ),
    // MedicationCategory(
    //   id: '7',
    //   name: 'Antibiotics',
    //   description: 'Understanding safe antibiotics',
    //   iconData: Icons.medication_liquid,
    //   color: AppColors.success,
    //   translationFilipino: 'Antibyotiko',
    //   translationCebuano: 'Antibyotiko',
    // ),
  ];
}

List<MedicationModel> getMedicationsByCategory(String categoryId) {
  switch (categoryId) {
    case '1': // Blood Pressure Medications
      return [
        MedicationModel(
          id: 'bp1',
          name: 'AMLODIPINE',
          category: 'Blood Pressure Medications',
          description: 'Calcium channel blocker that relaxes blood vessels',
          uses: [
            'Treats high blood pressure (hypertension)',
            'Prevents angina (chest pain)',
            'Reduces workload on the heart',
            'Improves blood flow'
          ],
          dosage: [
            'Start with 5mg once daily',
            'May increase to 10mg once daily',
            'Take at the same time each day',
            'Can be taken with or without food'
          ],
          sideEffects: [
            'Swelling in ankles or feet',
            'Dizziness or lightheadedness',
            'Flushing or feeling warm',
            'Headache',
            'Fatigue'
          ],
          precautions: [
            'Avoid grapefruit or grapefruit juice',
            'Rise slowly when standing up',
            'Monitor blood pressure regularly',
            'Inform doctor of liver problems'
          ],
          imageUrl:
              'https://drive.google.com/file/d/1CEquqy02p0U_Tj0dndPKCafq1d7gmvWx/view?usp=drive_link',
          isSafeForPregnancy: false,
          pregnancyCategory: 'C',
          translationFilipino: 'AMLODIPINE',
          translationCebuano: 'AMLODIPINE',
        ),
        MedicationModel(
          id: 'bp2',
          name: 'ENALAPRIL',
          category: 'Blood Pressure Medications',
          description: 'ACE inhibitor that relaxes blood vessels',
          uses: [
            'Treats high blood pressure',
            'Treats congestive heart failure',
            'Prevents kidney problems from diabetes',
            'Improves survival after heart attack'
          ],
          dosage: [
            'Start with 5mg once daily',
            'May increase to 10-40mg daily',
            'Take consistently at same time',
            'Can be taken with or without food'
          ],
          sideEffects: [
            'Dry persistent cough',
            'Dizziness',
            'Fatigue',
            'Headache',
            'Changes in taste'
          ],
          precautions: [
            'Do not use during pregnancy',
            'Monitor potassium levels',
            'Stay hydrated',
            'Report severe dizziness immediately'
          ],
          imageUrl:
              'https://drive.google.com/file/d/1Mmgh9WG_AayrlZOYzqiog7S4kyKeYrKU/view?usp=drive_link',
          isSafeForPregnancy: false,
          pregnancyCategory: 'D',
          translationFilipino: 'ENALAPRIL',
          translationCebuano: 'ENALAPRIL',
        ),
        MedicationModel(
          id: 'bp3',
          name: 'FUROSEMIDE',
          category: 'Blood Pressure Medications',
          description: 'Loop diuretic that removes excess fluid',
          uses: [
            'Treats fluid retention (edema)',
            'Treats high blood pressure',
            'Reduces swelling in heart failure',
            'Treats kidney problems'
          ],
          dosage: [
            'Start with 20-40mg once daily',
            'May increase to 80mg daily',
            'Take in morning to avoid nighttime urination',
            'Monitor weight daily'
          ],
          sideEffects: [
            'Increased urination',
            'Dizziness',
            'Muscle cramps',
            'Weakness',
            'Electrolyte imbalances'
          ],
          precautions: [
            'Monitor potassium levels',
            'Stay hydrated but avoid excess fluids',
            'May cause dehydration',
            'Avoid sun exposure'
          ],
          imageUrl:
              'https://drive.google.com/file/d/1Y9_gg82iG1IVgVx0tJaJIKZ4FcBPYpQF/view?usp=drive_link',
          isSafeForPregnancy: false,
          pregnancyCategory: 'C',
          translationFilipino: 'FUROSEMIDE',
          translationCebuano: 'FUROSEMIDE',
        ),
        MedicationModel(
          id: 'bp4',
          name: 'HYDROCHLOROTHIAZIDE',
          category: 'Blood Pressure Medications',
          description: 'Thiazide diuretic that reduces blood pressure',
          uses: [
            'Treats high blood pressure',
            'Reduces fluid retention',
            'Treats edema',
            'Prevents kidney stones'
          ],
          dosage: [
            'Start with 12.5-25mg once daily',
            'May increase to 50mg daily',
            'Take in morning',
            'Can be taken with food'
          ],
          sideEffects: [
            'Increased urination',
            'Dizziness',
            'Headache',
            'Muscle weakness',
            'Increased blood sugar'
          ],
          precautions: [
            'Monitor blood sugar levels',
            'Protect from sun exposure',
            'May cause potassium loss',
            'Regular blood tests needed'
          ],
          imageUrl:
              'https://drive.google.com/file/d/1fmiLVWmVayt1ByVtFkxHWfZhI_zHhDNb/view?usp=drive_link',
          isSafeForPregnancy: false,
          pregnancyCategory: 'B',
          translationFilipino: 'HYDROCHLOROTHIAZIDE',
          translationCebuano: 'HYDROCHLOROTHIAZIDE',
        ),
        MedicationModel(
          id: 'bp5',
          name: 'LABETALOL',
          category: 'Blood Pressure Medications',
          description:
              'Beta blocker that reduces heart rate and blood pressure',
          uses: [
            'Treats high blood pressure',
            'Treats hypertensive emergencies',
            'Controls blood pressure during pregnancy',
            'Prevents angina'
          ],
          dosage: [
            'Start with 100mg twice daily',
            'May increase to 2400mg daily',
            'Take with food',
            'Divide doses throughout day'
          ],
          sideEffects: [
            'Dizziness',
            'Fatigue',
            'Nausea',
            'Slow heart rate',
            'Cold hands and feet'
          ],
          precautions: [
            'Do not stop suddenly',
            'Monitor heart rate',
            'Avoid driving until effects known',
            'May mask low blood sugar symptoms'
          ],
          imageUrl:
              'https://drive.google.com/file/d/1XcaPGKm7jMocXe9CJ-6CC3WLab434hD8/view?usp=drive_link',
          isSafeForPregnancy: true,
          pregnancyCategory: 'C',
          translationFilipino: 'LABETALOL',
          translationCebuano: 'LABETALOL',
        ),
        MedicationModel(
          id: 'bp6',
          name: 'LOSARTAN',
          category: 'Blood Pressure Medications',
          description: 'ARB that blocks blood vessel constriction',
          uses: [
            'Treats high blood pressure',
            'Protects kidneys in diabetes',
            'Reduces stroke risk',
            'Treats heart failure'
          ],
          dosage: [
            'Start with 50mg once daily',
            'May increase to 100mg daily',
            'Take at same time daily',
            'Can be taken with or without food'
          ],
          sideEffects: [
            'Dizziness',
            'Fatigue',
            'Back pain',
            'Diarrhea',
            'Cough (less common than ACE inhibitors)'
          ],
          precautions: [
            'Do not use during pregnancy',
            'Monitor kidney function',
            'May cause high potassium',
            'Report swelling immediately'
          ],
          imageUrl:
              'https://drive.google.com/file/d/1qmecftNiyYWnjoLmx6BbT4qyAqZpeV-4/view?usp=drive_link',
          isSafeForPregnancy: false,
          pregnancyCategory: 'D',
          translationFilipino: 'LOSARTAN',
          translationCebuano: 'LOSARTAN',
        ),
        MedicationModel(
          id: 'bp7',
          name: 'METHYLDOPA',
          category: 'Blood Pressure Medications',
          description: 'Centrally acting antihypertensive',
          uses: [
            'Treats high blood pressure',
            'Safe for use during pregnancy',
            'Reduces blood pressure gradually',
            'Alternative for patients who cannot tolerate other medications'
          ],
          dosage: [
            'Start with 250mg 2-3 times daily',
            'May increase to 3g daily',
            'Take with food',
            'Divide doses throughout day'
          ],
          sideEffects: [
            'Drowsiness',
            'Dizziness',
            'Dry mouth',
            'Headache',
            'Depression (rare)'
          ],
          precautions: [
            'Avoid driving or operating machinery',
            'May cause drowsiness',
            'Monitor for depression',
            'Regular blood tests needed'
          ],
          imageUrl:
              'https://drive.google.com/file/d/1wKk_juL-XLkaDXRdbLpGYdMiHzQqSFZW/view?usp=drive_link',
          isSafeForPregnancy: true,
          pregnancyCategory: 'B',
          translationFilipino: 'METHYLDOPA',
          translationCebuano: 'METHYLDOPA',
        ),
        MedicationModel(
          id: 'bp8',
          name: 'NEBIVOLOL',
          category: 'Blood Pressure Medications',
          description: 'Beta blocker with vasodilating properties',
          uses: [
            'Treats high blood pressure',
            'Reduces heart workload',
            'Improves blood flow',
            'May help with heart failure'
          ],
          dosage: [
            'Start with 5mg once daily',
            'May increase to 10mg daily',
            'Take at same time each day',
            'Can be taken with food'
          ],
          sideEffects: [
            'Headache',
            'Dizziness',
            'Fatigue',
            'Slow heart rate',
            'Nausea'
          ],
          precautions: [
            'Do not stop suddenly',
            'Monitor heart rate',
            'May cause dizziness',
            'Avoid alcohol'
          ],
          imageUrl:
              'https://drive.google.com/file/d/1MUmtLc76KHQrTCmeU7NGhnfkFof7HWl7/view?usp=drive_link',
          isSafeForPregnancy: false,
          pregnancyCategory: 'C',
          translationFilipino: 'NEBIVOLOL',
          translationCebuano: 'NEBIVOLOL',
        ),
        MedicationModel(
          id: 'bp9',
          name: 'NIFEDIPINE',
          category: 'Blood Pressure Medications',
          description: 'Calcium channel blocker for hypertension',
          uses: [
            'Treats high blood pressure',
            'Prevents angina (chest pain)',
            'Controls rapid heart rate',
            'Treats Raynaud\'s phenomenon'
          ],
          dosage: [
            'Extended-release: 30-60mg once daily',
            'Immediate-release: 10-20mg 3 times daily',
            'Take consistently',
            'Do not crush extended-release tablets'
          ],
          sideEffects: [
            'Flushing',
            'Headache',
            'Dizziness',
            'Swelling in ankles',
            'Palpitations'
          ],
          precautions: [
            'Avoid grapefruit juice',
            'Rise slowly when standing',
            'May cause rapid heartbeat',
            'Monitor blood pressure regularly'
          ],
          imageUrl:
              'https://drive.google.com/file/d/1rbuZwGf0dHy_tQhJrW_cKHBEDrxAV_dg/view?usp=drive_link',
          isSafeForPregnancy: false,
          pregnancyCategory: 'C',
          translationFilipino: 'NIFEDIPINE',
          translationCebuano: 'NIFEDIPINE',
        ),
        MedicationModel(
          id: 'bp10',
          name: 'SPIRONOLACTONE',
          category: 'Blood Pressure Medications',
          description: 'Potassium-sparing diuretic',
          uses: [
            'Treats high blood pressure',
            'Reduces fluid retention',
            'Treats heart failure',
            'Prevents low potassium'
          ],
          dosage: [
            'Start with 25-50mg once daily',
            'May increase to 200mg daily',
            'Take with food',
            'Take in morning if possible'
          ],
          sideEffects: [
            'High potassium levels',
            'Breast enlargement in men',
            'Irregular menstrual periods',
            'Dizziness',
            'Nausea'
          ],
          precautions: [
            'Monitor potassium levels',
            'Avoid potassium supplements',
            'May cause hormonal effects',
            'Regular blood tests needed'
          ],
          imageUrl:
              'https://drive.google.com/file/d/1GW2BxgoLWZclHylhg2l7JabnUYACkghW/view?usp=drive_link',
          isSafeForPregnancy: false,
          pregnancyCategory: 'C',
          translationFilipino: 'SPIRONOLACTONE',
          translationCebuano: 'SPIRONOLACTONE',
        ),
      ];
    case '2': // Prenatal Vitamins
      return [
        MedicationModel(
          id: 'pv1',
          name: 'Obimin',
          category: 'Prenatal Vitamins',
          description: 'Complete prenatal vitamin supplement',
          uses: [
            'Provides essential nutrients during pregnancy',
            'Supports fetal development',
            'Prevents nutritional deficiencies',
            'Maintains maternal health'
          ],
          dosage: [
            'One capsule daily',
            'Take with meals',
            'Continue throughout pregnancy and breastfeeding'
          ],
          sideEffects: [
            'Nausea',
            'Constipation',
            'Dark stools',
            'Stomach discomfort'
          ],
          precautions: [
            'Take with food to reduce stomach upset',
            'Do not exceed recommended dose',
            'Consult doctor if you have medical conditions'
          ],
          imageUrl: 'assets/images/medications/obimin.jpg',
          isSafeForPregnancy: true,
          pregnancyCategory: 'A',
          translationFilipino: 'Obimin',
          translationCebuano: 'Obimin',
        ),
        MedicationModel(
          id: 'pv2',
          name: 'Materna',
          category: 'Prenatal Vitamins',
          description: 'Prenatal multivitamin with DHA',
          uses: [
            'Supports baby brain development',
            'Provides essential vitamins and minerals',
            'Reduces risk of birth defects',
            'Supports maternal energy levels'
          ],
          dosage: [
            'One tablet daily',
            'Take with food',
            'Best taken at same time each day'
          ],
          sideEffects: [
            'Mild nausea',
            'Constipation',
            'Fishy aftertaste (due to DHA)'
          ],
          precautions: [
            'Take with meals to reduce side effects',
            'Inform doctor of other supplements',
            'May cause urine to turn bright yellow'
          ],
          imageUrl: 'assets/images/medications/materna.jpg',
          isSafeForPregnancy: true,
          pregnancyCategory: 'A',
          translationFilipino: 'Materna',
          translationCebuano: 'Materna',
        ),
      ];
    case '3': // Iron Supplements
      return [
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
    case '4': // Folic Acid
      return [
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
    case '5': // Calcium
      return [
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
    case '6': // Pain Relief
      return [
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
    case '7': // Antibiotics
      return [
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
        MedicationModel(
          id: 'a2',
          name: 'Cephalexin',
          category: 'Antibiotics',
          description: 'Cephalosporin antibiotic',
          uses: [
            'Treats bacterial infections',
            'Respiratory tract infections',
            'Ear infections',
            'Skin infections'
          ],
          dosage: [
            '250-500mg every 6 hours',
            'Complete full course',
            'Take with food if stomach upset'
          ],
          sideEffects: [
            'Nausea',
            'Diarrhea',
            'Stomach pain',
            'Vaginal itching'
          ],
          precautions: [
            'Inform doctor of penicillin allergy',
            'Complete full course',
            'May cause false positive urine glucose'
          ],
          imageUrl: 'assets/images/medications/cephalexin.jpg',
          isSafeForPregnancy: true,
          pregnancyCategory: 'B',
          translationFilipino: 'Cephalexin',
          translationCebuano: 'Cephalexin',
        ),
      ];
    default:
      return [];
  }
}
