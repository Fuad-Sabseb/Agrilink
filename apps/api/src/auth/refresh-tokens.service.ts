import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as crypto from 'crypto';
import { RefreshToken } from './entities/refresh-token.entity';

const REFRESH_TOKEN_TTL_DAYS = 30;

@Injectable()
export class RefreshTokensService {
  constructor(
    @InjectRepository(RefreshToken)
    private readonly repo: Repository<RefreshToken>,
  ) {}

  private hash(token: string): string {
    return crypto.createHash('sha256').update(token).digest('hex');
  }

  async issue(userId: string, rawToken: string): Promise<RefreshToken> {
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + REFRESH_TOKEN_TTL_DAYS);

    const entity = this.repo.create({
      userId,
      tokenHash: this.hash(rawToken),
      expiresAt,
      revokedAt: null,
    });
    return this.repo.save(entity);
  }

  async findValid(rawToken: string): Promise<RefreshToken | null> {
    const tokenHash = this.hash(rawToken);
    const record = await this.repo.findOne({ where: { tokenHash } });
    if (!record) return null;
    if (record.revokedAt) return null;
    if (record.expiresAt.getTime() < Date.now()) return null;
    return record;
  }

  async revoke(record: RefreshToken): Promise<void> {
    record.revokedAt = new Date();
    await this.repo.save(record);
  }

  async revokeByRawToken(rawToken: string): Promise<void> {
    const record = await this.findValid(rawToken);
    if (record) {
      await this.revoke(record);
    }
  }
}
