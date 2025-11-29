import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/common/widgets/admin/profile_image_handler.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:fyp/utils/validators/validation.dart';
import '../../controllers/admin_layout/admin_profile_controller.dart';

class AdminProfileDialog extends StatefulWidget {
  final UserModel user;

  const AdminProfileDialog({
    super.key,
    required this.user,
  });

  @override
  State<AdminProfileDialog> createState() => _AdminProfileDialogState();
}

class _AdminProfileDialogState extends State<AdminProfileDialog> {
  late bool _isEditMode;
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();
  Uint8List? _pendingImageBytes;
  bool _pendingDeleteImage = false;
  bool _hasChanges = false;
  final UserRepository _userRepo = UserRepository.instance;

  @override
  void initState() {
    super.initState();
    _isEditMode = false;
    _usernameController = TextEditingController(text: widget.user.username);
    _phoneController = TextEditingController(text: widget.user.phoneNo ?? '');
    _usernameController.addListener(_updateHasChanges);
    _phoneController.addListener(_updateHasChanges);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);
    final isAdmin = widget.user.role == 'admin';

    return Dialog(
      backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditMode ? 'Edit Profile' : 'My Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                Row(
                  children: [
                    if (!_isEditMode)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isEditMode = true;
                          });
                        },
                        icon: Icon(
                          Iconsax.edit,
                          color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                        ),
                        tooltip: 'Edit',
                      ),
                    IconButton(
                      onPressed: () {
                        if (_isEditMode && _hasChanges) {
                          _showDiscardDialog(context, dark);
                        } else {
                          Get.back();
                        }
                      },
                      icon: Icon(
                        Iconsax.close_circle,
                        color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Divider(color: dark ? FColors.adminDarkDivider : FColors.adminLightDivider),
            const SizedBox(height: FSizes.spaceBtwItems),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image
                      Center(
                        child: ProfileImageHandler(
                          profileImg: widget.user.profileImg,
                          username: widget.user.username,
                          userId: widget.user.userId,
                          dark: dark,
                          radius: 60,
                          isEditMode: _isEditMode,
                          onImageChanged: (Uint8List? newImageBytes) {
                            setState(() {
                              _pendingImageBytes = newImageBytes;
                              if (newImageBytes != null) {
                                _pendingDeleteImage = false;
                              }
                              _updateHasChanges();
                            });
                          },
                          onDeleteRequested: (bool isDeleteRequested) {
                            setState(() {
                              _pendingDeleteImage = isDeleteRequested;
                              if (isDeleteRequested) {
                                _pendingImageBytes = null;
                              }
                              _updateHasChanges();
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: FSizes.spaceBtwSections),

                      // User ID (Read-only)
                      _buildInfoRow('User ID', widget.user.userId, dark),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Username (Editable for managers, read-only for admin)
                      if (_isEditMode && !isAdmin)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Username',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: dark ? FColors.adminDarkText : FColors.adminLightText,
                              ),
                            ),
                            const SizedBox(height: FSizes.xs),
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                hintText: 'Enter username',
                                hintStyle: TextStyle(
                                  color: dark
                                      ? FColors.adminDarkTextSecondary
                                      : FColors.adminLightTextSecondary,
                                ),
                                prefixIcon: Icon(
                                  Iconsax.user,
                                  color: dark
                                      ? FColors.adminDarkTextSecondary
                                      : FColors.adminLightTextSecondary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                                ),
                              ),
                              validator: (value) => FValidator.validateEmptyText('Username', value),
                            ),
                            const SizedBox(height: FSizes.spaceBtwItems),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildInfoRow('Username', widget.user.username, dark),
                            const SizedBox(height: FSizes.spaceBtwItems),
                          ],
                        ),

                      // Email (Read-only)
                      _buildInfoRow('Email', widget.user.email, dark),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Phone Number (Editable)
                      if (_isEditMode)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phone Number',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: dark ? FColors.adminDarkText : FColors.adminLightText,
                              ),
                            ),
                            const SizedBox(height: FSizes.xs),
                            TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                hintText: 'Enter phone number',
                                hintStyle: TextStyle(
                                  color: dark
                                      ? FColors.adminDarkTextSecondary
                                      : FColors.adminLightTextSecondary,
                                ),
                                prefixIcon: Icon(
                                  Iconsax.call,
                                  color: dark
                                      ? FColors.adminDarkTextSecondary
                                      : FColors.adminLightTextSecondary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                                ),
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  return FValidator.validatePhoneNumber(value);
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: FSizes.spaceBtwItems),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildInfoRow('Phone Number', widget.user.phoneNo ?? 'N/A', dark),
                            const SizedBox(height: FSizes.spaceBtwItems),
                          ],
                        ),

                      // Role (Read-only)
                      _buildInfoRow('Role', _getRoleDisplayName(widget.user.role), dark),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Status badges
                      Row(
                        children: [
                          _buildStatusBadge('Verified', widget.user.isVerified, dark),
                          const SizedBox(width: FSizes.sm),
                          _buildStatusBadge('Active', widget.user.isActive, dark),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            if (_isEditMode) ...[
              const SizedBox(height: FSizes.spaceBtwSections),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (_hasChanges) {
                          _showDiscardDialog(context, dark);
                        } else {
                          setState(() {
                            _isEditMode = false;
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _hasChanges ? () => _showUpdateDialog(context, dark) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                        disabledBackgroundColor: dark
                            ? FColors.adminDarkTextMuted
                            : FColors.adminLightTextMuted,
                      ),
                      child: const Text(
                        'Update Profile',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _updateHasChanges() {
    final isAdmin = widget.user.role == 'admin';
    setState(() {
      _hasChanges = (!isAdmin && _usernameController.text.trim() != widget.user.username) ||
          _phoneController.text.trim() != (widget.user.phoneNo ?? '') ||
          _pendingImageBytes != null ||
          _pendingDeleteImage;
    });
  }

  Widget _buildInfoRow(String label, String value, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        const SizedBox(height: FSizes.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(FSizes.md),
          decoration: BoxDecoration(
            color: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
            borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
            border: Border.all(
              color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String label, bool isActive, bool dark) {
    final backgroundColor = isActive
        ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
        : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Super Admin';
      case 'community_manager':
        return 'Community Manager';
      case 'event_manager':
        return 'Event Manager';
      case 'reward_manager':
        return 'Reward Manager';
      default:
        return role;
    }
  }

  void _showDiscardDialog(BuildContext context, bool dark) {
    Get.dialog(
      AlertDialog(
        backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        title: Text(
          'Discard Changes?',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        content: Text(
          'Are you sure you want to discard your changes?',
          style: TextStyle(
            color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _pendingImageBytes = null;
                _pendingDeleteImage = false;
                _hasChanges = false;
                _usernameController.text = widget.user.username;
                _phoneController.text = widget.user.phoneNo ?? '';
              });
              Get.back();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: dark ? FColors.adminDarkError : FColors.adminLightError,
            ),
            child: const Text('Discard', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, bool dark) async {
    if (_formKey.currentState!.validate()) {
      final isAdmin = widget.user.role == 'admin';

      // Check username uniqueness (only if username changed and not admin)
      if (!isAdmin && _usernameController.text.trim() != widget.user.username) {
        final isUsernameUnique = await _userRepo.isUsernameUnique(
          _usernameController.text.trim(),
          widget.user.userId,
        );

        if (!isUsernameUnique) {
          FLoaders.errorSnackBar(
            title: 'Error',
            message: 'Username is already taken',
          );
          return;
        }
      }

      // Check phone number uniqueness (if changed)
      if (_phoneController.text.trim() != (widget.user.phoneNo ?? '')) {
        final isPhoneUnique = await _userRepo.isPhoneNumberUnique(
          _phoneController.text.trim(),
          widget.user.userId,
        );

        if (!isPhoneUnique) {
          FLoaders.errorSnackBar(
            title: 'Error',
            message: 'Phone number is already in use',
          );
          return;
        }
      }

      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
          title: Text(
            'Update Profile',
            style: TextStyle(
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          content: Text(
            'Are you sure you want to update your profile?',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              ),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final controller = Get.put(AdminProfileController());

        UserModel updatedUser = widget.user.copyWith(
          username: isAdmin ? widget.user.username : _usernameController.text.trim(),
          phoneNo: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        );

        await controller.updateProfile(
          updatedUser,
          _pendingImageBytes,
          _pendingDeleteImage,
        );

        Get.back();
      }
    }
  }
}