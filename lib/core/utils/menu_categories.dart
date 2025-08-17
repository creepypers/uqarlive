
class MenuCategories {
  // Catégories disponibles pour les menus avec value-label pairs
  static const List<Map<String, String>> categories = [
    {'value': 'menu_jour', 'label': 'Menu du jour'},
    {'value': 'entree', 'label': 'Entrée'},
    {'value': 'plat_principal', 'label': 'Plat principal'},
    {'value': 'accompagnement', 'label': 'Accompagnement'},
    {'value': 'dessert', 'label': 'Dessert'},
    {'value': 'boisson', 'label': 'Boisson'},
    {'value': 'snack', 'label': 'Snack'},
  ];

  // Vérifier si une catégorie est valide
  static bool estCategorieValide(String categorie) {
    return categories.any((cat) => cat['value'] == categorie);
  }

  // Obtenir le nom affiché d'une catégorie
  static String obtenirNomCategorie(String categorie) {
    final found = categories.firstWhere(
      (cat) => cat['value'] == categorie,
      orElse: () => {'value': categorie, 'label': categorie},
    );
    return found['label']!;
  }

  // Obtenir toutes les catégories avec leurs noms affichés
  static Map<String, String> obtenirToutesCategories() {
    final Map<String, String> result = {};
    for (final cat in categories) {
      result[cat['value']!] = cat['label']!;
    }
    return result;
  }

  // Obtenir la liste des catégories avec value-label pairs
  static List<Map<String, String>> obtenirCategoriesList() {
    return List.from(categories);
  }

  // Obtenir seulement les valeurs des catégories
  static List<String> obtenirValeursCategories() {
    return categories.map((cat) => cat['value']!).toList();
  }

  // Obtenir seulement les labels des catégories
  static List<String> obtenirLabelsCategories() {
    return categories.map((cat) => cat['label']!).toList();
  }

  // Catégorie par défaut
  static const String categorieDefaut = 'menu_jour';
}
