class EvenementTypes {
  // Types d'événements disponibles
  static const List<String> types = [
    'reunion',
    'conference',
    'atelier',
    'soiree',
    'tournoi',
    'autre'
  ];
  // Noms affichés pour chaque type
  static const Map<String, String> nomsTypes = {
    'reunion': 'Réunion',
    'conference': 'Conférence',
    'atelier': 'Atelier',
    'soiree': 'Soirée',
    'tournoi': 'Tournoi',
    'autre': 'Autre'
  };
  // Vérifier si un type est valide
  static bool estTypeValide(String type) {
    return types.contains(type);
  }
  // Obtenir le nom affiché d'un type
  static String obtenirNomType(String type) {
    return nomsTypes[type] ?? type;
  }
  // Obtenir tous les types avec leurs noms affichés
  static Map<String, String> obtenirTousTypes() {
    return Map.from(nomsTypes);
  }
  // Type par défaut
  static const String typeDefaut = 'reunion';
}