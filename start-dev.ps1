# PowerShell скрипт запуска Hugo сервера в режиме разработки
# Использует hugo.local.toml конфигурацию без аналитики

Write-Host "🚀 Запуск Hugo сервера в режиме разработки..." -ForegroundColor Green

# Проверяем, не запущен ли уже сервер
$portCheck = Get-NetTCPConnection -LocalPort 1313 -ErrorAction SilentlyContinue
if ($portCheck) {
    Write-Host "⚠️  Порт 1313 уже занят! Возможно, сервер уже запущен." -ForegroundColor Yellow
    Write-Host "💡 Используйте ./stop-dev.ps1 для остановки" -ForegroundColor Cyan
    exit 1
}

Write-Host "📝 Конфигурация: hugo.local.toml" -ForegroundColor Cyan
Write-Host "🌐 Сервер будет доступен по адресу: http://localhost:1313" -ForegroundColor Cyan
Write-Host ""

# Запуск Hugo сервера в фоновом режиме
$job = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    hugo server --config hugo.local.toml --bind 0.0.0.0 --port 1313 --buildDrafts --buildFuture --disableFastRender
}

# Ждем немного, чтобы сервер успел запуститься
Start-Sleep -Seconds 3

# Проверяем, что процесс запустился успешно
if ($job.State -eq "Running") {
    Write-Host "✅ Hugo сервер успешно запущен в фоновом режиме (Job ID: $($job.Id))" -ForegroundColor Green
    Write-Host "📋 Для просмотра логов используйте: Receive-Job -Id $($job.Id)" -ForegroundColor Cyan
    Write-Host "🛑 Для остановки используйте: ./stop-dev.ps1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🎉 Управление возвращено в консоль. Сервер работает в фоне." -ForegroundColor Green
    
    # Сохраняем ID задачи в файл для остановки
    $job.Id | Out-File -FilePath "hugo-dev-job.txt" -Encoding UTF8
} else {
    Write-Host "❌ Ошибка запуска сервера! Проверьте статус задачи:" -ForegroundColor Red
    Receive-Job -Job $job
    Remove-Job -Job $job
    exit 1
}
