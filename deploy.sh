#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Oyno — первый деплой на чистый Ubuntu/Debian VPS
# Запускать от root или через sudo:  bash deploy.sh
# ─────────────────────────────────────────────────────────────────────────────
set -e

DOMAIN=""          # ← вставь свой домен, например: api.oyno.app
EMAIL=""           # ← e-mail для Let's Encrypt уведомлений
REPO_DIR="/opt/oyno"

# ── 1. Установка Docker и Docker Compose ─────────────────────────────────────
echo "==> Installing Docker..."
apt-get update -q
apt-get install -y -q ca-certificates curl gnupg lsb-release

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -q
apt-get install -y -q docker-ce docker-ce-cli containerd.io docker-compose-plugin

# ── 2. Копируем проект (если запускаем не из папки проекта) ──────────────────
echo "==> Deploying to $REPO_DIR..."
mkdir -p "$REPO_DIR"

# Если деплоишь через git:
# git clone https://github.com/YOUR_USER/oyno.git "$REPO_DIR"
# cd "$REPO_DIR" && git pull

# Если копируешь файлы вручную — просто запускай этот скрипт из папки проекта:
cd "$(dirname "$0")"

# ── 3. Создаём .env из примера (если не существует) ──────────────────────────
if [ ! -f .env ]; then
  cp .env.example .env
  echo ""
  echo "⚠️  .env создан из .env.example — заполни переменные перед запуском!"
  echo "   nano .env"
  exit 1
fi

# ── 4. Заменяем домен в nginx конфиге ────────────────────────────────────────
if [ -n "$DOMAIN" ]; then
  sed -i "s/YOUR_DOMAIN.COM/$DOMAIN/g" nginx/conf.d/oyno.conf
  sed -i "s/YOUR_DOMAIN.COM/$DOMAIN/g" nginx/conf.d/oyno.conf
fi

# ── 5. Запуск только HTTP (для получения сертификата) ────────────────────────
echo "==> Starting services (HTTP only for cert issuance)..."

# Временно закомментируем HTTPS блок и ssl_* директивы, чтобы nginx стартовал без сертификата
# После получения сертификата раскомментируем
cp nginx/conf.d/oyno.conf nginx/conf.d/oyno.conf.bak

# Стартуем без HTTPS-блока
cat > nginx/conf.d/oyno_init.conf << 'EOF'
server {
    listen 80;
    server_name _;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        proxy_pass http://web:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

mv nginx/conf.d/oyno.conf nginx/conf.d/oyno.conf.full
mv nginx/conf.d/oyno_init.conf nginx/conf.d/oyno.conf

docker compose up -d db redis web nginx

# ── 6. Получаем SSL сертификат ────────────────────────────────────────────────
echo "==> Obtaining SSL certificate for $DOMAIN..."
docker compose run --rm certbot certonly \
  --webroot \
  --webroot-path /var/www/certbot \
  --email "$EMAIL" \
  --agree-tos \
  --no-eff-email \
  -d "$DOMAIN" \
  -d "www.$DOMAIN"

# ── 7. Включаем HTTPS конфиг ──────────────────────────────────────────────────
mv nginx/conf.d/oyno.conf.full nginx/conf.d/oyno.conf

echo "==> Reloading nginx with HTTPS config..."
docker compose exec nginx nginx -s reload

# ── 8. Запускаем certbot auto-renew ──────────────────────────────────────────
docker compose up -d certbot

echo ""
echo "✅  Деплой завершён!"
echo "   API доступен на: https://$DOMAIN/api/"
echo "   Admin:           https://$DOMAIN/admin/"
echo ""
echo "Создай суперпользователя:"
echo "   docker compose exec web python manage.py createsuperuser"
