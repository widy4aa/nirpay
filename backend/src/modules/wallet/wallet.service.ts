import { Injectable, Logger, NotFoundException } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";

@Injectable()
export class WalletService {
  private readonly logger = new Logger(WalletService.name);

  constructor(private readonly prisma: PrismaService) {}

  async getBalance(userId: string) {
    this.logger.log(`[Wallet] Fetching balance for user: ${userId}`);

    const balance = await this.prisma.walletBalance.findUnique({
      where: { userId },
    });

    if (!balance) {
      throw new NotFoundException("Wallet not found");
    }

    return {
      amountCent: balance.amountCent.toString(), // Convert BigInt to string
      reservedCent: balance.reservedCent.toString(),
      currency: balance.currency,
    };
  }

  async resolveUsername(username: string) {
    this.logger.log(`[Wallet] Resolving username: ${username}`);

    const user = await this.prisma.user.findUnique({
      where: { username },
      select: {
        id: true,
        username: true,
        publicKeyB64: true,
      },
    });

    if (!user) {
      throw new NotFoundException("User not found");
    }

    return user;
  }
}
