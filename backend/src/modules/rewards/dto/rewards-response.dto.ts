export class RewardTransactionResponseDto {
  id: string;
  description: string;
  points: number;
  type: string;
  createdAt: string;

  constructor(partial: Partial<RewardTransactionResponseDto>) {
    Object.assign(this, partial);
  }
}

export class RewardsBalanceResponseDto {
  balance: number;

  constructor(balance: number) {
    this.balance = balance;
  }
}
