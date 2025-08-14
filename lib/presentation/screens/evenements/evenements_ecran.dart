// UI Design: Écran pour afficher tous les événements avec inscriptions
import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/evenement.dart';
import '../../../domain/repositories/evenements_repository.dart';
import '../../../domain/repositories/associations_repository.dart';
import '../../services/evenements_service.dart';
import '../../services/authentification_service.dart';
import '../../widgets/widget_barre_app_personnalisee.dart';

class EvenementsEcran extends StatefulWidget {
  const EvenementsEcran({super.key});

  @override
  State<EvenementsEcran> createState() => _EvenementsEcranState();
}

class _EvenementsEcranState extends State<EvenementsEcran>
    with SingleTickerProviderStateMixin {
  late final EvenementsRepository _evenementsRepository;
  late final AssociationsRepository _associationsRepository;
  late final EvenementsService _evenementsService;
  late final AuthentificationService _authentificationService;
  late TabController _tabController;

  List<Evenement> _tousEvenements = [];
  List<Evenement> _evenementsAVenir = [];
  List<Evenement> _evenementsEnCours = [];
  bool _chargement = true;
  String _filtreType = 'tous';
  final Map<String, String> _nomsAssociations = {}; // Cache des noms d'associations
  final Map<String, bool> _evenementsInscrits = {}; // Cache des inscriptions de l'utilisateur

  @override
  void initState() {
    super.initState();
    _initialiserServices();
    _tabController = TabController(length: 3, vsync: this);
    _chargerEvenements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initialiserServices() {
    _evenementsRepository = ServiceLocator.obtenirService<EvenementsRepository>();
    _associationsRepository = ServiceLocator.obtenirService<AssociationsRepository>();
    _evenementsService = EvenementsService();
    _authentificationService = ServiceLocator.obtenirService<AuthentificationService>();
  }

  Future<void> _chargerEvenements() async {
    setState(() => _chargement = true);

    try {
      // Charger les événements et les associations en parallèle
      final futures = await Future.wait([
        _evenementsRepository.obtenirEvenements(),
        _associationsRepository.obtenirAssociationsPopulaires(limite: 50),
      ]);

      final evenements = futures[0] as List<Evenement>;
      final associations = futures[1] as List;

      // Construire le cache des noms d'associations
      _nomsAssociations.clear();
      _nomsAssociations['admin_general'] = 'UQAR - Administration';
      for (final association in associations) {
        _nomsAssociations[association.id] = association.nom;
      }

      setState(() {
        _tousEvenements = evenements;
        _evenementsAVenir = evenements.where((e) => e.estAVenir).toList();
        _evenementsEnCours = evenements.where((e) => e.estEnCours).toList();
        _chargement = false;
      });
    } catch (e) {
      setState(() => _chargement = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des événements: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: const WidgetBarreAppPersonnalisee(
        titre: 'Événements',
        sousTitre: 'Tous les événements de l\'UQAR',
        afficherBoutonRetour: true,
      ),
      body: Column(
        children: [
          // Filtre par type
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Row(
              children: [
                Text(
                  'Filtrer par type:',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                    color: CouleursApp.texteFonce,
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _construireBoutonFiltre('tous', 'Tous'),
                        SizedBox(width: screenWidth * 0.02),
                        _construireBoutonFiltre('conference', 'Conférences'),
                        SizedBox(width: screenWidth * 0.02),
                        _construireBoutonFiltre('atelier', 'Ateliers'),
                        SizedBox(width: screenWidth * 0.02),
                        _construireBoutonFiltre('soiree', 'Soirées'),
                        SizedBox(width: screenWidth * 0.02),
                        _construireBoutonFiltre('sportif', 'Sportifs'),
                        SizedBox(width: screenWidth * 0.02),
                        _construireBoutonFiltre('culturel', 'Culturels'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Onglets
          Container(
            color: CouleursApp.blanc,
            child: TabBar(
              controller: _tabController,
              labelColor: CouleursApp.principal,
              unselectedLabelColor: CouleursApp.texteFonce.withValues(alpha: 0.6),
              indicatorColor: CouleursApp.principal,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Tous'),
                Tab(text: 'À venir'),
                Tab(text: 'En cours'),
              ],
            ),
          ),
          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _construireListeEvenements(_obtenirEvenementsFiltres(_tousEvenements)),
                _construireListeEvenements(_evenementsAVenir),
                _construireListeEvenements(_evenementsEnCours),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireBoutonFiltre(String valeur, String libelle) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final estSelectionne = _filtreType == valeur;

    return GestureDetector(
      onTap: () {
        setState(() {
          _filtreType = valeur;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: screenWidth * 0.02,
        ),
        decoration: BoxDecoration(
          color: estSelectionne 
            ? CouleursApp.principal 
            : CouleursApp.principal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: CouleursApp.principal,
            width: 1,
          ),
        ),
        child: Text(
          libelle,
          style: TextStyle(
            color: estSelectionne ? CouleursApp.blanc : CouleursApp.principal,
            fontSize: screenWidth * 0.03,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  List<Evenement> _obtenirEvenementsFiltres(List<Evenement> evenements) {
    if (_filtreType == 'tous') {
      return evenements;
    }
    return evenements.where((e) => e.typeEvenement == _filtreType).toList();
  }

  Widget _construireListeEvenements(List<Evenement> evenements) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    if (_chargement) {
      return const Center(
        child: CircularProgressIndicator(
          color: CouleursApp.principal,
        ),
      );
    }

    if (evenements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_outlined,
              size: screenWidth * 0.2,
              color: CouleursApp.texteFonce.withValues(alpha: 0.3),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Aucun événement trouvé',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: CouleursApp.texteFonce.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'Les nouveaux événements apparaîtront ici',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: CouleursApp.texteFonce.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _chargerEvenements,
      color: CouleursApp.principal,
      child: ListView.builder(
        padding: EdgeInsets.all(screenWidth * 0.04),
        itemCount: evenements.length,
        itemBuilder: (context, index) {
          final evenement = evenements[index];
          return _construireCarteEvenement(evenement);
        },
      ),
    );
  }

  Widget _construireCarteEvenement(Evenement evenement) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
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
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec titre et type
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  decoration: BoxDecoration(
                    color: _obtenirCouleurType(evenement.typeEvenement).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _obtenirIconeType(evenement.typeEvenement),
                    color: _obtenirCouleurType(evenement.typeEvenement),
                    size: screenWidth * 0.05,
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evenement.titre,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: CouleursApp.texteFonce,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        evenement.typeEvenement.toUpperCase(),
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: _obtenirCouleurType(evenement.typeEvenement),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge statut
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: screenWidth * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: _obtenirCouleurStatut(evenement.statutEvenement).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    evenement.statutEvenement,
                    style: TextStyle(
                      fontSize: screenWidth * 0.025,
                      color: _obtenirCouleurStatut(evenement.statutEvenement),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: screenHeight * 0.015),
            
            // Description
            if (evenement.description.isNotEmpty) ...[
              Text(
                evenement.description,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: screenHeight * 0.015),
            ],
            
            // Informations pratiques
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.grey[600],
                  size: screenWidth * 0.04,
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  '${evenement.dateDebut.day}/${evenement.dateDebut.month}/${evenement.dateDebut.year}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                if (evenement.lieu.isNotEmpty) ...[
                  Icon(
                    Icons.location_on,
                    color: Colors.grey[600],
                    size: screenWidth * 0.04,
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
            
            SizedBox(height: screenHeight * 0.01),
            
            // Association organisatrice
            Row(
              children: [
                Icon(
                  Icons.groups,
                  color: CouleursApp.principal,
                  size: screenWidth * 0.04,
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  _obtenirNomAssociation(evenement.associationId),
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: CouleursApp.principal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Prix
                if (!evenement.estGratuit && evenement.prix != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenWidth * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color: CouleursApp.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${evenement.prix!.toStringAsFixed(2)}\$',
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: CouleursApp.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            // Informations d'inscription
            if (evenement.inscriptionRequise) ...[
              SizedBox(height: screenHeight * 0.015),
              Row(
                children: [
                  Icon(
                    Icons.people,
                    color: Colors.grey[600],
                    size: screenWidth * 0.04,
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
            
            // Bouton d'inscription
            if (evenement.inscriptionRequise) ...[
              SizedBox(height: screenHeight * 0.015),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: evenement.estComplet ? null : () => _gererInscriptionEvenement(evenement),
                  icon: Icon(
                    _estInscritEvenement(evenement.id) ? Icons.person_remove : Icons.person_add,
                    size: screenWidth * 0.04,
                  ),
                  label: Text(
                    _estInscritEvenement(evenement.id) ? 'Se désinscrire' : 'S\'inscrire',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _estInscritEvenement(evenement.id) 
                      ? Colors.red 
                      : (evenement.estComplet ? Colors.grey : CouleursApp.principal),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                      horizontal: screenWidth * 0.04,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Vérifier si l'utilisateur est inscrit à un événement
  bool _estInscritEvenement(String evenementId) {
    return _evenementsInscrits[evenementId] ?? false;
  }

  // Gérer l'inscription/désinscription à un événement
  Future<void> _gererInscriptionEvenement(Evenement evenement) async {
    final utilisateur = _authentificationService.utilisateurActuel;
    if (utilisateur == null) {
      _afficherErreur('Vous devez être connecté pour vous inscrire aux événements');
      return;
    }

    try {
      final estInscrit = _estInscritEvenement(evenement.id);
      
      bool success;
      if (estInscrit) {
        // Désinscription
        success = await _evenementsService.desinscrireUtilisateur(evenement.id, utilisateur.id);
        if (success) {
          setState(() {
            _evenementsInscrits[evenement.id] = false;
          });
          _afficherSucces('Désinscription réussie à "${evenement.titre}"');
        } else {
          _afficherErreur('Erreur lors de la désinscription');
        }
      } else {
        // Inscription
        if (evenement.estComplet) {
          _afficherErreur('Cet événement est complet');
          return;
        }
        
        success = await _evenementsService.inscrireUtilisateur(evenement.id, utilisateur.id);
        if (success) {
          setState(() {
            _evenementsInscrits[evenement.id] = true;
          });
          _afficherSucces('Inscription réussie à "${evenement.titre}"');
        } else {
          _afficherErreur('Erreur lors de l\'inscription');
        }
      }
      
      // Recharger les données pour mettre à jour les compteurs
      await _chargerEvenements();
    } catch (e) {
      _afficherErreur('Erreur: $e');
    }
  }

  // Obtenir le nom de l'association
  String _obtenirNomAssociation(String associationId) {
    return _nomsAssociations[associationId] ?? 'Association';
  }

  // Obtenir la couleur selon le type d'événement
  Color _obtenirCouleurType(String type) {
    switch (type.toLowerCase()) {
      case 'conference':
        return Colors.blue;
      case 'atelier':
        return Colors.green;
      case 'soiree':
        return Colors.purple;
      case 'sportif':
        return Colors.orange;
      case 'culturel':
        return Colors.teal;
      case 'academique':
        return Colors.indigo;
      default:
        return CouleursApp.principal;
    }
  }

  // Obtenir l'icône selon le type d'événement
  IconData _obtenirIconeType(String type) {
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

  // Obtenir la couleur selon le statut
  Color _obtenirCouleurStatut(String statut) {
    switch (statut) {
      case 'À venir':
        return Colors.blue;
      case 'En cours':
        return Colors.green;
      case 'Terminé':
        return Colors.grey;
      default:
        return CouleursApp.principal;
    }
  }

  // Méthodes utilitaires pour les messages
  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _afficherSucces(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
