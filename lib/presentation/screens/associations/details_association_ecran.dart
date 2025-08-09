import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/association.dart';
import '../../services/navigation_service.dart';
import '../../services/adhesions_service.dart';
import '../../services/authentification_service.dart';
import '../../../core/di/service_locator.dart';
import '../../utils/associations_utils.dart';
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
  bool _estChefAssociation = false;

  @override
  void initState() {
    super.initState();
    _adhesionsService = ServiceLocator.obtenirService<AdhesionsService>();
    _authentificationService = ServiceLocator.obtenirService<AuthentificationService>();
    _adhesionsService.initialiser();
    print('DEBUG: initState appelé');
    _verifierStatutChef();
  }

  Future<void> _verifierStatutChef() async {
    final utilisateur = _authentificationService.utilisateurActuel;
    print('DEBUG: _verifierStatutChef - utilisateur: $utilisateur');
    
    if (utilisateur != null) {
      print('DEBUG: Utilisateur ID: ${utilisateur.id}');
      print('DEBUG: Association chefId: ${widget.association.chefId}');
      print('DEBUG: Comparaison: ${widget.association.chefId} == ${utilisateur.id}');
      
      final estChefAssociation = widget.association.chefId == utilisateur.id;
      print('DEBUG: estChefAssociation: $estChefAssociation');
      
      setState(() {
        _estChefAssociation = estChefAssociation;
      });
      print('DEBUG: Après setState - _estChefAssociation: $_estChefAssociation');
    } else {
      print('DEBUG: Aucun utilisateur connecté');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG BUILD: _estChefAssociation = $_estChefAssociation');
    
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

              // Section Événements à Venir
              if (widget.association.evenementsVenir != null &&
                  widget.association.evenementsVenir!.isNotEmpty) ...[
                _construireSectionEvenements(context),
                SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
              ],

              // Section Activités Organisées
              _construireSectionActivites(),
              SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif

              // Section Actualités Internes
              _construireSectionActualites(),
              SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
              
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
                        '${widget.association.nombreMembresFormatte} membres',
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
    final tauxActivite = widget.association.activites.length > 0 ? 
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
                  widget.association.nombreMembresFormatte,
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

  // UI Design: Section rejoindre l'association - GRATUIT
  Widget _construireSectionRejoindre() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Marge adaptative
      child: ElevatedButton(
        onPressed: () {}, // Cette méthode n'est plus utilisée
        style: ElevatedButton.styleFrom(
          backgroundColor: AssociationsUtils.obtenirCouleurType(
            widget.association.typeAssociation,
          ),
          foregroundColor: CouleursApp.blanc,
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02), // UI Design: Padding adaptatif
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_add, size: screenWidth * 0.06), // UI Design: Taille adaptative
            SizedBox(width: screenWidth * 0.03), // UI Design: Espacement adaptatif
            Text(
              'Rejoindre l\'association',
              style: TextStyle(
                fontSize: screenWidth * 0.04, // UI Design: Taille adaptative
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
              maxLines: 1,
            ),
          ],
        ),
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
          ...widget.association.evenementsVenir!.asMap().entries.map((entry) {
            final index = entry.key;
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
                        Icons.calendar_today,
                        color: Colors.orange,
                        size: screenWidth * 0.05, // UI Design: Taille adaptative
                      ),
                      SizedBox(width: screenWidth * 0.03), // UI Design: Espacement adaptatif
                      Expanded(
                        child: Text(
                          evenement,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                            fontWeight: FontWeight.w500,
                            color: CouleursApp.texteFonce,
                          ),
                          overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.015), // UI Design: Espacement adaptatif
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _obtenirDetailsEvenement(widget.association.id, index),
                          style: TextStyle(
                            fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
                            color: CouleursApp.texteFonce.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                          maxLines: 2,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03), // UI Design: Espacement adaptatif
                      ElevatedButton.icon(
                        onPressed: () => _inscrireEvenement(context, evenement),
                        icon: Icon(Icons.event_available, size: screenWidth * 0.04), // UI Design: Taille adaptative
                        label: Text(
                          'S\'inscrire',
                          style: TextStyle(fontSize: screenWidth * 0.03), // UI Design: Taille adaptative
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03, // UI Design: Padding adaptatif
                            vertical: screenHeight * 0.01,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
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
    
    // Données simulées d'actualités - à remplacer par de vraies données
    final actualites = _obtenirActualitesAssociation();

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
                        actualite['date']!,
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
                        Text(
                          actualite['titre']!,
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
                          actualite['description']!,
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

  // Données simulées d'actualités selon l'association
  List<Map<String, String>> _obtenirActualitesAssociation() {
    switch (widget.association.id) {
      case '1': // AÉUQAR
        return [
          {
            'date': '15 janvier 2025',
            'titre': 'Nouvelle assurance dentaire étendue',
            'description':
                'Couverture dentaire améliorée pour tous les membres avec nouveaux avantages orthodontiques.',
          },
          {
            'date': '10 janvier 2025',
            'titre': 'Assemblée générale de février',
            'description':
                'Ordre du jour disponible : budget 2025, nouveaux projets étudiants et élections.',
          },
          {
            'date': '5 janvier 2025',
            'titre': 'Partenariat commerce local',
            'description':
                'Nouveaux rabais chez 15 commerces de Rimouski avec la carte étudiante AÉUQAR.',
          },
        ];
      case '2': // Radio UQAR
        return [
          {
            'date': '12 janvier 2025',
            'titre': 'Nouveau studio d\'enregistrement',
            'description':
                'Équipement professionnel installé pour améliorer la qualité des émissions étudiantes.',
          },
          {
            'date': '8 janvier 2025',
            'titre': 'Formation podcasting',
            'description':
                'Atelier gratuit le 20 janvier pour apprendre les techniques de création de podcasts.',
          },
        ];
      case '3': // Sport UQAR
        return [
          {
            'date': '14 janvier 2025',
            'titre': 'Tournoi inter-universitaire',
            'description':
                'Inscription ouverte pour le championnat provincial de volleyball en mars.',
          },
          {
            'date': '11 janvier 2025',
            'titre': 'Nouveaux cours de yoga',
            'description':
                'Sessions hebdomadaires ajoutées les mardis et jeudis au centre sportif.',
          },
        ];
      default:
        return [
          {
            'date': '13 janvier 2025',
            'titre': 'Réunion mensuelle',
            'description':
                'Prochaine réunion prévue le 25 janvier pour planifier les activités de février.',
          },
          {
            'date': '9 janvier 2025',
            'titre': 'Nouveau projet en cours',
            'description':
                'Lancement d\'une initiative pour améliorer l\'engagement étudiant sur le campus.',
          },
        ];
    }
  }

  // Obtenir détails supplémentaires pour chaque événement
  String _obtenirDetailsEvenement(String associationId, int evenementIndex) {
    switch (associationId) {
      case '1': // AÉUQAR
        final details = [
          'Salle communautaire - 19h00 • Places limitées',
          'Campus principal - 20h30 • Inscription gratuite',
        ];
        return evenementIndex < details.length
            ? details[evenementIndex]
            : 'Détails à venir';
      case '2': // Radio UQAR
        final details = [
          'Studio A - 18h00 • Apportez vos instruments',
          'Local 102 - 16h00 • Matériel fourni',
        ];
        return evenementIndex < details.length
            ? details[evenementIndex]
            : 'Détails à venir';
      case '3': // Sport UQAR
        final details = [
          'Gymnase principal - 14h00 • Équipes de 6',
          'Départ campus - 9h00 • Inscription 15',
        ];
        return evenementIndex < details.length
            ? details[evenementIndex]
            : 'Détails à venir';
      default:
        return 'Lieu et horaire à confirmer';
    }
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

  // Actions
  void _inscrireEvenement(BuildContext context, String evenement) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.event_available, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Inscription événement',
                  style: StylesTexteApp.titre.copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vous souhaitez vous inscrire à :',
                style: TextStyle(
                  color: CouleursApp.texteFonce.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  evenement,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: CouleursApp.texteFonce,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Vous recevrez une confirmation par email avec tous les détails.',
                style: TextStyle(
                  fontSize: 12,
                  color: CouleursApp.texteFonce.withValues(alpha: 0.6),
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
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Inscription confirmée pour "$evenement"',
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  void _sabonnerActualites(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Abonné aux actualités de ${widget.association.nom}'),
            ),
          ],
        ),
        backgroundColor: AssociationsUtils.obtenirCouleurType(
          widget.association.typeAssociation,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _partagerAssociation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Partage de ${widget.association.nom}'),
        backgroundColor: AssociationsUtils.obtenirCouleurType(
          widget.association.typeAssociation,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    switch (widget.association.id) {
      case 'asso_001': // AEI
        return 'aei@uqar.ca';
      case 'asso_002': // Club Photo UQAR
        return 'photo@uqar.ca';
      case 'asso_003': // Sport UQAR
        return 'sport@uqar.ca';
      case 'asso_004': // AGE
        return 'age@uqar.ca';
      default:
        return 'contact@uqar.ca';
    }
  }

  String _obtenirTelephoneAssociation() {
    switch (widget.association.id) {
      case 'asso_001': // AEI
        return '(418) 723-1986';
      case 'asso_002': // Club Photo UQAR
        return '(418) 723-1987';
      case 'asso_003': // Sport UQAR
        return '(418) 723-1988';
      case 'asso_004': // AGE
        return '(418) 723-1989';
      default:
        return '(418) 723-1986';
    }
  }

  String _obtenirLocalAssociation() {
    switch (widget.association.id) {
      case 'asso_001': // AEI
        return 'Local A-101';
      case 'asso_002': // Club Photo UQAR
        return 'Local C-302';
      case 'asso_003': // Sport UQAR
        return 'Centre sportif';
      case 'asso_004': // AGE
        return 'Local B-201';
      default:
        return 'Local à déterminer';
    }
  }

  String _obtenirHorairesAssociation() {
    switch (widget.association.id) {
      case 'asso_001': // AEI
        return 'Lun-Ven: 9h-17h';
      case 'asso_002': // Club Photo UQAR
        return 'Mar-Jeu: 14h-18h';
      case 'asso_003': // Sport UQAR
        return 'Lun-Dim: 7h-22h';
      case 'asso_004': // AGE
        return 'Lun-Ven: 10h-16h';
      default:
        return 'Horaires variables';
    }
  }

    // Méthode pour ajouter une actualité (réservée au chef de l'association)
  void _ajouterActualite(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité d\'ajout d\'actualités en développement'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

