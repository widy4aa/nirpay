'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { sidebarItems } from '@/constants/sidebar';

export function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="w-64 bg-white border-r border-gray-200 h-screen flex flex-col">
      <div className="p-6 border-b border-gray-200 flex items-center gap-3">
        <div className="w-8 h-8 bg-blue-600 rounded-md flex items-center justify-center">
          <span className="text-white font-bold text-lg">N</span>
        </div>
        <span className="font-bold text-xl text-gray-900">Nirpay</span>
      </div>
      <nav className="flex-1 overflow-y-auto p-4 space-y-1">
        {sidebarItems.map((item) => {
          const isActive = pathname === item.href;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                isActive
                  ? 'bg-blue-50 text-blue-700'
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`}
            >
              <span>{item.title}</span>
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
