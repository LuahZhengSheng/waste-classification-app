import { CallableRequest } from 'firebase-functions/v2/https';

export type StaffRole = 'center_staff' | 'community_manager' | 'event_manager' | 'reward_manager';

export interface CreateStaffRequestData {
  centerId: string;
  username: string;
  email: string;
  password: string;
  role?: string;
}

export interface SendPasswordResetRequest {
  staffEmail?: string;
  staffId?: string;
}

// 正确的类型定义
export type CreateStaffCallableRequest = CallableRequest<CreateStaffRequestData>;
export type SendPasswordResetCallableRequest = CallableRequest<SendPasswordResetRequest>;

export interface StaffData {
  userId: string;
  username: string;
  email: string;
  role: StaffRole;
  centerId: string;
  isVerified: boolean;
  isActive: boolean;
  isBanned: boolean;
  joinDate: any;
  createdAt: any;
  profileImg: string;
  phoneNo?: string;
  gender?: string;
}

export interface EmailResult {
  success: boolean;
  error?: string;
}