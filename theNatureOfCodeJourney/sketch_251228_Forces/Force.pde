
class Force
{
  PVector location;
  PVector velocity;
  PVector acceleration;

  int sizeSphire;

  Force()
  {
    location = new PVector(width/2, height/2);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    sizeSphire = 48;
  }
  Force(float speedX, float speedY)
  {
    location = new PVector(width/2, height/2);
    velocity = new PVector(speedX, speedY);
    acceleration = new PVector(0, 0);
    sizeSphire = 48;
  }

  void update()
  {
    velocity.add(acceleration);
    velocity.limit(5);

    location.add(velocity);
  }
  void display()
  {
    stroke(0);
    strokeWeight(2);
    fill(127);
    ellipse(location.x, location.y, sizeSphire, sizeSphire);
  }

  void edges()
  {
    if ( location.x > width ) location.x = 0;
    if ( location.x < 0 ) location.x = width;
    if ( location.y > height ) location.y = 0;
    if ( location.y < 0 ) location.y = height;
  }
}
