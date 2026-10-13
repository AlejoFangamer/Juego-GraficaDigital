Jugador jugador;

class Jugador extends Entidad {
  PImage  sprJugador = loadImage("./Sprites/Jugador/Jugador.png");

  //Estado
  PVector posicion;
  float   rapidez;
  
  //Mirada
  float   mirar = 1;
  float   spriteMirar = mirar;
  
  // --- Animación ---
  boolean moviendose = false;
  float   currentTime = 0;
  float   spriteAngle = 0;
  float   spriteOpacity = 1;
  float   visualY = 0;
  float   visualYTime = 0;
  float   visualYamp = 0;

  // --- Punto de nacimiento del cañón (constante, no se recalcula) ---
  final PVector OFFSET_CANON = new PVector(0, -4);

  Jugador(float x, float y, float rapidez, int vida) {
    super(x, y, 8, 8, vida);
    this.posicion = new PVector(x, y);
    this.rapidez  = rapidez;
    
    iframes.duracion  = 1000;             // ms de invulnerabilidad
    fuerzaKnockback   = 8;
    friccionKnockback = 0.85;
  }

  void alRecibirDaño() {
    visualYamp = 10;
  };

  public void actualizar(PVector mov) {
    //POSICIÓN DEL JUGADOR
    move(mov.x * rapidez, mov.y * rapidez, solidos);
    aplicarKnockback();

    posicion.set(x+w/2, y+h);

    //DISPARO
    PVector apuntar = input.leerDisparo();
    boolean Disparar = input.kW || input.kA || input.kS || input.kD;
    
    if (Disparar) {
      disparos.disparar(bocaDeFuego(), apuntar);
    }
    
    actualizarMirada(mov,apuntar);
    animar(mov.magSq() > 0);

    vida = constrain(vida, 0, maxVida);
  }
  
  void actualizarMirada(PVector mov, PVector apuntar) {
    if (abs(apuntar.x) > 0.01) {
      mirar = (apuntar.x > 0) ? -1 : 1;
    } else if (abs(mov.x) > 0.01) {
      mirar = (mov.x > 0) ? -1 : 1;
    }
  }

  private void animar(boolean moviendose) {
    this.moviendose = moviendose;

    spriteMirar = lerp(spriteMirar, mirar, 0.3);

    if (visualYamp > 0) {
      visualYTime+=0.4;
      visualYamp-=0.2;
      visualY = -abs(sin(visualYTime) * (visualYamp));
    } else {
      visualYTime=0;
      visualY=0;
      visualYamp = 0;
    }

    if (invulnerable()) {
      spriteOpacity = ((millis() / 80) % 2 == 0) ? 1.0 : 0.3;
    } else {
      spriteOpacity = 1;
    }

    if (moviendose) {
      currentTime += 0.7;
      spriteAngle  = sin(currentTime) * 0.1;
    } else {
      spriteAngle = lerp(spriteAngle,0,0.2);
    }
  }

  /** Punto desde donde nacen las balas (borde del sprite, no el centro). */
  PVector bocaDeFuego() {
    return PVector.add(posicion, OFFSET_CANON);
  }

  public float getY() {
    return y+h;
  }

  public void dibujar(PGraphics p) {
    drawSombra(p, posicion.x+(0.9*mirar), posicion.y, 16);

    p.push();
      p.translate(posicion.x, posicion.y);
      p.tint(255, 255*spriteOpacity);
      p.scale(spriteMirar-(spriteAngle*mirar), 1+spriteAngle);
      p.image(sprJugador, -sprJugador.width/2, visualY-sprJugador.height);
    p.pop();
  }
}

//--------------- DISPARAR -----------------
Disparos disparos;
ArrayList<Bala> balas = new ArrayList<Bala>();

class Disparos {
  float dispersion;       // radianes
  float rapidezBala;
  float tamBala;
  float radioNacimiento;  // distancia desde la boca al centro de la bala

  Cooldown iframesDisparo;

  Disparos(int cadencia , float dispersion,
    float rapidezBala, float tamBala, float radioNacimiento) {
    this.iframesDisparo = new Cooldown(cadencia);
    this.dispersion      = dispersion;
    this.rapidezBala     = rapidezBala;
    this.tamBala         = tamBala;
    this.radioNacimiento = radioNacimiento;
  }

  void disparar(PVector centro, PVector direccion) {
    if (iframesDisparo.activo()) return;
    if (direccion.magSq() == 0 ) return;

    PVector dirFinal = aplicarDispersion(direccion);
    PVector origen   = PVector.add(centro, PVector.mult(dirFinal, radioNacimiento));

    balas.add(new Bala(origen, rapidezBala, dirFinal, tamBala));
    jugador.spriteAngle = -0.5;
    iframesDisparo.activar();
  }

  void actualizar() {
    for (int i = balas.size() - 1; i >= 0; i--) {
      Bala b = balas.get(i);
      b.actualizar();
      if (!b.viva) balas.remove(i);   // <-- antes nunca se limpiaban
    }
  }

  private PVector aplicarDispersion(PVector direccion) {
    return direccion.copy().rotate(random(-dispersion, dispersion));
  }
}

//--------------- BALAS -----------------

class Bala extends Caja implements Dibujable {
  Sprite sprite = new Sprite("Jugador/sprJugadorBala.png"); //Cargar sprite de la caja
  PVector posicion;
  PVector velocidad;
  float   tam;
  boolean viva = true;

  Bala(PVector origen, float rapidez, PVector direccion, float tam) {
    super(origen.x - tam/2, origen.y - tam/2, tam, tam);
    this.posicion  = origen.copy();                // copy: si no, todas siguen al jugador
    this.velocidad = PVector.mult(direccion, rapidez);
    this.tam       = tam;
  }

  void actualizar() {
    posicion.add(velocidad);
    x = posicion.x - tam/2;
    y = posicion.y - tam/2;

    if (posicion.x < -tam || posicion.x > MUNDO_ANCHO  + tam ||
      posicion.y < -tam || posicion.y > MUNDO_ALTO + tam) {
      viva = false;
    }

    if (viva) choque();
  }

  public float getY() {
    return y+h;
  }

  void choque() {
    for (int c = solidos.size() - 1; c >= 0; c--) {
      Caja s = solidos.get(c);
      if (overlaps(s)) {                       // la bala choca con un sólido
        if (s instanceof CajaRompible) {
          CajaRompible r = (CajaRompible) s;
          r.daño(1);
          if (r.destruida()) {
            solidos.remove(c);
            sndCajaRota.trigger();
            r.alDestruirse(); // deja de bloquear
          } // deja de bloquear
        }
        viva = false;
        sndBalaChoca.trigger();
        break;
      }
    }

    for (int c = enemigos.size() - 1; c >= 0; c--) {
      Caja s = enemigos.get(c);
      if (overlaps(s)) {                       // la bala choca con un sólido
        if (s instanceof Enemigo) {
          Enemigo r = (Enemigo) s;
          r.daño(this, 1);
        }
        viva = false;
        sndBalaChoca.trigger();
        break;
      }
    }
  }

  public void dibujar(PGraphics p) {
    p.pushMatrix();
    p.translate(posicion.x, posicion.y);
    p.rotate(velocidad.heading()); //Apunta a la dirección que fue disparado (angulo de PVector)
    sprite.dibujar(p, -sprite.ancho(), -sprite.alto()/2, sprite.ancho(), sprite.alto());
    p.popMatrix();
  }
}
