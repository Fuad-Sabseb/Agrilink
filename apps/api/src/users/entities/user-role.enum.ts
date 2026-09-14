/**
 * Matches the four actor types the proposal defines end-to-end (§6, final
 * product journey): Farmer, Buyer, Transporter, and Admin (institutional
 * back-office). One column on User rather than separate tables per role —
 * a person only ever registers as one of these in the MVP; the proposal
 * does not describe a single account holding multiple roles.
 */
export enum UserRole {
  FARMER = 'farmer',
  BUYER = 'buyer',
  TRANSPORTER = 'transporter',
  ADMIN = 'admin',
}

/**
 * Afaan Oromoo first, per proposal — Amharic and English also supported
 * (§10.4, §Localization). Stored per-user so the API can localize
 * server-generated content (e.g. notification text) later without a
 * frontend-only solution.
 */
export enum PreferredLanguage {
  AFAAN_OROMOO = 'om',
  AMHARIC = 'am',
  ENGLISH = 'en',
}
