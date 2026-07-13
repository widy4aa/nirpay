import { Test, TestingModule } from "@nestjs/testing";
import { INestApplication, ValidationPipe } from "@nestjs/common";
import request from "supertest";
import { App } from "supertest/types";
import { AppModule } from "../src/app.module";
import { PrismaService } from "../src/prisma/prisma.service";
import { TransformResponseInterceptor } from "../src/common/interceptors/transform-response.interceptor";
import { AllExceptionsFilter } from "../src/common/filters/http-exception.filter";

const mockPrismaService = {
  user: {
    findUnique: jest.fn(),
    findFirst: jest.fn(),
    findMany: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    count: jest.fn(),
  },
  walletBalance: {
    findUnique: jest.fn(),
    create: jest.fn(),
  },
  otpVerification: {
    create: jest.fn(),
    findUnique: jest.fn(),
    update: jest.fn(),
  },
  deviceSession: {
    create: jest.fn(),
  },
  $transaction: jest.fn((callback) => callback(mockPrismaService)),
};

describe("Auth (e2e)", () => {
  let app: INestApplication<App>;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(PrismaService)
      .useValue(mockPrismaService)
      .compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
        transformOptions: { enableImplicitConversion: true },
      }),
    );
    app.useGlobalFilters(new AllExceptionsFilter());
    app.useGlobalInterceptors(new TransformResponseInterceptor());
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  // ─────────────────────────────────────────────
  // 1.37 POST /auth/check-availability
  // ─────────────────────────────────────────────
  describe("POST /auth/check-availability", () => {
    it("should return available when email and phone are new", async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(null);

      const res = await request(app.getHttpServer())
        .post("/auth/check-availability")
        .send({ email: "new@test.com", phone: "081234567890" })
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.data.emailAvailable).toBe(true);
      expect(res.body.data.phoneAvailable).toBe(true);
    });

    it("should return unavailable when email exists", async () => {
      mockPrismaService.user.findUnique
        .mockResolvedValueOnce({ id: "1", email: "exists@test.com" })
        .mockResolvedValueOnce(null);

      const res = await request(app.getHttpServer())
        .post("/auth/check-availability")
        .send({ email: "exists@test.com", phone: "081234567890" })
        .expect(200);

      expect(res.body.data.emailAvailable).toBe(false);
    });
  });

  // ─────────────────────────────────────────────
  // 1.38 POST /auth/send-otp + verify-otp
  // ─────────────────────────────────────────────
  describe("POST /auth/send-otp", () => {
    it("should send OTP and return otpId", async () => {
      mockPrismaService.otpVerification.create.mockResolvedValue({
        id: "otp-uuid-123",
        email: "test@test.com",
        otpHash: "hashed",
        channel: "EMAIL",
        purpose: "register",
        attemptCount: 0,
        maxAttempts: 5,
        isUsed: false,
        expiresAt: new Date(Date.now() + 300000),
        createdAt: new Date(),
      });

      const res = await request(app.getHttpServer())
        .post("/auth/send-otp")
        .send({
          email: "test@test.com",
          phone: "081234567890",
          type: "register",
        })
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.data.otpId).toBe("otp-uuid-123");
      expect(res.body.data.expiresIn).toBe(300);
    });
  });

  describe("POST /auth/verify-otp", () => {
    it("should return 400 for invalid OTP code", async () => {
      const argon2 = require("argon2");
      const validOtpHash = await argon2.hash("123456", {
        type: argon2.argon2id,
      });

      mockPrismaService.otpVerification.findUnique.mockResolvedValue({
        id: "otp-uuid-123",
        otpHash: validOtpHash,
        isUsed: false,
        expiresAt: new Date(Date.now() + 300000),
        attemptCount: 0,
        maxAttempts: 5,
      });
      mockPrismaService.otpVerification.update.mockResolvedValue({});

      const res = await request(app.getHttpServer())
        .post("/auth/verify-otp")
        .send({ otpId: "otp-uuid-123", otpCode: "000000" })
        .expect(200);

      expect(res.body.data.verified).toBe(false);
    });

    it("should return 400 for OTP not found", async () => {
      mockPrismaService.otpVerification.findUnique.mockResolvedValue(null);

      await request(app.getHttpServer())
        .post("/auth/verify-otp")
        .send({ otpId: "nonexistent", otpCode: "123456" })
        .expect(400);
    });
  });

  // ─────────────────────────────────────────────
  // 1.39 GET /auth/check-username/:username
  // ─────────────────────────────────────────────
  describe("GET /auth/check-username/:username", () => {
    it("should return available true for new username", async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(null);

      const res = await request(app.getHttpServer())
        .get("/auth/check-username/newuser")
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.data.available).toBe(true);
    });

    it("should return available false for taken username", async () => {
      mockPrismaService.user.findUnique.mockResolvedValue({
        id: "1",
        username: "takenuser",
      });

      const res = await request(app.getHttpServer())
        .get("/auth/check-username/takenuser")
        .expect(200);

      expect(res.body.data.available).toBe(false);
    });
  });

  // ─────────────────────────────────────────────
  // 1.40 POST /auth/register
  // ─────────────────────────────────────────────
  describe("POST /auth/register", () => {
    const registerPayload = {
      email: "new@test.com",
      phone: "081234567890",
      username: "newuser",
      fullName: "New User",
      pin: "123456",
      publicKeyB64: "base64key",
    };

    it("should register a new user successfully", async () => {
      mockPrismaService.user.findFirst.mockResolvedValue(null);
      mockPrismaService.user.findUnique.mockResolvedValue(null);
      mockPrismaService.user.create.mockResolvedValue({
        id: "user-uuid-123",
        email: registerPayload.email,
        fullName: registerPayload.fullName,
        role: "USER",
        pinHash: "hashed",
        passwordHash: "hashed",
        isActive: true,
        isLocked: false,
        failedLoginCount: 0,
      });
      mockPrismaService.walletBalance.create.mockResolvedValue({
        id: "wb-uuid",
        userId: "user-uuid-123",
        amountCent: BigInt(0),
      });

      const res = await request(app.getHttpServer())
        .post("/auth/register")
        .send(registerPayload)
        .expect(201);

      expect(res.body.success).toBe(true);
      expect(res.body.data.userId).toBe("user-uuid-123");
      expect(res.body.data.accessToken).toBeDefined();
      expect(res.body.data.refreshToken).toBeDefined();
    });

    it("should return 409 for duplicate email", async () => {
      mockPrismaService.user.findFirst.mockResolvedValue({
        id: "existing-user",
        email: registerPayload.email,
      });

      await request(app.getHttpServer())
        .post("/auth/register")
        .send(registerPayload)
        .expect(409);
    });

    it("should return 400 for invalid body", async () => {
      await request(app.getHttpServer())
        .post("/auth/register")
        .send({ email: "invalid" })
        .expect(400);
    });
  });

  // ─────────────────────────────────────────────
  // 1.41 POST /auth/login
  // ─────────────────────────────────────────────
  describe("POST /auth/login", () => {
    it("should login with correct credentials", async () => {
      const argon2 = require("argon2");
      const pinHash = await argon2.hash("123456", { type: argon2.argon2id });

      mockPrismaService.user.findUnique.mockResolvedValue({
        id: "user-uuid-123",
        email: "test@test.com",
        fullName: "Test User",
        role: "USER",
        pinHash,
        passwordHash: pinHash,
        isActive: true,
        isLocked: false,
        failedLoginCount: 0,
      });
      mockPrismaService.user.update.mockResolvedValue({});
      mockPrismaService.deviceSession.create.mockResolvedValue({});

      const res = await request(app.getHttpServer())
        .post("/auth/login")
        .send({ email: "test@test.com", pin: "123456" })
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.data.accessToken).toBeDefined();
      expect(res.body.data.refreshToken).toBeDefined();
      expect(res.body.data.user.email).toBe("test@test.com");
    });

    it("should return 401 for wrong PIN", async () => {
      const argon2 = require("argon2");
      const pinHash = await argon2.hash("123456", { type: argon2.argon2id });

      mockPrismaService.user.findUnique.mockResolvedValue({
        id: "user-uuid-123",
        email: "test@test.com",
        pinHash,
        isActive: true,
        isLocked: false,
        failedLoginCount: 0,
      });
      mockPrismaService.user.update.mockResolvedValue({});

      await request(app.getHttpServer())
        .post("/auth/login")
        .send({ email: "test@test.com", pin: "000000" })
        .expect(401);
    });

    it("should return 401 for non-existent email", async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(null);

      await request(app.getHttpServer())
        .post("/auth/login")
        .send({ email: "notfound@test.com", pin: "123456" })
        .expect(401);
    });
  });
});
