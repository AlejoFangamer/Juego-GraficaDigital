///CARGAR SONIDOS Y MUSICAS

import ddf.minim.*;  //Cargar libreria Minim (sonidos)

String s = "/Sonidos/";  //Carpeta de sonidos
String m = "/Musicas/";  //Carpeta de Musicas

Minim minim;

//EFECTOS DE SONIDOS
AudioSample 
  sndMoneda,
  sndBalaChoca,
  sndCajaRota;
  
//MUSICAS

AudioPlayer
  musUrea;
  
void CargarSonidos() {
  minim = new Minim(this);
  
  sndMoneda = minim.loadSample(s+"sndMonedaRecogida.wav",512); //Cargar sonidos
  sndCajaRota = minim.loadSample(s+"sndCajaRota.wav",512); 
  sndBalaChoca = minim.loadSample(s+"sndBalaChoca.wav",512);
  sndBalaChoca.setGain(-5); //Bajar o subir volumen
  
  musUrea = minim.loadFile(m+"musUrea.mp3"); //Cargar musicas //Puta madre minim, como no vas a aceptar ogg, me cago en la puta de oro.
  musUrea.setGain(-5);
  musUrea.loop(); //Se repite la musica
  musUrea.play(); //Reproducir la musica.
}
