import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mama_app/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/professional_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ProfessionalModel> _professionals = [];
  bool _isLoading = true;
  final FirestoreService _firestoreService = FirestoreService();
  String? _currentUserId; // This would come from your auth service
  final AuthService _authService = AuthService();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    // TODO: Get current user ID from auth service
    _currentUserId = _authService.currentUserId; // Replace with actual user ID
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _professionals = getProfessionals();
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    // Data is now streamed, so no need to manually refresh
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Virtual Consultation',
        backgroundColor: AppColors.consultation,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.textWhite,
          labelColor: AppColors.textWhite,
          unselectedLabelColor: AppColors.textWhite.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Book Consultation'),
            Tab(text: 'My Appointments'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.consultation,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBookConsultationTab(),
            _buildAppointmentsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookConsultationTab() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.consultation));
    }

    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      children: [
        // Info Card
        CustomCard(
          gradient: LinearGradient(
            colors: [
              AppColors.consultation.withOpacity(0.1),
              AppColors.consultation.withOpacity(0.05),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.call,
                size: AppConstants.iconXXL,
                color: AppColors.consultation,
              ),
              const SizedBox(height: AppConstants.paddingM),
              const Text(
                'Connect with Health Professionals',
                style: TextStyle(
                  fontSize: AppConstants.fontXL,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingS),
              const Text(
                'Mobile consultations available from the comfort of your home',
                style: TextStyle(
                  fontSize: AppConstants.fontM,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.paddingL),

        // Available Professionals
        const Text(
          'Available Professionals',
          style: TextStyle(
            fontSize: AppConstants.fontXL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingM),

        ..._professionals
            .map((professional) => _buildProfessionalCard(professional)),
      ],
    );
  }

  Widget _buildProfessionalCard(ProfessionalModel professional) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      onTap: () {
        _showProfessionalDetails(professional);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.consultation.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: AppConstants.iconXL,
                  color: AppColors.consultation,
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      professional.name,
                      style: const TextStyle(
                        fontSize: AppConstants.fontL,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingXS),
                    Text(
                      professional.specialty,
                      style: const TextStyle(
                        fontSize: AppConstants.fontM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingXS),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: AppConstants.iconS,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppConstants.paddingXS),
                        Text(
                          '${professional.rating} • ${professional.experience}',
                          style: const TextStyle(
                            fontSize: AppConstants.fontS,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: const Text(
                  'Available',
                  style: TextStyle(
                    fontSize: AppConstants.fontXS,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _showBookingDialog(professional);
              },
              icon: const Icon(
                Icons.calendar_today,
                color: Colors.white,
              ),
              label: const Text('Book Appointment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.consultation,
                foregroundColor: AppColors.textWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.consultation));
    }

    if (_currentUserId == null) {
      return const Center(
        child: Text(
          'Please log in to view appointments',
          style: TextStyle(
            fontSize: AppConstants.fontM,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Upcoming Appointments
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getUpcomingAppointments(_currentUserId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.consultation));
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading appointments: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                );
              }

              final appointments = snapshot.data?.docs ?? [];

              if (appointments.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  children: [
                    CustomCard(
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: AppConstants.iconXXL,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppConstants.paddingM),
                          const Text(
                            'No Upcoming Appointments',
                            style: TextStyle(
                              fontSize: AppConstants.fontL,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingS),
                          const Text(
                            'Book a consultation with a healthcare professional',
                            style: TextStyle(
                              fontSize: AppConstants.fontM,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return ListView(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                children: [
                  const Text(
                    'Upcoming Appointments',
                    style: TextStyle(
                      fontSize: AppConstants.fontXL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  ...appointments.map((doc) {
                    final appointment = _documentToAppointmentModel(doc);
                    return _buildAppointmentCard(appointment);
                  }),
                ],
              );
            },
          ),
        ),

        // Past Appointments
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getPastAppointments(_currentUserId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.consultation));
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading past appointments: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                );
              }

              final appointments = snapshot.data?.docs ?? [];

              if (appointments.isEmpty) {
                return const Center(
                  child: Text(
                    'No past consultations',
                    style: TextStyle(
                      fontSize: AppConstants.fontM,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                children: [
                  const Text(
                    'Past Consultations',
                    style: TextStyle(
                      fontSize: AppConstants.fontXL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  ...appointments.map((doc) {
                    final appointment = _documentToAppointmentModel(doc);
                    return _buildAppointmentCard(appointment);
                  }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  AppointmentModel _documentToAppointmentModel(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      professionalId: data['professionalId'] ?? '',
      professionalName: data['professionalName'] ?? '',
      professionalSpecialty: data['professionalSpecialty'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'upcoming',
      consultationType: data['consultationType'] ?? 'call',
      notes: data['notes'],
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    final isUpcoming = appointment.status == 'upcoming';
    final isCompleted = appointment.status == 'completed';

    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.consultation.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.call,
                  color: AppColors.consultation,
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.professionalName,
                      style: const TextStyle(
                        fontSize: AppConstants.fontL,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      appointment.professionalSpecialty,
                      style: const TextStyle(
                        fontSize: AppConstants.fontS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isUpcoming
                      ? AppColors.info.withOpacity(0.1)
                      : isCompleted
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Text(
                  isUpcoming
                      ? 'Upcoming'
                      : isCompleted
                          ? 'Completed'
                          : 'Cancelled',
                  style: TextStyle(
                    fontSize: AppConstants.fontXS,
                    color: isUpcoming
                        ? AppColors.info
                        : isCompleted
                            ? AppColors.success
                            : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: AppConstants.iconS,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppConstants.paddingS),
              Text(
                _formatDateTime(appointment.dateTime),
                style: const TextStyle(
                  fontSize: AppConstants.fontM,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Chip(
                label: const Text('Phone Call'),
                backgroundColor: AppColors.consultation.withOpacity(0.1),
                labelStyle: const TextStyle(
                  color: AppColors.consultation,
                  fontSize: AppConstants.fontS,
                ),
              ),
            ],
          ),
          if (appointment.notes != null) ...[
            const SizedBox(height: AppConstants.paddingS),
            Text(
              'Notes: ${appointment.notes}',
              style: const TextStyle(
                fontSize: AppConstants.fontS,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (isUpcoming) ...[
            const SizedBox(height: AppConstants.paddingM),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _cancelAppointment(appointment.id);
                    },
                    icon: const Icon(Icons.cancel_outlined,
                        size: AppConstants.iconS),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isAppointmentTime(appointment.dateTime)
                        ? () {
                            _makePhoneCall(appointment.mobileNumber);
                          }
                        : null,
                    icon: const Icon(Icons.call, size: AppConstants.iconS),
                    label: const Text('Call Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAppointmentTime(appointment.dateTime)
                          ? AppColors.consultation
                          : AppColors.textSecondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (!_isAppointmentTime(appointment.dateTime))
              Container(
                margin: const EdgeInsets.only(top: AppConstants.paddingS),
                padding: const EdgeInsets.all(AppConstants.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: AppConstants.iconS,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: AppConstants.paddingS),
                    Expanded(
                      child: Text(
                        'Call button will be enabled at ${_formatTime(appointment.dateTime)}',
                        style: TextStyle(
                          fontSize: AppConstants.fontS,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _showProfessionalDetails(ProfessionalModel professional) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXL),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: ListView(
            controller: scrollController,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.consultation.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.consultation,
                      size: AppConstants.iconL,
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          professional.name,
                          style: const TextStyle(
                            fontSize: AppConstants.fontXL,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          professional.specialty,
                          style: const TextStyle(
                            fontSize: AppConstants.fontM,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: AppConstants.iconS,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: AppConstants.paddingXS),
                            Text(
                              '${professional.rating} • ${professional.experience}',
                              style: const TextStyle(
                                fontSize: AppConstants.fontS,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingL),

              // About
              const Text(
                'About',
                style: TextStyle(
                  fontSize: AppConstants.fontL,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.paddingS),
              Text(
                professional.about,
                style: const TextStyle(
                  fontSize: AppConstants.fontM,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppConstants.paddingL),

              // Qualifications
              const Text(
                'Qualifications',
                style: TextStyle(
                  fontSize: AppConstants.fontL,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.paddingS),
              ...professional.qualifications.map((qualification) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppConstants.paddingS),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.consultation,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingM),
                        Expanded(
                          child: Text(
                            qualification,
                            style: const TextStyle(
                              fontSize: AppConstants.fontM,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: AppConstants.paddingL),

              // Contact
              const Text(
                'Contact',
                style: TextStyle(
                  fontSize: AppConstants.fontL,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.paddingS),
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone, color: AppColors.consultation),
                    const SizedBox(width: AppConstants.paddingM),
                    Text(
                      professional.mobileNumber,
                      style: const TextStyle(
                        fontSize: AppConstants.fontM,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        _makePhoneCall(professional.mobileNumber);
                      },
                      icon:
                          const Icon(Icons.call, color: AppColors.consultation),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingL),

              // Available Times
              const Text(
                'Available Times',
                style: TextStyle(
                  fontSize: AppConstants.fontL,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.paddingS),
              ...professional.availableSlots.map((slot) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppConstants.paddingS),
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusM),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slot.day,
                            style: const TextStyle(
                              fontSize: AppConstants.fontM,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingXS),
                          Wrap(
                            spacing: AppConstants.paddingS,
                            runSpacing: AppConstants.paddingS,
                            children: slot.times
                                .map((time) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppConstants.paddingS,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.consultation
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.radiusS),
                                      ),
                                      child: Text(
                                        time,
                                        style: const TextStyle(
                                          fontSize: AppConstants.fontS,
                                          color: AppColors.consultation,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: AppConstants.paddingL),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showBookingDialog(professional);
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Book Appointment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.consultation,
                    foregroundColor: AppColors.textWhite,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDialog(ProfessionalModel professional) {
    final selectedDay = ValueNotifier<String?>(null);
    final selectedTime = ValueNotifier<String?>(null);
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Book Consultation with ${professional.name}'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    professional.specialty,
                    style: const TextStyle(
                      fontSize: AppConstants.fontM,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  const Text(
                    'Select Day:',
                    style: TextStyle(
                      fontSize: AppConstants.fontM,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingS),
                  Wrap(
                    spacing: AppConstants.paddingS,
                    runSpacing: AppConstants.paddingS,
                    children: professional.availableSlots
                        .map((slot) => ValueListenableBuilder<String?>(
                              valueListenable: selectedDay,
                              builder: (context, value, child) {
                                final isSelected = value == slot.day;
                                return FilterChip(
                                  label: Text(slot.day),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    selectedDay.value =
                                        selected ? slot.day : null;
                                    selectedTime.value =
                                        null; // Reset time when day changes
                                  },
                                  backgroundColor: AppColors.surfaceLight,
                                  selectedColor:
                                      AppColors.consultation.withOpacity(0.2),
                                  checkmarkColor: AppColors.consultation,
                                );
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  const Text(
                    'Select Time:',
                    style: TextStyle(
                      fontSize: AppConstants.fontM,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingS),
                  ValueListenableBuilder<String?>(
                    valueListenable: selectedDay,
                    builder: (context, day, child) {
                      if (day == null) {
                        return const Text(
                          'Please select a day first',
                          style: TextStyle(
                            fontSize: AppConstants.fontS,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        );
                      }

                      final selectedSlot = professional.availableSlots
                          .firstWhere((slot) => slot.day == day);

                      return Wrap(
                        spacing: AppConstants.paddingS,
                        runSpacing: AppConstants.paddingS,
                        children: selectedSlot.times
                            .map((time) => ValueListenableBuilder<String?>(
                                  valueListenable: selectedTime,
                                  builder: (context, value, child) {
                                    final isSelected = value == time;
                                    return FilterChip(
                                      label: Text(time),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        selectedTime.value =
                                            selected ? time : null;
                                      },
                                      backgroundColor: AppColors.surfaceLight,
                                      selectedColor: AppColors.consultation
                                          .withOpacity(0.2),
                                      checkmarkColor: AppColors.consultation,
                                    );
                                  },
                                ))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  const Text(
                    'Notes (Optional):',
                    style: TextStyle(
                      fontSize: AppConstants.fontM,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingS),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      hintText:
                          'Describe your symptoms or reason for consultation...',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusM),
                      ),
                      contentPadding:
                          const EdgeInsets.all(AppConstants.paddingM),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ValueListenableBuilder<String?>(
              valueListenable: selectedTime,
              builder: (context, time, child) {
                final canBook = selectedDay.value != null && time != null;
                return ElevatedButton(
                  onPressed: canBook
                      ? () async {
                          Navigator.pop(context);
                          await _bookAppointment(
                            professional: professional,
                            day: selectedDay.value!,
                            time: time!,
                            notes: notesController.text.trim(),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.consultation,
                    foregroundColor: AppColors.textWhite,
                  ),
                  child: const Text('Book Appointment'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bookAppointment({
    required ProfessionalModel professional,
    required String day,
    required String time,
    required String notes,
  }) async {
    if (_currentUserId == null) {
      _showErrorSnackBar('Please log in to book an appointment');
      return;
    }

    // Parse the selected day and time to create a DateTime
    final now = DateTime.now();
    final dayIndex =
        ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'].indexOf(day);
    final timeParts = time.split(RegExp(r'[:\s]'));
    final hour = int.parse(timeParts[0]);
    final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
    final isPM = time.contains('PM') && hour != 12;
    final finalHour = isPM ? hour + 12 : (hour == 12 ? 0 : hour);

    // Calculate the date for the selected day
    int daysUntilSelected = (dayIndex - now.weekday + 7) % 7;
    if (daysUntilSelected == 0) {
      daysUntilSelected = 7; // If today, schedule for next week
    }

    final appointmentDate = DateTime(
      now.year,
      now.month,
      now.day + daysUntilSelected,
      finalHour,
      minute,
    );

    try {
      await _firestoreService.bookAppointment(
        userId: _currentUserId!,
        professionalId: professional.id,
        professionalName: professional.name,
        professionalSpecialty: professional.specialty,
        mobileNumber: professional.mobileNumber,
        dateTime: appointmentDate,
        notes: notes.isNotEmpty ? notes : '',
      );

      _showSuccessSnackBar('Appointment booked successfully!');
      _tabController.animateTo(1); // Switch to appointments tab
    } catch (e) {
      _showErrorSnackBar('Failed to book appointment. Please try again.');
    }
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    final confirmed = await _showConfirmationDialog(
      'Cancel Appointment',
      'Are you sure you want to cancel this appointment?',
    );

    if (confirmed == true) {
      try {
        await _firestoreService.cancelAppointment(appointmentId);
        _showSuccessSnackBar('Appointment cancelled successfully!');
      } catch (e) {
        _showErrorSnackBar('Failed to cancel appointment. Please try again.');
      }
    }
  }

  Future<bool?> _showConfirmationDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textWhite,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        _showErrorSnackBar('Could not launch phone call');
      }
    } catch (e) {
      _showErrorSnackBar('Error making phone call: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDate =
        DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = appointmentDate.difference(today).inDays;

    String dayString;
    if (difference == 0) {
      dayString = 'Today';
    } else if (difference == 1) {
      dayString = 'Tomorrow';
    } else if (difference == -1) {
      dayString = 'Yesterday';
    } else {
      dayString = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final timeString = '$hour:$minute';

    return '$dayString, $timeString';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool _isAppointmentTime(DateTime appointmentDateTime) {
    final now = DateTime.now();

    // Create a DateTime for today with the appointment's time
    final appointmentTimeToday = DateTime(
      now.year,
      now.month,
      now.day,
      appointmentDateTime.hour,
      appointmentDateTime.minute,
    );

    // Check if the appointment date is today
    final isToday = now.year == appointmentDateTime.year &&
        now.month == appointmentDateTime.month &&
        now.day == appointmentDateTime.day;

    if (!isToday) {
      return false;
    }

    // Check if the current time is within 15 minutes of the appointment time
    final timeDifference = now.difference(appointmentTimeToday).inMinutes;
    return timeDifference >= -15 &&
        timeDifference <= 60; // 15 minutes before to 60 minutes after
  }
}
