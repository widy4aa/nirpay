export default () => ({
  port: parseInt(process.env.PORT || "3000", 10),
  database: {
    url: process.env.DATABASE_URL,
  },
  jwt: {
    secret: process.env.JWT_SECRET || "nirpay-jwt-secret-key-2026",
    accessExpiresIn: process.env.JWT_ACCESS_EXPIRES || "15m",
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES || "30d",
  },
  redis: {
    url: process.env.REDIS_URL || "redis://localhost:6379",
  },
  environment: process.env.NODE_ENV || "development",
});
