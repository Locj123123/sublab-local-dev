#!/bin/bash

# SubLab Local Development Server Startup Script
# Цей скрипт запускає лише існуючі сервери SubLab локально з єдиною базою даних Supabase

echo "🚀 Запуск SubLab серверів локально з єдиною базою даних..."
echo "========================================================"

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

# Перевіряємо наявність файлу .env
if [ ! -f ".env" ]; then
    echo "❌ Файл .env не знайдено!"
    echo "Будь ласка, створіть файл .env з вашими API ключами"
    echo "Приклад:"
    echo "OPENAI_API_KEY=your_openai_key"
    echo "ELEVENLABS_API_KEY=your_elevenlabs_key"
    echo "REPLICATE_API_TOKEN=your_replicate_token"
    echo "VITE_STRIPE_PUBLIC_KEY=your_stripe_key"
    exit 1
else
    echo "✅ Файл .env знайдено"
fi

# Перевіряємо які сервіси існують
echo "🔍 Перевірка наявних сервісів..."
echo "==============================="

available_services=()
profiles_to_start=()

# Базові сервіси (завжди запускаються)
available_services+=("supabase" "redis" "frontend" "chat-assistant")

# Перевіряємо наявність папок для SubLab сервісів
declare -A sublab_services=(
    ["sublab-v1"]="SubLab V1 (Orchestrator)"
    ["sublab-v2"]="SubLab V2 (Modules & Images)"
    ["sublab-v3"]="SubLab V3 (Audio Generation)"
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
echo "• Supabase Local (Єдина база даних та API для всіх сервісів)"
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

# Запускаємо Supabase CLI локально
echo "🗄️ Запуск локального Supabase..."
cd frontsublab
if ! supabase status > /dev/null 2>&1; then
    echo "Запуск Supabase CLI..."
    supabase start
else
    echo "✅ Supabase CLI вже запущений"
fi
cd ..

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
if curl -s -f "http://localhost:54321/rest/v1/" > /dev/null 2>&1; then
    echo "✅ Supabase Local (порт 54321) - працює"
else
    echo "❌ Supabase Local (порт 54321) - не працює"
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
echo "• Supabase Database (Єдина БД): localhost:54321 (API) / localhost:54322 (PostgreSQL)"
echo "• Supabase Studio: http://localhost:54323"
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
echo "• Підключитися до Supabase БД: psql postgresql://postgres:postgres@localhost:54322/postgres"
echo ""
echo "💡 Щоб додати новий SubLab сервіс:"
echo "1. Створіть папку ./sublab-vX (наприклад ./sublab-v1)"
echo "2. Додайте Dockerfile в папку"
echo "3. Перезапустіть скрипт - сервіс буде автоматично виявлено!"
echo ""