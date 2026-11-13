/**
 * Rappresenta un singolo quadro generativo composto da livelli concentrici di segmenti radiali
 * e da un quadrato di sfondo opzionale.
 */
class Quadro {
  static final float RAGGIO_MIN = 50.0f;
  static final float RAGGIO_MEDIO = 150.0f;
  static final float RAGGIO_MAX = 350.0f;
  static final float DIAMETRO_BASE = RAGGIO_MAX * 2.0f;

  static final int LIVELLI_CONCENTRICI = 10;
  static final int ANGOLO_GIRO = 360;
  static final float MAX_COLORE = 255.0f;

  final float x, y, lato, scala;
  final boolean haSfondo;
  final color bgCol;

  /**
   * Costruisce un nuovo Quadro calcolando automaticamente il fattore di scala omotetico
   * rispetto a DIAMETRO_BASE.
   *
   * @param x        Coordinata X del centro del quadro.
   * @param y        Coordinata Y del centro del quadro.
   * @param lato     Dimensione in pixel del lato della cella ospitante.
   * @param haSfondo Flag per abilitare il rendering del quadrato colorato di sfondo.
   */
  Quadro(float x, float y, float lato, boolean haSfondo) {
    this.x = x;
    this.y = y;
    this.lato = lato;
    this.scala = lato / DIAMETRO_BASE;
    this.haSfondo = haSfondo;
    this.bgCol = generaColoreCasuale();
  }

  /**
   * Genera una tripla RGB pseudo-casuale uniforme nello spazio colore [0, MAX_COLORE].
   *
   * @return Colore generato.
   */
  color generaColoreCasuale() {
    return color(random(MAX_COLORE), random(MAX_COLORE), random(MAX_COLORE));
  }

  /**
   * Restituisce il diametro reale in pixel occupato dal quadro dopo la trasformazione di scala.
   *
   * @return Diametro effettivo sullo schermo.
   */
  float getDiametroEffettivo() {
    return DIAMETRO_BASE * scala;
  }

  /**
   * Renderizza lo sfondo (se attivo) e la struttura radiale multi-livello nello spazio locale.
   */
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