import { Controller, Get, Query } from "@nestjs/common";
import { AdminService } from "./admin.service";
import { Roles } from "../../common/decorators/roles.decorator";
import { ApiResponse } from "../../common/interfaces/api-response.interface";

@Controller("admin")
@Roles("ADMIN", "SUPER_ADMIN")
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get("users")
  async getUsers(
    @Query("page") page: string = "1",
    @Query("limit") limit: string = "10",
  ): Promise<ApiResponse<any>> {
    const pageNumber = parseInt(page, 10) || 1;
    const limitNumber = parseInt(limit, 10) || 10;

    const result = await this.adminService.getUsers(pageNumber, limitNumber);

    return {
      success: true,
      data: result,
    };
  }

  @Get("stats")
  async getDashboardStats(): Promise<ApiResponse<any>> {
    const result = await this.adminService.getDashboardStats();
    return {
      success: true,
      data: result,
    };
  }
}
