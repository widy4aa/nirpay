import type { Metadata } from "next";
import AuthProvider from '@/components/providers/AuthProvider';
import "./globals.css";

export const metadata: Metadata = {
  title: "NirPay Dashboard",
  description: "NirPay Admin Dashboard",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="h-full antialiased">
      <head>
        <style>{`
          :root {
            --font-geist-sans: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            --font-geist-mono: 'SF Mono', 'Fira Code', 'Fira Mono', 'Roboto Mono', monospace;
          }
          body {
            font-family: var(--font-geist-sans);
          }
          code, pre, .font-mono {
            font-family: var(--font-geist-mono);
          }
        `}</style>
      </head>
      <body className="min-h-full flex flex-col">
        <AuthProvider>{children}</AuthProvider>
      </body>
    </html>
  );
}
