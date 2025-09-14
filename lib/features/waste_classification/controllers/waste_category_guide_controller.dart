import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../recycling_center/models/waste_category_model.dart';

class WasteCategoryController extends GetxController {
  static WasteCategoryController get instance => Get.find();

  // Observable variables
  final RxList<WasteCategory> allCategories = <WasteCategory>[].obs;
  final RxList<WasteCategory> filteredCategories = <WasteCategory>[].obs;
  final RxString searchText = ''.obs;
  final RxBool isLoading = false.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Load waste categories (mock data for now)
  void loadCategories() {
    isLoading.value = true;

    try {
      // Mock data - replace with actual API call
      final mockCategories = [
        WasteCategory(
          categoryId: '1',
          name: 'Plastic',
          description: 'Recyclable plastic items including bottles, containers, and packaging materials. Clean before disposal.',
          disposalMethod: 'Rinse clean and place in recycling bin',
          icon: Icons.recycling,
          color: Colors.blue,
          basePoints: 2.5,
          examples: ['Water bottles', 'Food containers', 'Shopping bags', 'Yogurt cups'],
          isRecyclable: true,
          createdAt: DateTime.now().subtract(Duration(days: 30)),
          updatedAt: DateTime.now(),
        ),
        WasteCategory(
          categoryId: '2',
          name: 'Paper',
          description: 'Paper and cardboard materials that can be recycled into new paper products.',
          disposalMethod: 'Keep dry and place in paper recycling bin',
          icon: Icons.description,
          color: Colors.amber,
          basePoints: 1.8,
          examples: ['Newspapers', 'Magazines', 'Cardboard boxes', 'Office paper'],
          isRecyclable: true,
          createdAt: DateTime.now().subtract(Duration(days: 25)),
          updatedAt: DateTime.now(),
        ),
        WasteCategory(
          categoryId: '3',
          name: 'Glass',
          description: 'Glass bottles and containers that can be infinitely recycled without quality loss.',
          disposalMethod: 'Remove caps and rinse before recycling',
          icon: Icons.local_bar,
          color: Colors.green,
          basePoints: 3.0,
          examples: ['Wine bottles', 'Jam jars', 'Glass containers', 'Beer bottles'],
          isRecyclable: true,
          createdAt: DateTime.now().subtract(Duration(days: 20)),
          updatedAt: DateTime.now(),
        ),
        WasteCategory(
          categoryId: '4',
          name: 'Electronic Waste',
          description: 'Electronic devices and components that require special handling due to hazardous materials.',
          disposalMethod: 'Take to certified e-waste collection center',
          icon: Icons.phone_android,
          color: Colors.purple,
          basePoints: 5.0,
          examples: ['Smartphones', 'Computers', 'Batteries', 'Cables'],
          isRecyclable: true,
          createdAt: DateTime.now().subtract(Duration(days: 15)),
          updatedAt: DateTime.now(),
        ),
        WasteCategory(
          categoryId: '5',
          name: 'Hazardous Waste',
          description: 'Dangerous materials that require special disposal to prevent environmental damage.',
          disposalMethod: 'Take to hazardous waste collection facility',
          icon: Icons.warning,
          color: Colors.red,
          basePoints: 6.0,
          examples: ['Paint', 'Chemicals', 'Motor oil', 'Pesticides'],
          isRecyclable: false,
          createdAt: DateTime.now().subtract(Duration(days: 2)),
          updatedAt: DateTime.now(),
        ),
        WasteCategory(
          categoryId: '6',
          name: 'Textile',
          description: 'Fabric and clothing items that can be donated, recycled, or repurposed.',
          disposalMethod: 'Donate or take to textile recycling center',
          icon: Icons.checkroom,
          color: Colors.pink,
          basePoints: 2.0,
          examples: ['Old clothes', 'Shoes', 'Bags', 'Linens'],
          isRecyclable: true,
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          updatedAt: DateTime.now(),
        ),
        WasteCategory(
          categoryId: '7',
          name: 'Organic Waste',
          description: 'Biodegradable waste that can be composted to create nutrient-rich soil.',
          disposalMethod: 'Compost or dispose in organic waste bin',
          icon: Icons.eco,
          color: Colors.lightGreen,
          basePoints: 1.5,
          examples: ['Food scraps', 'Garden waste', 'Leaves', 'Fruit peels'],
          isRecyclable: false,
          createdAt: DateTime.now().subtract(Duration(days: 10)),
          updatedAt: DateTime.now(),
        ),
        WasteCategory(
          categoryId: '8',
          name: 'Metal',
          description: 'Metallic items including aluminum cans, steel containers, and other metal objects.',
          disposalMethod: 'Clean and place in metal recycling bin',
          icon: Icons.hardware,
          color: Colors.grey,
          basePoints: 4.0,
          examples: ['Aluminum cans', 'Steel cans', 'Metal caps', 'Foil'],
          isRecyclable: true,
          createdAt: DateTime.now().subtract(Duration(days: 5)),
          updatedAt: DateTime.now(),
        ),
      ];

      allCategories.value = mockCategories;
      filteredCategories.value = mockCategories;
    } catch (e) {
      // Handle error
      Get.snackbar(
        'Error',
        'Failed to load waste categories',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Search categories
  void searchCategories(String query) {
    searchText.value = query;

    if (query.isEmpty) {
      filteredCategories.value = allCategories;
    } else {
      filteredCategories.value = allCategories.where((category) =>
      category.name.toLowerCase().contains(query.toLowerCase()) ||
          category.description.toLowerCase().contains(query.toLowerCase()) ||
          category.examples.any((example) =>
              example.toLowerCase().contains(query.toLowerCase()))
      ).toList();
    }
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    searchText.value = '';
    filteredCategories.value = allCategories;
  }

  /// Get categories by recyclability
  List<WasteCategory> getRecyclableCategories() {
    return allCategories.where((category) => category.isRecyclable).toList();
  }

  List<WasteCategory> getNonRecyclableCategories() {
    return allCategories.where((category) => !category.isRecyclable).toList();
  }

  /// Get category by ID
  WasteCategory? getCategoryById(String id) {
    try {
      return allCategories.firstWhere((category) => category.categoryId == id);
    } catch (e) {
      return null;
    }
  }

  /// Refresh categories
  Future<void> refreshCategories() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    loadCategories();
  }
}