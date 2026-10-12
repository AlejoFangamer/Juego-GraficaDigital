int vida = 3;

class Jugador extends Caja {
  PImage sprJugador = loadImage("./Sprites/Jugador/Jugador.png");
  
  // --- Estado ---
  PVector posicion;
  int vida;
  int maxVida;
  float Mirar = 1;
  float spriteMirar = Mirar;
  float rapidez;
  float tam;
  int col = 255;
  
  //--I-frames--
  int duracionIFrames = 1000;   // ms de invulnerabilidad
  int ultimoGolpe    = -999999;
  
  //--Knockback--
  PVector velocidadKnockback = new PVector(0, 0);
  float   fuerzaKnockback    = 8;      // píxeles por frame
  float   friccionKnockback  = 0.85; 

  // --- Animación ---
  boolean moviendose = false;
  float   currentTime = 0;
  float   spriteAngle = 0;
  float   spriteOpacity = 1;

  // --- Punto de nacimiento del cañón (constante, no se recalcula) ---
  final PVector OFFSET_CANON = new PVector(0, -8);

  Jugador(float x, float y, float rapidez, float tam, int vida) {
    super(x - tam/2, y - tam, 8, 8);
    this.posicion = new PVector(x, y);
    this.rapidez  = rapidez;
    this.tam      = tam;
    this.vida     = vida;
    this.maxVida  = vida;
  }
  
  void daño(Caja atacante, int cantidad) {
    if (IFrame()) return;
    ultimoGolpe = millis();
    
     // Overlap en cada eje
    float overlapX = Math.min(x + w, atacante.x + atacante.w) - Math.max(x, atacante.x);
    float overlapY = Math.min(y + h, atacante.y + atacante.h) - Math.max(y, atacante.y);
  
    // El eje con MENOS solapamiento es el lado del impacto
    if (overlapX < overlapY) {
      velocidadKnockback = new PVector(x < atacante.x ? -1 : 1, 0).mult(fuerzaKnockback);
    } else {
      velocidadKnockback = new PVector(0, y < atacante.y ? -1 : 1).mult(fuerzaKnockback);
    }
  
    if (vida > 0){
      vida -= cantidad;
    }
  };
  
  boolean IFrame() {
    return millis() - ultimoGolpe < duracionIFrames;
  };

  void actualizar(PVector direccionPos) {
    //POSICIÓN DEL JUGADOR
    
    posicion.set(x+w/2,y+h);
    move(direccionPos.x * rapidez, direccionPos.y * rapidez, solidos); 
    
    move(velocidadKnockback.x, velocidadKnockback.y, solidos);

    velocidadKnockback.mult(friccionKnockback);
    if (velocidadKnockback.magSq() < 0.01) velocidadKnockback.set(0, 0);
    
    //DISPARO
    boolean Disparar = input.kW || input.kA || input.kS || input.kD;
    if (Disparar) {
      disparos.disparar(jugador.bocaDeFuego(), input.leerDisparo());
    }
    
    //ANIMACIÓN AL CAMINAR
    PVector disparo = input.leerDisparo();
    
    animar(direccionPos.magSq() > 0);
    
    if (Math.abs(disparo.x) > 0.01) {
      Mirar = (disparo.x > 0) ? -1 : 1;
    }
    // Si no hay disparo, miramos hacia donde nos movemos
    else if (Math.abs(direccionPos.x) > 0.01) {
      Mirar = (direccionPos.x > 0) ? -1 : 1;
    }
    
    vida = constrain(vida,0,50);
  }

  private void animar(boolean moviendose) {
    this.moviendose = moviendose;
    
    spriteMirar = lerp(spriteMirar,Mirar,0.3);
    
    if (IFrame()){
      spriteOpacity = sin(millis()) * 1.5;
    }else{
      spriteOpacity = 1;
    }
    
    if (moviendose) {
      currentTime += 0.7;
      spriteAngle  = sin(currentTime) * 0.1;
    } else {
      spriteAngle = 0;
    }
  }

  /** Punto desde donde nacen las balas (borde del sprite, no el centro). */
  PVector bocaDeFuego() {
    return PVector.add(posicion, OFFSET_CANON);
  }
  
  public float getY() {
    return y+h;
  }

  void dibujar(PGraphics p) {
    drawSombra(p,posicion.x+(0.9*Mirar),posicion.y,tam);
    
    p.push();
      p.translate(posicion.x, posicion.y);
      //p.rotate(spriteAngle);
      p.fill(col, 0, 0);
      p.tint(255,255*spriteOpacity);
      //p.rect(-tam/2, -tam, tam, tam);
      p.scale(spriteMirar-(spriteAngle*Mirar),1+spriteAngle);
      p.image(sprJugador,-tam/2, -tam);
    p.pop();
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
    
    for (int c = killers.size() - 1; c >= 0; c--) {
      Caja s = killers.get(c);
      if (overlaps(s)) {                       // la bala choca con un sólido
        if (s instanceof Enemigo) {
          Enemigo r = (Enemigo) s;
          r.daño(this,1);
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
