import { Injectable, Logger } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";

@Injectable()
export class AdminService {
  private readonly logger = new Logger(AdminService.name);

  constructor(private readonly prisma: PrismaService) {}

  async getUsers(page: number = 1, limit: number = 10) {
    this.logger.log(`[Admin] Fetching users page: ${page}, limit: ${limit}`);

    const skip = (page - 1) * limit;

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        skip,
        take: limit,
        select: {
          id: true,
          email: true,
          username: true,
          fullName: true,
          role: true,
          kycStatus: true,
          isActive: true,
          createdAt: true,
        },
        orderBy: { createdAt: "desc" },
      }),
      this.prisma.user.count(),
    ]);

    return {
      users,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getDashboardStats() {
    this.logger.log("[Admin] Fetching dashboard stats");

    const [totalUsers] = await Promise.all([this.prisma.user.count()]);

    return {
      totalUsers,
      totalTransactions: 0,
      totalVolume: 0,
    };
  }
}
