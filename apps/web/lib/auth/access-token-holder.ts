/**
 * The access token lives here, in memory only, for the lifetime of the
 * page. It is deliberately NOT in localStorage/sessionStorage (see
 * token-storage.ts for the refresh token's persistence and the trade-off
 * note). A full page reload always goes through the silent-refresh flow
 * in AuthContext to repopulate this.
 */
let currentAccessToken: string | null = null;

export const accessTokenHolder = {
  get: () => currentAccessToken,
  set: (token: string | null) => {
    currentAccessToken = token;
  },
};
