
class Liquid
{
  // il liquido è dentro un rettagolo:
  float x, y, h, w;
  float costa;

  Liquid()
  {
    x = 0;
    w = width;
    y = height/2;
    h = height/2;
    costa = 1;
  }
  Liquid(float x_, float y_, float w_, float h_)
  {
    x = x_;
    w = w_;
    y = y_;
    h = h_;
    costa = 1;
  }

  PVector drag(Mover m)
  {
    PVector dragForce = m.velocity.copy();

    float speed = m.velocity.mag();
    float dragMagnitude = costa * speed * speed;

    dragForce.mult(-1);
    dragForce.normalize();
    dragForce.mult(dragMagnitude);

    return dragForce;
  }
  boolean containsR(Mover m)
  {
    // se fuori falso
    if (m.location.x < x     ) return false;
    if (m.location.x > x + w ) return false;
    if (m.location.x < y     ) return false;
    if (m.location.x > y + h ) return false;

    return true;
  }
}
