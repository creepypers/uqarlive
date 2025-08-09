import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/livre.dart';
import '../../domain/entities/association.dart';
import '../../domain/entities/utilisateur.dart';
import '../../domain/repositories/livres_repository.dart';
import '../../domain/repositories/associations_repository.dart';
import '../services/authentification_service.dart';
import 'livres/details_livre_ecran.dart';
import 'associations/associations_ecran.dart';
import 'associations/details_association_ecran.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import '../widgets/widget_carte.dart';
import '../widgets/widget_collection.dart';
import '../services/navigation_service.dart';

// UI Design: Page d'accueil UqarLive avec AppBar, sections échange de livres/assos/cantine et navbar
class AccueilEcran extends StatefulWidget {
  const AccueilEcran({super.key});

  @override
  State<AccueilEcran> createState() => _AccueilEcranState();
}

class _AccueilEcranState extends State<AccueilEcran> {
  // Services et Repositories
  late final LivresRepository _livresRepository;
  late final AssociationsRepository _associationsRepository;
  late final AuthentificationService _authentificationService;
  
  // États des données
  Utilisateur? _utilisateurActuel;
  List<Livre> _mesLivres = [];
  List<Livre> _livresEnVente = [];
  List<Association> _mesAssociations = [];
  bool _chargementLivres = false;
  bool _chargementLivresVente = false;
  bool _chargementAssociations = false;
  bool _chargementUtilisateur = true;

  @override
  void initState() {
    super.initState();
    _initialiserRepositories();
    _chargerDonneesUtilisateur();
  }

  Future<void> _chargerDonneesUtilisateur() async {
    setState(() => _chargementUtilisateur = true);
    
    try {
      await _authentificationService.chargerUtilisateurActuel();
      _utilisateurActuel = _authentificationService.utilisateurActuel;
      
      if (_utilisateurActuel != null) {
        await Future.wait([
          _chargerMesLivres(),
          _chargerLivresEnVente(),
          _chargerMesAssociations(),
        ]);
      }
    } catch (e) {
      // Gérer l'erreur
    } finally {
      setState(() => _chargementUtilisateur = false);
    }
  }

  void _initialiserRepositories() {
    // UI Design: Injection de dépendances via ServiceLocator - Clean Architecture
    _livresRepository = ServiceLocator.obtenirService<LivresRepository>();
    _associationsRepository = ServiceLocator.obtenirService<AssociationsRepository>();
    _authentificationService = ServiceLocator.obtenirService<AuthentificationService>();
  }

  Future<void> _chargerMesLivres() async {
    if (_utilisateurActuel == null) return;
    
    setState(() => _chargementLivres = true);

    try {
      final tousLesLivres = await _livresRepository.obtenirTousLesLivres();
      setState(() {
        // UI Design: Filtrer pour obtenir les livres de l'utilisateur connecté
        _mesLivres = tousLesLivres
            .where((livre) => livre.proprietaireId == _utilisateurActuel!.id)
            .take(5)
            .toList();
        _chargementLivres = false;
      });
    } catch (e) {
      setState(() => _chargementLivres = false);
    }
  }

  Future<void> _chargerLivresEnVente() async {
    setState(() => _chargementLivresVente = true);

    try {
      final tousLesLivres = await _livresRepository.obtenirTousLesLivres();
      setState(() {
        // UI Design: Filtrer pour obtenir seulement les livres en vente
        _livresEnVente = tousLesLivres
            .where((livre) => livre.prix != null && livre.prix! > 0 && livre.estDisponible)
            .take(6)
            .toList();
        _chargementLivresVente = false;
      });
    } catch (e) {
      setState(() => _chargementLivresVente = false);
    }
  }

  Future<void> _chargerMesAssociations() async {
    if (_utilisateurActuel == null) return;
    
    setState(() => _chargementAssociations = true);

    try {
      // UI Design: Pour l'instant, simulation des associations de l'utilisateur
      final toutesLesAssociations = await _associationsRepository.obtenirAssociationsPopulaires(limite: 10);
      setState(() {
        // Simuler que l'utilisateur fait partie de quelques associations
        _mesAssociations = toutesLesAssociations.take(3).toList();
        _chargementAssociations = false;
      });
    } catch (e) {
      setState(() => _chargementAssociations = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI Design: Obtenir les dimensions de l'écran pour l'adaptabilité
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;
    
    // UI Design: Affichage du chargement si les données utilisateur ne sont pas encore chargées
    if (_chargementUtilisateur || _utilisateurActuel == null) {
      return const Scaffold(
        backgroundColor: CouleursApp.fond,
        resizeToAvoidBottomInset: true, // UI Design: Éviter les débordements avec le clavier
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      resizeToAvoidBottomInset: true, // UI Design: Éviter les débordements avec le clavier
      appBar: WidgetBarreAppPersonnalisee(
        titre: 'Bienvenue',
        sousTitre: _utilisateurActuel != null 
            ? '${_utilisateurActuel!.prenom} ${_utilisateurActuel!.nom}'
            : 'Utilisateur',
        utilisateurConnecte: _utilisateurActuel,
        widgetFin: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04, // UI Design: Padding adaptatif
            vertical: screenWidth * 0.02,
          ),
          decoration: BoxDecoration(
            color: CouleursApp.blanc.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.ac_unit,
                color: CouleursApp.blanc,
                size: screenWidth * 0.05, // UI Design: Taille adaptative
              ),
              SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '-5°C',
                    style: TextStyle(
                      color: CouleursApp.blanc,
                      fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                    maxLines: 1,
                  ),
                  Text(
                    'Rimouski',
                    style: TextStyle(
                      color: CouleursApp.blanc.withValues(alpha: 0.8),
                      fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
                    ),
                    overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                    maxLines: 1,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: viewInsets.bottom + padding.bottom, // UI Design: Padding adaptatif pour éviter les débordements
            left: screenWidth * 0.04, // UI Design: Padding adaptatif
            right: screenWidth * 0.04,
            top: screenHeight * 0.02, // UI Design: Espacement adaptatif
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section actualités des assos
              _construireSectionActualites(),
              SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
              
              // Section mes livres
              _construireSectionMesLivres(),
              SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
              
              // Section mes associations
              _construireSectionMesAssociations(),
              SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
              
              // Section cantine
              _construireSectionCantine(),
              SizedBox(height: screenHeight * 0.025), // UI Design: Espacement adaptatif
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBarWidget(
        indexSelectionne: 2, // Accueil
        onTap: (index) => NavigationService.gererNavigationNavBar(context, index),
      ),
    );
  }

  // UI Design: Section mes livres avec WidgetCollection optimisé
  Widget _construireSectionMesLivres() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded( // UI Design: Widget flexible pour éviter les débordements
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mes Livres',
                    style: StylesTexteApp.titre.copyWith(
                      fontSize: screenWidth * 0.055, // UI Design: Taille adaptative
                    ),
                    overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                    maxLines: 1,
                  ),
                  Text(
                    'Vos livres universitaires',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                      color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                NavigationService.gererNavigationNavBar(context, 1); // Index 1 = Livres/Marketplace
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04, // UI Design: Padding adaptatif
                  vertical: screenWidth * 0.02,
                ),
                decoration: BoxDecoration(
                  color: CouleursApp.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: CouleursApp.accent.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Voir tout',
                  style: TextStyle(
                    color: CouleursApp.accent,
                    fontWeight: FontWeight.w500,
                    fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
                  ),
                  overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
        WidgetCollection<Livre>.listeHorizontale(
          elements: _mesLivres,
          enChargement: _chargementLivres,
          hauteur: screenHeight * 0.25, // UI Design: Hauteur adaptative
          espacementHorizontal: screenWidth * 0.03, // UI Design: Espacement adaptatif
          constructeurElement: (context, livre, index) {
            return WidgetCarte.livre(
              livre: livre,
              modeListe: true,
              largeur: screenWidth * 0.4, // UI Design: Largeur adaptative
              hauteur: screenHeight * 0.24, // UI Design: Hauteur adaptative
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DetailsLivreEcran(livre: livre),
                  ),
                );
              },
            );
          },
          messageEtatVide: 'Vous n\'avez pas encore ajouté de livres',
          iconeEtatVide: Icons.menu_book_outlined,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Padding adaptatif
        ),
      ],
    );
  }

  // UI Design: Section livres en vente avec WidgetCollection
  Widget _construireSectionLivresEnVente() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded( // UI Design: Widget flexible pour éviter les débordements
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Livres en Vente',
                    style: StylesTexteApp.titre.copyWith(
                      fontSize: screenWidth * 0.055, // UI Design: Taille adaptative
                    ),
                    overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                    maxLines: 1,
                  ),
                  Text(
                    'Livres disponibles à l\'achat',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                      color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                NavigationService.gererNavigationNavBar(context, 1); // Index 1 = Marketplace
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03, // UI Design: Padding adaptatif
                  vertical: screenWidth * 0.015,
                ),
                decoration: BoxDecoration(
                  color: CouleursApp.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Voir tout',
                      style: TextStyle(
                        color: CouleursApp.accent,
                        fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                      maxLines: 1,
                    ),
                    SizedBox(width: screenWidth * 0.01), // UI Design: Espacement adaptatif
                    Icon(
                      Icons.arrow_forward_ios,
                      color: CouleursApp.accent,
                      size: screenWidth * 0.03, // UI Design: Taille adaptative
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
        
        WidgetCollection<Livre>.listeHorizontale(
          elements: _livresEnVente,
          enChargement: _chargementLivresVente,
          hauteur: screenHeight * 0.25, // UI Design: Hauteur adaptative
          constructeurElement: (context, livre, index) => SizedBox(
            width: screenWidth * 0.35, // UI Design: Largeur adaptative
            child: WidgetCarte.livre(
              livre: livre,
              modeListe: true,
              hauteur: screenHeight * 0.23, // UI Design: Hauteur adaptative
              largeur: screenWidth * 0.35, // UI Design: Largeur adaptative
              onTap: () => _naviguerVersDetailsLivre(livre),
            ),
          ),
          messageEtatVide: 'Aucun livre en vente pour le moment',
          iconeEtatVide: Icons.sell_outlined,
        ),
      ],
    );
  }

  // UI Design: Section mes associations avec design moderne
  Widget _construireSectionMesAssociations() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded( // UI Design: Widget flexible pour éviter les débordements
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mes Associations',
                    style: StylesTexteApp.titre.copyWith(
                      fontSize: screenWidth * 0.055, // UI Design: Taille adaptative
                    ),
                    overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                    maxLines: 1,
                  ),
                  Text(
                    'Vos associations et clubs',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                      color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AssociationsEcran(),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04, // UI Design: Padding adaptatif
                  vertical: screenWidth * 0.02,
                ),
                decoration: BoxDecoration(
                  color: CouleursApp.principal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: CouleursApp.principal.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Explorer',
                  style: TextStyle(
                    color: CouleursApp.principal,
                    fontWeight: FontWeight.w500,
                    fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
                  ),
                  overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
        _chargementAssociations
            ? const Center(child: CircularProgressIndicator())
            : _mesAssociations.isEmpty
                ? Container(
                    padding: EdgeInsets.all(screenWidth * 0.1), // UI Design: Padding adaptatif
                    child: Column(
                      children: [
                        Icon(
                          Icons.groups_outlined,
                          size: screenWidth * 0.15, // UI Design: Taille adaptative
                          color: CouleursApp.principal.withValues(alpha: 0.3),
                        ),
                        SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
                        Text(
                          'Aucune association',
                          style: StylesTexteApp.moyenTitre.copyWith(
                            color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                            fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                          ),
                          overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                          maxLines: 1,
                        ),
                        SizedBox(height: screenHeight * 0.01), // UI Design: Espacement adaptatif
                        Text(
                          'Rejoignez des associations pour enrichir votre expérience étudiante',
                          style: StylesTexteApp.corpsNormal.copyWith(
                            color: CouleursApp.texteFonce.withValues(alpha: 0.5),
                            fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                          maxLines: 2,
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    height: screenHeight * 0.15, // UI Design: Hauteur adaptative
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Padding adaptatif
                      itemCount: _mesAssociations.length,
                      itemBuilder: (context, index) {
                        final association = _mesAssociations[index];
                        return Container(
                          width: screenWidth * 0.5, // UI Design: Largeur adaptative
                          margin: EdgeInsets.only(right: screenWidth * 0.03), // UI Design: Marge adaptative
                          decoration: BoxDecoration(
                            color: CouleursApp.blanc,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: CouleursApp.principal.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsAssociationEcran(association: association),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(screenWidth * 0.04), // UI Design: Padding adaptatif
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(screenWidth * 0.02), // UI Design: Padding adaptatif
                                        decoration: BoxDecoration(
                                          color: CouleursApp.principal.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.groups,
                                          color: CouleursApp.principal,
                                          size: screenWidth * 0.05, // UI Design: Taille adaptative
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.02, // UI Design: Padding adaptatif
                                          vertical: screenWidth * 0.01,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Membre',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: screenWidth * 0.025, // UI Design: Taille adaptative
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.015), // UI Design: Espacement adaptatif
                                  Text(
                                    association.nom,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                                      fontWeight: FontWeight.w600,
                                      color: CouleursApp.texteFonce,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                                  ),
                                  SizedBox(height: screenHeight * 0.005), // UI Design: Espacement adaptatif
                                  Text(
                                    association.typeAssociation.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.028, // UI Design: Taille adaptative
                                      color: CouleursApp.principal,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                                    maxLines: 1,
                                  ),
                                ],
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

  // UI Design: Section actualités des associations avec design moderne
  Widget _construireSectionActualites() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded( // UI Design: Widget flexible pour éviter les débordements
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actualités',
                    style: StylesTexteApp.titre.copyWith(
                      fontSize: screenWidth * 0.055, // UI Design: Taille adaptative
                    ),
                    overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                    maxLines: 1,
                  ),
                  Text(
                    'Nouvelles de vos associations',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                      color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AssociationsEcran(),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04, // UI Design: Padding adaptatif
                  vertical: screenWidth * 0.02,
                ),
                decoration: BoxDecoration(
                  color: CouleursApp.principal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: CouleursApp.principal.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Voir tout',
                  style: TextStyle(
                    color: CouleursApp.principal,
                    fontWeight: FontWeight.w500,
                    fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
                  ),
                  overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
        // UI Design: Liste horizontale d'actualités simulées
        SizedBox(
          height: screenHeight * 0.19, // UI Design: Hauteur adaptative
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Padding adaptatif
            itemCount: 3, // Afficher 3 actualités sur l'accueil
            itemBuilder: (context, index) {
              final actualites = [
                {
                  'titre': 'Tournoi Gaming Inter-Programmes',
                  'association': 'Étudiants Informatique',
                  'date': '25 Jan',
                  'priorite': 'haute',
                },
                {
                  'titre': 'Atelier Gestion du Stress',
                  'association': 'AGEUQAR',
                  'date': '24 Jan',
                  'priorite': 'haute',
                },
                {
                  'titre': 'Collecte Banque Alimentaire',
                  'association': 'Association Humanitaire',
                  'date': 'En cours',
                  'priorite': 'normale',
                },
              ];
              
              final actualite = actualites[index];
              return Container(
                width: screenWidth * 0.45, // UI Design: Largeur adaptative
                margin: EdgeInsets.only(right: screenWidth * 0.03), // UI Design: Marge adaptative
                decoration: BoxDecoration(
                  color: CouleursApp.blanc,
                  borderRadius: BorderRadius.circular(12),
                  border: actualite['priorite'] == 'haute' 
                    ? Border.all(color: CouleursApp.principal, width: 2)
                    : null,
                  boxShadow: [
                    BoxShadow(
                      color: CouleursApp.principal.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03), // UI Design: Padding adaptatif
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge priorité si haute
                      if (actualite['priorite'] == 'haute') ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02, // UI Design: Padding adaptatif
                            vertical: screenWidth * 0.01,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'URGENT',
                            style: TextStyle(
                              color: CouleursApp.blanc,
                              fontSize: screenWidth * 0.025, // UI Design: Taille adaptative
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01), // UI Design: Espacement adaptatif
                      ],
                      // Titre
                      Text(
                        actualite['titre']!,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                          fontWeight: FontWeight.w600,
                          color: CouleursApp.texteFonce,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                      ),
                      const Spacer(),
                      // Association et date
                      Text(
                        actualite['association']!,
                        style: TextStyle(
                          fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
                          color: CouleursApp.principal,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                      ),
                      SizedBox(height: screenHeight * 0.005), // UI Design: Espacement adaptatif
                      Text(
                        actualite['date']!,
                        style: TextStyle(
                          fontSize: screenWidth * 0.028, // UI Design: Taille adaptative
                          color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                        ),
                        overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // UI Design: Section cantine avec WidgetCarte moderne
  Widget _construireSectionCantine() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cantine UQAR',
          style: StylesTexteApp.titre.copyWith(
            fontSize: screenWidth * 0.055, // UI Design: Taille adaptative
          ),
          overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
          maxLines: 1,
        ),
        SizedBox(height: screenHeight * 0.005), // UI Design: Espacement adaptatif
        Text(
          'Découvrez les menus du jour',
          style: TextStyle(
            fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
            color: CouleursApp.texteFonce.withValues(alpha: 0.6),
          ),
          overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
          maxLines: 1,
        ),
        SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
        GestureDetector(
          onTap: () {
            NavigationService.gererNavigationNavBar(context, 0); // Index 0 = Cantine
          },
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [CouleursApp.accent, CouleursApp.accent.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: CouleursApp.accent.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            color: CouleursApp.blanc,
                            size: screenWidth * 0.06, // UI Design: Taille adaptative
                          ),
                          SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
                          Text(
                            'Menu du Jour',
                            style: TextStyle(
                              color: CouleursApp.blanc,
                              fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                            maxLines: 1,
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01), // UI Design: Espacement adaptatif
                      Text(
                        'Pâtes à la sauce marinara, salade césar, dessert du jour',
                        style: TextStyle(
                          color: CouleursApp.blanc.withValues(alpha: 0.9),
                          fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                        ),
                        overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                        maxLines: 2,
                      ),
                      SizedBox(height: screenHeight * 0.015), // UI Design: Espacement adaptatif
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02, // UI Design: Padding adaptatif
                              vertical: screenWidth * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: CouleursApp.blanc.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '12.99\$',
                              style: TextStyle(
                                color: CouleursApp.blanc,
                                fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02, // UI Design: Padding adaptatif
                              vertical: screenWidth * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'VÉG',
                              style: TextStyle(
                                color: CouleursApp.blanc,
                                fontSize: screenWidth * 0.025, // UI Design: Taille adaptative
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: CouleursApp.blanc,
                  size: screenWidth * 0.05, // UI Design: Taille adaptative
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // UI Design: Navigation vers les détails d'un livre
  void _naviguerVersDetailsLivre(Livre livre) {
    Navigator.pushNamed(
      context,
      '/details_livre',
      arguments: livre,
    );
  }
} 