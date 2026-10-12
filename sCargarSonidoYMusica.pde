///CARGAR SONIDOS Y MUSICAS
import gifAnimation.*;
import ddf.minim.*;  //Cargar libreria Minim (sonidos)

String s = "/Sonidos/";  //Carpeta de sonidos
String m = "/Musicas/";  //Carpeta de Musicas

Minim minim;

//EFECTOS DE SONIDOS
AudioSample 
  sndMoneda,
  sndBalaChoca,
  sndCajaRota,
  sndCorazon;
  
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
  
  //musUrea = minim.loadFile(m+"musUrea.mp3"); //Cargar musicas //Puta madre minim, como no vas a aceptar ogg, me cago en la puta de oro.
  //musUrea.setGain(-5);
  //musUrea.loop(); //Se repite la musica
  //musUrea.play(); //Reproducir la musica.
}


///CARGAR SPRITES




//LOGICA SPRITES

HashMap<String, PImage[]> cacheFrames = new HashMap<String, PImage[]>();

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

class Sprite {
  PImage[] frames;

  float   fps          = 10;    // frames del gif por segundo
  float   velocidad    = 1.0; 
  int     frameInicial = 0;
  boolean loop         = true;
  boolean pausado      = false;
  boolean terminado    = false; 

  private float cursor; // frame actual

  Sprite(String ruta) {
    frames = cargarFrames("./Sprites/"+ruta);
    reiniciar();
  }

  void reiniciar() {
    cursor = constrain(frameInicial, 0, frames.length - 1);
    terminado = false;
  }

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

  PImage frameActual() {
    return frames[constrain(int(cursor), 0, frames.length - 1)];
  }

  int cantidadFrames() { return frames.length; }

  void dibujar(PGraphics p, float x, float y, float w, float h) {
    PImage f = frameActual();
    p.image(f, x, y,w,h);
  }
}
