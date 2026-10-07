class Jugador extends Caja {
  // --- Estado ---
  PVector posicion;
  float rapidez;
  float tam;
  int col = 255;

  // --- Animación ---
  boolean moviendose = false;
  float   currentTime = 0;
  float   spriteAngle = 0;

  // --- Punto de nacimiento del cañón (constante, no se recalcula) ---
  final PVector OFFSET_CANON = new PVector(0, -15);

  Jugador(float x, float y, float rapidez, float tam) {
    super(x - tam/2, y - tam, tam, tam);
    this.posicion = new PVector(x, y);
    this.rapidez  = rapidez;
    this.tam      = tam;
  }

  void actualizar(PVector direccion) {
    //POSICIÓN DEL JUGADOR
    move(direccion.x * rapidez, direccion.y * rapidez, solidos);
    posicion.set(x+w/2,y+h);
    
    //DISPARO
    boolean Disparar = input.kW || input.kA || input.kS || input.kD;
    if (Disparar) {
      disparos.disparar(jugador.bocaDeFuego(), input.leerDisparo());
    }
    
    //ANIMACIÓN AL CAMINAR
    animar(direccion.magSq() > 0);
  }

  private void animar(boolean moviendose) {
    this.moviendose = moviendose;
    if (moviendose) {
      currentTime += 0.4;
      spriteAngle  = sin(currentTime) * 0.1;
    } else {
      spriteAngle = 0;
    }
  }

  /** Punto desde donde nacen las balas (borde del sprite, no el centro). */
  PVector bocaDeFuego() {
    return PVector.add(posicion, OFFSET_CANON);
  }

  void dibujar(PGraphics p) {
    drawSombra(p,posicion.x,posicion.y,tam);
    p.pushMatrix();
      p.translate(posicion.x, posicion.y);
      p.rotate(spriteAngle);
      p.fill(col, 0, 0);
      p.rect(-tam/2, -tam, tam, tam);
    p.popMatrix();
  }
}

//--------------- DISPARAR -----------------

class Disparos {
  ArrayList<Bala> balas = new ArrayList<Bala>();

  float cadencia;         // ms entre disparos
  float dispersion;       // radianes
  float rapidezBala;
  float tamBala;
  float radioNacimiento;  // distancia desde la boca al centro de la bala

  int ultimoDisparo = -999999;

  Disparos(float cadencia, float dispersion,
           float rapidezBala, float tamBala, float radioNacimiento) {
    this.cadencia        = cadencia;
    this.dispersion      = dispersion;
    this.rapidezBala     = rapidezBala;
    this.tamBala         = tamBala;
    this.radioNacimiento = radioNacimiento;
  }

  void disparar(PVector centro, PVector direccion) {
    if (millis() - ultimoDisparo < cadencia) return;
    if (direccion.magSq() == 0) return;

    PVector dirFinal = aplicarDispersion(direccion);
    PVector origen   = PVector.add(centro, PVector.mult(dirFinal, radioNacimiento));

    balas.add(new Bala(origen, rapidezBala, dirFinal, tamBala));
    ultimoDisparo = millis();
  }

  void actualizar() {
    for (int i = balas.size() - 1; i >= 0; i--) {
      Bala b = balas.get(i);
      b.actualizar();
      if (!b.viva) balas.remove(i);   // <-- antes nunca se limpiaban
    }
  }

  void dibujar(PGraphics p) {
    for (Bala b : balas) b.dibujar(p);
  }

  private PVector aplicarDispersion(PVector direccion) {
    return direccion.copy().rotate(random(-dispersion, dispersion));
  }
}

//--------------- BALAS -----------------

class Bala extends Caja {
  PVector posicion;
  PVector velocidad;
  float   tam;
  boolean viva = true;
  
  PImage sprBala = loadImage("/Sprites/Jugador/sprJugadorBala.png"); 

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

    if (posicion.x < -tam || posicion.x > width  + tam ||
        posicion.y < -tam || posicion.y > height + tam) {
      viva = false;
    }

    if (viva) choque();
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
  }

  void dibujar(PGraphics p) {
    p.pushMatrix();
      p.translate(posicion.x, posicion.y);
      p.rotate(velocidad.heading()); //Apunta a la dirección que fue disparado (angulo de PVector)
      p.image(sprBala,-sprBala.width,-sprBala.height/2);
    p.popMatrix();
  }
}
