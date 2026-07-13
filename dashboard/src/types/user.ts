export interface User {
  id: string;
  email: string;
  username: string;
  phone: string;
  kycStatus: 'UNVERIFIED' | 'PENDING' | 'APPROVED' | 'REJECTED';
  role: 'USER' | 'ADMIN' | 'SUPER_ADMIN';
  createdAt: string;
}

export interface UserListResponse {
  success: boolean;
  data: User[];
  total: number;
  page: number;
  limit: number;
}
