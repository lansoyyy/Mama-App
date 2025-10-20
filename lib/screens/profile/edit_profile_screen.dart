import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/firebase_storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactController =
      TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _conditionsController = TextEditingController();

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorageService _storageService = FirebaseStorageService();

  String _selectedUserType = 'Mother';
  DateTime _selectedDate = DateTime.now();
  String _selectedBloodType = 'O+';
  String? _profilePictureUrl;
  File? _profileImageFile;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        final userData = await _firestoreService.getUser(userId);
        if (userData != null) {
          setState(() {
            _nameController.text = userData['fullName'] ?? '';
            _emailController.text = userData['email'] ?? '';
            _phoneController.text = userData['phoneNumber'] ?? '';
            _addressController.text = userData['address'] ?? '';
            _emergencyContactController.text =
                userData['emergencyContact'] ?? '';
            _selectedUserType = userData['userType'] ?? 'Mother';
            _selectedBloodType = userData['bloodType'] ?? 'O+';
            _allergiesController.text = userData['allergies'] ?? '';
            _conditionsController.text = userData['chronicConditions'] ?? '';
            _profilePictureUrl = userData['profilePicture'] ?? '';

            // Parse date of birth if available
            if (userData['dateOfBirth'] != null) {
              try {
                _selectedDate = DateTime.parse(userData['dateOfBirth']);
              } catch (e) {
                print('Error parsing date of birth: $e');
              }
            }

            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Edit Profile'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                children: [
                  // Profile Picture Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: _profileImageFile != null
                              ? FileImage(_profileImageFile!) as ImageProvider
                              : (_profilePictureUrl != null &&
                                      _profilePictureUrl!.isNotEmpty)
                                  ? NetworkImage(_profilePictureUrl!)
                                      as ImageProvider
                                  : null,
                          child: (_profileImageFile == null &&
                                  (_profilePictureUrl == null ||
                                      _profilePictureUrl!.isEmpty))
                              ? const Icon(Icons.person,
                                  size: 60, color: AppColors.primary)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  color: AppColors.textWhite, size: 20),
                              onPressed: () {
                                _showImageSourceDialog();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingXL),

                  // Personal Information Section
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: AppConstants.fontXL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),

                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingM),

                  // Email (read-only since it's from Firebase Auth)
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: AppConstants.paddingM),

                  // Phone Number
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingM),

                  // Date of Birth
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(fontSize: AppConstants.fontL),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),

                  // Blood Type
                  DropdownButtonFormField<String>(
                    value: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                            .contains(_selectedBloodType)
                        ? _selectedBloodType
                        : 'O+',
                    decoration: const InputDecoration(
                      labelText: 'Blood Type',
                      prefixIcon: Icon(Icons.bloodtype_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBloodType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingM),

                  // User Type
                  DropdownButtonFormField<String>(
                    value: ['Mother', 'Caregiver', 'Health Worker']
                            .contains(_selectedUserType)
                        ? _selectedUserType
                        : 'Mother',
                    decoration: const InputDecoration(
                      labelText: 'User Type',
                      prefixIcon: Icon(Icons.person_pin_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: ['Mother', 'Caregiver', 'Health Worker']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUserType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingM),

                  // Address
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingXL),

                  // Emergency Contact Section
                  const Text(
                    'Emergency Contact',
                    style: TextStyle(
                      fontSize: AppConstants.fontXL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),

                  TextFormField(
                    controller: _emergencyContactController,
                    decoration: const InputDecoration(
                      labelText: 'Emergency Contact',
                      hintText: 'Name - Phone Number',
                      prefixIcon: Icon(Icons.emergency_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter emergency contact';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingXL),

                  // Medical Information Section
                  const Text(
                    'Medical Information',
                    style: TextStyle(
                      fontSize: AppConstants.fontXL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),

                  // Allergies
                  TextFormField(
                    controller: _allergiesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Allergies',
                      hintText: 'e.g., Penicillin, Peanuts',
                      prefixIcon: Icon(Icons.warning_amber_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),

                  // Chronic Conditions
                  TextFormField(
                    controller: _conditionsController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Chronic Conditions',
                      hintText: 'e.g., Diabetes, Hypertension',
                      prefixIcon: Icon(Icons.medical_information_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  const SizedBox(height: AppConstants.paddingXL),

                  // Save Button
                  _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                          text: 'Save Changes',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _saveProfile();
                            }
                          },
                        ),
                  const SizedBox(height: AppConstants.paddingM),

                  // Change Password Button
                  OutlinedButton.icon(
                    onPressed: () {
                      _showChangePasswordDialog();
                    },
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Change Password'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: AppConstants.iconM),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: AppConstants.fontS,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: AppConstants.fontM,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Profile Picture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            if (_profilePictureUrl != null || _profileImageFile != null)
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _profileImageFile = null;
                    _profilePictureUrl = '';
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    final File? imageFile = await _storageService.pickImageFromCamera();
    if (imageFile != null) {
      setState(() {
        _profileImageFile = imageFile;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final File? imageFile = await _storageService.pickImageFromGallery();
    if (imageFile != null) {
      setState(() {
        _profileImageFile = imageFile;
      });
    }
  }

  void _showChangePasswordDialog() {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text ==
                  confirmPasswordController.text) {
                Navigator.pop(context);

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                try {
                  final result = await _authService.changePassword(
                    currentPassword: currentPasswordController.text,
                    newPassword: newPasswordController.text,
                  );

                  if (context.mounted) {
                    // Close loading indicator
                    Navigator.pop(context);

                    if (result['success']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['message']),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['message']),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    // Close loading indicator
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Error changing password. Please try again.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Upload profile picture if a new one is selected
      String? profilePictureUrl = _profilePictureUrl;
      if (_profileImageFile != null) {
        final uploadedUrl = await _storageService.uploadProfilePicture(
          userId: userId,
          imageFile: _profileImageFile!,
        );
        if (uploadedUrl != null) {
          profilePictureUrl = uploadedUrl;
        }
      }

      // Format date of birth
      final formattedDate =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

      // Update user profile in Firestore
      await _firestoreService.updateUserProfile(
        uid: userId,
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        dateOfBirth: formattedDate,
        bloodType: _selectedBloodType,
        address: _addressController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim(),
        userType: _selectedUserType,
      );

      // Update medical information
      await _firestoreService.updateMedicalInfo(
        uid: userId,
        allergies: _allergiesController.text.trim(),
        chronicConditions: _conditionsController.text.trim(),
      );

      // Update profile picture URL if changed
      if (profilePictureUrl != _profilePictureUrl) {
        await _firestoreService.updateProfilePicture(
            userId, profilePictureUrl ?? '');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
