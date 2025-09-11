@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
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
set PORT_FOUND=0
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":1313"') do (
    if not "%%a"=="0" (
        set PORT_FOUND=1
        echo 📋 Порт 1313 занят процессом с PID: %%a
        echo 🔄 Завершение процесса с PID: %%a
        taskkill /F /PID %%a >nul 2>&1
        if !errorlevel! equ 0 (
            echo ✅ Процесс %%a завершен
        ) else (
            echo ⚠️  Не удалось завершить процесс %%a
        )
    )
)
if !PORT_FOUND! equ 0 (
    echo ℹ️  Порт 1313 свободен или содержит только TIME_WAIT соединения
    echo ✅ Порт готов к использованию
) else (
    timeout /t 2 >nul
    netstat -ano | findstr ":1313" | findstr /v "TIME_WAIT" >nul
    if %errorlevel% equ 0 (
        echo ⚠️  Порт 1313 все еще занят активными процессами
    ) else (
        echo ✅ Порт 1313 освобожден
    )
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
