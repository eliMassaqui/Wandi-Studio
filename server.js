const { SerialPort } = require('serialport');
const { ReadlineParser } = require('@serialport/parser-readline');
const WebSocket = require('ws');

let portaArduino;

// Conecta automaticamente ao Arduino
async function conectarArduino() {
    const portas = await SerialPort.list();
    const arduinoPort = portas.find(p => p.vendorId && p.productId);

    if (!arduinoPort) {
        console.log("Nenhum Arduino encontrado!");
        return;
    }

    console.log("Arduino encontrado:", arduinoPort.path);

    portaArduino = new SerialPort({
        path: arduinoPort.path,
        baudRate: 9600,
    });

    const parser = portaArduino.pipe(new ReadlineParser({ delimiter: "\r\n" }));

    parser.on("data", (data) => {
        wss.clients.forEach(client => {
            if (client.readyState === WebSocket.OPEN) {
                client.send(data);
            }
        });
    });

    portaArduino.on("open", () => console.log("Arduino conectado!"));
}

// WebSocket server
const wss = new WebSocket.Server({ port: 8080 });

wss.on("connection", ws => {
    console.log("Cliente conectado!");
    ws.on("message", msg => {
        if (portaArduino && portaArduino.isOpen) {
            portaArduino.write(msg + "\n");
        }
    });
});

conectarArduino();
