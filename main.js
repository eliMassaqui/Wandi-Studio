import * as THREE from 'three';

// Cena, câmera e renderer
const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(75, window.innerWidth/window.innerHeight, 0.1, 1000);
camera.position.z = 5;

const renderer = new THREE.WebGLRenderer();
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

// Cubo
const geometry = new THREE.BoxGeometry();
const material = new THREE.MeshBasicMaterial({ color: 0x00ff00 });
const cube = new THREE.Mesh(geometry, material);
scene.add(cube);

// Loop de animação
function animate() {
    requestAnimationFrame(animate);
    renderer.render(scene, camera);
}
animate();

// WebSocket
const ws = new WebSocket('ws://localhost:8080');

ws.onopen = () => console.log("Conectado ao Arduino!");
ws.onmessage = (event) => {
    const palavra = event.data.trim();
    console.log("Mensagem do Arduino:", palavra);

    if (palavra === "1") cube.material.color.set(0xff0000);   // vermelho
    else if (palavra === "0") cube.material.color.set(0x00ff00); // verde
};

// Input do teclado
document.addEventListener('keydown', (e) => {
    if (e.key === '1' || e.key === '0') {
        // Envia para o Arduino via WebSocket
        ws.send(e.key);

        // Muda a cor do cubo imediatamente
        if (e.key === '1') cube.material.color.set(0xff0000);   // vermelho
        if (e.key === '0') cube.material.color.set(0x00ff00); // verde
    }
});
