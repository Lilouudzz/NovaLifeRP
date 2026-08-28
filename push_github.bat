@echo off
REM ============================================================
REM  NovaLife RP — Initialisation Git + Push GitHub
REM  Compte cible : github.com/Laya-vtc  (repo: NovaLifeRP)
REM ============================================================
REM  AVANT DE LANCER :
REM  1. Crée le repo "NovaLifeRP" sur https://github.com/Laya-vtc
REM     (Public ou Private, NE PAS ajouter de README/.gitignore auto)
REM  2. Crée un token : GitHub > Settings > Developer settings >
REM     Personal access tokens (PAT) > "repo" (read/write).
REM  3. Quand Git demande identifiant : mettez votre PSEUDO GitHub
REM     Mot de passe : collez le TOKEN (pas votre vrai mot de passe).
REM  (ou utilisez Git Credential Manager qui s'ouvrira)
REM ============================================================

cd /d "%~dp0"

if not exist .git (
    git init
    git branch -M main
    git add .
    git commit -m "NovaLife RP — base serveur GTA RP (core, jobs, owner panel, addon vehicules, apparence)"
)

REM Adaptez l'URL si besoin (https obligatoire sans clé SSH)
git remote remove origin 2>nul
git remote add origin https://github.com/Laya-vtc/NovaLifeRP.git

echo.
echo PUSH vers Laya-vtc/NovaLifeRP ...
git push -u origin main

if %errorlevel%==0 (
    echo.
    echo ✅ Depot pousse avec succes !
) else (
    echo.
    echo ❌ Echec du push. Verifiez : repo cree sur GitHub ? token valide (scope repo) ?
    echo    URL : https://github.com/Laya-vtc/NovaLifeRP
)
pause
