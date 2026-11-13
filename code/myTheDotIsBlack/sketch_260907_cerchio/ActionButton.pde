/**
 * Pulsante generico con colore ed etichetta personalizzati (usato per "Custom" e "Conferma").
 */
class ActionButton extends UIElement {
  static final float RAGGIO_DEFAULT = 12.0f;
  static final float OPACITA_DEFAULT = 100.0f;

  final String etichetta;
  final color coloreBase;

  ActionButton(float x, float y, float w, float h, String etichetta, color coloreBase) {
    super(x, y, w, h, RAGGIO_DEFAULT, OPACITA_DEFAULT);
    this.etichetta = etichetta;
    this.coloreBase = coloreBase;
  }

  void display() {
    disegnaBox(coloreBase);
    disegnaTestoCentrato(etichetta, FONT_TOGGLE);
  }
}