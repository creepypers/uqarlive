// UI Design: Utilitaires pour les types d'associations - Clean Architecture
class AssociationTypes {
  // Types d'associations disponibles
  static const List<String> types = [
    'toutes',
    'etudiante',
    'culturelle',
    'sportive',
    'academique',
    'sociale',
    'technologie',
    'environnement',
    'autre',
  ];

  // Noms affichés pour chaque type
  static const Map<String, String> nomsTypes = {
    'toutes': 'Toutes',
    'etudiante': 'Étudiantes',
    'culturelle': 'Culturelles',
    'sportive': 'Sportives',
    'academique': 'Académiques',
    'sociale': 'Sociales',
    'technologie': 'Technologie',
    'environnement': 'Environnement',
    'autre': 'Autres',
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
  static const String typeDefaut = 'toutes';

  // Types pour la création d'associations (sans 'toutes')
  static List<String> get typesCreation => 
      types.where((type) => type != 'toutes').toList();
}
