
class MenuCategories {
  // Catégories disponibles pour les menus
  static const List<String> categories = [
    'menu_jour',
    'plat', 
    'snack',
    'dessert',
    'boisson',
  ];

  // Noms affichés pour chaque catégorie
  static const Map<String, String> nomsCategories = {
    'menu_jour': 'Menus du Jour',
    'plat': 'Plats',
    'snack': 'Snacks',
    'dessert': 'Desserts',
    'boisson': 'Boissons',
  };

  // Vérifier si une catégorie est valide
  static bool estCategorieValide(String categorie) {
    return categories.contains(categorie);
  }

  // Obtenir le nom affiché d'une catégorie
  static String obtenirNomCategorie(String categorie) {
    return nomsCategories[categorie] ?? categorie;
  }

  // Obtenir toutes les catégories avec leurs noms affichés
  static Map<String, String> obtenirToutesCategories() {
    return Map.from(nomsCategories);
  }

  // Catégorie par défaut
  static const String categorieDefaut = 'menu_jour';
}
