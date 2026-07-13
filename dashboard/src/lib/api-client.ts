const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

interface RequestConfig {
  method?: string;
  body?: unknown;
  headers?: Record<string, string>;
}

export class ApiError extends Error {
  constructor(message: string, public statusCode: number) {
    super(message);
    this.name = 'ApiError';
  }
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
    const error = await response.json().catch(() => ({ message: 'Request failed' }));
    throw new ApiError(error.message || 'Request failed', response.status);
  }

  return response.json();
}

export const api = {
  get: <T>(endpoint: string, headers?: Record<string, string>) => 
    apiClient<T>(endpoint, { headers }),
  post: <T>(endpoint: string, body: unknown, headers?: Record<string, string>) =>
    apiClient<T>(endpoint, { method: 'POST', body, headers }),
  put: <T>(endpoint: string, body: unknown, headers?: Record<string, string>) =>
    apiClient<T>(endpoint, { method: 'PUT', body, headers }),
  delete: <T>(endpoint: string, headers?: Record<string, string>) =>
    apiClient<T>(endpoint, { method: 'DELETE', headers }),
};
