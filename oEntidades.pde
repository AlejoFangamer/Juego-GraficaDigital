/// SISTEMA DE ENTIDADES.
// Cualquier entidad que reciba, o haga daño, usará esta funcion padre.


// SISTEMA DE COOLDOWN
// despues de X tiempo, puede realizar Y acción.
class Cooldown {
  int     duracion;                  
  int     ultimo = -999999;

  Cooldown(int duracion) {
    this.duracion = duracion;
  }

  void activar()   { ultimo = millis(); } //Activa el timer del cooldown.
  boolean activo() { return millis() - ultimo < duracion; } //Detecta si la duración del cooldown ha pasado.
}

class Entidad extends Caja implements Dibujable {
  int     vida; //Cuantas vidas tiene la entidad.
  int     maxVida; //Cuantas vida tuvo la entidad.
  boolean muerto = false; //Si está muerto o no.
  
  Cooldown iframes = new Cooldown(0); //Nuevo cooldown.
  
  PVector velocidadKnockback = new PVector(0, 0); //Setear la dirección del knockback
  float   fuerzaKnockback    = 1; //Velocidad del knockback por pixeles por frame
  float   friccionKnockback  = 0.85; //Fricción del knockback
  
  Entidad(float x, float y, float w, float h, int vida) {
    super(x, y, w, h);
    this.vida    = vida;
    this.maxVida = vida;
  }
  
  boolean invulnerable(){ //Es invulnerable solo cuando el cooldown no ha pasado.
    return iframes.activo();
  }
  
  // Si la entidad recibe daño.
  
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
  
  // SISTEMA DE KNOCKBACK
  // Si, digamos, el jugador o un enemigo es disparado, hace un pequeño empuje al lado contrario al que fue disparado.
  
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
  
  // Ganchos , por si quiero colocar cosas para otros objetos.
  void alRecibirDaño() { }
  void alMorir() { }
  
  public float getY() {
    return y + h;
  }
  
  public void dibujar(PGraphics p) { }
}

void drawSombra(PGraphics p, float x, float y, float tam) { //Dibujar sombra debajo de los objetos.
  p.pushStyle();
    p.noStroke();
    p.fill(0, 100);
    p.ellipse(x, y, tam, tam/2);
  p.popStyle();
}
