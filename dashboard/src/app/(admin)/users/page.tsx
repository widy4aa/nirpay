'use client';

import { useUsers } from '@/hooks/useUsers';
import { DataTable } from '@/components/shared/DataTable';
import { StatusBadge } from '@/components/shared/StatusBadge';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { User } from '@/types/user';

const columns = [
  { key: 'username', header: 'Username' },
  { key: 'email', header: 'Email' },
  {
    key: 'role',
    header: 'Role',
    render: (user: User) => <StatusBadge status={user.role} />,
  },
  {
    key: 'kycStatus',
    header: 'KYC Status',
    render: (user: User) => <StatusBadge status={user.kycStatus} />,
  },
  {
    key: 'createdAt',
    header: 'Created At',
    render: (user: User) => new Date(user.createdAt).toLocaleDateString(),
  },
];

export default function UsersPage() {
  const { users, isLoading, error } = useUsers();

  if (isLoading) return <LoadingSpinner />;
  if (error) return <div className="text-red-500">Failed to load users</div>;

  return (
    <div className="space-y-6">
      <h2 className="text-2xl font-bold text-gray-900">Users</h2>
      <DataTable data={users} columns={columns} emptyMessage="No users found" />
    </div>
  );
}
