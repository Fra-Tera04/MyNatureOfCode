import java.util.concurrent.ThreadLocalRandom;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/* Sketch principale per la generazione procedurale di quadri radiali su griglia.
 * Gestisce la macchina a stati (Menu vs Vista Quadri), il layout responsivo e gli input utente.
 */

// Costanti di input e sintassi del Domain-Specific Language (DSL) dei pattern
final char TASTO_INDIETRO = 'f';
final char SIMBOLO_PIENO = 'X';
final char SIMBOLO_VUOTO = '.';
final char SEPARATORE_RIGHE = '/';
final int DIM_GRIGLIA_MIN = 1;
final int DIM_GRIGLIA_MAX = 25;

// Tipografia e layout
final String NOME_FONT = "SansSerif";
final int FONT_TITOLO = 44;
final int FONT_SOTTOTITOLO = 16;
final int FONT_CARD = 26;
final int FONT_TOGGLE = 18;
final int FONT_GUIDA = 14;

final float RAPPORTO_TITOLO_Y = 0.07f;
final float RAPPORTO_SOTTOTITOLO_Y = 0.12f;
final float FATTORE_MARGINE_SUPERIORE_MENU = 0.6f;
final float FATTORE_MARGINE_INFERIORE_MENU = 0.5f;
final float ALTEZZA_BARRA_INFO = 44.0f;
final float MARGINE_GRIGLIA_MENU = 90.0f;
final float SPAZIO_TRA_CARD = 24.0f;
final float LARGHEZZA_PULSANTE_MENU = 240.0f;
final float ALTEZZA_PULSANTE_MENU = 48.0f;
final float SPAZIO_PULSANTI_BASSO = 20.0f;
final float MARGINE_TOGGLE_BASSO = 45.0f;

// Palette
final color COLORE_SFONDO = color(0);
final color COLORE_BARRA_INFO = color(18, 18, 28);
final color COLORE_BOX_INPUT = color(28, 28, 48);
final color COLORE_TESTO = color(255);
final color COLORE_SOTTOTITOLO = color(180);
final color GRADIENTE_INIZIO = color(10, 10, 30);
final color GRADIENTE_FINE = color(30, 10, 50);
final color COLORE_TOGGLE_ON = color(70, 180, 120);
final color COLORE_TOGGLE_OFF = color(140, 70, 80);
final color COLORE_BOTTONE_CUSTOM = color(70, 130, 210);
final color COLORE_ERRORE = color(255, 95, 95);
final color COLORE_VALIDO = color(100, 230, 150);

final Set<String> COMANDI_VALIDI = new HashSet<String>(
  Arrays.asList("riempi", "bordo", "scacchiera", "diagonali", "croce", "centro", "angoli")
  );

PFont font;
PGraphics sfondoMenuBuffer;

// Stati dell'applicazione
Modalita modalitaCorrente = null;
String patternAttivo = null;
boolean editorAperto = false;
boolean sfondoAttivo = true;

// Stato dell'editor di pattern (vuoto all'avvio)
String inputUtente = "";
String messaggioValidazione = "";
boolean patternValido = false;

Card[] menuCards;
ToggleButton toggleSfondo;
ActionButton btnApriEditor;
ActionButton btnConfermaEditor;
ActionButton btnAnnullaEditor;
final float LARGHEZZA_BOTTONE_EDITOR = 200.0f;
final float ALTEZZA_BOTTONE_EDITOR = 48.0f;
final float SPAZIO_BOTTONI_EDITOR = 24.0f;
final float MARGINE_BOTTONI_EDITOR_BASSO = 110.0f;
final String PLACEHOLDER_EDITOR = "Scrivi qui il tuo pattern (es. 6x6; bordo; croce)...";

volatile ArrayList<Quadro> quadri = new ArrayList<Quadro>();

void setup() {
  size(800, 800);
  noLoop();

  font = createFont(NOME_FONT, FONT_TITOLO);
  textFont(font);

  creaBufferSfondoMenu();
  inizializzaMenu();
  inizializzaEditor();
  aggiornaValidazione();
}

void creaBufferSfondoMenu() {
  sfondoMenuBuffer = createGraphics(width, height);
  sfondoMenuBuffer.beginDraw();
  for (int y = 0; y < height; y++) {
    float t = map(y, 0, height, 0, 1);
    sfondoMenuBuffer.stroke(lerpColor(GRADIENTE_INIZIO, GRADIENTE_FINE, t));
    sfondoMenuBuffer.line(0, y, width, y);
  }
  sfondoMenuBuffer.endDraw();
}

void inizializzaMenu() {
  Modalita[] tutteLeModalita = Modalita.values();
  int numCard = tutteLeModalita.length;
  menuCards = new Card[numCard];

  int colonne = ceil(sqrt(numCard));
  int righe = ceil((float) numCard / colonne);

  float inizioY = height * RAPPORTO_SOTTOTITOLO_Y + MARGINE_GRIGLIA_MENU * FATTORE_MARGINE_SUPERIORE_MENU;
  float fineY = height - MARGINE_TOGGLE_BASSO - ALTEZZA_PULSANTE_MENU - MARGINE_GRIGLIA_MENU * FATTORE_MARGINE_INFERIORE_MENU;
  float areaDispW = width - MARGINE_GRIGLIA_MENU * 2.0f;
  float areaDispH = fineY - inizioY;

  float cellaW = (areaDispW - SPAZIO_TRA_CARD * (colonne - 1)) / colonne;
  float cellaH = (areaDispH - SPAZIO_TRA_CARD * (righe - 1)) / righe;
  float latoCard = min(cellaW, cellaH);

  float larghezzaTotale = colonne * latoCard + (colonne - 1) * SPAZIO_TRA_CARD;
  float altezzaTotale = righe * latoCard + (righe - 1) * SPAZIO_TRA_CARD;
  float startX = (width - larghezzaTotale) / 2.0f;
  float startY = inizioY + (areaDispH - altezzaTotale) / 2.0f;

  for (int i = 0; i < numCard; i++) {
    int col = i % colonne;
    int riga = i / colonne;
    float x = startX + col * (latoCard + SPAZIO_TRA_CARD);
    float y = startY + riga * (latoCard + SPAZIO_TRA_CARD);
    menuCards[i] = new Card(x, y, latoCard, latoCard, tutteLeModalita[i]);
  }

  // Due pulsanti affiancati in basso: Toggle Sfondo + Pattern Personalizzato
  float larghezzaTotPulsanti = LARGHEZZA_PULSANTE_MENU * 2.0f + SPAZIO_PULSANTI_BASSO;
  float startPulsantiX = (width - larghezzaTotPulsanti) / 2.0f;
  float pulsantiY = height - MARGINE_TOGGLE_BASSO - ALTEZZA_PULSANTE_MENU;

  toggleSfondo = new ToggleButton(startPulsantiX, pulsantiY, LARGHEZZA_PULSANTE_MENU, ALTEZZA_PULSANTE_MENU, "Sfondo quadri");
  btnApriEditor = new ActionButton(
    startPulsantiX + LARGHEZZA_PULSANTE_MENU + SPAZIO_PULSANTI_BASSO,
    pulsantiY,
    LARGHEZZA_PULSANTE_MENU,
    ALTEZZA_PULSANTE_MENU,
    "Pattern Custom",
    COLORE_BOTTONE_CUSTOM
    );
}

void inizializzaEditor() {
  float larghezzaTotale = LARGHEZZA_BOTTONE_EDITOR * 2.0f + SPAZIO_BOTTONI_EDITOR;
  float startX = (width - larghezzaTotale) / 2.0f;
  float btnY = height - MARGINE_BOTTONI_EDITOR_BASSO;

  btnAnnullaEditor = new ActionButton(
    startX,
    btnY,
    LARGHEZZA_BOTTONE_EDITOR,
    ALTEZZA_BOTTONE_EDITOR,
    "Annulla",
    COLORE_TOGGLE_OFF
    );

  btnConfermaEditor = new ActionButton(
    startX + LARGHEZZA_BOTTONE_EDITOR + SPAZIO_BOTTONI_EDITOR,
    btnY,
    LARGHEZZA_BOTTONE_EDITOR,
    ALTEZZA_BOTTONE_EDITOR,
    "Genera Quadri",
    COLORE_TOGGLE_ON
    );
}

void draw() {
  if (editorAperto) {
    disegnaEditor();
  } else if (patternAttivo == null) {
    disegnaMenu();
  } else {
    background(COLORE_SFONDO);
    ArrayList<Quadro> snapshotQuadri = quadri;
    for (Quadro q : snapshotQuadri) {
      q.display();
    }
    mostraIstruzioni();
  }
}

void disegnaMenu() {
  image(sfondoMenuBuffer, 0, 0);

  float centroX = width / 2.0f;
  fill(COLORE_TESTO);
  textAlign(CENTER, CENTER);
  textSize(FONT_TITOLO);
  text("MENU", centroX, height * RAPPORTO_TITOLO_Y);

  textSize(FONT_SOTTOTITOLO);
  fill(COLORE_SOTTOTITOLO);
  text("Scegli una configurazione o crea un pattern personalizzato", centroX, height * RAPPORTO_SOTTOTITOLO_Y);

  for (Card c : menuCards) {
    c.display();
  }

  toggleSfondo.display(sfondoAttivo);
  btnApriEditor.display();
}

void disegnaEditor() {
  image(sfondoMenuBuffer, 0, 0);
  float centroX = width / 2.0f;

  // Titolo
  fill(COLORE_TESTO);
  textAlign(CENTER, CENTER);
  textSize(34);
  text("EDITOR PATTERN PERSONALIZZATO", centroX, 65);

  // Riquadro Guidelines
  float boxX = 80;
  float boxW = width - 160;
  noStroke();
  fill(COLORE_BARRA_INFO);
  rectMode(CORNER);
  rect(boxX, 115, boxW, 255, 14);

  fill(COLORE_TESTO);
  textAlign(LEFT, TOP);
  textSize(16);
  text("LINEE GUIDA SINTASSI (Griglie da 1x1 fino a 25x25):", boxX + 24, 132);

  fill(COLORE_SOTTOTITOLO);
  textSize(FONT_GUIDA);
  String guida =
    "1. MODALITÀ COMANDI:  <N>x<N>; <comando1>; <comando2>; ...\n" +
    "   • Comandi disponibili:  riempi, bordo, scacchiera, diagonali, croce, centro, angoli\n" +
    "   • Sottrazione: aggiungi '-' davanti a un comando per svuotare quelle celle\n" +
    "   • Esempio:  7x7; bordo; croce; -centro\n\n" +
    "2. MODALITÀ MANUALE:  Usa 'X' (pieno), '.' (vuoto) e '/' per andare a capo\n" +
    "   • Deve formare una griglia quadrata (es. 3x3):  X.X / .X. / X.X";
  text(guida, boxX + 24, 165);

  // Casella di input testo
  float inputY = 405;
  float inputH = 64;
  fill(COLORE_BOX_INPUT);
  stroke(patternValido ? COLORE_VALIDO : COLORE_ERRORE);
  strokeWeight(2);
  rect(boxX, inputY, boxW, inputH, 12);

  // --- BLOCCO SOSTITUITO ---
  noStroke();
  textAlign(LEFT, CENTER);
  textSize(20);

  if (inputUtente.isEmpty()) {
    fill(COLORE_SOTTOTITOLO);
    text(PLACEHOLDER_EDITOR, boxX + 20, inputY + inputH / 2.0f);
  } else {
    fill(COLORE_TESTO);
    text(inputUtente + "|", boxX + 20, inputY + inputH / 2.0f);
  }
  // -------------------------

  // Messaggio di validazione in tempo reale
  textAlign(CENTER, CENTER);
  textSize(16);
  fill(patternValido ? COLORE_VALIDO : COLORE_ERRORE);
  text(messaggioValidazione, centroX, inputY + inputH + 35);

  fill(COLORE_SOTTOTITOLO);
  textSize(14);
  text("Digita da tastiera  •  INVIO per generare  •  ESC per tornare al menu", centroX, inputY + inputH + 68);

  btnAnnullaEditor.display();
  btnConfermaEditor.display();
}

void mostraIstruzioni() {
  float barraY = height - ALTEZZA_BARRA_INFO;

  noStroke();
  rectMode(CORNER);
  fill(COLORE_BARRA_INFO);
  rect(0, barraY, width, ALTEZZA_BARRA_INFO);

  fill(COLORE_TESTO);
  textAlign(CENTER, CENTER);
  textSize(FONT_SOTTOTITOLO);
  String testo = "Premi " + Character.toUpperCase(TASTO_INDIETRO) + " per tornare al menu  |  Click o lettera per rigenerare";
  text(testo, width / 2.0f, barraY + ALTEZZA_BARRA_INFO / 2.0f);
}

/**
 * Verifica la correttezza sintattica e geometrica del pattern inserito dall'utente.
 */
void aggiornaValidazione() {
  String pulito = trim(inputUtente).toLowerCase();
  if (pulito.length() == 0) {
    patternValido = false;
    messaggioValidazione = "Errore: il pattern non può essere vuoto.";
    return;
  }

  // Caso A: Griglia manuale con '/'
  if (pulito.contains(String.valueOf(SEPARATORE_RIGHE))) {
    String[] righe = split(trim(inputUtente), SEPARATORE_RIGHE);
    int n = righe.length;
    if (n < DIM_GRIGLIA_MIN || n > DIM_GRIGLIA_MAX) {
      patternValido = false;
      messaggioValidazione = "Errore: la dimensione deve essere tra " + DIM_GRIGLIA_MIN + " e " + DIM_GRIGLIA_MAX + ".";
      return;
    }
    int cellePiene = 0;
    for (int r = 0; r < n; r++) {
      String riga = trim(righe[r]);
      if (riga.length() != n) {
        patternValido = false;
        messaggioValidazione = "Errore riga " + (r + 1) + ": servono esattamente " + n + " caratteri (trovati " + riga.length() + ").";
        return;
      }
      for (int c = 0; c < riga.length(); c++) {
        char ch = Character.toUpperCase(riga.charAt(c));
        if (ch != SIMBOLO_PIENO && ch != SIMBOLO_VUOTO) {
          patternValido = false;
          messaggioValidazione = "Errore: carattere non valido '" + riga.charAt(c) + "'. Usa solo X e .";
          return;
        }
        if (ch == SIMBOLO_PIENO) cellePiene++;
      }
    }
    if (cellePiene == 0) {
      patternValido = false;
      messaggioValidazione = "Attenzione: il pattern non contiene nessun quadro ('X').";
      return;
    }
    patternValido = true;
    messaggioValidazione = "Pattern manuale valido (" + n + "x" + n + ", " + cellePiene + " quadri).";
    return;
  }

  // Caso B: Comandi dichiarativi (<N>x<N>; cmd1; cmd2)
  String[] istruzioni = split(pulito, ';');
  String[] dimTokens = split(trim(istruzioni[0]), 'x');
  if (dimTokens.length != 2 || !trim(dimTokens[0]).equals(trim(dimTokens[1]))) {
    patternValido = false;
    messaggioValidazione = "Errore: inizia con una griglia quadrata (es. 6x6; riempi).";
    return;
  }

  int n;
  try {
    n = Integer.parseInt(trim(dimTokens[0]));
  }
  catch (NumberFormatException e) {
    patternValido = false;
    messaggioValidazione = "Errore: dimensione griglia non numerica.";
    return;
  }

  if (n < DIM_GRIGLIA_MIN || n > DIM_GRIGLIA_MAX) {
    patternValido = false;
    messaggioValidazione = "Errore: la dimensione N deve essere compresa tra " + DIM_GRIGLIA_MIN + " e " + DIM_GRIGLIA_MAX + ".";
    return;
  }

  if (istruzioni.length < 2 || trim(istruzioni[1]).length() == 0) {
    patternValido = false;
    messaggioValidazione = "Errore: specifica almeno un comando dopo '" + n + "x" + n + ";' (es. riempi).";
    return;
  }

  for (int i = 1; i < istruzioni.length; i++) {
    String cmd = trim(istruzioni[i]);
    if (cmd.length() == 0) continue;
    if (cmd.startsWith("-")) cmd = cmd.substring(1);
    if (!COMANDI_VALIDI.contains(cmd)) {
      patternValido = false;
      messaggioValidazione = "Comando sconosciuto: '" + cmd + "'.";
      return;
    }
  }

  boolean[][] test = valutaPattern(inputUtente);
  int attivi = 0;
  for (int r = 0; r < n; r++) {
    for (int c = 0; c < n; c++) {
      if (test[r][c]) attivi++;
    }
  }

  if (attivi == 0) {
    patternValido = false;
    messaggioValidazione = "Attenzione: il pattern risultante è vuoto (0 quadri).";
    return;
  }

  patternValido = true;
  messaggioValidazione = "Pattern valido (" + n + "x" + n + ", " + attivi + " quadri generati).";
}

boolean[][] valutaPattern(String pattern) {
  String pulito = trim(pattern).toLowerCase();

  if (pulito.contains(String.valueOf(SEPARATORE_RIGHE))) {
    String[] righe = split(trim(pattern), SEPARATORE_RIGHE);
    int n = righe.length;
    boolean[][] griglia = new boolean[n][n];
    for (int r = 0; r < n; r++) {
      String riga = trim(righe[r]);
      for (int c = 0; c < min(n, riga.length()); c++) {
        griglia[r][c] = (Character.toUpperCase(riga.charAt(c)) == SIMBOLO_PIENO);
      }
    }
    return griglia;
  }

  String[] istruzioni = split(pulito, ';');
  String[] dimTokens = split(trim(istruzioni[0]), 'x');
  int n = int(trim(dimTokens[0]));
  boolean[][] griglia = new boolean[n][n];

  for (int i = 1; i < istruzioni.length; i++) {
    String cmd = trim(istruzioni[i]);
    if (cmd.length() == 0) continue;
    boolean valore = !cmd.startsWith("-");
    if (!valore) cmd = cmd.substring(1);

    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        boolean match = false;
        switch (cmd) {
        case "riempi":
          match = true;
          break;
        case "bordo":
          match = (r == 0 || r == n - 1 || c == 0 || c == n - 1);
          break;
        case "scacchiera":
          match = ((r + c) % 2 == 0);
          break;
        case "diagonali":
          match = (r == c || r + c == n - 1);
          break;
        case "centro":
          match = (r == n / 2 && c == n / 2);
          break;
        case "angoli":
          match = ((r == 0 || r == n - 1) && (c == 0 || c == n - 1));
          break;
        case "croce":
          match = (r == n / 2 || c == n / 2);
          break;
        }
        if (match) griglia[r][c] = valore;
      }
    }
  }
  return griglia;
}

void generaQuadriDaPattern(String pattern) {
  ArrayList<Quadro> nuovaLista = new ArrayList<Quadro>();
  boolean[][] griglia = valutaPattern(pattern);
  int dimensioneGriglia = griglia.length;

  float altezzaUtile = height - ALTEZZA_BARRA_INFO;
  float areaGriglia = min(width, altezzaUtile);
  float latoCella = areaGriglia / dimensioneGriglia;
  float metaCella = latoCella / 2.0f;

  float offsetX = (width - areaGriglia) / 2.0f;
  float offsetY = (altezzaUtile - areaGriglia) / 2.0f;

  for (int r = 0; r < dimensioneGriglia; r++) {
    for (int c = 0; c < dimensioneGriglia; c++) {
      if (griglia[r][c]) {
        float x = offsetX + c * latoCella + metaCella;
        float y = offsetY + r * latoCella + metaCella;
        nuovaLista.add(new Quadro(x, y, latoCella, sfondoAttivo));
      }
    }
  }

  quadri = nuovaLista;
}

void mousePressed() {
  if (editorAperto) {
    if (btnAnnullaEditor.isClicked(mouseX, mouseY)) {
      editorAperto = false;
      redraw();
    } else if (btnConfermaEditor.isClicked(mouseX, mouseY) && patternValido) {
      editorAperto = false;
      patternAttivo = inputUtente;
      generaQuadriDaPattern(patternAttivo);
      redraw();
    }
    return;
  }

  if (patternAttivo == null) {
    if (toggleSfondo.isClicked(mouseX, mouseY)) {
      sfondoAttivo = !sfondoAttivo;
      redraw();
      return;
    }

    if (btnApriEditor.isClicked(mouseX, mouseY)) {
      editorAperto = true;
      aggiornaValidazione();
      redraw();
      return;
    }

    for (Card c : menuCards) {
      if (c.isClicked(mouseX, mouseY)) {
        modalitaCorrente = c.modalita;
        patternAttivo = modalitaCorrente.pattern;
        generaQuadriDaPattern(patternAttivo);
        redraw();
        break;
      }
    }
  } else {
    generaQuadriDaPattern(patternAttivo);
    redraw();
  }
}

void keyPressed() {
  // Gestione digitazione dentro l'editor
  if (editorAperto) {
    if (key == ESC) {
      key = 0; // Impedisce a Processing di chiudere la finestra
      editorAperto = false;
      redraw();
    } else if (key == ENTER || key == RETURN) {
      if (patternValido) {
        editorAperto = false;
        patternAttivo = inputUtente;
        generaQuadriDaPattern(patternAttivo);
        redraw();
      }
    } else if (key == BACKSPACE) {
      if (inputUtente.length() > 0) {
        inputUtente = inputUtente.substring(0, inputUtente.length() - 1);
        aggiornaValidazione();
        redraw();
      }
    } else if (key != CODED && key >= 32 && key <= 126 && inputUtente.length() < 60) {
      inputUtente += key;
      aggiornaValidazione();
      redraw();
    }
    return;
  }

  // Gestione navigazione nella schermata dei quadri
  if (Character.toLowerCase(key) == TASTO_INDIETRO) {
    modalitaCorrente = null;
    patternAttivo = null;
    redraw();
  } else if (patternAttivo != null && key != CODED && Character.isLetter(key)) {
    generaQuadriDaPattern(patternAttivo);
    redraw();
  }
}
