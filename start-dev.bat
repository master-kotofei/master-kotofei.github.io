@echo off
REM Batch скрипт запуска Hugo сервера в режиме разработки
REM Использует hugo.local.toml конфигурацию без аналитики

echo 🚀 Запуск Hugo сервера в режиме разработки...

REM Проверяем, не запущен ли уже сервер
netstat -an | findstr ":1313" >nul
if %errorlevel% equ 0 (
    echo ⚠️  Порт 1313 уже занят! Возможно, сервер уже запущен.
    echo 💡 Используйте stop-dev.bat для остановки
    pause
    exit /b 1
)

echo 📝 Конфигурация: hugo.local.toml
echo 🌐 Сервер будет доступен по адресу: http://localhost:1313
echo.

REM Запуск Hugo сервера
echo 🔄 Запуск Hugo сервера...
hugo server --config hugo.local.toml --bind 0.0.0.0 --port 1313 --buildDrafts --buildFuture --disableFastRender

if %errorlevel% equ 0 (
    echo ✅ Hugo сервер запущен успешно
) else (
    echo ❌ Ошибка запуска сервера!
    pause
    exit /b 1
)
