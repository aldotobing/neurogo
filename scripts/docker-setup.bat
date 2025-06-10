@echo off
setlocal enabledelayedexpansion

REM NeuroGO Docker Setup Script for Windows
echo 🧠 NeuroGO Docker Setup Script (Windows)
echo ========================================

REM Check if Docker is installed
echo [STEP] Checking Docker installation...
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed. Please install Docker Desktop first.
    echo Visit: https://docs.docker.com/desktop/windows/
    pause
    exit /b 1
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Compose is not installed. Please install Docker Compose first.
    pause
    exit /b 1
)
echo [INFO] Docker and Docker Compose are installed ✓

REM Check if Docker daemon is running
echo [STEP] Checking Docker daemon...
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker daemon is not running. Please start Docker Desktop first.
    pause
    exit /b 1
)
echo [INFO] Docker daemon is running ✓

REM Setup environment file
echo [STEP] Setting up environment file...
if not exist .env (
    copy .env.example .env >nul
    echo [INFO] Created .env file from template
    echo [WARNING] Please edit .env file to add your API keys if you have them
) else (
    echo [INFO] .env file already exists
)

REM Pull required Docker images
echo [STEP] Pulling required Docker images...
docker-compose pull ollama
if errorlevel 1 (
    echo [ERROR] Failed to pull Docker images
    pause
    exit /b 1
)
echo [INFO] Docker images pulled successfully ✓

REM Build NeuroGO image
echo [STEP] Building NeuroGO Docker image...
docker-compose build neurogo
if errorlevel 1 (
    echo [ERROR] Failed to build NeuroGO image
    pause
    exit /b 1
)
echo [INFO] NeuroGO image built successfully ✓

REM Start services
echo [STEP] Starting NeuroGO services...
docker-compose up -d
if errorlevel 1 (
    echo [ERROR] Failed to start services
    pause
    exit /b 1
)

echo [INFO] Services started! Waiting for them to be ready...

REM Wait for Ollama to be ready
echo [STEP] Waiting for Ollama to start...
set /a counter=0
set /a timeout=60

:wait_ollama
curl -s http://localhost:11434/api/tags >nul 2>&1
if not errorlevel 1 goto ollama_ready
if !counter! geq !timeout! (
    echo [ERROR] Ollama failed to start within !timeout! seconds
    pause
    exit /b 1
)
timeout /t 2 /nobreak >nul
set /a counter+=2
echo|set /p="."
goto wait_ollama

:ollama_ready
echo.
echo [INFO] Ollama is ready ✓

REM Pull a default model
echo [STEP] Pulling default Ollama model (llama3.1)...
docker-compose exec ollama ollama pull llama3.1
echo [INFO] Default model pulled ✓

REM Wait for NeuroGO to be ready
echo [STEP] Waiting for NeuroGO to start...
set /a counter=0

:wait_neurogo
curl -s http://localhost:8080/api/health >nul 2>&1
if not errorlevel 1 goto neurogo_ready
if !counter! geq !timeout! (
    echo [ERROR] NeuroGO failed to start within !timeout! seconds
    pause
    exit /b 1
)
timeout /t 2 /nobreak >nul
set /a counter+=2
echo|set /p="."
goto wait_neurogo

:neurogo_ready
echo.
echo [INFO] NeuroGO is ready ✓

REM Test the setup
echo [STEP] Testing NeuroGO setup...
curl -s http://localhost:8080/api/health | findstr "healthy" >nul
if errorlevel 1 (
    echo [ERROR] Health check failed
    pause
    exit /b 1
)
echo [INFO] Health check passed ✓

REM Test a simple command
curl -s -X POST http://localhost:8080/api/process -H "Content-Type: application/json" -d "{\"prompt\": \"help\"}" | findstr "NeuroGO" >nul
if errorlevel 1 (
    echo [ERROR] Command processing test failed
    pause
    exit /b 1
)
echo [INFO] Command processing test passed ✓

echo [INFO] All tests passed! ✓

REM Show final information
echo.
echo 🎉 NeuroGO is now running!
echo ==========================
echo.
echo 🌐 Playground UI: http://localhost:8080
echo 🔗 API Endpoint: http://localhost:8080/api
echo 🤖 Ollama API: http://localhost:11434
echo.
echo 📝 Try these commands in the playground:
echo   • help
echo   • status
echo   • chat hello world
echo   • generate code for a web server
echo.
echo 🛠️  Useful Docker commands:
echo   • docker-compose logs -f neurogo    # View logs
echo   • docker-compose stop               # Stop services
echo   • docker-compose down               # Stop and remove containers
echo   • docker-compose restart neurogo    # Restart NeuroGO
echo.
echo 📚 Edit .env file to add API keys for more providers!
echo.
pause
