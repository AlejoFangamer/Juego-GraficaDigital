///INICIALIZAR SISTEMA DE COLISIONES

//es bastante simple, Solo funciona con hitboxes rectangulares
//Detecta si x objeto entra en contacto o se solapa con otro objeto, teniendo en cuenta su posicion, anchura y altura.
//Es bastante general, si queremos hacer que un objeto tenga propiedades como posicion o tamaño, las debemos setear con super y depender de ella.
//APOYO DE IA

ArrayList<Caja> solidos = new ArrayList<Caja>();
class Caja implements Dibujable {
  float x, y, w, h;
  color c = color(110);

  boolean colisionable = true;

  Caja(float x, float y, float w, float h) {
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

  public float getY() {
    return y;
  }

  public void dibujar(PGraphics p) { //Dibujar bounding box
    p.pushStyle();
    p.stroke(c);
    p.noFill();
    p.rect(x, y, w, h);
    p.popStyle();
  }

  void move(float dx, float dy, ArrayList<Caja> solids) { //Movimiento de un objeto si choca con solidos
    if (!colisionable) {            // modo fantasma: sin comprobar nada
      x += dx;
      y += dy;
      return;
    }
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

//MUROS CON AUTOTILE

final int TS = 16;
int COLS, ROWS;                          // ya no son final: se definen al crear la sala

boolean[][] gridMuros;                   // se crea en crearRoom
PImage[] tilesMuro = new PImage[16];
ArrayList<Muro> muros = new ArrayList<Muro>();

final int[] DX = { 0, 1, 0, -1 };        // N, E, S, W
final int[] DY = {-1, 0, 1,  0 };

final int[][] POS = {
  {3, 3}, {3, 2}, {0, 3}, {0, 2},
  {3, 0}, {3, 1}, {0, 0}, {0, 1},
  {2, 3}, {2, 2}, {1, 3}, {1, 2},
  {2, 0}, {2, 1}, {1, 0}, {1, 1}
};

void cargarTilesetMuros(String file) {
  PImage sheet = loadImage(file);
  int ts = sheet.width / 4;
  for (int m = 0; m < 16; m++) {
    tilesMuro[m] = sheet.get(POS[m][0] * ts, POS[m][1] * ts, ts, ts);
  }
}


class Muro extends Caja {
  int gx, gy;                            // posición en CELDAS

  Muro(int gx, int gy) {
    super(gx * TS, gy * TS, TS, TS);     // x, y en píxeles
    this.gx = gx;
    this.gy = gy;
  }

  int calcBitmask() {
    int mask = 0;
    for (int i = 0; i < 4; i++) {
      int nx = gx + DX[i];
      int ny = gy + DY[i];
      if (nx >= 0 && nx < COLS && ny >= 0 && ny < ROWS && gridMuros[nx][ny]) {
        mask |= 1 << i;
      }
    }
    return mask;
  }
  
  public float getY() {
    return y+h;
  }

  public void dibujar(PGraphics p) {
    //p.image(muroBottom,x,y+TS/2,TS,TS);
    p.image(tilesMuro[calcBitmask()], x, y, TS, TS);
    
  }
}
