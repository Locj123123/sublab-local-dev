# SubLab Local Development Workspace

Локальний робочий простір для розробки SubLab системи з використанням Docker Compose.

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

### Базові сервіси
- **PostgreSQL** (порт 5432) - База даних
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
# База даних
DATABASE_URL=postgresql://postgres:postgres123@localhost:5432/sublab_db
POSTGRES_DB=sublab_db
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres123

# Redis
REDIS_URL=redis://localhost:6379

# API ключі
OPENAI_API_KEY=your_openai_key
ELEVENLABS_API_KEY=your_elevenlabs_key
REPLICATE_API_TOKEN=your_replicate_token

# Supabase
SUPABASE_URL=http://localhost:5432
SUPABASE_KEY=local-development-key
VITE_SUPABASE_URL=http://localhost:5432
VITE_SUPABASE_KEY=local-development-key
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

# Підключитися до бази даних
psql postgresql://postgres:postgres123@localhost:5432/sublab_db

# Повне очищення (видаляє volumes)
docker-compose down -v --remove-orphans
```

## 🔄 Додавання нових SubLab сервісів

1. Створіть папку `./sublab-vX` (наприклад `./sublab-v1`)
2. Додайте `Dockerfile` в папку
3. Перезапустіть скрипт - сервіс буде автоматично виявлено!

## 📊 Доступні сервіси після запуску

- **PostgreSQL Database**: localhost:5432
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
