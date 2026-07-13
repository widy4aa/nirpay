export function LoadingSpinner({ message = 'Loading...' }: { message?: string }) {
  return (
    <div className="flex flex-col items-center justify-center h-full min-h-[200px] w-full">
      <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mb-4" />
      {message && <p className="text-gray-500 text-sm">{message}</p>}
    </div>
  );
}
