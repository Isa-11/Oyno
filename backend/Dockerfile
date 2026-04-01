FROM python:3.11-slim

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python deps first (layer cache)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source
COPY . .

# Collect static files
RUN python manage.py collectstatic --noinput

EXPOSE 8000

# Daphne handles both HTTP and WebSocket (ASGI)
CMD ["daphne", "-b", "0.0.0.0", "-p", "8000", "oyno.asgi:application"]
