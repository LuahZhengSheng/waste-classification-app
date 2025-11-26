import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { getAuth } from 'firebase-admin/auth';
import { sendEmail, SystemEmailTemplates } from './accountEmailService';

// 定义数据类型
interface UserData {
  uid: string;
  role: string;
  username: string;
  email: string;
  phoneNo?: string;
  isBanned: boolean;
  isActive: boolean;
}

// 辅助函数：检查是否是系统角色
function isSystemRole(role: string): boolean {
  return ['community_manager', 'event_manager', 'reward_manager', 'center_staff', 'user'].includes(role);
}

// 辅助函数：获取变化的字段
function getChangedFields(beforeData: UserData, afterData: UserData): string[] {
  const changes: string[] = [];
  const fieldsToCheck = ['username', 'profileImg', 'role'];

  fieldsToCheck.forEach(field => {
    const beforeValue = (beforeData as any)[field];
    const afterValue = (afterData as any)[field];

    if (beforeValue !== afterValue) {
      const oldValue = beforeValue ?? 'Not set';
      const newValue = afterValue ?? 'Not set';
      changes.push(`- ${field}: ${oldValue} → ${newValue}`);
    }
  });

  return changes;
}

// 处理用户封禁
async function handleUserBanned(userData: UserData) {
  console.log(`🔨 User banned: ${userData.username}`);

  try {
    // 设置自定义声明，标记用户被封禁
    await getAuth().setCustomUserClaims(userData.uid, {
      banned: true,
      bannedAt: Date.now()
    });

    // 撤销所有刷新令牌，强制登出
    await getAuth().revokeRefreshTokens(userData.uid);

    console.log(`✅ User ${userData.uid} tokens revoked`);

  } catch (error) {
    console.error('❌ Failed to revoke tokens:', error);
  }

  // 发送邮件通知
  const emailResult = await sendEmail(
    userData.email,
    'Account Suspension Notice - SaveEarth',
    SystemEmailTemplates.getBanNotification(userData.username, userData.role),
    userData.username,
    'account_suspension'
  );

  if (!emailResult.success) {
    console.error('❌ Failed to send ban notification:', emailResult.error);
  }
}

// 处理用户恢复
async function handleUserRecovered(userData: UserData) {
  console.log(`🔓 User recovered: ${userData.username} (UID: ${userData.uid})`);

  try {
    // 移除封禁的自定义声明
    await getAuth().setCustomUserClaims(userData.uid, {
      banned: false,
      recoveredAt: Date.now()
    });

    console.log(`✅ User ${userData.uid} ban claims removed`);

  } catch (error) {
    console.error('❌ Failed to update user claims:', error);
  }

  const emailResult = await sendEmail(
    userData.email,
    'Account Recovery Notice - SaveEarth',
    SystemEmailTemplates.getRecoverNotification(userData.username, userData.role),
    userData.username,
    'account_recovery'
  );

  if (!emailResult.success) {
    console.error('❌ Failed to send recovery notification:', emailResult.error);
  }
}

// 处理用户信息更新
async function handleUserUpdated(userData: UserData, changes: string[]) {
  console.log(`✏️ User updated: ${userData.username}`, changes);

  const emailResult = await sendEmail(
    userData.email,
    'Account Updated - SaveEarth',
    SystemEmailTemplates.getUpdateNotification(userData.username, userData.role, changes),
    userData.username,
    'account_updated'
  );

  if (!emailResult.success) {
    console.error('❌ Failed to send update notification:', emailResult.error);
  }
}

// 监听用户状态变化 - 使用 v2 语法
export const onUserStatusChanged = onDocumentUpdated('users/{userId}', async (event) => {
  const beforeData = event.data?.before.data() as UserData;
  const afterData = event.data?.after.data() as UserData;
  const userId = event.params.userId;

  if (!beforeData || !afterData) {
    console.log('❌ No data found for user:', userId);
    return;
  }

  console.log(`📝 User ${userId} status changed`);

  // 只处理系统角色的用户
  if (!isSystemRole(afterData.role)) {
    return;
  }

  // 检查封禁操作
  const wasBanned = !beforeData.isBanned && afterData.isBanned;
  // 检查恢复操作
  const wasRecovered = beforeData.isBanned && !afterData.isBanned;

  if (wasBanned) {
    // 确保 afterData 包含 uid
    const userDataWithUid = { ...afterData, uid: userId };
    await handleUserBanned(userDataWithUid);
  } else if (wasRecovered) {
    // 确保 afterData 包含 uid
    const userDataWithUid = { ...afterData, uid: userId };
    await handleUserRecovered(userDataWithUid);
  }
});

// 监听用户信息更新 - 使用 v2 语法
export const onUserUpdated = onDocumentUpdated('users/{userId}', async (event) => {
  const beforeData = event.data?.before.data() as UserData;
  const afterData = event.data?.after.data() as UserData;
  const userId = event.params.userId;

  if (!beforeData || !afterData) {
    console.log('❌ No data found for user:', userId);
    return;
  }

  console.log(`📝 User ${userId} updated`);

  // 只处理系统角色的用户
  if (!isSystemRole(afterData.role)) {
    return;
  }

  // 检查是否有重要字段被修改（排除封禁状态变化）
  const wasBanned = !beforeData.isBanned && afterData.isBanned;
  const wasRecovered = beforeData.isBanned && !afterData.isBanned;

  if (wasBanned || wasRecovered) {
    return; // 封禁/恢复操作由专门的触发器处理
  }

  const changes = getChangedFields(beforeData, afterData);
  if (changes.length > 0) {
    await handleUserUpdated(afterData, changes);
  }
});