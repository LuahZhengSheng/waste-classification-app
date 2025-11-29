// src/accountManagement/accountEmailTemplates.ts

export class AccountEmailTemplates {
  /**
   * HTML 版本密码重置邮件
   */
  static getPasswordResetHtml(
    username: string,
    role: string,
    centerName: string,
    resetLink: string,
    adminName: string = 'System Administrator'
  ): string {
    const roleInfo = this.getRoleInfo(role, centerName);

    return `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #4CAF50, #45a049); color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
          .button { background-color: #4CAF50; color: white; padding: 12px 30px; text-decoration: none; border-radius: 4px; display: inline-block; margin: 20px 0; }
          .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 12px; }
          .info-box { background: #e8f5e8; border-left: 4px solid #4CAF50; padding: 15px; margin: 20px 0; }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>Welcome to SaveEarth!</h1>
          <p>${roleInfo.title}</p>
        </div>

        <div class="content">
          <h2>Hello ${username},</h2>

          <p>Your account has been created by <strong>${adminName}</strong>.</p>

          <div class="info-box">
            ${roleInfo.infoHtml}
          </div>

          <p>To get started, please set your password by clicking the button below:</p>

          <p style="text-align: center;">
            <a href="${resetLink}" class="button">Set Your Password</a>
          </p>

          <p><strong>Important:</strong> This link will expire in 1 hour for security reasons.</p>

          <p>If you have any questions or need assistance, please contact your administrator.</p>

          <div class="footer">
            <p><strong>SaveEarth Recycling Platform</strong></p>
            <p>This is an automated message. Please do not reply to this email.</p>
            <p>If you didn't expect this email, please contact your administrator immediately.</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  /**
   * 纯文本版本
   */
  static getPasswordResetText(
    username: string,
    role: string,
    centerName: string,
    resetLink: string,
    adminName: string = 'System Administrator'
  ): string {
    const roleInfo = this.getRoleInfo(role, centerName);

    return `
Welcome to SaveEarth!

Hello ${username},

Your account has been created by ${adminName}.

${roleInfo.infoText}

To get started, please set your password by clicking the link below:

${resetLink}

Important: This link will expire in 1 hour for security reasons.

If you have any questions or need assistance, please contact your administrator.

--
SaveEarth Recycling Platform
This is an automated message. Please do not reply to this email.
If you didn't expect this email, please contact your administrator immediately.
    `;
  }

  /**
   * 获取角色相关信息
   */
  private static getRoleInfo(role: string, centerName: string): { title: string; infoHtml: string; infoText: string } {
    switch (role) {
      case 'center_staff':
        return {
          title: 'Staff Account Created',
          infoHtml: `<strong>Recycling Center:</strong> ${centerName}<br><strong>Role:</strong> Recycling Center Staff`,
          infoText: `Recycling Center: ${centerName}\nRole: Recycling Center Staff`
        };
      case 'community_manager':
        return {
          title: 'Community Manager Account Created',
          infoHtml: `<strong>Role:</strong> Community Manager<br><strong>Responsibilities:</strong> Manage community posts and user interactions`,
          infoText: `Role: Community Manager\nResponsibilities: Manage community posts and user interactions`
        };
      case 'event_manager':
        return {
          title: 'Event Manager Account Created',
          infoHtml: `<strong>Role:</strong> Event Manager<br><strong>Responsibilities:</strong> Create and manage recycling events`,
          infoText: `Role: Event Manager\nResponsibilities: Create and manage recycling events`
        };
      case 'reward_manager':
        return {
          title: 'Reward Manager Account Created',
          infoHtml: `<strong>Role:</strong> Reward Manager<br><strong>Responsibilities:</strong> Manage rewards and redemptions`,
          infoText: `Role: Reward Manager\nResponsibilities: Manage rewards and redemptions`
        };
      default:
        return {
          title: 'Account Created',
          infoHtml: `<strong>Role:</strong> ${role}`,
          infoText: `Role: ${role}`
        };
    }
  }
}