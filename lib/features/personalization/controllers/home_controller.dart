import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/features/authentication/models/user_model.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  // Repository instances
  final _userRepository = Get.put(UserRepository());
  final _authRepository = Get.put(AuthenticationRepository());

  // Observable variables for slideshow
  final RxInt currentSlideIndex = 0.obs;
  final RxList<SlideModel> slides = <SlideModel>[].obs;

  // PageController for slideshow
  late PageController pageController;
  Timer? autoSlideTimer;

  // 🆕 Observable user model
  final Rx<UserModel> user = UserModel.empty().obs;

  // Observable variables for user stats (computed from user model)
  final RxInt rewardPoints = 0.obs;
  final RxDouble kgCO2e = 0.0.obs;
  final RxDouble totalKg = 0.0.obs;
  final RxInt frequency = 0.obs;

  // Loading states
  final RxBool isLoadingStats = false.obs;
  final RxBool isLoadingSlides = false.obs;

  // 🆕 Stream subscription
  StreamSubscription<UserModel>? _userStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    loadSlides();

    // 🆕 Listen to real-time user data
    _subscribeToUserStream();

    // Start auto slideshow after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      if (slides.isNotEmpty) {
        startAutoSlideshow();
      }
    });
  }

  @override
  void onClose() {
    pageController.dispose();
    autoSlideTimer?.cancel();
    _userStreamSubscription?.cancel(); // 🆕 Cancel subscription
    super.onClose();
  }

  // 🆕 Subscribe to user data stream
  void _subscribeToUserStream() {
    try {
      final userId = _authRepository.authUser?.uid;
      if (userId == null || userId.isEmpty) {
        print('No user logged in');
        return;
      }

      isLoadingStats.value = true;

      _userStreamSubscription = _userRepository
          .getUserDetailsStream(userId)
          .listen(
            (userData) {
          user.value = userData;
          _updateStatsFromUser(userData);
          isLoadingStats.value = false;
        },
        onError: (error) {
          print('Error loading user stats: $error');
          isLoadingStats.value = false;
        },
      );
    } catch (e) {
      print('Error subscribing to user stream: $e');
      isLoadingStats.value = false;
    }
  }

  // 🆕 Update stats from user model
  void _updateStatsFromUser(UserModel userData) {
    rewardPoints.value = userData.rewardPoint;
    kgCO2e.value = userData.totalEmissionReduced;
    totalKg.value = userData.totalWeightRecycled;
    frequency.value = userData.totalRecyclingActivities;
  }

  // Load slideshow data
  void loadSlides() {
    isLoadingSlides.value = true;

    slides.value = [
      SlideModel(
        title: "Welcome\ncollectors and\nmerchants.",
        subtitle: "Join us today!",
        backgroundColor: const Color(0xFFF8E1E1), // Light pink/peach
        image: "assets/images/slides/welcome_slide.png",
      ),
      SlideModel(
        title: "Earn Points\nfor Every\nRecycle!",
        subtitle: "Start collecting today",
        backgroundColor: const Color(0xFFE1F8E1), // Light green
        image: "assets/images/slides/earn_points_slide.png",
      ),
      SlideModel(
        title: "Track Your\nEnvironmental\nImpact",
        subtitle: "Make a difference",
        backgroundColor: const Color(0xFFE1E8F8), // Light blue
        image: "assets/images/slides/track_impact_slide.png",
      ),
    ];

    isLoadingSlides.value = false;

    if (slides.isNotEmpty) {
      startAutoSlideshow();
    }
  }

  // Start auto slideshow
  void startAutoSlideshow() {
    stopAutoSlideshow();

    autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (slides.isEmpty) return;

      if (!pageController.hasClients) {
        timer.cancel();
        return;
      }

      int nextIndex = (currentSlideIndex.value + 1) % slides.length;

      pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  // Stop auto slideshow
  void stopAutoSlideshow() {
    autoSlideTimer?.cancel();
    autoSlideTimer = null;
  }

  // Handle slide change
  void onSlideChanged(int index) {
    currentSlideIndex.value = index;
    startAutoSlideshow();
  }

  // Handle user interaction
  void onSlideInteractionStart() {
    stopAutoSlideshow();
  }

  void onSlideInteractionEnd() {
    startAutoSlideshow();
  }

  // Handle redeem points
  void onRedeemPressed() {
    Get.toNamed('/redeem');
  }

  // Handle calculate emission
  void onCalculateEmissionPressed() {
    Get.toNamed('/emission-calculator');
  }

  // 🆕 Refresh user data manually
  Future<void> refreshData() async {
    try {
      final userId = _authRepository.authUser?.uid;
      if (userId == null) return;

      isLoadingStats.value = true;

      // Fetch latest user data
      final userData = await _userRepository.fetchUserDetails();
      user.value = userData;
      _updateStatsFromUser(userData);

      // Reload slides
      loadSlides();
    } catch (e) {
      print('Error refreshing data: $e');
    } finally {
      isLoadingStats.value = false;
    }
  }

  // 🆕 Get formatted stats for display
  String get formattedPoints => rewardPoints.value.toString();

  String get formattedEmission {
    if (kgCO2e.value >= 1000) {
      return '${(kgCO2e.value / 1000).toStringAsFixed(2)} tonnes';
    }
    return '${kgCO2e.value.toStringAsFixed(2)} kg';
  }

  String get formattedWeight {
    if (totalKg.value >= 1000) {
      return '${(totalKg.value / 1000).toStringAsFixed(2)} tonnes';
    }
    return '${totalKg.value.toStringAsFixed(2)} kg';
  }

  String get formattedFrequency => '${frequency.value}x';
}

// Model for slideshow data
class SlideModel {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final String image;

  SlideModel({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.image,
  });
}
