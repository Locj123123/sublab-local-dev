#!/bin/bash

# SubLab Server Testing Script
# Цей скрипт тестує всі сервери та їх функціональність

echo "🧪 Запуск тестування SubLab серверів..."
echo "======================================"

# Кольори для виводу
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функція для логування
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Функція для тестування HTTP ендпоінту
test_endpoint() {
    local url=$1
    local name=$2
    local expected_status=${3:-200}
    
    log_info "Тестування $name: $url"
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" --max-time 10)
    
    if [ "$response" = "$expected_status" ]; then
        log_success "$name - HTTP $response"
        return 0
    else
        log_error "$name - HTTP $response (очікувалося $expected_status)"
        return 1
    fi
}

# Функція для тестування JSON API
test_json_api() {
    local url=$1
    local name=$2
    local expected_keys=$3
    
    log_info "Тестування JSON API $name: $url"
    
    response=$(curl -s "$url" --max-time 10)
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" --max-time 10)
    
    if [ "$http_code" = "200" ]; then
        # Перевіряємо чи відповідь є валідним JSON
        if echo "$response" | jq . > /dev/null 2>&1; then
            log_success "$name - JSON API працює"
            return 0
        else
            log_error "$name - Невалідний JSON відповідь"
            return 1
        fi
    else
        log_error "$name - HTTP $http_code"
        return 1
    fi
}

# Функція для тестування Supabase API
test_supabase_api() {
    local endpoint=$1
    local name=$2
    local apikey="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
    
    log_info "Тестування Supabase API $name: $endpoint"
    
    response=$(curl -s "$endpoint" -H "apikey: $apikey" --max-time 10)
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "$endpoint" -H "apikey: $apikey" --max-time 10)
    
    if [ "$http_code" = "200" ]; then
        log_success "$name - Supabase API працює"
        return 0
    else
        log_error "$name - HTTP $http_code"
        return 1
    fi
}

# Лічильники
total_tests=0
passed_tests=0
failed_tests=0

# Функція для запуску тесту
run_test() {
    local test_name=$1
    local test_function=$2
    shift 2
    local test_args=("$@")
    
    total_tests=$((total_tests + 1))
    
    if $test_function "${test_args[@]}"; then
        passed_tests=$((passed_tests + 1))
    else
        failed_tests=$((failed_tests + 1))
    fi
}

echo ""
log_info "🔍 Перевірка доступності сервісів..."

# Тестуємо базові сервіси
run_test "Supabase API" test_endpoint "http://localhost:54321/rest/v1/" "Supabase REST API" 200
run_test "Supabase Studio" test_endpoint "http://localhost:54323" "Supabase Studio" 307
run_test "Frontend" test_endpoint "http://localhost:5173" "React Frontend" 200
run_test "Chat Assistant Health" test_endpoint "http://localhost:8001/health" "Chat Assistant API" 200

# Тестуємо Supabase API ендпоінти
run_test "Users API" test_supabase_api "http://localhost:54321/rest/v1/users?select=id,email&limit=1" "Users API"
run_test "Agents API" test_supabase_api "http://localhost:54321/rest/v1/agents?select=id,name&limit=1" "Agents API"
run_test "Token Balances API" test_supabase_api "http://localhost:54321/rest/v1/token_balances?select=user_id,balance&limit=1" "Token Balances API"
run_test "Languages API" test_supabase_api "http://localhost:54321/rest/v1/languages?select=id,language&limit=1" "Languages API"
run_test "Voices API" test_supabase_api "http://localhost:54321/rest/v1/voices?select=id,name&limit=1" "Voices API"
run_test "Music API" test_supabase_api "http://localhost:54321/rest/v1/music?select=id,track&limit=1" "Music API"

# Тестуємо тестового користувача
run_test "Test User" test_supabase_api "http://localhost:54321/rest/v1/users?email=eq.test@sublab.local" "Test User Data"

# Тестуємо SubLab сервіси (якщо вони запущені)
if curl -s -f "http://localhost:8002/health" > /dev/null 2>&1; then
    run_test "SubLab V1" test_endpoint "http://localhost:8002/health" "SubLab V1 (Orchestrator)" 200
else
    log_warning "SubLab V1 не запущений (порт 8002)"
fi

if curl -s -f "http://localhost:8003/health" > /dev/null 2>&1; then
    run_test "SubLab V2" test_endpoint "http://localhost:8003/health" "SubLab V2 (Modules & Images)" 200
else
    log_warning "SubLab V2 не запущений (порт 8003)"
fi

if curl -s -f "http://localhost:8004/health" > /dev/null 2>&1; then
    run_test "SubLab V3" test_endpoint "http://localhost:8004/health" "SubLab V3 (Audio Generation)" 200
else
    log_warning "SubLab V3 не запущений (порт 8004)"
fi

if curl -s -f "http://localhost:8005/health" > /dev/null 2>&1; then
    run_test "SubLab Audio Processor" test_endpoint "http://localhost:8005/health" "SubLab Audio Processor" 200
else
    log_warning "SubLab Audio Processor не запущений (порт 8005)"
fi

# Тестуємо Redis
log_info "Тестування Redis..."
if docker exec sublab-redis redis-cli ping > /dev/null 2>&1; then
    log_success "Redis - працює"
    passed_tests=$((passed_tests + 1))
else
    log_error "Redis - не працює"
    failed_tests=$((failed_tests + 1))
fi
total_tests=$((total_tests + 1))

# Тестуємо базу даних
log_info "Тестування бази даних..."
if docker exec supabase_db_frontsublab psql -U postgres -d postgres -c "SELECT 1;" > /dev/null 2>&1; then
    log_success "PostgreSQL - працює"
    passed_tests=$((passed_tests + 1))
else
    log_error "PostgreSQL - не працює"
    failed_tests=$((failed_tests + 1))
fi
total_tests=$((total_tests + 1))

# Перевіряємо тестові дані
log_info "Перевірка тестових даних..."

# Тестовий користувач
test_user_count=$(docker exec supabase_db_frontsublab psql -U postgres -d postgres -t -c "SELECT COUNT(*) FROM users WHERE email = 'test@sublab.local';" 2>/dev/null | tr -d ' \n')
if [ "$test_user_count" = "1" ]; then
    log_success "Тестовий користувач існує"
    passed_tests=$((passed_tests + 1))
else
    log_error "Тестовий користувач не знайдено"
    failed_tests=$((failed_tests + 1))
fi
total_tests=$((total_tests + 1))

# Тестовий агент
test_agent_count=$(docker exec supabase_db_frontsublab psql -U postgres -d postgres -t -c "SELECT COUNT(*) FROM agents WHERE agent_id = '999999';" 2>/dev/null | tr -d ' \n')
if [ "$test_agent_count" = "1" ]; then
    log_success "Тестовий агент існує"
    passed_tests=$((passed_tests + 1))
else
    log_error "Тестовий агент не знайдено"
    failed_tests=$((failed_tests + 1))
fi
total_tests=$((total_tests + 1))

# Баланс токенів
test_balance=$(docker exec supabase_db_frontsublab psql -U postgres -d postgres -t -c "SELECT balance FROM token_balances WHERE user_id = '00000000-0000-0000-0000-000000000001';" 2>/dev/null | tr -d ' \n')
if [ "$test_balance" = "1000000" ]; then
    log_success "Баланс токенів тестового користувача: $test_balance"
    passed_tests=$((passed_tests + 1))
else
    log_error "Неправильний баланс токенів: $test_balance"
    failed_tests=$((failed_tests + 1))
fi
total_tests=$((total_tests + 1))

echo ""
echo "📊 Результати тестування:"
echo "========================="
echo "Всього тестів: $total_tests"
echo -e "Пройдено: ${GREEN}$passed_tests${NC}"
echo -e "Провалено: ${RED}$failed_tests${NC}"

if [ $failed_tests -eq 0 ]; then
    echo ""
    log_success "🎉 Всі тести пройшли успішно!"
    echo ""
    echo "📋 Доступні сервіси для тестування:"
    echo "===================================="
    echo "• Supabase Studio: http://localhost:54323"
    echo "• Frontend: http://localhost:5173"
    echo "• Chat Assistant API: http://localhost:8001"
    echo "• Supabase API: http://localhost:54321/rest/v1/"
    echo ""
    echo "🧪 Тестові дані:"
    echo "================"
    echo "• Тестовий користувач: test@sublab.local"
    echo "• Тестовий агент ID: 999999"
    echo "• Баланс токенів: 1,000,000"
    echo ""
    echo "💡 Корисні команди:"
    echo "==================="
    echo "• Переглянути логи: docker-compose logs -f [service-name]"
    echo "• Підключитися до БД: docker exec -it supabase_db_frontsublab psql -U postgres -d postgres"
    echo "• Перезапустити сервіс: docker-compose restart [service-name]"
    exit 0
else
    echo ""
    log_error "❌ Деякі тести провалилися!"
    echo ""
    echo "🔧 Рекомендації для виправлення:"
    echo "================================"
    echo "• Перевірте чи всі сервіси запущені: docker-compose ps"
    echo "• Переглянути логи: docker-compose logs [service-name]"
    echo "• Перезапустити сервіси: docker-compose restart"
    echo "• Перезапустити всі сервіси: ./start-servers.sh"
    exit 1
fi
