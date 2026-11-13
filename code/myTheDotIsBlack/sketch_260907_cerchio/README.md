# Progettazione e Sviluppo di un Generatore di Quadri Radiali in Processing 4

**Dalla struttura semplice alla programmazione a oggetti: storia, architettura e funzionamento del programma**

---

## Indice dei Capitoli

1. [Introduzione e Scopo del Progetto](#1-introduzione-e-scopo-del-progetto)
2. [Come è Nato e Cresciuto il Programma](#2-come-è-nato-e-cresciuto-il-programma)
3. [Organizzazione dell'Interfaccia Grafica](#3-organizzazione-dellinterfaccia-grafica)
4. [Come Viene Disegnato il Singolo Quadro](#4-come-viene-disegnato-il-singolo-quadro)
5. [Un Linguaggio Semplice per Creare le Griglie](#5-un-linguaggio-semplice-per-creare-le-griglie)
6. [Adattamento Automatico allo Schermo](#6-adattamento-automatico-allo-schermo)
7. [Gestione dei Comandi Rapidi e Velocità](#7-gestione-dei-comandi-rapidi-e-velocità)
8. [Idee Future: Trasformare una Foto in Quadri](#8-idee-future-trasformare-una-foto-in-quadri)
9. [Conclusioni](#9-conclusioni)

---

## 1. Introduzione e Scopo del Progetto

Questo progetto riguarda la creazione di un programma interattivo realizzato con **Processing 4** (un ambiente di programmazione basato sul linguaggio Java, pensato per creare immagini e animazioni). Lo scopo del programma è generare in modo automatico disegni geometrici circolari, chiamati _Quadri_, formati da tante linee colorate che partono dal centro come i raggi di una ruota.

Oltre all'aspetto visivo, il progetto si concentra sulla qualità del codice. L'obiettivo è stato trasformare un programma iniziale molto semplice in un sistema ordinato, facile da modificare, capire, manutenere e possibilmente ottimizzato per essere veloce. Ogni parte del codice cerca di avere un compito semplice e preciso, così da abattere gli accoppiamenti e tenere alta la coesione.

---

## 2. Come è Nato e Cresciuto il Programma

Il programma non è nato subito nella sua forma finale, ma è cresciuto attraverso diversi passaggi:

1. **La prima versione era un solo file:** All'inizio tutto il codice era scritto in un unico file. Il programma usava una varialie intera (`stato = 0, 1, 2`) per capire cosa mostrare. Poteva disegnare solo un quadro grande o una griglia fissa da 64 quadri. Il codice per disegnare era copiato due volte e il pulsante per mostrare sei quadri non funzionava.

2. **Il passaggio alla programmazione a oggetti:** Il codice è stato diviso in più file, creando le classi principali. Sono nate le prime classi per gestire i quadri e i pulsanti, è stato riparato il pulsante dei sei quadri ed è stata aggiunta la possibilità di cambiare i colori premendo un tasto della tastiera.

3. **Eliminazione dei numeri fissi:** I numeri scritti direttamente nel codice (chiamati _magic numbers_, cioè numeri di cui non si capisce subito il significato) sono stati sostituiti da costanti con nomi chiari, qui mi sono lasciato aiutare dall'ai, visionando se il risultato fosse adeguato. Le dimensioni dei quadri ora si calcolano da sole in base alla grandezza della finestra.

4. **Risoluzione degli errori di velocità e compatibilità:** Ho semper avuto questo error massager per il font "Arial", ma non era visibile alcun bug quidi ho aspettato ad aggiustarlo;l'ho sostituito con "SansSerif", uno più comune a quanto ho capito. Infine, notando un vero bug, il programma si bloccava irrimediabilmente se tenevo premuto un tasto durante la ex-funzione `venti`(in cui mostravo 64 quadri), ho dovuto usare le mie consocenze apprese durante la Triennale in informatica sull'uso dei thread in java per aggiustare, in effetti è bastato rendere il comportamento dell'accesso alla risorsa array loked.

5. **Nuovo menu a griglia e pulsante per lo sfondo:** I pulsanti del menu, prima disposti in diagonale, sono stati ordinati in una griglia centrata. È stata aggiunta una barra in basso per leggere i comandi e un pulsante per scegliere se attivare o spegnere lo sfondo colorato dietro ogni quadro.

6. **Semplificazione finale e nuovo linguaggio per le griglie:** I pulsanti del menu sono stati uniti sotto un'unica struttura base per evitare ripetizioni. È stato infine creato un sistema di comandi testuali semplici (come `"8x8; riempi"`) per disegnare griglie fino a 64 quadri senza dover scrivere lunghe sequenze a mano.

---

## 3. Organizzazione dell'Interfaccia Grafica

Per evitare di scrivere due volte lo stesso codice per i pulsanti del menu, è stata creata una struttura comune chiamata `UIElement` (una classe astratta, cioè un modello generale da cui derivano altri elementi più specifici).

- **Il modello generale (`UIElement`):** Contiene le regole che valgono per tutti i pulsanti. Salva la posizione e la grandezza del rettangolo, disegna il riquadro con gli angoli arrotondati, scrive il testo al centro e controlla se il cursore del mouse ha cliccato dentro i suoi bordi.

- **I pulsanti delle modalità (`Card`):** Usano il modello generale per mostrare le diverse scelte del menu (`Uno`, `Sei`, `Nove`, `Venti`, `64`). Prendono il nome direttamente da una lista centralizzata chiamata `Modalita` (un `enum`, cioè un elenco fisso di opzioni), mentre il colore viene pescato in modo sicuro da `PALETTE_BELLA` (una raccolta di $20$ colori esadecimali che coprono tutto lo spettro dell'arcobaleno) tramite il generatore Java `ThreadLocalRandom` (un selettore casuale sicuro per ambienti multi-thread che evita errori fuori scala).

- **Il pulsante di opzione (`ToggleButton`):** Usa lo stesso modello generale, ma cambia colore e testo ogni volta che viene cliccato, passando da verde (`SÌ`) a rosso (`NO`) per attivare o disattivare lo sfondo dei quadri.

---

## 4. Come Viene Disegnato il Singolo Quadro

La classe `Quadro` si occupa di disegnare una singola figura circolare e di adattarla allo spazio che ha a disposizione.

### Adattamento delle dimensioni

Ogni quadro nasce con una misura di riferimento fissa: il raggio massimo delle sue linee è di $350$ pixel, quindi la sua larghezza totale (il diametro) è di $700$ pixel. Quando il programma crea una griglia con tanti quadri piccoli, ogni quadro calcola da solo quanto deve rimpicciolirsi dividendo la larghezza della propria cella per $700$. In questo modo il disegno entra sempre alla perfezione nel suo spazio, senza mai uscire dai bordi.

### Creazione delle linee

Il disegno viene costruito sovrapponendo $9$ cerchi concentrici. Partendo dal centro verso l'esterno, le linee diventano via via più sottili. Per ogni livello, il programma ruota intorno al centro per tutti i $360$ gradi del cerchio e traccia una linea per ogni grado. La lunghezza e il colore di ogni singola linea vengono scelti a caso dal computer: questo crea un effetto visivo sempre nuovo ogni volta che si aggiorna il disegno.

Per evitare accostamenti cromatici sgradevoli, i colori non vengono più generati mescolando valori RGB a caso, ma estratti dalla lista `PALETTE_BELLA` (composta da $20$ tonalità bilanciate lungo l'arcobaleno, dal rosso cremisi al magenta). La funzione `getRandomNiceColor()` seleziona un colore casuale garantendo che l'indice estratto rimanga sempre strettamente compreso tra $0$ e la lunghezza massima della lista, evitando qualsiasi errore di lettura fuori intervallo.

---

## 5. Un Linguaggio Semplice per Creare le Griglie

All'inizio, per decidere dove mettere i quadri, bisognava scrivere a mano una griglia fatta di `'X'` (cella piena) e `'.'` (cella vuota). Per fare $64$ quadri bisognava scrivere sessantaquattro `'X'` divise da barre, un metodo scomodo e facile da sbagliare.

Per risolvere il problema è stata creata la funzione `valutaPattern()`, che legge un piccolo linguaggio di comandi (chiamato _DSL_, cioè un linguaggio creato apposta per un compito specifico). Ora basta scrivere la grandezza della griglia seguita da parole chiave separate da un punto e virgola:

- **`riempi`:** Riempie tutta la griglia di quadri (ad esempio `"8x8; riempi"` crea subito $64$ quadri).
- **`bordo`:** Disegna i quadri solo lungo il contorno esterno.
- **`scacchiera`:** Alterna un quadro e uno spazio vuoto, come su una scacchiera.
- **`diagonali` e `croce`:** Disegna i quadri lungo le due diagonali o lungo le linee centrali.
- **Il segno meno (`-`):** Permette di togliere quadri da una forma già creata. Ad esempio, scrivere `"5x5; riempi; -angoli; -centro"` riempie una griglia da $25$ posti e poi toglie i $4$ angoli e il centro, lasciando esattamente $20$ quadri disposti a ottagono.

Il programma rimane comunque compatibile con il vecchio metodo: se trova una barra `'/'` nel testo, capisce che si tratta di una griglia disegnata a mano (come `"XX. / XXX / .XX"`) e la legge cella per cella.

---

## 6. Adattamento Automatico allo Schermo

Tutte le parti visive si posizionano da sole in base alla grandezza della finestra, senza bisogno di calcolare le coordinate a mano:

- **Nel menu iniziale:** Il programma conta quante modalità esistono nella lista `Modalita`. Usa una formula matematica per capire quante colonne e quante righe servono per disporle in modo ordinato e le centra nello schermo, lasciando sempre lo spazio per il titolo in alto e il pulsante dello sfondo in basso.
- **Nella schermata dei quadri:** Il programma riserva una fascia in basso alta $44$ pixel per mostrare le istruzioni d'uso. Poi prende lo spazio quadrato rimasto sopra, lo divide in base al numero di righe della griglia e centra tutti i quadri. Così le istruzioni in basso restano sempre leggibili e non vengono mai coperte dai disegni.

---

## 7. Gestione dei Comandi Rapidi e Velocità

In Processing, il disegno sullo schermo e la lettura dei tasti della tastiera avvengono su due linee di lavoro separate (chiamate _thread_, cioè flussi di esecuzione paralleli). Se l'utente premeva un tasto troppo in fretta, il programma provava a cancellare la lista dei quadri proprio mentre la stava disegnando, causando un errore improvviso (`ConcurrentModificationException`).

Per risolvere questo problema, la lista dei quadri viene ora aggiornata in sicurezza:

1. Quando si preme un tasto, il programma prepara i nuovi quadri in una lista temporanea nascosta.
2. Solo quando la nuova lista è pronta, sostituisce quella vecchia in un solo istante (usando la parola chiave `volatile`, che assicura che tutte le parti del programma vedano subito il cambiamento).
3. Durante il disegno, il programma lavora su una copia fissa della lista corrente, evitando qualsiasi conflitto.

Infine, per non sprecare risorse del computer, il ciclo di disegno continuo è stato spento (`noLoop()`): lo schermo viene aggiornato solo quando l'utente clicca o preme un tasto. Inoltre, lo sfondo sfumato del menu viene disegnato una sola volta all'avvio e salvato in memoria (tramite un oggetto `PGraphics`, una sorta di tela invisibile), rendendo il passaggio tra le schermate istantaneo.

---

## 8. Idee Future: Trasformare una Foto in Quadri

La struttura attuale permette di aggiungere facilmente una funzione per creare composizioni partendo da una vera fotografia:

1. **Griglia basata sulla luminosità:** Si può caricare una foto, rimpicciolirla a una griglia di pochi pixel (ad esempio $20 \times 20$) e misurare quanto è chiaro o scuro ogni singolo punto. Dove la foto è chiara il programma inserisce un quadro, dove è scura lascia vuoto. In alternativa, può usare i colori della foto per colorare lo sfondo di ogni cella.
2. **Disegno dei contorni con sole linee:** Usando un calcolo matematico chiamato _filtro di Sobel_ (un metodo che trova i bordi delle figure confrontando le differenze di colore tra pixel vicini), il programma può individuare i contorni di un volto o di un oggetto. Invece di disegnare cerchi completi, i quadri potrebbero tracciare linee inclinate nella stessa direzione dei bordi della foto, trasformando l'immagine in un disegno astratto.

---

## 9. Conclusioni

Questo lavoro mostra come un'idea grafica semplice possa crescere fino a diventare un programma solido e ben strutturato. Dividere il codice in oggetti con compiti chiari, sostituire i numeri fissi con calcoli automatici e creare un piccolo linguaggio di comandi ha reso il software facile da capire, da usare e pronto per nuove espansioni future.
