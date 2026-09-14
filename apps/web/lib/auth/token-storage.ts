const REFRESH_TOKEN_KEY = 'agrilink.refreshToken';

/**
 * Only the refresh token is persisted. The access token deliberately lives
 * in memory only (React state) — it's short-lived (15 min) and never
 * touches storage, so an XSS payload that can read localStorage still
 * doesn't get a long-lived credential "for free" from there; it would
 * still need to catch the access token in memory.
 *
 * Known trade-off (documented in PROGRESS.md): the refresh token itself
 * IS in localStorage, which is readable by any script on the page. The
 * hardened alternative is an httpOnly cookie set by the API, which is a
 * Phase 35 (Security Hardening) change, not a Day 3 one — it requires the
 * API to set/clear cookies rather than return tokens in the JSON body.
 */
export const tokenStorage = {
  get(): string | null {
    if (typeof window === 'undefined') return null;
    return window.localStorage.getItem(REFRESH_TOKEN_KEY);
  },
  set(token: string): void {
    if (typeof window === 'undefined') return;
    window.localStorage.setItem(REFRESH_TOKEN_KEY, token);
  },
  clear(): void {
    if (typeof window === 'undefined') return;
    window.localStorage.removeItem(REFRESH_TOKEN_KEY);
  },
};
