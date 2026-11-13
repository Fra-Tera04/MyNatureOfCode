/**
 * Classe base astratta per tutti i componenti interattivi rettangolari dell'interfaccia utente.
 * Centralizza il rilevamento delle collisioni (AABB) e il rendering della forma di base.
 */
abstract class UIElement {
  static final float SPESSORE_BORDO = 1.0f;

  final float x, y, w, h;
  final float raggioAngoli;
  final float opacitaBordo;

  /**
   * Costruttore protetto per gli elementi UI.
   *
   * @param x            Coordinata X dell'angolo superiore sinistro.
   * @param y            Coordinata Y dell'angolo superiore sinistro.
   * @param w            Larghezza del componente in pixel.
   * @param h            Altezza del componente in pixel.
   * @param raggioAngoli Raggio di curvatura degli angoli arrotondati.
   * @param opacitaBordo Valore alpha (0-255) per il bordo di contorno.
   */
  UIElement(float x, float y, float w, float h, float raggioAngoli, float opacitaBordo) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.raggioAngoli = raggioAngoli;
    this.opacitaBordo = opacitaBordo;
  }

  /**
   * Disegna il rettangolo arrotondato di sfondo e il relativo bordo semitrasparente.
   *
   * @param coloreRiempimento Colore di riempimento del pulsante.
   */
  protected void disegnaBox(color coloreRiempimento) {
    noStroke();
    rectMode(CORNER);
    fill(coloreRiempimento);
    rect(x, y, w, h, raggioAngoli);

    noFill();
    stroke(COLORE_TESTO, opacitaBordo);
    strokeWeight(SPESSORE_BORDO);
    rect(x, y, w, h, raggioAngoli);
  }

  /**
   * Disegna un'etichetta testuale perfettamente centrata nel componente.
   *
   * @param testo          Stringa da visualizzare.
   * @param dimensioneFont Dimensione del testo in punti.
   */
  protected void disegnaTestoCentrato(String testo, int dimensioneFont) {
    noStroke();
    fill(COLORE_TESTO);
    textAlign(CENTER, CENTER);
    textSize(dimensioneFont);
    text(testo, x + w / 2.0f, y + h / 2.0f);
  }

  /**
   * Verifica se un punto (es. cursore del mouse) ricade all'interno del perimetro del componente.
   *
   * @param mx Coordinata X del puntatore.
   * @param my Coordinata Y del puntatore.
   * @return true se il punto è interno al rettangolo, false altrimenti.
   */
  boolean isClicked(float mx, float my) {
    return (mx > x && mx < x + w && my > y && my < y + h);
  }
}