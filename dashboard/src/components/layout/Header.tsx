'use client';

import { useSession, signOut } from 'next-auth/react';
import { Button } from '@/components/ui/button';

export function Header() {
  const { data: session } = useSession();

  return (
    <header className="h-16 bg-white border-b border-gray-200 flex items-center justify-between px-6">
      <h1 className="text-xl font-semibold text-gray-800">
        Admin Dashboard
      </h1>
      <div className="flex items-center gap-4">
        <div className="text-sm">
          <span className="text-gray-500 mr-2">Logged in as</span>
          <span className="font-medium text-gray-900">
            {session?.user?.email || 'Admin'}
          </span>
        </div>
        <Button variant="outline" size="sm" onClick={() => signOut()}>
          Logout
        </Button>
      </div>
    </header>
  );
}
