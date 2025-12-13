const sgMail = require('@sendgrid/mail');

// Firebase Functions v2 只支持环境变量
const SENDGRID_API_KEY = process.env.SENDGRID_API_KEY;

if (SENDGRID_API_KEY) {
  sgMail.setApiKey(SENDGRID_API_KEY);
  console.log('✅ SendGrid API key configured');
} else {
  console.warn('⚠️ SendGrid API key not configured - email sending will fail');
  console.warn('💡 Set environment variable SENDGRID_API_KEY in Firebase Console');
}

// 辅助函数：获取角色显示名称
function getRoleDisplayName(role: string): string {
  const roleNames: { [key: string]: string } = {
    'community_manager': 'Community Manager',
    'event_manager': 'Event Manager',
    'reward_manager': 'Reward Manager',
    'center_staff': 'Recycling Center Staff',
    'user': 'User'
  };
  return roleNames[role] || role;
}

// 辅助函数：从HTML提取纯文本
function extractTextFromHtml(html: string): string {
  return html
    .replace(/<[^>]*>/g, '') // 移除HTML标签
    .replace(/\s+/g, ' ') // 合并空格
    .trim();
}

// 邮件模板类 - 支持所有角色
export class SystemEmailTemplates {
  static getBanNotification(userName: string, userRole: string): string {
    const roleDisplayName = getRoleDisplayName(userRole);
    
    const htmlTemplate = `
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background: linear-gradient(135deg, #F44336, #D32F2F); color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
            .content { background: #f9f9f9; padding: 25px; border-radius: 0 0 8px 8px; border: 1px solid #ddd; }
            .footer { text-align: center; margin-top: 20px; padding: 15px; color: #666; font-size: 12px; }
            .warning { background: #ffebee; border: 1px solid #ffcdd2; padding: 15px; border-radius: 5px; margin: 15px 0; color: #c62828; }
            .button { display: inline-block; padding: 10px 20px; background: #F44336; color: white; text-decoration: none; border-radius: 5px; margin: 10px 0; }
        </style>
    </head>
    <body>
        <div class="header">
            <h1>🌍 SaveEarth</h1>
            <p>Account Suspension Notice</p>
        </div>
        <div class="content">
            <h2>Dear ${userName},</h2>

            <div class="warning">
                <strong>⚠️ Important Notice</strong>
                <p>Your ${roleDisplayName} account has been temporarily suspended by the system administrator.</p>
            </div>

            <p><strong>What this means:</strong></p>
            <ul>
                <li>You will not be able to access the SaveEarth system during this suspension period</li>
                <li>All account privileges have been temporarily revoked</li>
                <li>You will receive notification when your account is restored</li>
            </ul>

            <p><strong>Next Steps:</strong></p>
            <p>If you believe this is a mistake or would like to appeal this decision, please contact our support team immediately.</p>

            <p style="text-align: center;">
                <a href="mailto:saveearth.noreply@gmail.com" class="button">Contact Support</a>
            </p>
        </div>
        <div class="footer">
            <p>Best regards,<br><strong>SaveEarth System Administration Team</strong></p>
            <p>🌱 Together, let's make our planet greener!</p>
        </div>
    </body>
    </html>
        `;

    return htmlTemplate;
  }

  static getRecoverNotification(userName: string, userRole: string): string {
    const roleDisplayName = getRoleDisplayName(userRole);
    
    const htmlTemplate = `
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #2196F3, #1976D2); color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { background: #f9f9f9; padding: 25px; border-radius: 0 0 8px 8px; border: 1px solid #ddd; }
        .footer { text-align: center; margin-top: 20px; padding: 15px; color: #666; font-size: 12px; }
        .success { background: #d4edda; border: 1px solid #c3e6cb; padding: 15px; border-radius: 5px; margin: 15px 0; color: #155724; }
        .button { display: inline-block; padding: 10px 20px; background: #2196F3; color: white; text-decoration: none; border-radius: 5px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🌍 SaveEarth</h1>
        <p>Account Recovery Notice</p>
    </div>
    <div class="content">
        <h2>Dear ${userName},</h2>
        
        <div class="success">
            <strong>✅ Great News!</strong>
            <p>Your ${roleDisplayName} account has been successfully recovered and restored.</p>
        </div>

        <p><strong>Account Status:</strong></p>
        <ul>
            <li>✅ Your account access has been fully restored</li>
            <li>✅ All account privileges are now active</li>
            <li>✅ You can log in with your existing credentials</li>
        </ul>

        <p>You can now access the SaveEarth system and continue your important work in environmental conservation.</p>

        <p style="text-align: center;">
            <a href="https://yourapp.saveearth.com/login" color="#ffffff" class="button">Access Your Account</a>
        </p>

        <p><em>If you experience any issues logging in, please contact our support team.</em></p>
        
        <p><strong>Welcome back! 🌟</strong></p>
    </div>
    <div class="footer">
        <p>Best regards,<br><strong>SaveEarth System Administration Team</strong></p>
        <p>🌱 Together, let's make our planet greener!</p>
    </div>
</body>
</html>
    `;

    return htmlTemplate;
  }

  // 角色变更通知模板
  static getRoleChangeNotification(userName: string, oldRole: string, newRole: string): string {
    const oldRoleDisplayName = getRoleDisplayName(oldRole);
    const newRoleDisplayName = getRoleDisplayName(newRole);

    const htmlTemplate = `
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #9C27B0, #7B1FA2); color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { background: #f9f9f9; padding: 25px; border-radius: 0 0 8px 8px; border: 1px solid #ddd; }
        .footer { text-align: center; margin-top: 20px; padding: 15px; color: #666; font-size: 12px; }
        .role-change { background: #f3e5f5; border: 1px solid #ce93d8; padding: 15px; border-radius: 5px; margin: 15px 0; }
        .role-box { background: white; padding: 15px; border-radius: 5px; margin: 10px 0; border-left: 4px solid #9C27B0; }
        .role-label { font-size: 12px; color: #666; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 5px; }
        .role-value { font-size: 18px; font-weight: bold; color: #9C27B0; }
        .arrow { text-align: center; font-size: 24px; color: #9C27B0; margin: 10px 0; }
        .warning-box { background: #fff3e0; border: 1px solid #ffb74d; padding: 15px; border-radius: 5px; margin: 15px 0; color: #e65100; }
        .button { display: inline-block; padding: 10px 20px; background: #9C27B0; color: white; text-decoration: none; border-radius: 5px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🌍 SaveEarth</h1>
        <p>Role Update Notice</p>
    </div>
    <div class="content">
        <h2>Dear ${userName},</h2>

        <div class="role-change">
            <strong>🔄 Your Account Role Has Been Updated</strong>
            <p>An administrator has changed your account role. Please review the details below:</p>
        </div>

        <div class="role-box">
            <div class="role-label">Previous Role</div>
            <div class="role-value">👤 ${oldRoleDisplayName}</div>
        </div>

        <div class="arrow">⬇️</div>

        <div class="role-box">
            <div class="role-label">New Role</div>
            <div class="role-value">⭐ ${newRoleDisplayName}</div>
        </div>

        <div class="warning-box">
            <strong>⚠️ Important: Action Required</strong>
            <p><strong>You will be automatically logged out</strong> to apply these changes. Please log in again to access your account with the new role permissions.</p>
        </div>

        <p><strong>What Changes With Your New Role:</strong></p>
        <ul>
            <li>✨ Your access permissions have been updated</li>
            <li>🔐 You will need to re-authenticate to access the system</li>
            <li>📊 Your dashboard and available features may differ based on the new role</li>
            <li>🎯 New responsibilities and capabilities are now available</li>
        </ul>

        <p><strong>Next Steps:</strong></p>
        <ol>
            <li>You will be logged out automatically in a few moments</li>
            <li>Log back in using your existing credentials</li>
            <li>Explore your new role features and permissions</li>
        </ol>

        <p style="text-align: center;">
            <a href="https://yourapp.saveearth.com/login" class="button">Log In Now</a>
        </p>

        <p><em><strong>Need Help?</strong> If you believe this role change was made in error or have questions about your new role, please contact our support team.</em></p>

        <p style="text-align: center;">
            <a href="mailto:saveearth.noreply@gmail.com" style="color: #9C27B0; text-decoration: none;">📧 Contact Support</a>
        </p>
    </div>
    <div class="footer">
        <p>Best regards,<br><strong>SaveEarth System Administration Team</strong></p>
        <p>🌱 Together, let's make our planet greener!</p>
    </div>
</body>
</html>
    `;

    return htmlTemplate;
  }

  static getUpdateNotification(userName: string, userRole: string, changes: string[]): string {
    const roleDisplayName = getRoleDisplayName(userRole);

    const changesHtml = changes.length === 0 ?
      '<p>Your account information has been updated.</p>' :
      `
      <p><strong>The following changes were made to your account:</strong></p>
      <div style="background: #f8f9fa; padding: 15px; border-radius: 5px; border-left: 4px solid #2196F3;">
          ${changes.map(change => `<p style="margin: 5px 0;">${change}</p>`).join('')}
      </div>
      `;

    const htmlTemplate = `
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #FF9800, #F57C00); color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { background: #f9f9f9; padding: 25px; border-radius: 0 0 8px 8px; border: 1px solid #ddd; }
        .footer { text-align: center; margin-top: 20px; padding: 15px; color: #666; font-size: 12px; }
        .info { background: #d1ecf1; border: 1px solid #bee5eb; padding: 15px; border-radius: 5px; margin: 15px 0; color: #0c5460; }
        .button { display: inline-block; padding: 10px 20px; background: #FF9800; color: white; text-decoration: none; border-radius: 5px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🌍 SaveEarth</h1>
        <p>Account Updated</p>
    </div>
    <div class="content">
        <h2>Dear ${userName},</h2>

        <div class="info">
            <strong>📝 Account Update Notice</strong>
            <p>Your ${roleDisplayName} account information has been recently updated.</p>
        </div>

        ${changesHtml}

        <p><strong>Security Notice:</strong></p>
        <p>If you did not request these changes or believe this is an error, please contact our support team immediately to secure your account.</p>

        <p style="text-align: center;">
            <a href="mailto:saveearth.noreply@gmail.com" color="#ffffff" class="button">Contact Support</a>
        </p>

        <p><em>For security reasons, we recommend reviewing your account details regularly.</em></p>
    </div>
    <div class="footer">
        <p>Best regards,<br><strong>SaveEarth System Administration Team</strong></p>
        <p>🌱 Together, let's make our planet greener!</p>
    </div>
</body>
</html>
    `;

    return htmlTemplate;
  }
}

// 发送邮件函数
export async function sendEmail(
  toEmail: string,
  subject: string,
  message: string,
  managerName: string,
  actionType: string
): Promise<{ success: boolean; error?: string }> {
  try {
    if (!SENDGRID_API_KEY) {
      console.error('❌ SendGrid API key not configured');
      return {
        success: false,
        error: 'SendGrid API key not configured. Please set SENDGRID_API_KEY environment variable in Firebase Console.'
      };
    }

    console.log('📧 Sending notification to:', toEmail);
    console.log('📝 Subject:', subject);
    console.log('👤 Manager:', managerName);
    console.log('🔧 Action:', actionType);

    const msg = {
      to: toEmail,
      from: {
        email: 'saveearth.noreply@gmail.com',
        name: 'SaveEarth System Admin'
      },
      subject: subject,
      html: message, // 现在使用HTML格式
      text: extractTextFromHtml(message), // 提供纯文本备用
    };

    await sgMail.send(msg);
    console.log('✅ Email sent successfully to:', toEmail);

    return { success: true };
  } catch (error: any) {
    console.error('❌ Email sending failed:', error);
    return {
      success: false,
      error: error.message || 'Unknown error occurred'
    };
  }
}
