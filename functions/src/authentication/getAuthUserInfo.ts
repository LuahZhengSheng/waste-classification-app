import * as admin from 'firebase-admin';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';

// 定义接口类型
interface AuthQuery {
  email: string;
  type: string;
  timestamp?: admin.firestore.FieldValue;
}

// 处理 Auth 用户信息查询
export const getAuthUserInfo = onDocumentCreated('adminAuthQueries/{docId}', async (event) => {
  const snap = event.data;
  if (!snap) {
    console.log('No data associated with the event');
    return;
  }

  const data = snap.data() as AuthQuery;
  const { email, type } = data;

  // 验证必要字段
  if (!email || !type) {
    console.error('Missing required fields: email or type');
    await snap.ref.update({
      processed: true,
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
      error: 'Missing required fields: email or type'
    });
    return;
  }

  try {
    if (type === 'getEmailVerifiedStatus') {
      // 通过邮箱查找用户
      const user = await admin.auth().getUserByEmail(email);

      // 更新文档返回结果
      await snap.ref.update({
        emailVerified: user.emailVerified,
        uid: user.uid,
        processed: true,
        processedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      console.log(`Retrieved auth info for ${email}: emailVerified = ${user.emailVerified}`);
    } else {
      console.log(`Unknown query type: ${type}`);
      await snap.ref.update({
        processed: true,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        error: `Unknown query type: ${type}`
      });
    }
  } catch (error) {
    console.error('Error getting auth user info:', error);

    const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';

    // 更新文档返回错误
    await snap.ref.update({
      processed: true,
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
      error: errorMessage
    });
  }
});