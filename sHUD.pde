//INICIALIZAR LA INTERFAZ DEL JUEGO

//Dibuja la interfaz del juego
//eso significa, cantidad de vidas, monedas, pisos pasados y cuanto de la regla se ha logrado.

HUD hud;

float transOpacidad = 0;

class HUD {
  PImage hudCoin = loadImage("./Sprites/HUD/Coin.png");
  PImage hudHeart = loadImage("./Sprites/HUD/Heart.png");
  PFont  mono = loadFont("./Fuentes/Everyday_Standard-48.vlw");

  void dibujar(PGraphics p) {
    String textMonedas = "x " + puntos;
    
    float hudHeartWidth = hudCoin.width;
    float hudHeartMaxWidth = max(jugador.vida,jugador.maxVida);
    float hudMargin = 4;
    
    transOpacidad = lerp(transOpacidad,int(jugador.muerto),0.05);

    p.pushMatrix();
    p.pushStyle();
      p.translate(16, 16);
      p.noStroke();
      p.textAlign(LEFT, CENTER);
      p.textFont(mono, 6);
  
      p.fill(0, 100);
      p.rect(0, 0, (hudHeartWidth +textWidth(textMonedas)) + hudMargin*2, (textAscent()-textDescent()) + hudMargin*2, 5);
  
      p.image(hudCoin, hudMargin, hudMargin);
  
      p.fill(255, 255, 255);
      p.text(textMonedas, (hudHeartWidth + 4)+ hudMargin, hudMargin + ((textAscent()-textDescent()))/2); //Renderizar la cantidad de monedas
    p.popMatrix();
    p.popStyle();

    p.pushStyle();
    p.pushMatrix();
      p.translate(16, 16*2);
  
      p.noStroke();
      p.fill(0, 100);
      p.rect(0, 0, (hudHeartWidth * hudHeartMaxWidth) + hudMargin*2, hudHeartWidth + hudMargin*2, 5);
  
      for (int h = 0; h < jugador.maxVida; h++) {
        p.tint(0);
        p.image(hudHeart, hudMargin+(hudHeartWidth*h), hudMargin); //Renderizar la cantidad de vida maxima 
      }
      
      for (int h = 0; h < jugador.vida; h++) {
        p.tint(255);
        p.image(hudHeart, hudMargin+(hudHeartWidth*h), hudMargin); //Renderizar la cantidad de vida restante 
      }
    p.popMatrix();
    p.popStyle();

    p.pushStyle();
    p.pushMatrix();
      p.textAlign(RIGHT, CENTER);
      p.translate(ventanaW-16,ventanaH-16);
      p.text(enemigosDerrotados + "/" + enemigosTotales, 0, 0); //Renderizar la cantidad de enemigos derrotados
    p.popMatrix();
    p.popStyle();
    
    p.pushMatrix();
      p.textAlign(RIGHT, CENTER);
      p.translate(ventanaW-16,ventanaH-32);
      p.text("Floor: "+ floorsPasados, 0, 0); //Renderizar la cantidad de pisos pasados
    p.popMatrix();
    
    p.pushMatrix();
      p.textAlign(LEFT, CENTER);
      p.translate(16,ventanaH-16);
      p.text("FPS: " + floor(frameRate), 0, 0); //Renderizar la cantidad de pisos pasados
    p.popMatrix();
    
    p.pushMatrix();
    p.pushStyle();
      p.fill(0,255*transOpacidad);
      p.rect(0,0,width,height);
      
      if (jugador.muerto){
        p.fill(255);
        p.textAlign(CENTER, CENTER);
        p.translate(ventanaW/2,ventanaH/2);
        p.text("Game Over \n presiona R para reiniciar", 0,0);
      }
    p.popMatrix();
    p.popStyle();
    
  }
}
