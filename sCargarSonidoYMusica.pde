/// CARGAR SONIDOS Y MUSICAS

import gifAnimation.*;
import ddf.minim.*;  //Cargar libreria Minim (sonidos)

String s = "/Sonidos/";  //Carpeta de sonidos
String m = "/Musicas/";  //Carpeta de Musicas

PImage muroBottom;

Minim minim;

//EFECTOS DE SONIDOS
AudioSample 
  sndMoneda,
  sndBalaChoca,
  sndCajaRota,
  sndCorazon,
  
  sndEsqueleto1,
  sndEsqueleto2,
  sndEsqueletoMuere,
  
  sndJugadorHit,
  sndJugadorMuere
  ;
  
//MUSICAS

AudioPlayer
  musUrea;
  
void CargarSonidos() {
  minim = new Minim(this);
  
  sndMoneda = minim.loadSample(s+"sndMonedaRecogida.wav",512); //Cargar sonidos
  sndCajaRota = minim.loadSample(s+"sndCajaRota.wav",512); 
  
  sndBalaChoca = minim.loadSample(s+"sndBalaChoca.wav",512);
  sndBalaChoca.setGain(-5); //Bajar o subir volumen
  
  sndCorazon = minim.loadSample(s+"sndCorazonRecogido.wav",512);
  
  sndEsqueleto1 = minim.loadSample(s+"sndEsqueleto1.wav",512);
  sndEsqueleto2 = minim.loadSample(s+"sndEsqueleto2.wav",512);
  sndEsqueletoMuere =  minim.loadSample(s+"sndEsqueletoMuere.wav",512);
  
  sndJugadorMuere = minim.loadSample(s+"sndJugadorMuerte.wav",512);
  sndJugadorHit = minim.loadSample(s+"sndJugadorHit.wav",512);
  
  musUrea = minim.loadFile(m+"musTopHoppy.mp3"); //Cargar musicas //Puta madre minim, como no vas a aceptar ogg, me cago en la puta de oro.
  musUrea.setGain(-5);
  musUrea.play(); //Reproducir la musica.
  musUrea.loop(); //Se repite la musica
  
  cargarTilesetMuros("/Sprites/Tileset/Tileset2.png"); 
  muroBottom = loadImage("/Sprites/Tileset/TestTile_Bottom.png"); 
}


///CARGAR SPRITES


//Sistema de carga de sprites
//con funciones extra como el iniciar por un frame en especifico o reproducir la animación en una velocidad especifica.

HashMap<String, PImage[]> cacheFrames = new HashMap<String, PImage[]>(); //Cachea el sprite para que no se vuelva a cargar.

//Funcion para cargar los frames de una animación
//Detecta si el archivo es Gif. o otro archivo de imagen.
//Si es gif, guarda todos los frames en cacheFrames.
//Si no, simplemente los guarda en un PImage.

PImage[] cargarFrames(String ruta) {
  if (!cacheFrames.containsKey(ruta)) {
    PImage[] frames;
    if (ruta.toLowerCase().endsWith(".gif")) {
      frames = Gif.getPImages(this, ruta);
    } else {
      frames = new PImage[] { loadImage(ruta) };
    }
    cacheFrames.put(ruta, frames);
  }
  return cacheFrames.get(ruta);
}

//Clase padre de Sprite

class Sprite {
  PImage[] frames;

  float   fps          = 10;    // frames del gif por segundo
  float   velocidad    = 1.0;   // Velocidad de la animación.
  int     frameInicial = 0;     // Frame inicial de la animación.
  boolean loop         = true;  // La animación se repite o no ?.
  boolean pausado      = false; // La animación se pausa.
  boolean terminado    = false; // Detecta si la animación se termina.

  private float cursor; // frame actual

  Sprite(String ruta) {
    frames = cargarFrames("./Sprites/"+ruta);
    reiniciar();
  }
  
  int ancho() { return frames[0].width; } //Regresa el ancho de la animación.
  int alto()  { return frames[0].height; } //Regresa el alto de la animación.

  void reiniciar() {
    cursor = constrain(frameInicial, 0, frames.length - 1);
    terminado = false;
  }

  //Actualizar la reproducción de la animación.
  void actualizar() {
    if (frames.length <= 1 || pausado || terminado) return;
    cursor += (fps / 60.0) * velocidad;
    if (cursor >= frames.length) {
      if (loop) {
        cursor %= frames.length;
      } else {
        cursor = frames.length - 1;
        terminado = true;
      }
    }
  }

  // Regresa el frame actual de la animación.
  PImage frameActual() {
    return frames[constrain(int(cursor), 0, frames.length - 1)];
  }

  int cantidadFrames() { return frames.length; } //Regresa la cantidad de frames que tiene una animación.

  void dibujar(PGraphics p, float x, float y, float w, float h) { //Dibuja el sprite, animado o no, de la misma forma que Image.
    PImage f = frameActual();
    p.image(f, x, y,w,h);
  }
}
