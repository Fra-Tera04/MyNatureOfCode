Mover f;

Mover[] list = new Mover[100];

float xoff;

void setup() {
  size(640, 360);
  f = new Mover(0, 0);
  for (int i=0; i<list.length; i++)
  {
    list[i] = new Mover();
  }
  xoff = 0;
}

void draw() {
  xoff+=.01;

  for (Mover l : list)
  {
    PVector g = new PVector(
      random(-.1,.1),
      random(-.1,.1)
      );
    
    l.applayForce(g);
    l.freeEdges();
    l.update();

    l.display(noise(xoff));
  }
}

void draw1()
{
  background(0);
  PVector v = new PVector(0, 0);
  PVector g = new PVector(random(-.5,.5),random(-.5,.5));

  f.applayForce(v);
  f.applayForce(g);
  f.bouncingEdges();
  f.update();

  f.display();
}
