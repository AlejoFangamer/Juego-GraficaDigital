///INICIALIZAR LA CAMARA

Camara camara;

float MUNDO_ANCHO = ventanaW * 1.2; //Tamaño de la sala
float MUNDO_ALTO  = ventanaH * 1.2;

class Camara {
  PVector pos = new PVector(0, 0);   // esquina superior izquierda de lo que se ve
  float suavizado = 0.1;             // 1 = pegada al objetivo, 0.05 = muy lenta
  float anchoVista, altoVista;       // tamaño de la pantalla
  float mundoAncho, mundoAlto;       // tamaño total del mapa

  Camara(float anchoVista, float altoVista, float mundoAncho, float mundoAlto) {
    this.anchoVista = anchoVista;
    this.altoVista  = altoVista;
    this.mundoAncho = mundoAncho;
    this.mundoAlto  = mundoAlto;
  }

  // Aparecer directo al jugador
  void centrar(float cx, float cy) {
    pos.set(cx - anchoVista/2, cy - altoVista/2);
    limitar();
  }

  // Se acerca poco a poco al objetivo
  void seguir(float cx, float cy) {
    pos.x = lerp(pos.x, cx - anchoVista/2, suavizado); // Punto de posicion - la mitad del ancho de vista para que esté centrado
    pos.y = lerp(pos.y, cy - altoVista/2, suavizado);
    limitar();
  }

  // No mostrar nada fuera del mapa
  private void limitar() {
    pos.x = constrain(pos.x, 0, max(0, mundoAncho - anchoVista));
    pos.y = constrain(pos.y, 0, max(0, mundoAlto  - altoVista));
  }

  void aplicar(PGraphics p) {
    p.translate(-round(pos.x), -round(pos.y));   // round evita líneas parpadeantes
  }
}
