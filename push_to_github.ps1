# PowerShell Script de day code len GitHub va build APK tu dong qua GitHub Actions
param (
    [string]$RepoUrl
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   RUBIK 3D AI SOLVER - PUSH CODE VA BUILD APK GITHUB   " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

if (-not $RepoUrl) {
    $RepoUrl = Read-Host "Nhập link GitHub Repository của bạn (VD: https://github.com/username/rubik-ai.git)"
}

if ([string]::IsNullOrWhiteSpace($RepoUrl)) {
    Write-Host "❌ Bạn chưa nhập URL repository!" -ForegroundColor Red
    exit
}

Write-Host "`n[1/5] Khởi tạo Git..." -ForegroundColor Yellow
git init

Write-Host "[2/5] Đánh dấu tất cả tệp tin..." -ForegroundColor Yellow
git add .

Write-Host "[3/5] Tạo commit..." -ForegroundColor Yellow
git commit -m "feat: Rubik 3D AI Simulator & Solver with GitHub Actions APK build"

Write-Host "[4/5] Đổi tên nhánh chính thành 'main'..." -ForegroundColor Yellow
git branch -M main

Write-Host "[5/5] Đẩy code lên GitHub: $RepoUrl ..." -ForegroundColor Yellow
git remote remove origin 2>$null
git remote add origin $RepoUrl
git push -u origin main --force

Write-Host "`n========================================================" -ForegroundColor Green
Write-Host "🎉 HOÀN TẤT! CODE ĐÃ ĐƯỢC ĐẨY LÊN GITHUB THÀNH CÔNG!" -ForegroundColor Green
Write-Host "👉 Hãy mở trình duyệt và truy cập:" -ForegroundColor White
Write-Host "   $RepoUrl/actions" -ForegroundColor Cyan
Write-Host "   GitHub Actions đang tự động compile và xuất file APK cho bạn." -ForegroundColor White
Write-Host "   Sau khoảng 2-3 phút, tải file 'Rubik-AI-Solver-Release-APK' về điện thoại để cài đặt!" -ForegroundColor White
Write-Host "========================================================`n" -ForegroundColor Green
