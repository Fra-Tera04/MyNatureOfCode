import java.awt.event.KeyEvent;

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

/**
 * Casella di testo interattiva che incapsula la stringa digitata, la posizione del cursore
 * e il calcolo metrico per spostare il cursore con il mouse o con le frecce.
 */
class TextInputField extends UIElement {
  static final float RAGGIO_DEFAULT = 12.0f;
  static final float OPACITA_DEFAULT = 255.0f;
  static final float PADDING_TESTO = 20.0f;
  static final float MARGINE_CURSORE_Y = 16.0f;
  static final int MAX_CARATTERI = 60;

  final String placeholder;
  private String testo = "";
  private int indiceCursore = 0;

  TextInputField(float x, float y, float w, float h, String placeholder) {
    super(x, y, w, h, RAGGIO_DEFAULT, OPACITA_DEFAULT);
    this.placeholder = placeholder;
  }

  String getTesto() {
    return testo;
  }

  void posizionaCursoreAllaFine() {
    indiceCursore = testo.length();
  }

  /**
   * Renderizza la casella di testo, il placeholder (se vuota) e il cursore attivo.
   */
  void display(boolean valido) {
    noStroke();
    rectMode(CORNER);
    fill(COLORE_BOX_INPUT);
    stroke(valido ? COLORE_VALIDO : COLORE_ERRORE);
    strokeWeight(3);
    rect(x, y, w, h, raggioAngoli);

    noStroke();
    textAlign(LEFT, CENTER);
    textSize(FONT_INPUT_EDITOR);
    float testoX = x + PADDING_TESTO;
    float testoY = y + h / 2.0f;

    indiceCursore = constrain(indiceCursore, 0, testo.length());

    if (testo.isEmpty()) {
      fill(COLORE_SOTTOTITOLO);
      text(placeholder, testoX, testoY);
      disegnaCursore(testoX, COLORE_TESTO);
    } else {
      fill(COLORE_TESTO);
      text(testo, testoX, testoY);
      String primaDelCursore = testo.substring(0, indiceCursore);
      float cursoreX = testoX + textWidth(primaDelCursore);
      disegnaCursore(cursoreX, COLORE_VALIDO);
    }
  }

  private void disegnaCursore(float cursoreX, color coloreCursore) {
    stroke(coloreCursore);
    strokeWeight(2);
    line(cursoreX, y + MARGINE_CURSORE_Y, cursoreX, y + h - MARGINE_CURSORE_Y);
  }

  /**
   * Posiziona il cursore nel punto esatto cliccato dall'utente calcolando i punti medi dei caratteri.
   */
  void aggiornaCursoreDaMouse(float mx) {
    textSize(FONT_INPUT_EDITOR);
    float clickRelativoX = mx - (x + PADDING_TESTO);
    int migliorIndice = testo.length();

    for (int i = 0; i < testo.length(); i++) {
      float wCorrente = textWidth(testo.substring(0, i));
      float wProssimo = textWidth(testo.substring(0, i + 1));
      float puntoMedio = (wCorrente + wProssimo) / 2.0f;
      if (clickRelativoX < puntoMedio) {
        migliorIndice = i;
        break;
      }
    }
    indiceCursore = migliorIndice;
  }

  /**
   * Gestisce la digitazione e la navigazione del cursore.
   *
   * @return true se il contenuto testuale è cambiato (richiedendo una nuova validazione).
   */
  boolean gestisciTasto(char k, int kCode) {
    indiceCursore = constrain(indiceCursore, 0, testo.length());

    if (k == CODED) {
      if (kCode == LEFT && indiceCursore > 0) {
        indiceCursore--;
      } else if (kCode == RIGHT && indiceCursore < testo.length()) {
        indiceCursore++;
      } else if (kCode == KeyEvent.VK_HOME) {
        indiceCursore = 0;
      } else if (kCode == KeyEvent.VK_END) {
        indiceCursore = testo.length();
      }
      return false;
    }

    if (k == BACKSPACE) {
      if (indiceCursore > 0) {
        testo = testo.substring(0, indiceCursore - 1) + testo.substring(indiceCursore);
        indiceCursore--;
        return true;
      }
      return false;
    }

    if (k == DELETE) {
      if (indiceCursore < testo.length()) {
        testo = testo.substring(0, indiceCursore) + testo.substring(indiceCursore + 1);
        return true;
      }
      return false;
    }

    if (k == '-' || (k >= 32 && k <= 126)) {
      if (testo.length() < MAX_CARATTERI) {
        testo = testo.substring(0, indiceCursore) + k + testo.substring(indiceCursore);
        indiceCursore++;
        return true;
      }
    }
    return false;
  }
}