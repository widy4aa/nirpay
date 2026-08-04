'use client';

import Link from 'next/link';
import Image from 'next/image';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import {
  LayoutDashboard,
  Users,
  ShieldCheck,
  BookOpen,
  Snowflake,
  Settings,
  ArrowLeftRight,
  AlertTriangle,
  FileWarning,
  Coins,
} from 'lucide-react';

const mainNav = [
  { title: 'Dashboard', href: '/', icon: LayoutDashboard },
  { title: 'Users', href: '/users', icon: Users },
  { title: 'KYC', href: '/kyc', icon: ShieldCheck },
  { title: 'Ledger', href: '/ledger', icon: BookOpen },
];

const operationsNav = [
  { title: 'Freeze', href: '/operations/freeze', icon: Snowflake },
  { title: 'Balance Adjustment', href: '/operations/adjustment', icon: Settings },
  { title: 'Claims', href: '/operations/claims', icon: ArrowLeftRight },
  { title: 'Disputes', href: '/operations/disputes', icon: AlertTriangle },
  { title: 'Anomalies', href: '/operations/anomalies', icon: FileWarning },
  { title: 'Manual Mint', href: '/operations/mint', icon: Coins },
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="w-64 bg-white border-r border-gray-200 h-screen flex flex-col">
      <div className="p-6 border-b border-gray-200">
        <div className="flex items-center gap-3">
          <Image
            src="/logo.png"
            alt="Nirpay Logo"
            width={36}
            height={36}
            className="rounded-lg object-contain"
          />
          <span className="font-bold text-xl text-gray-900">NirPay Admin</span>
        </div>
      </div>

      <nav className="flex-1 overflow-y-auto p-4 space-y-6">
        <div>
          {mainNav.map((item) => {
            const isActive = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  'flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors mb-1',
                  isActive
                    ? 'bg-emerald-50 text-emerald-700'
                    : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                )}
              >
                <item.icon className="h-4 w-4" />
                {item.title}
              </Link>
            );
          })}
        </div>

        <div>
          <p className="px-3 text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2">
            Operations
          </p>
          {operationsNav.map((item) => {
            const isActive = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  'flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors mb-1',
                  isActive
                    ? 'bg-emerald-50 text-emerald-700'
                    : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                )}
              >
                <item.icon className="h-4 w-4" />
                {item.title}
              </Link>
            );
          })}
        </div>
      </nav>

      <div className="p-4 border-t border-gray-200">
        <Link
          href="/settings"
          className="flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium text-gray-600 hover:bg-gray-50 hover:text-gray-900"
        >
          <Settings className="h-4 w-4" />
          Configuration
        </Link>
      </div>
    </aside>
  );
}
