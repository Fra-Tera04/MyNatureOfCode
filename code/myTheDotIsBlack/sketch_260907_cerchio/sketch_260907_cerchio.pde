// Costanti di input e sintassi pattern
final char TASTO_INDIETRO = 'f';
final char SIMBOLO_PIENO = 'X';
final char SEPARATORE_RIGHE = '/';

// Tipografia e layout
final String NOME_FONT = "SansSerif";
final int FONT_TITOLO = 44;
final int FONT_SOTTOTITOLO = 16;
final int FONT_CARD = 26;
final int FONT_TOGGLE = 18;

final float RAPPORTO_TITOLO_Y = 0.07;
final float RAPPORTO_SOTTOTITOLO_Y = 0.12;
final float ALTEZZA_BARRA_INFO = 44;
final float MARGINE_GRIGLIA_MENU = 90;
final float SPAZIO_TRA_CARD = 24;
final float LARGHEZZA_TOGGLE = 260;
final float ALTEZZA_TOGGLE = 48;
final float MARGINE_TOGGLE_BASSO = 45;

// Palette
final color COLORE_SFONDO = color(0);
final color COLORE_BARRA_INFO = color(18, 18, 28);
final color COLORE_TESTO = color(255);
final color COLORE_SOTTOTITOLO = color(180);
final color GRADIENTE_INIZIO = color(10, 10, 30);
final color GRADIENTE_FINE = color(30, 10, 50);
final color COLORE_TOGGLE_ON = color(70, 180, 120);
final color COLORE_TOGGLE_OFF = color(140, 70, 80);

enum Modalita {
  UNO("Uno", "X", true, 0xFF5078DC), // RGB(80, 120, 220)
    SEI("Sei", "XX. / XXX / .XX", true, 0xFFDC6496), // RGB(220, 100, 150)
    NOVE("Nove", "XXX / XXX / XXX", true, 0xFFDC6496),
    VENTI("Venti", ".XXX. / XXXXX / XX.XX / XXXXX / .XXX.", true, 0xFF64C896); // RGB(100, 200, 150)

  final String etichetta;
  final String pattern;
  final boolean haSfondo;
  color colorr;

  Modalita(String etichetta, String pattern, boolean haSfondo, color c) {
    this.etichetta = etichetta;
    this.pattern = pattern;
    this.haSfondo = haSfondo;
    this.colorr = c;
  }

  color getColore() {
    return colorr;
  }
}

PFont font;
PGraphics sfondoMenuBuffer;
Modalita modalitaCorrente = null;
boolean sfondoAttivo = true;

Card[] menuCards;
ToggleButton toggleSfondo;

volatile ArrayList<Quadro> quadri = new ArrayList<Quadro>();

void setup() {
  size(800, 800);
  noLoop();

  font = createFont(NOME_FONT, FONT_TITOLO);
  textFont(font);

  creaBufferSfondoMenu();
  inizializzaMenu();
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

  // Calcolo dinamico della griglia (righe e colonne)
  int colonne = ceil(sqrt(numCard));
  int righe = ceil((float) numCard / colonne);

  float inizioY = height * RAPPORTO_SOTTOTITOLO_Y + MARGINE_GRIGLIA_MENU * 0.6;
  float fineY = height - MARGINE_TOGGLE_BASSO - ALTEZZA_TOGGLE - MARGINE_GRIGLIA_MENU * 0.5;
  float areaDispW = width - MARGINE_GRIGLIA_MENU * 2.0;
  float areaDispH = fineY - inizioY;

  float cellaW = (areaDispW - SPAZIO_TRA_CARD * (colonne - 1)) / colonne;
  float cellaH = (areaDispH - SPAZIO_TRA_CARD * (righe - 1)) / righe;
  float latoCard = min(cellaW, cellaH);

  // Centratura effettiva della griglia delle card
  float larghezzaTotale = colonne * latoCard + (colonne - 1) * SPAZIO_TRA_CARD;
  float altezzaTotale = righe * latoCard + (righe - 1) * SPAZIO_TRA_CARD;
  float startX = (width - larghezzaTotale) / 2.0;
  float startY = inizioY + (areaDispH - altezzaTotale) / 2.0;

  for (int i = 0; i < numCard; i++) {
    int col = i % colonne;
    int riga = i / colonne;
    float x = startX + col * (latoCard + SPAZIO_TRA_CARD);
    float y = startY + riga * (latoCard + SPAZIO_TRA_CARD);
    menuCards[i] = new Card(x, y, latoCard, latoCard, tutteLeModalita[i]);
  }

  // Pulsante impostazione sfondo centrato in basso
  float toggleX = (width - LARGHEZZA_TOGGLE) / 2.0;
  float toggleY = height - MARGINE_TOGGLE_BASSO - ALTEZZA_TOGGLE;
  toggleSfondo = new ToggleButton(toggleX, toggleY, LARGHEZZA_TOGGLE, ALTEZZA_TOGGLE, "Sfondo quadri");
}

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

void disegnaMenu() {
  image(sfondoMenuBuffer, 0, 0);

  float centroX = width / 2.0;
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

void mostraIstruzioni() {
  float barraY = height - ALTEZZA_BARRA_INFO;

  noStroke();
  rectMode(CORNER);
  fill(COLORE_BARRA_INFO);
  rect(0, barraY, width, ALTEZZA_BARRA_INFO);

  fill(COLORE_TESTO);
  textAlign(CENTER, CENTER);
  textSize(FONT_SOTTOTITOLO);
  String testo = "Premi " + Character.toUpperCase(TASTO_INDIETRO) + " per tornare al menu  |  Premi un'altra lettera per rigenerare";
  text(testo, width / 2.0, barraY + ALTEZZA_BARRA_INFO / 2.0);
}

void generaQuadri(Modalita modalita) {
  ArrayList<Quadro> nuovaLista = new ArrayList<Quadro>();
  String[] righe = split(modalita.pattern, SEPARATORE_RIGHE);
  int dimensioneGriglia = righe.length;

  // Area utile escludendo la barra delle istruzioni in basso
  float altezzaUtile = height - ALTEZZA_BARRA_INFO;
  float areaGriglia = min(width, altezzaUtile);
  float latoCella = areaGriglia / dimensioneGriglia;
  float metaCella = latoCella / 2.0;

  // Offset per centrare perfettamente la griglia nell'area utile
  float offsetX = (width - areaGriglia) / 2.0;
  float offsetY = (altezzaUtile - areaGriglia) / 2.0;

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
  } else
  {
    generaQuadri(modalitaCorrente);
    redraw();
  }
}

void keyPressed() {
  if (Character.toLowerCase(key) == TASTO_INDIETRO) {
    modalitaCorrente = null;
    redraw();
  } else if (modalitaCorrente != null && key != CODED && Character.isLetter(key)) {
    generaQuadri(modalitaCorrente);
    redraw();
  }
}
