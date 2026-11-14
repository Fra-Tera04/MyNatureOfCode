# Progettazione e Sviluppo di un Generatore di Quadri Radiali in Processing 4

**Dall'approccio procedurale all'ingegneria del software: storia, architettura Clean Code e funzionamento del sistema**

---

## Indice dei Capitoli

1. [Introduzione e Scopo del Progetto](#1-introduzione-e-scopo-del-progetto)
2. [Come è Nato e Cresciuto il Programma](#2-come-è-nato-e-cresciuto-il-programma)
3. [Architettura del Software, Clean Code e Design Pattern](#3-architettura-del-software-clean-code-e-design-pattern)
4. [Organizzazione dell'Interfaccia Grafica (`UIElement` e Derivati)](#4-organizzazione-dellinterfaccia-grafica-uielement-e-derivati)
5. [Come Viene Disegnato il Singolo Quadro (`Quadro`)](#5-come-viene-disegnato-il-singolo-quadro-quadro)
6. [Il Motore del Linguaggio per le Griglie (`PatternEngine`)](#6-il-motore-del-linguaggio-per-le-griglie-patternengine)
7. [L'Editor Interattivo e la Gestione del Cursore (`TextInputField`)](#7-leditor-interattivo-e-la-gestione-del-cursore-textinputfield)
8. [Adattamento Automatico allo Schermo e Griglie Rettangolari](#8-adattamento-automatico-allo-schermo-e-griglie-rettangolari)
9. [Gestione dei Comandi Rapidi, Thread-Safety e Performance](#9-gestione-dei-comandi-rapidi-thread-safety-e-performance)
10. [Idee Future: Estensibilità e Analisi delle Immagini](#10-idee-future-estensibilità-e-analisi-delle-immagini)
11. [Conclusioni](#11-conclusioni)

---

## 1. Introduzione e Scopo del Progetto

Questo progetto riguarda la creazione di un'applicazione interattiva realizzata con **Processing 4** (un ambiente di programmazione basato su Java, pensato per la grafica generativa e il visual design). Lo scopo del programma è generare in modo procedurale disegni geometrici circolari, chiamati _Quadri_, formati da centinaia di segmenti radiali colorati che partono dal centro come i raggi di una ruota.

Oltre all'aspetto visivo, il progetto rappresenta un caso di studio pratico sull'applicazione dei principi di **Ingegneria del Software** e **Clean Code**. L'obiettivo centrale è stato trasformare uno sketch iniziale monolitico in un'architettura modulare caratterizzata da:

- **Alta Coesione (_High Cohesion_):** Ogni file e ogni classe ha una singola responsabilità ben definita (_Single Responsibility Principle_ - SRP).
- **Basso Accoppiamento (_Low Coupling_):** Il motore logico che calcola le matrici geometriche non conosce nulla dei pulsanti, dei colori o della finestra di Processing, rendendo i moduli indipendenti, testabili e facilmente estensibili in futuro.

---

## 2. Come è Nato e Cresciuto il Programma

Il programma si è evoluto attraverso sette iterazioni incrementali:

1. **La prima versione in un solo file:** All'inizio tutto il codice era scritto in un unico file procedurale. Il programma usava numeri interi (`stato = 0, 1, 2`) per capire cosa mostrare, presentava codice duplicato e il pulsante per mostrare sei quadri non funzionava.
2. **Il passaggio alla programmazione a oggetti:** Il codice è stato diviso in più file creando le prime classi (`Quadro`, `Card`), riparando il pulsante dei sei quadri e aggiungendo la rigenerazione tramite tastiera.
3. **Eliminazione dei _magic numbers_ e creazione della paletta:** I valori numerici arbitrari sono stati sostituiti da costanti semantiche (`final`). È stata introdotta la paletta armonica `PALETTE_BELLA` composta da $20$ colori esadecimali lungo tutto lo spettro dell'arcobaleno, selezionati in modo statisticamente uniforme tramite `ThreadLocalRandom`.
4. **Risoluzione degli errori di concorrenza e compatibilità:** Il font "Arial" è stato sostituito con "SansSerif" per garantire la compatibilità su sistemi Linux. Inoltre, è stato eliminato il crash da `ConcurrentModificationException` che si verificava premendo rapidamente i tasti della tastiera.
5. **Nuovo menu a griglia e opzioni di sfondo:** I pulsanti del menu sono stati disposti in una griglia auto-centrante, affiancati da una barra informativa inferiore e da un pulsante `ToggleButton` per attivare o disattivare lo sfondo dei quadri.
6. **Introduzione dell'Editor Interattivo e Griglie Rettangolari:** È stata creata una schermata dedicata dove l'utente può scrivere il proprio pattern da tastiera, muovere il cursore con il mouse o con le frecce, creare anelli concentrici sottraendo blocchi dal baricentro (es. `"8x8; -6x6; 2x2"`) e definire griglie rettangolari (es. `"4x2"`).
7. **Rifattorizzazione Architetturale e Clean Code:** Il file principale è stato snellito trasformandolo in un puro coordinatore basato sulla macchina a stati esplicita `StatoApp`. L'interprete del linguaggio è stato isolato nella classe di dominio `PatternEngine` (affiancata dal Value Object `RisultatoValidazione`), mentre la casella di testo interattiva è diventata un componente autonomo (`TextInputField`) all'interno della gerarchia `UIElement`.

---

## 3. Architettura del Software, Clean Code e Design Pattern

Per evitare la sovra-ingegnerizzazione (_over-engineering_) ma garantire al contempo una struttura professionale e pronta per estensioni future, la codebase è stata suddivisa in **6 tab distinte**, applicando mirati pattern progettuali:

| File / Tab                    | Ruolo Architetturale            | Responsabilità Principale (Alta Coesione)                                                                                                    |
| :---------------------------- | :------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------- |
| `sketch_260907_cerchio.pde`   | **Controller / State Machine**  | Gestisce il ciclo di vita (`setup`, `draw`), smista gli eventi in base a `StatoApp` e coordina il layout delle viste.                        |
| `PatternEngine.pde`           | **Domain Model / Interpreter**  | Analizza, valida (`RisultatoValidazione`) e compila le stringhe del DSL in matrici booleane `boolean[][]`, senza alcuna dipendenza dalla UI. |
| `UIElement.pde`               | **Base View Component**         | Classe astratta che fattorizza posizionamento, rendering del box e rilevamento collisioni (_AABB_) per tutti i controlli grafici.            |
| `Card.pde`                    | **Specialized UI Controls**     | Contiene `Card` (pulsanti collegati alle modalità predefinite) e `ToggleButton` (interruttori booleani `SÌ`/`NO`).                           |
| `ActionButton.pde`            | **Interactive UI Controls**     | Contiene `ActionButton` (pulsanti di navigazione/conferma) e `TextInputField` (casella di testo editabile con gestione del cursore).         |
| `Modalita.pde` & `Quadro.pde` | **Data Configuration & Entity** | `Modalita` incapsula i preset del menu e la paletta cromatica; `Quadro` gestisce la geometria radiale del singolo elemento visivo.           |

### I Design Pattern adottati (e perché valgono la pena)

1. **Template Method & Gerarchia Polimorfica (`UIElement`):** Invece di duplicare i calcoli geometrici per verificare se il mouse ha cliccato un bottone (`isClicked`) o per disegnare rettangoli smussati (`disegnaBox`), la classe astratta `UIElement` fornisce i mattoni base a `Card`, `ToggleButton`, `ActionButton` e `TextInputField`.
2. **Explicit Finite State Machine (`enum StatoApp`):** Sostituisce le fragili combinazioni di variabili booleane (`editorAperto`, `patternAttivo == null`) con tre stati mutuamente esclusivi (`MENU`, `EDITOR`, `QUADRI`). In questo modo `draw()`, `mousePressed()` e `keyPressed()` eseguono un semplice `switch (statoCorrente)` delegando subito il lavoro a metodi brevi e specializzati (`gestisciMouseMenu()`, `gestisciMouseEditor()`, ecc.).
3. **Value Object Immutabile (`RisultatoValidazione`):** Invece di far modificare variabili globali al validatore (effetto collaterale che crea forte accoppiamento), il metodo `patternEngine.valida(testo)` restituisce un oggetto immutabile contenente il booleano `valido` e la stringa `messaggio`.
4. **Principio _Don't Repeat Yourself_ (DRY) nel Rendering:** Le due grandi schede informative dell'editor non sono più disegnate copiando e incollando 40 righe di codice grafico, ma richiamando due volte il metodo parametrico `disegnaSchedaGuida(...)`.

---

## 4. Organizzazione dell'Interfaccia Grafica (`UIElement` e Derivati)

Tutti gli elementi cliccabili dell'interfaccia derivano dalla classe astratta `UIElement`:

- **Il modello generale (`UIElement`):** Salva le coordinate immutabili (`x, y, w, h`), disegna il riquadro con angoli arrotondati, centra le etichette testuali e implementa il test di collisione _Axis-Aligned Bounding Box_ (`isClicked`).
- **I pulsanti delle modalità (`Card`):** Mostrano le scelte predefinite del menu (`Uno`, `Sei`, `Nove`, `Venti`, `64`). Estraggono i colori dalla costante `PALETTE_BELLA` definita in `Modalita` (una raccolta di $20$ colori esadecimali ARGB ordinati lungo l'arcobaleno) usando `ThreadLocalRandom.current().nextInt(PALETTE_BELLA.length)`, che garantisce una distribuzione uniforme sull'intero array senza mai rischiare errori fuori scala.
- **Il pulsante di opzione (`ToggleButton`) e i pulsanti d'azione (`ActionButton`):** Gestiscono rispettivamente lo stato attivo/inattivo dello sfondo dietro i quadri e le azioni di navigazione (`Pattern Custom`, `Annulla`, `Genera Quadri`).

---

## 5. Come Viene Disegnato il Singolo Quadro (`Quadro`)

La classe `Quadro` ha l'unica responsabilità di disegnare una figura circolare generativa all'interno della cella assegnata.

### Adattamento omotetico delle dimensioni

Ogni quadro possiede un raggio massimo interno di riferimento pari a $350$ pixel, corrispondente a un diametro base (`DIAMETRO_BASE`) di $700$ pixel. Quando viene istanziato dentro una griglia, calcola automaticamente il proprio fattore di scala:
$$\text{scala} = \frac{\text{lato}}{700.0}$$
Applicando la trasformazione `scale(scala)` nello spazio locale del quadro (`pushMatrix()` / `popMatrix()`), lo stesso identico algoritmo grafico può essere disegnato a schermo intero ($1 \times 1$) oppure miniaturizzato in una griglia $25 \times 25$ senza perdere proporzioni.

### Creazione dei livelli concentrici

Il disegno sovrappone $9$ anelli concentrici. Partendo dal centro verso l'esterno, lo spessore del tratto diminuisce progressivamente (`LIVELLI_CONCENTRICI - n`). Per ciascuno dei $360$ gradi dell'angolo giro viene tracciato un segmento radiale con estremi casuali compresi tra `RAGGIO_MIN` ($50$), `RAGGIO_MEDIO` ($150$) e `RAGGIO_MAX` ($350$).

---

## 6. Il Motore del Linguaggio per le Griglie (`PatternEngine`)

La classe `PatternEngine` incapsula l'interprete del _Domain-Specific Language_ (DSL) ideato per descrivere le griglie. È completamente disaccoppiata dalla grafica: riceve in ingresso una `String` e restituisce una matrice booleana `boolean[righe][colonne]` (per il calcolo) oppure un oggetto `RisultatoValidazione` (per la verifica sintattica).

Il motore normalizza automaticamente i caratteri (convertendo anche eventuali trattini lunghi Unicode `–` o `—` nel segno meno standard `-`) e supporta due paradigmi:

### 1. Modalità Comandi Dichiarativi (`<Colonne>x<Righe>; cmd1; cmd2; ...`)

Il primo blocco definisce le dimensioni della griglia $C \times R$ (da $1 \times 1$ fino a $25 \times 25$, incluse griglie rettangolari come `"4x2"` o `"2x4"`). I token successivi vengono smistati da uno `switch` verso funzioni geometriche dedicate:

- **Riempimento implicito:** Se l'utente scrive solo le dimensioni (es. `"16x16"` o `"4x2"`), il motore applica automaticamente `applicaComandoRiempi(griglia, true)`.
- **Parole chiave geometriche:**
  - `riempi`: seleziona tutte le celle della matrice.
  - `bordo`: seleziona il perimetro esterno ($r = 0$, $r = R - 1$, $c = 0$, $c = C - 1$).
  - `scacchiera`: attiva le celle a parità uniforme ($(r + c) \pmod 2 = 0$).
  - `diagonali`: traccia le diagonali principali della matrice.
  - `croce`: attiva la riga mediana ($R / 2$) e la colonna mediana ($C / 2$) in tempo lineare $O(R + C)$.
  - `centro` e `angoli`: attivano rispettivamente la cella mediana e i quattro vertici esterni in tempo costante $O(1)$.
- **Operatore di sottrazione (`-`):** Qualsiasi comando o sotto-griglia preceduto dal simbolo `-` imposta le celle bersaglio a `false` (vuoto). Se la prima istruzione dopo le dimensioni è una sottrazione (es. `"16x16; -8x8"`), `PatternEngine` parte automaticamente da una griglia tutta piena prima di scavare il blocco indicato.
- **Sotto-griglie concentriche dal baricentro (`applicaSubGrigliaCentrata`):** Scrivendo una dimensione $subC \times subR$ come comando (es. `"8x8; -6x6; 2x2"` oppure `"8x8; -6x6; 1x1"`), il motore calcola le coordinate continue del baricentro della matrice:
  $$c_{\text{centro}} = \frac{C - 1}{2.0}, \qquad r_{\text{centro}} = \frac{R - 1}{2.0}$$
  Se la parità della griglia principale e quella del sotto-blocco sono diverse (es. un blocco dispari `1x1` dentro una griglia pari `8x8`), il centro viene traslato di $0.5$ unità per allinearsi perfettamente alla cella mediana intera. Una cella $(r, c)$ viene modificata se e solo se la sua distanza dal centro è strettamente minore della semidimensione del blocco:
  $$|c - c_{\text{centro}}| < \frac{subC}{2.0} \quad \land \quad |r - r_{\text{centro}}| < \frac{subR}{2.0}$$

### 2. Modalità Disegno Manuale (`X`, `.` e `/`)

Se la stringa contiene il separatore `'/'`, `PatternEngine` attiva `compilaGrigliaManuale()`, che costruisce la matrice riga per riga interpretando `'X'` come cella piena e `'.'` come cella vuota, verificando che tutte le righe abbiano lo stesso numero di colonne.

---

## 7. L'Editor Interattivo e la Gestione del Cursore (`TextInputField`)

Per evitare di inquinare il file principale con calcoli sui pixel del testo e manipolazioni di sottostringhe, la casella di input dell'editor è stata trasformata nella classe `TextInputField` (estensione di `UIElement`).

Questo componente gestisce internamente:

- **Inserimento e Cancellazione Mid-String:** Mantiene un puntatore intero `indiceCursore` compreso tra $0$ e `testo.length()`. Ogni carattere digitato viene inserito esattamente nella posizione del cursore dividendo la stringa in due parti; supporta sia `BACKSPACE` (cancella a sinistra del cursore) sia `DELETE` (cancella a destra del cursore).
- **Navigazione da Tastiera:** Permette di scorrere lungo la formula con le frecce `LEFT` e `RIGHT` o di saltare istantaneamente agli estremi con i tasti `HOME` ed `END`.
- **Posizionamento tramite Clic del Mouse (`aggiornaCursoreDaMouse`):** Quando l'utente clicca dentro la casella di testo, il componente misura la larghezza in pixel delle sottostringhe progressive tramite `textWidth()` e confronta la coordinata $X$ del clic con il punto medio di ciascun carattere:
  $$\text{puntoMedio}_i = \frac{\text{textWidth}(S_{0..i}) + \text{textWidth}(S_{0..i+1})}{2.0}$$
  posizionando la barra verticale del cursore esattamente tra le due lettere cliccate.

---

## 8. Adattamento Automatico allo Schermo e Griglie Rettangolari

Tutte le schermate calcolano le proprie coordinate in modo responsivo rispetto a `width` e `height`:

- **Griglia del Menu:** Calcola il numero ottimale di righe e colonne in base al numero di costanti presenti in `Modalita`, centrando le `Card` nello spazio verticale compreso tra il sottotitolo e i pulsanti inferiori.
- **Griglia dei Quadri (Quadrata e Rettangolare):** Per supportare qualsiasi matrice $C \times R$ (es. `4x2`, `2x4` o `16x16`) mantenendo ogni cella perfettamente quadrata e senza mai uscire dallo schermo, il lato della singola cella viene calcolato come il minimo tra il rapporto orizzontale e quello verticale:
  $$\text{latoCella} = \min\left(\frac{\text{width}}{C}, \frac{\text{height} - \text{ALTEZZA\_BARRA\_INFO}}{R}\right)$$
  La griglia complessiva di dimensioni $(C \cdot \text{latoCella}) \times (R \cdot \text{latoCella})$ viene poi centrata orizzontalmente e verticalmente tramite gli offset `offsetX` e `offsetY`.

---

## 9. Gestione dei Comandi Rapidi, Thread-Safety e Performance

In Processing, il ciclo di disegno (`draw`) e gli eventi di input (`keyPressed`, `mousePressed`) vengono eseguiti su thread differenti (rispettivamente l'_Animation Thread_ e l'_Event Dispatch Thread_). Per garantire la massima stabilità anche tenendo premuto un tasto per rigenerare continuamente griglie da centinaia di quadri:

1. **Costruzione isolata (Shadow Copy):** Il metodo `generaQuadriDaPattern()` istanzia tutti i nuovi oggetti `Quadro` dentro una lista locale temporanea (`nuovaLista`).
2. **Scambio atomico del riferimento:** Solo a costruzione ultimata, il riferimento globale `volatile ArrayList<Quadro> quadri` viene sostituito con `quadri = nuovaLista`.
3. **Lettura su Snapshot locale:** Il metodo `disegnaVistaQuadri()` copia il riferimento in una variabile locale `snapshotQuadri` prima di iterare, rendendo impossibile qualsiasi conflitto di concorrenza.
4. **Zero carico CPU a riposo:** L'uso combinato di `noLoop()`, `redraw()` su evento e del buffer pre-renderizzato `sfondoMenuBuffer` (`PGraphics`) azzera il consumo di risorse quando l'utente non interagisce con la finestra.

---

## 10. Idee Future: Estensibilità e Analisi delle Immagini

L'isolamento del `PatternEngine` e il disaccoppiamento dell'architettura rendono il sistema immediatamente pronto per nuove funzionalità:

1. **Generatore da Immagini (Soglia di Luminosità):** Poiché `generaQuadriDaPattern()` richiede semplicemente una matrice `boolean[][]`, sarà possibile affiancare a `PatternEngine` una classe `ImagePatternGenerator` che carichi una fotografia (`PImage`), la ridimensioni a $C \times R$ pixel e restituisca `true` per i pixel la cui luminosità supera una soglia definita.
2. **Orientamento Vettoriale tramite Filtro di Sobel:** Passando a ciascun `Quadro` l'angolo del gradiente luminoso calcolato sull'immagine, i segmenti radiali potranno addensarsi lungo la direzione dei contorni reali della foto.
3. **Salvataggio di Preset Utente:** Grazie alla separazione dei dati, i pattern scritti nell'editor potranno essere salvati su file `.json` o `.txt` e caricati dinamicamente come nuove `Card` all'avvio.

---

## 11. Conclusioni

L'evoluzione di questo progetto dimostra come i principi di **Clean Code**, l'incapsulamento dei componenti grafici (`UIElement`, `TextInputField`), la separazione del dominio logico (`PatternEngine`) e l'uso di una macchina a stati esplicita (`StatoApp`) permettano di trasformare uno sketch creativo in un software solido, leggibile, privo di bug di concorrenza e semplice da mantenere nel tempo.
