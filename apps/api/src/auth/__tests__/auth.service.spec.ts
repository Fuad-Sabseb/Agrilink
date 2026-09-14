import { ConflictException, ForbiddenException, UnauthorizedException } from '@nestjs/common';
import { AuthService } from '../auth.service';
import { UserRole } from '../../users/entities/user-role.enum';

describe('AuthService', () => {
  let usersService: any;
  let passwordService: any;
  let refreshTokensService: any;
  let farmerProfileService: any;
  let jwtService: any;
  let configService: any;
  let authService: AuthService;

  const baseUser = {
    id: 'user-1',
    phoneNumber: '+251911223344',
    fullName: 'Tolosa Bekele',
    passwordHash: 'hashed-password',
    role: UserRole.FARMER,
    isActive: true,
  };

  beforeEach(() => {
    usersService = {
      findByPhoneNumber: jest.fn(),
      findByPhoneNumberWithPassword: jest.fn(),
      findById: jest.fn(),
      create: jest.fn(),
    };
    passwordService = {
      hash: jest.fn().mockResolvedValue('hashed-password'),
      compare: jest.fn(),
    };
    refreshTokensService = {
      issue: jest.fn().mockResolvedValue(undefined),
      findValid: jest.fn(),
      revoke: jest.fn().mockResolvedValue(undefined),
      revokeByRawToken: jest.fn().mockResolvedValue(undefined),
    };
    farmerProfileService = {
      createEmptyProfile: jest.fn().mockResolvedValue(undefined),
    };
    jwtService = {
      signAsync: jest.fn().mockResolvedValue('signed-token'),
      verifyAsync: jest.fn(),
    };
    configService = { get: jest.fn().mockReturnValue('secret') };

    authService = new AuthService(
      usersService,
      passwordService,
      refreshTokensService,
      farmerProfileService,
      jwtService,
      configService,
    );
  });

  describe('register', () => {
    it('rejects self-registration as admin before touching the database', async () => {
      await expect(
        authService.register({
          phoneNumber: '+251911223344',
          fullName: 'X',
          password: 'password123',
          role: UserRole.ADMIN,
        } as any),
      ).rejects.toThrow(ForbiddenException);

      expect(usersService.findByPhoneNumber).not.toHaveBeenCalled();
    });

    it('rejects a duplicate phone number', async () => {
      usersService.findByPhoneNumber.mockResolvedValue(baseUser);

      await expect(
        authService.register({
          phoneNumber: baseUser.phoneNumber,
          fullName: 'X',
          password: 'password123',
          role: UserRole.FARMER,
        } as any),
      ).rejects.toThrow(ConflictException);
    });

    it('hashes the password before storing, never the plaintext', async () => {
      usersService.findByPhoneNumber.mockResolvedValue(null);
      usersService.create.mockResolvedValue(baseUser);

      await authService.register({
        phoneNumber: baseUser.phoneNumber,
        fullName: baseUser.fullName,
        password: 'plaintext-password',
        role: UserRole.FARMER,
      } as any);

      expect(passwordService.hash).toHaveBeenCalledWith('plaintext-password');
      expect(usersService.create).toHaveBeenCalledWith(
        expect.objectContaining({ passwordHash: 'hashed-password' }),
      );
      // The plaintext must never reach the persistence layer.
      const createArg = usersService.create.mock.calls[0][0];
      expect(Object.values(createArg)).not.toContain('plaintext-password');
    });

    it('issues an access and refresh token pair on success', async () => {
      usersService.findByPhoneNumber.mockResolvedValue(null);
      usersService.create.mockResolvedValue(baseUser);

      const result = await authService.register({
        phoneNumber: baseUser.phoneNumber,
        fullName: baseUser.fullName,
        password: 'plaintext-password',
        role: UserRole.FARMER,
      } as any);

      expect(result.accessToken).toBe('signed-token');
      expect(result.refreshToken).toBe('signed-token');
      expect(refreshTokensService.issue).toHaveBeenCalledWith(baseUser.id, 'signed-token');
      // Two distinct jti values even though signAsync is mocked identically —
      // verifies the service generates them, not that the mock proves it.
      const [accessPayload] = jwtService.signAsync.mock.calls[0];
      const [refreshPayload] = jwtService.signAsync.mock.calls[1];
      expect(accessPayload.jti).toBeDefined();
      expect(refreshPayload.jti).toBeDefined();
      expect(accessPayload.jti).not.toEqual(refreshPayload.jti);
    });

    it('creates an empty farmer profile when registering as a farmer', async () => {
      usersService.findByPhoneNumber.mockResolvedValue(null);
      usersService.create.mockResolvedValue(baseUser); // baseUser.role === FARMER

      await authService.register({
        phoneNumber: baseUser.phoneNumber,
        fullName: baseUser.fullName,
        password: 'plaintext-password',
        role: UserRole.FARMER,
      } as any);

      expect(farmerProfileService.createEmptyProfile).toHaveBeenCalledWith(baseUser.id);
    });

    it('does NOT create a farmer profile when registering as a buyer', async () => {
      usersService.findByPhoneNumber.mockResolvedValue(null);
      usersService.create.mockResolvedValue({ ...baseUser, role: UserRole.BUYER });

      await authService.register({
        phoneNumber: baseUser.phoneNumber,
        fullName: baseUser.fullName,
        password: 'plaintext-password',
        role: UserRole.BUYER,
      } as any);

      expect(farmerProfileService.createEmptyProfile).not.toHaveBeenCalled();
    });
  });

  describe('login', () => {
    it('throws the same generic message for an unknown phone number as for a wrong password (no account enumeration)', async () => {
      usersService.findByPhoneNumberWithPassword.mockResolvedValue(null);

      let unknownPhoneError: any;
      try {
        await authService.login({ phoneNumber: '+251900000000', password: 'x' } as any);
      } catch (e) {
        unknownPhoneError = e;
      }

      usersService.findByPhoneNumberWithPassword.mockResolvedValue(baseUser);
      passwordService.compare.mockResolvedValue(false);

      let wrongPasswordError: any;
      try {
        await authService.login({ phoneNumber: baseUser.phoneNumber, password: 'wrong' } as any);
      } catch (e) {
        wrongPasswordError = e;
      }

      expect(unknownPhoneError).toBeInstanceOf(UnauthorizedException);
      expect(wrongPasswordError).toBeInstanceOf(UnauthorizedException);
      expect(unknownPhoneError.message).toEqual(wrongPasswordError.message);
    });

    it('rejects login for a deactivated account with a distinct, specific message', async () => {
      usersService.findByPhoneNumberWithPassword.mockResolvedValue({
        ...baseUser,
        isActive: false,
      });

      await expect(
        authService.login({ phoneNumber: baseUser.phoneNumber, password: 'x' } as any),
      ).rejects.toThrow('This account has been deactivated');
    });

    it('succeeds with correct credentials and issues tokens', async () => {
      usersService.findByPhoneNumberWithPassword.mockResolvedValue(baseUser);
      passwordService.compare.mockResolvedValue(true);

      const result = await authService.login({
        phoneNumber: baseUser.phoneNumber,
        password: 'correct-password',
      } as any);

      expect(result.user.id).toBe(baseUser.id);
      expect(result.accessToken).toBe('signed-token');
    });
  });

  describe('refresh', () => {
    it('rejects a token that fails signature/expiry verification', async () => {
      jwtService.verifyAsync.mockRejectedValue(new Error('bad signature'));

      await expect(authService.refresh('garbage-token')).rejects.toThrow(
        UnauthorizedException,
      );
      expect(refreshTokensService.findValid).not.toHaveBeenCalled();
    });

    it('rejects a validly-signed token that has already been revoked/rotated', async () => {
      jwtService.verifyAsync.mockResolvedValue({ sub: baseUser.id, role: baseUser.role });
      refreshTokensService.findValid.mockResolvedValue(null);

      await expect(authService.refresh('already-used-token')).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('rotates on success: revokes the old token and issues a new pair', async () => {
      const stored = { id: 'rt-1' };
      jwtService.verifyAsync.mockResolvedValue({ sub: baseUser.id, role: baseUser.role });
      refreshTokensService.findValid.mockResolvedValue(stored);
      usersService.findById.mockResolvedValue(baseUser);

      const result = await authService.refresh('valid-token');

      expect(refreshTokensService.revoke).toHaveBeenCalledWith(stored);
      expect(result.accessToken).toBe('signed-token');
    });
  });
});
