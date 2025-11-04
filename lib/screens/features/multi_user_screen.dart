import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../models/family_member_model.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_storage_service.dart';

class MultiUserScreen extends StatefulWidget {
  const MultiUserScreen({super.key});

  @override
  State<MultiUserScreen> createState() => _MultiUserScreenState();
}

class _MultiUserScreenState extends State<MultiUserScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();

  bool _isLoading = false;
  String? _editingMemberId;
  File? _selectedImageFile;

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = _authService.currentUserId;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Manage Users'),
      body: currentUserId == null
          ? const Center(child: Text('Please log in to manage users'))
          : StreamBuilder<DocumentSnapshot>(
              stream: _firestoreService.getUserStream(currentUserId),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const Center(child: Text('User data not found'));
                }

                Map<String, dynamic> userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                String userName = userData['fullName'] ?? 'User';

                return StreamBuilder<QuerySnapshot>(
                  stream: _firestoreService.getFamilyMembers(currentUserId),
                  builder: (context, familySnapshot) {
                    if (familySnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const LoadingIndicator();
                    }

                    List<FamilyMember> familyMembers = [];

                    // Add primary user as first member
                    FamilyMember primaryUser = FamilyMember(
                      id: currentUserId,
                      userId: currentUserId,
                      name: userName,
                      relationship: 'Primary Account',
                      info: 'Account Holder',
                      profilePicture: userData['profilePicture'],
                      isPrimary: true,
                      createdAt:
                          (userData['createdAt'] as Timestamp?)?.toDate() ??
                              DateTime.now(),
                      updatedAt:
                          (userData['updatedAt'] as Timestamp?)?.toDate() ??
                              DateTime.now(),
                    );
                    familyMembers.add(primaryUser);

                    // Add family members from Firestore
                    if (familySnapshot.hasData) {
                      for (var doc in familySnapshot.data!.docs) {
                        familyMembers.add(FamilyMember.fromFirestore(
                          doc.data() as Map<String, dynamic>,
                          doc.id,
                        ));
                      }
                    }

                    return ListView(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      children: [
                        CustomCard(
                          gradient: AppColors.secondaryGradient,
                          child: const Column(
                            children: [
                              Icon(Icons.family_restroom,
                                  size: AppConstants.iconXXL,
                                  color: AppColors.textWhite),
                              SizedBox(height: AppConstants.paddingM),
                              Text(
                                'Family Care Management',
                                style: TextStyle(
                                    fontSize: AppConstants.fontXL,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textWhite),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: AppConstants.paddingS),
                              Text(
                                'Manage medications for your family members',
                                style: TextStyle(
                                    fontSize: AppConstants.fontM,
                                    color: AppColors.textWhite),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingL),
                        ...familyMembers
                            .map((member) => _buildUserCard(member)),
                        const SizedBox(height: AppConstants.paddingM),
                        OutlinedButton.icon(
                          onPressed: _showAddFamilyMemberDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Family Member'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildUserCard(FamilyMember member) {
    IconData icon;
    Color color;

    // Determine icon and color based on relationship
    switch (member.relationship.toLowerCase()) {
      case 'mother':
      case 'mom':
        icon = Icons.person;
        color = AppColors.primary;
        break;
      case 'child':
      case 'son':
      case 'daughter':
        icon = Icons.child_care;
        color = AppColors.info;
        break;
      case 'father':
      case 'dad':
        icon = Icons.person;
        color = AppColors.primary;
        break;
      case 'grandmother':
      case 'grandma':
      case 'lola':
        icon = Icons.elderly;
        color = AppColors.secondary;
        break;
      case 'grandfather':
      case 'grandpa':
      case 'lolo':
        icon = Icons.elderly;
        color = AppColors.secondary;
        break;
      default:
        icon = Icons.person;
        color = AppColors.primary;
    }

    return Builder(
      builder: (context) => CustomCard(
        margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
        onTap: () {
          _showFamilyMemberDetails(member);
        },
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: color.withOpacity(0.1),
                  backgroundImage: (member.profilePicture != null &&
                          member.profilePicture!.isNotEmpty)
                      ? NetworkImage(member.profilePicture!) as ImageProvider
                      : null,
                  child: (member.profilePicture == null ||
                          member.profilePicture!.isEmpty)
                      ? Icon(icon, color: color, size: AppConstants.iconL)
                      : null,
                ),
                if (!member.isPrimary)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        _showImageSourceDialog(member);
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: AppColors.textWhite,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(member.name,
                          style: const TextStyle(
                              fontSize: AppConstants.fontL,
                              fontWeight: FontWeight.w600)),
                      if (member.isPrimary) ...[
                        const SizedBox(width: AppConstants.paddingS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.paddingS, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusS),
                          ),
                          child: const Text('Primary',
                              style: TextStyle(
                                  fontSize: AppConstants.fontXS,
                                  color: AppColors.primary)),
                        ),
                      ],
                      if (!member.isPrimary) ...[
                        const Spacer(),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditFamilyMemberDialog(member);
                            } else if (value == 'delete') {
                              _showDeleteConfirmationDialog(member);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 16),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      size: 16, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingXS),
                  Text(member.relationship,
                      style: const TextStyle(
                          fontSize: AppConstants.fontM,
                          color: AppColors.textSecondary)),
                  Text(member.info,
                      style: const TextStyle(
                          fontSize: AppConstants.fontS,
                          color: AppColors.textLight)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: AppConstants.iconS),
          ],
        ),
      ),
    );
  }

  void _showFamilyMemberDetails(FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.paddingL),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusM),
                    topRight: Radius.circular(AppConstants.radiusM),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.textWhite,
                      backgroundImage: (member.profilePicture != null &&
                              member.profilePicture!.isNotEmpty)
                          ? NetworkImage(member.profilePicture!) as ImageProvider
                          : null,
                      child: (member.profilePicture == null ||
                              member.profilePicture!.isEmpty)
                          ? Icon(Icons.person, size: 50, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontSize: AppConstants.fontXL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingS),
                    Text(
                      member.relationship,
                      style: const TextStyle(
                        fontSize: AppConstants.fontM,
                        color: AppColors.textWhite,
                      ),
                    ),
                    if (member.isPrimary) ...[
                      const SizedBox(height: AppConstants.paddingS),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingM,
                          vertical: AppConstants.paddingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textWhite.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        ),
                        child: const Text(
                          'Primary Account',
                          style: TextStyle(
                            fontSize: AppConstants.fontS,
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: AppConstants.fontL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    Text(
                      member.info,
                      style: const TextStyle(
                        fontSize: AppConstants.fontM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingL),
                    if (!member.isPrimary) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showEditFamilyMemberDialog(member);
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingM),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showDeleteConfirmationDialog(member);
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text('Delete'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(FamilyMember member) {
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
                _pickImageFromCamera(member);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery(member);
              },
            ),
            if (member.profilePicture != null && member.profilePicture!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePicture(member);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera(FamilyMember member) async {
    final File? imageFile = await _storageService.pickImageFromCamera();
    if (imageFile != null) {
      await _uploadProfilePicture(member, imageFile);
    }
  }

  Future<void> _pickImageFromGallery(FamilyMember member) async {
    final File? imageFile = await _storageService.pickImageFromGallery();
    if (imageFile != null) {
      await _uploadProfilePicture(member, imageFile);
    }
  }

  Future<void> _uploadProfilePicture(FamilyMember member, File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final uploadedUrl = await _storageService.uploadProfilePicture(
        userId: member.id,
        imageFile: imageFile,
      );

      if (uploadedUrl != null) {
        await _firestoreService.updateFamilyMemberProfilePicture(
          memberId: member.id,
          profilePictureUrl: uploadedUrl,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile picture: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeProfilePicture(FamilyMember member) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestoreService.updateFamilyMemberProfilePicture(
        memberId: member.id,
        profilePictureUrl: '',
      );

      // Also delete from storage
      await _storageService.deleteProfilePicture(member.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture removed successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing profile picture: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddFamilyMemberDialog() {
    _clearControllers();
    _editingMemberId = null;
    _selectedImageFile = null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Family Member'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: _selectedImageFile != null
                            ? FileImage(_selectedImageFile!) as ImageProvider
                            : null,
                        child: _selectedImageFile == null
                            ? const Icon(Icons.person,
                                size: 40, color: AppColors.primary)
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
                                color: AppColors.textWhite, size: 16),
                            onPressed: () {
                              _showAddMemberImageSourceDialog(setState);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter family member name',
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),
                TextField(
                  controller: _relationshipController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship',
                    hintText: 'e.g., Mother, Child, Grandmother',
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),
                TextField(
                  controller: _infoController,
                  decoration: const InputDecoration(
                    labelText: 'Additional Info',
                    hintText: 'e.g., Age, Medical conditions',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _addFamilyMember,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddMemberImageSourceDialog(StateSetter setState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Profile Picture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final File? imageFile = await _storageService.pickImageFromCamera();
                if (imageFile != null) {
                  setState(() {
                    _selectedImageFile = imageFile;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final File? imageFile = await _storageService.pickImageFromGallery();
                if (imageFile != null) {
                  setState(() {
                    _selectedImageFile = imageFile;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditFamilyMemberDialog(FamilyMember member) {
    _nameController.text = member.name;
    _relationshipController.text = member.relationship;
    _infoController.text = member.info;
    _editingMemberId = member.id;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Family Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter family member name',
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              TextField(
                controller: _relationshipController,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  hintText: 'e.g., Mother, Child, Grandmother',
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              TextField(
                controller: _infoController,
                decoration: const InputDecoration(
                  labelText: 'Additional Info',
                  hintText: 'e.g., Age, Medical conditions',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _updateFamilyMember,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Family Member'),
        content: Text(
            'Are you sure you want to remove ${member.name} from your family?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.of(context).pop();
                    _deleteFamilyMember(member.id);
                  },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _clearControllers() {
    _nameController.clear();
    _relationshipController.clear();
    _infoController.clear();
  }

  Future<void> _addFamilyMember() async {
    if (_nameController.text.trim().isEmpty ||
        _relationshipController.text.trim().isEmpty ||
        _infoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      // Add family member first to get the member ID
      String memberId = await _firestoreService.addFamilyMember(
        userId: currentUserId,
        name: _nameController.text.trim(),
        relationship: _relationshipController.text.trim(),
        info: _infoController.text.trim(),
      );

      // Upload profile picture if selected
      if (_selectedImageFile != null) {
        final uploadedUrl = await _storageService.uploadProfilePicture(
          userId: memberId,
          imageFile: _selectedImageFile!,
        );
        
        if (uploadedUrl != null) {
          await _firestoreService.updateFamilyMemberProfilePicture(
            memberId: memberId,
            profilePictureUrl: uploadedUrl,
          );
        }
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Family member added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateFamilyMember() async {
    if (_nameController.text.trim().isEmpty ||
        _relationshipController.text.trim().isEmpty ||
        _infoController.text.trim().isEmpty ||
        _editingMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestoreService.updateFamilyMember(
        memberId: _editingMemberId!,
        name: _nameController.text.trim(),
        relationship: _relationshipController.text.trim(),
        info: _infoController.text.trim(),
      );

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Family member updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteFamilyMember(String memberId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestoreService.deleteFamilyMember(memberId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Family member removed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
