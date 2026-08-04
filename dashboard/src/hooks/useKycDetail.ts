'use client';

import useSWR from 'swr';
import { useSession } from 'next-auth/react';

interface KycDetail {
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

export function useKycDetail(id: string | null) {
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

  const { data, error, isLoading, mutate } = useSWR<KycDetail>(
    id && session?.user?.accessToken
      ? `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/admin/kyc/${id}`
      : null,
    fetcher
  );

  return { user: data, isLoading, error, mutate };
}
