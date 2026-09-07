
public class Settings
{
  ArrayList<PVector> forces;
  ArrayList<Parameter> params;
  float x, y, w, h;
  float x_c, y_c, r_c;
  boolean displayMenu;

  Settings()
  {
    params = new ArrayList<Parameter>();
    forces = new ArrayList<PVector>();
    x = 10;
    y = 10;
    w = 200;
    h = 300;

    x_c = 20;
    y_c = 20;
    r_c = 25;
  }
  void addParam(String name, Mover m)
  {
    params.add(new Parameter(name, 0.0, 0, 1, x + 25, y + 40));
  }
  boolean setForce(String nome, boolean active)
  {
    // cerca
    
    // set activation
    
    return false;
  }

  float getValore(String nome)
  {
    for (Parameter p : params)
      if (p.nome.equals(nome)) return p.valore;

    return -69;
  }

  void updateAndDisplay()
  {
    if (displayMenu)
      fill(255);
    else
      fill(0);

    stroke(2);
    circle(x_c, y_c, r_c);

    if (!displayMenu)
      return;

    fill(50, 200); // Pannello semi-trasparente
    rect(x, y, w, h, 10);

    for (Parameter p : params)
    {
      p.update(mouseX, mouseY);
      print(p);
      p.display();
    }
  }

  void setVisibilityMenu(boolean visibility)
  {
    displayMenu = visibility;
  }
}

public class Parameter
{
  String nome;
  Mover m;
  float valore, min, max;
  float x, y, w, h;

  Parameter(String nome, float valore, float min, float max, float x, float y)
  {
    this.nome = nome;
    this.m = m;
    this.valore = valore;
    this.min = min;
    this.max = max;
    this.x = x;
    this.y = y;
    this.w = 150;
    this.h = 20;
  }

  void display()
  {
    fill(200);
    rect(x, y, w, h); // Background slider
    fill(100, 150, 255);

    float sliderPos = map(valore, min, max, 0, w);

    rect(x, y, sliderPos, h); // Riempimento
    fill(0);
    text(nome + ": " + nf(valore, 1, 2), x + 5, y + 15);
  }

  boolean update(int mx, int my)
  {
    if (mousePressed && mx > x && mx < x + w && my > y && my < y + h)
    {
      valore = map(mx, x, x + w, min, max);
      valore = constrain(valore, min, max);
      
      
      
      return true; // Il valore è cambiato
    }
    return false;
  }
}


interface Command
{
  void execute();
}
