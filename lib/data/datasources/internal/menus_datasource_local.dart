// UI Design: Source de données locale pour les menus de la cantine UQAR
class MenusDatasourceLocal {
  
  // UI Design: Variable statique pour stocker l'ID du menu du jour actuel
  static String? _menuDuJourActuel;
  
  // Liste statique mutable pour stocker les menus (simulation de base de données)
  static final List<Map<String, dynamic>> _menus = [
    // Menus du jour
    {
      'id': '1',
      'nom': 'Menu Étudiant',
      'description': 'Plat principal, accompagnement, dessert et boisson',
      'prix': 8.50,
      'estDisponible': true,
      'ingredients': ['Poulet grillé', 'Riz pilaf', 'Légumes de saison', 'Salade verte', 'Yaourt aux fruits'],
      'allergenes': 'Gluten, Lactose',
      'categorie': 'menu_jour',
      'calories': 650,
      'estVegetarien': false,
      'estVegan': false,
      'imageUrl': null,
      'dateAjout': '2024-01-15',
      'nutritionInfo': 'Protéines: 35g, Glucides: 65g, Lipides: 18g',
      'note': 4.2,
    },
    {
      'id': '2',
      'nom': 'Menu Végétarien',
      'description': 'Curry de légumes, quinoa et dessert maison',
      'prix': 7.50,
      'estDisponible': true,
      'ingredients': ['Curry de légumes', 'Quinoa bio', 'Courgettes', 'Tomates', 'Compote pomme-cannelle'],
      'allergenes': 'Traces de noix',
      'categorie': 'menu_jour',
      'calories': 520,
      'estVegetarien': true,
      'estVegan': false,
      'imageUrl': null,
      'dateAjout': '2024-01-15',
      'nutritionInfo': 'Protéines: 18g, Glucides: 78g, Lipides: 12g',
      'note': 4.6,
    },
    {
      'id': '3',
      'nom': 'Menu Express',
      'description': 'Sandwich gourmand, chips et boisson',
      'prix': 6.00,
      'estDisponible': true,
      'ingredients': ['Pain artisanal', 'Jambon de Bayonne', 'Fromage', 'Salade', 'Tomates'],
      'allergenes': 'Gluten, Lactose',
      'categorie': 'menu_jour',
      'calories': 480,
      'estVegetarien': false,
      'estVegan': false,
      'imageUrl': null,
      'dateAjout': '2024-01-15',
      'nutritionInfo': 'Protéines: 22g, Glucides: 45g, Lipides: 16g',
      'note': 4.1,
    },
    // Plats principaux
    {
      'id': '4',
      'nom': 'Pâtes Carbonara',
      'description': 'Pâtes fraîches à la carbonara traditionnelle',
      'prix': 5.50,
      'estDisponible': true,
      'ingredients': ['Pâtes fraîches', 'Lardons', 'Œufs', 'Parmesan', 'Crème fraîche'],
      'allergenes': 'Gluten, Œufs, Lactose',
      'categorie': 'plat',
      'calories': 580,
      'estVegetarien': false,
      'estVegan': false,
      'imageUrl': null,
      'dateAjout': '2024-01-12',
      'nutritionInfo': 'Protéines: 24g, Glucides: 52g, Lipides: 24g',
      'note': 4.7,
    },
    {
      'id': '5',
      'nom': 'Salade César',
      'description': 'Salade césar avec croûtons et parmesan',
      'prix': 4.50,
      'estDisponible': true,
      'ingredients': ['Salade romaine', 'Poulet grillé', 'Croûtons', 'Parmesan', 'Sauce césar'],
      'allergenes': 'Gluten, Œufs, Lactose',
      'categorie': 'plat',
      'calories': 320,
      'estVegetarien': false,
      'estVegan': false,
      'imageUrl': null,
      'dateAjout': '2024-01-12',
      'nutritionInfo': 'Protéines: 28g, Glucides: 12g, Lipides: 18g',
      'note': 4.3,
    },
    {
      'id': '6',
      'nom': 'Bowl Vegan',
      'description': 'Quinoa, légumes grillés, avocat et tahini',
      'prix': 6.50,
      'estDisponible': true,
      'ingredients': ['Quinoa', 'Légumes grillés', 'Avocat', 'Tahini', 'Graines de tournesol'],
      'allergenes': 'Traces de sésame',
      'categorie': 'plat',
      'calories': 420,
      'estVegetarien': true,
      'estVegan': true,
      'imageUrl': null,
      'dateAjout': '2024-01-12',
      'nutritionInfo': 'Protéines: 16g, Glucides: 58g, Lipides: 18g',
      'note': 4.8,
    },
  ];

  /// Méthode pour obtenir tous les menus
  List<Map<String, dynamic>> obtenirTousLesMenus() {
    return _menus;
  }

  /// Obtenir les menus par catégorie
  List<Map<String, dynamic>> obtenirMenusParCategorie(String categorie) {
    if (categorie == 'toutes') return obtenirTousLesMenus();
    return obtenirTousLesMenus()
        .where((menu) => menu['categorie'] == categorie)
        .toList();
  }

  /// Obtenir les menus disponibles
  List<Map<String, dynamic>> obtenirMenusDisponibles() {
    return obtenirTousLesMenus()
        .where((menu) => menu['estDisponible'] == true)
        .toList();
  }

  /// Obtenir les menus populaires (note >= 4.5)
  List<Map<String, dynamic>> obtenirMenusPopulaires() {
    return obtenirTousLesMenus()
        .where((menu) => 
            menu['estDisponible'] == true && 
            menu['note'] != null && 
            menu['note'] >= 4.5)
        .toList();
  }

  /// Obtenir les menus du jour
  List<Map<String, dynamic>> obtenirMenusDuJour() {
    return obtenirTousLesMenus()
        .where((menu) => menu['categorie'] == 'menu_jour')
        .toList();
  }

  /// Obtenir les menus végétariens
  List<Map<String, dynamic>> obtenirMenusVegetariens({bool veganUniquement = false}) {
    return obtenirTousLesMenus()
        .where((menu) => 
            menu['estVegetarien'] == true && 
            (!veganUniquement || menu['estVegan'] == true))
        .toList();
  }

  /// Méthode pour obtenir un menu par ID
  Map<String, dynamic>? obtenirMenuParId(String id) {
    try {
      return obtenirTousLesMenus().firstWhere((menu) => menu['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// Méthode pour rechercher des menus
  List<Map<String, dynamic>> rechercherMenus(String recherche) {
    final rechercheLowerCase = recherche.toLowerCase();
    return obtenirTousLesMenus().where((menu) {
      return menu['nom'].toLowerCase().contains(rechercheLowerCase) ||
          menu['description'].toLowerCase().contains(rechercheLowerCase) ||
          menu['ingredients'].any((ingredient) => 
              ingredient.toLowerCase().contains(rechercheLowerCase));
    }).toList();
  }

  /// Méthode pour obtenir les catégories
  List<String> obtenirCategories() {
    return ['menu_jour', 'plat', 'snack', 'dessert', 'boisson'];
  }

  /// Ajouter un nouveau menu
  Future<Map<String, dynamic>> ajouterMenu(Map<String, dynamic> menuData) async {
    // UI Design: Ajouter le menu à la liste statique
    _menus.add(menuData);
    return menuData;
  }

  /// Mettre à jour un menu existant
  Future<Map<String, dynamic>> mettreAJourMenu(String menuId, Map<String, dynamic> menuData) async {
    // UI Design: Trouver et mettre à jour le menu dans la liste statique
    final index = _menus.indexWhere((m) => m['id'] == menuId);
    
    if (index == -1) {
      throw Exception('Menu avec l\'ID $menuId introuvable');
    }
    _menus[index] = menuData;
    return menuData;
  }

  /// Supprimer un menu
  Future<bool> supprimerMenu(String menuId) async {
    // UI Design: Supprimer le menu de la liste statique
    final index = _menus.indexWhere((m) => m['id'] == menuId);
    if (index != -1) {
      _menus.removeAt(index);
      
      // Si on supprime le menu du jour actuel, le retirer
      if (_menuDuJourActuel == menuId) {
        _menuDuJourActuel = null;
      }
      return true;
    }
    return false;
  }

  /// Définir un menu comme menu du jour
  Future<void> definirMenuDuJour(String menuId) async {
    // Si ID vide, retirer le menu du jour
    if (menuId.isEmpty) {
      _menuDuJourActuel = null;
      return;
    }
    
    // Vérifier que le menu existe
    final menu = obtenirMenuParId(menuId);
    if (menu == null) {
      throw Exception('Menu avec l\'ID $menuId non trouvé');
    }
    
    // Définir le menu du jour
    _menuDuJourActuel = menuId;
  }

  /// Obtenir l'ID du menu du jour actuel
  Future<String?> obtenirMenuDuJourActuel() async {
    return _menuDuJourActuel;
  }
}
