# PowerShell скрипт остановки Hugo сервера и освобождения ресурсов
# Находит и завершает все процессы Hugo, освобождает порт 1313

Write-Host "🛑 Остановка Hugo сервера..." -ForegroundColor Yellow

# Поиск и завершение процессов Hugo
$hugoProcesses = Get-Process -Name "hugo" -ErrorAction SilentlyContinue

if ($hugoProcesses) {
    Write-Host "📋 Найдены процессы Hugo: $($hugoProcesses.Id -join ', ')" -ForegroundColor Cyan
    
    # Мягкое завершение процессов
    Write-Host "🔄 Завершение процессов Hugo..." -ForegroundColor Yellow
    $hugoProcesses | Stop-Process -Force
    
    # Ждем 3 секунды для корректного завершения
    Start-Sleep -Seconds 3
    
    # Проверяем, завершились ли процессы
    $remainingProcesses = Get-Process -Name "hugo" -ErrorAction SilentlyContinue
    
    if ($remainingProcesses) {
        Write-Host "⚠️  Принудительное завершение оставшихся процессов..." -ForegroundColor Red
        $remainingProcesses | Stop-Process -Force
    }
    
    Write-Host "✅ Процессы Hugo завершены" -ForegroundColor Green
} else {
    Write-Host "ℹ️  Активные процессы Hugo не найдены" -ForegroundColor Cyan
}

# Проверка и освобождение порта 1313
Write-Host "🔍 Проверка порта 1313..." -ForegroundColor Cyan
$portConnection = Get-NetTCPConnection -LocalPort 1313 -ErrorAction SilentlyContinue

if ($portConnection) {
    $portPID = $portConnection.OwningProcess
    Write-Host "📋 Порт 1313 занят процессом: $portPID" -ForegroundColor Cyan
    Write-Host "🔄 Освобождение порта 1313..." -ForegroundColor Yellow
    
    try {
        Stop-Process -Id $portPID -Force
        Write-Host "✅ Порт 1313 освобожден" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Не удалось завершить процесс $portPID" -ForegroundColor Yellow
    }
} else {
    Write-Host "ℹ️  Порт 1313 свободен" -ForegroundColor Cyan
}

# Остановка фоновых задач Hugo
if (Test-Path "hugo-dev-job.txt") {
    $jobId = Get-Content "hugo-dev-job.txt" -ErrorAction SilentlyContinue
    if ($jobId) {
        $job = Get-Job -Id $jobId -ErrorAction SilentlyContinue
        if ($job) {
            Write-Host "🔄 Остановка фоновой задачи Hugo (ID: $jobId)..." -ForegroundColor Yellow
            Stop-Job -Id $jobId
            Remove-Job -Id $jobId
            Write-Host "✅ Фоновая задача остановлена" -ForegroundColor Green
        }
    }
    Remove-Item "hugo-dev-job.txt" -ErrorAction SilentlyContinue
}

# Очистка временных файлов Hugo
Write-Host "🧹 Очистка временных файлов..." -ForegroundColor Cyan
if (Test-Path "resources\_gen") {
    Remove-Item "resources\_gen" -Recurse -Force
    Write-Host "✅ Временные файлы удалены" -ForegroundColor Green
}

# Удаление лог-файла
if (Test-Path "hugo-dev.log") {
    Remove-Item "hugo-dev.log" -Force
    Write-Host "✅ Лог-файл удален" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 Hugo сервер полностью остановлен и ресурсы освобождены!" -ForegroundColor Green
Write-Host "💡 Для запуска используйте: ./start-dev.ps1" -ForegroundColor Cyan
