// src/createStaff/staffEmailTemplates.ts

export class StaffEmailTemplates {
  /**
   * 员工账户创建和密码重置邮件模板
   */
  static getStaffPasswordReset(
    staffName: string,
    centerName: string,
    resetLink: string,
    adminName: string = 'System Administrator'
  ): string {
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
          <p>Staff Account Created</p>
        </div>

        <div class="content">
          <h2>Hello ${staffName},</h2>

          <p>Your staff account has been created by <strong>${adminName}</strong> and you've been assigned to:</p>

          <div class="info-box">
            <strong>Recycling Center:</strong> ${centerName}<br>
            <strong>Role:</strong> Recycling Center Staff
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
   * 纯文本版本（备用）
   */
  static getStaffPasswordResetText(
    staffName: string,
    centerName: string,
    resetLink: string,
    adminName: string = 'System Administrator'
  ): string {
    return `
Welcome to SaveEarth!

Hello ${staffName},

Your staff account has been created by ${adminName} and you've been assigned to:

Recycling Center: ${centerName}
Role: Recycling Center Staff

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
}