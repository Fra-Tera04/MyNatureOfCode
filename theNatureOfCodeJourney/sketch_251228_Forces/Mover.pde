
class Mover
{
  PVector location;
  PVector velocity;
  PVector acceleration;

  int sizich;
  float mass;
  color c;

  Mover()
  {
    location = new PVector(width/2, height/2);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    mass = random(1, 3);
    sizich = floor(mass * 9);
    c = color(random(0, 255), random(0, 255), random(0, 255));
    c *= mass/255;
  }
  Mover(float speedX, float speedY)
  {
    location = new PVector(width/2, height/2);
    velocity = new PVector(speedX, speedY);
    acceleration = new PVector(0, 0);
    mass = random(1, 4);
    sizich = floor(mass * 8);
  }


  void applayForce(PVector force)
  {
    acceleration.add(PVector.div(force, mass));
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
    //accellearateToTheMouse();
    applayVelocity();
    applayRestriction();
  }

  void pastello()
  {
    noStroke();
  }
  void strokee(color stroke, int weight)
  {
    stroke(stroke);
    strokeWeight(weight);
  }
  void display()
  {

    //fill(127);
    fill(c);
    ellipse(location.x, location.y, sizich, sizich);
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
    if ( location.x > width + mass)
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

  void friction(Mover l) {
    if (mousePressed)
    {
      PVector friction = l.velocity.copy();
      friction.normalize();
      friction.mult(-1);
      // mu = coefficente di frizione:
      friction.mult(.01);
      PVector vento = new PVector(.01, 0);
      l.applayForce(vento);

      //PVector veroIlMouse = new PVector(mouseX-l.location.x, mouseY-l.location.y);
      //veroIlMouse.setMag(.1);
      //l.applayForce(veroIlMouse);
    }
  }
  void dragForce(float cc)
  {
    if(mousePressed)
    {
      PVector drag = this.velocity.copy();
      drag.normalize();
      float c = -0.1+cc;
      float speed = this.velocity.mag();
      drag.mult(c*speed*speed);
      
      this.applayForce(drag);
    }
  }
}
