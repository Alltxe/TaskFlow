# Локальная сборка образа backend и экспорт в tar для VPS
# Запуск из каталога backend: .\scripts\deploy\build-and-export.ps1

$ErrorActionPreference = "Stop"

$ImageName = "taskflow-backend:latest"
$OutputTar = "taskflow-backend.tar"
$Platform = "linux/amd64"

$BackendRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $BackendRoot

Write-Host "==> Сборка образа $ImageName ($Platform) в $BackendRoot ..." -ForegroundColor Cyan
docker build --platform $Platform -t $ImageName .

Write-Host "==> Экспорт в $OutputTar ..." -ForegroundColor Cyan
docker save $ImageName -o $OutputTar

$sizeMb = [math]::Round((Get-Item $OutputTar).Length / 1MB, 1)
Write-Host "Готово: $BackendRoot\$OutputTar ($sizeMb MB)" -ForegroundColor Green
Write-Host ""
Write-Host "Дальше на VPS:" -ForegroundColor Yellow
Write-Host "  scp taskflow-backend.tar docker-compose.prod.yml .env.production.example user@IP:~/taskflow/"
Write-Host "  см. DEPLOY_VPS.md"
