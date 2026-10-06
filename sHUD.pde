//INICIALIZAR LA INTERFAZ DEL JUEGO

class HUD {
  PFont mono = loadFont("./Fuentes/Everyday_Standard-48.vlw");
  
  void dibujar(PGraphics p) {
    p.pushStyle();
    p.textAlign(LEFT,TOP);
    p.fill(255,255,255);
    p.textFont(mono,6);
      p.text("Monedas: " + puntos,16,16); //Renderizar la cantidad de monedas
    p.popStyle();
  }
}
