// src/emailNotifications/directEmailFunctions.ts

import { onCall } from 'firebase-functions/v2/https';
import { sendEmail, SystemEmailTemplates } from './accountEmailService';

// 定义请求数据类型
interface EmailRequest {
  toEmail: string;
  subject: string;
  message: string;
  userName: string;
  userRole: string;
  actionType: string;
}

interface BatchEmailRequest {
  notifications: EmailRequest[];
}

// 直接发送邮件的 HTTP 调用函数 - 使用 v2 语法
export const sendUserNotification = onCall(async (request) => {
  const data = request.data as EmailRequest;

  // 验证请求
  if (!request.auth) {
    throw new Error('User must be authenticated to send notifications');
  }

  const { toEmail, subject, message, userName, userRole, actionType } = data;

  // 验证输入参数
  if (!toEmail || !subject || !message || !userName || !userRole || !actionType) {
    throw new Error('Missing required parameters: toEmail, subject, message, userName, userRole, actionType');
  }

  try {
    const result = await sendEmail(toEmail, subject, message, userName, actionType);

    if (result.success) {
      return {
        success: true,
        message: 'Email sent successfully'
      };
    } else {
      throw new Error(result.error || 'Failed to send email');
    }
  } catch (error: any) {
    console.error('❌ Cloud Function email error:', error);
    throw new Error(error.message);
  }
});

// 批量发送通知的函数 - 使用 v2 语法
export const sendBatchUserNotifications = onCall(async (request) => {
  const data = request.data as BatchEmailRequest;

  if (!request.auth) {
    throw new Error('User must be authenticated');
  }

  const { notifications } = data;

  if (!Array.isArray(notifications) || notifications.length === 0) {
    throw new Error('Notifications array is required and cannot be empty');
  }

  const results = [];

  for (const notification of notifications) {
    const { toEmail, subject, message, userName, userRole, actionType } = notification;

    try {
      const result = await sendEmail(toEmail, subject, message, userName, actionType);
      results.push({
        toEmail,
        userName,
        userRole,
        success: result.success,
        error: result.error
      });
    } catch (error: any) {
      results.push({
        toEmail,
        userName,
        userRole,
        success: false,
        error: error.message
      });
    }
  }

  return {
    success: true,
    results: results
  };
});

// 便捷函数：发送封禁通知
export const sendBanNotification = onCall(async (request) => {
  const data = request.data as {
    toEmail: string;
    userName: string;
    userRole: string;
  };

  if (!request.auth) {
    throw new Error('User must be authenticated to send notifications');
  }

  const { toEmail, userName, userRole } = data;

  if (!toEmail || !userName || !userRole) {
    throw new Error('Missing required parameters: toEmail, userName, userRole');
  }

  try {
    const result = await sendEmail(
      toEmail,
      'Account Suspension Notice - SaveEarth',
      SystemEmailTemplates.getBanNotification(userName, userRole),
      userName,
      'account_suspension'
    );

    if (result.success) {
      return {
        success: true,
        message: 'Ban notification sent successfully'
      };
    } else {
      throw new Error(result.error || 'Failed to send ban notification');
    }
  } catch (error: any) {
    console.error('❌ Cloud Function ban notification error:', error);
    throw new Error(error.message);
  }
});

// 便捷函数：发送恢复通知
export const sendRecoveryNotification = onCall(async (request) => {
  const data = request.data as {
    toEmail: string;
    userName: string;
    userRole: string;
  };

  if (!request.auth) {
    throw new Error('User must be authenticated to send notifications');
  }

  const { toEmail, userName, userRole } = data;

  if (!toEmail || !userName || !userRole) {
    throw new Error('Missing required parameters: toEmail, userName, userRole');
  }

  try {
    const result = await sendEmail(
      toEmail,
      'Account Recovery Notice - SaveEarth',
      SystemEmailTemplates.getRecoverNotification(userName, userRole),
      userName,
      'account_recovery'
    );

    if (result.success) {
      return {
        success: true,
        message: 'Recovery notification sent successfully'
      };
    } else {
      throw new Error(result.error || 'Failed to send recovery notification');
    }
  } catch (error: any) {
    console.error('❌ Cloud Function recovery notification error:', error);
    throw new Error(error.message);
  }
});

// 便捷函数：发送更新通知
export const sendUpdateNotification = onCall(async (request) => {
  const data = request.data as {
    toEmail: string;
    userName: string;
    userRole: string;
    changes: string[];
  };

  if (!request.auth) {
    throw new Error('User must be authenticated to send notifications');
  }

  const { toEmail, userName, userRole, changes } = data;

  if (!toEmail || !userName || !userRole || !Array.isArray(changes)) {
    throw new Error('Missing required parameters: toEmail, userName, userRole, changes');
  }

  try {
    const result = await sendEmail(
      toEmail,
      'Account Updated - SaveEarth',
      SystemEmailTemplates.getUpdateNotification(userName, userRole, changes),
      userName,
      'account_updated'
    );

    if (result.success) {
      return {
        success: true,
        message: 'Update notification sent successfully'
      };
    } else {
      throw new Error(result.error || 'Failed to send update notification');
    }
  } catch (error: any) {
    console.error('❌ Cloud Function update notification error:', error);
    throw new Error(error.message);
  }
});