/* eslint-disable @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-return */
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

describe("AppController (e2e)", () => {
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
      }),
    );
    app.useGlobalFilters(new AllExceptionsFilter());
    app.useGlobalInterceptors(new TransformResponseInterceptor());
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it("/ (GET)", async () => {
    const res = await request(app.getHttpServer()).get("/").expect(200);

    expect(res.body.success).toBe(true);
    expect(res.body.data).toBe("Hello World!");
  });
});
