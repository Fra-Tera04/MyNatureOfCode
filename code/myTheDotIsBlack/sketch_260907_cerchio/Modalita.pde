import java.util.concurrent.ThreadLocalRandom;

/**
 * Definisce in modo dichiarativo le modalità di visualizzazione disponibili nel menu.
 * Ogni costante incapsula l'etichetta UI, la matrice testuale del pattern e il colore ARGB.
 */
enum Modalita {
  UNO("Uno", "1x1; riempi", 123),
    SEI("Sei", "XX. / XXX / .XX", 0xFF8338EC),
    NOVE("Nove", "3x3; riempi", 0xFFFF006E),
    VENTI("Venti", "5x5; riempi; -angoli; -centro", 0xFFFFBE0B),
    SESSANTAQUATTRO("64", "8x8; riempi", 0xFF06D6A0);

  final String etichetta;
  final String pattern;
  final color colore;

  // Paletta di colori armonici (formato ARGB)
  static final color[] PALETTE_BELLA = {
    0xFFFF2A5F, // Rosso Cremisi
    0xFFFF4D4D, // Rosso Corallo
    0xFFFF6B35, // Arancione Fuoco
    0xFFFF8C42, // Arancione Mandarino
    0xFFFFA62B, // Ambra Caldo
    0xFFFFBE0B, // Giallo Ambra
    0xFFFFD60A, // Giallo Limone
    0xFFE2F126, // Giallo Lime
    0xFFB5E48C, // Verde Germoglio
    0xFF76C893, // Verde Prato
    0xFF06D6A0, // Verde Menta
    0xFF00B4D8, // Turchese Chiaro
    0xFF0096C7, // Azzurro Ceruleo
    0xFF3A86FF, // Blu Elettrico
    0xFF4361EE, // Blu Cobalto
    0xFF5E60CE, // Indaco Reale
    0xFF8338EC, // Viola Indaco
    0xFF9D4EDD, // Viola Ametista
    0xFFC77DFF, // Lavanda Acceso
    0xFFFF006E  // Magenta Neon
  };

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
    return getRandomNiceColor();
  }

  /**
   * Seleziona e restituisce un colore casuale dalla paletta predefinita.
   *
   * @return Un valore color ARGB armonico.
   */
  color getRandomNiceColor() {
    int indice = ThreadLocalRandom.current().nextInt(PALETTE_BELLA.length);
    return PALETTE_BELLA[indice];
  }
}
