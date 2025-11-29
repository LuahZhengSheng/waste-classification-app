// src/accountManagement/accountEmailService.ts

import * as admin from 'firebase-admin';
import { AccountEmailTemplates } from './accountEmailTemplates';

const sgMail = require('@sendgrid/mail');

const SENDGRID_API_KEY = process.env.SENDGRID_API_KEY;

if (SENDGRID_API_KEY) {
  sgMail.setApiKey(SENDGRID_API_KEY);
  console.log('✅ SendGrid API key configured for account emails');
} else {
  console.warn('⚠️ SendGrid API key not configured - email sending will fail');
  console.warn('💡 Set environment variable SENDGRID_API_KEY in Firebase Console');
}

/**
 * 发送密码重置邮件（统一函数）
 */
export async function sendPasswordResetEmail(
  toEmail: string,
  username: string,
  role: string,
  centerName: string,
  resetLink: string,
  adminName?: string
): Promise<{ success: boolean; error?: string }> {
  try {
    if (!SENDGRID_API_KEY) {
      console.error('❌ SendGrid API key not configured');
      return {
        success: false,
        error: 'SendGrid API key not configured. Please set SENDGRID_API_KEY environment variable in Firebase Console.'
      };
    }

    console.log('📧 Sending password reset email to:', toEmail);
    console.log('👤 Username:', username);
    console.log('🔑 Role:', role);
    console.log('🏢 Center:', centerName);

    const subject = getEmailSubject(role, centerName);

    const msg = {
      to: toEmail,
      from: {
        email: 'saveearth.noreply@gmail.com',
        name: 'SaveEarth System'
      },
      subject: subject,
      text: AccountEmailTemplates.getPasswordResetText(username, role, centerName, resetLink, adminName),
      html: AccountEmailTemplates.getPasswordResetHtml(username, role, centerName, resetLink, adminName),
    };

    await sgMail.send(msg);
    console.log('✅ Password reset email sent successfully to:', toEmail);

    return { success: true };
  } catch (error: any) {
    console.error('❌ Password reset email sending failed:', error);

    let errorMessage = error.message || 'Unknown error occurred';
    if (error.response) {
      errorMessage += ` - SendGrid Response: ${JSON.stringify(error.response.body)}`;
    }

    return {
      success: false,
      error: errorMessage
    };
  }
}

/**
 * 获取邮件主题
 */
function getEmailSubject(role: string, centerName: string): string {
  const roleNames: { [key: string]: string } = {
    'center_staff': `Set Your Password - SaveEarth Staff Account for ${centerName}`,
    'community_manager': 'Set Your Password - SaveEarth Community Manager Account',
    'event_manager': 'Set Your Password - SaveEarth Event Manager Account',
    'reward_manager': 'Set Your Password - SaveEarth Reward Manager Account',
  };
  return roleNames[role] || 'Set Your Password - SaveEarth Account';
}

/**
 * 获取回收中心名称
 */
export async function getCenterName(centerId: string): Promise<string> {
  try {
    const centerDoc = await admin.firestore()
      .collection('recyclingCenters')
      .doc(centerId)
      .get();

    if (centerDoc.exists) {
      return centerDoc.data()?.name || `Center ${centerId}`;
    }

    return `Center ${centerId}`;
  } catch (error) {
    console.error('Error fetching center name:', error);
    return `Center ${centerId}`;
  }
}

/**
 * 获取管理员名称
 */
export async function getAdminName(adminUid: string): Promise<string> {
  try {
    const adminDoc = await admin.firestore()
      .collection('users')
      .doc(adminUid)
      .get();

    if (adminDoc.exists) {
      return adminDoc.data()?.username || 'System Administrator';
    }

    return 'System Administrator';
  } catch (error) {
    console.error('Error fetching admin name:', error);
    return 'System Administrator';
  }
}