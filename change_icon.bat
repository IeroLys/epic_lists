@echo off
if "%1"=="" (
    echo ❌ Укажи путь к иконке: change_icon.bat icon.png
    exit /b 1
)
copy /Y "%1" assets\app_icon.png
echo ✅ Иконка заменена
dart run flutter_launcher_icons
echo 🎉 Готово!