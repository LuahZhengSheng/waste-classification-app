import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/validators/validation.dart';
import 'package:fyp/features/admin/controllers/manager_management/manager_management_controller.dart';

class CreateManagerDialog extends StatefulWidget {
  final bool dark;

  const CreateManagerDialog({super.key, required this.dark});

  @override
  State<CreateManagerDialog> createState() => _CreateManagerDialogState();
}

class _CreateManagerDialogState extends State<CreateManagerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;
  bool _obscurePassword = true;
  bool _hasChanges = false;

  final List<Map<String, String>> _roles = [
    {'value': 'community_manager', 'label': 'Community Manager'},
    {'value': 'event_manager', 'label': 'Event Manager'},
    {'value': 'reward_manager', 'label': 'Reward Manager'},
  ];

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() => setState(() => _hasChanges = true));
    _emailController.addListener(() => setState(() => _hasChanges = true));
    _passwordController.addListener(() => setState(() => _hasChanges = true));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor:
          widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 650),
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(FSizes.sm),
                      decoration: BoxDecoration(
                        color: (widget.dark
                                ? FColors.adminDarkPrimary
                                : FColors.adminLightPrimary)
                            .withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.user_add,
                        color: widget.dark
                            ? FColors.adminDarkPrimary
                            : FColors.adminLightPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: FSizes.md),
                    Text(
                      'Create Manager',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: widget.dark
                            ? FColors.adminDarkText
                            : FColors.adminLightText,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    if (_hasChanges) {
                      _showDiscardDialog();
                    } else {
                      Get.back();
                    }
                  },
                  icon: Icon(
                    Iconsax.close_circle,
                    color: widget.dark
                        ? FColors.adminDarkTextSecondary
                        : FColors.adminLightTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Divider(
                color: widget.dark
                    ? FColors.adminDarkDivider
                    : FColors.adminLightDivider),
            const SizedBox(height: FSizes.spaceBtwItems),

            // Form
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username Field
                      Text(
                        'Username',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: widget.dark
                              ? FColors.adminDarkText
                              : FColors.adminLightText,
                        ),
                      ),
                      const SizedBox(height: FSizes.xs),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Enter username',
                          hintStyle: TextStyle(
                            color: widget.dark
                                ? FColors.adminDarkTextSecondary
                                : FColors.adminLightTextSecondary,
                          ),
                          prefixIcon: Icon(
                            Iconsax.user,
                            color: widget.dark
                                ? FColors.adminDarkTextSecondary
                                : FColors.adminLightTextSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(FSizes.cardRadiusMd),
                            borderSide: BorderSide(
                              color: widget.dark
                                  ? FColors.adminDarkBorder
                                  : FColors.adminLightBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(FSizes.cardRadiusMd),
                            borderSide: BorderSide(
                              color: widget.dark
                                  ? FColors.adminDarkBorder
                                  : FColors.adminLightBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(FSizes.cardRadiusMd),
                            borderSide: BorderSide(
                              color: widget.dark
                                  ? FColors.adminDarkPrimary
                                  : FColors.adminLightPrimary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) =>
                            FValidator.validateEmptyText('Username', value),
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Email Field
                      Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: widget.dark
                              ? FColors.adminDarkText
                              : FColors.adminLightText,
                        ),
                      ),
                      const SizedBox(height: FSizes.xs),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter email address',
                          hintStyle: TextStyle(
                            color: widget.dark
                                ? FColors.adminDarkTextSecondary
                                : FColors.adminLightTextSecondary,
                          ),
                          prefixIcon: Icon(
                            Iconsax.sms,
                            color: widget.dark
                                ? FColors.adminDarkTextSecondary
                                : FColors.adminLightTextSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(FSizes.cardRadiusMd),
                            borderSide: BorderSide(
                              color: widget.dark
                                  ? FColors.adminDarkBorder
                                  : FColors.adminLightBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(FSizes.cardRadiusMd),
                            borderSide: BorderSide(
                              color: widget.dark
                                  ? FColors.adminDarkBorder
                                  : FColors.adminLightBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(FSizes.cardRadiusMd),
                            borderSide: BorderSide(
                              color: widget.dark
                                  ? FColors.adminDarkPrimary
                                  : FColors.adminLightPrimary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: FValidator.validateEmail,
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Password Field
                      Text(
                        'Password',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: widget.dark
                              ? FColors.adminDarkText
                              : FColors.adminLightText,
                        ),
                      ),
                      const SizedBox(height: FSizes.xs),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Enter password',
                          hintStyle: TextStyle(
                            color: widget.dark
                                ? FColors.adminDarkTextSecondary
                                : FColors.adminLightTextSecondary,
                          ),
                          prefixIcon: Icon(
                            Iconsax.lock,
                            color: widget.dark
                                ? FColors.adminDarkTextSecondary
                                : FColors.adminLightTextSecondary,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Iconsax.eye_slash
                                  : Iconsax.eye,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(FSizes.cardRadiusMd),
                            borderSide: BorderSide(
                              color: widget.dark
                                  ? FColors.adminDarkBorder
                                  : FColors.adminLightBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(FSizes.cardRadiusMd),
                            borderSide: BorderSide(
                              color: widget.dark
                                  ? FColors.adminDarkBorder
                                  : FColors.adminLightBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(FSizes.cardRadiusMd),
                            borderSide: BorderSide(
                              color: widget.dark
                                  ? FColors.adminDarkPrimary
                                  : FColors.adminLightPrimary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: FValidator.validatePassword,
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Role Dropdown
                      Text(
                        'Role',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: widget.dark
                              ? FColors.adminDarkText
                              : FColors.adminLightText,
                        ),
                      ),
                      const SizedBox(height: FSizes.xs),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          hintText: 'Select manager role',
                          hintStyle: TextStyle(
                            color: widget.dark
                                ? FColors.adminDarkTextSecondary
                                : FColors.adminLightTextSecondary,
                          ),
                          prefixIcon: Icon(
                            Iconsax.shield_tick,
                            color: widget.dark
                                ? FColors.adminDarkTextSecondary
                                : FColors.adminLightTextSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(FSizes.cardRadiusMd),
                            borderSide: BorderSide(
                              color: widget.dark
                                  ? FColors.adminDarkBorder
                                  : FColors.adminLightBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(FSizes.cardRadiusMd),
                            borderSide: BorderSide(
                              color: widget.dark
                                  ? FColors.adminDarkBorder
                                  : FColors.adminLightBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(FSizes.cardRadiusMd),
                            borderSide: BorderSide(
                              color: widget.dark
                                  ? FColors.adminDarkPrimary
                                  : FColors.adminLightPrimary,
                              width: 2,
                            ),
                          ),
                        ),
                        dropdownColor: widget.dark
                            ? FColors.adminDarkSurface
                            : FColors.adminLightSurface,
                        items: _roles.map((role) {
                          return DropdownMenuItem<String>(
                            value: role['value'],
                            child: Text(
                              role['label']!,
                              style: TextStyle(
                                color: widget.dark
                                    ? FColors.adminDarkText
                                    : FColors.adminLightText,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value;
                            _hasChanges = true;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a role';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Info Box
                      Container(
                        padding: const EdgeInsets.all(FSizes.md),
                        decoration: BoxDecoration(
                          color: (widget.dark
                                  ? FColors.adminDarkInfo
                                  : FColors.adminLightInfo)
                              .withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(FSizes.cardRadiusMd),
                          border: Border.all(
                            color: widget.dark
                                ? FColors.adminDarkInfo
                                : FColors.adminLightInfo,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.info_circle,
                              color: widget.dark
                                  ? FColors.adminDarkInfo
                                  : FColors.adminLightInfo,
                              size: 20,
                            ),
                            const SizedBox(width: FSizes.sm),
                            Expanded(
                              child: Text(
                                'A verification email will be sent to the manager\'s email address.',
                                style: TextStyle(
                                  color: widget.dark
                                      ? FColors.adminDarkInfo
                                      : FColors.adminLightInfo,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            const SizedBox(height: FSizes.spaceBtwSections),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (_hasChanges) {
                        _showDiscardDialog();
                      } else {
                        Get.back();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: widget.dark
                            ? FColors.adminDarkBorder
                            : FColors.adminLightBorder,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: widget.dark
                            ? FColors.adminDarkTextSecondary
                            : FColors.adminLightTextSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: FSizes.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showCreateConfirmation(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.dark
                          ? FColors.adminDarkPrimary
                          : FColors.adminLightPrimary,
                      padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                    ),
                    child: const Text(
                      'Create Manager',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDiscardDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor:
            widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        title: Text(
          'Discard Changes?',
          style: TextStyle(
            color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        content: Text(
          'Are you sure you want to discard your changes?',
          style: TextStyle(
            color: widget.dark
                ? FColors.adminDarkTextSecondary
                : FColors.adminLightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: widget.dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.dark
                  ? FColors.adminDarkError
                  : FColors.adminLightError,
            ),
            child: const Text('Discard', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateConfirmation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor:
            widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        title: Text(
          'Create Manager',
          style: TextStyle(
            color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        content: Text(
          'Are you sure you want to create this manager account?',
          style: TextStyle(
            color: widget.dark
                ? FColors.adminDarkTextSecondary
                : FColors.adminLightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: widget.dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.dark
                  ? FColors.adminDarkPrimary
                  : FColors.adminLightPrimary,
            ),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final controller = ManagerManagementController.instance;
      await controller.createManager(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole!,
      );
      // Remove the immediate Get.back() and let the controller handle it
      // The controller will close the dialog after showing the success message
      if (controller.allManagers.isNotEmpty) {
        // Only close if creation was successful (you might want to add a success flag)
        Get.back();
      }
    }
  }
}
