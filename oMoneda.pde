///OBJETO MONEDA

//Coleccionable

Gif sprMoneda; //Animación de moneda mediante libreria de gif

class Moneda extends Caja implements Dibujable{
  PVector velocidad = new PVector(0, 0);
  float friccion = 0.9; 
  boolean recogida = false; //Esta moneda no ha sido recogida por defecto
  
  //float tam = 16; //Tamaño de moneda
  
  Moneda(float x, float y) {
    super(x, y, 8, 8); //Valores de colision
  }
  
  void actualizar() {
      if (velocidad.magSq() > 0) { //Si la velocidad o distancia del vector es mayor que 0 (osea que si está avanzando pue)
        move(velocidad.x, velocidad.y, solidos);   // se mueve CON colisión
        velocidad.mult(friccion);                   // fricción, se detiene lentamente
        if (velocidad.mag() < 0.05) velocidad.set(0, 0);  // se detiene del todo si su velocidad es menor que el numero que dice ahi xD
      }
      
      if (jugador.overlaps(this)){ //Si el jugador choca con una moneda en especifico
        recogida = true; //La recoge
        sndMoneda.trigger(); //Suena el sonido de moneda
        puntos++;  //y otorga un punto
      }
  }
  
  void lanzar(float fuerza) { //Funcion para cuando se lance la moneda a una velocidad especifica
    velocidad = PVector.random2D().mult(fuerza); //Se lanza a cualquier dirección pero a la velocidad especificada
  }
  
  public float getY() { return y; }
  
  public void dibujar(PGraphics p) { //Dibuja la moneda
    drawSombra(p,x+w/2.2,y+h,w);
    p.pushMatrix();
      p.translate(x,y);
      p.image(sprMoneda,0,0);
    p.popMatrix();
  }
}
