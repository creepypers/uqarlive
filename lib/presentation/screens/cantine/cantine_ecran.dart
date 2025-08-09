import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/menu.dart';
import '../../../domain/repositories/menus_repository.dart';
import '../../../presentation/widgets/navbar_widget.dart';
import '../../../presentation/widgets/widget_barre_app_personnalisee.dart';
import '../../../presentation/widgets/widget_carte.dart';
import '../../../presentation/widgets/widget_collection.dart';
import '../../../presentation/widgets/widget_section_statistiques.dart';
import '../../../presentation/services/statistiques_service.dart';
import '../../../presentation/services/navigation_service.dart';
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
    _menusRepository = ServiceLocator.obtenirService<MenusRepository>();
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
    // UI Design: Obtenir les dimensions de l'écran pour l'adaptabilité
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;
    
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      resizeToAvoidBottomInset: true, // UI Design: Éviter les débordements avec le clavier
      appBar: WidgetBarreAppPersonnalisee(
        titre: 'Cantine UQAR',
        sousTitre: 'Menus & Horaires',
        widgetFin: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _toggleVegetarien,
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.025), // UI Design: Padding adaptatif
                decoration: BoxDecoration(
                  color: _afficheVegetarienUniquement 
                    ? Colors.green.withValues(alpha: 0.2)
                    : CouleursApp.blanc.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _afficheVegetarienUniquement ? Icons.eco : Icons.eco_outlined,
                  color: _afficheVegetarienUniquement ? Colors.green : CouleursApp.blanc,
                  size: screenWidth * 0.06, // UI Design: Taille adaptative
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
            GestureDetector(
              onTap: () {
                // TODO: Implémenter la recherche
              },
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.025), // UI Design: Padding adaptatif
                decoration: BoxDecoration(
                  color: CouleursApp.blanc.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.search,
                  color: CouleursApp.blanc,
                  size: screenWidth * 0.06, // UI Design: Taille adaptative
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: viewInsets.bottom + padding.bottom + screenHeight * 0.025, // UI Design: Padding adaptatif pour éviter les débordements
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section infos cantine
              _construireSectionInfos(),
              SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
              
              // Section menus du jour
              if (_menusDuJour.isNotEmpty) ...[
                _construireSectionMenusDuJour(),
                SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
              ],
              
              // Filtres et catégories
              _construireFiltres(),
              SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
              
              // Grille des menus
              _construireGrilleMenus(),
              SizedBox(height: screenHeight * 0.025), // UI Design: Espacement adaptatif
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
        const {
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Padding adaptatif
          child: Row(
            children: [
              Icon(
                Icons.today,
                color: CouleursApp.principal,
                size: screenWidth * 0.06, // UI Design: Taille adaptative
              ),
              SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Text(
                'Menus du Jour',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                ),
                overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.015), // UI Design: Espacement adaptatif
        WidgetCollection<Menu>.listeHorizontale(
          elements: _menusDuJour,
          hauteur: screenHeight * 0.24, // UI Design: Hauteur adaptative
          constructeurElement: (context, menu, index) {
            return WidgetCarte.menu(
              menu: menu,
              modeListe: true,
              largeur: screenWidth * 0.5, // UI Design: Largeur adaptative
              hauteur: screenHeight * 0.23, // UI Design: Hauteur adaptative
              onTap: () => _ouvrirDetailsMenu(menu), // Ajout navigation
            );
          },
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Padding adaptatif
          messageEtatVide: 'Aucun menu du jour disponible',
          iconeEtatVide: Icons.restaurant_menu_outlined,
        ),
      ],
    );
  }

  // UI Design: Filtres et catégories
  Widget _construireFiltres() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Padding adaptatif
          child: Text(
            'Catégories',
            style: StylesTexteApp.titre.copyWith(
              fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
            ),
            overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
            maxLines: 1,
          ),
        ),
        SizedBox(height: screenHeight * 0.015), // UI Design: Espacement adaptatif
        SizedBox(
          height: screenHeight * 0.05, // UI Design: Hauteur adaptative
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Padding adaptatif
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final categorie = _categories[index];
              final estSelectionne = categorie == _categorieSelectionnee;
              
              return GestureDetector(
                onTap: () => _changerCategorie(categorie),
                child: Container(
                  margin: EdgeInsets.only(right: screenWidth * 0.03), // UI Design: Marge adaptative
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04, // UI Design: Padding adaptatif
                    vertical: screenHeight * 0.01,
                  ),
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
                      fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                    ),
                    overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                    maxLines: 1,
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return WidgetCollection<Menu>.grille(
      elements: _tousLesMenus,
      enChargement: _chargementMenus,
      nombreColonnes: 2,
      espacementColonnes: screenWidth * 0.04, // UI Design: Espacement adaptatif
      espacementLignes: screenHeight * 0.02, // UI Design: Espacement adaptatif
      constructeurElement: (context, menu, index) {
        return WidgetCarte.menu(
          menu: menu,
          onTap: () => _ouvrirDetailsMenu(menu),
        );
      },
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Padding adaptatif
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