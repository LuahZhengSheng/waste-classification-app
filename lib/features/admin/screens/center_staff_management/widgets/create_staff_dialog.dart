import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/validators/validation.dart';

import '../../../../recycling_center/models/partner_recycling_center_model.dart';
import '../../../controllers/center_staff_management/create_staff_controller.dart';

class CreateStaffDialog extends StatefulWidget {
  final bool dark;
  const CreateStaffDialog({super.key, required this.dark});

  @override
  State<CreateStaffDialog> createState() => _CreateStaffDialogState();
}

class _CreateStaffDialogState extends State<CreateStaffDialog> {
  final CreateStaffController _controller = Get.put(CreateStaffController());
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _searchController = TextEditingController();

  bool _hasChanges = false;
  bool _showDropdown = false;
  final FocusNode _searchFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() => setState(() => _hasChanges = true));
    _emailController.addListener(() => setState(() => _hasChanges = true));

    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        _showDropdownOverlay();
      }
    });
  }

  void _showDropdownOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _showDropdown = true);
  }

  void _hideDropdownOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _showDropdown = false);
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox? renderBox =
    _searchFocusNode.context?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return OverlayEntry(builder: (_) => const SizedBox());
    }

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Stack(children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: _hideDropdownOverlay,
            behavior: HitTestBehavior.translucent,
          ),
        ),
        Positioned(
          left: offset.dx - 45,
          top: offset.dy + size.height + 20,
          width: size.width + 90,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
            child: Container(
              width: size.width,
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.dark
                      ? FColors.adminDarkBorder
                      : FColors.adminLightBorder,
                ),
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                color: widget.dark
                    ? FColors.adminDarkSurface
                    : FColors.adminLightSurface,
              ),
              child: Obx(() {
                if (_controller.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: widget.dark
                          ? FColors.adminDarkPrimary
                          : FColors.adminLightPrimary,
                    ),
                  );
                }

                if (_controller.filteredCenters.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.search_normal,
                          size: 48,
                          color: widget.dark
                              ? FColors.adminDarkTextSecondary
                              : FColors.adminLightTextSecondary,
                        ),
                        const SizedBox(height: FSizes.sm),
                        Text(
                          _controller.searchQuery.isEmpty
                              ? 'No recycling centers available'
                              : 'No centers found',
                          style: TextStyle(
                            color: widget.dark
                                ? FColors.adminDarkTextSecondary
                                : FColors.adminLightTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_controller.searchQuery.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: FSizes.xs),
                            child: Text(
                              'Try a different search term',
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.dark
                                    ? FColors.adminDarkTextMuted
                                    : FColors.adminLightTextMuted,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: FSizes.xs),
                  itemCount: _controller.filteredCenters.length,
                  itemBuilder: (context, index) {
                    final center = _controller.filteredCenters[index];
                    final isSelected =
                        _controller.selectedCenterId == center.centerId;
                    return _buildCenterOption(center, isSelected);
                  },
                );
              }),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildCenterOption(PartnerRecyclingCenter center, bool isSelected) {
    final searchQuery = _controller.searchQuery.toLowerCase();

    return InkWell(
      onTap: () => _selectCenter(center),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.md,
          vertical: FSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (widget.dark
              ? FColors.adminDarkPrimary
              : FColors.adminLightPrimary)
              .withOpacity(0.1)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: widget.dark
                  ? FColors.adminDarkDivider
                  : FColors.adminLightDivider,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(FSizes.sm),
              decoration: BoxDecoration(
                color: isSelected
                    ? (widget.dark
                    ? FColors.adminDarkPrimary
                    : FColors.adminLightPrimary)
                    : (widget.dark
                    ? FColors.adminDarkBorder
                    : FColors.adminLightBorder),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.building,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : (widget.dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary),
              ),
            ),
            const SizedBox(width: FSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightedText(
                    center.name,
                    searchQuery,
                    TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: widget.dark
                          ? FColors.adminDarkText
                          : FColors.adminLightText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _buildHighlightedText(
                    center.centerId,
                    searchQuery,
                    TextStyle(
                      fontSize: 11,
                      color: widget.dark
                          ? FColors.adminDarkTextSecondary
                          : FColors.adminLightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Iconsax.tick_circle,
                color: widget.dark
                    ? FColors.adminDarkPrimary
                    : FColors.adminLightPrimary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query, TextStyle baseStyle) {
    if (query.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final lowerText = text.toLowerCase();
    final matches = <TextSpan>[];
    int currentIndex = 0;

    while (currentIndex < text.length) {
      final matchIndex = lowerText.indexOf(query, currentIndex);

      if (matchIndex == -1) {
        matches.add(TextSpan(
          text: text.substring(currentIndex),
          style: baseStyle,
        ));
        break;
      }

      if (matchIndex > currentIndex) {
        matches.add(TextSpan(
          text: text.substring(currentIndex, matchIndex),
          style: baseStyle,
        ));
      }

      matches.add(TextSpan(
        text: text.substring(matchIndex, matchIndex + query.length),
        style: baseStyle.copyWith(
          backgroundColor: (widget.dark
              ? FColors.adminDarkPrimary
              : FColors.adminLightPrimary)
              .withOpacity(0.3),
          fontWeight: FontWeight.bold,
          color: widget.dark
              ? FColors.adminDarkPrimary
              : FColors.adminLightPrimary,
        ),
      ));

      currentIndex = matchIndex + query.length;
    }

    return RichText(
      text: TextSpan(children: matches),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  void _selectCenter(PartnerRecyclingCenter center) {
    _controller.selectCenter(center);
    _searchController.text = center.name;
    _hideDropdownOverlay();
    _searchFocusNode.unfocus();
    setState(() => _hasChanges = true);
  }

  void _clearSelection() {
    _controller.clearSelection();
    _searchController.clear();
    _searchFocusNode.requestFocus();
    _showDropdownOverlay();
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
        constraints: const BoxConstraints(maxHeight: 600),
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
                      'Create Staff',
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
                      // Center Selection
                      Text(
                        'Recycling Center *',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: widget.dark
                              ? FColors.adminDarkText
                              : FColors.adminLightText,
                        ),
                      ),
                      const SizedBox(height: FSizes.xs),

                      // Search Input with Overlay
                      CompositedTransformTarget(
                        link: _layerLink,
                        child: TextFormField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          readOnly: _controller.selectedCenterId != null,
                          decoration: InputDecoration(
                            hintText: 'Search by center name or ID...',
                            hintStyle: TextStyle(
                              color: widget.dark
                                  ? FColors.adminDarkTextSecondary
                                  : FColors.adminLightTextSecondary,
                            ),
                            prefixIcon: Icon(
                              Iconsax.search_normal,
                              color: widget.dark
                                  ? FColors.adminDarkTextSecondary
                                  : FColors.adminLightTextSecondary,
                            ),
                            suffixIcon: _controller.selectedCenterId != null
                                ? IconButton(
                              icon: Icon(
                                Iconsax.close_circle,
                                color: widget.dark
                                    ? FColors.adminDarkTextSecondary
                                    : FColors.adminLightTextSecondary,
                              ),
                              onPressed: _clearSelection,
                            )
                                : _showDropdown
                                ? Icon(
                              Iconsax.arrow_up_2,
                              color: widget.dark
                                  ? FColors.adminDarkTextSecondary
                                  : FColors.adminLightTextSecondary,
                            )
                                : Icon(
                              Iconsax.arrow_down_1,
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
                          onChanged: (value) {
                            _controller.filterCenters(value);
                          },
                          onTap: () {
                            if (_controller.selectedCenterId != null) {
                              _clearSelection();
                            }
                          },
                          validator: (value) {
                            if (_controller.selectedCenterId == null) {
                              return 'Please select a recycling center';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Username Field
                      Text(
                        'Username *',
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
                          ),
                        ),
                        validator: (value) =>
                            FValidator.validateEmptyText('Username', value),
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Email Field
                      Text(
                        'Email *',
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
                          ),
                        ),
                        validator: FValidator.validateEmail,
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
                                'A password reset email will be sent to the staff\'s email address. They will set their own password.',
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
                      'Create Staff',
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
          'Create Staff',
          style: TextStyle(
            color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        content: Text(
          'A password reset email will be sent to ${_emailController.text}. Are you sure you want to create this staff account?',
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
      try {
        await _controller.createStaff(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
        );
        Get.back();
      } catch (e) {
        // Error handling is done in the controller
      }
    }
  }

  @override
  void dispose() {
    _hideDropdownOverlay();
    _usernameController.dispose();
    _emailController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}