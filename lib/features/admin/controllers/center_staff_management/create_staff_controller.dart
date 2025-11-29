import 'package:get/get.dart';
import 'package:fyp/features/recycling_center/models/partner_recycling_center_model.dart';
import 'package:fyp/data/repositories/recycling_center/recycling_center_repository.dart';
import 'package:fyp/utils/popups/loaders.dart';

import 'center_staff_management_controller.dart';

class CreateStaffController extends GetxController {
  static CreateStaffController get instance => Get.find();

  // Reactive variables
  final RxList<PartnerRecyclingCenter> _allCenters = <PartnerRecyclingCenter>[].obs;
  final RxList<PartnerRecyclingCenter> _filteredCenters = <PartnerRecyclingCenter>[].obs;
  final Rx<String?> _selectedCenterId = Rx<String?>(null);
  final Rx<String?> _selectedCenterName = Rx<String?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;

  // Getters
  List<PartnerRecyclingCenter> get allCenters => _allCenters;
  List<PartnerRecyclingCenter> get filteredCenters => _filteredCenters;
  String? get selectedCenterId => _selectedCenterId.value;
  String? get selectedCenterName => _selectedCenterName.value;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;

  @override
  void onInit() {
    super.onInit();
    _loadCenters();
  }

  // Load all active centers
  Future<void> _loadCenters() async {
    try {
      _isLoading.value = true;
      final repo = Get.put(RecyclingCenterRepository());
      final centers = await repo.getAllActiveCenters();

      // Sort centers by name (A to Z)
      centers.sort((a, b) => a.name.compareTo(b.name));

      _allCenters.value = centers;
      _filteredCenters.value = centers;
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: 'Failed to load recycling centers');
    } finally {
      _isLoading.value = false;
    }
  }

  // Filter centers based on search query
  void filterCenters(String query) {
    _searchQuery.value = query;

    if (query.isEmpty) {
      _filteredCenters.value = _allCenters;
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredCenters.value = _allCenters.where((center) {
        return center.name.toLowerCase().contains(lowerQuery) ||
            center.centerId.toLowerCase().contains(lowerQuery);
      }).toList();
    }
  }

  // Select a center
  void selectCenter(PartnerRecyclingCenter center) {
    _selectedCenterId.value = center.centerId;
    _selectedCenterName.value = center.name;
  }

  // Clear selection
  void clearSelection() {
    _selectedCenterId.value = null;
    _selectedCenterName.value = null;
    _searchQuery.value = '';
    _filteredCenters.value = _allCenters;
  }

  // Create staff (no password parameter)
  Future<void> createStaff({
    required String username,
    required String email,
  }) async {
    if (selectedCenterId == null) {
      FLoaders.errorSnackBar(title: 'Error', message: 'Please select a recycling center');
      return;
    }

    try {
      final controller = StaffManagementController.instance;
      await controller.createStaff(
        centerId: selectedCenterId!,
        username: username,
        email: email,
      );
    } catch (e) {
      rethrow;
    }
  }
}