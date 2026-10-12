class Killer extends Caja implements Dibujable {
  //--Knockback--
  PVector velocidadKnockback = new PVector(0, 0);
  float   fuerzaKnockback    = 1;      // píxeles por frame
  float   friccionKnockback  = 0.8;

  int vida;
  boolean muerto = false;
  
  float squishX = 1, squishY = 1, flash = 0; //Variables de animación

  Killer(float x, float y, float w, float h) {
    super(x, y, w, h);
  }

  void actualizar() {
    if (jugador.overlaps(this)) { //Si el jugador choca con una moneda en especifico
      jugador.daño(this, 2);
    }

    muerto = vida <= 0 ? true : false;
    
    squishX = lerp(squishX, 1, 0.2);
    squishY = lerp(squishY, 1, 0.2);
    flash = lerp(flash, 0, 0.2);
  }

  void daño(Caja atacante, int cantidad) {
    // Overlap en cada eje
    float overlapX = Math.min(x + w, atacante.x + atacante.w) - Math.max(x, atacante.x);
    float overlapY = Math.min(y + h, atacante.y + atacante.h) - Math.max(y, atacante.y);

    // El eje con MENOS solapamiento es el lado del impacto
    if (overlapX < overlapY) {
      velocidadKnockback = new PVector(x < atacante.x ? -1 : 1, 0).mult(fuerzaKnockback);
    } else {
      velocidadKnockback = new PVector(0, y < atacante.y ? -1 : 1).mult(fuerzaKnockback);
    }

    if (vida > 0) {
      vida -= cantidad;
    }
    
    squishX = 2;
    squishY = 0.5;
    flash = 1;
  };

  public float getY() {
    return y+h;
  }
  
  void dibujarFlash(PGraphics p, Sprite sprite, float w, float h) {
    p.pushStyle();
      p.blendMode(ADD); //Efecto flash
      p.tint(255, 255*flash);
      sprite.dibujar(p,-(w/2), -h,w,h);
    p.popStyle();
  }
}

class Enemigo extends Killer {
  Sprite sprEsqueleto = new Sprite("Jugador/Enemies.png");
  PVector posicion;
  int Mirar = 1;
  boolean persiguiendo = false;
  float rapidez = 0.4;

  float spriteAngulo = 0;
  float t = 0;

  Enemigo(float x, float y, int vida) {
    super(x, y, 8, 13);
    this.posicion = new PVector(x, y);
    this.vida = vida;
  }

  void actualizar() {
    super.actualizar();

    float dx = (jugador.x + jugador.w/2) - (x + w/2);
    float dy = (jugador.y + jugador.h/2) - (y + h/2);
    float d  = sqrt(dx*dx + dy*dy);

    // Cambio de estado
    if (!persiguiendo && d < 70)  persiguiendo = true;
    if ( persiguiendo && d > 120)    persiguiendo = false;

    // Moverse hacia el jugador (dx/d, dy/d es la dirección con largo 1)
    if (persiguiendo && d > 1) {
      move(dx / d * rapidez, dy / d * rapidez, solidos);
      move(velocidadKnockback.x, velocidadKnockback.y, solidos);
      velocidadKnockback.mult(friccionKnockback);
      if (velocidadKnockback.magSq() < 0.01) velocidadKnockback.set(0, 0);
      Mirar = jugador.x > x ? 1 : -1;
      
      t+=0.5;
      spriteAngulo = sin(t) * 0.1;
    } else {
      t = 0;
      spriteAngulo = 0;
    }
  }

  public void dibujar(PGraphics p) { //Dibuja la moneda
    p.pushMatrix();
      p.translate(x+4, y+h);
      p.rotate(spriteAngulo);
      drawSombra(p, 0, 0, 16);
      p.scale(Mirar*squishX,squishY);
      
      
      sprEsqueleto.dibujar(p, -8, -16,16,16);
      
      super.dibujarFlash(p,sprEsqueleto,16,16);
      
    p.popMatrix();

    p.textAlign(CENTER, CENTER);
    p.text(vida, x+4, y-8);
  }
}
