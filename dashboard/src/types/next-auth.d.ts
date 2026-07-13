import 'next-auth';

declare module 'next-auth' {
  interface User {
    role?: string;
    accessToken?: string;
  }
  
  interface Session {
    user: User & {
      role?: string;
      accessToken?: string;
    };
  }
}
