///OBJETO CAJA

//Solido

class CajaRompible extends Caja {
  PImage sprCaja = loadImage("./Sprites/Caja/Caja.png"); //Cargar sprite de la caja
  int vida; //Cuanta vida tiene la caja
  float squishX = 1 , squishY = 1, flash = 0; //Variables de animación
  
  CajaRompible(float x, float y, float w, float h, int vida){
    super(x,y,w,h);
    this.vida = vida;
  }
  
  void daño(int daño){ //Cuando recibe daño
    vida -= daño; //Disminuye su vida por la cantidad de daño que recibe
    squishX = 1.2;
    squishY = 0.7;
    flash = 1;
  }
  
  boolean destruida() { //Si su vida es menor o igual que 0, decir que es tru que está destruida
    return vida <= 0;
  }
  
  void alDestruirse() { } //Funcion vacia //Si quiero hacer otro tipo de cajas , puedo usar esta funcion como comodin para que al destruirse haga x cosa
  
  void dibujar(PGraphics p) {
    squishX = lerp(squishX,1,0.2);
    squishY = lerp(squishY,1,0.2);
    flash = lerp(flash,0,0.2);
    
    p.pushMatrix();
      p.translate(x+(w/2),y+h);
      p.scale(squishX,squishY);
      p.image(sprCaja,-(w/2), -h,w,h);
      p.pushStyle();
        p.blendMode(ADD); //Efecto flash
        p.tint(255, 255*flash); 
        p.image(sprCaja,-(w/2), -h,w,h);
      p.popStyle();
    p.popMatrix();
  }
}


//Caja con moneda

class CajaConMoneda extends CajaRompible { 
  CajaConMoneda(float x, float y, float w, float h, int vida) {
    super(x, y, w, h, vida);
  }

  void alDestruirse() { //Si se destruye, generar monedas
    int cant = 0;
    
    while (cant < 5){
      Moneda m = new Moneda(x+w/2, y+h/2);
      m.lanzar(random(2,4));
      monedas.add(m);
      cant++;
    }
  }
}
