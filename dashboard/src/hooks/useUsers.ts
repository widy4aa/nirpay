'use client';

import useSWR from 'swr';
import { api } from '@/lib/api-client';
import { ApiResponse } from '@/types/api';
import { User } from '@/types/user';

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
  const { data, error, isLoading, mutate } = useSWR<ApiResponse<UsersResponse>>(
    `/admin/users?page=${page}&limit=${limit}`,
    (url: string) => api.get<ApiResponse<UsersResponse>>(url)
  );

  return {
    users: data?.data?.users ?? [],
    total: data?.data?.meta?.total ?? 0,
    totalPages: data?.data?.meta?.totalPages ?? 0,
    isLoading,
    error,
    mutate,
  };
}
