class SistemaParticulas {
  boolean muerto = false;
}

ArrayList<DañoParticula> particulas = new ArrayList<DañoParticula>();

PFont everydayStandardBlack;

class DañoParticula extends SistemaParticulas{
  float x, y;
  float vy, vx;      // velocidad
  float alpha;       // transparencia
  float fadeSpeed;
  String txt;
  float size;
  
  float ang;         // ángulo actual
  float rotSpeed;    // velocidad de rotación
  
  DañoParticula(float x, float y, String txt) {
    this.x = x;
    this.y = y;
    this.txt = txt;
    this.alpha = 255;
    this.size = 8;
    this.vx = random(-2, 2);     // sale en dirección aleatoria
    this.vy = random(-4, -1);    // sube un poco primero
    this.fadeSpeed = random(3, 6);
    
    this.ang = 0;          // ángulo inicial aleatorio
    this.rotSpeed = random(-0.01, 0.01);
  }
  
  void actualizar() {
    x += vx;
    y += vy/2;
    vy += 0.3;       // gravedad — la jala hacia abajo
    alpha -= fadeSpeed;  
    
    if (size <= 0 || alpha <= 0) { muerto = true; }
  }
  
  void dibujar(PGraphics p) {
    p.pushMatrix();
    p.pushStyle();
      p.textFont(everydayStandardBlack,size);
      p.textAlign(CENTER, CENTER);
      p.translate(x, y);
      p.rotate(ang);
      p.fill(255, 255, 255, alpha);   // color con transparencia
      p.text(txt, 0, 0);
    p.popStyle();
    p.popMatrix();
  }
}
