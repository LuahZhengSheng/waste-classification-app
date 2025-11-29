import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fyp/features/reward_redemption/models/redemption_model.dart';
import 'package:fyp/features/reward_redemption/models/reward_model.dart';
import 'package:fyp/data/repositories/reward_redemption/redemption_repository.dart';
import 'package:fyp/data/repositories/reward_redemption/reward_repository.dart';

class MyRewardsController extends GetxController {
  final RedemptionRepository _redemptionRepo =
      RedemptionRepository.instance;
  final RewardRepository _rewardRepo = RewardRepository.instance;

  final RxBool isLoading = false.obs;
  final RxList<RedemptionModel> allRedemptions =
      <RedemptionModel>[].obs;
  final RxMap<String, RewardModel> rewardMap =
      <String, RewardModel>{}.obs;

  List<RedemptionModel> get activeRedemptions =>
      allRedemptions.where((r) => r.status == 'active').toList();

  List<RedemptionModel> get expiredRedemptions =>
      allRedemptions.where((r) => r.status == 'expired').toList();

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    isLoading.value = true;

    // 一次性获取该用户所有 redemption（所有状态）
    final stream =
    _redemptionRepo.getUserRedemptionsStream(user.uid);
    stream.listen((list) async {
      allRedemptions.assignAll(list);

      // 进入前先检查 active 的 validUntil，过期则更新为 expired
      await _updateExpiredRedemptions();

      // 获取对应 reward 数据
      await _loadRewardsForRedemptions();
      isLoading.value = false;
    });
  }

  Future<void> refreshData() async {
    await _loadData();
  }

  Future<void> _updateExpiredRedemptions() async {
    final now = DateTime.now();
    for (final r in allRedemptions) {
      if (r.status == 'active' &&
          !r.validUntil.isAfter(now)) {
        await _redemptionRepo.updateRedemptionStatus(
          r.redemptionId,
          'expired',
        );
        r.status = 'expired';
      }
    }
  }

  Future<void> _loadRewardsForRedemptions() async {
    final ids = allRedemptions.map((e) => e.rewardId).toSet();
    for (final id in ids) {
      if (!rewardMap.containsKey(id)) {
        try {
          final reward = await _rewardRepo.getRewardById(id);
          rewardMap[id] = reward;
        } catch (_) {
          // ignore missing reward
        }
      }
    }
  }

  RewardModel? getRewardById(String id) => rewardMap[id];

  bool isRedemptionNearExpiry(RedemptionModel r) {
    final now = DateTime.now();
    final diff = r.validUntil.difference(now).inDays;
    return diff <= 3 && diff >= 0;
  }

  int getDaysUntilExpiry(RedemptionModel r) {
    final now = DateTime.now();
    return r.validUntil.difference(now).inDays;
  }

  late final tabController =
  TabController(length: 2, vsync: NavigatorState());
}
