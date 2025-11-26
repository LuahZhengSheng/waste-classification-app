// import * as admin from 'firebase-admin';
// import { onUserUpdated } from 'firebase-functions/v2/identity';
//
// /**
//  * 直接监听邮箱验证状态变化，无需检测密码重置
//  */
// export const onStaffEmailVerified = onUserUpdated(async (event) => {
//   const userBefore = event.data.before;
//   const userAfter = event.data.after;
//
//   if (!userBefore || !userAfter) return;
//
//   try {
//     // 直接检查邮箱验证状态是否从 false → true
//     const emailWasNotVerified = !userBefore.emailVerified;
//     const emailIsNowVerified = userAfter.emailVerified;
//
//     if (emailWasNotVerified && emailIsNowVerified) {
//       console.log(`🎯 Email verification detected for user: ${userAfter.uid}`);
//
//       // 确认用户是员工
//       const userDoc = await admin.firestore().collection('users').doc(userAfter.uid).get();
//
//       if (userDoc.exists) {
//         const userData = userDoc.data();
//
//         if (userData?.role === 'center_staff') {
//           console.log(`🚀 Staff ${userAfter.email} verified email, updating Firestore`);
//
//           // 直接更新 Firestore 中的 isVerified
//           await admin.firestore().collection('users').doc(userAfter.uid).update({
//             isVerified: true,
//             emailVerifiedAt: admin.firestore.FieldValue.serverTimestamp(),
//             lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
//           });
//
//           console.log(`✅ Successfully updated isVerified for staff: ${userAfter.email}`);
//
//           // 记录验证事件（可选）
//           await admin.firestore().collection('verificationLogs').add({
//             staffUid: userAfter.uid,
//             staffEmail: userAfter.email,
//             verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
//             trigger: 'email_verification',
//             authProvider: userAfter.providerData[0]?.providerId || 'password'
//           });
//         }
//       }
//     }
//   } catch (error) {
//     console.error('Error handling email verification:', error);
//   }
// });