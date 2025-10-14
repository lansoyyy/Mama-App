import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookConsultationTab(),
          _buildAppointmentsTab(),
        ],
      ),
    );
  }

  Widget _buildBookConsultationTab() {
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
          child: const Column(
            children: [
              Icon(
                Icons.video_call,
                size: AppConstants.iconXXL,
                color: AppColors.consultation,
              ),
              SizedBox(height: AppConstants.paddingM),
              Text(
                'Connect with Health Professionals',
                style: TextStyle(
                  fontSize: AppConstants.fontXL,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppConstants.paddingS),
              Text(
                'Video or audio consultations available from the comfort of your home',
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
        
        _buildProfessionalCard(
          'Dr. Maria Santos',
          'OB-GYN Specialist',
          'Available Now',
          true,
          Icons.person,
        ),
        _buildProfessionalCard(
          'Dr. Juan Reyes',
          'Pharmacist',
          'Available at 2:00 PM',
          false,
          Icons.person,
        ),
        _buildProfessionalCard(
          'Nurse Ana Cruz',
          'Maternal Health Nurse',
          'Available Now',
          true,
          Icons.person,
        ),
        _buildProfessionalCard(
          'Dr. Rosa Garcia',
          'Pediatrician',
          'Available Tomorrow',
          false,
          Icons.person,
        ),
      ],
    );
  }

  Widget _buildProfessionalCard(
    String name,
    String specialty,
    String availability,
    bool isAvailable,
    IconData icon,
  ) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      onTap: () {
        _showBookingDialog(name, specialty);
      },
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.consultation.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: AppConstants.iconL,
              color: AppColors.consultation,
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: AppConstants.fontL,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingXS),
                Text(
                  specialty,
                  style: const TextStyle(
                    fontSize: AppConstants.fontM,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingXS),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isAvailable ? AppColors.success : AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingXS),
                    Text(
                      availability,
                      style: TextStyle(
                        fontSize: AppConstants.fontS,
                        color: isAvailable ? AppColors.success : AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: AppConstants.iconS,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
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
        
        _buildAppointmentCard(
          'Dr. Maria Santos',
          'OB-GYN Specialist',
          'Today, 3:00 PM',
          'Video Call',
          true,
        ),
        _buildAppointmentCard(
          'Dr. Juan Reyes',
          'Pharmacist',
          'Tomorrow, 10:00 AM',
          'Audio Call',
          false,
        ),
        
        const SizedBox(height: AppConstants.paddingL),
        const Text(
          'Past Consultations',
          style: TextStyle(
            fontSize: AppConstants.fontXL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingM),
        
        _buildAppointmentCard(
          'Nurse Ana Cruz',
          'Maternal Health Nurse',
          'Yesterday, 2:00 PM',
          'Video Call',
          false,
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(
    String name,
    String specialty,
    String dateTime,
    String type,
    bool isUpcoming,
  ) {
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
                  type == 'Video Call' ? Icons.video_call : Icons.call,
                  color: AppColors.consultation,
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: AppConstants.fontL,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      specialty,
                      style: const TextStyle(
                        fontSize: AppConstants.fontS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
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
                dateTime,
                style: const TextStyle(
                  fontSize: AppConstants.fontM,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Chip(
                label: Text(type),
                backgroundColor: AppColors.consultation.withOpacity(0.1),
                labelStyle: const TextStyle(
                  color: AppColors.consultation,
                  fontSize: AppConstants.fontS,
                ),
              ),
            ],
          ),
          if (isUpcoming) ...[
            const SizedBox(height: AppConstants.paddingM),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cancel appointment feature coming soon')),
                      );
                    },
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Video call feature coming soon')),
                      );
                    },
                    icon: const Icon(Icons.video_call),
                    label: const Text('Join'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showBookingDialog(String name, String specialty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book Consultation with $name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(specialty),
            const SizedBox(height: AppConstants.paddingL),
            const Text('Select consultation type:'),
            const SizedBox(height: AppConstants.paddingM),
            ListTile(
              leading: const Icon(Icons.video_call),
              title: const Text('Video Call'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Book video call
              },
            ),
            ListTile(
              leading: const Icon(Icons.call),
              title: const Text('Audio Call'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Book audio call
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
