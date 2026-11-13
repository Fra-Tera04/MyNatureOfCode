/**
 * Rappresenta una Card di selezione nel menu principale associata a una specifica Modalita.
 */
class Card extends UIElement {
  static final float RAGGIO_DEFAULT = 16.0f;
  static final float OPACITA_DEFAULT = 80.0f;

  final Modalita modalita;

  /**
   * Costruisce una nuova Card associata a una modalità di gioco/visualizzazione.
   *
   * @param x        Coordinata X superiore sinistra.
   * @param y        Coordinata Y superiore sinistra.
   * @param w        Larghezza della Card.
   * @param h        Altezza della Card.
   * @param modalita Riferimento all'enum Modalita corrispondente.
   */
  Card(float x, float y, float w, float h, Modalita modalita) {
    super(x, y, w, h, RAGGIO_DEFAULT, OPACITA_DEFAULT);
    this.modalita = modalita;
  }

  /**
   * Esegue il rendering della Card utilizzando il colore e l'etichetta della modalità.
   */
  void display() {
    disegnaBox(modalita.getColore());
    disegnaTestoCentrato(modalita.etichetta, FONT_CARD);
  }
}

/**
 * Rappresenta un pulsante di commutazione booleana (SÌ/NO) per le impostazioni del menu.
 */
class ToggleButton extends UIElement {
  static final float RAGGIO_DEFAULT = 12.0f;
  static final float OPACITA_DEFAULT = 100.0f;

  final String etichetta;

  /**
   * Costruisce un pulsante Toggle.
   *
   * @param x         Coordinata X superiore sinistra.
   * @param y         Coordinata Y superiore sinistra.
   * @param w         Larghezza del pulsante.
   * @param h         Altezza del pulsante.
   * @param etichetta Testo descrittivo dell'impostazione.
   */
  ToggleButton(float x, float y, float w, float h, String etichetta) {
    super(x, y, w, h, RAGGIO_DEFAULT, OPACITA_DEFAULT);
    this.etichetta = etichetta;
  }

  /**
   * Esegue il rendering del pulsante riflettendo visivamente lo stato booleano corrente.
   *
   * @param attivo Stato corrente dell'opzione (true = SÌ, false = NO).
   */
  void display(boolean attivo) {
    disegnaBox(attivo ? COLORE_TOGGLE_ON : COLORE_TOGGLE_OFF);
    String statoTesto = attivo ? "SÌ" : "NO";
    disegnaTestoCentrato(etichetta + ": " + statoTesto, FONT_TOGGLE);
  }
}