import 'dart:io';
import 'package:get/get.dart';
import '../../../data/repositories/waste_classification/detection_history_repository.dart';
import '../../../utils/constants/colors.dart';
import '../models/detection_history_model.dart';
import '../../../utils/popups/loaders.dart';

class DetectionHistoryController extends GetxController {
  static DetectionHistoryController get instance => Get.find();

  final DetectionHistoryRepository _repository = Get.put(DetectionHistoryRepository());

  final RxList<DetectionHistoryModel> historyList = <DetectionHistoryModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDetectionHistory();
  }

  /// Fetch detection history
  Future<void> fetchDetectionHistory() async {
    try {
      isLoading.value = true;
      final history = await _repository.getUserDetectionHistory();
      historyList.value = history;
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Save detection history
  Future<void> saveDetectionHistory({
    required File imageFile,
    required int detectionCount,
    required List<String> detectedItems,
  }) async {
    try {
      await _repository.saveDetectionHistory(
        imageFile: imageFile,
        detectionCount: detectionCount,
        detectedItems: detectedItems,
      );

      // Refresh history list
      await fetchDetectionHistory();
    } catch (e) {
      print('❌ Controller: Failed to save history: $e');
      // Don't show error to user, just log it
    }
  }

  /// Delete detection history
  Future<void> deleteHistory(DetectionHistoryModel history) async {
    try {
      final confirmed = await FLoaders.showConfirmationDialog(
        title: 'Delete History',
        message: 'Are you sure you want to delete this detection record?',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        confirmColor: FColors.error,
      );

      if (confirmed != true) return;

      FLoaders.showLoading('Deleting...');

      await _repository.deleteDetectionHistory(
        history.historyId,
        history.imageUrl,
      );

      FLoaders.stopLoading();

      FLoaders.successSnackBar(
        title: 'Deleted',
        message: 'Detection history deleted successfully',
      );

      // Refresh history list
      await fetchDetectionHistory();
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to delete history',
      );
    }
  }

  /// Clear all history
  Future<void> clearAllHistory() async {
    try {
      if (historyList.isEmpty) {
        FLoaders.warningSnackBar(
          title: 'No History',
          message: 'There is no history to clear',
        );
        return;
      }

      final confirmed = await FLoaders.showConfirmationDialog(
        title: 'Clear All History',
        message: 'Are you sure you want to delete all detection records? This action cannot be undone.',
        confirmText: 'Clear All',
        cancelText: 'Cancel',
        confirmColor: FColors.error,
      );

      if (confirmed != true) return;

      FLoaders.showLoading('Clearing history...');

      await _repository.clearAllHistory();

      FLoaders.stopLoading();

      FLoaders.successSnackBar(
        title: 'Cleared',
        message: 'All detection history cleared successfully',
      );

      // Refresh history list
      await fetchDetectionHistory();
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to clear history',
      );
    }
  }
}