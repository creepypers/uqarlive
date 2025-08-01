import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/menu.dart';
import '../../domain/repositories/menus_repository.dart';
import '../../data/repositories/menus_repository_impl.dart';
import '../../data/datasources/menus_datasource_local.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import '../widgets/widget_carte.dart';
import '../widgets/widget_collection.dart';
import '../widgets/widget_section_statistiques.dart';
import '../services/statistiques_service.dart';
import '../services/navigation_service.dart';
import 'details_menu_ecran.dart';

// UI Design: Page cantine UQAR avec menus, horaires et design moderne
class CantineEcran extends StatefulWidget {
  const CantineEcran({super.key});

  @override
  State<CantineEcran> createState() => _CantineEcranState();
}

class _CantineEcranState extends State<CantineEcran> {
  // Repository pour accéder aux données des menus
  late final MenusRepository _menusRepository;
  late final StatistiquesService _statistiquesService;
  List<Menu> _menusDuJour = [];
  List<Menu> _tousLesMenus = [];
  StatistiquesGlobales? _statistiques;
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
    _initialiserRepositories();
    _chargerDonnees();
  }

  void _initialiserRepositories() {
    final datasourceLocal = MenusDatasourceLocal();
    _menusRepository = MenusRepositoryImpl(datasourceLocal);
    _statistiquesService = ServiceLocator.obtenirService<StatistiquesService>();
  }

  Future<void> _chargerDonnees() async {
    setState(() {
      _chargementMenus = true;
    });

    try {
      final results = await Future.wait([
        _menusRepository.obtenirMenusDuJour(),
        _menusRepository.obtenirMenusParCategorie(_categorieSelectionnee),
        _statistiquesService.obtenirStatistiquesGlobales(),
      ]);

      setState(() {
        _menusDuJour = results[0] as List<Menu>;
        _tousLesMenus = results[1] as List<Menu>;
        _statistiques = results[2] as StatistiquesGlobales;
        _chargementMenus = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      setState(() {
        _chargementMenus = false;
      });
    }
  }

  Future<void> _chargerMenus() async {
    await _chargerDonnees();
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

  // UI Design: Section avec infos et horaires de la cantine - Données dynamiques
  Widget _construireSectionInfos() {
    if (_statistiques == null) {
      return const SizedBox.shrink();
    }

    return WidgetSectionStatistiques.cantine(
      titre: 'Horaires & Infos',
      iconeTitre: Icons.restaurant,
      statistiques: [
        {
          'valeur': '11h30 - 14h00',
          'label': 'Ouverture',
          'icone': Icons.access_time,
          'couleur': CouleursApp.accent,
        },
        {
          'valeur': '${_statistiques!.capaciteTotal} places',
          'label': 'Capacité',
          'icone': Icons.people,
          'couleur': CouleursApp.accent,
        },
        {
          'valeur': '${_statistiques!.prixMoyen.toStringAsFixed(2)}€',
          'label': 'Prix moyen',
          'icone': Icons.payment,
          'couleur': CouleursApp.accent,
        },
        {
          'valeur': '${_statistiques!.menusDisponibles} menus',
          'label': 'Disponibles',
          'icone': Icons.restaurant_menu,
          'couleur': CouleursApp.accent,
        },
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
              onTap: () => _ouvrirDetailsMenu(menu), // Ajout navigation
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsMenuEcran(menu: menu),
      ),
    );
  }
} 