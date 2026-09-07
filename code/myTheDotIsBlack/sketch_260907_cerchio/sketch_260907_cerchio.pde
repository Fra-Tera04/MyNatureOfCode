PFont font;

boolean menu;
int stato = 0;

void setup() {
  size(800, 800);
  background(0);
  noLoop();

  font = createFont("Arial", 32);
  textFont(font);
}

void draw() {
  background(0);
  if (stato == 0) menu();
  else if (stato == 1) uno();
  else if (stato == 2) venti();
}


void menu() {
  // Sfondo con leggero gradiente verticale
  for (int y = 0; y < height; y++) {
    float t = map(y, 0, height, 0, 1);
    stroke(lerpColor(color(10, 10, 30), color(30, 10, 50), t));
    line(0, y, width, y);
  }

  // Titolo
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(48);
  text("MENU", width/2, 60);

  textSize(16);
  fill(180);
  text("Scegli il numero di quadri", width/2, 100);

  // Card dinamiche invece di rettangoli fissi
  drawCard(100, 100, 200, 200, "Uno", color(80, 120, 220));
  drawCard(300, 300, 200, 200, "Sei", color(220, 100, 150));
  drawCard(500, 500, 200, 200, "Venti", color(100, 200, 150));

  textAlign(LEFT, BASELINE); // reset per non rompere altre parti dello sketch
}

void drawCard(float x, float y, float w, float h, String label, color base) {

  // Ombra leggera
  noStroke();
  rectMode(CORNER);
  
  fill(base);

  rect(x, y, w, h, 16);

  // Bordo sottile
  noFill();
  stroke(255, 80);
  strokeWeight(1);
  rect(x, y, w, h, 16);

  // Testo centrato nella card
  noStroke();
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(28);
  text(label, x + w/2, y + h/2);
}

void menu2()
{
  background(0);
  rectMode(CORNER);

  fill(255);
  textSize(32);

  text("Uno", 100, 90);
  rect(100, 100, 200, 200);

  text("Sei", 310, 290);
  rect(300, 300, 200, 200);

  text("Venti", 510, 490);
  rect(500, 500, 200, 200);
}

void uno()
{
  background(0);
  for (int n=1; n < 10; n++) {
    stroke(random(255), random(255), random(255));
    for (int i=0; i < 360; i+=1) {
      float x = random(50, 150);
      float xx = random(150, 350);

      pushMatrix();
      translate(width/2, height/2);
      rotate(radians(i));
      strokeCap(CORNER);
      strokeWeight(10-n);

      line(x, 0, xx, 0);

      popMatrix();
    }
  }

  fill(255);
  text("clicca F per tonrare indietro", 10, height-10);
}

void venti()
{

  //wh/l=y

  for (int l=-50; l < width+100; l+=100) {
    for (int m=-50; m < height-100; m+=100) {
      pushMatrix();
      noStroke();
      rectMode(CENTER);
      fill(random(255), random(255), random(255));
      rect(l, m, 100, 100);


      translate(l, m);
      scale(.14);

      for (int n=1; n < 10; n++) {
        stroke(random(0, 255), random(0, 255), random(0, 255));
        for (int i=0; i < 360; i+=1) {
          float x = random(50, 150);
          float xx = random(150, 350);

          pushMatrix();
          rotate(radians(i));
          strokeCap(CORNER);
          strokeWeight(10-n);

          line(x, 0, xx, 0);

          popMatrix();
        }
      }
      popMatrix();
    }
  }

  fill(255);
  text("clicca F per tonrare indietro", 10, height-10);
}


void mousePressed() {
  if (stato == 0) {
    if (mouseX > 100 && mouseX < 300 && mouseY > 100 && mouseY < 300) stato = 1;
    if (mouseX > 500 && mouseX < 700 && mouseY > 500 && mouseY < 700) stato = 2;
    if (mouseX > 300 && mouseX < 500 && mouseY > 300 && mouseY < 500) stato = 3;

    redraw();
  }
}

void keyPressed()
{
  if (key=='f' || key=='F')
    stato = 0;
  redraw();
}
