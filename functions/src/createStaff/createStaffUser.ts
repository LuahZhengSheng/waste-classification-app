// src/createStaff/createStaffUser.ts

import * as admin from 'firebase-admin';
import { onCall, CallableRequest } from 'firebase-functions/v2/https';
import { sendStaffPasswordResetEmail, getCenterName, getAdminName } from './staffEmailService';

// 定义请求数据类型
interface CreateStaffRequestData {
  centerId: string;
  username: string;
  email: string;
  password: string;
  role?: string;
}

/**
 * Cloud Function to create staff user without affecting current admin login
 */
export const createStaffUser = onCall(async (request: CallableRequest<CreateStaffRequestData>) => {
  const data = request.data;

  // Validate input data
  if (!data?.centerId || !data?.username || !data?.email || !data?.password) {
    throw new Error(
      'Missing required fields: centerId, username, email, password'
    );
  }

  const { centerId, username, email, password, role = 'center_staff' } = data;

  try {
    // Verify that the caller is authenticated
    if (!request.auth) {
      throw new Error(
        'User must be authenticated to create staff accounts'
      );
    }

    // Verify that the caller is an admin
    const callerUid = request.auth.uid;
    const callerUser = await admin.firestore().collection('users').doc(callerUid).get();
    const callerRole = callerUser.data()?.role;

    if (callerRole !== 'admin') {
      throw new Error(
        'Only admin users can create staff accounts'
      );
    }

    // Check if email already exists in Auth
    try {
      await admin.auth().getUserByEmail(email);
      // If we reach here, email already exists
      throw new Error('Email is already registered');
    } catch (error: any) {
      // If error code is 'auth/user-not-found', email doesn't exist (this is good)
      if (error.code !== 'auth/user-not-found') {
        throw error;
      }
    }

    // Check if username already exists in Firestore
    const usernameQuery = await admin.firestore()
      .collection('users')
      .where('username', '==', username)
      .limit(1)
      .get();

    if (!usernameQuery.empty) {
      throw new Error('Username is already taken');
    }

    // Create the user in Firebase Auth
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      emailVerified: false, // 初始状态为未验证
      disabled: false,
    });

    // Get center name and admin name for email
    const [centerName, adminName] = await Promise.all([
      getCenterName(centerId),
      getAdminName(callerUid)
    ]);

    // Create user document in Firestore
    const userData = {
      userId: userRecord.uid,
      username: username,
      email: email,
      role: role,
      centerId: centerId,
      isVerified: false, // 初始状态为未验证
      isActive: true,
      isBanned: false,
      joinDate: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      profileImg: '',
    };

    await admin.firestore()
      .collection('users')
      .doc(userRecord.uid)
      .set(userData);

    // Send password reset email
    let emailSent = false;
    let emailError = '';

    try {
      const passwordResetLink = await admin.auth().generatePasswordResetLink(email);

      // Send the password reset email
      const emailResult = await sendStaffPasswordResetEmail(
        email,
        username,
        centerName,
        passwordResetLink,
        adminName
      );

      emailSent = emailResult.success;
      if (!emailResult.success) {
        emailError = emailResult.error || 'Unknown email error';
        console.error('❌ Failed to send staff password reset email:', emailError);
      }

    } catch (emailErr: any) {
      console.error('❌ Error generating password reset link:', emailErr);
      emailError = emailErr.message;
    }

    return {
      success: true,
      userId: userRecord.uid,
      message: emailSent
        ? 'Staff user created successfully. Password reset email sent.'
        : 'Staff user created successfully, but password reset email failed to send.',
      emailSent: emailSent,
      emailError: emailError || null,
      data: {
        userId: userRecord.uid,
        username: username,
        email: email,
        centerId: centerId,
        centerName: centerName,
      }
    };

  } catch (error: any) {
    console.error('❌ Error creating staff user:', error);

    // Handle specific error types
    if (error.code === 'auth/email-already-exists') {
      throw new Error('Email is already registered');
    } else if (error.code === 'auth/invalid-email') {
      throw new Error('Invalid email address');
    } else if (error.code === 'auth/weak-password') {
      throw new Error('Password is too weak');
    } else if (error.code === 'auth/operation-not-allowed') {
      throw new Error('Email/password accounts are not enabled');
    }

    throw new Error('Failed to create staff user: ' + error.message);
  }
});