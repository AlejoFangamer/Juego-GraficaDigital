//ENEMIGO - CLASE PADRE
int enemigosDerrotados = 0; // shared across all objects
int enemigosTotales = 0;

class Killer extends Entidad {
  int   dañoAlJugador = 2;
  float squishX = 1, squishY = 1, flash = 0; //Variables de animación

  Killer(float x, float y, float w, float h, int vida) {
    super(x, y, w, h, vida);
    fuerzaKnockback   = 1;
    friccionKnockback = 0.8;
  }

  void actualizar() {
    // Overlap en cada eje
    if (!muerto && jugador.overlaps(this)) {
      jugador.daño(this, dañoAlJugador);
    }

    //aplicarKnockback();
    aplicarKnockback();
    separarDeEnemigos();

    squishX = lerp(squishX, 1, 0.2);
    squishY = lerp(squishY, 1, 0.2);
    flash   = lerp(flash, 0, 0.2);
  };

  void alRecibirDaño() {
    squishX = 2;
    squishY = 0.5;
    flash = 1;
  }

  float pasoMaxSeparacion = 3;   // px por frame: más alto = se separan más rápido

  //Colisión con otros enemigos para que no se solapen.
  //APOYO DE IA.

  void separarDeEnemigos() {
    for (Killer o : enemigos) {
      if (o == this || o.muerto || !overlaps(o)) continue;

      float ox = min(x + w, o.x + o.w) - max(x, o.x);   // cuánto se solapan en X
      float oy = min(y + h, o.y + o.h) - max(y, o.y);   // cuánto se solapan en Y

      float cx = x + w/2, cy = y + h/2;
      float ocx = o.x + o.w/2, ocy = o.y + o.h/2;

      // Desempate por si están EXACTAMENTE en el mismo punto:
      // los dos calculan lo contrario, así que se van en sentidos opuestos
      boolean yoMayor = System.identityHashCode(this) > System.identityHashCode(o);

      // Se aparta por el eje con MENOS solapamiento, la mitad cada uno
      if (ox < oy) {
        float lado = (cx < ocx) ? -1 : 1;
        if (cx == ocx) lado = yoMayor ? 1 : -1;
        move(lado * min(ox / 2, pasoMaxSeparacion), 0, solidos);
      } else {
        float lado = (cy < ocy) ? -1 : 1;
        if (cy == ocy) lado = yoMayor ? 1 : -1;
        move(0, lado * min(oy / 2, pasoMaxSeparacion), solidos);
      }
    }
  }

  void dibujarFlash(PGraphics p, Sprite sprite, float w, float h) {
    p.pushStyle();
    p.blendMode(ADD); //Efecto flash
    p.tint(255, 255*flash);
    sprite.dibujar(p, -(w/2), -h, w, h);
    p.popStyle();
  }
}

//ENEMIGO - ESQUELETO
ArrayList<Killer> enemigos = new ArrayList<Killer>();
class Enemigo extends Killer {

  Sprite  sprEsqueleto = new Sprite("Jugador/Enemies.png");
  
  AudioSample[] sonidos = {sndEsqueleto1,sndEsqueleto2,sndEsqueletoMuere};
  AudioSample sonidoElegido = sonidos[round(random(0,1))];

  PVector posicion;
  int     mirar = 1;

  //VALORES PARA PERSEGUIR

  boolean persiguiendo = false;
  float   rapidez        = 1;
  float   radioDeteccion = 70;
  float   radioPerdida   = 120;

  float   spriteAngulo = 0;
  float   t = 0;

  Enemigo(float x, float y, int vida) {
    super(x, y, 8, 13, vida);
  }

  void actualizar() {
    super.actualizar();
    if (muerto) return;

    float dx = (jugador.x + jugador.w/2) - (x + w/2);
    float dy = (jugador.y + jugador.h/2) - (y + h/2);
    float d  = sqrt(dx*dx + dy*dy);

    // Cambio de estado
    if (!persiguiendo && d < 70)  persiguiendo = true;
    if ( persiguiendo && d > 120) persiguiendo = false;

    // Moverse hacia el jugador (dx/d, dy/d es la dirección con largo 1)
    if (persiguiendo && d > 1) {
      move(dx / d * rapidez, dy / d * rapidez, solidos);
      mirar = jugador.x > x ? 1 : -1;

      t+=0.5;
      spriteAngulo = sin(t) * 0.1;
    } else {
      t = 0;
      spriteAngulo = 0;
    }
  }
  
  void alRecibirDaño() {
     super.alRecibirDaño();
     if (muerto) return;
     sonidoElegido = sonidos[round(random(0,1))];
     sonidoElegido.trigger();
  }
  
  void alMorir() { 
     sonidoElegido = sonidos[2];
     sonidoElegido.trigger();
  }

  public void dibujar(PGraphics p) {
    p.pushMatrix();
    p.translate(x+4, y+h);
    drawSombra(p, 0, 0, 16);
    p.rotate(spriteAngulo);
    p.scale(mirar*squishX, squishY);

    sprEsqueleto.dibujar(p, -8, -16, 16, 16);
    dibujarFlash(p, sprEsqueleto, 16, 16);
    p.popMatrix();

    p.textAlign(CENTER, CENTER);
    p.text(vida, x+4, y-8);
  }
}
