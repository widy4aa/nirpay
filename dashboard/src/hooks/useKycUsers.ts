'use client';

import useSWR from 'swr';
import { useSession } from 'next-auth/react';

interface KycUser {
  id: string;
  email: string;
  fullName: string;
  username: string;
  nik: string;
  province: string | null;
  city: string | null;
  district: string | null;
  village: string | null;
  postalCode: string | null;
  rt: string | null;
  rw: string | null;
  ktpPhotoUrl: string | null;
  kycFaceUrl: string | null;
  kycStatus: string;
  kycRejectReason: string | null;
  kycReviewedAt: string | null;
  createdAt: string;
}

interface KycResponse {
  users: KycUser[];
  meta: { total: number; page: number; limit: number; totalPages: number };
}

export function useKycUsers(status?: string, page = 1, limit = 20) {
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

  const params = new URLSearchParams();
  if (status && status !== 'all') params.set('status', status);
  params.set('page', String(page));
  params.set('limit', String(limit));

  const { data, error, isLoading, mutate } = useSWR<KycResponse>(
    session?.user?.accessToken
      ? `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/admin/kyc?${params.toString()}`
      : null,
    fetcher
  );

  return {
    users: data?.users ?? [],
    total: data?.meta?.total ?? 0,
    totalPages: data?.meta?.totalPages ?? 0,
    isLoading,
    error,
    mutate,
  };
}
