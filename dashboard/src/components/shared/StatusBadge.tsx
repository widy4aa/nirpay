import { Badge } from '@/components/ui/badge';

type StatusType = 'UNVERIFIED' | 'PENDING' | 'APPROVED' | 'REJECTED' | 'USER' | 'ADMIN' | 'SUPER_ADMIN';

const statusConfig: Record<StatusType, { label: string; variant: 'default' | 'secondary' | 'destructive' | 'outline' }> = {
  UNVERIFIED: { label: 'Unverified', variant: 'secondary' },
  PENDING: { label: 'Pending', variant: 'outline' },
  APPROVED: { label: 'Approved', variant: 'default' },
  REJECTED: { label: 'Rejected', variant: 'destructive' },
  USER: { label: 'User', variant: 'secondary' },
  ADMIN: { label: 'Admin', variant: 'default' },
  SUPER_ADMIN: { label: 'Super Admin', variant: 'default' },
};

export function StatusBadge({ status }: { status: string }) {
  const config = statusConfig[status as StatusType] || { label: status, variant: 'secondary' as const };
  return <Badge variant={config.variant}>{config.label}</Badge>;
}
