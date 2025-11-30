// src/rewardSystem/expireRewardsAndRedemptions.ts

import * as functions from "firebase-functions/v2";
import * as admin from "firebase-admin";

/**
 * Cloud Function to automatically expire rewards and redemptions
 * Runs every hour at the top of the hour (e.g., 1:00, 2:00, 3:00...)
 * Timezone: Asia/Kuala_Lumpur
 */
export const expireRewardsAndRedemptions = functions.scheduler.onSchedule(
  {
    schedule: "0 * * * *", // Every hour at minute 0
    timeZone: "Asia/Kuala_Lumpur",
    memory: "256MiB",
    timeoutSeconds: 540, // 9 minutes
  },
  async (event) => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();

    console.log("Starting expiration check at:", now.toDate());

    try {
      // ==================== Process Rewards ====================
      console.log("Processing rewards...");

      const rewardsSnapshot = await db
        .collection("rewards")
        .where("status", "==", "active")
        .get();

      let expiredRewardsCount = 0;
      const rewardBatch = db.batch();

      for (const doc of rewardsSnapshot.docs) {
        const data = doc.data();
        const validUntil = data.validUntil as admin.firestore.Timestamp;
        const quantity = data.quantity as number;
        const redemptionCount = data.redemptionCount as number || 0;
        const remainingQuantity = quantity - redemptionCount;

        // Check if reward should be expired
        const shouldExpire =
          validUntil.toDate() <= now.toDate() || remainingQuantity <= 0;

        if (shouldExpire) {
          rewardBatch.update(doc.ref, {
            status: "inactive",
          });
          expiredRewardsCount++;
          console.log(
            `Expiring reward ${doc.id}: validUntil=${validUntil.toDate()}, remainingQty=${remainingQuantity}`
          );
        }
      }

      // Commit reward updates
      if (expiredRewardsCount > 0) {
        await rewardBatch.commit();
        console.log(`✅ Expired ${expiredRewardsCount} rewards`);
      } else {
        console.log("No rewards to expire");
      }

      // ==================== Process Redemptions ====================
      console.log("Processing redemptions...");

      const redemptionsSnapshot = await db
        .collection("redemptions")
        .where("status", "==", "active")
        .get();

      let expiredRedemptionsCount = 0;

      // Process in batches of 500 (Firestore batch limit)
      const batchSize = 500;
      let currentBatch = db.batch();
      let operationsInBatch = 0;

      for (const doc of redemptionsSnapshot.docs) {
        const data = doc.data();
        const validUntil = data.validUntil as admin.firestore.Timestamp;

        // Check if redemption has expired
        if (validUntil.toDate() <= now.toDate()) {
          currentBatch.update(doc.ref, {
            status: "expired",
          });
          operationsInBatch++;
          expiredRedemptionsCount++;

          console.log(
            `Expiring redemption ${doc.id}: validUntil=${validUntil.toDate()}`
          );

          // Commit batch if it reaches the limit
          if (operationsInBatch >= batchSize) {
            await currentBatch.commit();
            currentBatch = db.batch();
            operationsInBatch = 0;
          }
        }
      }

      // Commit remaining operations
      if (operationsInBatch > 0) {
        await currentBatch.commit();
      }

      if (expiredRedemptionsCount > 0) {
        console.log(`✅ Expired ${expiredRedemptionsCount} redemptions`);
      } else {
        console.log("No redemptions to expire");
      }

      // ==================== Summary ====================
      console.log("==================== Summary ====================");
      console.log(`Total rewards expired: ${expiredRewardsCount}`);
      console.log(`Total redemptions expired: ${expiredRedemptionsCount}`);
      console.log("================================================");

      // Don't return anything - scheduled functions should return void
    } catch (error) {
      console.error("❌ Error in expireRewardsAndRedemptions:", error);
      throw error;
    }
  }
);
