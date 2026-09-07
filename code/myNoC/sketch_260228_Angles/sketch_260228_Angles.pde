

Mover[] movers = new Mover[200];

Mover san;

void setup() {
  size(640, 360);
  background(255);
  for (int i = 0; i < movers.length; i++) {
    movers[i] = new Mover(random(0.1, 2), random(width), random(height));
  }
  san = new Mover(100, width/2, height/2);
  
}

void draw() {
  background(255);

  san.display();

  for ( Mover m : movers)
  {
    PVector f = san.attract(m);
    m.applyForce(f);

    m.update();
    m.display();
  }

  //for ( Mover m : movers) {
  //  for ( Mover m1 : movers)
  //  {
  //    if(m.equals(m1))
  //      continue;

  //    PVector force = m1.attract(m);
  //    m.applyForce(force);
  //  }
  //    m.update();
  //    m.display();
  //}
}
