# AGENTS.md — Backend (NestJS) Coding Conventions
> **Single source of truth** untuk semua coding style di `backend/`.
> Wajib diikuti oleh semua agent/programmer yang kerja di folder ini.

---

## 1. Architecture: Modular + Domain-Driven

```
backend/
├── prisma/
│   ├── schema.prisma
│   └── seed/
│       └── seed.ts
├── src/
│   ├── main.ts
│   ├── app.module.ts
│   ├── common/
│   │   ├── constants/
│   │   │   └── app.constants.ts
│   │   ├── decorators/
│   │   │   └── current-user.decorator.ts
│   │   ├── dto/
│   │   │   └── pagination.dto.ts
│   │   ├── enums/
│   │   │   └── tx.enums.ts
│   │   ├── filters/
│   │   │   └── http-exception.filter.ts
│   │   ├── guards/
│   │   │   ├── jwt-auth.guard.ts
│   │   │   └── roles.guard.ts
│   │   ├── interceptors/
│   │   │   └── transform-response.interceptor.ts
│   │   ├── pipes/
│   │   │   └── validation.pipe.ts
│   │   └── utils/
│   │       └── helpers.ts
│   ├── modules/
│   │   ├── auth/
│   │   │   ├── auth.module.ts
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── otp.service.ts
│   │   │   ├── strategies/
│   │   │   │   └── jwt.strategy.ts
│   │   │   ├── guards/
│   │   │   │   └── auth.guard.ts
│   │   │   └── dto/
│   │   │       ├── register.dto.ts
│   │   │       └── login.dto.ts
│   │   ├── wallet/
│   │   │   ├── wallet.module.ts
│   │   │   ├── wallet.controller.ts
│   │   │   ├── wallet.service.ts
│   │   │   └── dto/
│   │   ├── admin/
│   │   │   ├── admin.module.ts
│   │   │   ├── admin.controller.ts
│   │   │   └── admin.service.ts
│   │   ├── sync/
│   │   │   ├── sync.module.ts
│   │   │   ├── sync.controller.ts
│   │   │   └── sync.service.ts
│   │   └── mock-bank/
│   │       ├── mock-bank.module.ts
│   │       ├── mock-bank.controller.ts
│   │       └── mock-bank.service.ts
│   └── config/
│       └── configuration.ts
├── test/
│   ├── auth.e2e-spec.ts
│   └── jest-e2e.json
├── package.json
├── tsconfig.json
├── tsconfig.build.json
└── nest-cli.json
```

### Rule: Setiap module WAJIB punya: `module.ts` + `controller.ts` + `service.ts` + `dto/`

---

## 2. Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Files | `kebab-case` | `auth.controller.ts`, `jwt.strategy.ts` |
| Classes | `PascalCase` | `AuthService`, `JwtAuthGuard` |
| Methods | `camelCase` | `register()`, `verifyOtp()` |
| Variables | `camelCase` | `accessToken`, `refreshToken` |
| DTOs | `PascalCase` + `Dto` | `RegisterDto`, `LoginDto` |
| Services | `PascalCase` + `Service` | `AuthService`, `OtpService` |
| Controllers | `PascalCase` + `Controller` | `AuthController` |
| Modules | `PascalCase` + `Module` | `AuthModule` |
| Guards | `PascalCase` + `Guard` | `JwtAuthGuard`, `RolesGuard` |
| Decorators | `camelCase` | `@CurrentUser()`, `@Public()` |
| Enums | `PascalCase` | `SyncStatus`, `TxType` |
| Constants | `camelCase` | `maxRetryCount`, `otpExpiryMinutes` |
| DB tables | `snake_case` | `wallet_balances`, `global_ledger` |
| DB columns | `snake_case` | `amount_cent`, `hop_count` |
| API paths | `kebab-case` | `/auth/check-availability`, `/wallet/balance` |
| Env vars | `UPPER_SNAKE_CASE` | `DATABASE_URL`, `JWT_SECRET` |

---

## 3. Module Pattern

### 3.1 Module Structure

```typescript
// BENAR ✅
@Module({
  imports: [
    PrismaModule,
    JwtModule.registerAsync({
      useFactory: (config: AppConfig) => ({
        secret: config.jwtSecret,
        signOptions: { expiresIn: '15m' },
      }),
      inject: [AppConfig],
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, OtpService, JwtStrategy],
  exports: [AuthService],
})
export class AuthModule {}

// SALAH ❌ — semua di satu file
@Injectable()
export class AuthService {
  constructor(private prisma: PrismaService) {}
}
```

### 3.2 Controller Pattern

```typescript
// BENAR ✅
@Controller('auth')
@UseGuards(JwtAuthGuard)
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @HttpCode(201)
  @Public()  // skip auth
  async register(@Body() dto: RegisterDto): Promise<ApiResponse<User>> {
    return this.authService.register(dto);
  }

  @Post('login')
  @HttpCode(200)
  @Public()
  async login(@Body() dto: LoginDto): Promise<ApiResponse<AuthTokens>> {
    return this.authService.login(dto);
  }

  @Get('check-username/:username')
  @Public()
  async checkUsername(@Param('username') username: string) {
    return this.authService.checkUsername(username);
  }

  @Get('wallet/balance')
  async getBalance(@CurrentUser() user: UserPayload) {
    return this.walletService.getBalance(user.id);
  }
}

// JANGAN ❌ — logic di controller
@Controller('auth')
export class AuthController {
  constructor(private prisma: PrismaService) {}

  @Post('register')
  async register(@Body() body: any) {
    // ❌ logic registration di controller
    const hashedPassword = await argon2.hash(body.pin);
    const user = await this.prisma.user.create({ data: { ... } });
    return user;
  }
}
```

### 3.3 Service Pattern

```typescript
// BENAR ✅
@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly otpService: OtpService,
    private readonly jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto): Promise<ApiResponse<User>> {
    this.logger.log(`Registering user: ${dto.email}`);

    // 1. Check availability
    const existing = await this.prisma.user.findFirst({
      where: { OR: [{ email: dto.email }, { phone: dto.phone }] },
    });
    if (existing) {
      throw new ConflictException('Email or phone already registered');
    }

    // 2. Hash PIN
    const pinHash = await argon2.hash(dto.pin, {
      type: argon2.argon2id,
    });

    // 3. Create user
    const user = await this.prisma.user.create({
      data: {
        email: dto.email,
        phone: dto.phone,
        username: dto.username,
        pinHash,
        publicKeyB64: dto.publicKeyB64,
      },
    });

    // 4. Create wallet
    await this.prisma.walletBalance.create({
      data: { userId: user.id, amountCent: 0 },
    });

    this.logger.log(`User registered: ${user.id}`);
    return { success: true, data: user };
  }
}

// JANGAN ❌
@Injectable()
export class AuthService {
  constructor(private prisma: PrismaService) {}

  async register(body: any) {
    return this.prisma.user.create({ data: body }); // ❌ no validation, no logging
  }
}
```

---

## 4. DTO (Data Transfer Object)

### 4.1 Always use class-validator + class-transformer

```dart
// BENAR ✅
import { IsEmail, IsString, MinLength, MaxLength, Matches } from 'class-validator';

export class RegisterDto {
  @IsEmail()
  email: string;

  @IsString()
  @Matches(/^(\+62|62|0)8[1-9][0-9]{6,9}$/)  // Indonesian phone
  phone: string;

  @IsString()
  @MinLength(3)
  @MaxLength(20)
  @Matches(/^[a-zA-Z0-9_]+$/)  // alphanumeric + underscore
  username: string;

  @IsString()
  @MinLength(6)
  @MaxLength(6)
  @Matches(/^[0-9]+$/)  // 6-digit PIN only
  pin: string;

  @IsString()
  publicKeyB64: string;
}

// SALAH ❌
export class RegisterDto {
  email: string;        // ❌ no validation
  phone: string;
  username: string;
  pin: string;
  publicKeyB64: string;
}
```

### 4.2 API Response Wrapper

```typescript
// BENAR ✅ — consistent response format
export interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data?: T;
  error?: {
    code: string;
    details?: string;
  };
}

// Usage in service
return {
  success: true,
  data: user,
  message: 'Registration successful',
};

// Error response
return {
  success: false,
  error: {
    code: 'USER_EXISTS',
    details: 'Email already registered',
  },
};
```

---

## 5. Error Handling

### 5.1 HTTP Exceptions

```typescript
// BENAR ✅ — use built-in NestJS exceptions
import {
  BadRequestException,
  UnauthorizedException,
  ForbiddenException,
  NotFoundException,
  ConflictException,
  InternalServerErrorException,
} from '@nestjs/common';

// Map error types to HTTP codes
throw new BadRequestException('Invalid PIN format');      // 400
throw new UnauthorizedException('Invalid credentials');    // 401
throw new ForbiddenException('Admin access required');     // 403
throw new NotFoundException('User not found');             // 404
throw new ConflictException('Email already registered');   // 409
throw new InternalServerErrorException('Database error');  // 500

// JANGAN ❌
throw new Error('Something went wrong');  // ❌ generic error
res.status(400).json({ message: 'Bad' }); // ❌ manual response
```

### 5.2 Global Exception Filter

```typescript
// common/filters/http-exception.filter.ts
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse();
    const request = ctx.getRequest();

    const status = exception instanceof HttpException
      ? exception.getStatus()
      : 500;

    const message = exception instanceof HttpException
      ? exception.getResponse()
      : { message: 'Internal server error' };

    response.status(status).json({
      success: false,
      timestamp: new Date().toISOString(),
      path: request.url,
      error: message,
    });
  }
}
```

### 5.3 Logging

```typescript
// BENAR ✅ — use NestJS Logger
private readonly logger = new Logger(AuthService.name);

this.logger.log('User registered: ' + user.id);
this.logger.warn('Rate limit exceeded for: ' + email);
this.logger.error('Login failed', exception.stack);

// JANGAN ❌
console.log('User registered');  // ❌
console.error('Error:', e);     // ❌
```

---

## 6. Authentication (JWT)

### 6.1 JWT Strategy

```typescript
// BENAR ✅
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private readonly config: AppConfig) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: config.jwtSecret,
    });
  }

  async validate(payload: JwtPayload) {
    return {
      id: payload.sub,
      email: payload.email,
      role: payload.role,
    };
  }
}

// Payload structure
interface JwtPayload {
  sub: string;      // user ID
  email: string;
  role: 'USER' | 'ADMIN' | 'SUPER_ADMIN';
  iat: number;
  exp: number;
}
```

### 6.2 Token Generation

```typescript
// BENAR ✅
async generateTokens(user: User) {
  const payload = { sub: user.id, email: user.email, role: user.role };

  const [accessToken, refreshToken] = await Promise.all([
    this.jwtService.signAsync(payload, { expiresIn: '15m' }),
    this.jwtService.signAsync(payload, { expiresIn: '30d' }),
  ]);

  return { accessToken, refreshToken };
}
```

### 6.3 Roles Guard

```typescript
// BENAR ✅
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('ADMIN', 'SUPER_ADMIN')
@Controller('admin')
export class AdminController { ... }

// Custom decorator
export const Roles = (...roles: string[]) => SetMetadata('roles', roles);
```

---

## 7. Prisma ORM

### 7.1 Schema Rules

```prisma
// BENAR ✅
model User {
  id            String   @id @default(uuid())
  email         String   @unique
  phone         String   @unique
  username      String   @unique
  pinHash       String   @map("pin_hash")
  publicKeyB64  String   @map("public_key_b64")
  kycStatus     String   @default("UNVERIFIED") @map("kyc_status")
  role          String   @default("USER")
  createdAt     DateTime @default(now()) @map("created_at")
  updatedAt     DateTime @updatedAt @map("updated_at")

  wallet        WalletBalance?
  sessions      DeviceSession[]

  @@map("users")
}

// JANGAN ❌
model User {
  id        String   @id
  email     String
  pin_hash  String   // ❌ inconsistent naming
  createdAt DateTime // ❌ no @map
}
```

### 7.2 Naming Convention

```
Tables:   snake_case, plural    → users, wallet_balances, global_ledger
Columns:  snake_case            → amount_cent, hop_count, sync_status
Relations: PascalCase           → WalletBalance, DeviceSession
@@map:    match table name     → @@map("users")
@map:     match column name     → @map("pin_hash")
```

### 7.3 Query Pattern

```typescript
// BENAR ✅ — use transactions for multi-step operations
async register(dto: RegisterDto) {
  return this.prisma.$transaction(async (tx) => {
    const user = await tx.user.create({ data: { ... } });
    await tx.walletBalance.create({
      data: { userId: user.id, amountCent: 0 },
    });
    return user;
  });
}

// BENAR ✅ — always include relations when needed
const userWithWallet = await this.prisma.user.findUnique({
  where: { id: userId },
  include: { wallet: true },
});

// SALAH ❌ — N+1 query
const users = await this.prisma.user.findMany();
for (const user of users) {
  user.wallet = await this.prisma.walletBalance.findUnique({
    where: { userId: user.id },
  });
}
```

---

## 8. Configuration

### 8.1 Environment Variables

```typescript
// BENAR ✅
// config/configuration.ts
export default () => ({
  port: parseInt(process.env.PORT, 10) || 3000,
  database: {
    url: process.env.DATABASE_URL,
  },
  jwt: {
    secret: process.env.JWT_SECRET,
    accessExpiresIn: '15m',
    refreshExpiresIn: '30d',
  },
  redis: {
    url: process.env.REDIS_URL,
  },
});

// Usage in module
ConfigModule.forRoot({
  isGlobal: true,
  load: [configuration],
}),
```

### 8.2 .env.example

```bash
# Database
DATABASE_URL="postgresql://user:password@localhost:5432/nirpay?schema=public"

# JWT
JWT_SECRET="your-secret-key-here"
JWT_ACCESS_EXPIRES="15m"
JWT_REFRESH_EXPIRES="30d"

# Redis
REDIS_URL="redis://localhost:6379"

# App
PORT=3000
NODE_ENV=development

# Mock Bank
MOCK_BANK_PRIVATE_KEY="ed25519-private-key"
```

---

## 9. Validation Pipe

```typescript
// BENAR ✅ — global validation pipe
// main.ts
app.useGlobalPipes(
  new ValidationPipe({
    whitelist: true,           // strip non-whitelisted properties
    forbidNonWhitelisted: true, // throw error on unknown properties
    transform: true,            // auto-transform to DTO classes
    transformOptions: {
      enableImplicitConversion: true,
    },
  }),
);

// JANGAN ❌ — no validation
app.useGlobalPipes(new ValidationPipe()); // ❌ no whitelist, no transform
```

---

## 10. API Response Interceptor

```typescript
// BENAR ✅ — wrap all responses
@Injectable()
export class TransformResponseInterceptor<T> implements NestInterceptor<T, ApiResponse<T>> {
  intercept(context: ExecutionContext, next: CallHandler): Observable<ApiResponse<T>> {
    return next.handle().pipe(
      map((data) => ({
        success: true,
        data,
        timestamp: new Date().toISOString(),
      })),
    );
  }
}
```

---

## 11. Debugging Rules

### 11.1 Logger

```typescript
// Gunakan NestJS Logger
private readonly logger = new Logger(AuthService.name);

// Format: [FeatureName] message
this.logger.log('[Auth] Registering user: ' + dto.email);
this.logger.log('[Auth] User registered: ' + user.id);
this.logger.warn('[Auth] Rate limit exceeded for: ' + email);
this.logger.error('[Auth] Login failed', exception.stack);

// JANGAN ❌
console.log('debug:', value);
console.error('error:', e);
```

### 11.2 Debug Endpoint

```typescript
// Development only
if (process.env.NODE_ENV === 'development') {
  @Get('debug/users')
  async debugUsers() {
    return this.prisma.user.findMany();
  }
}
```

---

## 12. Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov
```

### Test Pattern

```typescript
// BENAR ✅
describe('AuthService', () => {
  let service: AuthService;
  let prisma: PrismaService;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [AuthService, PrismaService],
    }).compile();

    service = module.get(AuthService);
    prisma = module.get(PrismaService);
  });

  it('should register a new user', async () => {
    const dto = { email: 'test@test.com', pin: '123456', ... };
    const result = await service.register(dto);
    expect(result.success).toBe(true);
  });
});
```

---

## 13. Anti-Patterns (JANGAN LAKUKAN)

| # | Anti-Pattern | Yang Benar |
|---|-------------|-----------|
| 1 | Logic di controller | Logic di service, controller handle HTTP only |
| 2 | `any` type di DTO | Pakai class-validator + typed DTO |
| 3 | No validation di DTO | Selalu pakai `@IsString()`, `@IsEmail()`, dll |
| 4 | `console.log()` | Pakai `new Logger()` |
| 5 | Raw SQL queries | Pakai Prisma ORM |
| 6 | `res.json()` langsung | Pakai `ApiResponse<T>` wrapper |
| 7 | Hardcode secrets | Pakai `ConfigService` + `.env` |
| 8 | No error handling | Selalu throw `HttpException` |
| 9 | N+1 queries | Pakai `include` atau `select` |
| 10 | No transaction | `$transaction()` untuk multi-step |
| 11 | No logging | Selalu log critical operations |
| 12 | `@Body() body: any` | `@Body() dto: RegisterDto` |
| 13 | Missing `@Public()` | Public endpoints harus explicit |
| 14 | No rate limiting | Rate limit di auth endpoints |

---

## 14. Checklist Sebelum Commit

```
□ Semua DTO pakai class-validator decorators
□ Tidak ada console.log() — pakai Logger
□ Semua service methods return ApiResponse<T>
□ Error handling pakai HttpException
□ Prisma queries pakai transaction untuk multi-step
□ Logging untuk semua critical operations
□ .env.example updated (jangan commit .env)
□ Unit test pass
□ npm run lint tanpa error
□ npm run build tanpa error
```
