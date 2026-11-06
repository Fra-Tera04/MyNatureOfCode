
Schermata schermata;
Menu menuu;

Uno uno;
Sei sei;
Venti venti;
//
float primo = 16, secondo = 2.666, terzo = 1.454545;

void setup()
{
  size(800, 800);
  menuu = new Menu();
  uno = new Uno();
  sei = new Sei();
  venti = new Venti();
  schermata = menuu;
  //noLoop();
}

void draw()
{
  background(0);
  schermata.disegna();
}

void mousePressed()
{
  schermata.mousePremuto();
}

void keyPressed() {
  schermata.tastoPremuto();
}

interface Schermata
{
  void disegna();
  default void mousePremuto() {
  }
  default void tastoPremuto() {
  }
}

class Uno implements Schermata
{
  void disegna()
  {
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
    textAlign(LEFT, BASELINE);
    text("clicca F per tornare indietro", 10, height-20);
  }
  void tastoPremuto() {
    if (key == 'f') {
      schermata = menuu;
    }
  }
}

class Sei implements Schermata
{
  void disegna()
  {
    int colonne = 7;
    int righe = 7;

    float cellW = width / (float) colonne;
    float cellH = height / (float) righe;

    for (int col = 1; col < colonne; col++) {
      for (int row = 1; row < righe; row++) {
        noStroke();
        rectMode(CENTER);
        fill(random(255), random(255), random(255));

        float l = col * cellW;
        float m = row * cellH;
        rect(l, m, cellW, cellH);

        pushMatrix();
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
    textAlign(LEFT, BASELINE);
    text("clicca F per tornare indietro", 10, height-20);
  }

  void tastoPremuto() {
    if (key == 'f') schermata = menuu;
  }
}

class Venti implements Schermata
{
  void disegna()
  {

    int colonne = 23;
    int righe = 23;

    float cellW = width / (float) colonne;
    float cellH = height / (float) righe;

    for (int col = 2; col < colonne-1; col++) {
      for (int row = 1; row < righe-2; row++) {
        noStroke();
        rectMode(CENTER);
        fill(random(255), random(255), random(255));

        float l = col * cellW;
        float m = row * cellH;
        rect(l, m, cellW, cellH);

        pushMatrix();
        translate(l, m);
        scale(.05);
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
    textAlign(LEFT, BASELINE);
    text("clicca F per tornare indietro", 10, height-20);
  }
  void tastoPremuto()
  {
    if (key == 'f') schermata = menuu;
  }
}

class Menu implements Schermata
{
  void disegna()
  {
    fill(255);
    textSize(32);
    drawCard(width/primo, 100, 200, 200, color(100, 200, 150), "Uno");
    drawCard(width/secondo, 100, 200, 200, color(280, 220, 220), "Sei");
    drawCard(width/terzo, 100, 200, 200, color(255, 100, 150), "Venti");
  }
  void drawCard(float x, float y, float w, float h, color c, String label) {
    noStroke();
    rectMode(CORNER);

    fill(c);
    rect(x, y, w, h, 16);

    // Testo centrato nella card
    noStroke();
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(28);
    text(label, x + w/2, y + h/2);
  }

  public void mousePremuto() {
    if (mouseX > width/primo && mouseX < width/primo +200 && mouseY > 100 && mouseY < 300) {
      schermata = uno;
    }
    if (mouseX > width/secondo && mouseX < width/secondo +200 && mouseY > 100 && mouseY < 300) {
      schermata = sei;
    }
    if (mouseX > width/terzo && mouseX < width/terzo +200 && mouseY > 100 && mouseY < 300) {
      schermata = venti;
    }
  }
}
