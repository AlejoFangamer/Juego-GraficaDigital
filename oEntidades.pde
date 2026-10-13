class Cooldown {
  int     duracion;                  
  int     ultimo = -999999;

  Cooldown(int duracion) {
    this.duracion = duracion;
  }

  void activar()   { ultimo = millis(); }
  boolean activo() { return millis() - ultimo < duracion; }
}

class Entidad extends Caja implements Dibujable {
  int     vida;
  int     maxVida;
  boolean muerto = false;
  
  Cooldown iframes = new Cooldown(0);
  
  PVector velocidadKnockback = new PVector(0, 0);
  float   fuerzaKnockback    = 1;      // pixeles por frame
  float   friccionKnockback  = 0.85;
  
  Entidad(float x, float y, float w, float h, int vida) {
    super(x, y, w, h);
    this.vida    = vida;
    this.maxVida = vida;
  }
  
  boolean invulnerable(){
    return iframes.activo();
  }
  
  void daño(Caja atacante, int cantidad) {
    if (muerto || invulnerable()) return;

    iframes.activar();
    empujarDesde(atacante);
    vida -= cantidad;
    alRecibirDaño();
    particulas.add(new DañoParticula(x, y, str(cantidad)));

    if (vida <= 0) {
      vida = 0;
      muerto = true;
      alMorir();
    }
  }
  
  void empujarDesde(Caja atacante) {
    float overlapX = min(x + w, atacante.x + atacante.w) - max(x, atacante.x);
    float overlapY = min(y + h, atacante.y + atacante.h) - max(y, atacante.y);

    if (overlapX < overlapY) {
      velocidadKnockback.set(x < atacante.x ? -1 : 1, 0);
    } else {
      velocidadKnockback.set(0, y < atacante.y ? -1 : 1);
    }
    velocidadKnockback.mult(fuerzaKnockback);
  }
  
  void aplicarKnockback() {
    if (velocidadKnockback.magSq() == 0) return;
    move(velocidadKnockback.x, velocidadKnockback.y, solidos);
    velocidadKnockback.mult(friccionKnockback);
    if (velocidadKnockback.magSq() < 0.01) velocidadKnockback.set(0, 0);
  }
  
  // --- Ganchos ---
  void alRecibirDaño() { }
  void alMorir() { }
  
  public float getY() {
    return y + h;
  }
  
  public void dibujar(PGraphics p) { }
}
