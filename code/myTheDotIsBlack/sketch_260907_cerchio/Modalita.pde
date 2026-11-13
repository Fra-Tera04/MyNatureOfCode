/**
 * Definisce in modo dichiarativo le modalità di visualizzazione disponibili nel menu.
 * Ogni costante incapsula l'etichetta UI, la matrice testuale del pattern e il colore ARGB.
 */
enum Modalita {
  UNO("Uno", "1x1; riempi", 0xFF5078DC),
    SEI("Sei", "XX. / XXX / .XX", 0xFFDC6496),
    NOVE("Nove", "3x3; riempi", 0xFFB46EDC),
    VENTI("Venti", "5x5; riempi; -angoli; -centro", 0xFF64C896),
    SESSANTAQUATTRO("64", "8x8; riempi", 0xFFE69650);

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
