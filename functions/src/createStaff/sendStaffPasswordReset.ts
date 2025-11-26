import * as admin from 'firebase-admin';
import { onCall } from 'firebase-functions/v2/https';
import { sendStaffPasswordResetEmail, getCenterName, getAdminName } from './staffEmailService';
import { SendPasswordResetCallableRequest, StaffData } from '../types/staffTypes';

/**
 * Send password reset email to existing staff member
 */
export const sendStaffPasswordReset = onCall(async (request: SendPasswordResetCallableRequest) => {
  const data = request.data;

  if (!request.auth) {
    throw new Error('User must be authenticated to send password reset emails');
  }

  if (!data?.staffEmail && !data?.staffId) {
    throw new Error('Either staffEmail or staffId is required');
  }

  try {
    // Verify caller is admin
    const callerUid = request.auth.uid;
    const callerUser = await admin.firestore().collection('users').doc(callerUid).get();
    const callerRole = callerUser.data()?.role;

    if (callerRole !== 'admin') {
      throw new Error('Only admin users can send password reset emails');
    }

    let staffDoc: admin.firestore.DocumentSnapshot;

    // Find staff by email or ID
    if (data.staffId) {
      staffDoc = await admin.firestore().collection('users').doc(data.staffId).get();
    } else {
      const staffQuery = await admin.firestore()
        .collection('users')
        .where('email', '==', data.staffEmail)
        .where('role', '==', 'center_staff')
        .limit(1)
        .get();

      if (staffQuery.empty) {
        throw new Error('Staff member not found with the provided email');
      }
      staffDoc = staffQuery.docs[0];
    }

    if (!staffDoc.exists) {
      throw new Error('Staff member not found');
    }

    const staffData = staffDoc.data() as StaffData;
    const targetStaffEmail = staffData.email;
    const staffName = staffData.username;
    const centerId = staffData.centerId;

    // Get center name and admin name
    const [centerName, adminName] = await Promise.all([
      getCenterName(centerId),
      getAdminName(callerUid)
    ]);

    // Generate password reset link - 修复变量名错误
    const passwordResetLink = await admin.auth().generatePasswordResetLink(targetStaffEmail); // 改为 targetStaffEmail
    // 或者使用带配置的版本：
    // const passwordResetLink = await admin.auth().generatePasswordResetLink(targetStaffEmail, {
    //   url: `https://saveearth-recycling.web.app/login`,
    //   handleCodeInApp: false,
    // });

    // Send email
    const emailResult = await sendStaffPasswordResetEmail(
      targetStaffEmail,
      staffName,
      centerName,
      passwordResetLink,
      adminName
    );

    if (!emailResult.success) {
      throw new Error(emailResult.error || 'Failed to send password reset email');
    }

    return {
      success: true,
      message: 'Password reset email sent successfully to staff member'
    };

  } catch (error: any) {
    console.error('❌ Error sending staff password reset email:', error);

    if (error.code === 'auth/user-not-found') {
      throw new Error('User with this email does not exist');
    }

    throw new Error('Failed to send password reset email: ' + error.message);
  }
});