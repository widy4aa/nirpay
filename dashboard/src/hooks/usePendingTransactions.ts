'use client';

import useSWR from 'swr';
import { useSession } from 'next-auth/react';

export interface PendingTransaction {
  id: string;
  txId: string;
  userId: string;
  userName: string;
  userEmail: string;
  direction: string;
  txType: string;
  amountCent: number;
  hopCount: number;
  syncStatus: string;
  counterpartyName: string | null;
  counterpartyId: string | null;
  rejectReason: string | null;
  createdAt: string;
}

interface TransactionsResponse {
  transactions: PendingTransaction[];
  meta: { total: number; page: number; limit: number; totalPages: number };
}

export function usePendingTransactions(txType?: string, page = 1, limit = 20) {
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
  if (txType && txType !== 'all') params.set('txType', txType);
  params.set('status', 'PENDING');
  params.set('page', String(page));
  params.set('limit', String(limit));

  const { data, error, isLoading, mutate } = useSWR<TransactionsResponse>(
    session?.user?.accessToken
      ? `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/admin/transactions?${params.toString()}`
      : null,
    fetcher
  );

  return {
    transactions: data?.transactions ?? [],
    total: data?.meta?.total ?? 0,
    totalPages: data?.meta?.totalPages ?? 0,
    isLoading,
    error,
    mutate,
  };
}
