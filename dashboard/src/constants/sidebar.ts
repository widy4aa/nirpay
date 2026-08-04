export interface NavItem {
  title: string;
  href: string;
  icon: string;
  badge?: number;
}

export const sidebarItems: NavItem[] = [
  { title: 'Overview', href: '/', icon: 'LayoutDashboard' },
  { title: 'Users', href: '/users', icon: 'Users' },
  { title: 'KYC Review', href: '/kyc', icon: 'ShieldCheck' },
  { title: 'Top Up', href: '/topup', icon: 'Wallet' },
  { title: 'Withdraw', href: '/withdraw', icon: 'Banknote' },
  { title: 'Transactions', href: '/transactions', icon: 'ArrowLeftRight' },
  { title: 'Ledger', href: '/ledger', icon: 'BookOpen' },
  { title: 'Disputes', href: '/disputes', icon: 'AlertTriangle' },
  { title: 'Anomalies', href: '/anomalies', icon: 'Shield' },
];
