'use client';

import useSWR from 'swr';
import { useSession } from 'next-auth/react';

interface Activity {
  id: string;
  actorId: string | null;
  actorRole: string | null;
  eventType: string;
  resourceType: string | null;
  detail: Record<string, unknown> | null;
  createdAt: string;
}

interface ActivityResponse {
  activities: Activity[];
  meta: { total: number; page: number; limit: number; totalPages: number };
}

export function useActivity() {
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

  const { data, error, isLoading } = useSWR<ActivityResponse>(
    session?.user?.accessToken
      ? `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/admin/activity?limit=5`
      : null,
    fetcher
  );

  return { activities: data?.activities ?? [], isLoading, error };
}
