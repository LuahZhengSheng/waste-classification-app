import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/validators/validation.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:fyp/utils/formatters/formatter.dart';
import 'package:fyp/features/admin/controllers/manager_management/manager_management_controller.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';

import '../../../../../data/repositories/user/manager_repository.dart';
import '../../../../community/screens/create_post/widgets/media_lightbox.dart';
import '../../../models/admin_model.dart';

class ManagerDetailDialog extends StatefulWidget {
  final AdminModel manager;
  final bool isEditMode;

  const ManagerDetailDialog({
    super.key,
    required this.manager,
    this.isEditMode = false,
  });

  @override
  State<ManagerDetailDialog> createState() => _ManagerDetailDialogState();
}

class _ManagerDetailDialogState extends State<ManagerDetailDialog> {
  late bool _isEditMode;
  late TextEditingController _usernameController;
  final _formKey = GlobalKey<FormState>();
  File? _newProfileImage;
  bool _hasChanges = false;
  final UserRepository _userRepo = UserRepository.instance;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.isEditMode;
    _usernameController = TextEditingController(text: widget.manager.username);
    _usernameController.addListener(() {
      setState(() {
        _hasChanges = _usernameController.text != widget.manager.username || _newProfileImage != null;
      });
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

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
                  _isEditMode ? 'Edit Manager' : 'Manager Details',
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
                        child: _buildProfileImage(dark),
                      ),
                      const SizedBox(height: FSizes.spaceBtwSections),

                      // Manager ID
                      _buildInfoRow('Manager ID', widget.manager.userId, dark),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Username
                      if (_isEditMode)
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
                            _buildInfoRow('Username', widget.manager.username, dark),
                            const SizedBox(height: FSizes.spaceBtwItems),
                          ],
                        ),

                      // Email
                      _buildInfoRow('Email', widget.manager.email, dark),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Phone Number
                      _buildInfoRow('Phone Number', widget.manager.phoneNo ?? 'N/A', dark),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Role
                      _buildInfoRow('Role', _formatRole(widget.manager.role), dark),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Login Attempt Count
                      _buildInfoRow(
                        'Login Attempts',
                        widget.manager.loginAttemptCount.toString(),
                        dark,
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Last Failed Login
                      _buildInfoRow(
                        'Last Failed Login',
                        widget.manager.lastFailedLogin != null
                            ? FFormatter.formatDate(widget.manager.lastFailedLogin!)
                            : 'N/A',
                        dark,
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Status badges
                      Row(
                        children: [
                          _buildStatusBadge('Verified', widget.manager.isVerified, dark),
                          const SizedBox(width: FSizes.sm),
                          _buildStatusBadge('Active', widget.manager.isActive, dark),
                          const SizedBox(width: FSizes.sm),
                          _buildStatusBadge(
                            'Banned',
                            widget.manager.isBanned,
                            dark,
                            isNegative: true,
                          ),
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

  Widget _buildProfileImage(bool dark) {
    final userRepo = UserRepository.instance;
    final cachedUrl = userRepo.getCachedProfileImageUrl(widget.manager.profileImg);

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (cachedUrl != null && cachedUrl.isNotEmpty) {
              Get.to(() => UnifiedMediaLightbox(
                mediaItems: [
                  UnifiedMediaItem.network(
                    id: widget.manager.userId,
                    networkUrl: cachedUrl,
                    isVideo: false,
                  ),
                ],
                initialIndex: 0,
              ));
            }
          },
          child: CircleAvatar(
            radius: 60,
            backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
            backgroundImage: _newProfileImage != null
                ? FileImage(_newProfileImage!)
                : (cachedUrl != null && cachedUrl.isNotEmpty
                ? NetworkImage(cachedUrl)
                : null),
            child: _newProfileImage == null && (cachedUrl == null || cachedUrl.isEmpty)
                ? const Icon(Iconsax.user, size: 40, color: Colors.white)
                : null,
          ),
        ),
        if (_isEditMode)
          Positioned(
            bottom: 0,
            right: 0,
            child: PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.camera, color: Colors.white, size: 20),
              ),
              onSelected: (value) {
                if (value == 'upload') {
                  _pickImage();
                } else if (value == 'delete') {
                  setState(() {
                    _newProfileImage = null;
                    _hasChanges = true;
                  });
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'upload',
                  child: Row(
                    children: [
                      Icon(Iconsax.gallery_add),
                      SizedBox(width: 8),
                      Text('Upload Photo'),
                    ],
                  ),
                ),
                if (widget.manager.profileImg != null && widget.manager.profileImg!.isNotEmpty)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Iconsax.trash, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Photo', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
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

  Widget _buildStatusBadge(String label, bool isActive, bool dark, {bool isNegative = false}) {
    Color backgroundColor;
    if (isNegative) {
      backgroundColor = isActive
          ? (dark ? FColors.adminDarkError : FColors.adminLightError)
          : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted);
    } else {
      backgroundColor = isActive
          ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
          : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted);
    }

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

  String _formatRole(String role) {
    switch (role) {
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _newProfileImage = File(image.path);
        _hasChanges = true;
      });
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
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        title: Text(
          'Update Manager Profile',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        content: Text(
          'Are you sure you want to update this manager profile?',
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
      if (_formKey.currentState!.validate()) {
        final repo = ManagerRepository.instance;
        final isUsernameUnique = await repo.isUsernameUnique(
          _usernameController.text,
          widget.manager.userId,
        );

        if (!isUsernameUnique) {
          FLoaders.errorSnackBar(
            title: 'Error',
            message: 'Username is already taken',
          );
          return;
        }

        final updatedManager = widget.manager.copyWith(
          username: _usernameController.text,
        );

        final controller = ManagerManagementController.instance;
        await controller.updateManager(updatedManager, _newProfileImage);
        Get.back();
      }
    }
  }
}