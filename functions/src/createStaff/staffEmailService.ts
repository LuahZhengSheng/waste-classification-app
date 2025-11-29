// src/createStaff/staffEmailService.ts

import * as admin from 'firebase-admin';
import { StaffEmailTemplates } from './staffEmailTemplates';

const sgMail = require('@sendgrid/mail');

// Firebase Functions v2 只支持环境变量
const SENDGRID_API_KEY = process.env.SENDGRID_API_KEY;

if (SENDGRID_API_KEY) {
  sgMail.setApiKey(SENDGRID_API_KEY);
  console.log('✅ SendGrid API key configured for staff emails');
} else {
  console.warn('⚠️ SendGrid API key not configured - staff email sending will fail');
  console.warn('💡 Set environment variable SENDGRID_API_KEY in Firebase Console');
}

/**
 * 发送员工密码重置邮件
 */
export async function sendStaffPasswordResetEmail(
  toEmail: string,
  staffName: string,
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

    console.log('📧 Sending staff password reset email to:', toEmail);
    console.log('👤 Staff Name:', staffName);
    console.log('🏢 Center:', centerName);
    console.log('🔑 Reset Link:', resetLink.substring(0, 50) + '...');

    const subject = `Set Your Password - SaveEarth Staff Account for ${centerName}`;

    const msg = {
      to: toEmail,
      from: {
        email: 'saveearth.noreply@gmail.com',
        name: 'SaveEarth Staff System'
      },
      subject: subject,
      text: StaffEmailTemplates.getStaffPasswordResetText(staffName, centerName, resetLink, adminName),
      html: StaffEmailTemplates.getStaffPasswordReset(staffName, centerName, resetLink, adminName),
    };

    await sgMail.send(msg);
    console.log('✅ Staff password reset email sent successfully to:', toEmail);

    return { success: true };
  } catch (error: any) {
    console.error('❌ Staff password reset email sending failed:', error);

    // 提供更详细的错误信息
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