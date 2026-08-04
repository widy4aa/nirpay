import NextAuth, { CredentialsSignin } from 'next-auth';
import Credentials from 'next-auth/providers/credentials';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';

export const { auth, signIn, signOut, handlers } = NextAuth({
  providers: [
    Credentials({
      name: 'Credentials',
      credentials: {
        email: { label: 'Email', type: 'email' },
        password: { label: 'Password', type: 'password' },
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) {
          const err = new CredentialsSignin();
          err.code = 'EmailPasswordKosong';
          throw err;
        }

        let res: Response;
        try {
          res = await fetch(`${API_BASE_URL}/api/auth/admin/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              email: credentials.email,
              password: credentials.password,
            }),
          });
        } catch {
          const err = new CredentialsSignin();
          err.code = 'BackendTidakDapatDijangkau';
          throw err;
        }

        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        let data: any;
        try {
          data = await res.json();
        } catch {
          const err = new CredentialsSignin();
          err.code = 'BackendError';
          throw err;
        }

        if (!res.ok || !data.success || !data.data?.user?.role) {
          const err = new CredentialsSignin();
          err.code = 'BukanAdmin';
          throw err;
        }

        return {
          id: data.data.user.id,
          email: data.data.user.email,
          name: data.data.user.fullName || data.data.user.name,
          role: data.data.user.role,
          accessToken: data.data.accessToken,
        };
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
      if (session.user) {
        session.user.id = token.sub as string;
        session.user.role = token.role as string;
        session.user.accessToken = token.accessToken as string;
      }
      return session;
    },
  },
});
