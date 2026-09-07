
class Mover {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float mass;
  float mass_mult = 16;
  float r = mass * mass_mult / 2;
  float G = 1;



  Mover(float m, float x, float y) {
    mass = m;
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    acceleration.mult(0);
  }

  void display() {
    stroke(0);
    strokeWeight(2);
    fill(255, 100);
    ellipse(position.x, position.y, mass*mass_mult, mass*mass_mult);
  }

  PVector attract(Mover a)
  {
    PVector force = PVector.sub(position, a.position);

    float d = constrain(force.mag(), 2, 10);
    force.normalize();
    float forza = (G * mass * a.mass) / (d * d);
    force.mult(forza);

    return force;
  }


PVector calculateFriction(float c)
{
  c = 0.05;
  PVector friction = this.velocity.copy();
  friction.mult(-1);
  friction.normalize();
  friction.mult(c);

  return friction;
}


  void clicked(int x, int y)
  {
    float d = dist(x, y, position.x, position.y);
    if ( d < r )
    {
      // da continuare
    }
  }

  void checkEdges() {

    if (position.x > width) {
      position.x = width;
      velocity.x *= -1;
    } else if (position.x < 0) {
      position.x = 0;
      velocity.x *= -1;
    }

    if (position.y > height) {
      velocity.y *= -1;
      position.y = height;
    }
  }
}
