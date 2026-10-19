import { accessTokenHolder } from './access-token-holder';
import { tokenStorage } from './token-storage';
import type {
  ApiErrorBody,
  AuthTokens,
  AuthUser,
  LoginInput,
  RegisterInput,
} from './types';

const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:3001/api/v1';

export class ApiError extends Error {
  constructor(
    message: string,
    public readonly status: number,
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

function extractMessage(body: unknown, fallback: string): string {
  const b = body as Partial<ApiErrorBody> | undefined;
  if (!b?.message) return fallback;
  return Array.isArray(b.message) ? b.message[0] : b.message;
}

async function request<T>(
  path: string,
  options: RequestInit = {},
): Promise<T> {
  let response: Response;
  try {
    response = await fetch(`${API_BASE_URL}${path}`, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
    });
  } catch {
    // Network failure (API unreachable, offline, CORS block, etc.) — the
    // proposal explicitly calls out unreliable connectivity as a first-
    // class condition to design for (§10.4), so this is a distinct,
    // user-facing case, not a generic 500.
    throw new ApiError(
      'Could not reach the AgriLink server. Check your connection and try again.',
      0,
    );
  }

  if (response.status === 204) {
    return undefined as T;
  }

  const body = await response.json().catch(() => undefined);

  if (!response.ok) {
    throw new ApiError(
      extractMessage(body, 'Something went wrong. Please try again.'),
      response.status,
    );
  }

  return body as T;
}

/**
 * Like `request`, but attaches the current access token and, on a 401,
 * attempts exactly one silent refresh-and-retry before giving up. Used for
 * every endpoint that requires a logged-in user. Exported so other
 * feature modules (farmers, and later marketplace/logistics/etc.) can use
 * the same refresh-and-retry behavior instead of reimplementing it.
 */
export async function authRequest<T>(
  path: string,
  options: RequestInit = {},
): Promise<T> {
  const attempt = () =>
    request<T>(path, {
      ...options,
      headers: {
        ...options.headers,
        Authorization: `Bearer ${accessTokenHolder.get() ?? ''}`,
      },
    });

  try {
    return await attempt();
  } catch (err) {
    if (err instanceof ApiError && err.status === 401) {
      const refreshToken = tokenStorage.get();
      if (!refreshToken) throw err;
      const tokens = await authApi.refresh(refreshToken);
      accessTokenHolder.set(tokens.accessToken);
      tokenStorage.set(tokens.refreshToken);
      return attempt();
    }
    throw err;
  }
}

export const authApi = {
  register: (input: RegisterInput) =>
    request<AuthTokens & { user: AuthUser }>('/auth/register', {
      method: 'POST',
      body: JSON.stringify(input),
    }),

  login: (input: LoginInput) =>
    request<AuthTokens & { user: AuthUser }>('/auth/login', {
      method: 'POST',
      body: JSON.stringify(input),
    }),

  refresh: (refreshToken: string) =>
    request<AuthTokens>('/auth/refresh', {
      method: 'POST',
      body: JSON.stringify({ refreshToken }),
    }),

  logout: (refreshToken: string) =>
    request<void>('/auth/logout', {
      method: 'POST',
      body: JSON.stringify({ refreshToken }),
    }),

  me: () => authRequest<AuthUser>('/users/me'),
};
