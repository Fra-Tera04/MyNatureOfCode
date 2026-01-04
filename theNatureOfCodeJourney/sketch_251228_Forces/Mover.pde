
class Mover
{
  PVector location;
  PVector velocity;
  PVector acceleration;
  
  int sizeSphire;
  float mass;
  color c;
  
  Mover()
  {
    location = new PVector(width/2, height/2);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    sizeSphire = floor(mass * 8);
    mass = random(1,3);
    c = color(random(0,255),random(0,255),random(0,255));
    c *= mass/255; 
  }
  Mover(float speedX, float speedY)
  {
    location = new PVector(width/2, height/2);
    velocity = new PVector(speedX, speedY);
    acceleration = new PVector(0, 0);
    sizeSphire = 8;
    mass = random(1,4);
  }


  void applayForce(PVector force)
  {
    acceleration.add(PVector.div(force,mass));
  }

  private void applayAccelleretion()
  {
    baseAccelleration();
  }
  private void baseAccelleration()
  {
    velocity.add(acceleration);
    acceleration.mult(0);
  }
  private void accellearateToTheMouse()
  {
    PVector mouse = new PVector(mouseX, mouseY);
    mouse.sub(location);
    mouse.setMag(.1);

    acceleration = mouse;
    velocity.add(acceleration);
  }


  private void applayVelocity()
  {
    location.add(velocity);
  }

  private void applayRestriction()
  {
    velocity.limit(15);
  }


  void update()
  {
    applayAccelleretion();
    applayVelocity();
    applayRestriction();
  }

  void display()
  {
    stroke(0);
    strokeWeight(2);
    fill(127);
    ellipse(location.x, location.y, mass, mass);
  }
  void display(float x)
  {
    stroke(0);
    strokeWeight(2);
    fill(random(0,255),random(0,255),random(0,255));
    ellipse(location.x, location.y, mass*8, mass*8);
  }

  void freeEdges()
  {
    if ( location.x > width ) location.x = 0;
    if ( location.x < 0 ) location.x = width;
    if ( location.y > height ) location.y = 0;
    if ( location.y < 0 ) location.y = height;
  }
  void bouncingEdges()
  {
    if ( location.x > width )
    {
      location.x = width;
      velocity.x *= -1;
    }
    if ( location.x < 0 )
    {
      location.x = 0;
      velocity.x *= -1;
    }
    if ( location.y > height )
    {
      location.y = height;
      velocity.y *= -1;
    }
    if ( location.y < 0 )
    {
      location.y = 0;
      velocity.y *= -1;
    }
  }
}
