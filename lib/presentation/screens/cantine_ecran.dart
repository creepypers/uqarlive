import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/menu.dart';
import '../../domain/repositories/menus_repository.dart';
import '../../data/repositories/menus_repository_impl.dart';
import '../../data/datasources/menus_datasource_local.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import '../widgets/widget_carte.dart';
import '../widgets/widget_collection.dart';
import '../services/navigation_service.dart';

// UI Design: Page cantine UQAR avec menus, horaires et design moderne
class CantineEcran extends StatefulWidget {
  const CantineEcran({Key? key}) : super(key: key);

  @override
  State<CantineEcran> createState() => _CantineEcranState();
}

class _CantineEcranState extends State<CantineEcran> {
  // Repository pour accéder aux données des menus
  late final MenusRepository _menusRepository;
  List<Menu> _menusDuJour = [];
  List<Menu> _tousLesMenus = [];
  String _categorieSelectionnee = 'menu_jour';
  bool _chargementMenus = false;
  bool _afficheVegetarienUniquement = false;

  final List<String> _categories = [
    'menu_jour',
    'plat', 
    'snack',
    'dessert',
    'boisson',
  ];

  final Map<String, String> _nomsCategories = {
    'menu_jour': 'Menus du Jour',
    'plat': 'Plats',
    'snack': 'Snacks',
    'dessert': 'Desserts',
    'boisson': 'Boissons',
  };

  @override
  void initState() {
    super.initState();
    _initialiserRepository();
    _chargerMenus();
  }

  void _initialiserRepository() {
    final datasourceLocal = MenusDatasourceLocal();
    _menusRepository = MenusRepositoryImpl(datasourceLocal);
  }

  Future<void> _chargerMenus() async {
    setState(() {
      _chargementMenus = true;
    });

    try {
      final [menusDuJour, menusCategorie] = await Future.wait([
        _menusRepository.obtenirMenusDuJour(),
        _menusRepository.obtenirMenusParCategorie(_categorieSelectionnee),
      ]);

      setState(() {
        _menusDuJour = menusDuJour;
        _tousLesMenus = menusCategorie;
        _chargementMenus = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des menus: $e');
      setState(() {
        _chargementMenus = false;
      });
    }
  }

  Future<void> _changerCategorie(String nouvelleCategorie) async {
    setState(() {
      _categorieSelectionnee = nouvelleCategorie;
      _chargementMenus = true;
    });

    try {
      List<Menu> menusCategorie;
      if (_afficheVegetarienUniquement) {
        menusCategorie = await _menusRepository.obtenirMenusVegetariens();
        if (nouvelleCategorie != 'menu_jour') {
          menusCategorie = menusCategorie.where((m) => m.categorie == nouvelleCategorie).toList();
        }
      } else {
        menusCategorie = await _menusRepository.obtenirMenusParCategorie(nouvelleCategorie);
      }

      setState(() {
        _tousLesMenus = menusCategorie;
        _chargementMenus = false;
      });
    } catch (e) {
      print('Erreur lors du changement de catégorie: $e');
      setState(() {
        _chargementMenus = false;
      });
    }
  }

  Future<void> _toggleVegetarien() async {
    setState(() {
      _afficheVegetarienUniquement = !_afficheVegetarienUniquement;
    });
    await _changerCategorie(_categorieSelectionnee);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: WidgetBarreAppPersonnalisee(
        titre: 'Cantine UQAR',
        sousTitre: 'Menus & Horaires',
        widgetFin: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _toggleVegetarien,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _afficheVegetarienUniquement 
                    ? Colors.green.withValues(alpha: 0.2)
                    : CouleursApp.blanc.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _afficheVegetarienUniquement ? Icons.eco : Icons.eco_outlined,
                  color: _afficheVegetarienUniquement ? Colors.green : CouleursApp.blanc,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                // TODO: Implémenter la recherche
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CouleursApp.blanc.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.search,
                  color: CouleursApp.blanc,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section infos cantine
              _construireSectionInfos(),
              const SizedBox(height: 16),
              
              // Section menus du jour
              if (_menusDuJour.isNotEmpty) ...[
                _construireSectionMenusDuJour(),
                const SizedBox(height: 24),
              ],
              
              // Filtres et catégories
              _construireFiltres(),
              const SizedBox(height: 16),
              
              // Grille des menus
              _construireGrilleMenus(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBarWidget(
        indexSelectionne: 0, // Cantine
        onTap: (index) => NavigationService.gererNavigationNavBar(context, index),
      ),
    );
  }

  // UI Design: Section avec infos et horaires de la cantine
  Widget _construireSectionInfos() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CouleursApp.accent.withValues(alpha: 0.1),
            CouleursApp.principal.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CouleursApp.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant,
                color: CouleursApp.principal,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Horaires & Infos',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _construireInfoItem(
                  icone: Icons.access_time,
                  titre: 'Ouverture',
                  valeur: '11h30 - 14h00',
                ),
              ),
              Expanded(
                child: _construireInfoItem(
                  icone: Icons.people,
                  titre: 'Places',
                  valeur: '150 places',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _construireInfoItem(
                  icone: Icons.payment,
                  titre: 'Paiement',
                  valeur: 'Carte & Espèces',
                ),
              ),
              Expanded(
                child: _construireInfoItem(
                  icone: Icons.wifi,
                  titre: 'WiFi',
                  valeur: 'Gratuit',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construireInfoItem({
    required IconData icone,
    required String titre,
    required String valeur,
  }) {
    return Row(
      children: [
        Icon(icone, color: CouleursApp.accent, size: 16),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titre,
              style: TextStyle(
                fontSize: 12,
                color: CouleursApp.texteFonce.withValues(alpha: 0.6),
              ),
            ),
            Text(
              valeur,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: CouleursApp.texteFonce,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // UI Design: Section menus du jour avec WidgetCollection optimisé
  Widget _construireSectionMenusDuJour() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.today,
                color: CouleursApp.principal,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Menus du Jour',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        WidgetCollection<Menu>.listeHorizontale(
          elements: _menusDuJour,
          hauteur: 190,
          constructeurElement: (context, menu, index) {
            return WidgetCarte.menu(
              menu: menu,
              modeListe: true,
              largeur: 200,
              hauteur: 185,
            );
          },
          padding: const EdgeInsets.symmetric(horizontal: 16),
          messageEtatVide: 'Aucun menu du jour disponible',
          iconeEtatVide: Icons.restaurant_menu_outlined,
        ),
      ],
    );
  }

  // UI Design: Filtres et catégories
  Widget _construireFiltres() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Catégories',
            style: StylesTexteApp.titre.copyWith(fontSize: 18),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final categorie = _categories[index];
              final estSelectionne = categorie == _categorieSelectionnee;
              
              return GestureDetector(
                onTap: () => _changerCategorie(categorie),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: estSelectionne 
                        ? CouleursApp.principal 
                        : CouleursApp.blanc,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: estSelectionne 
                          ? CouleursApp.principal 
                          : CouleursApp.principal.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _nomsCategories[categorie] ?? categorie,
                    style: TextStyle(
                      color: estSelectionne 
                          ? CouleursApp.blanc 
                          : CouleursApp.principal,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // UI Design: Grille des menus avec WidgetCollection
  Widget _construireGrilleMenus() {
    return WidgetCollection<Menu>.grille(
      elements: _tousLesMenus,
      enChargement: _chargementMenus,
      nombreColonnes: 2,
      espacementColonnes: 16,
      espacementLignes: 16,
      constructeurElement: (context, menu, index) {
        return WidgetCarte.menu(
          menu: menu,
          onTap: () => _ouvrirDetailsMenu(menu),
        );
      },
      padding: const EdgeInsets.symmetric(horizontal: 16),
      messageEtatVide: _afficheVegetarienUniquement 
        ? 'Aucun menu végétarien disponible'
        : 'Aucun menu disponible dans cette catégorie',
      iconeEtatVide: _afficheVegetarienUniquement 
        ? Icons.eco_outlined 
        : Icons.restaurant_outlined,
    );
  }

  void _ouvrirDetailsMenu(Menu menu) {
    // TODO: Implémenter la page de détails du menu
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Détails de ${menu.nom}'),
        backgroundColor: CouleursApp.principal,
      ),
    );
  }
} 