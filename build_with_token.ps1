# PowerShell Script tu dong tao Repo, Day Code va Build APK bang GitHub Token
param (
    [string]$Token,
    [string]$RepoName = "rubik-ai-solver"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   RUBIK 3D AI SOLVER - BUILD APK QUA GITHUB TOKEN TU DONG   " -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Kiem tra hoac yeu cau nhap Token
if (-not $Token) {
    Write-Host "👉 Vui lòng nhập GitHub Personal Access Token (PAT):" -ForegroundColor Yellow
    Write-Host "   (Token có dạng ghp_xxxx hoặc github_pat_xxxx với quyền 'repo' và 'workflow')" -ForegroundColor DarkGray
    $Token = Read-Host "GitHub Token"
}

$Token = $Token.Trim()

if ([string]::IsNullOrWhiteSpace($Token)) {
    Write-Host "❌ Token không được để trống!" -ForegroundColor Red
    exit
}

# 2. Xac thuc Token qua GitHub API
Write-Host "`n[1/5] Đang xác thực GitHub Token..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $Token"
    "User-Agent" = "Rubik-AI-Solver-Build"
    "Accept" = "application/vnd.github+json"
}

try {
    $userProfile = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers -Method Get
    $username = $userProfile.login
    Write-Host "✅ Xác thực thành công! Tài khoản GitHub: @$username" -ForegroundColor Green
} catch {
    Write-Host "❌ Token không hợp lệ hoặc đã hết hạn! Vui lòng kiểm tra lại." -ForegroundColor Red
    Write-Host "Chi tiết lỗi: $_" -ForegroundColor DarkRed
    exit
}

# 3. Kiem tra hoac tao Repository tren GitHub
Write-Host "`n[2/5] Đang kiểm tra repository '$RepoName' trên GitHub..." -ForegroundColor Yellow
$repoExists = $false
try {
    $repoCheck = Invoke-RestMethod -Uri "https://api.github.com/repos/$username/$RepoName" -Headers $headers -Method Get
    $repoExists = $true
    Write-Host "ℹ️ Repository '$RepoName' đã tồn tại." -ForegroundColor Cyan
} catch {
    $repoExists = $false
}

if (-not $repoExists) {
    Write-Host "Tạo mới repository '$RepoName' trên GitHub..." -ForegroundColor Yellow
    $body = @{
        name = $RepoName
        description = "Rubik 3D AI Solver & Simulator with GitHub Actions build APK"
        private = $false
        auto_init = $false
    } | ConvertTo-Json

    try {
        $newRepo = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Headers $headers -Method Post -Body $body
        Write-Host "✅ Đã tạo repository thành công: https://github.com/$username/$RepoName" -ForegroundColor Green
    } catch {
        Write-Host "❌ Không thể tạo repository: $_" -ForegroundColor Red
        exit
    }
}

# 4. Day code len GitHub
Write-Host "`n[3/5] Đang đẩy toàn bộ code lên GitHub..." -ForegroundColor Yellow
$remoteUrl = "https://oauth2:${Token}@github.com/${username}/${RepoName}.git"

git remote remove origin 2>$null
git remote add origin $remoteUrl
git branch -M main

$pushResult = git push -u origin main --force 2>&1
Write-Host $pushResult -ForegroundColor DarkGray
Write-Host "✅ Đã đẩy mã nguồn lên nhánh 'main' thành công!" -ForegroundColor Green

# 5. Theo doi qua trinh Build APK tren GitHub Actions
Write-Host "`n[4/5] Kích hoạt GitHub Actions..." -ForegroundColor Yellow
Write-Host "Đang kết nối theo dõi quá trình biên dịch APK..." -ForegroundColor Cyan

$actionUrl = "https://github.com/$username/$RepoName/actions"
Write-Host "👉 Bạn có thể xem trực tiếp tại: $actionUrl" -ForegroundColor White

Start-Sleep -Seconds 5

$maxAttempts = 40
$attempt = 0
$runId = $null

while ($attempt -lt $maxAttempts) {
    $attempt++
    try {
        $runsResponse = Invoke-RestMethod -Uri "https://api.github.com/repos/$username/$RepoName/actions/runs?per_page=1" -Headers $headers -Method Get
        if ($runsResponse.workflow_runs.Count -gt 0) {
            $latestRun = $runsResponse.workflow_runs[0]
            $status = $latestRun.status
            $conclusion = $latestRun.conclusion
            $runId = $latestRun.id

            if ($status -eq "completed") {
                if ($conclusion -eq "success") {
                    Write-Host "`n================================================================" -ForegroundColor Green
                    Write-Host "🎉 CHÚC MỪNG! APK ĐÃ ĐƯỢC BIÊN DỊCH THÀNH CÔNG!" -ForegroundColor Green
                    Write-Host "================================================================" -ForegroundColor Green
                    
                    # Lay link Artifacts
                    $artifactsResponse = Invoke-RestMethod -Uri "https://api.github.com/repos/$username/$RepoName/actions/runs/$runId/artifacts" -Headers $headers -Method Get
                    if ($artifactsResponse.artifacts.Count -gt 0) {
                        $apkArtifact = $artifactsResponse.artifacts[0]
                        Write-Host "📦 File Artifact: $($apkArtifact.name) ($([math]::Round($apkArtifact.size_in_bytes / 1MB, 2)) MB)" -ForegroundColor Cyan
                    }
                    
                    Write-Host "`n👉 Tải file APK tại đây:" -ForegroundColor Yellow
                    Write-Host "   https://github.com/$username/$RepoName/actions/runs/$runId" -ForegroundColor White
                    
                    Start-Process "https://github.com/$username/$RepoName/actions/runs/$runId"
                    break
                } else {
                    Write-Host "`n❌ Build thất bại với kết quả: $conclusion" -ForegroundColor Red
                    Write-Host "Chi tiết: https://github.com/$username/$RepoName/actions/runs/$runId" -ForegroundColor Yellow
                    break
                }
            } else {
                Write-Host "⏳ Đang build APK... Trạng thái: $status ($($attempt * 10)s)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "⏳ Đang chờ GitHub Actions khởi động..." -ForegroundColor DarkGray
        }
    } catch {
        Write-Host "⏳ Đang kiểm tra trạng thái..." -ForegroundColor DarkGray
    }
    Start-Sleep -Seconds 10
}

Write-Host "`nHoàn tất quá trình!" -ForegroundColor Green
