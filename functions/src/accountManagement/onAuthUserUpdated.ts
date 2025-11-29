// src/accountManagement/onAuthUserUpdated.ts

import * as admin from 'firebase-admin';
import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';

/**
 * 当 Firestore users 文档更新时，同步到 Auth Custom Claims
 */
export const onStaffAuthUpdated = onDocumentUpdated(
  'users/{userId}',
  async (event) => {
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();
    const userId = event.params.userId;

    if (!afterData) {
      console.log('No after data, skipping');
      return;
    }

    // 只处理 staff 和 manager 角色
    const validRoles = ['center_staff', 'community_manager', 'event_manager', 'reward_manager'];
    if (!validRoles.includes(afterData.role)) {
      return;
    }

    try {
      // 检查 isVerified 是否从 false 变为 true
      const wasVerified = beforeData?.isVerified || false;
      const isNowVerified = afterData.isVerified || false;

      if (!wasVerified && isNowVerified) {
        console.log(`User ${userId} is now verified, updating custom claims`);

        // 设置 custom claims
        await admin.auth().setCustomUserClaims(userId, {
          role: afterData.role,
          isVerified: true,
          isActive: afterData.isActive || false,
          isBanned: afterData.isBanned || false,
        });

        console.log(`✅ Custom claims updated for verified user ${userId}`);
      }

      // 同步其他状态变化到 custom claims（如果用户已验证）
      if (isNowVerified) {
        const isActiveChanged = beforeData?.isActive !== afterData.isActive;
        const isBannedChanged = beforeData?.isBanned !== afterData.isBanned;

        if (isActiveChanged || isBannedChanged) {
          console.log(`Updating custom claims for user ${userId} due to status change`);

          await admin.auth().setCustomUserClaims(userId, {
            role: afterData.role,
            isVerified: true,
            isActive: afterData.isActive || false,
            isBanned: afterData.isBanned || false,
          });

          console.log(`✅ Custom claims updated for user ${userId}`);
        }
      }

    } catch (error) {
      console.error(`❌ Error updating custom claims for user ${userId}:`, error);
    }
  }
);

/**
 * 当新的 staff/manager 用户文档创建时，初始化 custom claims
 */
export const onStaffAuthCreated = onDocumentCreated(
  'users/{userId}',
  async (event) => {
    const userData = event.data?.data();
    const userId = event.params.userId;

    if (!userData) {
      console.log('No user data, skipping');
      return;
    }

    // 只处理 staff 和 manager 角色
    const validRoles = ['center_staff', 'community_manager', 'event_manager', 'reward_manager'];
    if (!validRoles.includes(userData.role)) {
      return;
    }

    try {
      console.log(`New staff/manager created: ${userId}, role: ${userData.role}`);

      // 初始化 custom claims（新账户默认未验证）
      await admin.auth().setCustomUserClaims(userId, {
        role: userData.role,
        isVerified: false, // 新账户默认未验证
        isActive: userData.isActive || true,
        isBanned: userData.isBanned || false,
      });

      console.log(`✅ Initial custom claims set for new user ${userId}`);

    } catch (error) {
      console.error(`❌ Error setting initial custom claims for user ${userId}:`, error);
    }
  }
);