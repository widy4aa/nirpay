'use client';

import { useDashboardStats } from '@/hooks/useDashboardStats';
import { StatCard } from '@/components/shared/StatCard';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';

export default function DashboardPage() {
  const { stats, isLoading, error } = useDashboardStats();

  if (isLoading) return <LoadingSpinner />;
  if (error) return <div className="text-red-500">Failed to load stats</div>;

  return (
    <div className="space-y-6">
      <h2 className="text-2xl font-bold text-gray-900">Dashboard Overview</h2>
      <div className="grid gap-4 md:grid-cols-3">
        <StatCard
          title="Total Users"
          value={stats?.totalUsers ?? 0}
        />
        <StatCard
          title="Total Transactions"
          value={stats?.totalTransactions ?? 0}
        />
        <StatCard
          title="Total Volume"
          value={`Rp ${((stats?.totalVolume ?? 0) / 100).toLocaleString()}`}
        />
      </div>
    </div>
  );
}
