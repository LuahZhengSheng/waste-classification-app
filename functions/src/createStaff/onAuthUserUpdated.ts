import * as admin from 'firebase-admin';
import { beforeUserCreated, beforeUserSignedIn } from 'firebase-functions/v2/identity';

/**
 * 监听 Auth 用户更新事件，实时同步员工验证状态
 * 当员工通过密码重置完成验证时自动触发
 */
export const onStaffAuthUpdated = beforeUserSignedIn(async (event) => {
  const user = event.data;

  // 安全检查
  if (!user) {
    console.log('Missing user data in auth update event');
    return;
  }

  try {
    console.log(`Auth user signing in: ${user.email} (UID: ${user.uid})`);
    console.log(`Email verification status: ${user.emailVerified}`);

    // 检查用户是否是员工
    const userDoc = await admin.firestore().collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      console.log(`User document not found for: ${user.uid}`);
      return;
    }

    const userData = userDoc.data();

    // 只处理员工角色
    if (userData?.role !== 'center_staff') {
      return;
    }

    console.log(`Processing staff verification sync for: ${user.email}`);

    // 核心逻辑：如果邮箱验证状态为已验证但 Firestore 中未验证
    const isVerifiedInAuth = user.emailVerified;
    const isVerifiedInFirestore = userData.isVerified;

    if (isVerifiedInAuth && !isVerifiedInFirestore) {
      console.log(`🎯 Staff ${user.uid} email verified via password reset, updating Firestore...`);

      // 立即更新 Firestore 中的验证状态
      const updateData = {
        isVerified: true,
      };

      await admin.firestore().collection('users').doc(user.uid).update(updateData);

      console.log(`✅ Successfully synced verification status for staff: ${user.email}`);
      console.log(`📝 Verification log recorded for staff: ${user.email}`);

    } else {
      console.log(`ℹ️ No verification status change needed for staff: ${user.email}`);
      console.log(`   Auth=${isVerifiedInAuth}, Firestore=${isVerifiedInFirestore}`);
    }

  } catch (error) {
    console.error('❌ Error in onStaffAuthUpdated:', error);
  }
});

/**
 * 监听用户创建事件，确保新员工的初始状态正确
 */
export const onStaffAuthCreated = beforeUserCreated(async (event) => {
  const user = event.data;

  // 安全检查
  if (!user) {
    console.log('Missing user data in auth create event');
    return;
  }

  try {
    console.log(`New auth user created: ${user.email} (UID: ${user.uid})`);

    // 检查用户是否是员工
    const userDoc = await admin.firestore().collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      console.log(`User document not found for new user: ${user.uid}`);
      return;
    }

    const userData = userDoc.data();

    // 只处理员工角色
    if (userData?.role !== 'center_staff') {
      return;
    }

    console.log(`New staff auth user detected: ${user.email}`);

    // 确保 Firestore 中的 isVerified 状态与 Auth 一致
    if (user.emailVerified !== userData.isVerified) {
      await admin.firestore().collection('users').doc(user.uid).update({
        isVerified: user.emailVerified,
      });

      console.log(`✅ Synced initial verification status for new staff: ${user.email}`);
    }

  } catch (error) {
    console.error('❌ Error in onStaffAuthCreated:', error);
  }
});