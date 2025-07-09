import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/menu.dart';
import '../../domain/repositories/menus_repository.dart';
import '../../data/repositories/menus_repository_impl.dart';
import '../../data/datasources/menus_datasource_local.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/navigation_service.dart';

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
  List<Menu> _menusPopulaires = [];
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
      final [menusDuJour, menusPopulaires, menusCategorie] = await Future.wait([
        _menusRepository.obtenirMenusDuJour(),
        _menusRepository.obtenirMenusPopulaires(),
        _menusRepository.obtenirMenusParCategorie(_categorieSelectionnee),
      ]);

      setState(() {
        _menusDuJour = menusDuJour;
        _menusPopulaires = menusPopulaires;
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
      appBar: _construireAppBar(),
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
              
              // Section menus populaires
              if (_menusPopulaires.isNotEmpty) ...[
                _construireSectionMenusPopulaires(),
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

  // UI Design: AppBar avec titre et actions
  PreferredSizeWidget _construireAppBar() {
    return AppBar(
      backgroundColor: CouleursApp.principal,
      elevation: 0,
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: CouleursApp.blanc),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Cantine UQAR',
        style: TextStyle(
          color: CouleursApp.blanc,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _afficheVegetarienUniquement ? Icons.eco : Icons.eco_outlined,
            color: _afficheVegetarienUniquement ? Colors.green : CouleursApp.blanc,
          ),
          onPressed: _toggleVegetarien,
        ),
        IconButton(
          icon: Icon(Icons.search, color: CouleursApp.blanc),
          onPressed: () {
            // TODO: Implémenter la recherche
          },
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
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

  // UI Design: Section menus du jour avec scrolling horizontal
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
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _menusDuJour.length,
            itemBuilder: (context, index) {
              return _construireCarteMenuDuJour(_menusDuJour[index]);
            },
          ),
        ),
      ],
    );
  }

  // UI Design: Section menus populaires
  Widget _construireSectionMenusPopulaires() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Populaires',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _menusPopulaires.length,
            itemBuilder: (context, index) {
              return _construireCarteMenuPopulaire(_menusPopulaires[index]);
            },
          ),
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

  // UI Design: Grille des menus par catégorie
  Widget _construireGrilleMenus() {
    if (_chargementMenus) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: CircularProgressIndicator(
            color: CouleursApp.principal,
          ),
        ),
      );
    }

    if (_tousLesMenus.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 48,
                color: CouleursApp.texteFonce.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun menu disponible',
                style: TextStyle(
                  fontSize: 16,
                  color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _tousLesMenus.length,
        itemBuilder: (context, index) {
          return _construireCarteMenu(_tousLesMenus[index]);
        },
      ),
    );
  }

  // UI Design: Carte menu du jour
  Widget _construireCarteMenuDuJour(Menu menu) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [CouleursApp.accent, CouleursApp.principal],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.restaurant,
                    size: 32,
                    color: CouleursApp.blanc,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CouleursApp.blanc.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      menu.prixFormatte,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: CouleursApp.principal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.nom,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: CouleursApp.texteFonce,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    menu.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  _construireBadgesMenu(menu),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Carte menu populaire
  Widget _construireCarteMenuPopulaire(Menu menu) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  menu.nom,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.texteFonce,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 2),
                  Text(
                    menu.note?.toStringAsFixed(1) ?? '—',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            menu.description,
            style: TextStyle(
              fontSize: 11,
              color: CouleursApp.texteFonce.withValues(alpha: 0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                menu.prixFormatte,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: CouleursApp.principal,
                ),
              ),
              _construireBadgesMenu(menu),
            ],
          ),
        ],
      ),
    );
  }

  // UI Design: Carte menu standard
  Widget _construireCarteMenu(Menu menu) {
    return Container(
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: CouleursApp.accent.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    _getIconeCategorie(menu.categorie),
                    size: 32,
                    color: CouleursApp.accent,
                  ),
                ),
                if (!menu.estDisponible)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ÉPUISÉ',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.nom,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: CouleursApp.texteFonce,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    menu.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        menu.prixFormatte,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: CouleursApp.principal,
                        ),
                      ),
                      _construireBadgesMenu(menu),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widgets utilitaires
  Widget _construireBadgesMenu(Menu menu) {
    final badges = menu.badges;
    if (badges.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      children: badges.take(2).map((badge) {
        Color couleur = CouleursApp.accent;
        if (badge == 'VEGAN' || badge == 'VÉGÉ') couleur = Colors.green;
        if (badge == 'ÉPUISÉ') couleur = Colors.red;
        if (badge == 'POPULAIRE') couleur = Colors.amber;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: couleur.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: couleur.withValues(alpha: 0.3)),
          ),
          child: Text(
            badge,
            style: TextStyle(
              fontSize: 8,
              color: couleur,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconeCategorie(String categorie) {
    switch (categorie) {
      case 'menu_jour': return Icons.restaurant;
      case 'plat': return Icons.dinner_dining;
      case 'snack': return Icons.fastfood;
      case 'dessert': return Icons.cake;
      case 'boisson': return Icons.local_drink;
      default: return Icons.restaurant_menu;
    }
  }
} 