import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../features/waste_classification/models/waste_category_model.dart';

class WasteCategoryRepository extends GetxController {
  static WasteCategoryRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection name variable
  final String _collectionName = 'wasteCategories';

  /// Fetch all waste categories from Firestore (alias for compatibility)
  Future<List<WasteCategory>> getAllCategories() async {
    return getAllWasteCategories();
  }

  /// Fetch all waste categories from Firestore
  Future<List<WasteCategory>> getAllWasteCategories() async {
    try {
      final QuerySnapshot snapshot = await _db
          .collection(_collectionName)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => WasteCategory.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Repository Error: Failed to fetch categories: $e');
      throw 'Failed to load waste categories';
    }
  }

  /// Fetch a single category by ID
  Future<WasteCategory?> getCategoryById(String id) async {
    try {
      final doc = await _db.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        return WasteCategory.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      print('Repository Error: Failed to fetch category $id: $e');
      throw 'Failed to load category';
    }
  }

  /// Fetch recyclable categories
  Future<List<WasteCategory>> getRecyclableCategories() async {
    try {
      final QuerySnapshot snapshot = await _db
          .collection(_collectionName)
          .where('isRecyclable', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => WasteCategory.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Repository Error: Failed to fetch recyclable categories: $e');
      throw 'Failed to load recyclable categories';
    }
  }

  /// Fetch non-recyclable categories
  Future<List<WasteCategory>> getNonRecyclableCategories() async {
    try {
      final QuerySnapshot snapshot = await _db
          .collection(_collectionName)
          .where('isRecyclable', isEqualTo: false)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => WasteCategory.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Repository Error: Failed to fetch non-recyclable categories: $e');
      throw 'Failed to load non-recyclable categories';
    }
  }

  /// Search categories by name or examples
  Future<List<WasteCategory>> searchCategories(String query) async {
    try {
      if (query.isEmpty) {
        return getAllWasteCategories();
      }

      final lowercaseQuery = query.toLowerCase();

      // Get all categories first, then filter locally
      final allCategories = await getAllWasteCategories();

      return allCategories.where((category) {
        // Search by name
        if (category.name.toLowerCase().contains(lowercaseQuery)) {
          return true;
        }
        // Search by examples
        if (category.examples.any((example) =>
            example.toLowerCase().contains(lowercaseQuery))) {
          return true;
        }
        return false;
      }).toList();
    } catch (e) {
      print('Repository Error: Failed to search categories: $e');
      throw 'Failed to search categories';
    }
  }
}