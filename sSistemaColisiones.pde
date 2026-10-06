///INICIALIZAR SISTEMA DE COLISIONES

//es bastante simple, Solo funciona con hitboxes rectangulares
//Detecta si x objeto entra en contacto o se solapa con otro objeto, teniendo en cuenta su posicion, anchura y altura.
//Es bastante general, si queremos hacer que un objeto tenga propiedades como posicion o tamaño, las debemos setear con super y depender de ella.

class Caja {
  float x, y, w, h;
  color c = color(110);
  
  Caja(float x, float y, float w, float h){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  boolean overlaps(Caja o) { //Codigo que detecta si un objeto se solapa con otro
    return x < o.x + o.w &&
           x + w > o.x &&
           y < o.y + o.h &&
           y + h > o.y;
  }
  
  void dibujar(PGraphics p) { //Dibujar bounding box
    p.pushStyle();
      p.stroke(c);
      p.noFill();
      p.rect(x, y, w, h);
    p.popStyle();
  }
  
  void move(float dx, float dy, ArrayList<Caja> solids) { //Movimiento de un objeto si choca con solidos
    // Eje X
    x += dx; //Avanza en x
    for (Caja s : solids) { //Para cada caja que entre en la categoria SOLIDA
      if (s != this && overlaps(s)) { //Si el objeto no es si mismo y se solapa con un solido
        if (dx > 0) x = s.x - w;       // choco yendo a la derecha //Se pone la posicion del solido menos el tamaño de la hitbox del que se mueve
        else if (dx < 0) x = s.x + s.w; // choco yendo a la izquierda
      }
    }
    // Eje Y
    y += dy;  //Avanza en y
    for (Caja s : solids) {
      if (s != this && overlaps(s)) {
        if (dy > 0) y = s.y - h;       // choco yendo hacia abajo
        else if (dy < 0) y = s.y + s.h; // choco yendo hacia arriba
      }
    }
  }
}
