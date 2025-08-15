import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/menu.dart';
import '../../../domain/repositories/menus_repository.dart';
import '../../../domain/repositories/horaires_repository.dart';
import '../../../presentation/widgets/navbar_widget.dart';
import '../../../presentation/widgets/widget_barre_app_personnalisee.dart';
import '../../../presentation/widgets/widget_carte.dart';
import '../../../presentation/widgets/widget_collection.dart';
import '../../../presentation/widgets/widget_section_statistiques.dart';
import '../../../presentation/widgets/widget_bouton_conversations.dart';
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
  late final HorairesRepository _horairesRepository; // UI Design: Horaires dynamiques
  Menu? _menuDuJourSpecial; // UI Design: Menu du jour spécial défini par l'admin
  List<Menu> _tousLesMenus = [];
  List<Menu> _menusFiltres = [];
  Map<String, Map<String, TimeOfDay>> _horaires = {}; // UI Design: Horaires de la cantine
  StatistiquesGlobales? _statistiques;
  String _categorieSelectionnee = 'menu_jour';
  bool _chargementMenus = false;
  bool _afficheVegetarienUniquement = false;
  
  // Variables pour la recherche
  final TextEditingController _controleurRecherche = TextEditingController();
  String _termeRecherche = '';

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

  @override
  void dispose() {
    _controleurRecherche.dispose();
    super.dispose();
  }

  void _initialiserRepositories() {
    _menusRepository = ServiceLocator.obtenirService<MenusRepository>();
    _statistiquesService = ServiceLocator.obtenirService<StatistiquesService>();
    _horairesRepository = ServiceLocator.obtenirService<HorairesRepository>(); // UI Design: Horaires dynamiques
  }

  Future<void> _chargerDonnees() async {
    setState(() {
      _chargementMenus = true;
    });

    try {
      final results = await Future.wait([
        _menusRepository.obtenirMenusDuJour(),
        _menusRepository.obtenirTousLesMenus(), // UI Design: Charger tous les menus pour le filtrage local
        _statistiquesService.obtenirStatistiquesGlobales(),
        _menusRepository.obtenirMenuDuJourActuel(), // UI Design: Menu du jour spécial
        _horairesRepository.obtenirTousLesHorairesCantine(), // UI Design: Horaires dynamiques
      ]);

      setState(() {
        _tousLesMenus = results[1] as List<Menu>;
        _menusFiltres = results[1] as List<Menu>; // UI Design: Initialiser les menus filtrés
        _statistiques = results[2] as StatistiquesGlobales;
        _horaires = results[4] as Map<String, Map<String, TimeOfDay>>; // UI Design: Horaires dynamiques
        
        // UI Design: Récupérer le menu du jour spécial défini par l'admin
        final menuDuJourId = results[3] as String?;
        if (menuDuJourId != null && menuDuJourId.isNotEmpty) {
          try {
            _menuDuJourSpecial = _tousLesMenus.firstWhere(
              (menu) => menu.id == menuDuJourId,
            );
          } catch (e) {
            // Menu du jour non trouvé dans la liste
            _menuDuJourSpecial = null;
          }
        } else {
          _menuDuJourSpecial = null;
        }
        
        _chargementMenus = false;
      });
    } catch (e) {
      setState(() {
        _chargementMenus = false;
      });
    }
  }



  // UI Design: Implémenter la recherche de menus par nom, description ou catégorie
  void _rechercherMenus(String terme) {
    setState(() {
      _termeRecherche = terme.toLowerCase().trim();
      _appliquerFiltres();
    });
  }

  // UI Design: Appliquer tous les filtres (recherche + catégorie + végétarien)
  void _appliquerFiltres() {
    List<Menu> menusFiltres = _tousLesMenus;

    // Filtre par terme de recherche
    if (_termeRecherche.isNotEmpty) {
      menusFiltres = menusFiltres.where((menu) {
        return menu.nom.toLowerCase().contains(_termeRecherche) ||
               menu.description.toLowerCase().contains(_termeRecherche) ||
               menu.categorie.toLowerCase().contains(_termeRecherche) ||
               menu.ingredients.any((ingredient) => ingredient.toLowerCase().contains(_termeRecherche));
      }).toList();
    }

    // Filtre par catégorie
    if (_categorieSelectionnee != 'menu_jour') {
      menusFiltres = menusFiltres.where((menu) => 
          menu.categorie == _categorieSelectionnee).toList();
    }

    // Filtre végétarien
    if (_afficheVegetarienUniquement) {
      menusFiltres = menusFiltres.where((menu) => 
          menu.estVegetarien).toList();
    }

    setState(() {
      _menusFiltres = menusFiltres;
    });
  }

  // UI Design: Ouvrir l'interface de recherche
  void _ouvrirRecherche() {
    showDialog(
      context: context,
      builder: (context) => _construireDialogueRecherche(),
    );
  }

  // UI Design: Construire le dialogue de recherche
  Widget _construireDialogueRecherche() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Rechercher un menu'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controleurRecherche,
            autofocus: true,
            style: StylesTexteApp.champ,
            decoration: InputDecoration(
              hintText: 'Nom, description, ingrédient...',
              hintStyle: StylesTexteApp.champ.copyWith(
                color: CouleursApp.texteFonce.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: CouleursApp.principal.withValues(alpha: 0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: CouleursApp.principal.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: CouleursApp.principal, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: _rechercherMenus,
          ),
          const SizedBox(height: 16),
          if (_termeRecherche.isNotEmpty) 
            Text(
              '${_menusFiltres.length} menu(s) trouvé(s)',
              style: StylesTexteApp.champ.copyWith(
                color: CouleursApp.principal,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _controleurRecherche.clear();
            _rechercherMenus('');
            Navigator.pop(context);
          },
          child: Text(
            'Effacer',
            style: TextStyle(color: CouleursApp.texteFonce.withValues(alpha: 0.6)),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: CouleursApp.principal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Fermer', style: TextStyle(color: CouleursApp.blanc)),
        ),
      ],
    );
  }

  Future<void> _changerCategorie(String nouvelleCategorie) async {
    setState(() {
      _categorieSelectionnee = nouvelleCategorie;
    });
    
    // UI Design: Utiliser le filtrage local au lieu de recharger depuis le repository
    _appliquerFiltres();
  }

  Future<void> _toggleVegetarien() async {
    setState(() {
      _afficheVegetarienUniquement = !_afficheVegetarienUniquement;
    });
    // UI Design: Utiliser le filtrage local
    _appliquerFiltres();
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
              onTap: _ouvrirRecherche, // UI Design: Recherche implementée
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
              
              // Section menu du jour spécial (défini par l'admin)
              if (_menuDuJourSpecial != null) ...[
                _construireSectionMenuDuJourSpecial(),
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

      // UI Design: Widget réutilisable pour accéder aux conversations
      floatingActionButton: const WidgetBoutonConversations(),

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

    // UI Design: Obtenir les horaires du jour actuel
    final maintenant = DateTime.now();
    final jourActuel = _obtenirJourSemaine(maintenant.weekday);
    final horairesDuJour = _horaires[jourActuel];
    
    String horairesText = 'Fermé';
    Color horairesColor = Colors.red;
    
    if (horairesDuJour != null) {
      final ouverture = horairesDuJour['ouverture'];
      final fermeture = horairesDuJour['fermeture'];
      
      if (ouverture != null && fermeture != null) {
        horairesText = '${_formatterHeure(ouverture)} - ${_formatterHeure(fermeture)}';
        
        // UI Design: Vérifier si c'est ouvert maintenant
        final heureActuelle = TimeOfDay.now();
        final estOuvert = _estDansCreneauHoraire(heureActuelle, ouverture, fermeture);
        horairesColor = estOuvert ? Colors.green : CouleursApp.accent;
      }
    }

    return WidgetSectionStatistiques.cantine(
      titre: 'Horaires & Infos',
      iconeTitre: Icons.restaurant,
      statistiques: [
        {
          'valeur': horairesText,
          'label': 'Aujourd\'hui ($jourActuel)',
          'icone': Icons.access_time,
          'couleur': horairesColor,
        },
        {
          'valeur': '${_statistiques!.capaciteTotal} places',
          'label': 'Capacité',
          'icone': Icons.people,
          'couleur': CouleursApp.accent,
        },
        {
          'valeur': ' 24${_statistiques!.prixMoyen.toStringAsFixed(2)}',
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

  // UI Design: Section menu du jour spécial défini par l'admin
  Widget _construireSectionMenuDuJourSpecial() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec badge spécial
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.025),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.star,
                  color: Colors.white,
                  size: screenWidth * 0.06,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                    Text(
                      'Menu du Jour Spécial',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: CouleursApp.texteFonce,
                      ),
                    ),
                    Text(
                      'Recommandé par notre chef',
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.025,
                  vertical: screenWidth * 0.015,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'NOUVEAU',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.025,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          
          // Carte menu spécial premium
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.withValues(alpha: 0.1),
                  Colors.deepOrange.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _ouvrirDetailsMenu(_menuDuJourSpecial!),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
          child: Row(
                    children: [
                      // Image ou icône du menu
                      Container(
                        width: screenWidth * 0.2,
                        height: screenWidth * 0.2,
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.restaurant_menu,
                          color: Colors.orange.shade700,
                          size: screenWidth * 0.08,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      
                      // Informations du menu
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _menuDuJourSpecial!.nom,
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.bold,
                                color: CouleursApp.texteFonce,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Text(
                              _menuDuJourSpecial!.description,
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            
                            // Prix et badges
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.025,
                                    vertical: screenWidth * 0.01,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    ' 24${_menuDuJourSpecial!.prix.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.035,
                                    ),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                if (_menuDuJourSpecial!.estVegetarien)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02,
                                      vertical: screenWidth * 0.008,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                                          Icons.eco,
                                          size: screenWidth * 0.03,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
              Text(
                                          _menuDuJourSpecial!.estVegan ? 'VEGAN' : 'VÉGÉ',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.025,
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Flèche
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.orange.shade700,
                        size: screenWidth * 0.05,
              ),
            ],
          ),
        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Section menus du jour avec WidgetCollection optimisé/ UI Design: Filtres et catégories
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
      elements: _menusFiltres, // UI Design: Utiliser les menus filtrés pour l'affichage
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

  // UI Design: Méthodes utilitaires pour les horaires
  String _obtenirJourSemaine(int weekday) {
    const jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return jours[weekday - 1];
  }

  String _formatterHeure(TimeOfDay heure) {
    final minute = heure.minute.toString().padLeft(2, '0');
    return '${heure.hour}h$minute';
  }

  bool _estDansCreneauHoraire(TimeOfDay maintenant, TimeOfDay ouverture, TimeOfDay fermeture) {
    final maintenantMinutes = maintenant.hour * 60 + maintenant.minute;
    final ouvertureMinutes = ouverture.hour * 60 + ouverture.minute;
    final fermetureMinutes = fermeture.hour * 60 + fermeture.minute;
    
    return maintenantMinutes >= ouvertureMinutes && maintenantMinutes <= fermetureMinutes;
  }
} 