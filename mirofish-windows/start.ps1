# MiroFish 실행 스크립트
# 2_start.bat 을 더블클릭하면 이 파일이 실행됩니다.

$InstallDir = Join-Path $HOME 'MiroFish'

if (-not (Test-Path (Join-Path $InstallDir '.env'))) {
    Write-Host '[오류] 아직 설치가 안 됐어요. 먼저 1_install.bat 을 실행해 주세요.' -ForegroundColor Red
    return
}

# 설치 직후에도 node / uv 를 찾을 수 있도록 PATH 새로고침
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')

Write-Host 'MiroFish를 켜는 중입니다...' -ForegroundColor Cyan
Write-Host '창이 2개 열립니다 (두뇌 / 화면). 끄려면 두 창을 모두 닫으세요.' -ForegroundColor Cyan

# 두뇌(백엔드) — .env 의 FLASK_HOST=127.0.0.1 덕분에 내 컴퓨터에서만 접속됨
Start-Process cmd -ArgumentList '/k', "title MiroFish 두뇌(백엔드) && cd /d `"$InstallDir\backend`" && uv run python run.py"

# 화면(프론트엔드) — 127.0.0.1 로만 열어서 같은 와이파이의 다른 사람은 접속 불가
Start-Process cmd -ArgumentList '/k', "title MiroFish 화면(프론트엔드) && cd /d `"$InstallDir\frontend`" && npx vite --host 127.0.0.1"

Write-Host "`n잠시 후 브라우저가 자동으로 열려요. 안 열리면 주소창에 http://localhost:3000 을 입력하세요." -ForegroundColor Green
Write-Host '처음에는 캐릭터 수와 라운드를 적게(10~20) 해서 테스트하세요!' -ForegroundColor Yellow
