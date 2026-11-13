/**
 * Sketch principale per la generazione procedurale di quadri radiali su griglia.
 * Gestisce la macchina a stati (Menu vs Vista Quadri), il layout responsivo e gli input utente.
 */

// Costanti di input e sintassi del Domain-Specific Language (DSL) dei pattern
final char TASTO_INDIETRO = 'f';
final char SIMBOLO_PIENO = 'X';
final char SEPARATORE_RIGHE = '/';

// Costanti tipografiche e di layout
final String NOME_FONT = "SansSerif";
final int FONT_TITOLO = 44;
final int FONT_SOTTOTITOLO = 16;
final int FONT_CARD = 26;
final int FONT_TOGGLE = 18;

final float RAPPORTO_TITOLO_Y = 0.07f;
final float RAPPORTO_SOTTOTITOLO_Y = 0.12f;
final float FATTORE_MARGINE_SUPERIORE_MENU = 0.6f;
final float FATTORE_MARGINE_INFERIORE_MENU = 0.5f;
final float ALTEZZA_BARRA_INFO = 44.0f;
final float MARGINE_GRIGLIA_MENU = 90.0f;
final float SPAZIO_TRA_CARD = 24.0f;
final float LARGHEZZA_TOGGLE = 260.0f;
final float ALTEZZA_TOGGLE = 48.0f;
final float MARGINE_TOGGLE_BASSO = 45.0f;

// Palette cromatica
final color COLORE_SFONDO = color(0);
final color COLORE_BARRA_INFO = color(18, 18, 28);
final color COLORE_TESTO = color(255);
final color COLORE_SOTTOTITOLO = color(180);
final color GRADIENTE_INIZIO = color(10, 10, 30);
final color GRADIENTE_FINE = color(30, 10, 50);
final color COLORE_TOGGLE_ON = color(70, 180, 120);
final color COLORE_TOGGLE_OFF = color(140, 70, 80);

/**
 * Definisce in modo dichiarativo le modalità di visualizzazione disponibili nel menu.
 * Ogni costante incapsula l'etichetta UI, la matrice testuale del pattern e il colore ARGB.
 */
enum Modalita {
  UNO("Uno", "X", 0xFF5078DC), // RGB(80, 120, 220)
    SEI("Sei", "XX. / XXX / .XX", 0xFFDC6496), // RGB(220, 100, 150)
    NOVE("Nove", "XXX / XXX / XXX", 0xFFB46EDC), // RGB(180, 110, 220)
    VENTI("Venti", ".XXX. / XXXXX / XX.XX / XXXXX / .XXX.", 0xFF64C896); // RGB(100, 200, 150)

  final String etichetta;
  final String pattern;
  final color colore;

  /**
   * Costruttore della modalità.
   *
   * @param etichetta Nome visualizzato sulla Card del menu.
   * @param pattern   Stringa che codifica la disposizione spaziale dei quadri.
   * @param colore    Colore esadecimale ARGB associato alla Card.
   */
  Modalita(String etichetta, String pattern, color colore) {
    this.etichetta = etichetta;
    this.pattern = pattern;
    this.colore = colore;
  }

  /**
   * Restituisce il colore associato alla modalità.
   *
   * @return Valore intero color ARGB.
   */
  color getColore() {
    return colore;
  }
}

PFont font;
PGraphics sfondoMenuBuffer;
Modalita modalitaCorrente = null;
boolean sfondoAttivo = true;

Card[] menuCards;
ToggleButton toggleSfondo;

/** Lista thread-safe aggiornata tramite sostituzione atomica del riferimento (Copy-On-Write). */
volatile ArrayList<Quadro> quadri = new ArrayList<Quadro>();

/**
 * Inizializza la finestra grafica, il font di sistema, il buffer dello sfondo e i componenti del menu.
 */
void setup() {
  size(800, 800);
  noLoop();

  font = createFont(NOME_FONT, FONT_TITOLO);
  textFont(font);

  creaBufferSfondoMenu();
  inizializzaMenu();
}

/**
 * Pre-renderizza il gradiente lineare del menu su un buffer off-screen (PGraphics)
 * per ridurre la complessità di disegno del menu a O(1) per frame.
 */
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

/**
 * Calcola dinamicamente il Box Layout a griglia per le Card del menu e posiziona il ToggleButton.
 */
void inizializzaMenu() {
  Modalita[] tutteLeModalita = Modalita.values();
  int numCard = tutteLeModalita.length;
  menuCards = new Card[numCard];

  int colonne = ceil(sqrt(numCard));
  int righe = ceil((float) numCard / colonne);

  float inizioY = height * RAPPORTO_SOTTOTITOLO_Y + MARGINE_GRIGLIA_MENU * FATTORE_MARGINE_SUPERIORE_MENU;
  float fineY = height - MARGINE_TOGGLE_BASSO - ALTEZZA_TOGGLE - MARGINE_GRIGLIA_MENU * FATTORE_MARGINE_INFERIORE_MENU;
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

  float toggleX = (width - LARGHEZZA_TOGGLE) / 2.0f;
  float toggleY = height - MARGINE_TOGGLE_BASSO - ALTEZZA_TOGGLE;
  toggleSfondo = new ToggleButton(toggleX, toggleY, LARGHEZZA_TOGGLE, ALTEZZA_TOGGLE, "Sfondo quadri");
}

/**
 * Ciclo principale di rendering (eseguito solo su richiesta tramite redraw()).
 * Disegna il menu principale oppure lo snapshot immutabile dei quadri attivi.
 */
void draw() {
  if (modalitaCorrente == null) {
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

/**
 * Disegna lo sfondo pre-calcolato, le intestazioni testuali, la griglia di Card e il pulsante di opzione.
 */
void disegnaMenu() {
  image(sfondoMenuBuffer, 0, 0);

  float centroX = width / 2.0f;
  fill(COLORE_TESTO);
  textAlign(CENTER, CENTER);
  textSize(FONT_TITOLO);
  text("MENU", centroX, height * RAPPORTO_TITOLO_Y);

  textSize(FONT_SOTTOTITOLO);
  fill(COLORE_SOTTOTITOLO);
  text("Scegli il numero di quadri", centroX, height * RAPPORTO_SOTTOTITOLO_Y);

  for (Card c : menuCards) {
    c.display();
  }

  toggleSfondo.display(sfondoAttivo);
}

/**
 * Renderizza la barra informativa inferiore con le istruzioni di navigazione e rigenerazione.
 */
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
 * Analizza il pattern della modalità specificata, calcola le coordinate baricentriche
 * nell'area utile (esclusa la barra info) e pubblica atomicamente la nuova lista di Quadri.
 *
 * @param modalita La configurazione Modalita da istanziare.
 */
void generaQuadri(Modalita modalita) {
  ArrayList<Quadro> nuovaLista = new ArrayList<Quadro>();
  String[] righe = split(modalita.pattern, SEPARATORE_RIGHE);
  int dimensioneGriglia = righe.length;

  float altezzaUtile = height - ALTEZZA_BARRA_INFO;
  float areaGriglia = min(width, altezzaUtile);
  float latoCella = areaGriglia / dimensioneGriglia;
  float metaCella = latoCella / 2.0f;

  float offsetX = (width - areaGriglia) / 2.0f;
  float offsetY = (altezzaUtile - areaGriglia) / 2.0f;

  for (int r = 0; r < dimensioneGriglia; r++) {
    String rigaCorrente = trim(righe[r]);
    for (int c = 0; c < rigaCorrente.length(); c++) {
      if (rigaCorrente.charAt(c) == SIMBOLO_PIENO) {
        float x = offsetX + c * latoCella + metaCella;
        float y = offsetY + r * latoCella + metaCella;
        nuovaLista.add(new Quadro(x, y, latoCella, sfondoAttivo));
      }
    }
  }

  quadri = nuovaLista;
}

/**
 * Gestisce i clic del mouse: nel menu attiva i pulsanti; nella vista quadri rigenera il disegno.
 */
void mousePressed() {
  if (modalitaCorrente == null) {
    if (toggleSfondo.isClicked(mouseX, mouseY)) {
      sfondoAttivo = !sfondoAttivo;
      redraw();
      return;
    }

    for (Card c : menuCards) {
      if (c.isClicked(mouseX, mouseY)) {
        modalitaCorrente = c.modalita;
        generaQuadri(modalitaCorrente);
        redraw();
        break;
      }
    }
  } else {
    generaQuadri(modalitaCorrente);
    redraw();
  }
}

/**
 * Gestisce gli eventi da tastiera: 'F' riporta al menu, qualsiasi altra lettera rigenera i quadri.
 */
void keyPressed() {
  if (Character.toLowerCase(key) == TASTO_INDIETRO) {
    modalitaCorrente = null;
    redraw();
  } else if (modalitaCorrente != null && key != CODED && Character.isLetter(key)) {
    generaQuadri(modalitaCorrente);
    redraw();
  }
}
