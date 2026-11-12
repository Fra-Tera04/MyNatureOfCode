class Quadro {
  // Parametri geometrici intrinseci del Quadro
  static final float RAGGIO_MIN = 50;
  static final float RAGGIO_MEDIO = 150;
  static final float RAGGIO_MAX = 350;
  static final float DIAMETRO_BASE = RAGGIO_MAX * 2.0;

  static final int LIVELLI_CONCENTRICI = 10;
  static final int ANGOLO_GIRO = 360;
  static final float MAX_COLORE = 255;

  float x, y, lato, scala;
  boolean haSfondo;
  color bgCol;

  Quadro(float x, float y, float lato, float scala, boolean haSfondo) {
    this.x = x;
    this.y = y;
    this.lato = lato;
    this.scala = scala;
    this.haSfondo = haSfondo;
    this.bgCol = generaColoreCasuale();
  }

  color generaColoreCasuale() {
    return color(random(MAX_COLORE), random(MAX_COLORE), random(MAX_COLORE));
  }

  void display() {
    pushMatrix();
    translate(x, y);

    if (haSfondo) {
      noStroke();
      rectMode(CENTER);
      fill(bgCol);
      rect(0, 0, lato, lato);
    }

    scale(scala);
    strokeCap(CORNER);

    for (int n = 1; n < LIVELLI_CONCENTRICI; n++) {
      stroke(generaColoreCasuale());
      strokeWeight(LIVELLI_CONCENTRICI - n);
      for (int i = 0; i < ANGOLO_GIRO; i++) {
        float r1 = random(RAGGIO_MIN, RAGGIO_MEDIO);
        float r2 = random(RAGGIO_MEDIO, RAGGIO_MAX);
        pushMatrix();
        rotate(radians(i));
        line(r1, 0, r2, 0);
        popMatrix();
      }
    }
    popMatrix();
  }
}