// UI Design: Écran de gestion d'association pour les chefs - Design moderne premium
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/association.dart';
import '../../../domain/entities/demande_adhesion.dart';
import '../../../domain/entities/utilisateur.dart';
import '../../../domain/entities/evenement.dart';
import '../../../domain/repositories/utilisateurs_repository.dart';
import '../../../domain/repositories/evenements_repository.dart';
import '../../../presentation/services/adhesions_service.dart';
import '../../../presentation/services/authentification_service.dart';
import '../../../presentation/services/evenements_service.dart';
import '../../../presentation/widgets/widget_barre_app_personnalisee.dart';
import '../../../core/di/service_locator.dart';
import 'ajouter_actualite_ecran.dart';
import 'ajouter_evenement_ecran.dart';

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
  List<DemandeAdhesion> _demandesAdhesion = [];
  List<Evenement> _evenementsAssociation = [];
  final Map<String, Utilisateur> _utilisateursCache = {};
  final Map<String, bool> _evenementsInscrits = {}; // Cache des inscriptions
  bool _chargement = true;
  bool _chargementEvenements = true;

  @override
  void initState() {
    super.initState();
    _adhesionsService = ServiceLocator.obtenirService<AdhesionsService>();
    _authentificationService = ServiceLocator.obtenirService<AuthentificationService>();
    _utilisateursRepository = ServiceLocator.obtenirService<UtilisateursRepository>();
    _evenementsRepository = ServiceLocator.obtenirService<EvenementsRepository>();
    _evenementsService = EvenementsService();
    _adhesionsService.initialiser();
    _chargerDemandesAdhesion();
    _chargerEvenementsAssociation();
  }

  Future<void> _chargerDemandesAdhesion() async {
    setState(() {
      _chargement = true;
    });

    try {
      // UI Design: Récupérer les vraies demandes d'adhésion depuis le service
      final demandes = await _adhesionsService.obtenirDemandesEnAttente(widget.association.id);
      setState(() {
        _demandesAdhesion = demandes;
        _chargement = false;
      });
    } catch (e) {
      setState(() {
        _demandesAdhesion = [];
        _chargement = false;
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

  // UI Design: Vérifier si l'utilisateur est inscrit à un événement
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.01),
              // Actions rapides
              _construireActionsRapides(),
              SizedBox(height: screenHeight * 0.025),
              
              // Statistiques et demandes
              _construireStatistiquesEtDemandes(),
              SizedBox(height: screenHeight * 0.025),
              
              // Événements de l'association
              _construireEvenementsAssociation(),
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

  Widget _construireStatistiquesEtDemandes() {
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
          // En-tête avec statistiques
                    Row(
                      children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.025),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people_outline, color: Colors.orange, size: 24),
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
                      '${_demandesAdhesion.length} en attente',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
                        if (_chargement)
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
          
          // Liste des demandes
                    if (_demandesAdhesion.isEmpty && !_chargement)
            _construireEtatVide()
          else
            Column(
              children: _demandesAdhesion.map((demande) => _construireCarteDemande(demande)).toList(),
            ),
        ],
      ),
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

  Widget _construireEvenementsAssociation() {
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
}
