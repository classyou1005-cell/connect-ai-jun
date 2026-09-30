# MiroFish 윈도우 자동 설치 스크립트
# 1_install.bat 을 더블클릭하면 이 파일이 실행됩니다.

$ErrorActionPreference = 'Stop'
$InstallDir = Join-Path $HOME 'MiroFish'
$RepoUrl = 'https://github.com/666ghj/MiroFish.git'

function Say($msg, $color = 'Cyan') { Write-Host "`n>> $msg" -ForegroundColor $color }

function Refresh-Path {
    # 방금 설치한 프로그램을 이 창에서 바로 쓸 수 있도록 PATH 새로고침
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machine;$user;$HOME\.local\bin"
}

function Ensure-Tool($command, $wingetId, $name) {
    if (Get-Command $command -ErrorAction SilentlyContinue) {
        Write-Host "   [OK] $name 이미 설치됨" -ForegroundColor Green
        return
    }
    Say "$name 설치 중... (몇 분 걸릴 수 있어요)"
    winget install --id $wingetId -e --silent --accept-package-agreements --accept-source-agreements
    Refresh-Path
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "$name 설치를 확인하지 못했어요. 이 창을 닫고 1_install.bat 을 다시 실행해 주세요."
    }
    Write-Host "   [OK] $name 설치 완료" -ForegroundColor Green
}

try {
    Write-Host '==========================================' -ForegroundColor Yellow
    Write-Host '        MiroFish 자동 설치를 시작합니다' -ForegroundColor Yellow
    Write-Host '==========================================' -ForegroundColor Yellow

    # 1. 준비물 설치 (Python은 uv가 알아서 받아옵니다)
    Say '1/4 준비물 확인 (Git, Node.js, uv)'
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "winget 이 없어요. Microsoft Store에서 '앱 설치 관리자(App Installer)'를 업데이트한 뒤 다시 실행해 주세요."
    }
    Ensure-Tool 'git'  'Git.Git'            'Git'
    Ensure-Tool 'node' 'OpenJS.NodeJS.LTS'  'Node.js'
    Ensure-Tool 'uv'   'astral-sh.uv'       'uv'

    # 2. MiroFish 내려받기
    Say "2/4 MiroFish 내려받기 → $InstallDir"
    if (Test-Path (Join-Path $InstallDir '.git')) {
        git -C $InstallDir pull --ff-only
    } else {
        git clone --depth 1 $RepoUrl $InstallDir
    }

    # 3. API 키 설정 (.env)
    $envPath = Join-Path $InstallDir '.env'
    if (Test-Path $envPath) {
        Say '3/4 .env 파일이 이미 있어서 그대로 둡니다 (키를 바꾸려면 메모장으로 .env 를 여세요)'
    } else {
        Say '3/4 API 키 입력'
        Write-Host '   Gemini 키 발급: https://aistudio.google.com/apikey'
        Write-Host '   Zep 키 발급   : https://app.getzep.com'
        $gemini = (Read-Host '   Gemini API 키를 붙여넣고 Enter').Trim()
        $zep = (Read-Host '   Zep API 키를 붙여넣고 Enter').Trim()
        if (-not $gemini -or -not $zep) { throw '키가 비어 있어요. 두 키를 발급받은 뒤 다시 실행해 주세요.' }

        $envText = @"
# AI 모델 (Gemini 무료 키, OpenAI 호환 주소)
LLM_API_KEY=$gemini
LLM_BASE_URL=https://generativelanguage.googleapis.com/v1beta/openai/
LLM_MODEL_NAME=gemini-3.1-flash-lite-preview

# 기억 저장소
ZEP_API_KEY=$zep

# 내 컴퓨터에서만 접속 가능하게
FLASK_HOST=127.0.0.1
"@
        # BOM 없는 UTF-8로 저장 (BOM이 있으면 첫 줄 키를 못 읽을 수 있음)
        [IO.File]::WriteAllText($envPath, $envText, (New-Object System.Text.UTF8Encoding($false)))
        Write-Host '   [OK] .env 저장 완료' -ForegroundColor Green
    }

    # 4. 부품 설치
    Say '4/4 부품 설치 (5~10분 걸려요. 창을 닫지 마세요)'
    Push-Location $InstallDir
    npm run setup:all
    if ($LASTEXITCODE -ne 0) { throw '부품 설치 중 오류가 났어요. 위의 빨간 글씨를 복사해서 Claude에게 보여주세요.' }
    Pop-Location

    Write-Host "`n==========================================" -ForegroundColor Green
    Write-Host '  설치 완료! 이제 2_start.bat 을 더블클릭하세요' -ForegroundColor Green
    Write-Host '==========================================' -ForegroundColor Green
}
catch {
    Write-Host "`n[오류] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host '이 창의 내용을 복사해서 Claude에게 보여주면 해결을 도와드려요.' -ForegroundColor Yellow
}
