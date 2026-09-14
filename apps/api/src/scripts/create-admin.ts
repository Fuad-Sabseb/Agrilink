import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { UsersService } from '../users/users.service';
import { PasswordService } from '../auth/password.service';
import { UserRole } from '../users/entities/user-role.enum';

/**
 * The out-of-band admin provisioning mechanism referenced since Phase 04
 * ("Admin accounts cannot self-register" — AuthService.register() blocks
 * role: admin unconditionally, by design). This script is that "out of
 * band": run by whoever operates the deployment, from a trusted shell —
 * never exposed as an HTTP endpoint, because an HTTP endpoint that can
 * mint admin accounts is just self-registration with extra steps.
 *
 * Usage:
 *   npm run create-admin -- --phone=+251911223344 --name="Ops Admin" --password="a-real-password"
 *
 * Deliberately NOT a fixed default admin/password seeded via migration —
 * a hardcoded bootstrap credential shipped in a migration is a real,
 * well-known attack surface (anyone with the source has the password for
 * every deployment that didn't think to change it). This script requires
 * the operator to supply a real password up front instead.
 */

function parseArgs(): { phone?: string; name?: string; password?: string } {
  const args: Record<string, string> = {};
  for (const arg of process.argv.slice(2)) {
    const match = arg.match(/^--([^=]+)=(.*)$/);
    if (match) args[match[1]] = match[2];
  }
  return { phone: args.phone, name: args.name, password: args.password };
}

const ETHIOPIAN_PHONE_REGEX = /^\+251[79]\d{8}$/;

async function main() {
  const { phone, name, password } = parseArgs();

  if (!phone || !name || !password) {
    console.error(
      'Usage: npm run create-admin -- --phone=+251911223344 --name="Ops Admin" --password="..."',
    );
    process.exit(1);
  }
  if (!ETHIOPIAN_PHONE_REGEX.test(phone)) {
    console.error('--phone must be a valid Ethiopian mobile number, e.g. +251911223344');
    process.exit(1);
  }
  if (password.length < 8) {
    console.error('--password must be at least 8 characters');
    process.exit(1);
  }

  const app = await NestFactory.createApplicationContext(AppModule, {
    logger: ['error', 'warn'],
  });

  try {
    const usersService = app.get(UsersService);
    const passwordService = app.get(PasswordService);

    const existing = await usersService.findByPhoneNumber(phone);
    if (existing) {
      console.error(`A user with phone ${phone} already exists (role: ${existing.role}).`);
      process.exit(1);
    }

    const passwordHash = await passwordService.hash(password);
    const admin = await usersService.create({
      phoneNumber: phone,
      fullName: name,
      passwordHash,
      role: UserRole.ADMIN,
    });

    console.log(`Admin account created: ${admin.fullName} (${admin.phoneNumber}), id=${admin.id}`);
    console.log('Log in via POST /api/v1/auth/login like any other account.');
  } finally {
    await app.close();
  }
}

main().catch((err) => {
  console.error('Failed to create admin account:', err);
  process.exit(1);
});
