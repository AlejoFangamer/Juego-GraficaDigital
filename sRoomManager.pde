/// SISTEMA DE CREACIÓN DE HABITACIONES

// Funcion para que se cargue una nueva habitación.
// Basicamente elimina todo en la sala y los vuelve a crear dependiendo de una imagen.


PImage roomTest;
int floorsPasados = -1; //Cuantas habitaciones has pasado.

String[] roomFiles = {
  "r1.png",
  "r2.png",
  "r3.png"
}; //Cargar habitaciones.

PImage[] roomImages = new PImage[roomFiles.length];


void crearNuevaRoom(PImage room) {
  //---REINICIAR TODO---
  items = new ArrayList<Items>();
  enemigos = new ArrayList<Killer>();
  solidos = new ArrayList<Caja>();
  solidosRompibles = new ArrayList<Caja>();
  balas = new ArrayList<Bala>();
  puertas = new ArrayList<Puerta>();
  
  enemigosDerrotados = 0;
  enemigosTotales = 0;
  floorsPasados++;
  transOpacidad = 1;
  //---------------------
  
  final int colorBloque = #000000;
  final int colorJugador = #00ffff;
  final int colorEnemigo = #ff0000;
  final int colorPuerta = #ffff00;
  final int colorCaja = #8f563b;
  
  camara = null;
  
  //Desde acá se inicia el sistema de detección de grilla para el autotile.
  
  COLS = room.width;              
  ROWS = room.height;
  MUNDO_ANCHO = COLS * TS;
  MUNDO_ALTO  = ROWS * TS;
  
  gridMuros = new boolean[COLS][ROWS];   // cuadrícula nueva para esta sala
  muros.clear();

  room.loadPixels(); //Carga todos los pixeles de la imagen
  
  for(int x = 0; x < room.width; x++){
    for(int y = 0; y < room.height; y++){
      
      int index = x+y * room.width;
      color colorPixel = room.pixels[index];
      
      switch (colorPixel) {
        case colorJugador:
          jugador = new Jugador(x*TS, y*TS, 2, 5);
          break;
        
        case colorBloque:
          //solidos.add(new CajaConMoneda(x*16, y*16, 16, 16, 1));
          gridMuros[x][y] = true;        // celdas, no píxeles
          Muro m = new Muro(x, y);
          muros.add(m);
          solidos.add(m);
          break;
        
        case colorEnemigo:
          enemigos.add(new Enemigo(x*TS, y*TS, 2));
          break;  
          
        case colorPuerta:
          puertas.add(new Puerta(x*TS,y*TS));
          break;
          
        case colorCaja:
          solidos.add(new CajaConMoneda(x*TS,y*TS,TS,TS,3));
          break; 
          
      }
    }
  }
  
  //Crear la camara
  camara = new Camara(ventanaW, ventanaH, MUNDO_ANCHO, MUNDO_ALTO);
  //Poner la camara en el centro del jugador
  camara.centrar(jugador.x + jugador.w/2, jugador.y + jugador.h/2);
  
  enemigosTotales = enemigos.size();
}

//

ArrayList<Puerta> puertas = new ArrayList<Puerta>();

class Puerta extends Caja {
  boolean abierto = false; //Jejejejeje
  
  Sprite sprPuerta = new Sprite("Tileset/Puerta.gif");
  
  Puerta(float x, float y){
    super(x,y,32,16);
    sprPuerta.fps = 0;
    sprPuerta.frameInicial = 0;
    sprPuerta.reiniciar();
  }
  
  
  //Si el jugador se choca con la puerta, puede pasar a la siguiente sala.
  //Pero solo si no hay enemigos en la sala.
  void actualizar(){
    if (enemigos.isEmpty()){
      sprPuerta.cursor = 1;
      
      if (jugador.overlaps(this)) {
        crearNuevaRoom(roomImages[round(random(0,2))]);
      }
    }
  }
  
  public void dibujar(PGraphics p){
    p.push();
      p.translate(x,y);
      sprPuerta.dibujar(p, 0, 0, w, h);
    p.pop();
  }
}
