// src/accountManagement/createStaffManager.ts

import * as admin from 'firebase-admin';
import { onCall, CallableRequest } from 'firebase-functions/v2/https';
import { sendPasswordResetEmail, getCenterName, getAdminName } from './accountEmailService';

// 定义请求数据类型
interface CreateAccountRequestData {
  centerId?: string; // Optional for managers
  username: string;
  email: string;
  role: 'center_staff' | 'community_manager' | 'event_manager' | 'reward_manager';
}

/**
 * 生成随机16位密码
 */
function generateRandomPassword(): string {
  const length = 16;
  const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*';
  let password = '';

  // 确保至少包含一个大写字母、小写字母、数字和特殊字符
  password += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[Math.floor(Math.random() * 26)];
  password += 'abcdefghijklmnopqrstuvwxyz'[Math.floor(Math.random() * 26)];
  password += '0123456789'[Math.floor(Math.random() * 10)];
  password += '!@#$%^&*'[Math.floor(Math.random() * 8)];

  // 填充剩余字符
  for (let i = password.length; i < length; i++) {
    password += charset[Math.floor(Math.random() * charset.length)];
  }

  // 打乱字符顺序
  return password.split('').sort(() => Math.random() - 0.5).join('');
}

/**
 * Cloud Function to create staff/manager user without affecting current admin login
 */
export const createStaffManager = onCall(async (request: CallableRequest<CreateAccountRequestData>) => {
  const data = request.data;

  // Validate input data
  if (!data?.username || !data?.email || !data?.role) {
    throw new Error('Missing required fields: username, email, role');
  }

  // Validate role
  const validRoles = ['center_staff', 'community_manager', 'event_manager', 'reward_manager'];
  if (!validRoles.includes(data.role)) {
    throw new Error('Invalid role. Must be one of: center_staff, community_manager, event_manager, reward_manager');
  }

  // Center staff requires centerId
  if (data.role === 'center_staff' && !data.centerId) {
    throw new Error('centerId is required for center_staff role');
  }

  const { centerId, username, email, role } = data;

  try {
    // Verify that the caller is authenticated
    if (!request.auth) {
      throw new Error('User must be authenticated to create staff/manager accounts');
    }

    // Verify that the caller is an admin
    const callerUid = request.auth.uid;
    const callerUser = await admin.firestore().collection('users').doc(callerUid).get();
    const callerRole = callerUser.data()?.role;

    if (callerRole !== 'admin') {
      throw new Error('Only admin users can create staff/manager accounts');
    }

    // Check if email already exists in Auth
    try {
      await admin.auth().getUserByEmail(email);
      throw new Error('Email is already registered');
    } catch (error: any) {
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

    // Generate random 16-character password
    const randomPassword = generateRandomPassword();
    console.log('✅ Generated random password for user');

    // Create the user in Firebase Auth
    const userRecord = await admin.auth().createUser({
      email: email,
      password: randomPassword,
      emailVerified: false,
      disabled: false,
    });

    console.log('✅ Firebase Auth account created:', userRecord.uid);

    // Get center name (if staff) and admin name for email
    const [centerName, adminName] = await Promise.all([
      centerId ? getCenterName(centerId) : Promise.resolve('N/A'),
      getAdminName(callerUid)
    ]);

    // Create user document in Firestore
    const userData: any = {
      userId: userRecord.uid,
      username: username,
      email: email,
      role: role,
      isVerified: false,
      isActive: true,
      isBanned: false,
      joinDate: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      profileImg: '',
      loginAttemptCount: 0,
    };

    // Add centerId for center_staff
    if (role === 'center_staff' && centerId) {
      userData.centerId = centerId;
    }

    await admin.firestore()
      .collection('users')
      .doc(userRecord.uid)
      .set(userData);

    console.log('✅ Firestore document created');

    // Send password reset email
    let emailSent = false;
    let emailError = '';

    try {
      const passwordResetLink = await admin.auth().generatePasswordResetLink(email);

      const emailResult = await sendPasswordResetEmail(
        email,
        username,
        role,
        centerName,
        passwordResetLink,
        adminName
      );

      emailSent = emailResult.success;
      if (!emailResult.success) {
        emailError = emailResult.error || 'Unknown email error';
        console.error('❌ Failed to send password reset email:', emailError);
      } else {
        console.log('✅ Password reset email sent successfully');
      }

    } catch (emailErr: any) {
      console.error('❌ Error generating password reset link:', emailErr);
      emailError = emailErr.message;
    }

    // Get role display name
    const roleDisplayName = getRoleDisplayName(role);

    return {
      success: true,
      userId: userRecord.uid,
      message: emailSent
        ? `${roleDisplayName} account created successfully. Password reset email sent.`
        : `${roleDisplayName} account created successfully, but password reset email failed to send.`,
      emailSent: emailSent,
      emailError: emailError || null,
      data: {
        userId: userRecord.uid,
        username: username,
        email: email,
        role: role,
        centerId: centerId || null,
        centerName: centerName,
      }
    };

  } catch (error: any) {
    console.error('❌ Error creating account:', error);

    if (error.code === 'auth/email-already-exists') {
      throw new Error('Email is already registered');
    } else if (error.code === 'auth/invalid-email') {
      throw new Error('Invalid email address');
    } else if (error.code === 'auth/weak-password') {
      throw new Error('Password is too weak');
    } else if (error.code === 'auth/operation-not-allowed') {
      throw new Error('Email/password accounts are not enabled');
    }

    throw new Error('Failed to create account: ' + error.message);
  }
});

/**
 * Get role display name
 */
function getRoleDisplayName(role: string): string {
  const roleNames: { [key: string]: string } = {
    'center_staff': 'Staff',
    'community_manager': 'Community Manager',
    'event_manager': 'Event Manager',
    'reward_manager': 'Reward Manager',
  };
  return roleNames[role] || 'User';
}