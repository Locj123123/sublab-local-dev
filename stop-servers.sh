#!/bin/bash

# SubLab Local Development Server Stop Script
# Цей скрипт зупиняє всі сервери SubLab

echo "🛑 Зупинка SubLab серверів..."
echo "============================="

# Зупиняємо всі контейнери
docker-compose down

echo "✅ Всі сервери зупинено"
echo ""
echo "📝 Для повного очищення виконайте:"
echo "docker-compose down -v --remove-orphans"
