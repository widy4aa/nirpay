export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="max-w-md w-full p-8 bg-white rounded-lg shadow-md border border-gray-200">
        <div className="flex justify-center mb-8">
          <div className="w-16 h-16 bg-emerald-100 rounded-full flex items-center justify-center">
            <span className="text-2xl font-bold text-emerald-600">N</span>
          </div>
        </div>
        <h1 className="text-2xl font-bold text-center mb-8 text-gray-900">
          NirPay Admin
        </h1>
        {children}
      </div>
    </div>
  );
}
