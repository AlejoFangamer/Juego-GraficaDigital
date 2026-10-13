///OBJETO CAJA

//Solido
ArrayList<Caja> solidosRompibles = new ArrayList<Caja>();
class CajaRompible extends Caja implements Dibujable {
  Sprite sprite = new Sprite("Caja/Caja.png"); //Cargar sprite de la caja
  int vida; //Cuanta vida tiene la caja
  float squishX = 1, squishY = 1, flash = 0; //Variables de animación

  CajaRompible(float x, float y, float w, float h, int vida) {
    super(x, y, w, h);
    this.vida = vida;
  }

  void daño(int daño) { //Cuando recibe daño
    vida -= daño; //Disminuye su vida por la cantidad de daño que recibe
    squishX = 1.2;
    squishY = 0.7;
    flash = 1;
  }

  boolean destruida() { //Si su vida es menor o igual que 0, decir que es tru que está destruida
    return vida <= 0;
  }

  void alDestruirse() {
  }
  
  //Funcion vacia //Si quiero hacer otro tipo de cajas , puedo usar esta funcion como comodin para que al destruirse haga x cosa
  public float getY() {
    return y+h;
  }
  
  public void dibujar(PGraphics p) {
    drawSombra(p, x+w/2, y+(h-2), w+3);
    squishX = lerp(squishX, 1, 0.2);
    squishY = lerp(squishY, 1, 0.2);
    flash = lerp(flash, 0, 0.2);

    p.pushMatrix();
      p.translate(x+(w/2), y+h);
      p.scale(squishX,squishY);
      sprite.dibujar(p,-(w/2), -h,w,h);
    p.pushStyle();
      p.blendMode(ADD); //Efecto flash
      p.tint(255, 255*flash);
      sprite.dibujar(p,-(w/2), -h,w,h);
    p.popStyle();
    p.popMatrix();
  }
}


//Caja con moneda

class CajaConMoneda extends CajaRompible implements Dibujable {
  CajaConMoneda(float x, float y, float w, float h, int vida) {
    super(x, y, w, h, vida);
  }

  void alDestruirse() { //Si se destruye, generar monedas
    int cant = 0;
    
    boolean tieneVida = round(random(0,1)) == 1 ? true : false;

    while (cant < 5) {
      Moneda m = new Moneda(x+w/2, y+h/2);
      m.lanzar(random(2, 10));
      items.add(m);
      cant++;
    }
    
    if (tieneVida){
      Vida a = new Vida(x+w/2, y+h/2);
      a.lanzar(random(2, 10));
      items.add(a);
    }
  }
}
