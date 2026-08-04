'use client';

import Link from 'next/link';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { buttonVariants } from '@/components/ui/button';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { useDashboardStats } from '@/hooks/useDashboardStats';
import { usePendingKyc } from '@/hooks/usePendingKyc';
import { useActivity } from '@/hooks/useActivity';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import {
  Users,
  ArrowRightLeft,
  Coins,
  TrendingUp,
  TrendingDown,
  Activity,
  CircleCheck,
  ShieldCheck,
  AlertTriangle,
} from 'lucide-react';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
} from 'recharts';

const activityIcons: Record<string, React.ElementType> = {
  LOGIN: CircleCheck,
  REGISTER: Users,
  KYC_APPROVED: ShieldCheck,
  KYC_REJECTED: AlertTriangle,
  MINT: Coins,
  FREEZE: AlertTriangle,
  DEFAULT: Activity,
};

const activityColors: Record<string, string> = {
  LOGIN: 'text-emerald-500',
  REGISTER: 'text-blue-500',
  KYC_APPROVED: 'text-emerald-500',
  KYC_REJECTED: 'text-red-500',
  MINT: 'text-purple-500',
  FREEZE: 'text-amber-500',
  DEFAULT: 'text-gray-500',
};

function timeAgo(dateStr: string) {
  const diff = Date.now() - new Date(dateStr).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins} min ago`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  return `${days}d ago`;
}

export default function DashboardPage() {
  const { stats, isLoading: statsLoading } = useDashboardStats();
  const { users: pendingKycUsers, total: pendingKycTotal, isLoading: kycLoading } = usePendingKyc();
  const { activities, isLoading: activityLoading } = useActivity();

  if (statsLoading) return <LoadingSpinner />;

  const statCards = [
    {
      title: 'Total Users',
      value: stats?.totalUsers?.toLocaleString() ?? '0',
      icon: Users,
      trend: { value: 12, label: 'this month', up: true },
    },
    {
      title: 'Total Transactions',
      value: stats?.totalTransactions?.toLocaleString() ?? '0',
      icon: ArrowRightLeft,
      trend: { value: 0, label: 'no data yet', up: false },
    },
    {
      title: 'Volume',
      value: `Rp ${((stats?.totalVolume ?? 0) / 100).toLocaleString()}`,
      icon: Coins,
      trend: { value: 0, label: 'no data yet', up: false },
    },
    {
      title: 'Pending KYC',
      value: stats?.pendingKyc?.toLocaleString() ?? '0',
      icon: ShieldCheck,
      trend: { value: 0, label: 'awaiting review', up: false },
    },
  ];

  const userDistribution = [
    { name: 'Active Users', value: stats?.activeUsers ?? 0, color: '#10b981' },
    { name: 'Inactive Users', value: stats?.inactiveUsers ?? 0, color: '#e5e7eb' },
  ];

  const totalDist = (stats?.activeUsers ?? 0) + (stats?.inactiveUsers ?? 0);
  const activePct = totalDist > 0 ? Math.round(((stats?.activeUsers ?? 0) / totalDist) * 100) : 0;

  // Placeholder chart data (Sprint 2: connect ke Transaction model)
  const transactionData = [
    { day: 'Mon', value: 0 },
    { day: 'Tue', value: 0 },
    { day: 'Wed', value: 0 },
    { day: 'Thu', value: 0 },
    { day: 'Fri', value: 0 },
    { day: 'Sat', value: 0 },
    { day: 'Sun', value: 0 },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Dashboard Overview</h2>
          <p className="text-sm text-gray-500">
            Real-time enterprise-wide financial performance and system health.
          </p>
        </div>
      </div>

      {/* Stat Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {statCards.map((card) => (
          <Card key={card.title} className="rounded-xl border-gray-200">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-gray-500">{card.title}</p>
                  <p className="text-3xl font-bold text-gray-900 mt-1">{card.value}</p>
                </div>
                <div className="h-10 w-10 bg-gray-100 rounded-lg flex items-center justify-center">
                  <card.icon className="h-5 w-5 text-gray-600" />
                </div>
              </div>
              <div className="flex items-center mt-3 text-xs">
                {card.trend.up ? (
                  <TrendingUp className="h-3 w-3 text-emerald-500 mr-1" />
                ) : (
                  <TrendingDown className="h-3 w-3 text-gray-400 mr-1" />
                )}
                <span className={card.trend.up ? 'text-emerald-600 font-medium' : 'text-gray-500'}>
                  {card.trend.up ? '+' : ''}{card.trend.value}%
                </span>
                <span className="text-gray-400 ml-1">{card.trend.label}</span>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Transaction Volume */}
        <Card className="lg:col-span-2 rounded-xl border-gray-200">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-lg font-semibold">Transaction Volume</CardTitle>
            <div className="flex items-center gap-2 text-sm text-gray-500">
              <div className="h-3 w-3 rounded-full bg-emerald-500" />
              Total Value
            </div>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={transactionData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis dataKey="day" stroke="#9ca3af" fontSize={12} />
                <YAxis stroke="#9ca3af" fontSize={12} />
                <Tooltip />
                <Line type="monotone" dataKey="value" stroke="#10b981" strokeWidth={2} dot={false} />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* User Distribution */}
        <Card className="rounded-xl border-gray-200">
          <CardHeader>
            <CardTitle className="text-lg font-semibold">User Distribution</CardTitle>
          </CardHeader>
          <CardContent className="flex flex-col items-center">
            <div className="relative w-48 h-48">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie data={userDistribution} cx="50%" cy="50%" innerRadius={60} outerRadius={80} dataKey="value" strokeWidth={0}>
                    {userDistribution.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                </PieChart>
              </ResponsiveContainer>
              <div className="absolute inset-0 flex items-center justify-center">
                <div className="text-center">
                  <p className="text-2xl font-bold text-gray-900">{activePct}%</p>
                  <p className="text-xs text-gray-500">ACTIVE</p>
                </div>
              </div>
            </div>
            <div className="flex gap-6 mt-4 text-sm">
              <div className="flex items-center gap-2">
                <div className="h-3 w-3 rounded-full bg-emerald-500" />
                <span className="text-gray-600">Active</span>
                <span className="font-semibold">{stats?.activeUsers ?? 0}</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="h-3 w-3 rounded-full bg-gray-200" />
                <span className="text-gray-600">Inactive</span>
                <span className="font-semibold">{stats?.inactiveUsers ?? 0}</span>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Bottom Row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Pending KYC */}
        <Card className="lg:col-span-2 rounded-xl border-gray-200">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-lg font-semibold">
              Pending KYC {pendingKycTotal > 0 && `(${pendingKycTotal})`}
            </CardTitle>
            <Link 
              href="/kyc" 
              className={buttonVariants({ variant: 'ghost', size: 'sm', className: 'text-emerald-600 hover:text-emerald-700' })}
            >
              View All
            </Link>
          </CardHeader>
          <CardContent>
            {kycLoading ? (
              <LoadingSpinner />
            ) : pendingKycUsers.length === 0 ? (
              <p className="text-sm text-gray-500 text-center py-8">No pending KYC requests</p>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead className="text-gray-500">USER</TableHead>
                    <TableHead className="text-gray-500">NIK</TableHead>
                    <TableHead className="text-gray-500">DATE</TableHead>
                    <TableHead className="text-gray-500 text-right">ACTION</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {pendingKycUsers.map((user) => (
                    <TableRow key={user.id}>
                      <TableCell>
                        <div className="flex items-center gap-3">
                          <div className="h-8 w-8 rounded-full bg-gray-100 flex items-center justify-center text-sm font-medium text-gray-600">
                            {user.fullName?.charAt(0) || '?'}
                          </div>
                          <div>
                            <p className="font-medium text-gray-900">{user.fullName}</p>
                            <p className="text-xs text-gray-500">{user.email}</p>
                          </div>
                        </div>
                      </TableCell>
                      <TableCell className="text-gray-500 font-mono text-sm">{user.nik}</TableCell>
                      <TableCell className="text-gray-500">
                        {new Date(user.createdAt).toLocaleDateString()}
                      </TableCell>
                      <TableCell className="text-right">
                        <Link 
                          href="/kyc" 
                          className={buttonVariants({ variant: 'outline', size: 'sm', className: 'rounded-lg' })}
                        >
                          Review
                        </Link>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </CardContent>
        </Card>

        {/* Live Activity */}
        <Card className="rounded-xl border-gray-200">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-lg font-semibold">Live Activity</CardTitle>
            <Badge variant="outline" className="text-emerald-600 border-emerald-200 bg-emerald-50">
              REAL-TIME
            </Badge>
          </CardHeader>
          <CardContent className="space-y-4">
            {activityLoading ? (
              <LoadingSpinner />
            ) : activities.length === 0 ? (
              <p className="text-sm text-gray-500 text-center py-8">No activity yet</p>
            ) : (
              activities.map((item) => {
                const Icon = activityIcons[item.eventType] || activityIcons.DEFAULT;
                const color = activityColors[item.eventType] || activityColors.DEFAULT;
                return (
                  <div key={item.id} className="flex gap-3">
                    <div className="mt-0.5">
                      <Icon className={`h-5 w-5 ${color}`} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-900">{item.eventType.replace(/_/g, ' ')}</p>
                      <p className="text-xs text-gray-500 truncate">
                        {(typeof item.detail?.email === 'string' ? item.detail.email : null) || item.resourceType || 'System event'}
                      </p>
                    </div>
                    <span className="text-xs text-gray-400 whitespace-nowrap">
                      {timeAgo(item.createdAt)}
                    </span>
                  </div>
                );
              })
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
