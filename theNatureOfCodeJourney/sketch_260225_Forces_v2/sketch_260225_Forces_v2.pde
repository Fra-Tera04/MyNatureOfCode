
Mover[] movers = new Mover[5];

void setup() {
  size(383, 200);
  randomSeed(1);
  for (int i = 0; i < movers.length; i++) {
    movers[i] = new Mover(random(1, 4), random(width), 0);
  }
}

void draw() {
  background(255);

  for (Mover m : movers) {

    // PVector wind = new PVector(0.01, 0);
    PVector gravity = new PVector(0, 0.1*m.mass);

    float c = 0.05;
    PVector friction = m.velocity.copy();
    friction.mult(-1);
    friction.normalize();
    friction.mult(c);

    m.applyForce(friction);
    // movers[i].applyForce(wind);
    m.applyForce(gravity);
    
    moveWithMouse1();
    
    m.update();
    m.display();
    m.checkEdges();
  }
}

void moveWithMouse1()
{
  for ( Mover m : movers){
    float d = dist(mouseX, mouseY, m.position.x,m.position.y);
    float r = m.mass*8;
    if ( d <= r)
      {
        float x_ = constrain((int)(mouseX - pmouseX),0,2);
        float y_ = constrain((int)(mouseY - pmouseY),0,2);
              
        m.applyForce(new PVector(x_,y_));
      }
    }
}
