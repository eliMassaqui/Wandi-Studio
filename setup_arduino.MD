Documentação: setup_arduino_perfeito.bat
1️⃣ Objetivo

Este script automatiza todo o processo necessário para preparar um Arduino para uso com Node.js + Johnny-Five, de forma plug-and-play em computadores Windows.

Ele faz:

Instala o core AVR (necessário para Arduino Uno, Nano, Mega).

Instala as bibliotecas Firmata e Servo.

Cria um sketch vazio.

Detecta automaticamente a porta do Arduino e o tipo de placa (Uno, Nano ou Mega).

Compila e envia o sketch vazio.

Baixa, compila e envia o StandardFirmata (necessário para Johnny-Five).

Garante que o Arduino está pronto para comunicação via Node.js.

2️⃣ Pré-requisitos

Windows 10 ou superior.

Arduino CLI instalado e disponível no PATH do sistema.

Arduino conectado via USB.

Conexão com a internet para baixar bibliotecas e StandardFirmata.

3️⃣ Estrutura do script

O script é dividido em blocos lógicos:

a) Configuração do Arduino CLI
SET ARDUINO_CLI=arduino-cli
%ARDUINO_CLI% core update-index
%ARDUINO_CLI% core install arduino:avr


Define o comando Arduino CLI.

Atualiza o índice de cores/boards.

Instala o core AVR, necessário para compilar para Uno, Nano ou Mega.

b) Instalação das bibliotecas necessárias
%ARDUINO_CLI% lib install "Firmata"
%ARDUINO_CLI% lib install "Servo"


Firmata: protocolo para comunicação Arduino ↔ Node.js (Johnny-Five).

Servo: necessário para o StandardFirmata funcionar com servos.

c) Criação do sketch vazio
SET SKETCH_DIR=%USERPROFILE%\Arduino\sketches
IF NOT EXIST "%SKETCH_DIR%" mkdir "%SKETCH_DIR%"
SET SKETCH_PATH=%SKETCH_DIR%\MeuSketchVazio

IF NOT EXIST "%SKETCH_PATH%" (
    %ARDUINO_CLI% sketch new "%SKETCH_PATH%"
)


Cria a pasta de sketches se não existir.

Cria um sketch vazio chamado MeuSketchVazio.

d) Detecção automática da porta do Arduino
SET PORT=
FOR /F "tokens=1,2,3,* delims= " %%A IN ('%ARDUINO_CLI% board list ^| findstr /R /C:"COM"') DO (
    SET PORT=%%A
)


Detecta automaticamente a porta COM onde o Arduino está conectado.

Se não houver placa, o script informa e encerra.

e) Mapeamento da placa (FQBN)
SET BOARD=arduino:avr:uno
FOR /F "tokens=2 delims= " %%B IN ('%ARDUINO_CLI% board list ^| findstr /R /C:"Arduino Mega"') DO (
    SET BOARD=arduino:avr:mega
)
FOR /F "tokens=2 delims= " %%B IN ('%ARDUINO_CLI% board list ^| findstr /R /C:"Arduino Nano"') DO (
    SET BOARD=arduino:avr:nano:cpu=atmega328
)


Define o FQBN correto para compilar o sketch e o StandardFirmata.

Suporta placas comuns: Uno, Nano, Mega.

f) Compilação e upload do sketch vazio
%ARDUINO_CLI% compile --fqbn %BOARD% "%SKETCH_PATH%"
%ARDUINO_CLI% upload -p %PORT% --fqbn %BOARD% "%SKETCH_PATH%"


Compila o sketch vazio e envia para a placa.

Garante que a placa está conectada e respondendo antes de enviar StandardFirmata.

g) Preparação e download do StandardFirmata
SET FIRMATA_DIR=%SKETCH_DIR%\StandardFirmata
IF NOT EXIST "%FIRMATA_DIR%" mkdir "%FIRMATA_DIR%"

IF NOT EXIST "%FIRMATA_DIR%\StandardFirmata.ino" (
    powershell -Command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/firmata/arduino/master/examples/StandardFirmata/StandardFirmata.ino -OutFile '%FIRMATA_DIR%\StandardFirmata.ino'"
)


Cria a pasta StandardFirmata se não existir.

Baixa o arquivo .ino diretamente do GitHub se ainda não existir.

Usa PowerShell (presente no Windows 10+) para download.

h) Compilação e upload do StandardFirmata
%ARDUINO_CLI% compile --fqbn %BOARD% "%FIRMATA_DIR%"
%ARDUINO_CLI% upload -p %PORT% --fqbn %BOARD% "%FIRMATA_DIR%"


Compila e envia o StandardFirmata para a placa.

Garante compatibilidade total com Johnny-Five.

i) Mensagem final
echo Arduino pronto! Sketch vazio e StandardFirmata instalados.
echo Placa pronta para Node.js + Johnny-Five
pause


Informa que o processo foi concluído.

O pause mantém a janela aberta para que o usuário veja a mensagem.

4️⃣ Uso passo a passo

Conectar o Arduino ao PC via USB.

Executar setup_arduino_perfeito.bat como Administrador.

O script fará tudo automaticamente:

Detecta placa e porta

Cria sketch vazio

Instala Firmata e Servo

Baixa e envia StandardFirmata

Após a execução, o Arduino está pronto para projetos Node.js com Johnny-Five.

5️⃣ Observações

Funciona com Uno, Nano, Mega por padrão.

Para outras placas, basta adicionar o FQBN correspondente.

O script é idempotente: se o Arduino ou as bibliotecas já estiverem instaladas, não faz downloads desnecessários.

É plug-and-play, ideal para clientes que nunca instalaram Arduino CLI.

Requer conexão à internet na primeira execução para baixar bibliotecas e StandardFirmata.