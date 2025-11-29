// src/accountManagement/resendPasswordReset.ts

import * as admin from 'firebase-admin';
import { onCall, CallableRequest } from 'firebase-functions/v2/https';
import { sendPasswordResetEmail, getCenterName, getAdminName } from './accountEmailService';

interface ResendPasswordResetRequestData {
  userId: string;
  email: string;
}

interface UserData {
  email: string;
  username: string;
  role: string;
  centerId?: string;
  lastPasswordResetTime?: admin.firestore.Timestamp;
  isVerified: boolean;
  isActive: boolean;
  isBanned: boolean;
}

/**
 * Resend password reset email to existing staff/manager
 */
export const resendPasswordReset = onCall(async (request: CallableRequest<ResendPasswordResetRequestData>) => {
  const data = request.data;

  if (!request.auth) {
    throw new Error('User must be authenticated to send password reset emails');
  }

  if (!data?.userId || !data?.email) {
    throw new Error('userId and email are required');
  }

  try {
    // Verify caller is admin
    const callerUid = request.auth.uid;
    const callerUser = await admin.firestore().collection('users').doc(callerUid).get();
    const callerRole = callerUser.data()?.role;

    if (callerRole !== 'admin') {
      throw new Error('Only admin users can send password reset emails');
    }

    // Get user document
    const userDoc = await admin.firestore().collection('users').doc(data.userId).get();

    if (!userDoc.exists) {
      throw new Error('User not found');
    }

    const userData = userDoc.data() as UserData;

    // Validate user role
    const validRoles = ['center_staff', 'community_manager', 'event_manager', 'reward_manager'];
    if (!validRoles.includes(userData.role)) {
      throw new Error('Invalid user role. Can only send password reset to staff/managers');
    }

    // Check if user is verified (should not allow if verified)
    if (userData.isVerified) {
      throw new Error('Cannot send password reset to verified users');
    }

    // Check if user is active and not banned
    if (!userData.isActive || userData.isBanned) {
      throw new Error('Cannot send password reset to inactive or banned users');
    }

    // Check cooldown (10 minutes)
    if (userData.lastPasswordResetTime) {
      const lastResetTime = userData.lastPasswordResetTime.toDate();
      const now = new Date();
      const timeDiff = now.getTime() - lastResetTime.getTime();
      const minutesDiff = timeDiff / (1000 * 60);

      if (minutesDiff < 10) {
        const remainingMinutes = Math.ceil(10 - minutesDiff);
        throw new Error(`Please wait ${remainingMinutes} minute(s) before sending another password reset email`);
      }
    }

    const targetEmail = userData.email;
    const username = userData.username;
    const role = userData.role;
    const centerId = userData.centerId;

    // Get center name (if staff) and admin name
    const [centerName, adminName] = await Promise.all([
      centerId ? getCenterName(centerId) : Promise.resolve('N/A'),
      getAdminName(callerUid)
    ]);

    // Generate password reset link
    const passwordResetLink = await admin.auth().generatePasswordResetLink(targetEmail);

    // Send email
    const emailResult = await sendPasswordResetEmail(
      targetEmail,
      username,
      role,
      centerName,
      passwordResetLink,
      adminName
    );

    if (!emailResult.success) {
      throw new Error(emailResult.error || 'Failed to send password reset email');
    }

    // Update lastPasswordResetTime in Firestore
    await admin.firestore().collection('users').doc(data.userId).update({
      lastPasswordResetTime: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log('✅ Password reset email resent successfully');

    return {
      success: true,
      message: 'Password reset email sent successfully'
    };

  } catch (error: any) {
    console.error('❌ Error resending password reset email:', error);

    if (error.code === 'auth/user-not-found') {
      throw new Error('User with this email does not exist');
    }

    throw new Error(error.message || 'Failed to send password reset email');
  }
});