
Mover[] movers = new Mover[51];
Settings set;
int counter = 0;

void setup() {

  // size(383, 200);
  size(400, 400);

  movers[0] = new Mover(5, width/2, height/2);
  for (int i = 1; i < movers.length; i++) {
    movers[i] = new Mover(random(1, 10), random(width), 0);
  }

  set = new Settings();
}

void draw() {
  background(255);

  PVector gravity = new PVector(0, 0.1);
  
  
  set.updateAndDisplay();



  for (Mover m : movers) {

    //if(m==movers[0])

    // PVector wind = new PVector(0.01, 0);
    set.addParam("gravity", m);
    //PVector friction = m.calculateFriction(0.05);
    m.applyForce(gravity);

    moveWithMouse1();
    
    m.update();
    m.display();
    m.checkEdges();
  }
}

void moveWithMouse1()
{
  for ( Mover m : movers) {
    float d = dist(mouseX, mouseY, m.position.x, m.position.y);
    float r = m.mass*8;
    if ( d <= r)
    {
      float x_ = constrain((mouseX - pmouseX), 0, 1);
      float y_ = constrain((mouseY - pmouseY), 0, 1);

      m.applyForce(new PVector(x_, y_));
    }
  }
}

void mousePressed()
{
  // mouse in cerchio settings on/off
  if ( mouseX < set.x_c + set.r_c &&
    mouseX > set.x_c - set.r_c &&
    mouseY < set.y_c + set.r_c &&
    mouseY > set.y_c - set.r_c
    )
  {
    counter++;
    set.setVisibilityMenu( counter%2==0 );
  }
}


// per costruire una gui dovrei fare delle classi a posite
// così da automattizare lo spostamento dell astessa etc.

//boolean menu;

//color statusCerchio;
//color attivo,disattivo;

// in setup
//  attivo = color(255);
//  disattivo = color(0);

// in draw
//  if(menu)
//  {
//    fill(50,50,50);
//    rect(0,0,100,height);

//    controlloCerchio();
//    fill(statusCerchio);
//    circle(50,10,20);
//  }

//void mousePressed()
//{
//   if(mouseX <20 && mouseX > 0 && mouseY >0 && mouseY < 20)
//     menu = (menu)? false : true;

//   if(mouseX <20 && mouseX > 0 && mouseY >0 && mouseY < 20)

//}
