'use client';

import useSWR from 'swr';
import { useSession } from 'next-auth/react';

interface UserDetail {
  id: string;
  email: string;
  username: string;
  fullName: string;
  phoneNumber: string;
  kycStatus: string;
  isActive: boolean;
  isLocked: boolean;
  lockedReason: string | null;
  lastLoginAt: string | null;
  createdAt: string;
  province: string | null;
  city: string | null;
  district: string | null;
  village: string | null;
  nik: string | null;
  gender: string | null;
  ktpPhotoUrl: string | null;
  kycFaceUrl: string | null;
  wallet: {
    amountCent: string;
    reservedCent: string;
    currency: string;
    totalMinted: string;
    totalSent: string;
    totalReceived: string;
  } | null;
  sessions: Array<{
    id: string;
    deviceName: string | null;
    deviceId: string | null;
    ipAddress: string | null;
    lastActiveAt: string | null;
    expiresAt: string;
    createdAt: string;
  }>;
  totalTransactions: number;
  riskScore: number;
}

export function useUserDetail(id: string | null) {
  const { data: session } = useSession();

  const fetcher = async (url: string) => {
    const res = await fetch(url, {
      headers: {
        'Content-Type': 'application/json',
        ...(session?.user?.accessToken
          ? { Authorization: `Bearer ${session.user.accessToken}` }
          : {}),
      },
    });
    if (!res.ok) throw new Error(`API error: ${res.status}`);
    const json = await res.json();
    return json.data;
  };

  const { data, error, isLoading, mutate } = useSWR<UserDetail>(
    id && session?.user?.accessToken
      ? `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/admin/users/${id}`
      : null,
    fetcher
  );

  return { user: data, isLoading, error, mutate };
}
