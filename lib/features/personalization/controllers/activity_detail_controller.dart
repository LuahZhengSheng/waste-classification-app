import 'package:fyp/features/personalization/models/recycle_activity_model.dart';
import 'package:fyp/features/recycling_center/models/partner_recycling_center.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/utils/device/device_utility.dart';
import 'package:share_plus/share_plus.dart';

class ActivityDetailController extends GetxController {
  static ActivityDetailController get instance => Get.find();

  // Observable variables
  final Rx<RecyclingActivity> activity = RecyclingActivity.empty().obs;
  final Rx<PartnerRecyclingCenter> recyclingCenter = PartnerRecyclingCenter.empty().obs;
  final RxBool isLoading = false.obs;
  final RxBool isCenterLoading = false.obs;
  final RxString selectedImageUrl = ''.obs;

  // Firebase instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    // Get activity from arguments
    final RecyclingActivity activityArg = Get.arguments as RecyclingActivity;
    activity.value = activityArg;
    selectedImageUrl.value = activityArg.supportImage;

    // Fetch recycling center details
    fetchRecyclingCenter();
  }

  /// Fetch recycling center details
  Future<void> fetchRecyclingCenter() async {
    try {
      isCenterLoading.value = true;

      final doc = await _db
          .collection('PartnerRecyclingCenters')
          .doc(activity.value.centerId)
          .get();

      if (doc.exists) {
        recyclingCenter.value = PartnerRecyclingCenter.fromSnapshot(doc);
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load recycling center details: ${e.toString()}',
      );
    } finally {
      isCenterLoading.value = false;
    }
  }

  /// Refresh activity data
  Future<void> refreshActivity() async {
    try {
      isLoading.value = true;

      final doc = await _db
          .collection('RecyclingActivities')
          .doc(activity.value.activityId)
          .get();

      if (doc.exists) {
        activity.value = RecyclingActivity.fromSnapshot(doc);
        FLoaders.successSnackBar(
          title: 'Updated',
          message: 'Activity details have been refreshed',
        );
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to refresh activity: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete the current activity
  Future<void> deleteActivity() async {
    try {
      if (!activity.value.canDelete) {
        FLoaders.warningSnackBar(
          title: 'Cannot Delete',
          message: 'Only pending or rejected activities can be deleted',
        );
        return;
      }

      isLoading.value = true;

      await _db.collection('RecyclingActivities').doc(activity.value.activityId).delete();

      FLoaders.successSnackBar(
        title: 'Deleted',
        message: 'Activity has been deleted successfully',
      );

      // Navigate back to history screen
      Get.back();
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to delete activity: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Share activity details
  void shareActivity() {
    final text = '''
🌱 Recycling Activity Details 🌱

Waste Type: ${activity.value.wasteObject}
Weight: ${activity.value.formattedWeight}
Points Earned: ${activity.value.pointsEarned} pts
Status: ${activity.value.statusDisplayText}
Date: ${activity.value.formattedCreatedAt}

${recyclingCenter.value.name.isNotEmpty ? 'Recycling Center: ${recyclingCenter.value.name}' : ''}

#RecycleRight #SaveEarth #GoGreen
    ''';

    Share.share(text, subject: 'My Recycling Activity');
  }

  /// Contact recycling center
  void contactCenter() {
    if (recyclingCenter.value.phoneNo.isNotEmpty) {
      FDeviceUtils.launchUrl('tel:${recyclingCenter.value.phoneNo}');
    } else {
      FLoaders.warningSnackBar(
        title: 'No Contact',
        message: 'Phone number not available for this center',
      );
    }
  }

  /// Visit center website
  void visitCenterWebsite() {
    if (recyclingCenter.value.website.isNotEmpty) {
      FDeviceUtils.launchUrl(recyclingCenter.value.website);
    } else {
      FLoaders.warningSnackBar(
        title: 'No Website',
        message: 'Website not available for this center',
      );
    }
  }

  /// Send email to center
  void emailCenter() {
    if (recyclingCenter.value.email.isNotEmpty) {
      final subject = 'Inquiry about Recycling Activity ${activity.value.activityId}';
      final body = 'Hello,\n\nI have a question about my recycling activity:\n\nActivity ID: ${activity.value.activityId}\nWaste Type: ${activity.value.wasteObject}\nDate: ${activity.value.formattedCreatedAt}\n\nThank you.';
      FDeviceUtils.launchUrl('mailto:${recyclingCenter.value.email}?subject=$subject&body=$body');
    } else {
      FLoaders.warningSnackBar(
        title: 'No Email',
        message: 'Email not available for this center',
      );
    }
  }

  /// Get status message for user
  String get statusMessage {
    switch (activity.value.status.toLowerCase()) {
      case 'pending':
        return 'Your recycling activity is being reviewed by the center. You\'ll be notified once it\'s processed.';
      case 'approved':
        return 'Great! Your recycling activity has been approved. Points will be added to your account.';
      case 'rejected':
        return 'Unfortunately, your activity was rejected. Please contact the center for more details.';
      case 'completed':
        return 'Congratulations! Your recycling activity is complete and points have been added to your account.';
      default:
        return 'Status unknown. Please contact support if this persists.';
    }
  }

  /// Get next steps message
  String get nextStepsMessage {
    switch (activity.value.status.toLowerCase()) {
      case 'pending':
        return 'Please wait for center review. Estimated processing time: 1-2 business days.';
      case 'approved':
        return 'Your points will be credited within 24 hours.';
      case 'rejected':
        return 'You can delete this activity or contact the center for clarification.';
      case 'completed':
        return 'Keep up the great work! Start your next recycling activity.';
      default:
        return 'Contact support for assistance.';
    }
  }

  /// Check if activity is recent (within 24 hours)
  bool get isRecentActivity {
    return activity.value.isRecent;
  }

  /// Get activity age text
  String get activityAge {
    final hours = activity.value.ageInHours;
    if (hours < 1) {
      return 'Just now';
    } else if (hours < 24) {
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    } else {
      final days = (hours / 24).floor();
      return '$days day${days == 1 ? '' : 's'} ago';
    }
  }

  /// Open image in full screen
  void openFullScreenImage() {
    if (activity.value.supportImage.isNotEmpty) {
      Get.toNamed('/full-screen-image', arguments: {
        'imageUrl': activity.value.supportImage,
        'title': '${activity.value.wasteObject} - Support Image',
      });
    }
  }

  /// Copy activity ID to clipboard
  void copyActivityId() {
    if (activity.value.activityId.isNotEmpty) {
      // Copy to clipboard logic here
      FLoaders.customToast(message: 'Activity ID copied to clipboard');
    }
  }

  /// Navigate to edit activity (if allowed)
  void editActivity() {
    if (activity.value.canEdit) {
      Get.toNamed('/edit-recycling-activity', arguments: activity.value);
    } else {
      FLoaders.warningSnackBar(
        title: 'Cannot Edit',
        message: 'Only pending activities can be edited',
      );
    }
  }

  /// Get environment impact message
  String get environmentImpact {
    final weight = activity.value.weight;
    switch (activity.value.wasteObject.toLowerCase()) {
      case 'plastic':
        final bottles = (weight * 20).round(); // Approx 50g per bottle
        return 'Equivalent to recycling ~$bottles plastic bottles';
      case 'paper':
        final sheets = (weight * 200).round(); // Approx 5g per sheet
        return 'Equivalent to recycling ~$sheets sheets of paper';
      case 'glass':
        final bottles = (weight * 2).round(); // Approx 500g per bottle
        return 'Equivalent to recycling ~$bottles glass bottles';
      case 'metal':
        final cans = (weight * 67).round(); // Approx 15g per can
        return 'Equivalent to recycling ~$cans aluminum cans';
      case 'electronics':
        return 'Helped prevent toxic materials from entering landfills';
      default:
        return 'Made a positive environmental impact!';
    }
  }

  /// Calculate CO2 saved (rough estimate)
  double get co2Saved {
    final weight = activity.value.weight;
    switch (activity.value.wasteObject.toLowerCase()) {
      case 'plastic':
        return weight * 2.0; // 2kg CO2 per kg plastic
      case 'paper':
        return weight * 1.5; // 1.5kg CO2 per kg paper
      case 'glass':
        return weight * 0.3; // 0.3kg CO2 per kg glass
      case 'metal':
        return weight * 4.0; // 4kg CO2 per kg metal
      case 'electronics':
        return weight * 3.0; // 3kg CO2 per kg electronics
      default:
        return weight * 1.0;
    }
  }
}