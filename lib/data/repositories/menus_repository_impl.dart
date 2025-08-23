import '../../domain/entities/menu.dart';
import '../../domain/usercases/menus_repository.dart';
import '../datasources/internal/menus_datasource_local.dart';
import '../models/menu_model.dart';
class MenusRepositoryImpl implements MenusRepository {
  final MenusDatasourceLocal _datasourceLocal;
  MenusRepositoryImpl(this._datasourceLocal);
  @override
  Future<List<Menu>> obtenirMenusDisponibles() async {
    try {
      final menusData = _datasourceLocal.obtenirMenusDisponibles();
      return menusData.map((data) => MenuModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des menus disponibles: $e');
    }
  }
  @override
  Future<List<Menu>> obtenirMenusParCategorie(String categorie) async {
    try {
      final menusData = _datasourceLocal.obtenirMenusParCategorie(categorie);
      return menusData.map((data) => MenuModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des menus par catégorie: $e');
    }
  }
  @override
  Future<List<Menu>> obtenirMenusDuJour() async {
    try {
      final menusData = _datasourceLocal.obtenirMenusDuJour();
      return menusData.map((data) => MenuModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des menus du jour: $e');
    }
  }
  @override
  Future<List<Menu>> obtenirMenusVegetariens({bool veganUniquement = false}) async {
    try {
      final menusData = _datasourceLocal.obtenirMenusVegetariens(veganUniquement: veganUniquement);
      return menusData.map((data) => MenuModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des menus végétariens: $e');
    }
  }
  @override
  Future<List<Menu>> rechercherMenus(String recherche) async {
    try {
      final menusData = _datasourceLocal.rechercherMenus(recherche);
      return menusData.map((data) => MenuModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche de menus: $e');
    }
  }
  @override
  Future<Menu?> obtenirMenuParId(String id) async {
    try {
      final menuData = _datasourceLocal.obtenirMenuParId(id);
      if (menuData == null) return null;
      return MenuModel.fromMap(menuData);
    } catch (e) {
      throw Exception('Erreur lors du chargement du menu par ID: $e');
    }
  }
  @override
  Future<List<String>> obtenirCategories() async {
    try {
      return _datasourceLocal.obtenirCategories();
    } catch (e) {
      throw Exception('Erreur lors du chargement des catégories: $e');
    }
  }
  @override
  Future<List<Menu>> obtenirMenusPopulaires() async {
    try {
      final menusData = _datasourceLocal.obtenirMenusPopulaires();
      return menusData.map((data) => MenuModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des menus populaires: $e');
    }
  }
  @override
  Future<List<Menu>> obtenirTousLesMenus() async {
    try {
      final menusData = _datasourceLocal.obtenirTousLesMenus();
      return menusData.map((data) => MenuModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement de tous les menus: $e');
    }
  }
  @override
  Future<Menu> ajouterMenu(Menu menu) async {
    try {
      final menuModel = MenuModel.fromEntity(menu);
      final menuAjoute = await _datasourceLocal.ajouterMenu(menuModel.toMap());
      return MenuModel.fromMap(menuAjoute);
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du menu: $e');
    }
  }
  @override
  Future<Menu> mettreAJourMenu(Menu menu) async {
    try {
      final menuModel = MenuModel.fromEntity(menu);
      final menuMisAJour = await _datasourceLocal.mettreAJourMenu(menu.id, menuModel.toMap());
      return MenuModel.fromMap(menuMisAJour);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du menu: $e');
    }
  }
  @override
  Future<bool> supprimerMenu(String menuId) async {
    try {
      return await _datasourceLocal.supprimerMenu(menuId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du menu: $e');
    }
  }
  @override
  Future<void> definirMenuDuJour(String menuId) async {
    try {
      await _datasourceLocal.definirMenuDuJour(menuId);
    } catch (e) {
      throw Exception('Erreur lors de la définition du menu du jour: $e');
    }
  }
  @override
  Future<String?> obtenirMenuDuJourActuel() async {
    try {
      return await _datasourceLocal.obtenirMenuDuJourActuel();
    } catch (e) {
      throw Exception('Erreur lors de la récupération du menu du jour actuel: $e');
    }
  }
} 