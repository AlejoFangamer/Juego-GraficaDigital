PImage roomTest;

void crearRoom(PImage room) {
  final int colorBloque = #000000;
  final int colorJugador = #00ffff;
  final int colorEnemigo = #ff0000;
  
  MUNDO_ANCHO = room.width*16; 
  MUNDO_ALTO  = room.height*16;
  
  room.loadPixels();
  
  for(int x = 0; x < room.width; x++){
    for(int y = 0; y < room.height; y++){
      
      int index = x+y * room.width;
      color colorPixel = room.pixels[index];
      
      switch (colorPixel) {
        
        case colorBloque:
          solidos.add(new CajaConMoneda(x*16, y*16, 16, 16, 1));
          break;
          
        case colorJugador:
          jugador = new Jugador(x*16, y*16, 2, 5);
          break;
        
        case colorEnemigo:
          enemigos.add(new Enemigo(x*16, y*16, 5));
          break;  
          
      }
    }
  }
}
