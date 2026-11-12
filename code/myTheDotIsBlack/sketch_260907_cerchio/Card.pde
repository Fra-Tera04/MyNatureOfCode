class Card {
  static final float RAGGIO_ANGOLI = 16;
  static final float OPACITA_BORDO = 80;
  static final float SPESSORE_BORDO = 1;

  float x, y, w, h;
  String label;
  color baseColor;
  int targetState;

  Card(float x, float y, float w, float h, String label, color baseColor, int targetState) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.baseColor = baseColor;
    this.targetState = targetState;
  }

  void display() {
    noStroke();
    rectMode(CORNER);
    fill(baseColor);
    rect(x, y, w, h, RAGGIO_ANGOLI);

    noFill();
    stroke(COLORE_TESTO, OPACITA_BORDO);
    strokeWeight(SPESSORE_BORDO);
    rect(x, y, w, h, RAGGIO_ANGOLI);

    noStroke();
    fill(COLORE_TESTO);
    textAlign(CENTER, CENTER);
    textSize(FONT_CARD);
    text(label, x + w / 2.0, y + h / 2.0);
  }

  boolean isClicked(float mx, float my) {
    return (mx > x && mx < x + w && my > y && my < y + h);
  }
}