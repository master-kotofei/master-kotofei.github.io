@echo off
chcp 65001 >nul
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
start /B "Hugo Server" cmd /c "hugo server --config hugo.local.toml --bind 0.0.0.0 --port 1313 --buildDrafts --buildFuture --disableFastRender > hugo-dev.log 2>&1"

REM Ждем немного, чтобы сервер успел запуститься
timeout /t 3 /nobreak >nul

REM Проверяем, что сервер запустился
netstat -an | findstr ":1313" >nul
if %errorlevel% equ 0 (
    echo ✅ Hugo сервер запущен успешно в фоновом режиме
    echo 🌐 Сервер доступен по адресу: http://localhost:1313
    echo 📋 Логи сохраняются в файл: hugo-dev.log
    echo 🛑 Для остановки используйте: stop-dev.bat
    echo.
    echo 🎉 Управление возвращено в консоль. Сервер работает в фоне.
) else (
    echo ❌ Ошибка запуска сервера! Проверьте логи в файле hugo-dev.log
    pause
    exit /b 1
)
