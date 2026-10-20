/// INICIADOR
// Todo se configura y se inicia desde este punto

//import java.util.Collections;
import java.util.Comparator;
import geomerative.*; //Libreria.


int ventanaW = 320; //Tamaño real de la ventana
int ventanaH = 180;

int ventanaMult = 4;
int ventanaW_new = ventanaW*ventanaMult; //Tamaño maximizado de la ventana
int ventanaH_new = ventanaH*ventanaMult;

int puntos = 0;

PGraphics lienzo;
PImage fondo;

interface Dibujable {
  float getY();   // la y de la "base" del objeto
  void dibujar(PGraphics p);
}

ArrayList<Dibujable> escena = new ArrayList<Dibujable>(); // 

float lengthdir_x(float len, float dir) {
  return len * cos(radians(dir));
}

float lengthdir_y(float len, float dir) {
  return len * sin(radians(dir));
}

//INICIALIZAR TODO Y REPETIR TODO
void init() {

  for (int i = 0; i < roomFiles.length; i++) {
      roomImages[i] = loadImage("Niveles/" + roomFiles[i]);
  }

  //Inicia en una room
  //roomTest = loadImage(); 
  floorsPasados = -1;
  crearNuevaRoom(roomImages[round(random(0,2))]);

  //El disparo del jugador
  disparos = new Disparos(
    300,
    radians(2), // dispersión
    5, // rapidez bala
    5, // tamaño bala
    8 // radio de nacimiento (boca → bala)
   );

}

// SETEAR EL SKETCH //

void settings() { 
  size(ventanaW, ventanaH, P2D);
  noSmooth(); //Sin antialias
}

// EJECUTAR COSAS QUE SOLO SE DEBEN EJECUTAR UNA SOLA VEZ //

void setup() {
  centrarVentana(); //Centrar la ventana en caso de que se mueva
  input = new InputManager(); //Iniciar sistema de botones
  hud = new HUD(); //Iniciar sistema de interfaz

  CargarSonidos(); //Cargar sonidos y musicas
  
  everydayStandardBlack = loadFont("./Fuentes/Everyday_Standard_Black-48.vlw");
  
  //EFECTO PIXEL PERFECT
  hint(DISABLE_TEXTURE_MIPMAPS);
  ((PGraphicsOpenGL)g).textureSampling(3);
  lienzo = createGraphics(ventanaW, ventanaH, JAVA2D);
  
  frameRate(60); // 60 FPS

  //Carga fondo
  fondo = loadImage("/Sprites/Fondo/Fondo1.png");

  //Inicializar sala y variables
  init();
}

void draw() {
  background(0);
  createCanvas();
  actualizarProcesos();

  windowTitle("Magic Rooms | fps: " + floor(frameRate));
}


// CENTRAR LA VENTANA AL CENTRO DEL MONITOR
// ORIGINALMENTE USADO EN CASO DE QUE SE REDIMENSIONE LA VENTANA.

void centrarVentana() {
  windowResize(ventanaW_new, ventanaH_new);
  int screenW = displayWidth; //Ancho del monitor
  int screenH = displayHeight; //Alto del monitor
  int x = (screenW - width) / 2;
  int y = (screenH - height) / 2;
  surface.setLocation(x, y);
}

//TODO SE DIBUJA ACA
void createCanvas() {
  lienzo.beginDraw();
    lienzo.background(0);
    lienzo.pushMatrix();
    
      camara.aplicar(lienzo); //La camara mueve todo lo que se dibuja
    
      for (int x = 0; x < width; x += fondo.width) { //Dibujar fondo , me cago en processing y su forma de no tener fondos repetidos, es que me cago en su puta madre, son las 3am.
        for (int y = 0; y < height; y += fondo.height) {
          lienzo.image(fondo, x, y);
        }
      }
    
      for (Dibujable d : escena) d.dibujar(lienzo);
      //for (Muro p : muros) p.dibujar(lienzo); 
      for (DañoParticula p : particulas) p.dibujar(lienzo); 
  
    lienzo.popMatrix();
    hud.dibujar(lienzo); //Dibujar la interfaz
  lienzo.endDraw();

  image(lienzo, 0, 0, width, height);
}

//CUALQUIER PROCESO QUE NECESITE DE CONSTANTE ACTUALIZACIÓN, SE PONE AQUI
void actualizarProcesos() {
  PVector dirMovimiento = input.leerMovimiento();  // flechas
  jugador.actualizar(dirMovimiento);
  
  camara.seguir(jugador.x + jugador.w/2, jugador.y + jugador.h/2);
  disparos.actualizar();

  for (Killer a : enemigos) a.actualizar();
  for (Items m : items) m.actualizar();
 
  for (Puerta n : puertas) n.actualizar(); 
  
  for (DañoParticula p : particulas) p.actualizar();
  
  particulas.removeIf(m -> m.muerto);
  items.removeIf(m -> m.recogida);
  
  int antes = enemigos.size();
  enemigos.removeIf(e -> e.muerto);
  enemigosDerrotados += antes - enemigos.size();
  
  
  //SISTEMA DE Y-SORTING
  //COMPARA LAS POSICIONES EN Y DE TODOS LOS OBJETOS.
  //SI OBJETO A ESTÁ MAS ABAJO QUE OBJETO B, DIBUJARÁ EL OBJETO A POR ENCIMA DE OBJETO B.
  //APOYO DE IA

  escena.clear();
  escena.add(jugador);
  escena.addAll(items);
  escena.addAll(solidos);
  escena.addAll(enemigos);
  escena.addAll(balas);
  escena.addAll(muros);
  escena.addAll(puertas);
  escena.sort((a, b) -> Float.compare(a.getY(), b.getY()));
}
