'use client';

import useSWR from 'swr';
import { useSession } from 'next-auth/react';

interface User {
  id: string;
  email: string;
  username: string;
  fullName: string;
  role: string;
  kycStatus: string;
  isActive: boolean;
  createdAt: string;
}

interface UsersResponse {
  users: User[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

export function useUsers(page = 1, limit = 10) {
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

  const { data, error, isLoading, mutate } = useSWR<UsersResponse>(
    session?.user?.accessToken
      ? `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/admin/users?page=${page}&limit=${limit}`
      : null,
    fetcher
  );

  return {
    users: data?.users ?? [],
    total: data?.meta?.total ?? 0,
    totalPages: data?.meta?.totalPages ?? 0,
    currentPage: data?.meta?.page ?? page,
    isLoading,
    error,
    mutate,
  };
}
