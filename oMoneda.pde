/// SISTEMA DE COLECCIONABLES

// Una clase expandible para todo tipo de coleccionables.
// en los cuales todos se transmiten la acción de si el jugador lo recoge, si se tira, etc.

ArrayList<Items> items = new ArrayList<Items>();

class Items extends Caja implements Dibujable {
  // EFECTO MAGNETO
  // si el jugador se acerca ligeramente al objeto, los objetos se acercan al jugador, haciendo facil su recolección.
  
  PVector velocidad = new PVector(0, 0);
  float   friccion = 0.9;
  boolean recogible = false;
  boolean recogida = false; //Esta moneda no ha sido recogida por defecto

  int     rapidez = 1;

  boolean puedePerseguir = false;
  boolean siguiendo = false;
  float   radioIman  = 32;     // distancia a la que empieza a atraer
  float   fuerzaIman = 2;

  float   visualX = 0;
  float   t = 0;

  Items(float x, float y, float w, float h) {
    super(x, y, w, h); //Valores de colision
  }

  void actualizar() {
    if (velocidad.magSq() > 0) {
      t+= 0.2; //Si la velocidad o distancia del vector es mayor que 0 (osea que si está avanzando pue)
      velocidad.mult(friccion);
      // fricción, se detiene lentamente
      if (!siguiendo) {
        visualX = -abs(sin(t) * (5*velocidad.mag()));
      }
      // se detiene del todo si su velocidad es menor que el numero que dice ahi xD
      if (velocidad.mag() < 0.05) {
        velocidad.set(0, 0);
        visualX = 0;
      };
    }

    if (!siguiendo && velocidad.magSq() == 0) {
      siguiendo = true;
      recogible = true;
    }

    if (puedePerseguir && siguiendo) {
      float dx = (jugador.x + jugador.w/2) - (x + w/2);
      float dy = (jugador.y + jugador.h/2) - (y + h/2);
      float d  = sqrt(dx*dx + dy*dy);

      if (d < radioIman && d > 1) {
        colisionable = false;
        float b = 1 - d / radioIman;

        PVector tiron = new PVector(dx, dy);
        tiron.setMag(fuerzaIman * b);
        velocidad.add(tiron);
      }
    }

    move(velocidad.x, velocidad.y, solidos);

    if (jugador.overlaps(this) && recogible) { //Si el jugador choca con una moneda en especifica
      recoger();
    }
  }

  void recoger() {
    recogida = true; //La recoge
  }

  public float getY() {
    return y+8;
  }

  void lanzar(float fuerza) { //Funcion para cuando se lance la moneda a una velocidad especifica
    velocidad = PVector.random2D().mult(fuerza); //Se lanza a cualquier dirección pero a la velocidad especificada
    siguiendo = false;
  }
}


class Moneda extends Items {
  Sprite sprMoneda = new Sprite("Items/Moneda.gif");
  //float tam = 16; //Tamaño de moneda

  Moneda(float x, float y) {
    super(x, y, 8, 8); //Valores de colision
    sprMoneda.fps = 8;
    sprMoneda.frameInicial = int(random(sprMoneda.cantidadFrames()));
    sprMoneda.reiniciar();
    puedePerseguir = true;
  }

  void actualizar() {
    super.actualizar();
    sprMoneda.actualizar();
  }

  void recoger() {
    super.recoger();
    sndMoneda.trigger(); //Suena el sonido de moneda
    puntos++;
  }

  public void dibujar(PGraphics p) { //Dibuja la moneda
    drawSombra(p, round(x+(w/2)), round(y+h), w);
    p.pushMatrix();
    p.translate(x, y);
    sprMoneda.dibujar(p, 0, visualX, w, h);
    p.popMatrix();
  }
}

class Vida extends Items {
  Sprite sprite = new Sprite("Items/Heart.gif");
  //float tam = 16; //Tamaño de moneda

  Vida(float x, float y) {
    super(x, y, 8, 8); //Valores de colision
  }
  
  void actualizar() {
    super.actualizar();
    sprite.actualizar();
  }

  void recoger() {
    if (!(jugador.vida >= jugador.maxVida)) {
      recogida = true;
      sndCorazon.trigger(); //Suena el sonido de moneda
      jugador.vida++;
    }
  }

  public void dibujar(PGraphics p) { //Dibuja la moneda
    drawSombra(p, round(x+(w/2)), round(y+h), w);
    p.pushMatrix();
    p.translate(x, y);
    sprite.dibujar(p, 0, visualX, w, h);
    p.popMatrix();
  }
}
