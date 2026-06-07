import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RewardTransaction } from './entities/reward-transaction.entity';
import { TransactionType } from './entities/transaction-type.enum';
import {
  RewardTransactionResponseDto,
  RewardsBalanceResponseDto,
} from './dto/rewards-response.dto';

@Injectable()
export class RewardsService {
  private readonly logger = new Logger(RewardsService.name);

  constructor(
    @InjectRepository(RewardTransaction)
    private readonly rewardRepo: Repository<RewardTransaction>,
  ) {}

  async getBalance(userId: string): Promise<RewardsBalanceResponseDto> {
    const result = await this.rewardRepo
      .createQueryBuilder('rt')
      .select(
        `COALESCE(SUM(CASE WHEN rt.type = '${TransactionType.EARNED}' THEN rt.points ELSE 0 END), 0) - COALESCE(SUM(CASE WHEN rt.type = '${TransactionType.REDEEMED}' THEN rt.points ELSE 0 END), 0)`,
        'balance',
      )
      .where('rt.userId = :userId', { userId })
      .getRawOne();

    return new RewardsBalanceResponseDto(Number(result?.balance ?? 0));
  }

  async getTransactions(userId: string): Promise<RewardTransactionResponseDto[]> {
    const transactions = await this.rewardRepo.find({
      where: { userId },
      order: { createdAt: 'DESC' },
      take: 100,
    });

    return transactions.map(
      (t) =>
        new RewardTransactionResponseDto({
          id: t.id,
          description: t.description,
          points: t.points,
          type: t.type,
          createdAt: t.createdAt.toISOString(),
        }),
    );
  }

  async earnPoints(
    userId: string,
    orderId: string,
    points: number,
    description: string,
  ): Promise<void> {
    const tx = this.rewardRepo.create({
      userId,
      orderId,
      points,
      description,
      type: TransactionType.EARNED,
    });
    await this.rewardRepo.save(tx);
    this.logger.log(`Points earned: ${points} for user ${userId}`);
  }

  async redeemPoints(
    userId: string,
    points: number,
    description: string,
  ): Promise<void> {
    const balance = await this.getBalance(userId);
    if (balance.balance < points) {
      throw new Error('Insufficient points');
    }

    const tx = this.rewardRepo.create({
      userId,
      points,
      description,
      type: TransactionType.REDEEMED,
    });
    await this.rewardRepo.save(tx);
    this.logger.log(`Points redeemed: ${points} for user ${userId}`);
  }
}
