#!/bin/bash

# ─── NirPay Deploy Script ───

set -e

echo "🚀 NirPay Docker Deploy"
echo "======================="

# Copy .env jika belum ada
if [ ! -f .env ]; then
    echo "📋 Creating .env from .env.example..."
    cp .env.example .env
    echo "⚠️  Please edit .env with your configuration!"
    echo ""
fi

# Generate APP_KEY jika belum di-set
if grep -q "GENERATE_WITH_php_artisan_key_generate" .env; then
    echo "🔑 Generating Laravel APP_KEY..."
    APP_KEY=$(openssl rand -base64 32)
    sed -i "s|base64:GENERATE_WITH_php_artisan_key_generate|base64:$APP_KEY|" .env
    echo "✅ APP_KEY generated"
fi

# Build dan start containers
echo ""
echo "🐳 Building and starting Docker containers..."
docker compose up -d --build

# Tunggu database ready
echo ""
echo "⏳ Waiting for database to be ready..."
sleep 10

# Run migrations
echo ""
echo "🗄️  Running database migrations..."
docker compose exec -T backend php artisan migrate --force

# Seed database
echo ""
echo "🌱 Seeding database..."
docker compose exec -T backend php artisan db:seed --force

# Clear caches
echo ""
echo "🧹 Clearing caches..."
docker compose exec -T backend php artisan config:cache
docker compose exec -T backend php artisan route:cache

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📱 Services:"
echo "   Backend API:  http://localhost:${BACKEND_PORT:-3001}"
echo "   Dashboard:    http://localhost:${DASHBOARD_PORT:-3000}"
echo "   Database:     localhost:${DB_PORT:-5432}"
echo "   Mailpit:      http://localhost:8025"
echo ""
echo "👤 Dummy Users:"
echo "   user1@gmail.com / password"
echo "   user2@gmail.com / password"
echo ""
echo "🔑 Admin:"
echo "   admin@nirpay.com / Admin123"
echo ""
