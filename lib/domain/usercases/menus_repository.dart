import '../entities/menu.dart';
abstract class MenusRepository {
  /// Obtenir tous les menus disponibles
  Future<List<Menu>> obtenirMenusDisponibles();
  /// Obtenir les menus par catégorie
  Future<List<Menu>> obtenirMenusParCategorie(String categorie);
  /// Obtenir les menus du jour
  Future<List<Menu>> obtenirMenusDuJour();
  /// Obtenir les menus végétariens/vegan
  Future<List<Menu>> obtenirMenusVegetariens({bool veganUniquement = false});
  /// Rechercher des menus par nom ou description
  Future<List<Menu>> rechercherMenus(String recherche);
  /// Obtenir un menu par ID
  Future<Menu?> obtenirMenuParId(String id);
  /// Obtenir les catégories disponibles
  Future<List<String>> obtenirCategories();
  /// Obtenir les menus populaires (note >= 4.5)
  Future<List<Menu>> obtenirMenusPopulaires();
  /// Obtenir tous les menus (pour administration)
  Future<List<Menu>> obtenirTousLesMenus();
  /// Ajouter un nouveau menu (administration)
  Future<Menu> ajouterMenu(Menu menu);
  /// Modifier un menu existant (administration)
  Future<Menu> mettreAJourMenu(Menu menu);
  /// Supprimer un menu (administration)
  Future<bool> supprimerMenu(String menuId);
  /// Définir un menu comme menu du jour (administration)
  Future<void> definirMenuDuJour(String menuId);
  /// Obtenir l'ID du menu du jour actuel
  Future<String?> obtenirMenuDuJourActuel();
} 