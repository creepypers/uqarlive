// UI Design: Écran de gestion d'association pour les chefs - Design moderne premium
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/association.dart';
import '../../../domain/entities/demande_adhesion.dart';
import '../../../domain/entities/utilisateur.dart';
import '../../../domain/entities/evenement.dart';
import '../../../domain/entities/membre_association.dart';
import '../../../domain/repositories/utilisateurs_repository.dart';
import '../../../domain/repositories/evenements_repository.dart';
import '../../../domain/repositories/membres_association_repository.dart';
import '../../../presentation/services/adhesions_service.dart';
import '../../../presentation/services/authentification_service.dart';
import '../../../presentation/services/evenements_service.dart';
import '../../../presentation/services/gestion_membres_service.dart';
import '../../../presentation/widgets/widget_barre_app_personnalisee.dart';
import '../../../core/di/service_locator.dart';
import 'actualites/ajouter_actualite_ecran.dart';
import 'evenements/ajouter_evenement_ecran.dart';

class GestionAssociationEcran extends StatefulWidget {
  final Association association;

  const GestionAssociationEcran({
    Key? key,
    required this.association,
  }) : super(key: key);

  @override
  State<GestionAssociationEcran> createState() => _GestionAssociationEcranState();
}

class _GestionAssociationEcranState extends State<GestionAssociationEcran> {
  late final AdhesionsService _adhesionsService;
  late final AuthentificationService _authentificationService;
  late final UtilisateursRepository _utilisateursRepository;
  late final EvenementsRepository _evenementsRepository;
  late final EvenementsService _evenementsService;
  late final MembresAssociationRepository _membresRepository;
  late final GestionMembresService _gestionMembresService;
  List<DemandeAdhesion> _demandesAdhesion = [];
  List<Evenement> _evenementsAssociation = [];
  List<MembreAssociation> _membresAssociation = [];
  // UI Design: Cache pour optimiser les performances
  final Map<String, Utilisateur> _utilisateursCache = {};
  final Map<String, bool> _evenementsInscrits = {}; // Cache des inscriptions
  bool _chargementEvenements = true;
  bool _chargementMembres = true;
  

  @override
  void initState() {
    super.initState();
    _adhesionsService = ServiceLocator.obtenirService<AdhesionsService>();
    _authentificationService = ServiceLocator.obtenirService<AuthentificationService>();
    _utilisateursRepository = ServiceLocator.obtenirService<UtilisateursRepository>();
    _evenementsRepository = ServiceLocator.obtenirService<EvenementsRepository>();
    _evenementsService = EvenementsService();
    _membresRepository = ServiceLocator.obtenirService<MembresAssociationRepository>();
    _gestionMembresService = ServiceLocator.obtenirService<GestionMembresService>();
    _adhesionsService.initialiser();
    _gestionMembresService.initialiser();
    _chargerDemandesAdhesion();
    _chargerEvenementsAssociation();
    _chargerMembresAssociation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _chargerDemandesAdhesion() async {
    setState(() {
    });

    try {
      // UI Design: Récupérer les vraies demandes d'adhésion depuis le service
      final demandes = await _adhesionsService.obtenirDemandesEnAttente(widget.association.id);
      setState(() {
        _demandesAdhesion = demandes;
      });
    } catch (e) {
      setState(() {
        _demandesAdhesion = [];
      });
      _afficherErreur('Erreur lors du chargement des demandes: ${e.toString()}');
    }
  }

  Future<void> _repondreDemande(DemandeAdhesion demande, bool accepter) async {
    try {
      // UI Design: Implémenter l'acceptation/rejet des demandes via le service
      bool resultat;
      
      final utilisateurConnecte = _authentificationService.utilisateurActuel;
      if (utilisateurConnecte == null) {
        _afficherErreur('Vous devez être connecté pour traiter les demandes');
        return;
      }

      if (accepter) {
        resultat = await _adhesionsService.accepterDemande(
          demandeId: demande.id,
          chefId: utilisateurConnecte.id,
          messageReponse: 'Votre demande d\'adhésion a été acceptée !',
        );
      } else {
        resultat = await _adhesionsService.refuserDemande(
          demandeId: demande.id,
          chefId: utilisateurConnecte.id,
          messageReponse: 'Votre demande d\'adhésion a été refusée.',
        );
      }

      if (resultat) {
        if (accepter) {
          _afficherSucces('Demande acceptée avec succès !');
        } else {
          _afficherSucces('Demande rejetée');
        }
        _chargerDemandesAdhesion(); // Recharger la liste
      } else {
        _afficherErreur('Erreur lors du traitement de la demande');
      }
    } catch (e) {
      _afficherErreur('Erreur: $e');
    }
  }

  Future<void> _chargerEvenementsAssociation() async {
    setState(() {
      _chargementEvenements = true;
    });

    try {
      // UI Design: Récupérer les événements de cette association
      final evenements = await _evenementsRepository.obtenirEvenementsParAssociation(widget.association.id);
      setState(() {
        _evenementsAssociation = evenements.where((e) => e.estAVenir).toList();
        _chargementEvenements = false;
      });
    } catch (e) {
      setState(() {
        _evenementsAssociation = [];
        _chargementEvenements = false;
      });
    }
  }

  Future<void> _chargerMembresAssociation() async {
    setState(() {
      _chargementMembres = true;
    });

    try {
      // UI Design: Récupérer les vrais membres de l'association
      final membres = await _gestionMembresService.obtenirMembresAssociation(widget.association.id);
      setState(() {
        _membresAssociation = membres;
        _chargementMembres = false;
      });
    } catch (e) {
      setState(() {
        _membresAssociation = [];
        _chargementMembres = false;
      });
      _afficherErreur('Erreur lors du chargement des membres: ${e.toString()}');
    }
  }

  // UI Design: Nouvelle méthode pour retirer un membre de l'association// UI Design: Vérifier si l'utilisateur est inscrit à un événement
  bool _estInscritEvenement(String evenementId) {
    return _evenementsInscrits[evenementId] ?? false;
  }

  // UI Design: Gérer l'inscription/désinscription à un événement
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
      
      // Recharger les événements pour mettre à jour les compteurs
      await _chargerEvenementsAssociation();
    } catch (e) {
      _afficherErreur('Erreur: $e');
    }
  }

  void _ajouterActualite() async {
    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AjouterActualiteEcran(
          association: widget.association,
        ),
      ),
    );
    if (resultat == true) {
      _afficherSucces('Actualité ajoutée avec succès !');
    }
  }

  void _ajouterEvenement() async {
    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AjouterEvenementEcran(
          association: widget.association,
        ),
      ),
    );
    if (resultat == true) {
      _afficherSucces('Événement créé avec succès !');
    }
  }

  // Méthodes helper pour utilisateurs
  Future<Utilisateur?> _obtenirUtilisateur(String utilisateurId) async {
    if (_utilisateursCache.containsKey(utilisateurId)) {
      return _utilisateursCache[utilisateurId];
    }

    try {
      final utilisateur = await _utilisateursRepository.obtenirUtilisateurParId(utilisateurId);
      if (utilisateur != null) {
        _utilisateursCache[utilisateurId] = utilisateur;
      }
      return utilisateur;
    } catch (e) {
      return null;
    }
  }

  String _obtenirInitiales(Utilisateur? utilisateur) {
    if (utilisateur == null) return 'U';
    final prenomInitiale = utilisateur.prenom.isNotEmpty ? utilisateur.prenom[0].toUpperCase() : 'U';
    final nomInitiale = utilisateur.nom.isNotEmpty ? utilisateur.nom[0].toUpperCase() : '';
    return prenomInitiale + nomInitiale;
  }

  String _obtenirNomComplet(Utilisateur? utilisateur) {
    if (utilisateur == null) return 'Utilisateur inconnu';
    return '${utilisateur.prenom} ${utilisateur.nom}';
  }

  void _afficherSucces(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
          backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: WidgetBarreAppPersonnalisee(
          titre: 'Gestion Association',
          sousTitre: widget.association.nom,
          afficherBoutonRetour: true,
          afficherProfil: false,
          hauteurBarre: 90,
          widgetFin: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenWidth * 0.015,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.admin_panel_settings, color: Colors.white, size: 18),
                SizedBox(width: screenWidth * 0.015),
                const Text(
                  'Chef',
                  style: TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Actions rapides
              Container(
                margin: EdgeInsets.all(screenWidth * 0.05),
                child: _construireActionsRapides(),
              ),
              
              // Onglets
              Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const TabBar(
                  labelColor: CouleursApp.principal,
                  unselectedLabelColor: CouleursApp.gris,
                  indicatorColor: CouleursApp.principal,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.person_add),
                      text: 'Demandes',
                    ),
                    Tab(
                      icon: Icon(Icons.event),
                      text: 'Actualités & Événements',
                    ),
                    Tab(
                      icon: Icon(Icons.group),
                      text: 'Membres',
                    ),
                  ],
                ),
              ),
              
              // Contenu des onglets avec hauteur fixe pour éviter le débordement
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6, // Hauteur fixe pour éviter le débordement
                child: TabBarView(
                  children: [
                    // Onglet 1: Demandes d'adhésion
                    SingleChildScrollView(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: _construireOngletDemandes(),
                    ),
                    
                    // Onglet 2: Actualités et événements
                    SingleChildScrollView(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: _construireOngletActualitesEvenements(),
                    ),
                    
                    // Onglet 3: Membres
                    SingleChildScrollView(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: _construireOngletMembres(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construireActionsRapides() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
        borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.025),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [CouleursApp.principal, CouleursApp.accent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.flash_on, color: Colors.white, size: 24),
              ),
              SizedBox(width: screenWidth * 0.04),
                        Text(
                'Actions Rapides',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                  color: CouleursApp.texteFonce,
                          ),
                        ),
                      ],
                    ),
          SizedBox(height: screenHeight * 0.025),
          Row(
            children: [
              Expanded(
                child: _construireBoutonAction(
                  'Actualité',
                  Icons.article_outlined,
                  CouleursApp.accent,
                  _ajouterActualite,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: _construireBoutonAction(
                  'Événement',
                  Icons.event_outlined,
                  CouleursApp.principal,
                  _ajouterEvenement,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _construireBoutonAction(String titre, IconData icone, Color couleur, VoidCallback onTap) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
                decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
            color: couleur.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
      child: ElevatedButton(
        onPressed: onTap,
                            style: ElevatedButton.styleFrom(
          backgroundColor: couleur,
                              foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                              shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Column(
          children: [
            Icon(icone, size: screenWidth * 0.06),
            SizedBox(height: screenHeight * 0.008),
            Text(
              titre,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
      ),
    );
  }

  Widget _construireOngletDemandes() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête avec statistiques
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.025),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_add_outlined, color: Colors.orange, size: 24),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demandes d\'Adhésion',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: CouleursApp.texteFonce,
                    ),
                  ),
                  Text(
                    '${_demandesAdhesion.length} demande${_demandesAdhesion.length != 1 ? 's' : ''} en attente',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.025),
        
        // Liste des demandes
        if (_demandesAdhesion.isEmpty)
          _construireEtatVide()
        else
          Column(
            children: _demandesAdhesion.map((demande) => _construireCarteDemande(demande)).toList(),
          ),
      ],
    );
  }

  Widget _construireOngletActualitesEvenements() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête avec statistiques
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.025),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.event_outlined, color: Colors.blue, size: 24),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Événements à Venir',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: CouleursApp.texteFonce,
                    ),
                  ),
                  Text(
                    '${_evenementsAssociation.length} événement${_evenementsAssociation.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (_chargementEvenements)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(CouleursApp.principal),
                ),
              ),
          ],
        ),
        SizedBox(height: screenHeight * 0.025),
        
        // Liste des événements
        if (_evenementsAssociation.isEmpty && !_chargementEvenements)
          _construireEtatVideEvenements()
        else
          Column(
            children: _evenementsAssociation.map((evenement) => _construireCarteEvenement(evenement)).toList(),
          ),
      ],
    );
  }

  Widget _construireOngletMembres() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête avec statistiques
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.025),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.group_outlined, color: Colors.purple, size: 24),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Membres de l\'Association',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: CouleursApp.texteFonce,
                    ),
                  ),
                  Text(
                    '${_membresAssociation.length} membre${_membresAssociation.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (_chargementMembres)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(CouleursApp.principal),
                ),
              ),
          ],
        ),
        SizedBox(height: screenHeight * 0.025),
        
        // Liste des membres
        if (_membresAssociation.isEmpty && !_chargementMembres)
          _construireEtatVideMembres()
        else
          SizedBox(
            height: 300, // Hauteur fixe pour la scrollbar
            child: ListView.builder(
              itemCount: _membresAssociation.length,
              itemBuilder: (context, index) => _construireCarteMembre(_membresAssociation[index]),
            ),
          ),
      ],
    );
  }

  Widget _construireEtatVide() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.08),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.06),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: screenWidth * 0.12,
              color: Colors.grey.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
                            'Aucune demande en attente',
                            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: CouleursApp.texteFonce.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireEtatVideEvenements() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.08),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.06),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              Icons.event_available_outlined,
              size: screenWidth * 0.12,
              color: Colors.blue.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            'Aucun événement à venir',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: CouleursApp.texteFonce.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'Créez des événements pour engager votre communauté !',
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: CouleursApp.texteFonce.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _construireEtatVideMembres() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.08),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.06),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              Icons.group_outlined,
              size: screenWidth * 0.12,
              color: Colors.purple.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            'Aucun membre trouvé',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: CouleursApp.texteFonce.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'Ajoutez des membres pour enrichir votre communauté !',
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: CouleursApp.texteFonce.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _construireCarteDemande(DemandeAdhesion demande) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CouleursApp.principal.withValues(alpha: 0.1)),
      ),
      child: FutureBuilder<Utilisateur?>(
        future: _obtenirUtilisateur(demande.utilisateurId),
        builder: (context, snapshot) {
          final utilisateur = snapshot.data;
          return Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: screenWidth * 0.06,
                backgroundColor: CouleursApp.principal,
                child: Text(
                  _obtenirInitiales(utilisateur),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
              SizedBox(width: screenWidth * 0.04),
              
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _obtenirNomComplet(utilisateur),
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: CouleursApp.texteFonce,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.003),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.025,
                        vertical: screenWidth * 0.01,
                      ),
                            decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        demande.roledemande.isNotEmpty ? demande.roledemande : 'Membre',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Boutons d'action
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                          color: Colors.red.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                    child: IconButton(
                      onPressed: () => _repondreDemande(demande, false),
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.all(screenWidth * 0.025),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.025),
                                  Container(
                                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                                    ),
                                    child: IconButton(
                                      onPressed: () => _repondreDemande(demande, true),
                      icon: const Icon(Icons.check_rounded, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.all(screenWidth * 0.025),
                      ),
                                    ),
                                  ),
                                ],
                              ),
            ],
          );
        },
      ),
    );
  }

  Widget _construireCarteEvenement(Evenement evenement) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête événement
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.event,
                  color: Colors.white,
                  size: screenWidth * 0.04,
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
                    SizedBox(height: screenHeight * 0.003),
                    Text(
                      evenement.lieu,
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Badge complet si nécessaire
              if (evenement.estComplet)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: screenWidth * 0.008,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'COMPLET',
                    style: TextStyle(
                      fontSize: screenWidth * 0.025,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: screenHeight * 0.012),
          
          // Informations événement
          Row(
            children: [
              Icon(Icons.access_time, size: screenWidth * 0.04, color: CouleursApp.texteFonce.withValues(alpha: 0.6)),
              SizedBox(width: screenWidth * 0.02),
              Text(
                '${evenement.dateDebut.day}/${evenement.dateDebut.month}/${evenement.dateDebut.year} à ${evenement.dateDebut.hour}:${evenement.dateDebut.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: screenWidth * 0.032,
                  color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.008),
          
          if (evenement.inscriptionRequise) ...[
            Row(
              children: [
                Icon(Icons.people_outline, size: screenWidth * 0.04, color: CouleursApp.texteFonce.withValues(alpha: 0.6)),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  '${evenement.nombreInscrits}${evenement.capaciteMaximale != null ? '/${evenement.capaciteMaximale}' : ''} inscrit${evenement.nombreInscrits != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.032,
                    color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.015),
            
            // Bouton d'inscription
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _construireCarteMembre(MembreAssociation membre) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return GestureDetector(
      onLongPress: () => _afficherActionsMembre(membre),
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.015),
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CouleursApp.principal.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: FutureBuilder<Utilisateur?>(
          future: _obtenirUtilisateur(membre.utilisateurId),
          builder: (context, snapshot) {
            final utilisateur = snapshot.data;
            return Row(
              children: [
                // Avatar avec couleur selon le rôle
                Container(
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.12,
                  decoration: BoxDecoration(
                    color: _obtenirCouleurRole(membre.role),
                    borderRadius: BorderRadius.circular(screenWidth * 0.06),
                  ),
                  child: Center(
                    child: Icon(
                      _obtenirIconeRole(membre.role),
                      color: Colors.white,
                      size: screenWidth * 0.06,
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                
                // Informations du membre
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _obtenirNomComplet(utilisateur),
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: CouleursApp.texteFonce,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.025,
                          vertical: screenWidth * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: _obtenirCouleurRole(membre.role).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          membre.roleFormate,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: _obtenirCouleurRole(membre.role),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        'Membre depuis ${_formaterDate(membre.dateAdhesion)}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                

              ],
            );
          },
        ),
      ),
    );
  }

  // Méthodes helper pour les rôles
  Color _obtenirCouleurRole(String role) {
    final roleLower = role.toLowerCase();
    switch (roleLower) {
      case 'president':
      case 'président':
      case 'chef':
        return Colors.red;
      case 'vice_president':
      case 'vice-président':
      case 'vice président':
        return Colors.orange;
      case 'tresorier':
      case 'trésorier':
        return Colors.purple;
      case 'secretaire':
      case 'secrétaire':
        return Colors.teal;
      case 'membre_bureau':
      case 'membre du bureau':
        return Colors.indigo;
      case 'membre':
      case 'membre actif':
        return CouleursApp.principal;
      default:
        return CouleursApp.gris;
    }
  }

  IconData _obtenirIconeRole(String role) {
    final roleLower = role.toLowerCase();
    switch (roleLower) {
      case 'president':
      case 'président':
      case 'chef':
        return Icons.admin_panel_settings;
      case 'vice_president':
      case 'vice-président':
      case 'vice président':
        return Icons.star;
      case 'tresorier':
      case 'trésorier':
        return Icons.account_balance_wallet;
      case 'secretaire':
      case 'secrétaire':
        return Icons.description;
      case 'membre_bureau':
      case 'membre du bureau':
        return Icons.business;
      case 'membre':
      case 'membre actif':
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }

  String _formaterDate(DateTime date) {
    final maintenant = DateTime.now();
    final difference = maintenant.difference(date);
    
    if (difference.inDays < 1) {
      return 'aujourd\'hui';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inDays < 30) {
      final semaines = (difference.inDays / 7).floor();
      return '$semaines semaine${semaines > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final mois = (difference.inDays / 30).floor();
      return '$mois mois';
    } else {
      final annees = (difference.inDays / 365).floor();
      return '$annees an${annees > 1 ? 's' : ''}';
    }
  }

  // Afficher les actions disponibles pour un membre
  void _afficherActionsMembre(MembreAssociation membre) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // En-tête
            Padding(
              padding: const EdgeInsets.all(20),
              child: FutureBuilder<Utilisateur?>(
                future: _obtenirUtilisateur(membre.utilisateurId),
                builder: (context, snapshot) {
                  final utilisateur = snapshot.data;
                  return Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _obtenirCouleurRole(membre.role),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Icon(
                            _obtenirIconeRole(membre.role),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _obtenirNomComplet(utilisateur),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              membre.roleFormate,
                              style: TextStyle(
                                fontSize: 14,
                                color: _obtenirCouleurRole(membre.role),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            // Actions disponibles
            if (!membre.estPresident) ...[
              ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.green),
                title: const Text('Promouvoir'),
                subtitle: const Text('Choisir un nouveau rôle'),
                onTap: () {
                  Navigator.pop(context);
                  _afficherModalPromotion(membre);
                },
              ),
            ],
            
            if (membre.estMembreBureau && !membre.estPresident) ...[
              ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.orange),
                title: const Text('Rétrograder'),
                subtitle: Text('Passer au rôle de ${_obtenirRolePrecedent(membre.role)}'),
                onTap: () {
                  Navigator.pop(context);
                  _retraderMembre(membre);
                },
              ),
            ],
            
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Retirer de l\'association'),
              subtitle: const Text('Cette action est irréversible'),
              onTap: () {
                Navigator.pop(context);
                _supprimerMembre(membre);
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Méthodes helper pour les promotions/rétrogradations
  String _obtenirRolePrecedent(String roleActuel) {
    final roleLower = roleActuel.toLowerCase();
    switch (roleLower) {
      case 'president':
      case 'président':
      case 'chef':
        return 'Vice-Président';
      case 'vice_president':
      case 'vice-président':
      case 'vice président':
        return 'Trésorier';
      case 'tresorier':
      case 'trésorier':
        return 'Secrétaire';
      case 'secretaire':
      case 'secrétaire':
        return 'Membre du Bureau';
      case 'membre_bureau':
      case 'membre du bureau':
        return 'Membre';
      default:
        return 'Membre';
    }
  }

  // Afficher le modal de promotion avec dropdown
  void _afficherModalPromotion(MembreAssociation membre) {
    String? nouveauRoleSelectionne;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Promouvoir le membre',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Promouvoir ${_obtenirNomComplet(_utilisateursCache[membre.utilisateurId])}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sélectionnez le nouveau rôle :',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: nouveauRoleSelectionne,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nouveau rôle',
                ),
                items: _obtenirRolesDisponibles(membre.role).map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Row(
                      children: [
                        Icon(
                          _obtenirIconeRole(role),
                          color: _obtenirCouleurRole(role),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(role),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    nouveauRoleSelectionne = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner un rôle';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: nouveauRoleSelectionne != null
                  ? () {
                      Navigator.pop(context);
                      _promouvoirMembreVersRole(membre, nouveauRoleSelectionne!);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Promouvoir'),
            ),
          ],
        ),
      ),
    );
  }

  // Obtenir la liste des rôles disponibles pour la promotion
  List<String> _obtenirRolesDisponibles(String roleActuel) {
    final roleLower = roleActuel.toLowerCase();
    final rolesDisponibles = <String>[];
    
    // Ajouter les rôles selon le rôle actuel
    if (roleLower == 'membre' || roleLower == 'membre actif') {
      rolesDisponibles.addAll([
        'Membre du Bureau',
        'Secrétaire',
        'Trésorier',
        'Vice-Président',
        'Président',
      ]);
    } else if (roleLower == 'membre_bureau' || roleLower == 'membre du bureau') {
      rolesDisponibles.addAll([
        'Secrétaire',
        'Trésorier',
        'Vice-Président',
        'Président',
      ]);
    } else if (roleLower == 'secretaire' || roleLower == 'secrétaire') {
      rolesDisponibles.addAll([
        'Trésorier',
        'Vice-Président',
        'Président',
      ]);
    } else if (roleLower == 'tresorier' || roleLower == 'trésorier') {
      rolesDisponibles.addAll([
        'Vice-Président',
        'Président',
      ]);
    } else if (roleLower == 'vice_president' || roleLower == 'vice-président' || roleLower == 'vice président') {
      rolesDisponibles.addAll([
        'Président',
      ]);
    }
    
    return rolesDisponibles;
  }

  // Promouvoir un membre vers un rôle spécifique
  Future<void> _promouvoirMembreVersRole(MembreAssociation membre, String nouveauRole) async {
    final utilisateurConnecte = _authentificationService.utilisateurActuel;
    if (utilisateurConnecte == null) {
      _afficherErreur('Vous devez être connecté pour promouvoir un membre');
      return;
    }

    try {
      final resultat = await _membresRepository.changerRole(membre.id, nouveauRole);

      if (resultat) {
        _afficherSucces('Membre promu au rôle de $nouveauRole avec succès !');
        _chargerMembresAssociation();
      } else {
        _afficherErreur('Erreur lors de la promotion du membre');
      }
    } catch (e) {
      _afficherErreur('Erreur: $e');
    }
  }

  // Méthodes d'action pour les membres
  Future<void> _retraderMembre(MembreAssociation membre) async {
    final utilisateurConnecte = _authentificationService.utilisateurActuel;
    if (utilisateurConnecte == null) {
      _afficherErreur('Vous devez être connecté pour rétrograder un membre');
      return;
    }

    try {
      final nouveauRole = _obtenirRolePrecedent(membre.role);
      final resultat = await _membresRepository.changerRole(membre.id, nouveauRole);

      if (resultat) {
        _afficherSucces('Membre rétrogradé au rôle de $nouveauRole avec succès !');
        _chargerMembresAssociation();
      } else {
        _afficherErreur('Erreur lors de la rétrogradation du membre');
      }
    } catch (e) {
      _afficherErreur('Erreur: $e');
    }
  }

  Future<void> _supprimerMembre(MembreAssociation membre) async {
    final utilisateurConnecte = _authentificationService.utilisateurActuel;
    if (utilisateurConnecte == null) {
      _afficherErreur('Vous devez être connecté pour supprimer un membre');
      return;
    }

    try {
      final resultat = await _membresRepository.supprimerMembre(membre.id);

      if (resultat) {
        _afficherSucces('Membre supprimé avec succès !');
        _chargerMembresAssociation();
      } else {
        _afficherErreur('Erreur lors de la suppression du membre');
      }
    } catch (e) {
      _afficherErreur('Erreur: $e');
    }
  }
}
