@echo off
echo ===================================================
echo Instalando Git Hooks de Calidad de Codigo para Flutter
echo ===================================================

copy /Y .git\hooks\pre-commit .git\hooks\pre-commit
echo [OK] Hook pre-commit configurado exitosamente.
echo Ahora Git verificara formato, flutter analyze y flutter test antes de cada commit.
pause
