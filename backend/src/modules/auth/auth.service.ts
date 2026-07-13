import {
  Injectable,
  Logger,
  ConflictException,
  UnauthorizedException,
} from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { PrismaService } from "../../prisma/prisma.service";
import { OtpService } from "./otp.service";
import { RegisterDto } from "./dto/register.dto";
import { LoginDto } from "./dto/login.dto";
import * as argon2 from "argon2";

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly otpService: OtpService,
    private readonly jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto): Promise<{
    userId: string;
    accessToken: string;
    refreshToken: string;
  }> {
    this.logger.log(`[Auth] Registering user: ${dto.email}`);

    const existingUser = await this.prisma.user.findFirst({
      where: {
        OR: [{ email: dto.email }, { phoneNumber: dto.phone }],
      },
    });

    if (existingUser) {
      throw new ConflictException("Email or phone already registered");
    }

    if (dto.username) {
      const existingUsername = await this.prisma.user.findUnique({
        where: { username: dto.username },
      });
      if (existingUsername) {
        throw new ConflictException("Username already taken");
      }
    }

    const pinHash = await argon2.hash(dto.pin, { type: argon2.argon2id });

    const result = await this.prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: {
          email: dto.email,
          phoneNumber: dto.phone,
          fullName: dto.fullName,
          username: dto.username,
          passwordHash: pinHash,
          pinHash,
          publicKeyB64: dto.publicKeyB64,
          gender: dto.gender,
          birthDate: dto.birthDate ? new Date(dto.birthDate) : null,
        },
      });

      await tx.walletBalance.create({
        data: { userId: user.id, amountCent: BigInt(0) },
      });

      return user;
    });

    const tokens = await this.generateTokens(result);

    this.logger.log(`[Auth] User registered: ${result.id}`);

    return {
      userId: result.id,
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    };
  }

  async login(dto: LoginDto): Promise<{
    accessToken: string;
    refreshToken: string;
    user: { id: string; email: string; fullName: string; role: string };
  }> {
    this.logger.log(`[Auth] Login attempt: ${dto.email}`);

    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });

    if (!user) {
      throw new UnauthorizedException("Invalid credentials");
    }

    if (!user.isActive) {
      throw new UnauthorizedException("Account is deactivated");
    }

    if (user.isLocked) {
      throw new UnauthorizedException("Account is locked");
    }

    const isPinValid = await argon2.verify(user.pinHash, dto.pin);

    if (!isPinValid) {
      await this.prisma.user.update({
        where: { id: user.id },
        data: { failedLoginCount: { increment: 1 } },
      });
      throw new UnauthorizedException("Invalid credentials");
    }

    const tokens = await this.generateTokens(user);

    await this.prisma.user.update({
      where: { id: user.id },
      data: {
        failedLoginCount: 0,
        lastLoginAt: new Date(),
      },
    });

    await this.prisma.deviceSession.create({
      data: {
        userId: user.id,
        authToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresAt: new Date(Date.now() + 15 * 60 * 1000),
      },
    });

    this.logger.log(`[Auth] Login successful: ${user.id}`);

    return {
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      user: {
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
      },
    };
  }

  async checkAvailability(
    email: string,
    phone: string,
  ): Promise<{ emailAvailable: boolean; phoneAvailable: boolean }> {
    this.logger.log(`[Auth] Checking availability: ${email}`);

    const existingEmail = await this.prisma.user.findUnique({
      where: { email },
    });

    const existingPhone = await this.prisma.user.findUnique({
      where: { phoneNumber: phone },
    });

    return {
      emailAvailable: !existingEmail,
      phoneAvailable: !existingPhone,
    };
  }

  async checkUsername(username: string): Promise<{ available: boolean }> {
    this.logger.log(`[Auth] Checking username: ${username}`);

    const existing = await this.prisma.user.findUnique({
      where: { username },
    });

    return { available: !existing };
  }

  private async generateTokens(user: {
    id: string;
    email: string;
    role: string;
  }): Promise<{ accessToken: string; refreshToken: string }> {
    const payload = {
      sub: user.id,
      email: user.email,
      role: user.role,
    };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload, { expiresIn: "15m" }),
      this.jwtService.signAsync(payload, { expiresIn: "30d" }),
    ]);

    return { accessToken, refreshToken };
  }
}
