import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { PreferredLanguage, UserRole } from './entities/user-role.enum';

export interface CreateUserInput {
  phoneNumber: string;
  fullName: string;
  passwordHash: string;
  role: UserRole;
  email?: string;
  preferredLanguage?: PreferredLanguage;
}

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,
  ) {}

  async findByPhoneNumber(phoneNumber: string): Promise<User | null> {
    return this.usersRepository.findOne({ where: { phoneNumber } });
  }

  /**
   * The only path that also selects passwordHash (it's `select: false` by
   * default on the entity). Used exclusively by AuthService for login.
   */
  async findByPhoneNumberWithPassword(
    phoneNumber: string,
  ): Promise<User | null> {
    return this.usersRepository
      .createQueryBuilder('user')
      .addSelect('user.passwordHash')
      .where('user.phoneNumber = :phoneNumber', { phoneNumber })
      .getOne();
  }

  async findById(id: string): Promise<User | null> {
    return this.usersRepository.findOne({ where: { id } });
  }

  async create(input: CreateUserInput): Promise<User> {
    const user = this.usersRepository.create({
      phoneNumber: input.phoneNumber,
      fullName: input.fullName,
      passwordHash: input.passwordHash,
      role: input.role,
      email: input.email ?? null,
      preferredLanguage: input.preferredLanguage ?? PreferredLanguage.AFAAN_OROMOO,
    });
    return this.usersRepository.save(user);
  }
}
