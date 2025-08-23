import 'package:flutter/material.dart';
class MenuCategories {
  // Structure complète des catégories avec toutes leurs informations
  static const Map<String, Map<String, dynamic>> categories = {
    'menu_jour': {
      'nom': 'Menus du Jour',
      'couleur': Colors.orange,
      'icone': Icons.restaurant_menu,
    },
    'plat': {
      'nom': 'Plats',
      'couleur': Colors.blue,
      'icone': Icons.restaurant,
    },
    'snack': {
      'nom': 'Snacks',
      'couleur': Colors.green,
      'icone': Icons.fastfood,
    },
    'dessert': {
      'nom': 'Desserts',
      'couleur': Colors.purple,
      'icone': Icons.cake,
    },
    'boisson': {
      'nom': 'Boissons',
      'couleur': Colors.teal,
      'icone': Icons.local_drink,
    },
  };
  // Vérifier si une catégorie est valide
  static bool estCategorieValide(String categorie) {
    return categories.containsKey(categorie);
  }
  // Obtenir le nom affiché d'une catégorie
  static String obtenirNomCategorie(String categorie) {
    return categories[categorie]?['nom'] ?? categorie;
  }
  // Obtenir la couleur d'une catégorie
  static Color obtenirCouleurCategorie(String categorie) {
    return categories[categorie]?['couleur'] ?? Colors.grey;
  }
  // Obtenir l'icône d'une catégorie
  static IconData obtenirIconeCategorie(String categorie) {
    return categories[categorie]?['icone'] ?? Icons.restaurant;
  }
  // Obtenir toutes les catégories (clés)
  static List<String> obtenirToutesCategories() {
    return categories.keys.toList();
  }
  // Obtenir toutes les catégories avec leurs informations complètes
  static Map<String, Map<String, dynamic>> obtenirToutesCategoriesCompletes() {
    return Map.from(categories);
  }
  // Obtenir toutes les catégories avec leurs noms affichés
  static Map<String, String> obtenirToutesCategoriesAvecNoms() {
    return Map.fromEntries(
      categories.entries.map((entry) => MapEntry(entry.key, entry.value['nom'] as String))
    );
  }
  // Catégorie par défaut
  static const String categorieDefaut = 'menu_jour';
}