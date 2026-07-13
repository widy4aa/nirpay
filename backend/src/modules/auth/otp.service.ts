import { Injectable, Logger, BadRequestException } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import * as argon2 from "argon2";
import { randomInt } from "crypto";

@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name);

  constructor(private readonly prisma: PrismaService) {}

  generateOtp(): string {
    return randomInt(100000, 999999).toString();
  }

  async sendOtp(
    email: string,
    phone: string,
    type: string,
  ): Promise<{ otpId: string; expiresIn: number }> {
    this.logger.log(`[OTP] Sending OTP to ${email} for ${type}`);

    const otp = this.generateOtp();
    const otpHash = await argon2.hash(otp);

    const otpRecord = await this.prisma.otpVerification.create({
      data: {
        email,
        otpHash,
        channel: "EMAIL",
        purpose: type,
        expiresAt: new Date(Date.now() + 5 * 60 * 1000),
      },
    });

    this.logger.log(`[OTP] OTP sent to ${email} — id: ${otpRecord.id}`);

    // Mock email send — log OTP for development
    if (process.env.NODE_ENV === "development") {
      this.logger.log(`[OTP] DEV MODE — OTP for ${email}: ${otp}`);
    }

    return { otpId: otpRecord.id, expiresIn: 300 };
  }

  async verifyOtp(otpId: string, otpCode: string): Promise<boolean> {
    this.logger.log(`[OTP] Verifying OTP: ${otpId}`);

    const otpRecord = await this.prisma.otpVerification.findUnique({
      where: { id: otpId },
    });

    if (!otpRecord) {
      throw new BadRequestException("OTP not found");
    }

    if (otpRecord.isUsed) {
      throw new BadRequestException("OTP already used");
    }

    if (new Date() > otpRecord.expiresAt) {
      throw new BadRequestException("OTP expired");
    }

    if (otpRecord.attemptCount >= otpRecord.maxAttempts) {
      throw new BadRequestException("OTP max attempts exceeded");
    }

    const isValid = await argon2.verify(otpRecord.otpHash, otpCode);

    if (!isValid) {
      await this.prisma.otpVerification.update({
        where: { id: otpId },
        data: { attemptCount: { increment: 1 } },
      });
      return false;
    }

    await this.prisma.otpVerification.update({
      where: { id: otpId },
      data: { isUsed: true },
    });

    this.logger.log(`[OTP] OTP verified: ${otpId}`);
    return true;
  }
}
