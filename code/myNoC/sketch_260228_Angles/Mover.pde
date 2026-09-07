
public class Mover
{
  PVector position;
  PVector velocity;
  PVector acceleration;
  float mass;
  float g = 1;

  float angle = 0;
  float aVelocity = 0;
  float aAcceleration = 0.001;

  Mover()
  {
    this(4, width/2, height/2);
  }
  Mover(float m, float x, float y)
  {
    mass = m;
    position = new PVector(x, y);
    velocity = new PVector(random(0, 1), random(0, 1));
    acceleration = new PVector(0, 0);
  }

  void applyForce(PVector force)
  {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  void update()
  {
    velocity.add(acceleration);
    position.add(velocity);

    aAcceleration = acceleration.x/10.0;
    aVelocity += aAcceleration;
    aVelocity = constrain(aVelocity, -0.1, 0.1);
    angle += aVelocity;

    acceleration.mult(0);
  }

  void display()
  {
    stroke(0);
    fill(175, 200);
    rectMode(CENTER);
    
    pushMatrix();
      translate(position.x, position.y);
      rotate(angle);
      rect(0, 0, mass*16, mass*16);
    popMatrix();
  }

  PVector attract(Mover m)
  {
    PVector force = PVector.sub(position, m.position);
    float distance = force.mag();
    
    distance = constrain(distance, 5.0, 25.0);
    force.normalize();
    float strength = (g * mass * m.mass) / (distance * distance);
    force.mult(strength);
    
    return force;
  }
}
