import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  HttpCode,
  UseGuards,
} from "@nestjs/common";
import { AuthService } from "./auth.service";
import { RegisterDto } from "./dto/register.dto";
import { LoginDto } from "./dto/login.dto";
import { SendOtpDto, VerifyOtpDto } from "./dto/otp.dto";
import { OtpService } from "./otp.service";
import { Public } from "../../common/decorators/public.decorator";
import { ApiResponse } from "../../common/interfaces/api-response.interface";

@Controller("auth")
@UseGuards()
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly otpService: OtpService,
  ) {}

  @Post("register")
  @Public()
  @HttpCode(201)
  async register(@Body() dto: RegisterDto): Promise<ApiResponse<any>> {
    const result = await this.authService.register(dto);
    return {
      success: true,
      message: "Registration successful",
      data: result,
    };
  }

  @Post("login")
  @Public()
  @HttpCode(200)
  async login(@Body() dto: LoginDto): Promise<ApiResponse<any>> {
    const result = await this.authService.login(dto);
    return {
      success: true,
      message: "Login successful",
      data: result,
    };
  }

  @Post("check-availability")
  @Public()
  @HttpCode(200)
  async checkAvailability(
    @Body() body: { email: string; phone: string },
  ): Promise<ApiResponse<any>> {
    const result = await this.authService.checkAvailability(
      body.email,
      body.phone,
    );
    return {
      success: true,
      data: result,
    };
  }

  @Post("send-otp")
  @Public()
  @HttpCode(200)
  async sendOtp(@Body() dto: SendOtpDto): Promise<ApiResponse<any>> {
    const result = await this.otpService.sendOtp(
      dto.email,
      dto.phone,
      dto.type,
    );
    return {
      success: true,
      message: "OTP sent successfully",
      data: result,
    };
  }

  @Post("verify-otp")
  @Public()
  @HttpCode(200)
  async verifyOtp(@Body() dto: VerifyOtpDto): Promise<ApiResponse<any>> {
    const verified = await this.otpService.verifyOtp(dto.otpId, dto.otpCode);
    return {
      success: verified,
      message: verified ? "OTP verified" : "Invalid OTP",
      data: { verified },
    };
  }

  @Get("check-username/:username")
  @Public()
  @HttpCode(200)
  async checkUsername(
    @Param("username") username: string,
  ): Promise<ApiResponse<any>> {
    const result = await this.authService.checkUsername(username);
    return {
      success: true,
      data: result,
    };
  }
}
