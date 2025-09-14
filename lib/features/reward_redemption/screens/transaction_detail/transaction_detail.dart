import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/formatters/formatter.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/reward_point_controller.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final RewardTransaction transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isDark = FHelperFunctions.isDarkMode(context);
    final isEarning = transaction.isEarning;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1A1F36), const Color(0xFF0A0E21)]
                  : [FColors.primary.withOpacity(0.1), Colors.white.withOpacity(0.8)],
            ),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.only(left: FSizes.md),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : FColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Iconsax.arrow_left_2,
              color: FColors.primary,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Transaction Summary Card
            _buildHeroTransactionCard(isDark, isEarning),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Transaction Details Card
            _buildModernTransactionDetails(isDark, isEarning),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Additional Information Cards
            if (isEarning) _buildModernEarningDetails(isDark),
            if (!isEarning) _buildModernSpendingDetails(isDark),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Modern Action Buttons
            _buildModernActionButtons(isDark, isEarning),

            const SizedBox(height: FSizes.defaultSpace),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroTransactionCard(bool isDark, bool isEarning) {
    final pointsColor = isEarning ? FColors.success : FColors.error;
    final pointsPrefix = isEarning ? '+' : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FSizes.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isEarning
              ? [
            const Color(0xFF10B981),
            const Color(0xFF059669),
            const Color(0xFF047857),
          ]
              : [
            const Color(0xFFEF4444),
            const Color(0xFFDC2626),
            const Color(0xFFB91C1C),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: pointsColor.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            left: -50,
            bottom: -50,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Column(
            children: [
              // Transaction Type Icon with Glow Effect
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Icon(
                  isEarning ? Iconsax.arrow_up_35 : Iconsax.arrow_down5,
                  color: FColors.white,
                  size: 36,
                ),
              ),

              const SizedBox(height: FSizes.lg),

              // Transaction Type Label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isEarning ? 'Points Earned' : 'Points Spent',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: FColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: FSizes.md),

              // Points Amount with Animation Effect
              Text(
                '$pointsPrefix${transaction.points}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: FColors.white,
                  letterSpacing: -2,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),

              Text(
                'Points',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: FColors.white.withOpacity(0.9),
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: FSizes.lg),

              // Status Badge with Pulse Effect
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.lg,
                  vertical: FSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: FColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: FColors.white.withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: FSizes.sm),
                    const Text(
                      'Completed',
                      style: TextStyle(
                        color: FColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernTransactionDetails(bool isDark, bool isEarning) {
    return Container(
      padding: const EdgeInsets.all(FSizes.xl),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F36).withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      FColors.primary.withOpacity(0.2),
                      FColors.primary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.document_text,
                  color: FColors.primary,
                  size: FSizes.iconSm,
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Transaction Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? FColors.white : const Color(0xFF1A202C),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),

          const SizedBox(height: FSizes.xl),

          // Details List
          _buildModernDetailItem(
            icon: Iconsax.hashtag1,
            label: 'Transaction ID',
            value: transaction.id,
            isDark: isDark,
            isFirst: true,
          ),

          _buildModernDetailItem(
            icon: Iconsax.note_text,
            label: 'Description',
            value: transaction.description,
            isDark: isDark,
          ),

          _buildModernDetailItem(
            icon: Iconsax.calendar_2,
            label: 'Date & Time',
            value: '${FFormatter.formatDate(transaction.date)} • ${_formatTime(transaction.date)}',
            isDark: isDark,
          ),

          _buildModernDetailItem(
            icon: isEarning ? Iconsax.arrow_up_35 : Iconsax.arrow_down5,
            label: 'Type',
            value: isEarning ? 'Earning' : 'Spending',
            isDark: isDark,
            valueColor: isEarning ? FColors.success : FColors.error,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildModernEarningDetails(bool isDark) {
    if (transaction.wasteType == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(FSizes.xl),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F36).withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      FColors.success.withOpacity(0.2),
                      FColors.success.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.triangle,
                  color: FColors.success,
                  size: FSizes.iconSm,
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Recycling Activity Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? FColors.white : const Color(0xFF1A202C),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),

          const SizedBox(height: FSizes.xl),

          if (transaction.relatedActivityId != null)
            _buildModernDetailItem(
              icon: Iconsax.activity,
              label: 'Activity ID',
              value: transaction.relatedActivityId!,
              isDark: isDark,
              isFirst: true,
            ),

          _buildModernDetailItem(
            icon: Iconsax.trash,
            label: 'Waste Type',
            value: transaction.wasteType!,
            isDark: isDark,
            isFirst: transaction.relatedActivityId == null,
          ),

          _buildModernDetailItem(
            icon: Iconsax.weight_1,
            label: 'Weight',
            value: '${transaction.weight?.toStringAsFixed(2)} kg',
            isDark: isDark,
          ),

          _buildModernDetailItem(
            icon: Iconsax.calculator,
            label: 'Points Calculation',
            value: '${transaction.weight?.toStringAsFixed(2)} kg × ${(transaction.points / transaction.weight!).round()} pts/kg',
            isDark: isDark,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildModernSpendingDetails(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.xl),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F36).withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      FColors.error.withOpacity(0.2),
                      FColors.error.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.gift,
                  color: FColors.error,
                  size: FSizes.iconSm,
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Redemption Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? FColors.white : const Color(0xFF1A202C),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),

          const SizedBox(height: FSizes.xl),

          if (transaction.relatedRedemptionId != null)
            _buildModernDetailItem(
              icon: Iconsax.ticket,
              label: 'Redemption ID',
              value: transaction.relatedRedemptionId!,
              isDark: isDark,
              isFirst: true,
            ),

          if (transaction.pinCode != null)
            _buildModernDetailItem(
              icon: Iconsax.security_safe,
              label: 'PIN Code',
              value: _formatPinCode(transaction.pinCode!),
              isDark: isDark,
              isMonospace: true,
              isFirst: transaction.relatedRedemptionId == null,
            ),

          _buildModernDetailItem(
            icon: Iconsax.verify,
            label: 'Status',
            value: 'Used',
            isDark: isDark,
            valueColor: FColors.success,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildModernDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
    bool isMonospace = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : FSizes.lg,
        top: isFirst ? 0 : FSizes.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  FColors.primary.withOpacity(0.15),
                  FColors.primary.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: FColors.primary,
              size: FSizes.iconSm,
            ),
          ),

          const SizedBox(width: FSizes.lg),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? FColors.white.withOpacity(0.6)
                        : const Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? (isDark ? FColors.white : const Color(0xFF1A202C)),
                    fontFamily: isMonospace ? 'Courier' : null,
                    letterSpacing: isMonospace ? 1.5 : 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionButtons(bool isDark, bool isEarning) {
    return Column(
      children: [
        // Primary Action Button
        if (!isEarning && transaction.pinCode != null)
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [FColors.primary, FColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: FColors.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _copyPinCode(),
              icon: const Icon(Iconsax.copy, color: FColors.white),
              label: const Text(
                'Copy PIN Code',
                style: TextStyle(
                  color: FColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),

        if (isEarning)
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [FColors.primary, FColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: FColors.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _viewRecyclingActivity(),
              icon: const Icon(Iconsax.eye, color: FColors.white),
              label: const Text(
                'View Activity Details',
                style: TextStyle(
                  color: FColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),

        const SizedBox(height: FSizes.md),

        // Secondary Action Button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: FColors.primary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: OutlinedButton.icon(
            onPressed: () => _shareTransaction(),
            icon: Icon(Iconsax.share, color: FColors.primary),
            label: Text(
              'Share Transaction',
              style: TextStyle(
                color: FColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatPinCode(String pinCode) {
    if (pinCode.length == 6) {
      return '${pinCode.substring(0, 3)} ${pinCode.substring(3)}';
    }
    return pinCode;
  }

  void _copyPinCode() {
    Get.snackbar(
      'Copied',
      'PIN code copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: FColors.success,
      colorText: FColors.white,
      duration: const Duration(seconds: 2),
      borderRadius: 16,
      margin: const EdgeInsets.all(FSizes.defaultSpace),
    );
  }

  void _viewRecyclingActivity() {
    Get.snackbar(
      'Info',
      'Opening activity details...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: FColors.info,
      colorText: FColors.white,
      duration: const Duration(seconds: 2),
      borderRadius: 16,
      margin: const EdgeInsets.all(FSizes.defaultSpace),
    );
  }

  void _shareTransaction() {
    Get.snackbar(
      'Share',
      'Sharing transaction details...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: FColors.primary,
      colorText: FColors.white,
      duration: const Duration(seconds: 2),
      borderRadius: 16,
      margin: const EdgeInsets.all(FSizes.defaultSpace),
    );
  }
}