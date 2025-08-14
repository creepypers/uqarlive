// UI Design: Source de données locale pour les menus de la cantine UQAR
class MenusDatasourceLocal {
  
  // UI Design: Variable statique pour stocker l'ID du menu du jour actuel
  static String? _menuDuJourActuel;
  
  /// Obtenir tous les menus de la cantine
  List<Map<String, dynamic>> obtenirTousLesMenus() {
    return [
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
        'ingredients': ['Quinoa', 'Brocolis', 'Courgettes', 'Avocat', 'Graines de tournesol', 'Sauce tahini'],
        'allergenes': 'Sésame',
        'categorie': 'plat',
        'calories': 420,
        'estVegetarien': true,
        'estVegan': true,
        'imageUrl': null,
        'dateAjout': '2024-01-10',
        'nutritionInfo': 'Protéines: 16g, Glucides: 48g, Lipides: 18g',
        'note': 4.8,
      },

      // Snacks et sandwichs
      {
        'id': '7',
        'nom': 'Croque-Monsieur',
        'description': 'Croque-monsieur gratinée au four',
        'prix': 3.50,
        'estDisponible': true,
        'ingredients': ['Pain de mie', 'Jambon blanc', 'Gruyère', 'Béchamel'],
        'allergenes': 'Gluten, Lactose',
        'categorie': 'snack',
        'calories': 380,
        'estVegetarien': false,
        'estVegan': false,
        'imageUrl': null,
        'dateAjout': '2024-01-08',
        'nutritionInfo': 'Protéines: 18g, Glucides: 28g, Lipides: 22g',
        'note': 4.0,
      },
      {
        'id': '8',
        'nom': 'Wrap Végétarien',
        'description': 'Tortilla aux légumes grillés et houmous',
        'prix': 4.00,
        'estDisponible': false,
        'ingredients': ['Tortilla', 'Courgettes', 'Poivrons', 'Houmous', 'Roquette'],
        'allergenes': 'Gluten, Sésame',
        'categorie': 'snack',
        'calories': 290,
        'estVegetarien': true,
        'estVegan': true,
        'imageUrl': null,
        'dateAjout': '2024-01-08',
        'nutritionInfo': 'Protéines: 12g, Glucides: 38g, Lipides: 10g',
        'note': 4.4,
      },

      // Desserts
      {
        'id': '9',
        'nom': 'Tiramisu Maison',
        'description': 'Tiramisu fait par notre chef pâtissier',
        'prix': 2.50,
        'estDisponible': true,
        'ingredients': ['Mascarpone', 'Biscuits', 'Café', 'Cacao', 'Œufs'],
        'allergenes': 'Gluten, Œufs, Lactose',
        'categorie': 'dessert',
        'calories': 220,
        'estVegetarien': true,
        'estVegan': false,
        'imageUrl': null,
        'dateAjout': '2024-01-05',
        'nutritionInfo': 'Protéines: 6g, Glucides: 18g, Lipides: 14g',
        'note': 4.9,
      },
      {
        'id': '10',
        'nom': 'Fruit de Saison',
        'description': 'Sélection de fruits frais de saison',
        'prix': 1.50,
        'estDisponible': true,
        'ingredients': ['Pommes', 'Oranges', 'Bananes', 'Kiwis'],
        'allergenes': null,
        'categorie': 'dessert',
        'calories': 80,
        'estVegetarien': true,
        'estVegan': true,
        'imageUrl': null,
        'dateAjout': '2024-01-05',
        'nutritionInfo': 'Protéines: 1g, Glucides: 18g, Lipides: 0g',
        'note': 4.2,
      },

      // Boissons
      {
        'id': '11',
        'nom': 'Café Équitable',
        'description': 'Café arabica issu du commerce équitable',
        'prix': 1.20,
        'estDisponible': true,
        'ingredients': ['Café arabica'],
        'allergenes': null,
        'categorie': 'boisson',
        'calories': 5,
        'estVegetarien': true,
        'estVegan': true,
        'imageUrl': null,
        'dateAjout': '2024-01-01',
        'nutritionInfo': 'Protéines: 0g, Glucides: 1g, Lipides: 0g',
        'note': 4.1,
      },
      {
        'id': '12',
        'nom': 'Smoothie Fruits Rouges',
        'description': 'Smoothie maison aux fruits rouges et yaourt',
        'prix': 2.80,
        'estDisponible': true,
        'ingredients': ['Fraises', 'Framboises', 'Myrtilles', 'Yaourt nature', 'Miel'],
        'allergenes': 'Lactose',
        'categorie': 'boisson',
        'calories': 120,
        'estVegetarien': true,
        'estVegan': false,
        'imageUrl': null,
        'dateAjout': '2024-01-01',
        'nutritionInfo': 'Protéines: 6g, Glucides: 22g, Lipides: 2g',
        'note': 4.5,
      },
    ];
  }

  // Méthodes pour filtrer les menus
  List<Map<String, dynamic>> obtenirMenusParCategorie(String categorie) {
    if (categorie == 'Toutes') return obtenirTousLesMenus();
    return obtenirTousLesMenus()
        .where((menu) => menu['categorie'] == categorie)
        .toList();
  }

  List<Map<String, dynamic>> obtenirMenusDisponibles() {
    return obtenirTousLesMenus()
        .where((menu) => menu['estDisponible'] == true)
        .toList();
  }

  List<Map<String, dynamic>> obtenirMenusVegetariens({bool veganUniquement = false}) {
    return obtenirTousLesMenus().where((menu) {
      if (veganUniquement) {
        return menu['estVegan'] == true && menu['estDisponible'] == true;
      } else {
        return menu['estVegetarien'] == true && menu['estDisponible'] == true;
      }
    }).toList();
  }

  List<Map<String, dynamic>> obtenirMenusDuJour() {
    return obtenirMenusParCategorie('menu_jour')
        .where((menu) => menu['estDisponible'] == true)
        .toList();
  }

  List<Map<String, dynamic>> obtenirMenusPopulaires() {
    return obtenirTousLesMenus()
        .where((menu) => 
            menu['estDisponible'] == true && 
            menu['note'] != null && 
            menu['note'] >= 4.5)
        .toList();
  }

  // Méthode pour obtenir un menu par ID
  Map<String, dynamic>? obtenirMenuParId(String id) {
    try {
      return obtenirTousLesMenus().firstWhere((menu) => menu['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Méthode pour rechercher des menus
  List<Map<String, dynamic>> rechercherMenus(String recherche) {
    final rechercheLowerCase = recherche.toLowerCase();
    return obtenirTousLesMenus().where((menu) {
      return menu['nom'].toLowerCase().contains(rechercheLowerCase) ||
          menu['description'].toLowerCase().contains(rechercheLowerCase) ||
          menu['ingredients'].any((ingredient) => 
              ingredient.toLowerCase().contains(rechercheLowerCase));
    }).toList();
  }

  // Méthode pour obtenir les catégories
  List<String> obtenirCategories() {
    return ['menu_jour', 'plat', 'snack', 'dessert', 'boisson'];
  }

  /// Ajouter un nouveau menu
  Future<Map<String, dynamic>> ajouterMenu(Map<String, dynamic> menuData) async {

    
    // Créer une copie de la liste existante
    final menus = obtenirTousLesMenus();
    
    // Ajouter le nouveau menu
    menus.add(menuData);
    
    // Note: Dans une vraie implémentation, on utiliserait une base de données
    // Ici on simule juste le succès de l'opération
    return menuData;
  }

  /// Mettre à jour un menu existant
  Future<Map<String, dynamic>> mettreAJourMenu(String menuId, Map<String, dynamic> menuData) async {
    // Simulation de mise à jour - dans une vraie app, cela irait en base de données
    // Pour cette démo, nous simulons la modification en mettant à jour la liste en mémoire
    
    // Créer une copie de la liste existante
    final menus = obtenirTousLesMenus();
    
    // Trouver l'index du menu à modifier
    final index = menus.indexWhere((m) => m['id'] == menuId);
    
    if (index != -1) {
      // Mettre à jour le menu existant
      menus[index] = menuData;
      return menuData;
    }
    
    return menuData;
  }

  /// Supprimer un menu
  Future<bool> supprimerMenu(String menuId) async {
    // Simulation de suppression - dans une vraie app, cela irait en base de données
    // Si on supprime le menu du jour actuel, le retirer
    if (_menuDuJourActuel == menuId) {
      _menuDuJourActuel = null;
    }
    return true;
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