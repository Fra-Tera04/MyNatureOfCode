class Card {
  static final float RAGGIO_ANGOLI = 16;
  static final float OPACITA_BORDO = 80;
  static final float SPESSORE_BORDO = 1;

  final float x, y, w, h;
  final Modalita modalita;

  Card(float x, float y, float w, float h, Modalita modalita) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.modalita = modalita;
  }

  void display() {
    noStroke();
    rectMode(CORNER);
    fill(modalita.getColore());
    rect(x, y, w, h, RAGGIO_ANGOLI);

    noFill();
    stroke(COLORE_TESTO, OPACITA_BORDO);
    strokeWeight(SPESSORE_BORDO);
    rect(x, y, w, h, RAGGIO_ANGOLI);

    noStroke();
    fill(COLORE_TESTO);
    textAlign(CENTER, CENTER);
    textSize(FONT_CARD);
    text(modalita.etichetta, x + w / 2.0, y + h / 2.0);
  }

  boolean isClicked(float mx, float my) {
    return (mx > x && mx < x + w && my > y && my < y + h);
  }
}

class ToggleButton {
  static final float RAGGIO_ANGOLI = 12;
  static final float OPACITA_BORDO = 100;
  static final float SPESSORE_BORDO = 1;

  final float x, y, w, h;
  final String etichetta;

  ToggleButton(float x, float y, float w, float h, String etichetta) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.etichetta = etichetta;
  }

  void display(boolean attivo) {
    noStroke();
    rectMode(CORNER);
    fill(attivo ? COLORE_TOGGLE_ON : COLORE_TOGGLE_OFF);
    rect(x, y, w, h, RAGGIO_ANGOLI);

    noFill();
    stroke(COLORE_TESTO, OPACITA_BORDO);
    strokeWeight(SPESSORE_BORDO);
    rect(x, y, w, h, RAGGIO_ANGOLI);

    noStroke();
    fill(COLORE_TESTO);
    textAlign(CENTER, CENTER);
    textSize(FONT_TOGGLE);
    String statoTesto = attivo ? "SÌ" : "NO";
    text(etichetta + ": " + statoTesto, x + w / 2.0, y + h / 2.0);
  }

  boolean isClicked(float mx, float my) {
    return (mx > x && mx < x + w && my > y && my < y + h);
  }
}