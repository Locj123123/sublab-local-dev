# SubLab Local Development Workspace

Локальний робочий простір для розробки SubLab системи з використанням Docker Compose та єдиною базою даних Supabase.

## 🚀 Швидкий старт

### Передумови
- Docker Desktop
- Docker Compose
- Git

### Запуск сервісів

```bash
# Запуск всіх сервісів
./start-servers.sh

# Зупинка всіх сервісів
./stop-servers.sh
```

## 📋 Архітектура

### 🎯 Єдина база даних Supabase
Цей проект використовує **єдину базу даних Supabase** для всіх сервісів, що забезпечує:
- **Централізоване управління даними** - всі сервіси працюють з однією БД
- **Консистентність даних** - немає проблем з синхронізацією між різними БД
- **Спрощена розробка** - один набір міграцій та схем
- **Ефективне використання ресурсів** - менше накладних витрат
- **Легке тестування** - всі тести працюють з однією БД

### Базові сервіси
- **Supabase Local** (порт 54321) - Локальна база даних з продакшн схемою
- **Supabase Studio** (порт 54323) - Веб-інтерфейс для управління базою даних
- **Redis** (порт 6379) - Кеш та черги
- **Frontend** (порт 5173) - React додаток
- **Chat Assistant API** (порт 8001) - API для чат-асистента

### SubLab сервіси (опціонально)
- **SubLab V1** (порт 8002) - Orchestrator
- **SubLab V2** (порт 8003) - Modules & Images
- **SubLab V3** (порт 8004) - Audio Generation
- **SubLab V4** (порт 8005) - Audio Assembly
- **SubLab V5** (порт 8006) - Audio Mixing

## 🔧 Налаштування

### Environment Variables
Створіть файл `.env` з наступними змінними:

```env
# ===========================================
# SUPABASE - ЄДИНА БАЗА ДАНИХ
# ===========================================
# Supabase Local (внутрішня мережа Docker для backend)
SUPABASE_URL=http://supabase:54321
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU

# Frontend Supabase (для браузера - localhost)
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0

# База даних PostgreSQL (пряме підключення)
DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres

# ===========================================
# REDIS - КЕШ ТА ЧЕРГИ
# ===========================================
REDIS_URL=redis://redis:6379

# ===========================================
# API КЛЮЧІ
# ===========================================
OPENAI_API_KEY=your_openai_key
ELEVENLABS_API_KEY=your_elevenlabs_key
REPLICATE_API_TOKEN=your_replicate_token
VITE_STRIPE_PUBLIC_KEY=your_stripe_key
```

## 📁 Структура проекту

```
.
├── docker-compose.yml      # Docker Compose конфігурація
├── start-servers.sh        # Скрипт запуску сервісів
├── stop-servers.sh         # Скрипт зупинки сервісів
├── .env                    # Environment змінні (створюється автоматично)
├── .gitignore             # Git ignore правила
├── frontsublab/           # Frontend React додаток
├── chat-assistant-api/    # Chat Assistant API (якщо існує)
├── sublab-v1/            # SubLab V1 сервіс (якщо існує)
├── sublab-v2/            # SubLab V2 сервіс (якщо існує)
├── sublab-v3/            # SubLab V3 сервіс (якщо існує)
├── sublab-v4/            # SubLab V4 сервіс (якщо існує)
└── sublab-v5/            # SubLab V5 сервіс (якщо існує)
```

## 🛠️ Корисні команди

```bash
# Переглянути логи сервісу
docker-compose logs -f [service-name]

# Перезапустити сервіс
docker-compose restart [service-name]

# Переглянути статус всіх сервісів
docker-compose ps

# Підключитися до єдиної Supabase бази даних
psql postgresql://postgres:postgres@localhost:54322/postgres

# Повне очищення (видаляє volumes)
docker-compose down -v --remove-orphans
```

## 🔄 Додавання нових SubLab сервісів

1. Створіть папку `./sublab-vX` (наприклад `./sublab-v1`)
2. Додайте `Dockerfile` в папку
3. Перезапустіть скрипт - сервіс буде автоматично виявлено!

## 📊 Доступні сервіси після запуску

- **Supabase Database (Єдина БД)**: localhost:54321 (API) / localhost:54322 (PostgreSQL)
- **Supabase Studio**: http://localhost:54323 (Веб-інтерфейс для управління БД)
- **Redis Cache**: localhost:6379
- **Frontend (React App)**: http://localhost:5173
- **Chat Assistant API**: http://localhost:8001
- **SubLab V1**: http://localhost:8002 (якщо існує)
- **SubLab V2**: http://localhost:8003 (якщо існує)
- **SubLab V3**: http://localhost:8004 (якщо існує)
- **SubLab V4**: http://localhost:8005 (якщо існує)
- **SubLab V5**: http://localhost:8006 (якщо існує)

## 🐛 Вирішення проблем

### Порт вже використовується
```bash
# Перевірити які процеси використовують порт
lsof -i :5173

# Зупинити всі контейнери
docker-compose down
```

### Проблеми з Docker
```bash
# Перезапустити Docker Desktop
# Або очистити Docker кеш
docker system prune -a
```

## 📝 Ліцензія

Цей проект є частиною SubLab системи розробки.
