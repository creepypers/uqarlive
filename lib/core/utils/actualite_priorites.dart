class ActualitePriorites {
  // Priorités disponibles pour les actualités
  static const List<String> priorites = [
    'normale',
    'importante',
    'urgente'
  ];
  // Noms affichés pour chaque priorité
  static const Map<String, String> nomsPriorites = {
    'normale': 'Normale',
    'importante': 'Importante',
    'urgente': 'Urgente'
  };
  // Couleurs pour chaque priorité
  static const Map<String, int> couleursPriorites = {
    'normale': 0xFF005499,    // Bleu UQAR
    'importante': 0xFFFF9800, // Orange
    'urgente': 0xFFF44336     // Rouge
  };
  // Vérifier si une priorité est valide
  static bool estPrioriteValide(String priorite) {
    return priorites.contains(priorite);
  }
  // Obtenir le nom affiché d'une priorité
  static String obtenirNomPriorite(String priorite) {
    return nomsPriorites[priorite] ?? priorite;
  }
  // Obtenir la couleur d'une priorité
  static int obtenirCouleurPriorite(String priorite) {
    return couleursPriorites[priorite] ?? 0xFF005499;
  }
  // Obtenir toutes les priorités avec leurs noms affichés
  static Map<String, String> obtenirToutesPriorites() {
    return Map.from(nomsPriorites);
  }
  // Priorité par défaut
  static const String prioriteDefaut = 'normale';
}