# server.py atualizado
import asyncio
import websockets
import json
import random

async def enviar_dados(websocket):
    while True:
        dados = {
            "x": random.uniform(-2, 2),
            "y": random.uniform(-2, 2),
        }
        await websocket.send(json.dumps(dados))
        await asyncio.sleep(0.05)

async def main():
    # Note: removemos o "path" da função
    async with websockets.serve(enviar_dados, "localhost", 8765):
        print("Servidor WebSocket rodando em ws://localhost:8765")
        await asyncio.Future()

asyncio.run(main())
