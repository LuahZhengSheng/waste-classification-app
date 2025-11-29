import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../data/repositories/recycling_center/waste_category_repository.dart';
import '../models/waste_category_model.dart';

class WasteCategoryController extends GetxController {
  static WasteCategoryController get instance => Get.find();

  final WasteCategoryRepository _repository = Get.put(WasteCategoryRepository());

  // Observable variables
  final RxList<WasteCategory> allCategories = <WasteCategory>[].obs;
  final RxString searchText = ''.obs;
  final RxString selectedFilter = 'recyclable'.obs; // 'recyclable', 'not_recyclable'
  final RxBool isLoading = false.obs;

  // 将 TextEditingController 改为 late final 并正确初始化
  late final TextEditingController searchController;

  // Page controller for swipe gesture
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    // 在 onInit 中初始化控制器
    searchController = TextEditingController();
    pageController = PageController(initialPage: 0);

    // 添加搜索监听器
    searchController.addListener(_onSearchChanged);

    loadCategories();
  }

  @override
  void onClose() {
    // 先移除监听器，再 dispose
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    pageController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    searchCategories(searchController.text);
  }

  /// Load waste categories
  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      final categories = await _repository.getAllWasteCategories();
      allCategories.value = categories;
    } catch (e) {
      print('Controller Error: $e');
      FLoaders.errorSnackBar(title: 'Error', message: 'Failed to load waste categories');
    } finally {
      isLoading.value = false;
    }
  }

  /// Switch filter tab
  void switchFilter(String filter) {
    selectedFilter.value = filter;
  }

  /// Apply filters and search
  void applyFilters() {
    // 现在过滤逻辑在 UI 层处理
  }

  /// Search categories
  void searchCategories(String query) {
    searchText.value = query;
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    searchText.value = '';
  }

  /// Get categories by recyclability
  List<WasteCategory> getRecyclableCategories() {
    final query = searchText.value.toLowerCase();
    var result = allCategories.where((category) => category.isRecyclable).toList();

    // Apply search filter
    if (query.isNotEmpty) {
      result = result.where((category) {
        // Search by name
        if (category.name.toLowerCase().contains(query)) {
          return true;
        }
        // Search by examples
        if (category.examples.any((example) =>
            example.toLowerCase().contains(query))) {
          return true;
        }
        return false;
      }).toList();
    }

    return result;
  }

  List<WasteCategory> getNonRecyclableCategories() {
    final query = searchText.value.toLowerCase();
    var result = allCategories.where((category) => !category.isRecyclable).toList();

    // Apply search filter
    if (query.isNotEmpty) {
      result = result.where((category) {
        // Search by name
        if (category.name.toLowerCase().contains(query)) {
          return true;
        }
        // Search by examples
        if (category.examples.any((example) =>
            example.toLowerCase().contains(query))) {
          return true;
        }
        return false;
      }).toList();
    }

    return result;
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
    await loadCategories();
  }

  /// Check if has data for current filter
  bool get hasData {
    if (selectedFilter.value == 'recyclable') {
      return getRecyclableCategories().isNotEmpty;
    } else {
      return getNonRecyclableCategories().isNotEmpty;
    }
  }
}