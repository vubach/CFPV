import { Controller, Get, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { RewardsService } from './rewards.service';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { User } from '../users/entities/user.entity';
import { RewardsBalanceResponseDto, RewardTransactionResponseDto } from './dto/rewards-response.dto';

@Controller('rewards')
@UseGuards(AuthGuard('jwt'))
export class RewardsController {
  constructor(private readonly rewardsService: RewardsService) {}

  @Get('balance')
  async getBalance(
    @CurrentUser() user: User,
  ): Promise<RewardsBalanceResponseDto> {
    return this.rewardsService.getBalance(user.id);
  }

  @Get('transactions')
  async getTransactions(
    @CurrentUser() user: User,
  ): Promise<RewardTransactionResponseDto[]> {
    return this.rewardsService.getTransactions(user.id);
  }
}
