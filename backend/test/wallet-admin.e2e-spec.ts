import { Test, TestingModule } from "@nestjs/testing";
import { INestApplication, ValidationPipe } from "@nestjs/common";
import request from "supertest";
import { App } from "supertest/types";
import { AppModule } from "../src/app.module";
import { PrismaService } from "../src/prisma/prisma.service";
import { TransformResponseInterceptor } from "../src/common/interceptors/transform-response.interceptor";
import { AllExceptionsFilter } from "../src/common/filters/http-exception.filter";
import * as argon2 from "argon2";

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

let accessToken: string;

describe("Wallet & Admin (e2e)", () => {
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

    // Login to get a valid token
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

    const loginRes = await request(app.getHttpServer())
      .post("/auth/login")
      .send({ email: "test@test.com", pin: "123456" });

    accessToken = loginRes.body.data.accessToken;
  });

  afterAll(async () => {
    await app.close();
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  // ─────────────────────────────────────────────
  // 1.42 GET /wallet/balance
  // ─────────────────────────────────────────────
  describe("GET /wallet/balance", () => {
    it("should return wallet balance with valid token", async () => {
      mockPrismaService.walletBalance.findUnique.mockResolvedValue({
        id: "wb-uuid",
        userId: "user-uuid-123",
        amountCent: BigInt(0),
        reservedCent: BigInt(0),
        currency: "IDR",
      });

      const res = await request(app.getHttpServer())
        .get("/wallet/balance")
        .set("Authorization", `Bearer ${accessToken}`)
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.data.amountCent).toBe("0");
      expect(res.body.data.currency).toBe("IDR");
    });

    it("should return 401 without token", async () => {
      await request(app.getHttpServer()).get("/wallet/balance").expect(401);
    });
  });

  // ─────────────────────────────────────────────
  // 1.43 GET /wallet/resolve/:username
  // ─────────────────────────────────────────────
  describe("GET /wallet/resolve/:username", () => {
    it("should resolve username to user info", async () => {
      mockPrismaService.user.findUnique.mockResolvedValue({
        id: "user-uuid-123",
        username: "testuser",
        publicKeyB64: "base64key",
      });

      const res = await request(app.getHttpServer())
        .get("/wallet/resolve/testuser")
        .set("Authorization", `Bearer ${accessToken}`)
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.data.username).toBe("testuser");
      expect(res.body.data.publicKeyB64).toBe("base64key");
    });

    it("should return 404 for non-existent username", async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(null);

      await request(app.getHttpServer())
        .get("/wallet/resolve/nonexistent")
        .set("Authorization", `Bearer ${accessToken}`)
        .expect(404);
    });
  });

  // ─────────────────────────────────────────────
  // GET /admin/users
  // ─────────────────────────────────────────────
  describe("GET /admin/users", () => {
    it("should return 403 for non-admin user", async () => {
      await request(app.getHttpServer())
        .get("/admin/users")
        .set("Authorization", `Bearer ${accessToken}`)
        .expect(403);
    });
  });
});
