#!/bin/bash

# SubLab Local Development Server Startup Script
# Цей скрипт запускає лише існуючі сервери SubLab локально

echo "🚀 Запуск SubLab серверів локально..."
echo "=================================="

# Перевіряємо наявність Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не встановлено!"
    echo "Будь ласка, встановіть Docker Desktop"
    exit 1
fi

# Перевіряємо наявність Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose не встановлено!"
    echo "Будь ласка, встановіть Docker Compose"
    exit 1
fi

echo "✅ Перевірки пройшли успішно"
echo ""

# Створюємо файл .env якщо його немає
if [ ! -f ".env" ]; then
    echo "📝 Створення файлу .env з базовими налаштуваннями..."
    cat > .env << EOF
# Локальна база даних
DATABASE_URL=postgresql://postgres:postgres123@localhost:5432/sublab_db
POSTGRES_DB=sublab_db
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres123

# Redis
REDIS_URL=redis://localhost:6379

# API ключі (додайте свої)
OPENAI_API_KEY=
ELEVENLABS_API_KEY=
REPLICATE_API_TOKEN=

# Supabase (для сумісності)
SUPABASE_URL=http://localhost:5432
SUPABASE_KEY=local-development-key
VITE_SUPABASE_URL=http://localhost:5432
VITE_SUPABASE_KEY=local-development-key
EOF
    echo "✅ Файл .env створено з базовими налаштуваннями"
fi

# Перевіряємо які сервіси існують
echo "🔍 Перевірка наявних сервісів..."
echo "==============================="

available_services=()
profiles_to_start=()

# Базові сервіси (завжди запускаються)
available_services+=("postgres" "redis" "frontend" "chat-assistant")

# Перевіряємо наявність папок для SubLab сервісів
declare -A sublab_services=(
    ["sublab-v1"]="SubLab V1 (Orchestrator)"
    ["sublab-v2"]="SubLab V2 (Modules & Images)"
    ["sublab-v3"]="SubLab V3 (Audio Generation)"
    ["sublab-v4"]="SubLab V4 (Audio Assembly)"
    ["sublab-v5"]="SubLab V5 (Audio Mixing)"
)

for service in "${!sublab_services[@]}"; do
    if [ -d "./$service" ]; then
        echo "✅ Знайдено: ${sublab_services[$service]} (./$service)"
        available_services+=("$service")
        profiles_to_start+=("$service")
    else
        echo "⏭️  Пропущено: ${sublab_services[$service]} (папка ./$service не існує)"
    fi
done

echo ""
echo "📋 Сервіси для запуску:"
echo "======================="
echo "• PostgreSQL (База даних)"
echo "• Redis (Кеш та черги)"
echo "• Frontend (React App)"
echo "• Chat Assistant API"

for service in "${!sublab_services[@]}"; do
    if [ -d "./$service" ]; then
        echo "• ${sublab_services[$service]}"
    fi
done

echo ""

# Зупиняємо існуючі контейнери
echo "🛑 Зупинка існуючих контейнерів..."
docker-compose down

# Формуємо команду запуску з профілями
compose_command="docker-compose"
if [ ${#profiles_to_start[@]} -gt 0 ]; then
    for profile in "${profiles_to_start[@]}"; do
        compose_command="$compose_command --profile $profile"
    done
fi
compose_command="$compose_command up --build -d"

# Збираємо та запускаємо доступні сервіси
echo "🔨 Збірка та запуск доступних сервісів..."
echo "Команда: $compose_command"
eval $compose_command

# Чекаємо поки всі сервіси запустяться
echo "⏳ Очікування запуску сервісів..."
sleep 15

# Перевіряємо статус сервісів
echo "📊 Статус сервісів:"
echo "==================="

# Перевіряємо базові сервіси
if docker ps --format "table {{.Names}}" | grep -q "sublab-postgres"; then
    echo "✅ PostgreSQL (порт 5432) - працює"
else
    echo "❌ PostgreSQL (порт 5432) - не працює"
fi

if docker ps --format "table {{.Names}}" | grep -q "sublab-redis"; then
    echo "✅ Redis (порт 6379) - працює"
else
    echo "❌ Redis (порт 6379) - не працює"
fi

# Перевіряємо веб-сервіси
web_services=(
    "frontend:5173:Frontend"
    "chat-assistant:8001:Chat Assistant API"
)

for service in "${!sublab_services[@]}"; do
    if [ -d "./$service" ]; then
        port=$((8002 + ${service: -1} - 1))
        web_services+=("$service:$port:${sublab_services[$service]}")
    fi
done

for service_info in "${web_services[@]}"; do
    IFS=':' read -r service port name <<< "$service_info"
    
    if [ "$service" = "frontend" ]; then
        if curl -s -f "http://localhost:$port" > /dev/null 2>&1; then
            echo "✅ $name (порт $port) - працює"
        else
            echo "❌ $name (порт $port) - не працює"
        fi
    else
        if curl -s -f "http://localhost:$port/health" > /dev/null 2>&1; then
            echo "✅ $name (порт $port) - працює"
        else
            echo "❌ $name (порт $port) - не працює"
        fi
    fi
done

echo ""
echo "🎉 Запуск завершено!"
echo ""
echo "📋 Доступні сервіси:"
echo "===================="
echo "• PostgreSQL Database: localhost:5432"
echo "• Redis Cache: localhost:6379"
echo "• Frontend (React App): http://localhost:5173"
echo "• Chat Assistant API: http://localhost:8001"

for service in "${!sublab_services[@]}"; do
    if [ -d "./$service" ]; then
        port=$((8002 + ${service: -1} - 1))
        echo "• ${sublab_services[$service]}: http://localhost:$port"
    fi
done

echo ""
echo "📝 Корисні команди:"
echo "==================="
echo "• Переглянути логи: docker-compose logs -f [service-name]"
echo "• Зупинити всі сервіси: docker-compose down"
echo "• Перезапустити сервіс: docker-compose restart [service-name]"
echo "• Переглянути статус: docker-compose ps"
echo "• Підключитися до БД: psql postgresql://postgres:postgres123@localhost:5432/sublab_db"
echo ""
echo "💡 Щоб додати новий SubLab сервіс:"
echo "1. Створіть папку ./sublab-vX (наприклад ./sublab-v1)"
echo "2. Додайте Dockerfile в папку"
echo "3. Перезапустіть скрипт - сервіс буде автоматично виявлено!"
echo ""