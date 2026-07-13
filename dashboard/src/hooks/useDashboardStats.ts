'use client';

import useSWR from 'swr';
import { api } from '@/lib/api-client';
import { ApiResponse } from '@/types/api';

interface DashboardStats {
  totalUsers: number;
  totalTransactions: number;
  totalVolume: number;
}

export function useDashboardStats() {
  const { data, error, isLoading, mutate } = useSWR<ApiResponse<DashboardStats>>(
    '/admin/stats',
    (url: string) => api.get<ApiResponse<DashboardStats>>(url)
  );

  return {
    stats: data?.data,
    isLoading,
    error,
    mutate,
  };
}
