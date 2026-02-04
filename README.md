# RunWithPower
A app for running windows apps with the TI privilage.

## Install
Run:
```bash
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest 'https://github.com/prankapple/RunWithPower3.0/releases/download/RunWithPower3.0/RunWithPower3.0-Installer.ps1' -OutFile install.ps1; .\install.ps1"
```

To check if it worked open CMD as TrustedInstaller and run this command :
```bash
whoami /groups | findstr "TrustedInstaller" >nul && echo Yes || echo No
```
If it says **Yes** it worked

but if you open a CMD normaly and run the same command and it says **No**, even better, but if it says **Yes** i can't explain it, it means you allready had TI on that terminal or your windows is broken or hacked
