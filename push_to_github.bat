@echo off
chcp 65001 >nul
echo ========================================================
echo   HUONG DAN DAY CODE LEN GITHUB DE XUAT FILE APK
echo ========================================================
echo.
set /p REPO_URL="Nhap link GitHub Repository cua ban (Vi du: https://github.com/user/rubik-app.git): "

if "%REPO_URL%"=="" (
    echo Vui long nhap dung link repository GitHub!
    pause
    exit /b
)

echo.
echo [1/5] Khoi tao Git...
git init

echo [2/5] Them tat ca tep tin vao Git...
git add .

echo [3/5] Tao Commit...
git commit -m "feat: Rubik 3D AI Solver app with GitHub Actions build APK"

echo [4/5] Chuyen sang nhanh main...
git branch -M main

echo [5/5] Ket noi va day len GitHub...
git remote remove origin 2>nul
git remote add origin %REPO_URL%
git push -u origin main --force

echo.
echo ========================================================
echo   THANH CONG!
echo   Vao muc 'Actions' tren repository GitHub cua ban de xem
echo   qua trinh dong goi APK va tai file app-release.apk ve!
echo ========================================================
pause
