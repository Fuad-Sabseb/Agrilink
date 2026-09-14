export type UserRole = 'farmer' | 'buyer' | 'transporter' | 'admin';
export type PreferredLanguage = 'om' | 'am' | 'en';

export interface AuthUser {
  id: string;
  phoneNumber: string;
  email: string | null;
  fullName: string;
  role: UserRole;
  preferredLanguage: PreferredLanguage;
  isActive: boolean;
  createdAt: string;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface RegisterInput {
  phoneNumber: string;
  fullName: string;
  password: string;
  role: UserRole;
  preferredLanguage?: PreferredLanguage;
}

export interface LoginInput {
  phoneNumber: string;
  password: string;
}

/** Shape of a NestJS ValidationPipe / HttpException error body. */
export interface ApiErrorBody {
  statusCode: number;
  message: string | string[];
  error?: string;
}
