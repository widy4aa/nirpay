'use client';

import { useState } from 'react';
import { useKycUsers } from '@/hooks/useKycUsers';
import { useSession } from 'next-auth/react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import {
  Search,
  Eye,
  CheckCircle,
  XCircle,
  ChevronLeft,
  ChevronRight,
  FileText,
  User,
  MapPin,
} from 'lucide-react';

const kycStatusColors: Record<string, string> = {
  APPROVED: 'bg-emerald-100 text-emerald-700',
  PENDING: 'bg-amber-100 text-amber-700',
  UNVERIFIED: 'bg-gray-100 text-gray-600',
  REJECTED: 'bg-red-100 text-red-700',
};

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SelectedUserType = any;

export default function KycPage() {
  const [statusFilter, setStatusFilter] = useState<string>('UNVERIFIED');
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [selectedUser, setSelectedUser] = useState<SelectedUserType>(null);
  const [detailOpen, setDetailOpen] = useState(false);
  const [rejectOpen, setRejectOpen] = useState(false);
  const [rejectReason, setRejectReason] = useState('');
  const [actionLoading, setActionLoading] = useState(false);

  const { users, total, totalPages, isLoading, mutate } = useKycUsers(statusFilter, page, 20);
  const { data: session } = useSession();

  const filteredUsers = users.filter(
    (u) =>
      u.fullName?.toLowerCase().includes(search.toLowerCase()) ||
      u.email?.toLowerCase().includes(search.toLowerCase()) ||
      u.nik?.includes(search)
  );

  const handleViewDetail = (user: SelectedUserType) => {
    setSelectedUser(user);
    setDetailOpen(true);
  };

  const handleApprove = async (userId: string) => {
    setActionLoading(true);
    try {
      const res = await fetch(
        `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/admin/kyc/${userId}/approve`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${session?.user?.accessToken}`,
          },
        }
      );
      if (res.ok) {
        mutate();
        setDetailOpen(false);
        setSelectedUser(null);
      }
    } catch (error) {
      console.error('Approve failed:', error);
    } finally {
      setActionLoading(false);
    }
  };

  const handleReject = async (userId: string) => {
    setActionLoading(true);
    try {
      const res = await fetch(
        `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/admin/kyc/${userId}/reject`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${session?.user?.accessToken}`,
          },
          body: JSON.stringify({ reason: rejectReason }),
        }
      );
      if (res.ok) {
        mutate();
        setRejectOpen(false);
        setDetailOpen(false);
        setSelectedUser(null);
        setRejectReason('');
      }
    } catch (error) {
      console.error('Reject failed:', error);
    } finally {
      setActionLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h2 className="text-2xl font-bold text-gray-900">KYC Review</h2>
        <p className="text-sm text-gray-500">
          Review and verify user identity documents
        </p>
      </div>

      {/* Filters */}
      <Card className="rounded-xl border-gray-200">
        <CardContent className="p-4">
          <div className="flex items-center gap-4">
            <div className="relative flex-1 max-w-sm">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
              <Input
                placeholder="Search by name, email, or NIK..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="pl-10"
              />
            </div>
            <Select
              value={statusFilter}
              onValueChange={(value) => {
                setStatusFilter(value || 'all');
                setPage(1);
              }}
            >
              <SelectTrigger className="w-48">
                <SelectValue placeholder="KYC Status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Status</SelectItem>
                <SelectItem value="UNVERIFIED">Unverified</SelectItem>
                <SelectItem value="PENDING">Pending</SelectItem>
                <SelectItem value="APPROVED">Approved</SelectItem>
                <SelectItem value="REJECTED">Rejected</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>

      {/* Table */}
      <Card className="rounded-xl border-gray-200">
        <CardHeader className="flex flex-row items-center justify-between pb-2">
          <CardTitle className="text-lg font-semibold flex items-center gap-2">
            <FileText className="h-5 w-5 text-gray-500" />
            KYC Requests
          </CardTitle>
          <span className="text-sm text-gray-500">{total} total</span>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <LoadingSpinner />
          ) : (
            <>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead className="text-gray-500">USER</TableHead>
                    <TableHead className="text-gray-500">NIK</TableHead>
                    <TableHead className="text-gray-500">LOCATION</TableHead>
                    <TableHead className="text-gray-500">STATUS</TableHead>
                    <TableHead className="text-gray-500">DATE</TableHead>
                    <TableHead className="text-gray-500 text-right">ACTION</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredUsers.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={6} className="text-center py-8 text-gray-500">
                        No KYC requests found
                      </TableCell>
                    </TableRow>
                  ) : (
                    filteredUsers.map((user) => (
                      <TableRow key={user.id}>
                        <TableCell>
                          <div className="flex items-center gap-3">
                            <div className="h-9 w-9 rounded-full bg-emerald-100 flex items-center justify-center text-sm font-medium text-emerald-700">
                              {user.fullName?.charAt(0) || '?'}
                            </div>
                            <div>
                              <p className="font-medium text-gray-900">{user.fullName}</p>
                              <p className="text-xs text-gray-500">{user.email}</p>
                            </div>
                          </div>
                        </TableCell>
                        <TableCell className="font-mono text-sm text-gray-600">
                          {user.nik || '-'}
                        </TableCell>
                        <TableCell className="text-gray-600 text-sm">
                          {user.city && user.province ? `${user.city}, ${user.province}` : '-'}
                        </TableCell>
                        <TableCell>
                          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${kycStatusColors[user.kycStatus] || 'bg-gray-100 text-gray-600'}`}>
                            {user.kycStatus}
                          </span>
                        </TableCell>
                        <TableCell className="text-gray-500 text-sm">
                          {new Date(user.createdAt).toLocaleDateString()}
                        </TableCell>
                        <TableCell className="text-right">
                          <Button
                            variant="outline"
                            size="sm"
                            className="rounded-lg"
                            onClick={() => handleViewDetail(user)}
                          >
                            <Eye className="h-4 w-4 mr-1" />
                            Review
                          </Button>
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>

              {/* Pagination */}
              {totalPages > 1 && (
                <div className="flex items-center justify-between mt-4 pt-4 border-t border-gray-100">
                  <p className="text-sm text-gray-500">
                    Page {page} of {totalPages}
                  </p>
                  <div className="flex items-center gap-2">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => setPage(Math.max(1, page - 1))}
                      disabled={page === 1}
                    >
                      <ChevronLeft className="h-4 w-4" />
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => setPage(Math.min(totalPages, page + 1))}
                      disabled={page === totalPages}
                    >
                      <ChevronRight className="h-4 w-4" />
                    </Button>
                  </div>
                </div>
              )}
            </>
          )}
        </CardContent>
      </Card>

      {/* Detail Dialog */}
      <Dialog open={detailOpen} onOpenChange={setDetailOpen}>
        <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>KYC Review — {selectedUser?.fullName}</DialogTitle>
          </DialogHeader>

          {selectedUser && (
            <div className="space-y-6">
              {/* User Info */}
              <div className="flex items-center gap-4">
                <div className="h-12 w-12 rounded-full bg-emerald-100 flex items-center justify-center text-lg font-bold text-emerald-700">
                  {selectedUser.fullName?.charAt(0)}
                </div>
                <div>
                  <p className="font-semibold text-gray-900">{selectedUser.fullName}</p>
                  <p className="text-sm text-gray-500">{selectedUser.email}</p>
                </div>
                <Badge className={kycStatusColors[selectedUser.kycStatus] || 'bg-gray-100'}>
                  {selectedUser.kycStatus}
                </Badge>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* KTP Photo */}
                <div>
                  <h4 className="text-sm font-medium text-gray-500 mb-2 flex items-center gap-2">
                    <FileText className="h-4 w-4" />
                    KTP Photo
                  </h4>
                  {selectedUser.ktpPhotoUrl ? (
                    <div className="border border-gray-200 rounded-lg overflow-hidden">
                      <img
                        src={`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}${selectedUser.ktpPhotoUrl}`}
                        alt="KTP"
                        className="w-full h-48 object-cover"
                        onError={(e) => {
                          (e.target as HTMLImageElement).src = 'https://placehold.co/400x200?text=KTP+Not+Available';
                        }}
                      />
                    </div>
                  ) : (
                    <div className="border border-gray-200 rounded-lg h-48 flex items-center justify-center bg-gray-50">
                      <p className="text-gray-400 text-sm">No KTP uploaded</p>
                    </div>
                  )}
                </div>

                {/* Selfie Photo */}
                <div>
                  <h4 className="text-sm font-medium text-gray-500 mb-2 flex items-center gap-2">
                    <User className="h-4 w-4" />
                    Selfie Photo
                  </h4>
                  {selectedUser.kycFaceUrl ? (
                    <div className="border border-gray-200 rounded-lg overflow-hidden">
                      <img
                        src={`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}${selectedUser.kycFaceUrl}`}
                        alt="Selfie"
                        className="w-full h-48 object-cover"
                        onError={(e) => {
                          (e.target as HTMLImageElement).src = 'https://placehold.co/400x200?text=Selfie+Not+Available';
                        }}
                      />
                    </div>
                  ) : (
                    <div className="border border-gray-200 rounded-lg h-48 flex items-center justify-center bg-gray-50">
                      <p className="text-gray-400 text-sm">No selfie uploaded</p>
                    </div>
                  )}
                </div>
              </div>

              {/* Identity Details */}
              <div>
                <h4 className="text-sm font-medium text-gray-500 mb-3 flex items-center gap-2">
                  <User className="h-4 w-4" />
                  Identity Details
                </h4>
                <div className="grid grid-cols-2 gap-4 bg-gray-50 rounded-lg p-4">
                  <div>
                    <p className="text-xs text-gray-500">Full Name</p>
                    <p className="text-sm font-medium text-gray-900">{selectedUser.fullName}</p>
                  </div>
                  <div>
                    <p className="text-xs text-gray-500">NIK</p>
                    <p className="text-sm font-mono text-gray-900">{selectedUser.nik || '-'}</p>
                  </div>
                  <div>
                    <p className="text-xs text-gray-500">Email</p>
                    <p className="text-sm text-gray-900">{selectedUser.email}</p>
                  </div>
                  <div>
                    <p className="text-xs text-gray-500">Username</p>
                    <p className="text-sm text-gray-900">@{selectedUser.username}</p>
                  </div>
                </div>
              </div>

              {/* Address */}
              <div>
                <h4 className="text-sm font-medium text-gray-500 mb-3 flex items-center gap-2">
                  <MapPin className="h-4 w-4" />
                  Address
                </h4>
                <div className="bg-gray-50 rounded-lg p-4">
                  <p className="text-sm text-gray-900">
                    {[
                      selectedUser.village,
                      selectedUser.district,
                      selectedUser.city,
                      selectedUser.province,
                    ]
                      .filter(Boolean)
                      .join(', ')}
                  </p>
                  <p className="text-sm text-gray-600 mt-1">
                    {selectedUser.rt && selectedUser.rw
                      ? `RT ${selectedUser.rt} / RW ${selectedUser.rw}`
                      : ''}
                    {selectedUser.postalCode ? ` — ${selectedUser.postalCode}` : ''}
                  </p>
                </div>
              </div>

              {/* Reject Reason (if rejected) */}
              {selectedUser.kycRejectReason && (
                <div className="bg-red-50 border border-red-200 rounded-lg p-4">
                  <p className="text-sm font-medium text-red-700">Rejection Reason</p>
                  <p className="text-sm text-red-600 mt-1">{selectedUser.kycRejectReason}</p>
                </div>
              )}
            </div>
          )}

          <DialogFooter className="gap-2">
            {selectedUser?.kycStatus !== 'APPROVED' && (
              <>
                <Button
                  variant="outline"
                  className="rounded-lg text-red-600 border-red-300 hover:bg-red-50"
                  onClick={() => setRejectOpen(true)}
                  disabled={actionLoading}
                >
                  <XCircle className="h-4 w-4 mr-2" />
                  Reject
                </Button>
                <Button
                  className="rounded-lg bg-emerald-600 hover:bg-emerald-700"
                  onClick={() => handleApprove(selectedUser.id)}
                  disabled={actionLoading}
                >
                  <CheckCircle className="h-4 w-4 mr-2" />
                  {actionLoading ? 'Processing...' : 'Approve'}
                </Button>
              </>
            )}
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Reject Dialog */}
      <Dialog open={rejectOpen} onOpenChange={setRejectOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Reject KYC</DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            <p className="text-sm text-gray-500">
              Please provide a reason for rejecting <strong>{selectedUser?.fullName}&apos;s</strong> KYC submission.
            </p>
            <Textarea
              placeholder="e.g., Foto KTP tidak jelas, NIK tidak terbaca..."
              value={rejectReason}
              onChange={(e) => setRejectReason(e.target.value)}
              rows={4}
            />
          </div>
          <DialogFooter className="gap-2">
            <Button
              variant="outline"
              onClick={() => {
                setRejectOpen(false);
                setRejectReason('');
              }}
            >
              Cancel
            </Button>
            <Button
              variant="destructive"
              onClick={() => handleReject(selectedUser?.id)}
              disabled={!rejectReason.trim() || actionLoading}
            >
              {actionLoading ? 'Processing...' : 'Reject KYC'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
