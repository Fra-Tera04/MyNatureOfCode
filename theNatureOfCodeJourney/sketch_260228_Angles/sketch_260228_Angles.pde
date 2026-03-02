

Mover[] movers = new Mover[20];

Mover a;

void setup() {
  size(640,360);
  background(255);
  for (int i = 0; i < movers.length; i++) {
    movers[i] = new Mover(random(0.1,2),random(width),random(height)); 
  }
  a = new Mover();
}

void draw() {
  background(255);

  a.display();

  for ( Mover m : movers) {
    PVector force = a.attract(m);
    m.applyForce(force);

    m.update();
    m.display();
  }

}
