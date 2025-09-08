#!/bin/bash

# SubLab Local Development Server Stop Script
# Цей скрипт зупиняє всі сервери SubLab

echo "🛑 Зупинка SubLab серверів..."
echo "============================="

# Зупиняємо всі контейнери
docker-compose down

# Зупиняємо Supabase CLI
echo "🗄️ Зупинка локального Supabase..."
cd frontsublab
supabase stop
cd ..

echo "✅ Всі сервери зупинено"
echo ""
echo "📝 Для повного очищення виконайте:"
echo "docker-compose down -v --remove-orphans"
