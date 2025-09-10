@echo off
REM Batch скрипт остановки Hugo сервера и освобождения ресурсов

echo 🛑 Остановка Hugo сервера...

REM Поиск и завершение процессов Hugo
echo 🔍 Поиск процессов Hugo...
tasklist /FI "IMAGENAME eq hugo.exe" 2>nul | find /I "hugo.exe" >nul
if %errorlevel% equ 0 (
    echo 📋 Найдены процессы Hugo
    echo 🔄 Завершение процессов Hugo...
    taskkill /F /IM hugo.exe >nul 2>&1
    timeout /t 2 >nul
    echo ✅ Процессы Hugo завершены
) else (
    echo ℹ️  Активные процессы Hugo не найдены
)

REM Проверка и освобождение порта 1313
echo 🔍 Проверка порта 1313...
netstat -ano | findstr ":1313" >nul
if %errorlevel% equ 0 (
    echo 📋 Порт 1313 занят
    echo 🔄 Попытка освобождения порта...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":1313"') do (
        taskkill /F /PID %%a >nul 2>&1
    )
    echo ✅ Порт 1313 освобожден
) else (
    echo ℹ️  Порт 1313 свободен
)

REM Очистка временных файлов Hugo
echo 🧹 Очистка временных файлов...
if exist "resources\_gen" (
    rmdir /s /q "resources\_gen" >nul 2>&1
    echo ✅ Временные файлы удалены
)

REM Удаление лог-файла
if exist "hugo-dev.log" (
    del "hugo-dev.log" >nul 2>&1
    echo ✅ Лог-файл удален
)

echo.
echo 🎉 Hugo сервер полностью остановлен и ресурсы освобождены!
echo 💡 Для запуска используйте: start-dev.bat
pause
