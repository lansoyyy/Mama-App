class ProfessionalModel {
  final String id;
  final String name;
  final String specialty;
  final String mobileNumber;
  final String experience;
  final double rating;
  final List<TimeSlot> availableSlots;
  final String imageUrl;
  final List<String> qualifications;
  final String about;

  ProfessionalModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.mobileNumber,
    required this.experience,
    required this.rating,
    required this.availableSlots,
    required this.imageUrl,
    required this.qualifications,
    required this.about,
  });
}

class TimeSlot {
  final String day;
  final List<String> times;
  final bool isAvailable;

  TimeSlot({
    required this.day,
    required this.times,
    required this.isAvailable,
  });
}

class AppointmentModel {
  final String id;
  final String professionalId;
  final String professionalName;
  final String professionalSpecialty;
  final String mobileNumber;
  final DateTime dateTime;
  final String status; // 'upcoming', 'completed', 'cancelled'
  final String consultationType; // 'call' only
  final String? notes;

  AppointmentModel({
    required this.id,
    required this.professionalId,
    required this.professionalName,
    required this.professionalSpecialty,
    required this.mobileNumber,
    required this.dateTime,
    required this.status,
    required this.consultationType,
    this.notes,
  });
}

// Hardcoded professional data
List<ProfessionalModel> getProfessionals() {
  return [
    ProfessionalModel(
      id: '1',
      name: 'Dr. Maria Santos',
      specialty: 'OB-GYN Specialist',
      mobileNumber: '+639123456789',
      experience: '15 years',
      rating: 4.8,
      availableSlots: [
        TimeSlot(
          day: 'Monday',
          times: ['09:00 AM', '10:00 AM', '02:00 PM', '03:00 PM'],
          isAvailable: true,
        ),
        TimeSlot(
          day: 'Tuesday',
          times: ['09:00 AM', '11:00 AM', '02:00 PM', '04:00 PM'],
          isAvailable: true,
        ),
        TimeSlot(
          day: 'Wednesday',
          times: ['10:00 AM', '01:00 PM', '03:00 PM'],
          isAvailable: true,
        ),
        TimeSlot(
          day: 'Thursday',
          times: ['09:00 AM', '02:00 PM', '03:00 PM', '04:00 PM'],
          isAvailable: true,
        ),
        TimeSlot(
          day: 'Friday',
          times: ['10:00 AM', '11:00 AM', '02:00 PM', '03:00 PM'],
          isAvailable: true,
        ),
      ],
      imageUrl: 'assets/images/professionals/dr_maria.jpg',
      qualifications: [
        'MD - University of the Philippines',
        'Board Certified OB-GYN',
        'Fellowship in Maternal-Fetal Medicine'
      ],
      about:
          'Dr. Santos specializes in high-risk pregnancies and maternal care. She has delivered over 2000 babies and is known for her compassionate approach to patient care.',
    ),
    ProfessionalModel(
      id: '2',
      name: 'Dr. Juan Reyes',
      specialty: 'Pharmacist',
      mobileNumber: '+639234567890',
      experience: '10 years',
      rating: 4.6,
      availableSlots: [
        TimeSlot(
          day: 'Monday',
          times: ['08:00 AM', '10:00 AM', '01:00 PM', '03:00 PM'],
          isAvailable: true,
        ),
        TimeSlot(
          day: 'Tuesday',
          times: ['09:00 AM', '11:00 AM', '02:00 PM'],
          isAvailable: true,
        ),
        TimeSlot(
          day: 'Wednesday',
          times: ['08:00 AM', '10:00 AM', '02:00 PM', '04:00 PM'],
          isAvailable: true,
        ),
        TimeSlot(
          day: 'Thursday',
          times: ['09:00 AM', '01:00 PM', '03:00 PM'],
          isAvailable: true,
        ),
        TimeSlot(
          day: 'Friday',
          times: ['08:00 AM', '10:00 AM', '01:00 PM', '03:00 PM'],
          isAvailable: true,
        ),
      ],
      imageUrl: 'assets/images/professionals/dr_juan.jpg',
      qualifications: [
        'PharmD - University of Santo Tomas',
        'Licensed Pharmacist',
        'Certified Clinical Pharmacist'
      ],
      about:
          'Dr. Reyes specializes in medication management for pregnant women. He provides expert advice on drug interactions and safe medication practices during pregnancy.',
    ),
    ProfessionalModel(
      id: '3',
      name: 'Nurse Ana Cruz',
      specialty: 'Maternal Health Nurse',
      mobileNumber: '+639345678901',
      experience: '12 years',
      rating: 4.9,
      availableSlots: [
        TimeSlot(
          day: 'Monday',
          times: ['07:00 AM', '09:00 AM', '01:00 PM', '04:00 PM'],
          isAvailable: true,
        ),
        TimeSlot(
          day: 'Tuesday',
          times: ['08:00 AM', '10:00 AM', '02:00 PM', '05:00 PM'],
          isAvailable: true,
        ),
        TimeSlot(
          day: 'Wednesday',
          times: ['07:00 AM', '11:00 AM', '03:00 PM'],
          isAvailable: true,
        ),
        TimeSlot(
          day: 'Thursday',
          times: ['08:00 AM', '01:00 PM', '04:00 PM'],
          isAvailable: true,
        ),
        TimeSlot(
          day: 'Friday',
          times: ['07:00 AM', '09:00 AM', '02:00 PM', '05:00 PM'],
          isAvailable: true,
        ),
      ],
      imageUrl: 'assets/images/professionals/nurse_ana.jpg',
      qualifications: [
        'BSN - Manila Central University',
        'Registered Nurse',
        'Certified Maternal-Newborn Nurse'
      ],
      about:
          'Nurse Cruz provides comprehensive maternal health education and support. She specializes in prenatal care, postpartum recovery, and newborn care guidance.',
    ),
    ProfessionalModel(
      id: '4',
      name: 'Dr. Rosa Garcia',
      specialty: 'Pediatrician',
      mobileNumber: '+639456789012',
      experience: '18 years',
      rating: 4.7,
      availableSlots: [
        TimeSlot(
          day: 'Monday',
          times: ['10:00 AM', '11:00 AM', '02:00 PM', '04:00 PM'],
          isAvailable: true,
        ),
        TimeSlot(
          day: 'Tuesday',
          times: ['09:00 AM', '12:00 PM', '03:00 PM'],
          isAvailable: true,
        ),
        TimeSlot(
          day: 'Wednesday',
          times: ['10:00 AM', '01:00 PM', '03:00 PM', '05:00 PM'],
          isAvailable: true,
        ),
        TimeSlot(
          day: 'Thursday',
          times: ['09:00 AM', '11:00 AM', '02:00 PM'],
          isAvailable: true,
        ),
        TimeSlot(
          day: 'Friday',
          times: ['10:00 AM', '12:00 PM', '03:00 PM', '04:00 PM'],
          isAvailable: true,
        ),
      ],
      imageUrl: 'assets/images/professionals/dr_rosa.jpg',
      qualifications: [
        'MD - Ateneo School of Medicine',
        'Board Certified Pediatrician',
        'Fellowship in Neonatology'
      ],
      about:
          'Dr. Garcia specializes in newborn care and pediatric health. She provides comprehensive care for infants and children, with special expertise in developmental milestones and vaccinations.',
    ),
    ProfessionalModel(
      id: '5',
      name: 'Dr. Jose Martinez',
      specialty: 'General Practitioner',
      mobileNumber: '+639567890123',
      experience: '20 years',
      rating: 4.5,
      availableSlots: [
        TimeSlot(
          day: 'Monday',
          times: ['08:00 AM', '10:00 AM', '02:00 PM', '04:00 PM'],
          isAvailable: true,
        ),
        TimeSlot(
          day: 'Tuesday',
          times: ['09:00 AM', '11:00 AM', '01:00 PM', '03:00 PM'],
          isAvailable: true,
        ),
        TimeSlot(
          day: 'Wednesday',
          times: ['08:00 AM', '10:00 AM', '02:00 PM', '05:00 PM'],
          isAvailable: true,
        ),
        TimeSlot(
          day: 'Thursday',
          times: ['09:00 AM', '12:00 PM', '03:00 PM'],
          isAvailable: true,
        ),
        TimeSlot(
          day: 'Friday',
          times: ['08:00 AM', '11:00 AM', '02:00 PM', '04:00 PM'],
          isAvailable: true,
        ),
      ],
      imageUrl: 'assets/images/professionals/dr_jose.jpg',
      qualifications: [
        'MD - De La Salle University',
        'Board Certified General Practitioner',
        'Certificate in Family Medicine'
      ],
      about:
          'Dr. Martinez provides comprehensive primary care for the whole family. He has extensive experience in managing common illnesses and providing preventive care for pregnant women and children.',
    ),
  ];
}

// Appointment management
class AppointmentManager {
  static final List<AppointmentModel> _appointments = [
    // Sample existing appointments
    AppointmentModel(
      id: '1',
      professionalId: '1',
      professionalName: 'Dr. Maria Santos',
      professionalSpecialty: 'OB-GYN Specialist',
      mobileNumber: '+639123456789',
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 3)),
      status: 'upcoming',
      consultationType: 'call',
      notes: 'Routine prenatal checkup',
    ),
    AppointmentModel(
      id: '2',
      professionalId: '2',
      professionalName: 'Dr. Juan Reyes',
      professionalSpecialty: 'Pharmacist',
      mobileNumber: '+639234567890',
      dateTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      status: 'completed',
      consultationType: 'call',
      notes: 'Medication consultation',
    ),
  ];

  static List<AppointmentModel> getAppointments() {
    return List.from(_appointments);
  }

  static List<AppointmentModel> getUpcomingAppointments() {
    return _appointments
        .where((appointment) => appointment.status == 'upcoming')
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  static List<AppointmentModel> getPastAppointments() {
    return _appointments
        .where((appointment) =>
            appointment.status == 'completed' ||
            appointment.status == 'cancelled')
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  static Future<bool> bookAppointment({
    required String professionalId,
    required String professionalName,
    required String professionalSpecialty,
    required String mobileNumber,
    required DateTime dateTime,
    required String notes,
  }) async {
    try {
      final newAppointment = AppointmentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        professionalId: professionalId,
        professionalName: professionalName,
        professionalSpecialty: professionalSpecialty,
        mobileNumber: mobileNumber,
        dateTime: dateTime,
        status: 'upcoming',
        consultationType: 'call',
        notes: notes,
      );

      _appointments.add(newAppointment);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> cancelAppointment(String appointmentId) async {
    try {
      final appointmentIndex = _appointments
          .indexWhere((appointment) => appointment.id == appointmentId);

      if (appointmentIndex != -1) {
        _appointments[appointmentIndex] =
            _appointments[appointmentIndex].copyWith(status: 'cancelled');
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> completeAppointment(String appointmentId) async {
    try {
      final appointmentIndex = _appointments
          .indexWhere((appointment) => appointment.id == appointmentId);

      if (appointmentIndex != -1) {
        _appointments[appointmentIndex] =
            _appointments[appointmentIndex].copyWith(status: 'completed');
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

extension AppointmentModelCopy on AppointmentModel {
  AppointmentModel copyWith({
    String? id,
    String? professionalId,
    String? professionalName,
    String? professionalSpecialty,
    String? mobileNumber,
    DateTime? dateTime,
    String? status,
    String? consultationType,
    String? notes,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      professionalId: professionalId ?? this.professionalId,
      professionalName: professionalName ?? this.professionalName,
      professionalSpecialty:
          professionalSpecialty ?? this.professionalSpecialty,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      consultationType: consultationType ?? this.consultationType,
      notes: notes ?? this.notes,
    );
  }
}
