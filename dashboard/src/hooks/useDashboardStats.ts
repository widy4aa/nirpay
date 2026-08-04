'use client';

import useSWR from 'swr';
import { useSession } from 'next-auth/react';

interface DashboardStats {
  totalUsers: number;
  activeUsers: number;
  inactiveUsers: number;
  totalAdmins: number;
  pendingKyc: number;
  approvedKyc: number;
  rejectedKyc: number;
  totalTransactions: number;
  totalVolume: number;
}

export function useDashboardStats() {
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

    if (!res.ok) {
      throw new Error(`API error: ${res.status}`);
    }

    const json = await res.json();
    return json.data;
  };

  const { data, error, isLoading, mutate } = useSWR<DashboardStats>(
    session?.user?.accessToken
      ? `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/admin/stats`
      : null,
    fetcher
  );

  return { stats: data, isLoading, error, mutate };
}
