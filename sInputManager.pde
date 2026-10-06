///INICIALIZAR SISTEMA DE BOTONES ACCIONADORES

//detecta constantemente si se están presionando ciertas teclas.
//y esta detección se almacena en variables que otros objetos pueden usar.

class InputManager {
  
  private boolean kUp, kDown, kLeft, kRight; //Teclas Direccionales
  private boolean kW, kA, kS, kD; //Teclas de letras
  
  void presionar(char k , int tecla) { //Si se presiona un codigo o tecla , activarla.
    setKey(k,tecla,true);
  }
  
  void soltar(char k , int tecla) { //si se suelta la tecla, desactivarla.
    setKey(k,tecla,false);
  }
  
  private void setKey(char k, int kc, boolean val) { //si alguna tecla de las mencionadas es presionada o soltada, su variable guarda este registro
    switch (Character.toLowerCase(k)) {
      case 'w': kW     = val; break;
      case 'a': kA     = val; break;
      case 's': kS     = val; break;
      case 'd': kD     = val; break;
    }
    
    if (kc == UP)    kUp    = val;
    if (kc == DOWN)  kDown  = val;
    if (kc == LEFT)  kLeft  = val;
    if (kc == RIGHT) kRight = val;
  }
  
  //MOVIMIENTO DE JUGADOR
  
  PVector leerMovimiento() {
    PVector d = new PVector(0, 0);
    if (input.kUp)    d.y -= 1;
    if (input.kDown)  d.y += 1;
    if (input.kLeft)  d.x -= 1;
    if (input.kRight) d.x += 1;
    if (d.magSq() > 1) d.normalize(); //se normaliza el movimiento para que no vaya mas rapido en diagonal
    return d;
  }
  
  //DIRECCIÓN DE DISPARO (WASD)

  PVector leerDisparo() {
    PVector d = new PVector(0, 0);
    if (input.kW) d.y -= 1;
    if (input.kS) d.y += 1;
    if (input.kA) d.x -= 1;
    if (input.kD) d.x += 1;
    if (d.magSq() > 1) d.normalize();
    return d;
  }
}
