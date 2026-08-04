'use client';

import { useParams, useRouter } from 'next/navigation';
import { useUserDetail } from '@/hooks/useUserDetail';
import { useSession } from 'next-auth/react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button, buttonVariants } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Separator } from '@/components/ui/separator';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from '@/components/ui/alert-dialog';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import {
  Edit,
  Ban,
  RefreshCw,
  Mail,
  Download,
  Trash2,
  Smartphone,
  MapPin,
  Calendar,
  Shield,
  Wallet,
  ArrowUpDown,
} from 'lucide-react';
import { useState } from 'react';

const kycStatusColors: Record<string, string> = {
  APPROVED: 'bg-emerald-100 text-emerald-700',
  PENDING: 'bg-amber-100 text-amber-700',
  UNVERIFIED: 'bg-gray-100 text-gray-600',
  REJECTED: 'bg-red-100 text-red-700',
};

function timeAgo(dateStr: string | null) {
  if (!dateStr) return 'Never';
  const diff = Date.now() - new Date(dateStr).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins} mins ago`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  return `${days}d ago`;
}

export default function UserDetailPage() {
  const params = useParams();
  const router = useRouter();
  const userId = params.id as string;
  const { user, isLoading, mutate } = useUserDetail(userId);
  const { data: session } = useSession();
  const [activeTab, setActiveTab] = useState('overview');

  const handleAction = async (action: string) => {
    const token = session?.user?.accessToken;
    const baseUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';

    try {
      let res: Response;

      switch (action) {
        case 'freeze':
          res = await fetch(`${baseUrl}/api/admin/users/${userId}/freeze`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${token}`,
            },
          });
          break;
        case 'unfreeze':
          res = await fetch(`${baseUrl}/api/admin/users/${userId}/unfreeze`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${token}`,
            },
          });
          break;
        case 'reset-kyc':
          res = await fetch(`${baseUrl}/api/admin/users/${userId}/reset-kyc`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${token}`,
            },
          });
          break;
        case 'terminate-sessions':
          res = await fetch(`${baseUrl}/api/admin/users/${userId}/sessions`, {
            method: 'DELETE',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${token}`,
            },
          });
          break;
        case 'delete':
          res = await fetch(`${baseUrl}/api/admin/users/${userId}`, {
            method: 'DELETE',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${token}`,
            },
          });
          if (res.ok) {
            router.push('/users');
            return;
          }
          break;
        default:
          return;
      }

      if (res && res.ok) {
        mutate(); // Refresh data
      }
    } catch (error) {
      console.error('Action failed:', error);
    }
  };

  if (isLoading) return <LoadingSpinner />;
  if (!user) return <div className="p-6 text-red-500">User not found</div>;

  const balance = user.wallet
    ? `Rp. ${(Number(user.wallet.amountCent) / 100).toLocaleString()}`
    : 'Rp. 0';

  return (
    <div className="space-y-6">
      {/* Breadcrumb */}
      <div className="flex items-center gap-2 text-sm text-gray-500">
        <button onClick={() => router.push('/users')} className="hover:text-gray-900">
          Users
        </button>
        <span>/</span>
        <span className="text-gray-900 font-medium">{user.fullName}</span>
      </div>

      {/* Profile Header */}
      <Card className="rounded-xl border-gray-200">
        <CardContent className="p-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="relative">
                <div className="h-16 w-16 rounded-full bg-emerald-100 flex items-center justify-center text-2xl font-bold text-emerald-700">
                  {user.fullName?.charAt(0) || '?'}
                </div>
                <div className={`absolute bottom-0 right-0 h-4 w-4 rounded-full border-2 border-white ${user.isActive && !user.isLocked ? 'bg-emerald-500' : 'bg-red-500'}`} />
              </div>
              <div>
                <div className="flex items-center gap-3">
                  <h2 className="text-2xl font-bold text-gray-900">{user.fullName}</h2>
                  <Badge className={kycStatusColors[user.kycStatus] || 'bg-gray-100'}>
                    {user.isLocked ? 'FROZEN' : user.isActive ? 'ACTIVE' : 'INACTIVE'}
                  </Badge>
                </div>
                <p className="text-sm text-gray-500">
                  UID: {user.id.slice(0, 8).toUpperCase()}...
                </p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <Button variant="outline" className="rounded-lg">
                <Edit className="h-4 w-4 mr-2" />
                Edit Profile
              </Button>
              {user.isLocked ? (
                <Button
                  variant="outline"
                  className="rounded-lg text-emerald-600 border-emerald-300 hover:bg-emerald-50"
                  onClick={() => handleAction('unfreeze')}
                >
                  <RefreshCw className="h-4 w-4 mr-2" />
                  Unfreeze Account
                </Button>
              ) : (
                <AlertDialog>
                  <AlertDialogTrigger className={buttonVariants({ variant: 'destructive', className: 'rounded-lg cursor-pointer' })}>
                    <Ban className="h-4 w-4 mr-2" />
                    Freeze Account
                  </AlertDialogTrigger>
                  <AlertDialogContent>
                    <AlertDialogHeader>
                      <AlertDialogTitle>Freeze Account?</AlertDialogTitle>
                      <AlertDialogDescription>
                        This will lock the user&apos;s account and terminate all active sessions. The user will not be able to login until unfrozen.
                      </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                      <AlertDialogCancel>Cancel</AlertDialogCancel>
                      <AlertDialogAction
                        onClick={() => handleAction('freeze')}
                        className="bg-red-600 hover:bg-red-700"
                      >
                        Yes, Freeze
                      </AlertDialogAction>
                    </AlertDialogFooter>
                  </AlertDialogContent>
                </AlertDialog>
              )}
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Stat Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card className="rounded-xl border-gray-200">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-500">Total Balance</p>
                <p className="text-2xl font-bold text-gray-900 mt-1">{balance}</p>
                <p className="text-xs text-gray-400 mt-1">Updated {timeAgo(user.wallet ? new Date().toISOString() : null)}</p>
              </div>
              <div className="h-10 w-10 bg-emerald-100 rounded-lg flex items-center justify-center">
                <Wallet className="h-5 w-5 text-emerald-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="rounded-xl border-gray-200">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-500">Total Transactions</p>
                <p className="text-2xl font-bold text-gray-900 mt-1">{user.totalTransactions}</p>
                <p className="text-xs text-gray-400 mt-1">Last 30 days</p>
              </div>
              <div className="h-10 w-10 bg-blue-100 rounded-lg flex items-center justify-center">
                <ArrowUpDown className="h-5 w-5 text-blue-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="rounded-xl border-gray-200">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-500">Risk Score</p>
                <p className={`text-2xl font-bold mt-1 ${user.riskScore < 0.3 ? 'text-emerald-600' : user.riskScore < 0.7 ? 'text-amber-600' : 'text-red-600'}`}>
                  {user.riskScore < 0.3 ? 'Low' : user.riskScore < 0.7 ? 'Medium' : 'High'} ({user.riskScore})
                </p>
                <p className="text-xs text-gray-400 mt-1">Institutional Grade</p>
              </div>
              <div className="h-10 w-10 bg-purple-100 rounded-lg flex items-center justify-center">
                <Shield className="h-5 w-5 text-purple-600" />
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Main Content + Sidebar */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left: Tabs */}
        <div className="lg:col-span-2">
          <Card className="rounded-xl border-gray-200">
            <CardContent className="p-0">
              <Tabs value={activeTab} onValueChange={setActiveTab}>
                <TabsList className="w-full justify-start rounded-none border-b border-gray-200 bg-transparent h-12 px-6">
                  <TabsTrigger value="overview" className="rounded-none data-[state=active]:border-b-2 data-[state=active]:border-emerald-600 data-[state=active]:text-emerald-600 data-[state=active]:shadow-none">
                    Overview
                  </TabsTrigger>
                  <TabsTrigger value="transactions" className="rounded-none data-[state=active]:border-b-2 data-[state=active]:border-emerald-600 data-[state=active]:text-emerald-600 data-[state=active]:shadow-none">
                    Transactions
                  </TabsTrigger>
                  <TabsTrigger value="chains" className="rounded-none data-[state=active]:border-b-2 data-[state=active]:border-emerald-600 data-[state=active]:text-emerald-600 data-[state=active]:shadow-none">
                    Chains
                  </TabsTrigger>
                  <TabsTrigger value="hop" className="rounded-none data-[state=active]:border-b-2 data-[state=active]:border-emerald-600 data-[state=active]:text-emerald-600 data-[state=active]:shadow-none">
                    Hop History
                  </TabsTrigger>
                </TabsList>

                {/* Overview Tab */}
                <TabsContent value="overview" className="p-6">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                    {/* Profile Details */}
                    <div>
                      <h3 className="text-lg font-semibold text-gray-900 mb-4">Profile Details</h3>
                      <div className="space-y-3">
                        <div className="flex justify-between border-b border-gray-100 pb-3">
                          <span className="text-gray-500">Full Name</span>
                          <span className="font-medium text-gray-900">{user.fullName}</span>
                        </div>
                        <div className="flex justify-between border-b border-gray-100 pb-3">
                          <span className="text-gray-500">Email</span>
                          <span className="font-medium text-gray-900">{user.email}</span>
                        </div>
                        <div className="flex justify-between border-b border-gray-100 pb-3">
                          <span className="text-gray-500">Phone</span>
                          <span className="font-medium text-gray-900">{user.phoneNumber || '-'}</span>
                        </div>
                        <div className="flex justify-between border-b border-gray-100 pb-3">
                          <span className="text-gray-500">NIK</span>
                          <span className="font-mono text-sm text-gray-900">{user.nik || '-'}</span>
                        </div>
                        <div className="flex justify-between border-b border-gray-100 pb-3">
                          <span className="text-gray-500">Location</span>
                          <span className="font-medium text-gray-900">
                            {user.city && user.province ? `${user.city}, ${user.province}` : '-'}
                          </span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-500">Joined</span>
                          <span className="font-medium text-gray-900">
                            {new Date(user.createdAt).toLocaleDateString('en-US', {
                              month: 'short',
                              day: 'numeric',
                              year: 'numeric',
                            })}
                          </span>
                        </div>
                      </div>
                    </div>

                    {/* Security Settings */}
                    <div>
                      <h3 className="text-lg font-semibold text-gray-900 mb-4">Security Settings</h3>
                      <div className="space-y-3">
                        <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                          <div className="flex items-center gap-3">
                            <div className="h-8 w-8 bg-emerald-100 rounded-lg flex items-center justify-center">
                              <Shield className="h-4 w-4 text-emerald-600" />
                            </div>
                            <div>
                              <p className="text-sm font-medium text-gray-900">Hardware Key</p>
                              <p className="text-xs text-gray-500">
                                {user.kycFaceUrl ? 'Ed25519 Registered' : 'Not registered'}
                              </p>
                            </div>
                          </div>
                        </div>
                        <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                          <div className="flex items-center gap-3">
                            <div className="h-8 w-8 bg-blue-100 rounded-lg flex items-center justify-center">
                              <Calendar className="h-4 w-4 text-blue-600" />
                            </div>
                            <div>
                              <p className="text-sm font-medium text-gray-900">Last Login</p>
                              <p className="text-xs text-gray-500">{timeAgo(user.lastLoginAt)}</p>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </TabsContent>

                {/* Transactions Tab (Placeholder) */}
                <TabsContent value="transactions" className="p-6">
                  <div className="text-center py-12 text-gray-500">
                    <ArrowUpDown className="h-12 w-12 mx-auto mb-4 text-gray-300" />
                    <p className="font-medium">No transactions yet</p>
                    <p className="text-sm">Transaction history will appear here once the user starts transacting.</p>
                  </div>
                </TabsContent>

                {/* Chains Tab (Placeholder) */}
                <TabsContent value="chains" className="p-6">
                  <div className="text-center py-12 text-gray-500">
                    <RefreshCw className="h-12 w-12 mx-auto mb-4 text-gray-300" />
                    <p className="font-medium">No chains yet</p>
                    <p className="text-sm">Chain history will appear here.</p>
                  </div>
                </TabsContent>

                {/* Hop History Tab (Placeholder) */}
                <TabsContent value="hop" className="p-6">
                  <div className="text-center py-12 text-gray-500">
                    <MapPin className="h-12 w-12 mx-auto mb-4 text-gray-300" />
                    <p className="font-medium">No hop history yet</p>
                    <p className="text-sm">Hop history will appear here.</p>
                  </div>
                </TabsContent>
              </Tabs>
            </CardContent>
          </Card>
        </div>

        {/* Right: Quick Actions + Sessions */}
        <div className="space-y-6">
          {/* Quick Actions */}
          <Card className="rounded-xl border-gray-200">
            <CardHeader className="pb-3">
              <CardTitle className="text-lg font-semibold flex items-center gap-2">
                <span className="text-emerald-500">⚡</span> Quick Actions
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <Button variant="outline" className="w-full justify-start rounded-lg">
                <Wallet className="h-4 w-4 mr-3" />
                Balance Adjustment
              </Button>
              <Button
                variant="outline"
                className="w-full justify-start rounded-lg"
                onClick={() => handleAction('reset-kyc')}
              >
                <RefreshCw className="h-4 w-4 mr-3" />
                Reset KYC Status
              </Button>
              <Button variant="outline" className="w-full justify-start rounded-lg">
                <Mail className="h-4 w-4 mr-3" />
                Send Manual Email
              </Button>
              <Button variant="outline" className="w-full justify-start rounded-lg">
                <Download className="h-4 w-4 mr-3" />
                Export Data Log
              </Button>
              <Separator className="my-2" />
              <AlertDialog>
                <AlertDialogTrigger className={buttonVariants({ variant: 'outline', className: 'w-full justify-start rounded-lg text-red-600 border-red-200 hover:bg-red-50 cursor-pointer' })}>
                  <Trash2 className="h-4 w-4 mr-3" />
                  Delete User Record
                </AlertDialogTrigger>
                <AlertDialogContent>
                  <AlertDialogHeader>
                    <AlertDialogTitle>Delete User Record?</AlertDialogTitle>
                    <AlertDialogDescription>
                      This action cannot be undone. This will permanently delete <strong>{user.email}</strong> and all associated data.
                    </AlertDialogDescription>
                  </AlertDialogHeader>
                  <AlertDialogFooter>
                    <AlertDialogCancel>Cancel</AlertDialogCancel>
                    <AlertDialogAction
                      onClick={() => handleAction('delete')}
                      className="bg-red-600 hover:bg-red-700"
                    >
                      Yes, Delete
                    </AlertDialogAction>
                  </AlertDialogFooter>
                </AlertDialogContent>
              </AlertDialog>
            </CardContent>
          </Card>

          {/* Device Sessions */}
          <Card className="rounded-xl border-gray-200">
            <CardHeader className="flex flex-row items-center justify-between pb-3">
              <CardTitle className="text-lg font-semibold">Device Sessions</CardTitle>
              {user.sessions.length > 0 && (
                <Button
                  variant="ghost"
                  size="sm"
                  className="text-red-600 hover:text-red-700 text-xs"
                  onClick={() => handleAction('terminate-sessions')}
                >
                  TERMINATE ALL
                </Button>
              )}
            </CardHeader>
            <CardContent className="space-y-3">
              {user.sessions.length === 0 ? (
                <p className="text-sm text-gray-500 text-center py-4">No active sessions</p>
              ) : (
                user.sessions.map((session) => (
                  <div key={session.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                    <div className="flex items-center gap-3">
                      <Smartphone className="h-5 w-5 text-gray-400" />
                      <div>
                        <p className="text-sm font-medium text-gray-900">
                          {session.deviceName || 'Unknown Device'}
                        </p>
                        <p className="text-xs text-gray-500">
                          {session.ipAddress || 'Unknown IP'} • Online
                        </p>
                      </div>
                    </div>
                  </div>
                ))
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
