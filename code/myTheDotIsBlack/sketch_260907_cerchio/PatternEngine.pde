import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * Value Object immutabile che incapsula l'esito della validazione di un pattern.
 */
class RisultatoValidazione {
  final boolean valido;
  final String messaggio;

  RisultatoValidazione(boolean valido, String messaggio) {
    this.valido = valido;
    this.messaggio = messaggio;
  }
}

/**
 * Motore di dominio per la validazione e la compilazione del Domain-Specific Language (DSL)
 * in matrici booleane [righe][colonne], totalmente indipendente dall'interfaccia grafica.
 */
class PatternEngine {
  static final char SIMBOLO_PIENO = 'X';
  static final char SIMBOLO_VUOTO = '.';
  static final char SEPARATORE_RIGHE = '/';
  static final int DIM_GRIGLIA_MIN = 1;
  static final int DIM_GRIGLIA_MAX = 25;

  final Set<String> comandiValidi = new HashSet<String>(
    Arrays.asList("riempi", "bordo", "scacchiera", "diagonali", "croce", "centro", "angoli")
    );

  /**
   * Verifica la correttezza sintattica e geometrica del pattern inserito dall'utente.
   */
  RisultatoValidazione valida(String inputRaw) {
    String normalizzato = normalizzaTrattini(inputRaw);
    String pulito = trim(normalizzato).toLowerCase();

    if (pulito.isEmpty()) {
      return new RisultatoValidazione(false, "Errore: il pattern non può essere vuoto.");
    }

    if (pulito.contains(String.valueOf(SEPARATORE_RIGHE))) {
      return validaGrigliaManuale(normalizzato);
    }
    return validaComandiDichiarativi(normalizzato, pulito);
  }

  /**
   * Compila una stringa DSL valida in una matrice booleana [righe][colonne].
   */
  boolean[][] valutaPattern(String patternRaw) {
    String normalizzato = normalizzaTrattini(patternRaw);
    String pulito = trim(normalizzato).toLowerCase();

    if (pulito.contains(String.valueOf(SEPARATORE_RIGHE))) {
      return compilaGrigliaManuale(trim(normalizzato));
    }

    String[] istruzioni = split(pulito, ';');
    int[] dims = parseDimensioni(istruzioni[0]);
    int colonne = dims[0];
    int righe = dims[1];
    boolean[][] griglia = new boolean[righe][colonne];

    ArrayList<String> comandi = estraiComandi(istruzioni);

    if (comandi.isEmpty()) {
      applicaComandoRiempi(griglia, true);
      return griglia;
    }

    if (comandi.get(0).startsWith("-")) {
      applicaComandoRiempi(griglia, true);
    }

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

  private RisultatoValidazione validaGrigliaManuale(String input) {
    String[] righeArr = split(trim(input), SEPARATORE_RIGHE);
    int numRighe = righeArr.length;
    if (numRighe < DIM_GRIGLIA_MIN || numRighe > DIM_GRIGLIA_MAX) {
      return new RisultatoValidazione(false, "Errore: le righe devono essere tra " + DIM_GRIGLIA_MIN + " e " + DIM_GRIGLIA_MAX + ".");
    }

    int numColonne = trim(righeArr[0]).length();
    if (numColonne < DIM_GRIGLIA_MIN || numColonne > DIM_GRIGLIA_MAX) {
      return new RisultatoValidazione(false, "Errore: le colonne devono essere tra " + DIM_GRIGLIA_MIN + " e " + DIM_GRIGLIA_MAX + ".");
    }

    int cellePiene = 0;
    for (int r = 0; r < numRighe; r++) {
      String riga = trim(righeArr[r]);
      if (riga.length() != numColonne) {
        return new RisultatoValidazione(false, "Errore riga " + (r + 1) + ": servono " + numColonne + " colonne (trovate " + riga.length() + ").");
      }
      for (int c = 0; c < numColonne; c++) {
        char ch = Character.toUpperCase(riga.charAt(c));
        if (ch != SIMBOLO_PIENO && ch != SIMBOLO_VUOTO) {
          return new RisultatoValidazione(false, "Errore: carattere non valido '" + riga.charAt(c) + "'. Usa solo X e .");
        }
        if (ch == SIMBOLO_PIENO) cellePiene++;
      }
    }

    if (cellePiene == 0) {
      return new RisultatoValidazione(false, "Attenzione: il pattern non contiene nessun quadro ('X').");
    }
    return new RisultatoValidazione(true, "Pattern manuale valido (" + numColonne + "x" + numRighe + ", " + cellePiene + " quadri).");
  }

  private RisultatoValidazione validaComandiDichiarativi(String inputOriginale, String pulito) {
    String[] istruzioni = split(pulito, ';');
    int[] dims = parseDimensioni(istruzioni[0]);
    if (dims == null) {
      return new RisultatoValidazione(false, "Errore: usa formato Colonne x Righe tra " + DIM_GRIGLIA_MIN + " e " + DIM_GRIGLIA_MAX + " (es. 4x2 o 16x16).");
    }

    int colonne = dims[0];
    int righe = dims[1];
    ArrayList<String> comandi = estraiComandi(istruzioni);

    for (String rawCmd : comandi) {
      String cmd = rawCmd.startsWith("-") ? trim(rawCmd.substring(1)) : rawCmd;
      int[] subDims = parseDimensioni(cmd);

      if (subDims != null) {
        if (subDims[0] > colonne || subDims[1] > righe) {
          return new RisultatoValidazione(false, "Errore: il blocco '" + cmd + "' supera la griglia " + colonne + "x" + righe + ".");
        }
      } else if (!comandiValidi.contains(cmd)) {
        return new RisultatoValidazione(false, "Comando sconosciuto: '" + cmd + "'.");
      }
    }

    boolean[][] test = valutaPattern(inputOriginale);
    int attivi = contaCelleAttive(test);
    if (attivi == 0) {
      return new RisultatoValidazione(false, "Attenzione: il pattern risultante è vuoto (0 quadri).");
    }

    String notaImplicita = comandi.isEmpty() ? " - riempimento automatico" : "";
    return new RisultatoValidazione(true, "Pattern valido (" + colonne + " col x " + righe + " righe, " + attivi + " quadri" + notaImplicita + ").");
  }

  private String normalizzaTrattini(String s) {
    return (s == null) ? "" : s.replace('–', '-').replace('—', '-');
  }

  private int[] parseDimensioni(String token) {
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

  private ArrayList<String> estraiComandi(String[] istruzioni) {
    ArrayList<String> lista = new ArrayList<String>();
    for (int i = 1; i < istruzioni.length; i++) {
      String token = trim(istruzioni[i]);
      if (!token.isEmpty()) {
        lista.add(token);
      }
    }
    return lista;
  }

  private int contaCelleAttive(boolean[][] griglia) {
    int count = 0;
    for (int r = 0; r < griglia.length; r++) {
      for (int c = 0; c < griglia[0].length; c++) {
        if (griglia[r][c]) count++;
      }
    }
    return count;
  }

  private boolean[][] compilaGrigliaManuale(String pattern) {
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

  private void applicaSubGrigliaCentrata(boolean[][] griglia, int subC, int subR, boolean valore) {
    int righe = griglia.length;
    int colonne = griglia[0].length;

    float centroC = (colonne - 1) / 2.0f;
    float centroR = (righe - 1) / 2.0f;

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

  private void applicaComandoRiempi(boolean[][] griglia, boolean valore) {
    for (int r = 0; r < griglia.length; r++) {
      for (int c = 0; c < griglia[0].length; c++) {
        griglia[r][c] = valore;
      }
    }
  }

  private void applicaComandoBordo(boolean[][] griglia, boolean valore) {
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

  private void applicaComandoScacchiera(boolean[][] griglia, boolean valore) {
    for (int r = 0; r < griglia.length; r++) {
      for (int c = 0; c < griglia[0].length; c++) {
        if ((r + c) % 2 == 0) {
          griglia[r][c] = valore;
        }
      }
    }
  }

  private void applicaComandoDiagonali(boolean[][] griglia, boolean valore) {
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

  private void applicaComandoCentro(boolean[][] griglia, boolean valore) {
    griglia[griglia.length / 2][griglia[0].length / 2] = valore;
  }

  private void applicaComandoAngoli(boolean[][] griglia, boolean valore) {
    int maxR = griglia.length - 1;
    int maxC = griglia[0].length - 1;
    griglia[0][0] = valore;
    griglia[0][maxC] = valore;
    griglia[maxR][0] = valore;
    griglia[maxR][maxC] = valore;
  }

  private void applicaComandoCroce(boolean[][] griglia, boolean valore) {
    int righe = griglia.length;
    int colonne = griglia[0].length;
    int rCentro = righe / 2;
    int cCentro = colonne / 2;

    for (int c = 0; c < colonne; c++) griglia[rCentro][c] = valore;
    for (int r = 0; r < righe; r++) griglia[r][cCentro] = valore;
  }
}
