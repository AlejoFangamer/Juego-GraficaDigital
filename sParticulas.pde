class SistemaParticulas {
  boolean muerto = false;
}
//PARTICULAS DE PERDIDA DE VIDA.

ArrayList<DañoParticula> particulas = new ArrayList<DañoParticula>();
PFont everydayStandardBlack;

class DañoParticula extends SistemaParticulas{
  RShape grp;
  
  
  float   x, y;
  PVector posicion;
  PVector velocidad;
  PVector dir;
  float   vy, vx;      // velocidad
  float   alpha;       // transparencia
  float   fadeSpeed;
  String  txt;
  float   size;
  
  float   ang;         // ángulo actual
  float   rotSpeed;    // velocidad de rotación
  
  DañoParticula(float x, float y, String txt) {
    this.posicion = new PVector(x,y);
    
    this.dir = new PVector(0,-1);
    this.velocidad = PVector.mult(dir,2.0);
    this.txt = txt;
    
    this.alpha = 255;
    this.size = 7;
    this.vx = random(-2, 2);     // sale en dirección aleatoria
    this.vy = random(-4, -1);    // sube un poco primero
    this.fadeSpeed = random(3, 6);
    
    this.ang = 0;          // ángulo inicial aleatorio
    this.rotSpeed = random(-0.01, 0.01);
    
    //RG.init(this);
  }
  
  void actualizar() {
    posicion.add(velocidad);
    velocidad.mult(0.96);
    
    alpha -= fadeSpeed;  
    
    if (alpha <= 0) { muerto = true; }
  }
  
  void dibujar(PGraphics p) {
    p.pushMatrix();
    p.pushStyle();
      p.textFont(everydayStandardBlack,size);
      p.textAlign(CENTER, CENTER);
      p.translate(posicion.x, posicion.y);
      p.rotate(ang);
      p.fill(255, 255, 255, alpha);   // color con transparencia
      p.text(txt, 0, 0);
    p.popStyle();
    p.popMatrix();
  }
}
