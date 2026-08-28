@echo off
REM ============================================================
REM  NovaLife RP — Lanceur FXServer (Windows)
REM  Placez ce fichier à la racine de votre dossier FXServer
REM  (au même niveau que FXServer.exe / run.cmd).
REM  Le dossier du serveur (NovaLifeRP) doit être copié dans
REM  le dossier "resources" de FXServer, OU vous pointez
REM  server.cfg vers le bon chemin.
REM ============================================================

cd /d "%~dp0"
IF NOT EXIST server.cfg (
    echo [NovaLife] server.cfg introuvable. Copiez server.cfg.example -> server.cfg et renseignez CHANGE_ME.
    pause
    exit /b 1
)

echo [NovaLife] Demarrage du serveur...
REM Ajustez le chemin de l'executable FXServer si besoin
IF EXIST FXServer.exe (
    FXServer.exe +exec server.cfg
) ELSE IF EXIST run.cmd (
    call run.cmd +exec server.cfg
) ELSE (
    echo [NovaLife] FXServer.exe introuvable dans ce dossier.
    pause
)
