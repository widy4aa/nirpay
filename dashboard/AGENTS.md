# AGENTS.md — Dashboard (Next.js) Coding Conventions
> **Single source of truth** untuk semua coding style di `dashboard/`.
> Wajib diikuti oleh semua agent/programmer yang kerja di folder ini.

---

## 1. Architecture: App Router + Server Components

```
dashboard/
├── src/
│   ├── app/
│   │   ├── (auth)/
│   │   │   ├── login/
│   │   │   │   └── page.tsx
│   │   │   └── layout.tsx
│   │   ├── (admin)/
│   │   │   ├── layout.tsx          # DashboardLayout (sidebar)
│   │   │   ├── page.tsx            # Overview / dashboard
│   │   │   ├── users/
│   │   │   │   ├── page.tsx        # User list
│   │   │   │   └── [id]/
│   │   │   │       └── page.tsx    # User detail
│   │   │   ├── transactions/
│   │   │   │   └── page.tsx
│   │   │   ├── ledger/
│   │   │   │   └── page.tsx
│   │   │   ├── disputes/
│   │   │   │   └── page.tsx
│   │   │   └── anomalies/
│   │   │       └── page.tsx
│   │   ├── api/
│   │   │   └── auth/
│   │   │       └── [...nextauth]/
│   │   │           └── route.ts
│   │   ├── layout.tsx              # Root layout
│   │   ├── page.tsx                # Redirect to /login or /
│   │   └── globals.css
│   ├── components/
│   │   ├── ui/                     # shadcn/ui components
│   │   │   ├── button.tsx
│   │   │   ├── card.tsx
│   │   │   ├── table.tsx
│   │   │   └── ...
│   │   ├── layout/
│   │   │   ├── DashboardLayout.tsx
│   │   │   ├── Sidebar.tsx
│   │   │   └── Header.tsx
│   │   └── shared/
│   │       ├── StatCard.tsx
│   │       ├── DataTable.tsx
│   │       ├── LoadingSpinner.tsx
│   │       └── EmptyState.tsx
│   ├── lib/
│   │   ├── api-client.ts           # Axios/fetch wrapper
│   │   ├── auth.ts                 # NextAuth config
│   │   ├── prisma.ts               # Prisma client singleton
│   │   └── utils.ts                # Utilities
│   ├── hooks/
│   │   ├── useUsers.ts             # SWR hook for users
│   │   ├── useTransactions.ts
│   │   └── useDashboardStats.ts
│   ├── types/
│   │   ├── api.ts                  # API response types
│   │   ├── user.ts                 # User types
│   │   └── dashboard.ts            # Dashboard types
│   └── constants/
│       ├── routes.ts               # Route paths
│       └── sidebar.ts              # Sidebar navigation items
├── public/
│   └── ...
├── package.json
├── next.config.js
├── tailwind.config.ts
├── tsconfig.json
└── postcss.config.js
```

### Rule: Setiap fitur di `(admin)/` harus punya: page.tsx + hook di `hooks/` + type di `types/`

---

## 2. Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Files (components) | `PascalCase.tsx` | `DataTable.tsx`, `StatCard.tsx` |
| Files (non-component) | `camelCase.ts` | `api-client.ts`, `useUsers.ts` |
| Files (pages) | `page.tsx` (Next.js) | `page.tsx` |
| Files (API routes) | `route.ts` (Next.js) | `route.ts` |
| Files (layouts) | `layout.tsx` (Next.js) | `layout.tsx` |
| Components | `PascalCase` | `DataTable`, `Sidebar` |
| Functions/hooks | `camelCase` | `fetchUsers`, `useUsers()` |
| Variables | `camelCase` | `isLoading`, `usersData` |
| Types/interfaces | `PascalCase` | `User`, `ApiResponse` |
| Constants | `UPPER_SNAKE_CASE` | `API_BASE_URL`, `MAX_RETRY` |
| Route paths | `kebab-case` | `/users`, `/transactions` |
| DB tables | `snake_case` | `global_ledger`, `wallet_balances` |

---

## 3. Component Pattern

### 3.1 Server Component (Default)

```tsx
// BENAR ✅ — Server Component (default in App Router)
import { DataTable } from '@/components/shared/DataTable';
import { prisma } from '@/lib/prisma';

export default async function UsersPage() {
  const users = await prisma.user.findMany({
    orderBy: { createdAt: 'desc' },
  });

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Users</h1>
      <DataTable data={users} columns={userColumns} />
    </div>
  );
}
```

### 3.2 Client Component (only when needed)

```tsx
// BENAR ✅ — Client Component (only for interactivity)
'use client';

import { useState } from 'react';
import { useUsers } from '@/hooks/useUsers';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';

export function UserList() {
  const { users, isLoading, error } = useUsers();

  if (isLoading) return <LoadingSpinner />;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <div>
      {users.map((user) => (
        <div key={user.id}>{user.name}</div>
      ))}
    </div>
  );
}

// JANGAN ❌ — every component is client
'use client';
export default function UsersPage() {
  // ❌ no need for client if just displaying data
}
```

### 3.3 When to use 'use client'

```
✅ Server Component (default):
- Data fetching
- Static content
- Lists from DB
- Layouts

✅ Client Component ('use client'):
- onClick handlers
- useState / useEffect
- Forms with input
- Real-time updates (WebSocket)
- Browser APIs (localStorage, etc.)
```

---

## 4. Types (TypeScript)

### 4.1 Always define types

```typescript
// BENAR ✅ — types/user.ts
export interface User {
  id: string;
  email: string;
  username: string;
  phone: string;
  kycStatus: 'UNVERIFIED' | 'PENDING' | 'APPROVED' | 'REJECTED';
  role: 'USER' | 'ADMIN' | 'SUPER_ADMIN';
  createdAt: string;
}

export interface UserListResponse {
  success: boolean;
  data: User[];
  total: number;
  page: number;
  limit: number;
}

// SALAH ❌ — no types
function UserList({ users }: { users: any[] }) {
  return users.map((u) => <div>{u.name}</div>); // ❌ u.name doesn't exist
}
```

### 4.2 API Response Types

```typescript
// BENAR ✅
export interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data?: T;
  error?: {
    code: string;
    details?: string;
  };
}

// Usage
const response = await fetch('/api/admin/users');
const data: ApiResponse<User[]> = await response.json();
```

---

## 5. API Client (Fetch Wrapper)

```typescript
// BENAR ✅ — lib/api-client.ts
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

interface RequestConfig {
  method?: string;
  body?: unknown;
  headers?: Record<string, string>;
}

async function apiClient<T>(endpoint: string, config: RequestConfig = {}): Promise<T> {
  const { method = 'GET', body, headers = {} } = config;

  const response = await fetch(`${API_BASE_URL}${endpoint}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...headers,
    },
    body: body ? JSON.stringify(body) : undefined,
  });

  if (!response.ok) {
    const error = await response.json();
    throw new ApiError(error.message || 'Request failed', response.status);
  }

  return response.json();
}

export class ApiError extends Error {
  constructor(message: string, public statusCode: number) {
    super(message);
    this.name = 'ApiError';
  }
}

export const api = {
  get: <T>(endpoint: string) => apiClient<T>(endpoint),
  post: <T>(endpoint: string, body: unknown) =>
    apiClient<T>(endpoint, { method: 'POST', body }),
  put: <T>(endpoint: string, body: unknown) =>
    apiClient<T>(endpoint, { method: 'PUT', body }),
  delete: <T>(endpoint: string) =>
    apiClient<T>(endpoint, { method: 'DELETE' }),
};
```

---

## 6. Data Fetching (SWR)

### 6.1 Hook Pattern

```typescript
// BENAR ✅ — hooks/useUsers.ts
'use client';

import useSWR from 'swr';
import { api } from '@/lib/api-client';
import type { UserListResponse } from '@/types/user';

const fetcher = (url: string) => api.get<UserListResponse>(url);

export function useUsers(page = 1, limit = 20) {
  const { data, error, isLoading, mutate } = useSWR(
    `/admin/users?page=${page}&limit=${limit}`,
    fetcher,
    {
      revalidateOnFocus: false,
      revalidateOnReconnect: false,
    }
  );

  return {
    users: data?.data ?? [],
    total: data?.total ?? 0,
    isLoading,
    error,
    mutate,
  };
}

// SALAH ❌ — fetch in useEffect
'use client';
export function UserList() {
  const [users, setUsers] = useState([]);
  useEffect(() => {
    fetch('/api/admin/users')
      .then((res) => res.json())
      .then((data) => setUsers(data));  // ❌ no error handling, no loading state
  }, []);
}
```

### 6.2 SWR Config

```typescript
// lib/swr-config.ts
export const swrConfig = {
  fetcher: async (url: string) => {
    const res = await fetch(url);
    if (!res.ok) throw new ApiError('Failed to fetch', res.status);
    return res.json();
  },
  revalidateOnFocus: false,
  revalidateOnReconnect: false,
  shouldRetryOnError: false,
};
```

---

## 7. Styling (Tailwind + shadcn/ui)

### 7.1 Always use Tailwind classes

```tsx
// BENAR ✅
<div className="flex items-center justify-between p-4 bg-white rounded-lg border border-gray-200">
  <h2 className="text-lg font-semibold text-gray-900">Users</h2>
  <span className="text-sm text-gray-500">1,234 total</span>
</div>

// JANGAN ❌ — inline styles
<div style={{ display: 'flex', padding: '16px', background: 'white' }}>
  <h2 style={{ fontSize: '18px', fontWeight: 'bold' }}>Users</h2>
</div>
```

### 7.2 Use shadcn/ui components

```tsx
// BENAR ✅ — use shadcn/ui Button
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { DataTable } from '@/components/ui/data-table';

export function StatCard({ title, value }: StatCardProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>{title}</CardTitle>
      </CardHeader>
      <CardContent>
        <p className="text-2xl font-bold">{value}</p>
      </CardContent>
    </Card>
  );
}

// JANGAN ❌ — custom button when shadcn exists
<button className="bg-blue-500 text-white px-4 py-2 rounded">
  Click me
</button>
```

### 7.3 Status Badge Pattern

```tsx
// BENAR ✅ — consistent status badges
const statusConfig = {
  UNVERIFIED: { label: 'Unverified', className: 'bg-gray-100 text-gray-700' },
  PENDING: { label: 'Pending', className: 'bg-yellow-100 text-yellow-700' },
  APPROVED: { label: 'Approved', className: 'bg-green-100 text-green-700' },
  REJECTED: { label: 'Rejected', className: 'bg-red-100 text-red-700' },
} as const;

function StatusBadge({ status }: { status: keyof typeof statusConfig }) {
  const config = statusConfig[status];
  return (
    <span className={`px-2 py-1 rounded-full text-xs font-medium ${config.className}`}>
      {config.label}
    </span>
  );
}
```

---

## 8. Route Group Convention

```
(auth)/          ← group tanpa affect URL
  login/
    page.tsx     ← /login

(admin)/         ← group dengan shared layout
  page.tsx       ← /
  users/
    page.tsx     ← /users
  transactions/
    page.tsx     ← /transactions
```

### Sidebar Navigation

```typescript
// constants/sidebar.ts
export interface NavItem {
  title: string;
  href: string;
  icon: string;
  badge?: number;
}

export const sidebarItems: NavItem[] = [
  { title: 'Overview', href: '/', icon: 'LayoutDashboard' },
  { title: 'Users', href: '/users', icon: 'Users' },
  { title: 'Transactions', href: '/transactions', icon: 'ArrowLeftRight' },
  { title: 'Ledger', href: '/ledger', icon: 'BookOpen' },
  { title: 'Disputes', href: '/disputes', icon: 'AlertTriangle' },
  { title: 'Anomalies', href: '/anomalies', icon: 'Shield' },
];
```

---

## 9. Error Handling

### 9.1 Error Boundary

```tsx
// app/(admin)/error.tsx
'use client';

export default function AdminError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div className="flex flex-col items-center justify-center h-screen">
      <h2 className="text-xl font-semibold mb-4">Something went wrong</h2>
      <p className="text-gray-500 mb-4">{error.message}</p>
      <button
        onClick={() => reset()}
        className="px-4 py-2 bg-blue-500 text-white rounded"
      >
        Try again
      </button>
    </div>
  );
}
```

### 9.2 Loading State

```tsx
// app/(admin)/loading.tsx
export default function AdminLoading() {
  return (
    <div className="flex items-center justify-center h-screen">
      <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500" />
    </div>
  );
}
```

### 9.3 API Error Handling

```typescript
// BENAR ✅ — in hook
export function useUsers() {
  const { data, error, isLoading } = useSWR('/admin/users', fetcher);

  return {
    users: data?.data ?? [],
    isLoading,
    error: error?.message ?? null,
  };
}

// In component
if (error) {
  return <ErrorState message={error} onRetry={mutate} />;
}
```

---

## 10. Authentication (NextAuth)

```typescript
// BENAR ✅ — lib/auth.ts
import { NextAuthOptions } from 'next-auth';
import CredentialsProvider from 'next-auth/providers/credentials';

export const authOptions: NextAuthOptions = {
  providers: [
    CredentialsProvider({
      name: 'Credentials',
      credentials: {
        email: { label: 'Email', type: 'email' },
        password: { label: 'Password', type: 'password' },
      },
      async authorize(credentials) {
        const res = await fetch(`${API_URL}/auth/login`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            email: credentials.email,
            pin: credentials.password,
          }),
        });

        const data = await res.json();
        if (data.success && data.data.role === 'ADMIN') {
          return {
            id: data.data.id,
            email: data.data.email,
            role: data.data.role,
            accessToken: data.data.accessToken,
          };
        }
        return null;
      },
    }),
  ],
  session: { strategy: 'jwt' },
  pages: {
    signIn: '/login',
  },
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.role = user.role;
        token.accessToken = user.accessToken;
      }
      return token;
    },
    async session({ session, token }) {
      session.user.role = token.role;
      session.user.accessToken = token.accessToken;
      return session;
    },
  },
};
```

---

## 11. Prisma (Server-side only)

```typescript
// BENAR ✅ — lib/prisma.ts (singleton)
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma = globalForPrisma.prisma ?? new PrismaClient();

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}

// Usage in server component
const users = await prisma.user.findMany({
  select: {
    id: true,
    email: true,
    username: true,
    kycStatus: true,
    createdAt: true,
  },
  orderBy: { createdAt: 'desc' },
});
```

---

## 12. Table Component Pattern

```tsx
// BENAR ✅ — shared DataTable
'use client';

import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';

interface Column<T> {
  key: string;
  header: string;
  render?: (item: T) => React.ReactNode;
}

interface DataTableProps<T> {
  data: T[];
  columns: Column<T>[];
}

export function DataTable<T extends { id: string }>({
  data,
  columns,
}: DataTableProps<T>) {
  return (
    <Table>
      <TableHeader>
        <TableRow>
          {columns.map((col) => (
            <TableHead key={col.key}>{col.header}</TableHead>
          ))}
        </TableRow>
      </TableHeader>
      <TableBody>
        {data.map((item) => (
          <TableRow key={item.id}>
            {columns.map((col) => (
              <TableCell key={col.key}>
                {col.render ? col.render(item) : String(item[col.key as keyof T])}
              </TableCell>
            ))}
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}

// Usage
const userColumns: Column<User>[] = [
  { key: 'name', header: 'Name' },
  { key: 'email', header: 'Email' },
  {
    key: 'kycStatus',
    header: 'Status',
    render: (user) => <StatusBadge status={user.kycStatus} />,
  },
  {
    key: 'createdAt',
    header: 'Joined',
    render: (user) => new Date(user.createdAt).toLocaleDateString(),
  },
];
```

---

## 13. Anti-Patterns (JANGAN LAKUKAN)

| # | Anti-Pattern | Yang Benar |
|---|-------------|-----------|
| 1 | `'use client'` di semua component | Server Component default, Client hanya saat perlu |
| 2 | `any` type | Selalu define interface/type |
| 3 | `useEffect` untuk fetch data | Pakai SWR hook |
| 4 | Inline styles | Pakai Tailwind classes |
| 5 | Custom button/input | Pakai shadcn/ui components |
| 6 | `console.log()` | Pakai proper logging |
| 7 | Hardcoded API URL | Pakai `process.env.NEXT_PUBLIC_API_URL` |
| 8 | No error handling | Selalu handle loading + error state |
| 9 | Fetch di server component | Prisma langsung di server component |
| 10 | Magic numbers | Define di constants |
| 11 | Status string literals | Pakai type union / enum |
| 12 | No loading states | Selalu ada loading indicator |

---

## 14. Checklist Sebelum Commit

```
□ Server Component default, 'use client' hanya saat perlu
□ Semua data punya TypeScript types
□ Pakai SWR untuk client-side data fetching
□ Pakai shadcn/ui components (bukan custom)
□ Pakai Tailwind classes (bukan inline styles)
□ Error + loading state dihandle
□ Tidak ada console.log()
□ API URL pakai environment variable
□ npm run lint tanpa error
□ npm run build tanpa error
```
