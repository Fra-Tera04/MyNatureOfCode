// Costanti di stato
final int STATO_MENU = 0;
final int STATO_UNO = 1;
final int STATO_VENTI = 2;
final int STATO_SEI = 3;

// Costanti di configurazione e UI
final char TASTO_INDIETRO = 'f';
final char SIMBOLO_PIENO = 'X';
final String SEPARATORE_RIGHE = "/";

// Pattern compatti (N x N per mantenere celle quadrate)
final String PATTERN_SEI =
  "XX. / " +
  "XXX / " +
  ".XX";

final String PATTERN_VENTI =
  ".XXX. / " +
  "XXXXX / " +
  "XX.XX / " +
  "XXXXX / " +
  ".XXX.";

final String NOME_FONT = "SansSerif"; // Compatibile con Linux/Pop!_OS senza warning
final int FONT_TITOLO = 48;
final int FONT_SOTTOTITOLO = 16;
final int FONT_CARD = 28;
final int MARGINE_TESTO = 10;

final color COLORE_SFONDO = color(0);
final color COLORE_TESTO = color(255);
final color COLORE_SOTTOTITOLO = color(180);
final color GRADIENTE_INIZIO = color(10, 10, 30);
final color GRADIENTE_FINE = color(30, 10, 50);

PFont font;
int stato = STATO_MENU;
Card[] menuCards;

// volatile garantisce la visibilità immediata tra il thread degli eventi e il thread di draw()
volatile ArrayList<Quadro> quadri = new ArrayList<Quadro>();

void setup() {
  size(800, 800);
  noLoop();
  font = createFont(NOME_FONT, FONT_TITOLO);
  textFont(font);

  inizializzaMenu();
}

void inizializzaMenu() {
  int numCard = 3;
  menuCards = new Card[numCard];

  float latoCard = width / 4.0;
  float passo = latoCard;
  float offsetIniziale = latoCard / 2.0;

  String[] etichette = {"Uno", "Sei", "Venti"};
  int[] statiTarget = {STATO_UNO, STATO_SEI, STATO_VENTI};
  color[] colori = {
    color(80, 120, 220),
    color(220, 100, 150),
    color(100, 200, 150)
  };

  for (int i = 0; i < numCard; i++) {
    float pos = offsetIniziale + i * passo;
    menuCards[i] = new Card(pos, pos, latoCard, latoCard, etichette[i], colori[i], statiTarget[i]);
  }
}

void draw() {
  background(COLORE_SFONDO);
  if (stato == STATO_MENU) {
    disegnaMenu();
  } else {
    // Cattura un riferimento locale immutabile per questo frame: evita ConcurrentModificationException
    ArrayList<Quadro> snapshotQuadri = quadri;
    for (Quadro q : snapshotQuadri) {
      q.display();
    }
    mostraIstruzioni();
  }
}

void disegnaMenu() {
  for (int y = 0; y < height; y++) {
    float t = map(y, 0, height, 0, 1);
    stroke(lerpColor(GRADIENTE_INIZIO, GRADIENTE_FINE, t));
    line(0, y, width, y);
  }

  float centroX = width / 2.0;
  float posTitoloY = height * 0.075;
  float posSottotitoloY = height * 0.125;

  fill(COLORE_TESTO);
  textAlign(CENTER, CENTER);
  textSize(FONT_TITOLO);
  text("MENU", centroX, posTitoloY);

  textSize(FONT_SOTTOTITOLO);
  fill(COLORE_SOTTOTITOLO);
  text("Scegli il numero di quadri", centroX, posSottotitoloY);

  for (Card c : menuCards) {
    c.display();
  }
}

void mostraIstruzioni() {
  fill(COLORE_TESTO);
  textAlign(LEFT, BASELINE);
  textSize(FONT_SOTTOTITOLO);
  text("Premi " + Character.toUpperCase(TASTO_INDIETRO) + " per tornare indietro | Premi un'altra lettera per rigenerare", MARGINE_TESTO, height - MARGINE_TESTO);
}

void generaQuadri(int nuovoStato) {
  if (nuovoStato == STATO_UNO) {
    ArrayList<Quadro> nuovaLista = new ArrayList<Quadro>();
    float centroX = width / 2.0;
    float centroY = height / 2.0;
    float scalaSingola = (float) width / Quadro.DIAMETRO_BASE;
    nuovaLista.add(new Quadro(centroX, centroY, width, scalaSingola, false));
    quadri = nuovaLista; // Sostituzione atomica del riferimento
  } else if (nuovoStato == STATO_VENTI) {
    multiPattern(PATTERN_VENTI);
  } else if (nuovoStato == STATO_SEI) {
    multiPattern(PATTERN_SEI);
  }
}

void multiPattern(String pattern) {
  // Costruisce la lista off-screen prima di pubblicarla al thread di rendering
  ArrayList<Quadro> nuovaLista = new ArrayList<Quadro>();
  String[] righe = split(pattern, SEPARATORE_RIGHE.charAt(0));
  int n = righe.length;
  float latoCella = (float) width / n;
  float metaCella = latoCella / 2.0;
  float scala = latoCella / Quadro.DIAMETRO_BASE;

  for (int r = 0; r < n; r++) {
    String rigaCorrente = trim(righe[r]);
    for (int c = 0; c < rigaCorrente.length(); c++) {
      if (rigaCorrente.charAt(c) == SIMBOLO_PIENO) {
        float x = c * latoCella + metaCella;
        float y = r * latoCella + metaCella;
        nuovaLista.add(new Quadro(x, y, latoCella, scala, true));
      }
    }
  }

  quadri = nuovaLista; // Sostituzione atomica
}

void mousePressed() {
  if (stato == STATO_MENU) {
    for (Card c : menuCards) {
      if (c.isClicked(mouseX, mouseY)) {
        stato = c.targetState;
        generaQuadri(stato);
        redraw();
        break;
      }
    }
  }
}

void keyPressed() {
  if (Character.toLowerCase(key) == TASTO_INDIETRO) {
    stato = STATO_MENU;
    redraw();
  } else if (stato != STATO_MENU && key != CODED && Character.isLetter(key)) {
    generaQuadri(stato);
    redraw();
  }
}
