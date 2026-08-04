'use client';

import { useState } from 'react';
import { usePendingTransactions, PendingTransaction } from '@/hooks/usePendingTransactions';
import { useSession } from 'next-auth/react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';

export default function WithdrawPage() {
  const { data: session } = useSession();
  const [filter, setFilter] = useState('PENDING');
  const { transactions, total, isLoading, error, mutate } = usePendingTransactions('WITHDRAW');
  const [processingId, setProcessingId] = useState<string | null>(null);

  const filteredTransactions = filter === 'all'
    ? transactions
    : transactions.filter(tx => tx.syncStatus === filter);

  const handleApprove = async (txId: string) => {
    if (!confirm('Setujui withdraw ini? Dana akan dicairkan.')) return;
    setProcessingId(txId);
    try {
      const res = await fetch(`${API_URL}/api/wallet/withdraw/${txId}/approve`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${session?.user?.accessToken}`,
        },
      });
      if (!res.ok) throw new Error('Failed to approve');
      await mutate();
      alert('Withdraw berhasil disetujui!');
    } catch (e) {
      alert('Gagal menyetujui: ' + (e as Error).message);
    } finally {
      setProcessingId(null);
    }
  };

  const handleReject = async (txId: string) => {
    const reason = prompt('Alasan penolakan:');
    if (reason === null) return;
    setProcessingId(txId);
    try {
      const res = await fetch(`${API_URL}/api/wallet/withdraw/${txId}/reject`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${session?.user?.accessToken}`,
        },
        body: JSON.stringify({ reason }),
      });
      if (!res.ok) throw new Error('Failed to reject');
      await mutate();
      alert('Withdraw ditolak. Saldo dikembalikan ke user.');
    } catch (e) {
      alert('Gagal menolak: ' + (e as Error).message);
    } finally {
      setProcessingId(null);
    }
  };

  const formatAmount = (cent: number) => {
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      minimumFractionDigits: 0,
    }).format(cent / 100);
  };

  const formatDate = (dateStr: string) => {
    return new Date(dateStr).toLocaleString('id-ID', {
      day: '2-digit',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'PENDING':
        return <Badge variant="outline" className="bg-yellow-50 text-yellow-700 border-yellow-200">Pending</Badge>;
      case 'SYNCED':
        return <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200">Disetujui</Badge>;
      case 'REJECTED':
        return <Badge variant="outline" className="bg-red-50 text-red-700 border-red-200">Ditolak</Badge>;
      default:
        return <Badge variant="outline">{status}</Badge>;
    }
  };

  const getMethodBadge = (method: string | null) => {
    if (!method) return null;
    const isBank = ['BCA', 'MANDIRI', 'BRI', 'BNI'].includes(method);
    return (
      <Badge variant="outline" className={isBank ? 'bg-blue-50 text-blue-700 border-blue-200' : 'bg-purple-50 text-purple-700 border-purple-200'}>
        {method}
      </Badge>
    );
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Withdraw</h1>
          <p className="text-muted-foreground">Kelola permintaan penarikan saldo dari pengguna</p>
        </div>
        <div className="flex gap-2">
          {['PENDING', 'SYNCED', 'REJECTED', 'all'].map((f) => (
            <Button
              key={f}
              variant={filter === f ? 'default' : 'outline'}
              size="sm"
              onClick={() => setFilter(f)}
            >
              {f === 'PENDING' ? 'Pending' : f === 'SYNCED' ? 'Disetujui' : f === 'REJECTED' ? 'Ditolak' : 'Semua'}
            </Button>
          ))}
        </div>
      </div>

      {/* Stats */}
      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Pending</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{transactions.filter(tx => tx.syncStatus === 'PENDING').length}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Disetujui</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">{transactions.filter(tx => tx.syncStatus === 'SYNCED').length}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Ditolak</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-red-600">{transactions.filter(tx => tx.syncStatus === 'REJECTED').length}</div>
          </CardContent>
        </Card>
      </div>

      {/* Transactions List */}
      <Card>
        <CardHeader>
          <CardTitle>Daftar Withdraw</CardTitle>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="text-center py-8 text-muted-foreground">Memuat...</div>
          ) : error ? (
            <div className="text-center py-8 text-red-500">Gagal memuat data</div>
          ) : filteredTransactions.length === 0 ? (
            <div className="text-center py-8 text-muted-foreground">Tidak ada transaksi</div>
          ) : (
            <div className="space-y-4">
              {filteredTransactions.map((tx) => (
                <div
                  key={tx.txId}
                  className="flex items-center justify-between p-4 border rounded-lg hover:bg-muted/50 transition-colors"
                >
                  <div className="flex-1 space-y-1">
                    <div className="flex items-center gap-2">
                      <span className="font-medium">{tx.userName}</span>
                      <span className="text-sm text-muted-foreground">({tx.userEmail})</span>
                      {getStatusBadge(tx.syncStatus)}
                      {getMethodBadge(tx.counterpartyName)}
                    </div>
                    <div className="text-sm text-muted-foreground">
                      TX: {tx.txId.substring(0, 8)}... | {formatDate(tx.createdAt)}
                    </div>
                    {tx.counterpartyId && (
                      <div className="text-sm text-muted-foreground">
                        Rekening/Akun: {tx.counterpartyId}
                      </div>
                    )}
                    {tx.rejectReason && (
                      <div className="text-sm text-red-500">
                        Alasan ditolak: {tx.rejectReason}
                      </div>
                    )}
                  </div>
                  <div className="flex items-center gap-4">
                    <div className="text-right">
                      <div className="text-lg font-bold text-red-600">
                        -{formatAmount(tx.amountCent)}
                      </div>
                    </div>
                    {tx.syncStatus === 'PENDING' && (
                      <div className="flex gap-2">
                        <Button
                          size="sm"
                          onClick={() => handleApprove(tx.txId)}
                          disabled={processingId === tx.txId}
                          className="bg-green-600 hover:bg-green-700"
                        >
                          {processingId === tx.txId ? '...' : '✓ Cairkan'}
                        </Button>
                        <Button
                          size="sm"
                          variant="destructive"
                          onClick={() => handleReject(tx.txId)}
                          disabled={processingId === tx.txId}
                        >
                          {processingId === tx.txId ? '...' : '✕ Tolak'}
                        </Button>
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
