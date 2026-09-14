import { Injectable } from '@nestjs/common';
import * as bcrypt from 'bcrypt';

// Cost factor 12: deliberately higher than bcrypt's default (10) since
// AgriLink handles farmer financial/transaction data down the line: worth
// the extra ~4x hashing time on register/login, which is not a hot path.
const SALT_ROUNDS = 12;

@Injectable()
export class PasswordService {
  hash(plainText: string): Promise<string> {
    return bcrypt.hash(plainText, SALT_ROUNDS);
  }

  compare(plainText: string, hash: string): Promise<boolean> {
    return bcrypt.compare(plainText, hash);
  }
}
