import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FarmerProfile } from './entities/farmer-profile.entity';
import { UpdateFarmerProfileDto } from './dto/update-farmer-profile.dto';

@Injectable()
export class FarmerProfileService {
  constructor(
    @InjectRepository(FarmerProfile)
    private readonly repo: Repository<FarmerProfile>,
  ) {}

  /**
   * Called once, from AuthService.register(), the moment a user registers
   * with role=farmer — so a profile row always exists and the frontend
   * never has to handle "farmer with no profile yet" as a distinct state.
   */
  async createEmptyProfile(userId: string): Promise<FarmerProfile> {
    const profile = this.repo.create({
      userId,
      zone: null,
      woreda: null,
      kebele: null,
      cooperativeName: null,
    });
    return this.repo.save(profile);
  }

  async findByUserId(userId: string): Promise<FarmerProfile> {
    const profile = await this.repo.findOne({ where: { userId } });
    if (!profile) {
      // Should be unreachable given createEmptyProfile runs at registration
      // — surfacing loudly rather than silently returning an empty object
      // if that invariant is ever violated (e.g. a future data migration).
      throw new NotFoundException('Farmer profile not found');
    }
    return profile;
  }

  async updateOwnProfile(
    userId: string,
    dto: UpdateFarmerProfileDto,
  ): Promise<FarmerProfile> {
    const profile = await this.findByUserId(userId);
    Object.assign(profile, dto);
    return this.repo.save(profile);
  }
}
