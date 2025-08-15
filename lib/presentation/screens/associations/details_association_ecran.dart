import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/association.dart';
import '../../../domain/entities/evenement.dart';
import '../../../domain/entities/actualite.dart';
import '../../../domain/repositories/evenements_repository.dart';
import '../../../domain/repositories/actualites_repository.dart';
import '../../services/navigation_service.dart';
import '../../services/adhesions_service.dart';
import '../../services/authentification_service.dart';
import '../../services/evenements_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/utils/associations_utils.dart';
import '../../widgets/navbar_widget.dart';
import '../../widgets/widget_barre_app_personnalisee.dart';
// import supprimé: widget_section_statistiques.dart non utilisé
// import supprimé: gestion_demandes_association_ecran non utilisé ici
import 'gestion_association_ecran.dart';

// UI Design: Page de détails complète d'une association UQAR
class DetailsAssociationEcran extends StatefulWidget {
  final Association association;

  const DetailsAssociationEcran({super.key, required this.association});

  @override
  State<DetailsAssociationEcran> createState() => _DetailsAssociationEcranState();
}

class _DetailsAssociationEcranState extends State<DetailsAssociationEcran> {
  late final AdhesionsService _adhesionsService;
  late final AuthentificationService _authentificationService;
  late final EvenementsRepository _evenementsRepository;
  late final ActualitesRepository _actualitesRepository;
  bool _estChefAssociation = false;
  
  // UI Design: Données dynamiques pour événements et actualités
  List<Evenement> _evenementsAssociation = [];
  List<Actualite> _actualitesAssociation = [];
  bool _chargementEvenements = true;
  bool _chargementActualites = true;

  @override
  void initState() {
    super.initState();
    _adhesionsService = ServiceLocator.obtenirService<AdhesionsService>();
    _authentificationService = ServiceLocator.obtenirService<AuthentificationService>();
    _evenementsRepository = ServiceLocator.obtenirService<EvenementsRepository>();
    _actualitesRepository = ServiceLocator.obtenirService<ActualitesRepository>();
    _adhesionsService.initialiser();
    _verifierStatutChef();
    _chargerDonneesAssociation();
  }

  Future<void> _verifierStatutChef() async {
    final utilisateur = _authentificationService.utilisateurActuel;
    
    if (utilisateur != null) {
      final estChefAssociation = widget.association.chefId == utilisateur.id;
      
      setState(() {
        _estChefAssociation = estChefAssociation;
      });
    }
  }

  // UI Design: Charger les événements et actualités dynamiques de l'association
  Future<void> _chargerDonneesAssociation() async {
    try {
      // Charger les événements en parallèle
      final futureEvenements = _evenementsRepository.obtenirEvenementsParAssociation(widget.association.id);
      final futureActualites = _actualitesRepository.obtenirActualitesParAssociation(widget.association.id);
      
      final resultats = await Future.wait([futureEvenements, futureActualites]);
      
      if (mounted) {
        setState(() {
          _evenementsAssociation = (resultats[0] as List<Evenement>)
              .where((e) => e.estAVenir) // Seulement les événements à venir
              .take(5) // Limiter à 5 événements
              .toList();
          _actualitesAssociation = (resultats[1] as List<Actualite>)
              .take(5) // Limiter à 5 actualités
              .toList();
          _chargementEvenements = false;
          _chargementActualites = false;
        });
      }
    } catch (e) {
      // En cas d'erreur, arrêter le chargement
      if (mounted) {
        setState(() {
          _chargementEvenements = false;
          _chargementActualites = false;
        });
      }

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
    
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      resizeToAvoidBottomInset: true, // UI Design: Éviter les débordements avec le clavier
      appBar: WidgetBarreAppPersonnalisee(
        titre: widget.association.nom,
        sousTitre: AssociationsUtils.obtenirNomType(widget.association.typeAssociation),
        afficherProfil: false,
        afficherBoutonRetour: true,
        widgetFin: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_estChefAssociation) ...[
              IconButton(
                icon: Icon(Icons.admin_panel_settings, color: CouleursApp.blanc, size: screenWidth * 0.06), // UI Design: Taille adaptative
                onPressed: () => _ouvrirGestionDemandes(),
                tooltip: 'Gérer l\'association',
              ),
            ],
            IconButton(
              icon: Icon(Icons.person_add, color: CouleursApp.blanc, size: screenWidth * 0.06), // UI Design: Taille adaptative
              onPressed: () => _rejoindreAssociation(context),
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
              // Section En-tête avec logo et infos principales
              _construireEnTete(),
              SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
              
              // Section Statistiques
              _construireSectionStatistiques(),
              SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
              
              // Section Description - SIMPLIFIÉ
              if (widget.association.descriptionLongue != null) ...[
                _construireSectionDescription(),
                SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
              ],

              // Section Événements à Venir - Données dynamiques
              if (_chargementEvenements) ...[
                _construireChargementEvenements(),
                SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
              ] else if (_evenementsAssociation.isNotEmpty) ...[
                _construireSectionEvenements(context),
                SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
              ],

              // Section Activités Organisées
              _construireSectionActivites(),
              SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif

              // Section Actualités Internes - Données dynamiques
              if (_chargementActualites) ...[
                _construireChargementActualites(),
                SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
              ] else if (_actualitesAssociation.isNotEmpty) ...[
              _construireSectionActualites(),
              SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
              ],
              
              // Section Contact
              if (widget.association.aDesContacts) ...[
                _construireSectionContact(),
                SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
              ],
              
              // Boutons d'action principaux
              _construireBoutonsActions(context),
              SizedBox(height: screenHeight * 0.04), // UI Design: Espacement adaptatif
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBarWidget(
        indexSelectionne: 3, // Associations
        onTap:
            (index) => NavigationService.gererNavigationNavBar(context, index),
      ),
    );
  }

  // UI Design: En-tête avec logo et informations principales
  Widget _construireEnTete() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04), // UI Design: Marge adaptative
      padding: EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AssociationsUtils.obtenirCouleurType(widget.association.typeAssociation),
            AssociationsUtils.obtenirCouleurType(
              widget.association.typeAssociation,
            ).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AssociationsUtils.obtenirCouleurType(
              widget.association.typeAssociation,
            ).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo/Icône
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04), // UI Design: Padding adaptatif
            decoration: BoxDecoration(
              color: CouleursApp.blanc.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              AssociationsUtils.obtenirIconeType(widget.association.typeAssociation),
              size: screenWidth * 0.1, // UI Design: Taille adaptative
              color: CouleursApp.blanc,
            ),
          ),
          SizedBox(width: screenWidth * 0.04), // UI Design: Espacement adaptatif
          // Informations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.association.nom,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05, // UI Design: Taille adaptative
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.blanc,
                  ),
                  overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                  maxLines: 2,
                ),
                SizedBox(height: screenHeight * 0.005), // UI Design: Espacement adaptatif
                Text(
                  widget.association.description,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                    color: CouleursApp.blanc.withValues(alpha: 0.9),
                  ),
                  overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                  maxLines: 2,
                ),
                SizedBox(height: screenHeight * 0.01), // UI Design: Espacement adaptatif
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
                        '${widget.association.membresActifs.length} membres',
                        style: TextStyle(
                          color: CouleursApp.blanc,
                          fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                        maxLines: 1,
                      ),
                    ),
                    if (widget.association.estActive) ...[
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
                          'ACTIVE',
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
                  ],
                ),
                SizedBox(height: screenHeight * 0.01), // UI Design: Espacement adaptatif
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: CouleursApp.blanc.withValues(alpha: 0.8),
                      size: screenWidth * 0.04,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      'Chef: ${_obtenirNomChefAssociation()}',
                      style: TextStyle(
                        color: CouleursApp.blanc.withValues(alpha: 0.9),
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Section statistiques de l'association modernisée
  Widget _construireSectionStatistiques() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    final anneesExistence = DateTime.now().year - widget.association.dateCreation.year;
    final tauxActivite = widget.association.activites.isNotEmpty ? 
        (widget.association.activites.length / 10 * 100).clamp(0, 100).round() : 0; // Simulation taux d'activité
    final couleurAssociation = AssociationsUtils.obtenirCouleurType(widget.association.typeAssociation);

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec titre et icône
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.025),
                decoration: BoxDecoration(
                  color: couleurAssociation.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics,
                  color: couleurAssociation,
                  size: screenWidth * 0.06,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistiques de l\'association',
                      style: StylesTexteApp.titre.copyWith(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.w700,
                        color: CouleursApp.texteFonce,
                      ),
                    ),
                    Text(
                      'Données clés de ${widget.association.nom}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.025),
          
          // Grille de statistiques modernes
          Row(
            children: [
              Expanded(
                child: _construireCarteStatistiqueAssociation(
                  'Membres',
                  '${widget.association.membresActifs.length}',
                  Icons.groups,
                  couleurAssociation,
                  'Membres actifs',
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: _construireCarteStatistiqueAssociation(
                  'Existence',
                  '$anneesExistence ans',
                  Icons.cake,
                  couleurAssociation,
                  'Années d\'existence',
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            children: [
              Expanded(
                child: _construireCarteStatistiqueAssociation(
                  'Activités',
                  '${widget.association.activites.length}',
                  Icons.event,
                  couleurAssociation,
                  'Activités organisées',
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: _construireCarteStatistiqueAssociation(
                  'Taux',
                  '$tauxActivite%',
                  Icons.trending_up,
                  couleurAssociation,
                  'Taux d\'activité',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UI Design: Carte statistique moderne pour association
  Widget _construireCarteStatistiqueAssociation(String titre, String valeur, IconData icone, Color couleur, String description) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            couleur.withValues(alpha: 0.15),
            couleur.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: couleur.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: couleur.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                  color: couleur.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icone,
                  color: couleur,
                  size: screenWidth * 0.055,
                ),
              ),
              SizedBox(width: screenWidth * 0.025),
              Expanded(
                child: Text(
                  titre,
                  style: TextStyle(
                    fontSize: screenWidth * 0.038,
                    color: CouleursApp.texteFonce.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.025),
          Text(
            valeur,
            style: TextStyle(
              fontSize: screenWidth * 0.065,
              fontWeight: FontWeight.bold,
              color: couleur,
            ),
          ),
          SizedBox(height: screenWidth * 0.015),
          Text(
            description,
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: CouleursApp.texteFonce.withValues(alpha: 0.6),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // UI Design: Section contact
  Widget _construireSectionContact() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Marge adaptative
      padding: EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_phone,
                color: AssociationsUtils.obtenirCouleurType(
                  widget.association.typeAssociation,
                ),
                size: screenWidth * 0.06, // UI Design: Taille adaptative
              ),
              SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Text(
                'Contact',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                ),
                overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
          
          // Informations de contact
          _construireInfoContact(
            Icons.email,
            'Email',
            _obtenirEmailAssociation(),
            cliquable: true,
          ),
          SizedBox(height: screenHeight * 0.015),
          _construireInfoContact(
            Icons.phone,
            'Téléphone',
            _obtenirTelephoneAssociation(),
            cliquable: true,
          ),
          SizedBox(height: screenHeight * 0.015),
          _construireInfoContact(
            Icons.location_on,
            'Local',
            _obtenirLocalAssociation(),
            cliquable: false,
          ),
          SizedBox(height: screenHeight * 0.015),
          _construireInfoContact(
            Icons.schedule,
            'Horaires',
            _obtenirHorairesAssociation(),
            cliquable: false,
          ),
        ],
      ),
    );
  }



  // Helper: Construire une info de contact
  Widget _construireInfoContact(
    IconData icone,
    String label,
    String valeur, {
    bool cliquable = false,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    return Row(
      children: [
        Icon(
          icone,
          color:
              cliquable
                  ? AssociationsUtils.obtenirCouleurType(
                    widget.association.typeAssociation,
                  )
                  : CouleursApp.texteFonce.withValues(alpha: 0.6),
          size: screenWidth * 0.05, // UI Design: Taille adaptative
        ),
        SizedBox(width: screenWidth * 0.03), // UI Design: Espacement adaptatif
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
                color: CouleursApp.texteFonce.withValues(alpha: 0.6),
              ),
              overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
              maxLines: 1,
            ),
            Text(
              valeur,
              style: TextStyle(
                fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                fontWeight: FontWeight.w500,
                color:
                    cliquable
                        ? AssociationsUtils.obtenirCouleurType(
                          widget.association.typeAssociation,
                        )
                        : CouleursApp.texteFonce,
                decoration: cliquable ? TextDecoration.underline : null,
              ),
              overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
              maxLines: 1,
            ),
          ],
        ),
      ],
    );
  }

  // UI Design: Section description de l'association
  Widget _construireSectionDescription() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04), // UI Design: Marge adaptative
      padding: EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AssociationsUtils.obtenirCouleurType(
                  widget.association.typeAssociation,
                ),
                size: screenWidth * 0.06, // UI Design: Taille adaptative
              ),
              SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Text(
                'À Propos',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                ),
                overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015), // UI Design: Espacement adaptatif
          Text(
            widget.association.descriptionLongue!,
            style: TextStyle(
              fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
              height: 1.5,
              color: CouleursApp.texteFonce,
            ),
            overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
            maxLines: 6,
          ),
        ],
      ),
    );
  }

  // UI Design: Section événements à venir
  Widget _construireSectionEvenements(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Marge adaptative
      padding: EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event, color: Colors.orange, size: screenWidth * 0.06), // UI Design: Taille adaptative
              SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Text(
                'Événements à Venir',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                ),
                overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
          // UI Design: Affichage des événements dynamiques
          ..._evenementsAssociation.asMap().entries.map((entry) {
            final evenement = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: screenHeight * 0.015), // UI Design: Espacement adaptatif
              padding: EdgeInsets.all(screenWidth * 0.04), // UI Design: Padding adaptatif
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        color: Colors.orange,
                        size: screenWidth * 0.05, // UI Design: Taille adaptative
                      ),
                      SizedBox(width: screenWidth * 0.03), // UI Design: Espacement adaptatif
                      Expanded(
                        child: Text(
                          evenement.titre,
                          style: TextStyle(
                            fontSize: screenWidth * 0.038, // UI Design: Taille adaptative
                            fontWeight: FontWeight.w600,
                            color: CouleursApp.texteFonce,
                          ),
                          overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  // Description
                  if (evenement.description.isNotEmpty) ...[
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      evenement.description,
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  SizedBox(height: screenHeight * 0.015), // UI Design: Espacement adaptatif
                  
                  // Date et lieu
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.grey[600],
                        size: screenWidth * 0.04, // UI Design: Taille adaptative
                      ),
                      SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
                      Text(
                        '${evenement.dateDebut.day}/${evenement.dateDebut.month}/${evenement.dateDebut.year} - ${evenement.dateDebut.hour.toString().padLeft(2, '0')}:${evenement.dateDebut.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
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
                        SizedBox(width: screenWidth * 0.01),
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
                  if (evenement.inscriptionRequise && !_estChefAssociation) ...[
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
                            : (evenement.estComplet ? Colors.grey : Colors.orange),
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
            );
          }),
        ],
      ),
    );
  }

  // UI Design: Indicateur de chargement pour les événements
  Widget _construireChargementEvenements() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event, color: Colors.orange, size: screenWidth * 0.06),
              SizedBox(width: screenWidth * 0.02),
              Text(
                'Événements à Venir',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045,
                        ),
                      ),
                    ],
                  ),
          SizedBox(height: screenHeight * 0.02),
          // Indicateur de chargement
          Center(
            child: Column(
              children: [
                const CircularProgressIndicator(
                  color: CouleursApp.principal,
                  strokeWidth: 2,
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  'Chargement des événements...',
                  style: TextStyle(
                    fontSize: screenWidth * 0.032,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
                ],
              ),
            );
  }

  // UI Design: Indicateur de chargement pour les actualités
  Widget _construireChargementActualites() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.newspaper, color: CouleursApp.accent, size: screenWidth * 0.06),
              SizedBox(width: screenWidth * 0.02),
              Text(
                'Actualités Internes',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          // Indicateur de chargement
          Center(
            child: Column(
              children: [
                const CircularProgressIndicator(
                  color: CouleursApp.principal,
                  strokeWidth: 2,
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  'Chargement des actualités...',
                  style: TextStyle(
                    fontSize: screenWidth * 0.032,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Section activités organisées
  Widget _construireSectionActivites() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Marge adaptative
      padding: EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sports_esports,
                color: AssociationsUtils.obtenirCouleurType(
                  widget.association.typeAssociation,
                ),
                size: screenWidth * 0.06, // UI Design: Taille adaptative
              ),
              SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Text(
                'Activités Organisées',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                ),
                overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
          Wrap(
            spacing: screenWidth * 0.02, // UI Design: Espacement adaptatif
            runSpacing: screenWidth * 0.02, // UI Design: Espacement adaptatif
            children:
                widget.association.activites.map((activite) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03, // UI Design: Padding adaptatif
                      vertical: screenWidth * 0.02,
                    ),
                    decoration: BoxDecoration(
                      color: AssociationsUtils.obtenirCouleurType(
                        widget.association.typeAssociation,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AssociationsUtils.obtenirCouleurType(
                          widget.association.typeAssociation,
                        ).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      activite,
                      style: TextStyle(
                        fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
                        fontWeight: FontWeight.w500,
                        color: AssociationsUtils.obtenirCouleurType(
                          widget.association.typeAssociation,
                        ),
                      ),
                      overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                      maxLines: 1,
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  // UI Design: Section actualités internes
  Widget _construireSectionActualites() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    // UI Design: Utiliser les actualités dynamiques chargées
    final actualites = _actualitesAssociation;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Marge adaptative
      padding: EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.newspaper, color: CouleursApp.accent, size: screenWidth * 0.06), // UI Design: Taille adaptative
              SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Text(
                'Actualités Internes',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                ),
                overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
          ...actualites.map((actualite) {
            return Container(
              margin: EdgeInsets.only(bottom: screenHeight * 0.02), // UI Design: Espacement adaptatif
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: screenWidth * 0.02, // UI Design: Taille adaptative
                        height: screenWidth * 0.02, // UI Design: Taille adaptative
                        decoration: const BoxDecoration(
                          color: CouleursApp.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
                      Text(
                        '${actualite.datePublication.day}/${actualite.datePublication.month}/${actualite.datePublication.year}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
                          color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                        maxLines: 1,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.008), // UI Design: Espacement adaptatif
                  Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.04), // UI Design: Padding adaptatif
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge priorité et titre
                        Row(
                          children: [
                            // Badge priorité
                            if (actualite.priorite == 'urgente') ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.02,
                                  vertical: screenWidth * 0.005,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'URGENT',
                                  style: TextStyle(
                                    color: CouleursApp.blanc,
                                    fontSize: screenWidth * 0.025,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                            ] else if (actualite.priorite == 'importante') ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.02,
                                  vertical: screenWidth * 0.005,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'IMPORTANT',
                                  style: TextStyle(
                                    color: CouleursApp.blanc,
                                    fontSize: screenWidth * 0.025,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                              SizedBox(width: screenWidth * 0.02),
                            ],
                          ],
                        ),
                        if (actualite.priorite == 'urgente' || actualite.priorite == 'importante' || actualite.estEpinglee)
                          SizedBox(height: screenHeight * 0.008),
                        Text(
                          actualite.titre,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                            fontWeight: FontWeight.w600,
                            color: CouleursApp.texteFonce,
                          ),
                          overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                          maxLines: 2,
                        ),
                        SizedBox(height: screenHeight * 0.005), // UI Design: Espacement adaptatif
                        Text(
                          actualite.description,
                          style: TextStyle(
                            fontSize: screenWidth * 0.033, // UI Design: Taille adaptative
                            color: CouleursApp.texteFonce.withValues(
                              alpha: 0.8,
                            ),
                            height: 1.4,
                          ),
                          overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }



  // UI Design: Boutons d'actions principaux
  Widget _construireBoutonsActions(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Padding adaptatif
      child: Column(
        children: [
          // Bouton rejoindre l'association
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _rejoindreAssociation(context),
              icon: Icon(Icons.group_add, size: screenWidth * 0.05), // UI Design: Taille adaptative
              label: Text(
                'Rejoindre ${widget.association.nom}',
                style: TextStyle(
                  fontSize: screenWidth * 0.04, // UI Design: Taille adaptative
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AssociationsUtils.obtenirCouleurType(
                  widget.association.typeAssociation,
                ),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02), // UI Design: Padding adaptatif
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.015), // UI Design: Espacement adaptatif

          // Bouton de gestion pour le chef de l'association
          if (_estChefAssociation) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _ouvrirGestionDemandes(),
                icon: Icon(Icons.admin_panel_settings, size: screenWidth * 0.05), // UI Design: Taille adaptative
                label: Text(
                  'Gérer les demandes d\'adhésion',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04, // UI Design: Taille adaptative
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                  maxLines: 1,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02), // UI Design: Padding adaptatif
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.015), // UI Design: Espacement adaptatif
          ],
        ],
      ),
    );
  }





  void _rejoindreAssociation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.group_add,
                color: AssociationsUtils.obtenirCouleurType(
                  widget.association.typeAssociation,
                ),
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Rejoindre ${widget.association.nom}',
                  style: StylesTexteApp.titre.copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'En rejoignant cette association, vous bénéficierez de :',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: CouleursApp.texteFonce,
                ),
              ),
              const SizedBox(height: 12),
              ..._obtenirAvantagesMembre().map((avantage) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AssociationsUtils.obtenirCouleurType(
                          widget.association.typeAssociation,
                        ),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          avantage,
                          style: TextStyle(
                            fontSize: 13,
                            color: CouleursApp.texteFonce.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AssociationsUtils.obtenirCouleurType(
                    widget.association.typeAssociation,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Cotisation annuelle : ${_obtenirCotisation()}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AssociationsUtils.obtenirCouleurType(
                      widget.association.typeAssociation,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _confirmerAdhesion(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AssociationsUtils.obtenirCouleurType(
                  widget.association.typeAssociation,
                ),
                foregroundColor: Colors.white,
              ),
              child: const Text('Rejoindre'),
            ),
          ],
        );
      },
    );
  }

  // Obtenir les avantages de membre selon l'association
  List<String> _obtenirAvantagesMembre() {
    switch (widget.association.id) {
      case '1': // AÉUQAR
        return [
          'Assurance santé et dentaire étendue',
          'Rabais dans les commerces partenaires',
          'Accès prioritaire aux événements',
          'Représentation étudiante officielle',
        ];
      case '2': // Radio UQAR
        return [
          'Accès aux studios d\'enregistrement',
          'Formation technique gratuite',
          'Participation aux émissions',
          'Matériel audio professionnel',
        ];
      case '3': // Sport UQAR
        return [
          'Accès gratuit aux installations sportives',
          'Inscription prioritaire aux cours',
          'Équipement sportif à tarif réduit',
          'Participation aux compétitions',
        ];
      default:
        return [
          'Participation aux activités exclusives',
          'Réseautage avec les membres',
          'Développement de compétences',
          'Engagement communautaire',
        ];
    }
  }

  // Obtenir cotisation selon l'association
  String _obtenirCotisation() {
    switch (widget.association.id) {
      case 'asso_001': // AEI
        return 'Gratuit';
      case 'asso_002': // Club Photo UQAR
        return '25\$ par session';
      case 'asso_003': // Sport UQAR
        return '40\$ par session';
      case 'asso_004': // AGE
        return '15\$ par session';
      default:
        return '20\$ par session';
    }
  }

  // Nouvelle méthode pour confirmer l'adhésion
  Future<void> _confirmerAdhesion(BuildContext context) async {
    Navigator.of(context).pop();
    
    final utilisateur = _authentificationService.utilisateurActuel;
    if (utilisateur == null) {
      _afficherErreur('Vous devez être connecté pour rejoindre une association');
      return;
    }

    // Vérifier si l'adhésion est possible
    final verification = await _adhesionsService.peutDemanderAdhesion(utilisateur, widget.association);
    
    if (!verification['peut']) {
      _afficherErreur(verification['raison']);
      return;
    }

    // Créer la demande d'adhésion
    final success = await _adhesionsService.creerDemandeAdhesion(
      utilisateurId: utilisateur.id,
      associationId: widget.association.id,
      messageDemande: 'Je souhaite rejoindre cette association pour participer à ses activités.',
      roledemande: 'membre',
    );

    if (success) {
      _afficherSucces('Demande d\'adhésion envoyée à ${widget.association.nom} !');
    } else {
      _afficherErreur('Erreur lors de l\'envoi de la demande d\'adhésion');
    }
  }

  // Ouvrir l'écran de gestion des demandes (pour les chefs)
  void _ouvrirGestionDemandes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GestionAssociationEcran(
          association: widget.association,
        ),
      ),
    );
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

  // Méthodes pour obtenir les informations de contact et du chef
  String _obtenirNomChefAssociation() {
    // Utiliser le chefId de l'association pour obtenir le nom du chef
    switch (widget.association.chefId) {
      case 'etud_001': // Alexandre Martin
        return 'Alexandre Martin';
      case 'etud_006': // Sophie Gagnon
        return 'Sophie Gagnon';
      case 'etud_007': // Maxime Leblanc
        return 'Maxime Leblanc';
      case 'etud_008': // Juliette Beaulieu
        return 'Juliette Beaulieu';
      case 'etud_009': // Laurence Giguère
        return 'Laurence Giguère';
      case 'etud_010': // Maria Santos
        return 'Maria Santos';
      case 'etud_011': // Isabelle Dufour
        return 'Isabelle Dufour';
      default:
        return widget.association.president ?? 'À déterminer';
    }
  }

  String _obtenirEmailAssociation() {
    // UI Design: Utiliser les vraies données de l'association
    return widget.association.email ?? 'Non renseigné';
  }

  String _obtenirTelephoneAssociation() {
    // UI Design: Utiliser les vraies données de l'association
    return widget.association.telephone ?? 'Non renseigné';
  }

  String _obtenirLocalAssociation() {
    // UI Design: Utiliser les vraies données de l'association
    return widget.association.localisation ?? 'Non renseigné';
  }

  String _obtenirHorairesAssociation() {
    // UI Design: Utiliser les vraies données de l'association
    return widget.association.horairesBureau ?? 'Non renseigné';
  }

  // UI Design: Gestion des inscriptions aux événements
  final Map<String, bool> _evenementsInscrits = {}; // Cache des inscriptions de l'utilisateur

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
      final evenementsService = EvenementsService();
      final estInscrit = _estInscritEvenement(evenement.id);
      
      bool success;
      if (estInscrit) {
        // Désinscription
        success = await evenementsService.desinscrireUtilisateur(evenement.id, utilisateur.id);
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
        
        success = await evenementsService.inscrireUtilisateur(evenement.id, utilisateur.id);
        if (success) {
          setState(() {
            _evenementsInscrits[evenement.id] = true;
          });
          _afficherSucces('Inscription réussie à "${evenement.titre}"');
        } else {
          _afficherErreur('Erreur lors de l\'inscription');
        }
      }
      
      // Recharger les données de l'événement pour mettre à jour le compteur
      await _chargerDonneesAssociation();
    } catch (e) {
      _afficherErreur('Erreur: $e');
    }
  }

}

