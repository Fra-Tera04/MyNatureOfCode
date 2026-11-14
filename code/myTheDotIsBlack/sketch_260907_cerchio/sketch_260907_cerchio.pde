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

// Costanti posizione casella input editor
final float BOX_EDITOR_X = 80.0f;
final float BOX_EDITOR_Y = 405.0f;
final float BOX_EDITOR_H = 64.0f;
final float PADDING_TESTO_EDITOR = 20.0f;
final int FONT_INPUT_EDITOR = 20;

// Stato dell'editor di pattern (vuoto all'avvio)
String inputUtente = "";
int indiceCursore = 0; // Posizione del cursore (0 <= indiceCursore <= inputUtente.length())
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

  // 1. Titolo Principale
  fill(COLORE_TESTO);
  textAlign(CENTER, CENTER);
  textSize(34);
  text("EDITOR PATTERN PERSONALIZZATO", centroX, 55);

  // 2. Due Schede affiancate ad alta leggibilità (Comandi vs Manuale)
  float margineLat = 50.0f;
  float spazioCard = 20.0f;
  float cardW = (width - margineLat * 2.0f - spazioCard) / 2.0f;
  float cardY = 100.0f;
  float cardH = 285.0f;

  // --- SCHEDA SINISTRA: MODALITÀ COMANDI ---
  float card1X = margineLat;
  fill(COLORE_BARRA_INFO);
  stroke(COLORE_BOTTONE_CUSTOM);
  strokeWeight(2);
  rectMode(CORNER);
  rect(card1X, cardY, cardW, cardH, 14);

  noStroke();
  textAlign(LEFT, TOP);
  fill(COLORE_BOTTONE_CUSTOM);
  textSize(20);
  text("1. COMANDI RAPIDI", card1X + 20, cardY + 18);

  fill(COLORE_TESTO);
  textSize(16);
  text("Formato:  Colonne x Righe; comandi", card1X + 20, cardY + 52);

  fill(COLORE_SOTTOTITOLO);
  textSize(15);
  text(
    "• Parola chiave:\n" +
    "  riempi, bordo, scacchiera,\n" +
    "  diagonali, croce, centro, angoli\n" +
    "• Usa '-' davanti per svuotare\n" +
    "• Sotto-griglie al centro (es. -6x6)",
    card1X + 20, cardY + 84
    );

  // Riquadro Esempio in evidenza (Card 1)
  fill(COLORE_VALIDO);
  textSize(16);
  text("Esempi:  8x8; -6x6; 2x2   |   4x2", card1X + 20, cardY + 235);

  // --- SCHEDA DESTRA: MODALITÀ MANUALE ---
  float card2X = card1X + cardW + spazioCard;
  fill(COLORE_BARRA_INFO);
  stroke(COLORE_VALIDO);
  strokeWeight(2);
  rect(card2X, cardY, cardW, cardH, 14);

  noStroke();
  textAlign(LEFT, TOP);
  fill(COLORE_VALIDO);
  textSize(20);
  text("2. DISEGNO MANUALE", card2X + 20, cardY + 18);

  fill(COLORE_TESTO);
  textSize(16);
  text("Disegna riga per riga (max 25x25)", card2X + 20, cardY + 52);

  fill(COLORE_SOTTOTITOLO);
  textSize(15);
  text(
    "• 'X'  = inserisce un quadro\n" +
    "• '.'  = lascia spazio vuoto\n" +
    "• '/'  = va alla riga successiva\n\n" +
    "Tutte le righe devono avere\n" +
    "lo stesso numero di colonne.",
    card2X + 20, cardY + 84
    );

  // Riquadro Esempio in evidenza (Card 2)
  fill(COLORE_VALIDO);
  textSize(16);
  text("Esempio:  X.X / .X. / X.X", card2X + 20, cardY + 235);

  // 3. Casella di input testo (allargata per allinearsi alle due schede)
  float inputX = margineLat;
  float inputW = width - margineLat * 2.0f;
  fill(COLORE_BOX_INPUT);
  stroke(patternValido ? COLORE_VALIDO : COLORE_ERRORE);
  strokeWeight(3);
  rect(inputX, BOX_EDITOR_Y, inputW, BOX_EDITOR_H, 12);

  // Testo e cursore mobile
  noStroke();
  textAlign(LEFT, CENTER);
  textSize(FONT_INPUT_EDITOR);
  float testoX = inputX + PADDING_TESTO_EDITOR;
  float testoY = BOX_EDITOR_Y + BOX_EDITOR_H / 2.0f;

  indiceCursore = constrain(indiceCursore, 0, inputUtente.length());

  if (inputUtente.isEmpty()) {
    fill(COLORE_SOTTOTITOLO);
    text(PLACEHOLDER_EDITOR, testoX, testoY);
    stroke(COLORE_TESTO);
    strokeWeight(2);
    line(testoX, BOX_EDITOR_Y + 16, testoX, BOX_EDITOR_Y + BOX_EDITOR_H - 16);
  } else {
    fill(COLORE_TESTO);
    text(inputUtente, testoX, testoY);

    String primaDelCursore = inputUtente.substring(0, indiceCursore);
    float cursoreX = testoX + textWidth(primaDelCursore);

    stroke(COLORE_VALIDO);
    strokeWeight(2);
    line(cursoreX, BOX_EDITOR_Y + 16, cursoreX, BOX_EDITOR_Y + BOX_EDITOR_H - 16);
  }

  // 4. Messaggio di validazione in evidenza
  noStroke();
  textAlign(CENTER, CENTER);
  textSize(18);
  fill(patternValido ? COLORE_VALIDO : COLORE_ERRORE);
  text(messaggioValidazione, centroX, BOX_EDITOR_Y + BOX_EDITOR_H + 36);

  fill(COLORE_TESTO);
  textSize(15);
  text("Frecce ◄ ► o Click per spostare il cursore   •   INVIO per generare   •   ESC per uscire", centroX, BOX_EDITOR_Y + BOX_EDITOR_H + 72);

  btnAnnullaEditor.display();
  btnConfermaEditor.display();
}

void mostraIstruzioni() {
  float barraY = height - ALTEZZA_BARRA_INFO;

  noStroke();
  rectMode(CORNER);
  fill(COLORE_BARRA_INFO);
  rect(0, barraY, width, ALTEZZA_BARRA_INFO);

  // Linea superiore di separazione per mettere in risalto la barra
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

/**
 * Verifica se una stringa rispetta il formato "CxR" (colonne x righe) e restituisce [colonne, righe].
 * Restituisce null se il formato o i limiti [DIM_GRIGLIA_MIN, DIM_GRIGLIA_MAX] non sono validi.
 */
int[] parseDimensioni(String token) {
  String[] parti = split(trim(token), 'x');
  if (parti.length != 2) return null;

  try {
    int colonne = Integer.parseInt(trim(parti[0]));
    int righe = Integer.parseInt(trim(parti[1]));
    if (colonne < DIM_GRIGLIA_MIN || colonne > DIM_GRIGLIA_MAX ||
      righe < DIM_GRIGLIA_MIN || righe > DIM_GRIGLIA_MAX) {
      return null;
    }
    return new int[]{colonne, righe};
  }
  catch (NumberFormatException e) {
    return null;
  }
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

  // Caso A: Griglia manuale con '/' (supporta anche rettangoli CxR)
  if (pulito.contains(String.valueOf(SEPARATORE_RIGHE))) {
    String[] righeArr = split(trim(inputUtente), SEPARATORE_RIGHE);
    int numRighe = righeArr.length;
    if (numRighe < DIM_GRIGLIA_MIN || numRighe > DIM_GRIGLIA_MAX) {
      patternValido = false;
      messaggioValidazione = "Errore: le righe devono essere tra " + DIM_GRIGLIA_MIN + " e " + DIM_GRIGLIA_MAX + ".";
      return;
    }

    int numColonne = trim(righeArr[0]).length();
    if (numColonne < DIM_GRIGLIA_MIN || numColonne > DIM_GRIGLIA_MAX) {
      patternValido = false;
      messaggioValidazione = "Errore: le colonne devono essere tra " + DIM_GRIGLIA_MIN + " e " + DIM_GRIGLIA_MAX + ".";
      return;
    }

    int cellePiene = 0;
    for (int r = 0; r < numRighe; r++) {
      String riga = trim(righeArr[r]);
      if (riga.length() != numColonne) {
        patternValido = false;
        messaggioValidazione = "Errore riga " + (r + 1) + ": servono " + numColonne + " colonne (trovate " + riga.length() + ").";
        return;
      }
      for (int c = 0; c < numColonne; c++) {
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
    messaggioValidazione = "Pattern manuale valido (" + numColonne + "x" + numRighe + ", " + cellePiene + " quadri).";
    return;
  }

  // Caso B: Comandi dichiarativi (<C>x<R> [; cmd1; cmd2; -<subC>x<subR>])
  String[] istruzioni = split(pulito, ';');
  int[] dims = parseDimensioni(istruzioni[0]);
  if (dims == null) {
    patternValido = false;
    messaggioValidazione = "Errore: usa formato Colonne x Righe tra " + DIM_GRIGLIA_MIN + " e " + DIM_GRIGLIA_MAX + " (es. 4x2 o 16x16).";
    return;
  }

  int colonne = dims[0];
  int righe = dims[1];

  // Controlla se ci sono istruzioni reali dopo il primo token
  boolean haIstruzioniReali = false;
  for (int i = 1; i < istruzioni.length; i++) {
    String cmd = trim(istruzioni[i]);
    if (cmd.length() == 0) continue;
    haIstruzioniReali = true;

    if (cmd.startsWith("-")) cmd = trim(cmd.substring(1));

    // Può essere un comando testuale oppure una sotto-griglia centrale (es. 8x8)
    int[] subDims = parseDimensioni(cmd);
    if (subDims != null) {
      if (subDims[0] > colonne || subDims[1] > righe) {
        patternValido = false;
        messaggioValidazione = "Errore: il blocco '" + cmd + "' supera la griglia " + colonne + "x" + righe + ".";
        return;
      }
    } else if (!COMANDI_VALIDI.contains(cmd)) {
      patternValido = false;
      messaggioValidazione = "Comando sconosciuto: '" + cmd + "'.";
      return;
    }
  }

  boolean[][] test = valutaPattern(inputUtente);
  int attivi = 0;
  for (int r = 0; r < righe; r++) {
    for (int c = 0; c < colonne; c++) {
      if (test[r][c]) attivi++;
    }
  }

  if (attivi == 0) {
    patternValido = false;
    messaggioValidazione = "Attenzione: il pattern risultante è vuoto (0 quadri).";
    return;
  }

  patternValido = true;
  String notaImplicita = haIstruzioniReali ? "" : " - riempimento automatico";
  messaggioValidazione = "Pattern valido (" + colonne + " col x " + righe + " righe, " + attivi + " quadri" + notaImplicita + ").";
}

/**
 * Compila una stringa DSL in una matrice booleana [righe][colonne].
 */
/**
 * Compila una stringa DSL in una matrice booleana [righe][colonne],
 * instradando ogni istruzione tramite switch verso la relativa funzione geometrica.
 *
 * @param pattern Stringa di configurazione (es. "8x8; -7x7; 6x6" oppure "XX. / XXX / .XX").
 * @return Matrice booleana dove true indica la presenza di un Quadro.
 */
boolean[][] valutaPattern(String pattern) {
  String pulito = trim(pattern).toLowerCase();

  // Caso 1: Matrice manuale esplicita (es. "XX. / XXX / .XX")
  if (pulito.contains(String.valueOf(SEPARATORE_RIGHE))) {
    return compilaGrigliaManuale(trim(pattern));
  }

  // Caso 2: Comandi dichiarativi (<C>x<R>; cmd1; cmd2; ...)
  String[] istruzioni = split(pulito, ';');
  int[] dims = parseDimensioni(istruzioni[0]);
  int colonne = dims[0];
  int righe = dims[1];
  boolean[][] griglia = new boolean[righe][colonne];

  // Estrae i soli comandi non vuoti successivi alla dimensione
  ArrayList<String> comandi = estraiComandi(istruzioni);

  // Se non ci sono comandi (es. "16x16") -> riempimento implicito
  if (comandi.isEmpty()) {
    applicaComandoRiempi(griglia, true);
    return griglia;
  }

  // Se la prima operazione è una sottrazione (es. "8x8; -7x7; 6x6"), parte dalla griglia piena
  if (comandi.get(0).startsWith("-")) {
    applicaComandoRiempi(griglia, true);
  }

  // Esegue in sequenza ogni comando tramite switch
  for (String rawCmd : comandi) {
    boolean valore = !rawCmd.startsWith("-");
    String cmd = valore ? rawCmd : trim(rawCmd.substring(1));

    int[] subDims = parseDimensioni(cmd);
    String tipoOperazione = (subDims != null) ? "subgriglia" : cmd;

    switch (tipoOperazione) {
    case "subgriglia":
      if (subDims != null) {
        applicaSubGrigliaCentrata(griglia, subDims[0], subDims[1], valore);
      }
      break;
    case "riempi":
      applicaComandoRiempi(griglia, valore);
      break;
    case "bordo":
      applicaComandoBordo(griglia, valore);
      break;
    case "scacchiera":
      applicaComandoScacchiera(griglia, valore);
      break;
    case "diagonali":
      applicaComandoDiagonali(griglia, valore);
      break;
    case "centro":
      applicaComandoCentro(griglia, valore);
      break;
    case "angoli":
      applicaComandoAngoli(griglia, valore);
      break;
    case "croce":
      applicaComandoCroce(griglia, valore);
      break;
    }
  }

  return griglia;
}

// ============================================================================
// FUNZIONI DEDICATE AL CALCOLO DEI PATTERN
// ============================================================================

/**
 * Filtra i token successivi al primo eliminando eventuali stringhe vuote.
 */
ArrayList<String> estraiComandi(String[] istruzioni) {
  ArrayList<String> lista = new ArrayList<String>();
  for (int i = 1; i < istruzioni.length; i++) {
    String token = trim(istruzioni[i]);
    if (token.length() > 0) {
      lista.add(token);
    }
  }
  return lista;
}

/**
 * Compila una matrice esplicita formattata con 'X', '.' e '/'.
 */
boolean[][] compilaGrigliaManuale(String pattern) {
  String[] righeArr = split(pattern, SEPARATORE_RIGHE);
  int righe = righeArr.length;
  int colonne = trim(righeArr[0]).length();
  boolean[][] griglia = new boolean[righe][colonne];

  for (int r = 0; r < righe; r++) {
    String riga = trim(righeArr[r]);
    for (int c = 0; c < colonne; c++) {
      griglia[r][c] = (Character.toUpperCase(riga.charAt(c)) == SIMBOLO_PIENO);
    }
  }
  return griglia;
}

/**
 * Applica un blocco rettangolare centrato calcolando la distanza dal baricentro della matrice.
 * Se griglia e blocco hanno la stessa parità (entrambi pari o entrambi dispari),
 * la centratura è geometricamente esatta; in caso di parità mista, allinea al centro intero.
 *
 * @param griglia Matrice booleana [righe][colonne] da modificare.
 * @param subC    Numero di colonne del blocco centrale.
 * @param subR    Numero di righe del blocco centrale.
 * @param valore  Valore booleano da assegnare (true = pieno, false = vuoto).
 */
void applicaSubGrigliaCentrata(boolean[][] griglia, int subC, int subR, boolean valore) {
  int righe = griglia.length;
  int colonne = griglia[0].length;

  float centroC = (colonne - 1) / 2.0f;
  float centroR = (righe - 1) / 2.0f;

  // Se la parità tra griglia e sotto-blocco è diversa (es. 1x1 dentro 8x8),
  // sposta il centro di 0.5 per centrare sulla cella mediana inferiore
  if ((colonne % 2) != (subC % 2)) centroC -= 0.5f;
  if ((righe % 2) != (subR % 2)) centroR -= 0.5f;

  float metaC = subC / 2.0f;
  float metaR = subR / 2.0f;

  for (int r = 0; r < righe; r++) {
    for (int c = 0; c < colonne; c++) {
      if (abs(c - centroC) < metaC && abs(r - centroR) < metaR) {
        griglia[r][c] = valore;
      }
    }
  }
}

/**
 * Imposta tutte le celle della griglia al valore booleano specificato.
 */
void applicaComandoRiempi(boolean[][] griglia, boolean valore) {
  for (int r = 0; r < griglia.length; r++) {
    for (int c = 0; c < griglia[0].length; c++) {
      griglia[r][c] = valore;
    }
  }
}

/**
 * Seleziona il perimetro esterno della griglia (prima/ultima riga e prima/ultima colonna).
 */
void applicaComandoBordo(boolean[][] griglia, boolean valore) {
  int righe = griglia.length;
  int colonne = griglia[0].length;
  for (int r = 0; r < righe; r++) {
    for (int c = 0; c < colonne; c++) {
      if (r == 0 || r == righe - 1 || c == 0 || c == colonne - 1) {
        griglia[r][c] = valore;
      }
    }
  }
}

/**
 * Seleziona le celle a parità uniforme ((r + c) % 2 == 0).
 */
void applicaComandoScacchiera(boolean[][] griglia, boolean valore) {
  for (int r = 0; r < griglia.length; r++) {
    for (int c = 0; c < griglia[0].length; c++) {
      if ((r + c) % 2 == 0) {
        griglia[r][c] = valore;
      }
    }
  }
}

/**
 * Seleziona le diagonali principali della griglia.
 */
void applicaComandoDiagonali(boolean[][] griglia, boolean valore) {
  int righe = griglia.length;
  int colonne = griglia[0].length;
  for (int r = 0; r < righe; r++) {
    for (int c = 0; c < colonne; c++) {
      if (r == c || r + c == colonne - 1 || r + c == righe - 1) {
        griglia[r][c] = valore;
      }
    }
  }
}

/**
 * Seleziona la cella centrale (o le celle mediane).
 */
void applicaComandoCentro(boolean[][] griglia, boolean valore) {
  int rCentro = griglia.length / 2;
  int cCentro = griglia[0].length / 2;
  griglia[rCentro][cCentro] = valore;
}

/**
 * Seleziona i quattro vertici esterni della griglia.
 */
void applicaComandoAngoli(boolean[][] griglia, boolean valore) {
  int maxR = griglia.length - 1;
  int maxC = griglia[0].length - 1;
  griglia[0][0] = valore;
  griglia[0][maxC] = valore;
  griglia[maxR][0] = valore;
  griglia[maxR][maxC] = valore;
}

/**
 * Seleziona la riga mediana e la colonna mediana formando una croce.
 */
void applicaComandoCroce(boolean[][] griglia, boolean valore) {
  int righe = griglia.length;
  int colonne = griglia[0].length;
  int rCentro = righe / 2;
  int cCentro = colonne / 2;

  for (int c = 0; c < colonne; c++) griglia[rCentro][c] = valore;
  for (int r = 0; r < righe; r++) griglia[r][cCentro] = valore;
}

/**
 * Genera i Quadri adattando le celle quadrate a griglie sia quadrate sia rettangolari (Colonne x Righe).
 */
void generaQuadriDaPattern(String pattern) {
  ArrayList<Quadro> nuovaLista = new ArrayList<Quadro>();
  boolean[][] griglia = valutaPattern(pattern);
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
  if (editorAperto) {
    float boxW = width - BOX_EDITOR_X * 2.0f;

    // Clic dentro la casella di testo -> posiziona il cursore nel punto cliccato
    if (mouseX >= BOX_EDITOR_X && mouseX <= BOX_EDITOR_X + boxW &&
      mouseY >= BOX_EDITOR_Y && mouseY <= BOX_EDITOR_Y + BOX_EDITOR_H) {

      textSize(FONT_INPUT_EDITOR);
      float testoX = BOX_EDITOR_X + PADDING_TESTO_EDITOR;
      float clickRelativoX = mouseX - testoX;

      int migliorIndice = inputUtente.length();
      for (int i = 0; i <= inputUtente.length(); i++) {
        float wCorrente = textWidth(inputUtente.substring(0, i));
        if (i < inputUtente.length()) {
          float wProssimo = textWidth(inputUtente.substring(0, i + 1));
          float puntoMedio = (wCorrente + wProssimo) / 2.0f;
          if (clickRelativoX < puntoMedio) {
            migliorIndice = i;
            break;
          }
        }
      }
      indiceCursore = migliorIndice;
      redraw();
      return;
    }

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
      indiceCursore = inputUtente.length();
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
  if (editorAperto) {
    indiceCursore = constrain(indiceCursore, 0, inputUtente.length());

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
    } else if (key == CODED) {
      if (keyCode == LEFT && indiceCursore > 0) {
        indiceCursore--;
        redraw();
      } else if (keyCode == RIGHT && indiceCursore < inputUtente.length()) {
        indiceCursore++;
        redraw();
      } else if (keyCode == java.awt.event.KeyEvent.VK_HOME) {
        indiceCursore = 0;
        redraw();
      } else if (keyCode == java.awt.event.KeyEvent.VK_END) {
        indiceCursore = inputUtente.length();
        redraw();
      }
    } else if (key == BACKSPACE) {
      if (indiceCursore > 0) {
        inputUtente = inputUtente.substring(0, indiceCursore - 1) + inputUtente.substring(indiceCursore);
        indiceCursore--;
        aggiornaValidazione();
        redraw();
      }
    } else if (key == DELETE) {
      if (indiceCursore < inputUtente.length()) {
        inputUtente = inputUtente.substring(0, indiceCursore) + inputUtente.substring(indiceCursore + 1);
        aggiornaValidazione();
        redraw();
      }
    } else if (key == '-' || (key >= 32 && key <= 126)) {
      if (inputUtente.length() < 60) {
        inputUtente = inputUtente.substring(0, indiceCursore) + key + inputUtente.substring(indiceCursore);
        indiceCursore++;
        aggiornaValidazione();
        redraw();
      }
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
