@echo off
REM Impression Share Dashboard — Daily Refresh
REM Runs: fetch -> build -> git push
REM Scheduled via Windows Task Scheduler (daily)

set GIT_DIR=C:\Users\crisc\OneDrive\Desktop\GIT
set SCRIPTS_DIR=%GIT_DIR%\work\scripts
set LOG=%GIT_DIR%\is_update.log

echo ======================================== >> %LOG%
echo %DATE% %TIME% — Starting IS refresh >> %LOG%

REM 1. Fetch fresh data from Google Ads API
python "%SCRIPTS_DIR%\fetch_is_data.py" >> %LOG% 2>&1
if %errorlevel% neq 0 (
    echo ERROR: fetch_is_data.py failed >> %LOG%
    exit /b 1
)

REM 2. Build JS data files
python "%GIT_DIR%\build_is_data.py" >> %LOG% 2>&1
if %errorlevel% neq 0 (
    echo ERROR: build_is_data.py failed >> %LOG%
    exit /b 1
)

REM 3. Commit and push to GitHub Pages
cd /d "%GIT_DIR%"
git add is-data.js auction-data.js >> %LOG% 2>&1
git commit -m "IS dashboard update %DATE%" >> %LOG% 2>&1
git push origin main >> %LOG% 2>&1
if %errorlevel% neq 0 (
    echo ERROR: git push failed >> %LOG%
    exit /b 1
)

echo %DATE% %TIME% — Done >> %LOG%
echo ======================================== >> %LOG%
