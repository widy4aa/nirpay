'use client';

import useSWR from 'swr';
import { useSession } from 'next-auth/react';

interface KycUser {
  id: string;
  email: string;
  fullName: string;
  username: string;
  nik: string;
  kycStatus: string;
  createdAt: string;
}

interface KycResponse {
  users: KycUser[];
  meta: { total: number; page: number; limit: number; totalPages: number };
}

export function usePendingKyc() {
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

  const { data, error, isLoading, mutate } = useSWR<KycResponse>(
    session?.user?.accessToken
      ? `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/admin/kyc?status=UNVERIFIED&limit=5`
      : null,
    fetcher
  );

  return { users: data?.users ?? [], total: data?.meta?.total ?? 0, isLoading, error, mutate };
}
