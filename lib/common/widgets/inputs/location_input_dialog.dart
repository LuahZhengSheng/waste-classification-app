import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import '../../../features/event/models/address_model.dart';
import '../../../features/event/models/geopoint_model.dart';
import '../../../features/event/models/location_model.dart';

class LocationInputDialog extends StatefulWidget {
  final bool dark;
  final Location? initialLocation;
  final Function(Location) onLocationSelected;

  const LocationInputDialog({
    super.key,
    required this.dark,
    this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  State<LocationInputDialog> createState() => _LocationInputDialogState();
}

class _LocationInputDialogState extends State<LocationInputDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _unitNoController;
  late TextEditingController _areaController;
  late TextEditingController _postcodeController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;

  bool _isLoading = false;
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    _unitNoController = TextEditingController(text: widget.initialLocation?.address.unitNo ?? '');
    _areaController = TextEditingController(text: widget.initialLocation?.address.area ?? '');
    _postcodeController = TextEditingController(text: widget.initialLocation?.address.postcode ?? '');
    _cityController = TextEditingController(text: widget.initialLocation?.address.city ?? '');
    _stateController = TextEditingController(text: widget.initialLocation?.address.state ?? '');

    // Add listeners to show map when address fields are filled
    _areaController.addListener(_checkAddressCompletion);
    _cityController.addListener(_checkAddressCompletion);
    _stateController.addListener(_checkAddressCompletion);
    _postcodeController.addListener(_checkAddressCompletion);
  }

  void _checkAddressCompletion() {
    final hasBasicAddress = _areaController.text.trim().isNotEmpty &&
        _cityController.text.trim().isNotEmpty &&
        _stateController.text.trim().isNotEmpty &&
        _postcodeController.text.trim().isNotEmpty;

    if (hasBasicAddress && !_showMap) {
      setState(() {
        _showMap = true;
      });
      _simulateMapLoad();
    } else if (!hasBasicAddress && _showMap) {
      setState(() {
        _showMap = false;
      });
    }
  }

  void _simulateMapLoad() {
    // Simulate loading for map
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _unitNoController.dispose();
    _areaController.dispose();
    _postcodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(FSizes.lg),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: widget.dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.location,
                    color: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                  ),
                  const SizedBox(width: FSizes.sm),
                  Text(
                    'Event Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Iconsax.close_circle,
                      color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(FSizes.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Google Map Preview Area
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: widget.dark
                              ? FColors.adminDarkSurfaceVariant
                              : FColors.adminLightSurfaceVariant,
                          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                          border: Border.all(
                            color: widget.dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                          ),
                        ),
                        child: _showMap
                            ? _isLoading
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                            ),
                            const SizedBox(height: FSizes.md),
                            Text(
                              'Loading map...',
                              style: TextStyle(
                                color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                              ),
                            ),
                          ],
                        )
                            : Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      (widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary).withOpacity(0.1),
                                      (widget.dark ? FColors.adminDarkSecondary : FColors.adminLightSecondary).withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Iconsax.map_1,
                                      size: 48,
                                      color: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                                    ),
                                    const SizedBox(height: FSizes.sm),
                                    Text(
                                      'Google Map Preview',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                                      ),
                                    ),
                                    Text(
                                      'Location pinned successfully',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: FSizes.sm,
                              right: FSizes.sm,
                              child: Container(
                                padding: const EdgeInsets.all(FSizes.xs),
                                decoration: BoxDecoration(
                                  color: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                                  borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                                ),
                                child: const Icon(
                                  Iconsax.location,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        )
                            : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.map,
                              size: 48,
                              color: widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                            ),
                            const SizedBox(height: FSizes.sm),
                            Text(
                              'Google Map will appear here',
                              style: TextStyle(
                                color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: FSizes.xs),
                            Text(
                              'Fill in the address fields below to see location preview',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: FSizes.spaceBtwSections),

                      // Address Form
                      Text(
                        'Address Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                        ),
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Unit Number
                      TextFormField(
                        controller: _unitNoController,
                        decoration: _inputDecoration('Unit/Building Number *', Iconsax.home_2),
                        style: _inputTextStyle(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Unit number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: FSizes.spaceBtwInputFields),

                      // Area/Street
                      TextFormField(
                        controller: _areaController,
                        decoration: _inputDecoration('Area/Street *', Iconsax.map),
                        style: _inputTextStyle(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Area/Street is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: FSizes.spaceBtwInputFields),

                      // Postcode and City Row
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _postcodeController,
                              decoration: _inputDecoration('Postcode *', Iconsax.location),
                              style: _inputTextStyle(),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Postcode is required';
                                }
                                if (value.trim().length < 5) {
                                  return 'Invalid postcode';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: FSizes.md),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _cityController,
                              decoration: _inputDecoration('City *', Iconsax.building),
                              style: _inputTextStyle(),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'City is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: FSizes.spaceBtwInputFields),

                      // State
                      DropdownButtonFormField<String>(
                        value: _stateController.text.isEmpty ? null : _stateController.text,
                        decoration: _inputDecoration('State *', Iconsax.global),
                        style: _inputTextStyle(),
                        dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                        items: _malaysianStates.map((String state) {
                          return DropdownMenuItem<String>(
                            value: state,
                            child: Text(
                              state,
                              style: _inputTextStyle(),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _stateController.text = newValue;
                            _checkAddressCompletion();
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'State is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(FSizes.lg),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: widget.dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: widget.dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                        ),
                      ),
                      child: const Text(
                        'Save Location',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveLocation() {
    if (_formKey.currentState!.validate()) {
      final address = Address(
        unitNo: _unitNoController.text.trim(),
        area: _areaController.text.trim(),
        postcode: _postcodeController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
      );

      // In real implementation, you would get the actual coordinates from Google Maps API
      final geoPoint = GeoPointModel(
        latitude: 3.1390, // Default Kuala Lumpur coordinates
        longitude: 101.6869,
      );

      final location = Location(
        address: address,
        geoPoint: geoPoint,
      );

      widget.onLocationSelected(location);
      Get.back();
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
      ),
      prefixIcon: Icon(
        icon,
        color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        borderSide: BorderSide(
          color: widget.dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        borderSide: BorderSide(
          color: widget.dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        borderSide: BorderSide(
          color: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        borderSide: BorderSide(
          color: widget.dark ? FColors.adminDarkError : FColors.adminLightError,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        borderSide: BorderSide(
          color: widget.dark ? FColors.adminDarkError : FColors.adminLightError,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: widget.dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
    );
  }

  TextStyle _inputTextStyle() {
    return TextStyle(
      color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
    );
  }

  static const List<String> _malaysianStates = [
    'Johor',
    'Kedah',
    'Kelantan',
    'Kuala Lumpur',
    'Labuan',
    'Malacca',
    'Negeri Sembilan',
    'Pahang',
    'Penang',
    'Perak',
    'Perlis',
    'Putrajaya',
    'Sabah',
    'Sarawak',
    'Selangor',
    'Terengganu',
  ];
}