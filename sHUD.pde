//INICIALIZAR LA INTERFAZ DEL JUEGO

HUD hud;

class HUD {
  PImage hudCoin = loadImage("./Sprites/HUD/Coin.png");
  PImage hudHeart = loadImage("./Sprites/HUD/Heart.png");
  PFont mono = loadFont("./Fuentes/Everyday_Standard-48.vlw");

  void dibujar(PGraphics p) {
    String textMonedas = "x " + puntos;
    
    float hudHeartWidth = hudCoin.width;
    float hudHeartMaxWidth = max(jugador.vida,jugador.maxVida);
    float hudMargin = 4;

    p.push();
      p.translate(16, 16);
      p.noStroke();
      p.textAlign(LEFT, CENTER);
      p.textFont(mono, 6);
  
      p.fill(0, 100);
      p.rect(0, 0, (hudHeartWidth +textWidth(textMonedas)) + hudMargin*2, (textAscent()-textDescent()) + hudMargin*2, 5);
  
      p.image(hudCoin, hudMargin, hudMargin);
  
      p.fill(255, 255, 255);
      p.text(textMonedas, (hudHeartWidth + 4)+ hudMargin, hudMargin + ((textAscent()-textDescent()))/2); //Renderizar la cantidad de monedas
    p.pop();

    p.push();
      p.translate(16, 16*2);
  
      p.noStroke();
      p.fill(0, 100);
      p.rect(0, 0, (hudHeartWidth * hudHeartMaxWidth) + hudMargin*2, hudHeartWidth + hudMargin*2, 5);
  
      for (int h = 0; h < jugador.maxVida; h++) {
        p.tint(0);
        p.image(hudHeart, hudMargin+(hudHeartWidth*h), hudMargin);
      }
      
      for (int h = 0; h < jugador.vida; h++) {
        p.tint(255);
        p.image(hudHeart, hudMargin+(hudHeartWidth*h), hudMargin);
      }

    p.pop();
  }
}

void drawSombra(PGraphics p, float x, float y, float tam) {
  p.push();
  p.noStroke();
  p.fill(0, 100);
  p.ellipse(x, y, tam, tam/2);
  p.pop();
}
