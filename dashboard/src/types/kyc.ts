export interface KycUser {
  id: string;
  email: string;
  fullName: string;
  username: string;
  nik: string;
  province: string;
  city: string;
  district: string;
  village: string;
  postalCode: string;
  rt: string;
  rw: string;
  ktpPhotoUrl: string;
  kycFaceUrl: string;
  kycStatus: 'UNVERIFIED' | 'PENDING' | 'APPROVED' | 'REJECTED';
  kycRejectReason: string | null;
  kycReviewedAt: string | null;
  createdAt: string;
}

export interface KycUsersResponse {
  users: KycUser[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}
