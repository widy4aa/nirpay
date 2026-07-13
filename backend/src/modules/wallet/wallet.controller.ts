import { Controller, Get, Param } from "@nestjs/common";
import { WalletService } from "./wallet.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { ApiResponse } from "../../common/interfaces/api-response.interface";

@Controller("wallet")
export class WalletController {
  constructor(private readonly walletService: WalletService) {}

  @Get("balance")
  async getBalance(
    @CurrentUser("id") userId: string,
  ): Promise<ApiResponse<any>> {
    const balance = await this.walletService.getBalance(userId);
    return {
      success: true,
      data: balance,
    };
  }

  @Get("resolve/:username")
  async resolveUsername(
    @Param("username") username: string,
  ): Promise<ApiResponse<any>> {
    const user = await this.walletService.resolveUsername(username);
    return {
      success: true,
      data: user,
    };
  }
}
