@echo off
echo 🌐 Setting up NeuroGO web files...

set PROJECT_ROOT=%cd%
echo 📂 Project root: %PROJECT_ROOT%

REM Create necessary directories
if not exist "web" mkdir web
if not exist "web\static" mkdir web\static

echo ✅ Directories created

echo 📝 Creating web files...

REM Create a simple index.html for Windows
echo ^<!DOCTYPE html^> > web\index.html
echo ^<html^>^<head^>^<title^>NeuroGO^</title^>^</head^> >> web\index.html
echo ^<body^>^<h1^>NeuroGO Playground^</h1^>^<p^>Web files created successfully!^</p^>^</body^>^</html^> >> web\index.html

echo ✅ Basic web files created
echo 🔧 For full functionality, run the Linux setup script or manually copy the files
echo 🎉 Setup complete!
pause
