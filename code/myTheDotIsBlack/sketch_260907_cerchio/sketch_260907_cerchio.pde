import java.util.concurrent.ThreadLocalRandom;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * Sketch principale per la generazione procedurale di quadri radiali su griglia.
 * Coordina la macchina a stati (StatoApp), il layout responsivo e la delega ai moduli di dominio.
 */

enum StatoApp {
  MENU,
    EDITOR,
    QUADRI
}

// Costanti di navigazione, tipografia e layout
final char TASTO_INDIETRO = 'f';
final String NOME_FONT = "SansSerif";
final int FONT_TITOLO = 44;
final int FONT_SOTTOTITOLO = 16;
final int FONT_CARD = 26;
final int FONT_TOGGLE = 18;
final int FONT_INPUT_EDITOR = 20;

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

final float BOX_EDITOR_X = 50.0f;
final float BOX_EDITOR_Y = 405.0f;
final float BOX_EDITOR_H = 64.0f;
final float LARGHEZZA_BOTTONE_EDITOR = 200.0f;
final float ALTEZZA_BOTTONE_EDITOR = 48.0f;
final float SPAZIO_BOTTONI_EDITOR = 24.0f;
final float MARGINE_BOTTONI_EDITOR_BASSO = 110.0f;
final String PLACEHOLDER_EDITOR = "Scrivi qui il tuo pattern (es. 6x6; bordo; croce)...";

// Palette UI
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

// Componenti e stato dell'applicazione
PFont font;
PGraphics sfondoMenuBuffer;

StatoApp statoCorrente = StatoApp.MENU;
PatternEngine patternEngine = new PatternEngine();
RisultatoValidazione validazioneCorrente;

String patternAttivo = null;
boolean sfondoAttivo = true;

Card[] menuCards;
ToggleButton toggleSfondo;
ActionButton btnApriEditor;
ActionButton btnConfermaEditor;
ActionButton btnAnnullaEditor;
TextInputField campoInputPattern;

volatile ArrayList<Quadro> quadri = new ArrayList<Quadro>();

void setup() {
  size(800, 800);
  noLoop();

  font = createFont(NOME_FONT, FONT_TITOLO);
  textFont(font);

  creaBufferSfondoMenu();
  inizializzaMenu();
  inizializzaEditor();
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
  float inputW = width - BOX_EDITOR_X * 2.0f;
  campoInputPattern = new TextInputField(BOX_EDITOR_X, BOX_EDITOR_Y, inputW, BOX_EDITOR_H, PLACEHOLDER_EDITOR);
  validazioneCorrente = patternEngine.valida(campoInputPattern.getTesto());

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

// ============================================================================
// CICLO DI RENDERING DISTINTO PER STATO
// ============================================================================

void draw() {
  switch (statoCorrente) {
  case MENU:
    disegnaMenu();
    break;
  case EDITOR:
    disegnaEditor();
    break;
  case QUADRI:
    disegnaVistaQuadri();
    break;
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

  fill(COLORE_TESTO);
  textAlign(CENTER, CENTER);
  textSize(34);
  text("EDITOR PATTERN PERSONALIZZATO", centroX, 55);

  float spazioCard = 20.0f;
  float cardW = (width - BOX_EDITOR_X * 2.0f - spazioCard) / 2.0f;
  float cardY = 100.0f;
  float cardH = 285.0f;

  disegnaSchedaGuida(
    BOX_EDITOR_X, cardY, cardW, cardH,
    COLORE_BOTTONE_CUSTOM,
    "1. COMANDI RAPIDI",
    "Formato:  Colonne x Righe; comandi",
    "• Parola chiave:\n  riempi, bordo, scacchiera,\n  diagonali, croce, centro, angoli\n• Usa '-' davanti per svuotare\n• Sotto-griglie al centro (es. -6x6)",
    "Esempi:  8x8; -6x6; 2x2   |   4x2"
    );

  disegnaSchedaGuida(
    BOX_EDITOR_X + cardW + spazioCard, cardY, cardW, cardH,
    COLORE_VALIDO,
    "2. DISEGNO MANUALE",
    "Disegna riga per riga (max 25x25)",
    "• 'X'  = inserisce un quadro\n• '.'  = lascia spazio vuoto\n• '/'  = va alla riga successiva\n\nTutte le righe devono avere\nlo stesso numero di colonne.",
    "Esempio:  X.X / .X. / X.X"
    );

  campoInputPattern.display(validazioneCorrente.valido);

  noStroke();
  textAlign(CENTER, CENTER);
  textSize(18);
  fill(validazioneCorrente.valido ? COLORE_VALIDO : COLORE_ERRORE);
  text(validazioneCorrente.messaggio, centroX, BOX_EDITOR_Y + BOX_EDITOR_H + 36);

  fill(COLORE_TESTO);
  textSize(15);
  text("Frecce ◄ ► o Click per spostare il cursore   •   INVIO per generare   •   ESC per uscire", centroX, BOX_EDITOR_Y + BOX_EDITOR_H + 72);

  btnAnnullaEditor.display();
  btnConfermaEditor.display();
}

void disegnaSchedaGuida(
  float x, float y, float w, float h,
  color coloreAccento, String titolo, String sottotitolo, String corpo, String esempio
  ) {
  fill(COLORE_BARRA_INFO);
  stroke(coloreAccento);
  strokeWeight(2);
  rectMode(CORNER);
  rect(x, y, w, h, 14);

  noStroke();
  textAlign(LEFT, TOP);
  fill(coloreAccento);
  textSize(20);
  text(titolo, x + 20, y + 18);

  fill(COLORE_TESTO);
  textSize(16);
  text(sottotitolo, x + 20, y + 52);

  fill(COLORE_SOTTOTITOLO);
  textSize(15);
  text(corpo, x + 20, y + 84);

  fill(COLORE_VALIDO);
  textSize(16);
  text(esempio, x + 20, y + 235);
}

void disegnaVistaQuadri() {
  background(COLORE_SFONDO);
  ArrayList<Quadro> snapshotQuadri = quadri;
  for (Quadro q : snapshotQuadri) {
    q.display();
  }
  mostraIstruzioni();
}

void mostraIstruzioni() {
  float barraY = height - ALTEZZA_BARRA_INFO;

  noStroke();
  rectMode(CORNER);
  fill(COLORE_BARRA_INFO);
  rect(0, barraY, width, ALTEZZA_BARRA_INFO);

  stroke(COLORE_BOTTONE_CUSTOM);
  strokeWeight(2);
  line(0, barraY, width, barraY);

  noStroke();
  fill(COLORE_TESTO);
  textAlign(CENTER, CENTER);
  textSize(18);
  String testo = "[ " + Character.toUpperCase(TASTO_INDIETRO) + " ] Torna al Menu     |     [ Click / Lettera ] Rigenera Quadri";
  text(testo, width / 2.0f, barraY + ALTEZZA_BARRA_INFO / 2.0f);
}

// ============================================================================
// GENERAZIONE QUADRI E GESTIONE DEGLI INPUT PER STATO
// ============================================================================

void avviaVisualizzazioneQuadri(String pattern) {
  patternAttivo = pattern;
  generaQuadriDaPattern(patternAttivo);
  statoCorrente = StatoApp.QUADRI;
  redraw();
}

void generaQuadriDaPattern(String pattern) {
  ArrayList<Quadro> nuovaLista = new ArrayList<Quadro>();
  boolean[][] griglia = patternEngine.valutaPattern(pattern);
  int righe = griglia.length;
  int colonne = griglia[0].length;

  float altezzaUtile = height - ALTEZZA_BARRA_INFO;
  float latoCella = min(width / (float) colonne, altezzaUtile / (float) righe);
  float metaCella = latoCella / 2.0f;

  float larghezzaTotale = colonne * latoCella;
  float altezzaTotale = righe * latoCella;

  float offsetX = (width - larghezzaTotale) / 2.0f;
  float offsetY = (altezzaUtile - altezzaTotale) / 2.0f;

  for (int r = 0; r < righe; r++) {
    for (int c = 0; c < colonne; c++) {
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
  switch (statoCorrente) {
  case MENU:
    gestisciMouseMenu();
    break;
  case EDITOR:
    gestisciMouseEditor();
    break;
  case QUADRI:
    generaQuadriDaPattern(patternAttivo);
    redraw();
    break;
  }
}

void gestisciMouseMenu() {
  if (toggleSfondo.isClicked(mouseX, mouseY)) {
    sfondoAttivo = !sfondoAttivo;
    redraw();
    return;
  }

  if (btnApriEditor.isClicked(mouseX, mouseY)) {
    campoInputPattern.posizionaCursoreAllaFine();
    validazioneCorrente = patternEngine.valida(campoInputPattern.getTesto());
    statoCorrente = StatoApp.EDITOR;
    redraw();
    return;
  }

  for (Card c : menuCards) {
    if (c.isClicked(mouseX, mouseY)) {
      avviaVisualizzazioneQuadri(c.modalita.pattern);
      break;
    }
  }
}

void gestisciMouseEditor() {
  if (campoInputPattern.isClicked(mouseX, mouseY)) {
    campoInputPattern.aggiornaCursoreDaMouse(mouseX);
    redraw();
  } else if (btnAnnullaEditor.isClicked(mouseX, mouseY)) {
    statoCorrente = StatoApp.MENU;
    redraw();
  } else if (btnConfermaEditor.isClicked(mouseX, mouseY) && validazioneCorrente.valido) {
    avviaVisualizzazioneQuadri(campoInputPattern.getTesto());
  }
}

void keyPressed() {
  switch (statoCorrente) {
  case EDITOR:
    gestisciTastieraEditor();
    break;
  case QUADRI:
    gestisciTastieraQuadri();
    break;
  default:
    break;
  }
}

void gestisciTastieraEditor() {
  if (key == ESC) {
    key = 0; // Impedisce a Processing di chiudere lo sketch
    statoCorrente = StatoApp.MENU;
    redraw();
  } else if (key == ENTER || key == RETURN) {
    if (validazioneCorrente.valido) {
      avviaVisualizzazioneQuadri(campoInputPattern.getTesto());
    }
  } else {
    boolean testoModificato = campoInputPattern.gestisciTasto(key, keyCode);
    if (testoModificato) {
      validazioneCorrente = patternEngine.valida(campoInputPattern.getTesto());
    }
    redraw();
  }
}

void gestisciTastieraQuadri() {
  if (Character.toLowerCase(key) == TASTO_INDIETRO) {
    patternAttivo = null;
    statoCorrente = StatoApp.MENU;
    redraw();
  } else if (key != CODED && Character.isLetter(key)) {
    generaQuadriDaPattern(patternAttivo);
    redraw();
  }
}
