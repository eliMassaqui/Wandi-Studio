@echo off
REM =========================================================
REM Setup Arduino automático definitivo
REM Sketch vazio + StandardFirmata
REM Funciona em qualquer computador Windows com Arduino CLI
REM =========================================================

SET ARDUINO_CLI=arduino-cli

REM Atualiza cores e instala core AVR
%ARDUINO_CLI% core update-index
%ARDUINO_CLI% core install arduino:avr

REM Instala bibliotecas necessárias
%ARDUINO_CLI% lib install "Firmata"
%ARDUINO_CLI% lib install "Servo"

REM Criar pasta do sketch vazio
SET SKETCH_DIR=%USERPROFILE%\Arduino\sketches
IF NOT EXIST "%SKETCH_DIR%" mkdir "%SKETCH_DIR%"
SET SKETCH_PATH=%SKETCH_DIR%\MeuSketchVazio

IF NOT EXIST "%SKETCH_PATH%" (
    echo Criando sketch vazio...
    %ARDUINO_CLI% sketch new "%SKETCH_PATH%"
)

REM Detecta porta do Arduino automaticamente
SET PORT=
FOR /F "tokens=1,2,3,* delims= " %%A IN ('%ARDUINO_CLI% board list ^| findstr /R /C:"COM"') DO (
    SET PORT=%%A
)
IF "%PORT%"=="" (
    echo Nenhum Arduino detectado! Conecte a placa e execute novamente.
    pause
    exit /B
)
echo Arduino detectado na porta %PORT%

REM Mapear placa comum para FQBN
SET BOARD=arduino:avr:uno
FOR /F "tokens=2 delims= " %%B IN ('%ARDUINO_CLI% board list ^| findstr /R /C:"Arduino Mega"') DO (
    SET BOARD=arduino:avr:mega
)
FOR /F "tokens=2 delims= " %%B IN ('%ARDUINO_CLI% board list ^| findstr /R /C:"Arduino Nano"') DO (
    SET BOARD=arduino:avr:nano:cpu=atmega328
)
echo Placa detectada: %BOARD%

REM Compilar e enviar sketch vazio
echo Compilando sketch vazio...
%ARDUINO_CLI% compile --fqbn %BOARD% "%SKETCH_PATH%"
echo Enviando sketch vazio...
%ARDUINO_CLI% upload -p %PORT% --fqbn %BOARD% "%SKETCH_PATH%"

REM Preparar StandardFirmata
SET FIRMATA_DIR=%SKETCH_DIR%\StandardFirmata
IF NOT EXIST "%FIRMATA_DIR%" mkdir "%FIRMATA_DIR%"

REM Baixar StandardFirmata se não existir
IF NOT EXIST "%FIRMATA_DIR%\StandardFirmata.ino" (
    echo Baixando StandardFirmata do GitHub...
    powershell -Command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/firmata/arduino/master/examples/StandardFirmata/StandardFirmata.ino -OutFile '%FIRMATA_DIR%\StandardFirmata.ino'"
)

REM Compilar e enviar StandardFirmata
echo Compilando StandardFirmata...
%ARDUINO_CLI% compile --fqbn %BOARD% "%FIRMATA_DIR%"
echo Enviando StandardFirmata...
%ARDUINO_CLI% upload -p %PORT% --fqbn %BOARD% "%FIRMATA_DIR%"

echo =========================================
echo Arduino pronto! Sketch vazio e StandardFirmata instalados.
echo Placa pronta para Node.js + Johnny-Five
pause
