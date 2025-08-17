import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/livre.dart';
import '../../domain/entities/association.dart';
import '../../domain/entities/utilisateur.dart';
import '../../domain/entities/actualite.dart';
import '../../domain/entities/evenement.dart';
import '../../domain/usercases/livres_repository.dart';
import '../../domain/usercases/associations_repository.dart';
import '../../domain/usercases/actualites_repository.dart';
import '../../domain/usercases/evenements_repository.dart';
import '../../domain/usercases/membres_association_repository.dart';
import '../services/authentification_service.dart';
import 'livres/details_livre_ecran.dart';

import 'associations/associations_ecran.dart';
import 'associations/details_association_ecran.dart';
import 'associations/actualites/actualites_ecran.dart';
import 'associations/evenements/evenements_ecran.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import '../widgets/widget_carte.dart';
import '../widgets/widget_collection.dart';
import '../widgets/widget_bouton_conversations.dart';
import '../services/navigation_service.dart';
import '../services/meteo_service.dart';
import '../../domain/entities/meteo.dart';
import '../../domain/entities/menu.dart'; 
import '../../domain/usercases/menus_repository.dart'; 


class AccueilEcran extends StatefulWidget {
  const AccueilEcran({super.key});

  @override
  State<AccueilEcran> createState() => _AccueilEcranState();
}

class _AccueilEcranState extends State<AccueilEcran> {
  // Services et Repositories
  late final LivresRepository _livresRepository;
  late final AssociationsRepository _associationsRepository;
  late final ActualitesRepository _actualitesRepository;
  late final EvenementsRepository _evenementsRepository;
  late final AuthentificationService _authentificationService;
  late final MembresAssociationRepository _membresAssociationRepository;
  late final MeteoService _meteoService;
  late final MenusRepository _menusRepository; 
  
  // États des données
  Utilisateur? _utilisateurActuel;
  List<Livre> _mesLivres = [];
  List<Association> _mesAssociations = [];
  List<Actualite> _actualites = []; 
  List<Evenement> _evenements = []; 
  final Map<String, String> _rolesAssociations = {}; // Stocker les rôles des associations
  bool _chargementLivres = false;
  bool _chargementAssociations = false;
  bool _chargementActualites = false; 
  bool _chargementEvenements = false; 
  bool _chargementUtilisateur = true;
  bool _donneesChargees = false; // Éviter le rechargement inutile
  Meteo? _meteoRimouski;
  Meteo? _meteoLevis;
  Menu? _menuDuJour; 
  bool _chargementMenuDuJour = false; 

  @override
  void initState() {
    super.initState();
    _initialiserRepositories();
    _chargerDonneesUtilisateur();
  }

  Future<void> _chargerMeteo() async {
    try {
      final rim = await _meteoService.temperatureRimouski();
      final lev = await _meteoService.temperatureLevis();
      if (mounted) {
        setState(() {
          _meteoRimouski = rim;
          _meteoLevis = lev;
        });
      }
    } catch (_) {
      // silencieux si l'API échoue
    }
  }

  Future<void> _chargerDonneesUtilisateur() async {
    // Éviter le rechargement si les données sont déjà chargées
    if (_donneesChargees && _utilisateurActuel != null) {
      return;
    }
    
    setState(() => _chargementUtilisateur = true);
    
    try {
      await _authentificationService.chargerUtilisateurActuel();
      _utilisateurActuel = _authentificationService.utilisateurActuel;
      
      if (_utilisateurActuel != null) {
        await Future.wait([
          _chargerMesLivres(),
          _chargerMesAssociations(),
          _chargerActualites(), 
          _chargerEvenements(), 
          _chargerMeteo(),
          _chargerMenuDuJour(), 
        ]);
        _donneesChargees = true;
      } else {
        
        await _chargerActualites();
        await _chargerMeteo();
      }
    } catch (e) {
      // Gérer l'erreur
    } finally {
      setState(() => _chargementUtilisateur = false);
    }
  }

  void _initialiserRepositories() {
    
    _livresRepository = ServiceLocator.obtenirService<LivresRepository>();
    _associationsRepository = ServiceLocator.obtenirService<AssociationsRepository>();
    _actualitesRepository = ServiceLocator.obtenirService<ActualitesRepository>();
    _evenementsRepository = ServiceLocator.obtenirService<EvenementsRepository>();
    _authentificationService = ServiceLocator.obtenirService<AuthentificationService>();
    _membresAssociationRepository = ServiceLocator.obtenirService<MembresAssociationRepository>();
    _meteoService = ServiceLocator.obtenirService<MeteoService>();
    _menusRepository = ServiceLocator.obtenirService<MenusRepository>(); 
  }

  Future<void> _chargerMesLivres() async {
    if (_utilisateurActuel == null) return;
    
    setState(() => _chargementLivres = true);

    try {
      final tousLesLivres = await _livresRepository.obtenirTousLesLivres();
      setState(() {
        
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



  Future<void> _chargerMesAssociations() async {
    if (_utilisateurActuel == null) return;
    
    setState(() => _chargementAssociations = true);

    try {
      // Récupérer les memberships de l'utilisateur
      final memberships = await _membresAssociationRepository.obtenirMembresParUtilisateur(_utilisateurActuel!.id);
      
      // Récupérer les détails des associations pour chaque membership
      final List<Association> associations = [];
      _rolesAssociations.clear(); // Réinitialiser les rôles
      
      for (final membership in memberships) {
        try {
          final toutesAssociations = await _associationsRepository.obtenirAssociationsPopulaires(limite: 50);
          final association = toutesAssociations.firstWhere(
            (assoc) => assoc.id == membership.associationId,
            orElse: () => throw Exception('Association non trouvée'),
          );
          associations.add(association);
          
          // Stocker le rôle formaté de l'utilisateur dans cette association
          _rolesAssociations[association.id] = membership.roleFormate;
        } catch (e) {
          // Ignorer si l'association n'est pas trouvée
        }
      }
      
      setState(() {
        _mesAssociations = associations.take(3).toList(); // Limiter à 3 pour l'accueil
        _chargementAssociations = false;
      });
    } catch (e) {
      setState(() {
        _mesAssociations = [];
        _chargementAssociations = false;
        _rolesAssociations.clear();
      });
    }
  }

  
  Future<void> _chargerActualites() async {
    setState(() => _chargementActualites = true);

    try {
      // Charger toutes les actualités pour avoir un mélange de priorités
        final toutesActualites = await _actualitesRepository.obtenirActualites();
      
      // Prioriser les actualités épinglées et urgentes
      final actualitesTriees = List<Actualite>.from(toutesActualites);
      actualitesTriees.sort((a, b) {
        // D'abord les épinglées
        if (a.estEpinglee && !b.estEpinglee) return -1;
        if (!a.estEpinglee && b.estEpinglee) return 1;
        
        // Puis par priorité (urgente > importante > normale)
        final prioriteA = a.priorite == 'urgente' ? 3 : (a.priorite == 'importante' ? 2 : 1);
        final prioriteB = b.priorite == 'urgente' ? 3 : (b.priorite == 'importante' ? 2 : 1);
        if (prioriteA != prioriteB) return prioriteB.compareTo(prioriteA);
        
        // Enfin par date (plus récent en premier)
        return b.datePublication.compareTo(a.datePublication);
      });
      
        setState(() {
        
        _actualites = actualitesTriees.take(3).toList();
          _chargementActualites = false;
        });
    } catch (e) {
        setState(() => _chargementActualites = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;
    
    
    if (_chargementUtilisateur || _utilisateurActuel == null) {
      return const Scaffold(
        backgroundColor: CouleursApp.fond,
        resizeToAvoidBottomInset: true, 
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      resizeToAvoidBottomInset: true, 
      appBar: WidgetBarreAppPersonnalisee(
        titre: 'Bienvenue',
        sousTitre: _utilisateurActuel != null 
            ? '${_utilisateurActuel!.prenom} ${_utilisateurActuel!.nom}'
            : 'Utilisateur',
        utilisateurConnecte: _utilisateurActuel,
        widgetFin: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04, 
            vertical: screenWidth * 0.02,
          ),
          decoration: BoxDecoration(
            color: CouleursApp.blanc.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.thermostat, color: CouleursApp.blanc, size: screenWidth * 0.05),
              SizedBox(width: screenWidth * 0.02),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _meteoRimouski != null ? '${_meteoRimouski!.temperatureCelsius.toStringAsFixed(0)}°C' : '—',
                    style: TextStyle(
                      color: CouleursApp.blanc,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    _meteoRimouski?.ville ?? 'Rimouski',
                    style: TextStyle(
                      color: CouleursApp.blanc.withValues(alpha: 0.8),
                      fontSize: screenWidth * 0.03,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
              SizedBox(width: screenWidth * 0.04),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _meteoLevis != null ? '${_meteoLevis!.temperatureCelsius.toStringAsFixed(0)}°C' : '—',
                    style: TextStyle(
                      color: CouleursApp.blanc,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    _meteoLevis?.ville ?? 'Lévis',
                    style: TextStyle(
                      color: CouleursApp.blanc.withValues(alpha: 0.8),
                      fontSize: screenWidth * 0.03,
                    ),
                    overflow: TextOverflow.ellipsis,
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
            bottom: viewInsets.bottom + padding.bottom, 
            left: screenWidth * 0.04, 
            right: screenWidth * 0.04,
            top: screenHeight * 0.02, 
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section actualités des assos
              _construireSectionActualites(),
              SizedBox(height: screenHeight * 0.03), 
              
              // Section mes livres
              _construireSectionMesLivres(),
              SizedBox(height: screenHeight * 0.03), 
              
              // Section mes associations
              _construireSectionMesAssociations(),
              SizedBox(height: screenHeight * 0.03), 
              
              // Section événements à venir
              _construireSectionEvenements(),
              SizedBox(height: screenHeight * 0.03), 
              
              // Section cantine
              _construireSectionCantine(),
              SizedBox(height: screenHeight * 0.025), 
            ],
          ),
        ),
      ),

      
      floatingActionButton: const WidgetBoutonConversations(),

      bottomNavigationBar: NavBarWidget(
        indexSelectionne: 2, // Accueil
        onTap: (index) => NavigationService.gererNavigationNavBar(context, index),
      ),
    );
  }

  
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
            Expanded( 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mes Livres',
                    style: StylesTexteApp.titre.copyWith(
                      fontSize: screenWidth * 0.055, 
                    ),
                    overflow: TextOverflow.ellipsis, 
                    maxLines: 1,
                  ),
                  Text(
                    'Vos livres universitaires',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035, 
                      color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis, 
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
                  horizontal: screenWidth * 0.04, 
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
                    fontSize: screenWidth * 0.03, 
                  ),
                  overflow: TextOverflow.ellipsis, 
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02), 
        WidgetCollection<Livre>.listeHorizontale(
          elements: _mesLivres,
          enChargement: _chargementLivres,
          hauteur: screenHeight * 0.25, 
          espacementHorizontal: screenWidth * 0.03, 
          constructeurElement: (context, livre, index) {
            return WidgetCarte.livre(
              livre: livre,
              modeListe: true,
              largeur: screenWidth * 0.4, 
              hauteur: screenHeight * 0.24, 
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
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), 
        ),
      ],
    );
  }



  
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
            Expanded( 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mes Associations',
                    style: StylesTexteApp.titre.copyWith(
                      fontSize: screenWidth * 0.055, 
                    ),
                    overflow: TextOverflow.ellipsis, 
                    maxLines: 1,
                  ),
                  Text(
                    'Vos associations et clubs',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035, 
                      color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis, 
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
                  horizontal: screenWidth * 0.04, 
                  vertical: screenWidth * 0.02,
                ),
                decoration: BoxDecoration(
                  color: CouleursApp.principal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: CouleursApp.principal.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Voir plus',
                  style: TextStyle(
                    color: CouleursApp.principal,
                    fontWeight: FontWeight.w500,
                    fontSize: screenWidth * 0.03, 
                  ),
                  overflow: TextOverflow.ellipsis, 
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02), 
        _chargementAssociations
            ? const Center(child: CircularProgressIndicator())
            : _mesAssociations.isEmpty
                ? Container(
                    padding: EdgeInsets.all(screenWidth * 0.1), 
                    child: Column(
                      children: [
                        Icon(
                          Icons.groups_outlined,
                          size: screenWidth * 0.15, 
                          color: CouleursApp.principal.withValues(alpha: 0.3),
                        ),
                        SizedBox(height: screenHeight * 0.02), 
                        Text(
                          'Aucune association',
                          style: StylesTexteApp.moyenTitre.copyWith(
                            color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                            fontSize: screenWidth * 0.045, 
                          ),
                          overflow: TextOverflow.ellipsis, 
                          maxLines: 1,
                        ),
                        SizedBox(height: screenHeight * 0.01), 
                        Text(
                          'Rejoignez des associations pour enrichir votre expérience étudiante',
                          style: StylesTexteApp.corpsNormal.copyWith(
                            color: CouleursApp.texteFonce.withValues(alpha: 0.5),
                            fontSize: screenWidth * 0.035, 
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis, 
                          maxLines: 2,
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    height: screenHeight * 0.15, 
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), 
                      itemCount: _mesAssociations.length,
                      itemBuilder: (context, index) {
                        final association = _mesAssociations[index];
                        return Container(
                          width: screenWidth * 0.5, 
                          margin: EdgeInsets.only(right: screenWidth * 0.03), 
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
                              padding: EdgeInsets.all(screenWidth * 0.04), 
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(screenWidth * 0.02), 
                                        decoration: BoxDecoration(
                                          color: CouleursApp.principal.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.groups,
                                          color: CouleursApp.principal,
                                          size: screenWidth * 0.05, 
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.02), 
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.02, 
                                          vertical: screenWidth * 0.01,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _obtenirCouleurRole(_rolesAssociations[association.id] ?? 'Membre').withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          _rolesAssociations[association.id] ?? 'Membre',
                                          style: TextStyle(
                                            color: _obtenirCouleurRole(_rolesAssociations[association.id] ?? 'Membre'),
                                            fontSize: screenWidth * 0.025, 
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis, 
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.015), 
                                  Text(
                                    association.nom,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035, 
                                      fontWeight: FontWeight.w600,
                                      color: CouleursApp.texteFonce,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis, 
                                  ),
                                  SizedBox(height: screenHeight * 0.005), 
                                  Text(
                                    association.typeAssociation.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.028, 
                                      color: CouleursApp.principal,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis, 
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
            Expanded( 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actualités',
                    style: StylesTexteApp.titre.copyWith(
                      fontSize: screenWidth * 0.055, 
                    ),
                    overflow: TextOverflow.ellipsis, 
                    maxLines: 1,
                  ),
                  Text(
                    'Nouvelles de vos associations',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035, 
                      color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis, 
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
                    builder: (context) => const ActualitesEcran(),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04, 
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
                    fontSize: screenWidth * 0.03, 
                  ),
                  overflow: TextOverflow.ellipsis, 
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02), 
        
        SizedBox(
          height: screenHeight * 0.19, 
          child: _chargementActualites
            ? const Center(
                child: CircularProgressIndicator(
                  color: CouleursApp.principal,
                  strokeWidth: 2,
                ),
              )
            : _actualites.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.newspaper_outlined,
                        size: screenWidth * 0.1,
                        color: CouleursApp.texteFonce.withValues(alpha: 0.3),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Aucune actualité disponible',
                        style: TextStyle(
                          color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), 
                  itemCount: _actualites.length,
                  itemBuilder: (context, index) {
                    final actualite = _actualites[index];
              return Container(
                width: screenWidth * 0.45, 
                margin: EdgeInsets.only(right: screenWidth * 0.03), 
                decoration: BoxDecoration(
                  color: CouleursApp.blanc,
                  borderRadius: BorderRadius.circular(12),
                  border: actualite.priorite == 'urgente' 
                    ? Border.all(color: Colors.red, width: 2)
                    : actualite.priorite == 'importante'
                      ? Border.all(color: Colors.orange, width: 1.5)
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
                  padding: EdgeInsets.all(screenWidth * 0.03), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges priorité et épinglé
                      Row(
                        children: [
                          // Badge priorité
                          if (actualite.priorite == 'urgente') ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02, 
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
                              fontSize: screenWidth * 0.025, 
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis, 
                            maxLines: 1,
                          ),
                        ),
                            SizedBox(width: screenWidth * 0.02), 
                          ] else if (actualite.priorite == 'importante') ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02, 
                                vertical: screenWidth * 0.01,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'IMPORTANT',
                                style: TextStyle(
                                  color: CouleursApp.blanc,
                                  fontSize: screenWidth * 0.025, 
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis, 
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02), 
                          ],
                          // Badge épinglé
                          if (actualite.estEpinglee) ...[
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.01),
                              decoration: BoxDecoration(
                                color: CouleursApp.principal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.push_pin,
                                color: CouleursApp.principal,
                                size: screenWidth * 0.03,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (actualite.priorite == 'urgente' || actualite.priorite == 'importante' || actualite.estEpinglee)
                        SizedBox(height: screenHeight * 0.01), 
                      // Titre
                      Text(
                        actualite.titre,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035, 
                          fontWeight: FontWeight.w600,
                          color: CouleursApp.texteFonce,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis, 
                      ),
                      const Spacer(),
                      // Association et date
                      Text(
                        _obtenirNomAssociation(actualite.associationId),
                        style: TextStyle(
                          fontSize: screenWidth * 0.03, 
                          color: CouleursApp.principal,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, 
                      ),
                      SizedBox(height: screenHeight * 0.005), 
                      Text(
                        _formaterDateActualite(actualite.datePublication),
                        style: TextStyle(
                          fontSize: screenWidth * 0.028, 
                          color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                        ),
                        overflow: TextOverflow.ellipsis, 
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
            fontSize: screenWidth * 0.055, 
          ),
          overflow: TextOverflow.ellipsis, 
          maxLines: 1,
        ),
        SizedBox(height: screenHeight * 0.005), 
        Text(
          'Découvrez les menus du jour',
          style: TextStyle(
            fontSize: screenWidth * 0.035, 
            color: CouleursApp.texteFonce.withValues(alpha: 0.6),
          ),
          overflow: TextOverflow.ellipsis, 
          maxLines: 1,
        ),
        SizedBox(height: screenHeight * 0.02), 
        GestureDetector(
          onTap: () {
            NavigationService.gererNavigationNavBar(context, 0); // Index 0 = Cantine
          },
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.05), 
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
                            size: screenWidth * 0.06, 
                          ),
                          SizedBox(width: screenWidth * 0.02), 
                          Text(
                            'Menu du Jour',
                            style: TextStyle(
                              color: CouleursApp.blanc,
                              fontSize: screenWidth * 0.045, 
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis, 
                            maxLines: 1,
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01), 
                      _chargementMenuDuJour
                        ? const Center(child: CircularProgressIndicator())
                        : _menuDuJour == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.restaurant_menu,
                                      color: CouleursApp.blanc.withValues(alpha: 0.5),
                                      size: screenWidth * 0.08, 
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    Text(
                                      'Aucun menu disponible',
                                      style: TextStyle(
                                        color: CouleursApp.blanc.withValues(alpha: 0.7),
                                        fontSize: screenWidth * 0.035, 
                                      ),
                                      overflow: TextOverflow.ellipsis, 
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _menuDuJour!.nom,
                                    style: TextStyle(
                                      color: CouleursApp.blanc.withValues(alpha: 0.9),
                                      fontSize: screenWidth * 0.035, 
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis, 
                                    maxLines: 2,
                                  ),
                                  SizedBox(height: screenHeight * 0.015), 
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.02, 
                                          vertical: screenWidth * 0.01,
                                        ),
                                        decoration: BoxDecoration(
                                          color: CouleursApp.blanc.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _menuDuJour!.prixFormatte,
                                          style: TextStyle(
                                            color: CouleursApp.blanc,
                                            fontSize: screenWidth * 0.03, 
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis, 
                                          maxLines: 1,
                                        ),
                                      ),
                                      if (_menuDuJour!.estVegetarien) ...[
                                        SizedBox(width: screenWidth * 0.02), 
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.02, 
                                            vertical: screenWidth * 0.01,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(alpha: 0.8),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _menuDuJour!.estVegan ? 'VEGAN' : 'VÉG',
                                            style: TextStyle(
                                              color: CouleursApp.blanc,
                                              fontSize: screenWidth * 0.025, 
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis, 
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: CouleursApp.blanc,
                  size: screenWidth * 0.05, 
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  
  String _formaterDateActualite(DateTime datePublication) {
    final maintenant = DateTime.now();
    final difference = maintenant.difference(datePublication);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      final semaines = (difference.inDays / 7).floor();
      return semaines == 1 ? 'Il y a 1 semaine' : 'Il y a $semaines semaines';
    } else {
      // Format court: jour/mois
      return '${datePublication.day}/${datePublication.month}';
    }
  }

  
  Color _obtenirCouleurRole(String role) {
    switch (role.toLowerCase()) {
      case 'président':
      case 'chef':
        return Colors.purple;
      case 'vice-président':
        return Colors.blue;
      case 'trésorier':
        return Colors.orange;
      case 'secrétaire':
        return Colors.teal;
      case 'membre du bureau':
        return Colors.indigo;
      default:
        return Colors.green;
    }
  }



  
  String _obtenirNomAssociation(String associationId) {
    if (associationId == 'admin_general') return 'UQAR - Administration';
    
    try {
      final association = _mesAssociations.firstWhere(
        (assoc) => assoc.id == associationId,
        orElse: () => throw Exception('Association non trouvée'),
      );
      return association.nom;
    } catch (e) {
      return 'Association';
    }
  }

  
  Future<void> _chargerEvenements() async {
    setState(() => _chargementEvenements = true);

    try {
      // Charger tous les événements à venir
      final tousEvenements = await _evenementsRepository.obtenirEvenements();
      
      // Filtrer pour obtenir seulement les événements à venir
      final evenementsAVenir = tousEvenements
          .where((e) => e.estAVenir)
          .take(3) // Limiter à 3 événements pour l'accueil
          .toList();
      
      setState(() {
        _evenements = evenementsAVenir;
        _chargementEvenements = false;
      });
    } catch (e) {
      setState(() => _chargementEvenements = false);
    }
  }

  
  Future<void> _chargerMenuDuJour() async {
    setState(() => _chargementMenuDuJour = true);
    try {
      final menusDuJour = await _menusRepository.obtenirMenusDuJour();
      if (menusDuJour.isNotEmpty) {
        setState(() {
          _menuDuJour = menusDuJour.first; // Prendre le premier menu du jour
        });
      }
    } catch (e) {
      // Gérer l'erreur
    } finally {
      setState(() => _chargementMenuDuJour = false);
    }
  }

  
  Widget _construireSectionEvenements() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded( 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Événements à Venir',
                    style: StylesTexteApp.titre.copyWith(
                      fontSize: screenWidth * 0.055, 
                    ),
                    overflow: TextOverflow.ellipsis, 
                    maxLines: 1,
                  ),
                  Text(
                    'Prochains événements de vos associations',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035, 
                      color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis, 
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
                    builder: (context) => const EvenementsEcran(),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04, 
                  vertical: screenWidth * 0.02,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Voir tout',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                    fontSize: screenWidth * 0.03, 
                  ),
                  overflow: TextOverflow.ellipsis, 
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02), 
        
        SizedBox(
          height: screenHeight * 0.19, 
          child: _chargementEvenements
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.orange,
                  strokeWidth: 2,
                ),
              )
            : _evenements.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_outlined,
                        size: screenWidth * 0.1,
                        color: CouleursApp.texteFonce.withValues(alpha: 0.3),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Aucun événement à venir',
                        style: TextStyle(
                          color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), 
                  itemCount: _evenements.length,
                  itemBuilder: (context, index) {
                    final evenement = _evenements[index];
                    return Container(
                      width: screenWidth * 0.45, 
                      margin: EdgeInsets.only(right: screenWidth * 0.03), 
                      decoration: BoxDecoration(
                        color: CouleursApp.blanc,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.03), 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Type d'événement avec icône
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(screenWidth * 0.02),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _obtenirIconeTypeEvenement(evenement.typeEvenement),
                                    color: Colors.orange,
                                    size: screenWidth * 0.04,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Expanded(
                                  child: Text(
                                    evenement.typeEvenement.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.025,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            // Titre
                            Text(
                              evenement.titre,
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w600,
                                color: CouleursApp.texteFonce,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            // Date et lieu
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.grey[600],
                                  size: screenWidth * 0.035,
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Text(
                                  '${evenement.dateDebut.day}/${evenement.dateDebut.month}',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.03,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (evenement.lieu.isNotEmpty) ...[
                                  SizedBox(width: screenWidth * 0.03),
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.grey[600],
                                    size: screenWidth * 0.035,
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Expanded(
                                    child: Text(
                                      evenement.lieu,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.03,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            // Informations d'inscription
                            if (evenement.inscriptionRequise) ...[
                              SizedBox(height: screenHeight * 0.01),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people,
                                    color: Colors.grey[600],
                                    size: screenWidth * 0.035,
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text(
                                    '${evenement.nombreInscrits}/${evenement.capaciteMaximale ?? '∞'} inscrits',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (evenement.estComplet)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.02,
                                        vertical: screenWidth * 0.01,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'COMPLET',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: screenWidth * 0.025,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
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

  
  IconData _obtenirIconeTypeEvenement(String type) {
    switch (type.toLowerCase()) {
      case 'conference':
        return Icons.mic;
      case 'atelier':
        return Icons.build;
      case 'soiree':
        return Icons.celebration;
      case 'sportif':
        return Icons.sports;
      case 'culturel':
        return Icons.theater_comedy;
      case 'academique':
        return Icons.school;
      default:
        return Icons.event;
    }
  }
} 
