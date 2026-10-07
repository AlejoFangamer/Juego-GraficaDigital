import gifAnimation.*; //Libreria de animación por gif //Dudo que sea la mejor manera, pero no conozco otra mejor xD
import java.util.Collections;
import java.util.Comparator;

int ventanaW = 320; //Tamaño real de la ventana
int ventanaH = 180;

int ventanaW_new = ventanaW*4; //Tamaño maximizado de la ventana
int ventanaH_new = ventanaH*4;

int puntos = 0;

PGraphics lienzo;
PImage fondo;

Jugador jugador;
Disparos disparos;
InputManager input;
HUD hud;

interface Dibujable {
  float getY();   // la y de la "base" del objeto
  void dibujar(PGraphics p);
}

ArrayList<Moneda> monedas = new ArrayList<Moneda>();
ArrayList<Caja> solidos = new ArrayList<Caja>();
ArrayList<Caja> solidosRompibles = new ArrayList<Caja>();

ArrayList<Dibujable> escena = new ArrayList<Dibujable>();

float lengthdir_x(float len, float dir) {
  return len * cos(radians(dir));
}

float lengthdir_y(float len, float dir) {
  return len * sin(radians(dir));
}

void init() { //INICIALIZAR TODO Y REPETIR TODO

  monedas = new ArrayList<Moneda>();
  solidos = new ArrayList<Caja>();
  solidosRompibles = new ArrayList<Caja>();
  
  //Crear al jugador
  jugador = new Jugador(ventanaW/2,ventanaH/2,3,32); 
  
  //Crear la camara
  camara = new Camara(ventanaW, ventanaH, MUNDO_ANCHO, MUNDO_ALTO);
  //Poner la camara en el centro del jugador
  camara.centrar(jugador.x + jugador.w/2, jugador.y + jugador.h/2);
  
  //El disparo del jugador
  disparos = new Disparos(
    100,               // cadencia ms
    radians(2),        // dispersión
    5,                 // rapidez bala
    5,                 // tamaño bala
    16                // radio de nacimiento (boca → bala)
  );
  
  //Generar monedas aleatoriamente por la sala
  while (monedas.size() < 10) {
    monedas.add(new Moneda(32+random(MUNDO_ANCHO-64), 32+random(MUNDO_ALTO-64)));
  }
  
  for (int c = 0; c < 360; c+= 360/5){
    float puntaX = 200 + lengthdir_x(32, c);
    float puntaY = 100 + lengthdir_y(32, c);
    solidos.add(new CajaConMoneda(puntaX, puntaY, 32, 32,3));
  }
  
  //Añadir cajas a la sala, de diferente tipo
  solidos.add(new CajaRompible(32, 32, 32, 32,10));
  solidos.add(new CajaConMoneda(64, 64, 32, 32,10));
  
  puntos = 0;
  
  sprMoneda = new Gif(this, "./Sprites/Moneda/Moneda.gif");
  sprMoneda.loop();
  
}

void settings() { //Setear el sketch
  size(ventanaW, ventanaH,P2D);
  noSmooth(); //Sin antialias
}

void setup() {
  centrarVentana(); //Centrar la ventana en caso de que se mueva
  input = new InputManager(); //Iniciar sistema de botones
  hud = new HUD(); //Iniciar sistema de interfaz
  
  CargarSonidos(); //Cargar sonidos y musicas
  
  //EFECTO PIXEL PERFECT 
  hint(DISABLE_TEXTURE_MIPMAPS);
  ((PGraphicsOpenGL)g).textureSampling(3);
  lienzo = createGraphics(ventanaW, ventanaH,JAVA2D);
  
  //Carga fondo
  fondo = loadImage("/Sprites/Fondo/Fondo.jpg");
  
  //Setear los fps a 60
  frameRate(60); 
  
  //Inicializar sala y variables
  init();
}

void draw() {
  background(0);
  createCanvas();
  actualizarProcesos();
}

void keyPressed() {
  input.presionar(key,keyCode);
  
  if (key == 'r' || key == 'R') {
    init();
  }
}

void keyReleased() {
  input.soltar(key,keyCode);
}

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
        
        for (int x = 0; x < width; x += fondo.width) { //Dibujar fondo , me cago en processing y su forma de no tener fondos repetidos, es que me cago en su puta madre, son las 3am
          for (int y = 0; y < height; y += fondo.height) {
            lienzo.image(fondo, x, y);
          }
        }
        
        jugador.dibujar(lienzo); //Dibujar al jugador
        disparos.dibujar(lienzo); //Dibujar las balas
        /*for (Moneda m : monedas) m.dibujar(lienzo); //Dibujar todas las monedas
        for (Caja s : solidos) s.dibujar(lienzo); //Dibujar todos los solidos*/
        for (Dibujable d : escena) d.dibujar(lienzo);
        
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
  for (Moneda m : monedas) m.actualizar();
  monedas.removeIf(m -> m.recogida); 
  
  
  escena.clear();
  //escena.add(jugador);
  escena.addAll(monedas);
  escena.addAll(solidos);
  Collections.sort(escena, new Comparator<Dibujable>() {
    public int compare(Dibujable a, Dibujable b) {
      return Float.compare(a.getY(), b.getY());
    }
  });
}
