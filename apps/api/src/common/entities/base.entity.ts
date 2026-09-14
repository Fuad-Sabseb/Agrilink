import {
  CreateDateColumn,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

/**
 * Every entity in AgriLink extends this rather than declaring id/timestamps
 * itself — one definition of "what a record is", consistent across the 7
 * proposal modules (Farmer, Market, Buyer, Transport, Transaction, etc.).
 */
export abstract class BaseEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
