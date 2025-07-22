import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/association.dart';
import '../services/navigation_service.dart';
import '../utils/associations_utils.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import '../widgets/widget_section_statistiques.dart';

// UI Design: Page de détails complète d'une association UQAR
class DetailsAssociationEcran extends StatelessWidget {
  final Association association;

  const DetailsAssociationEcran({super.key, required this.association});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: WidgetBarreAppPersonnalisee(
        titre: association.nom,
        sousTitre: AssociationsUtils.obtenirNomType(association.typeAssociation),
        afficherProfil: false,
        widgetFin: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.person_add, color: CouleursApp.blanc),
              onPressed: () => _rejoindreAssociation(context),
            ),
            IconButton(
              icon: Icon(Icons.share, color: CouleursApp.blanc),
              onPressed: () => _partagerAssociation(context),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section En-tête avec logo et infos principales
              _construireEnTete(),
              const SizedBox(height: 16),
              
              // Section Statistiques
              _construireSectionStatistiques(),
              const SizedBox(height: 24),
              
              // Section Description - SIMPLIFIÉ
              if (association.descriptionLongue != null) ...[
                _construireSectionDescription(),
                const SizedBox(height: 24),
              ],

              // Section Événements à Venir
              if (association.evenementsVenir != null &&
                  association.evenementsVenir!.isNotEmpty) ...[
                _construireSectionEvenements(context),
                const SizedBox(height: 24),
              ],

              // Section Activités Organisées
              _construireSectionActivites(),
              const SizedBox(height: 24),

              // Section Actualités Internes
              _construireSectionActualites(),
              const SizedBox(height: 24),
              
              // Section Contact
              if (association.aDesContacts) ...[
                _construireSectionContact(),
                const SizedBox(height: 24),
              ],
              
              // Boutons d'action principaux
              _construireBoutonsActions(context),
              const SizedBox(height: 32),
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
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AssociationsUtils.obtenirCouleurType(association.typeAssociation),
            AssociationsUtils.obtenirCouleurType(
              association.typeAssociation,
            ).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AssociationsUtils.obtenirCouleurType(
              association.typeAssociation,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CouleursApp.blanc.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              AssociationsUtils.obtenirIconeType(association.typeAssociation),
              size: 40,
              color: CouleursApp.blanc,
            ),
          ),
          const SizedBox(width: 16),
          // Informations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  association.nom,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.blanc,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  association.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: CouleursApp.blanc.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: CouleursApp.blanc.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${association.nombreMembresFormatte} membres',
                        style: TextStyle(
                          color: CouleursApp.blanc,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (association.estActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: CouleursApp.blanc,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Section statistiques de l'association
  Widget _construireSectionStatistiques() {
    final anneesExistence = DateTime.now().year - association.dateCreation.year;
    
    return WidgetSectionStatistiques.marketplace(
      statistiques: [
        ElementStatistique(
          valeur: association.nombreMembresFormatte,
          label: 'Membres\nactifs',
          icone: Icons.groups,
          couleurIcone: AssociationsUtils.obtenirCouleurType(
            association.typeAssociation,
          ),
        ),
        ElementStatistique(
          valeur: '$anneesExistence',
          label: 'Années\nd\'existence',
          icone: Icons.cake,
          couleurIcone: AssociationsUtils.obtenirCouleurType(
            association.typeAssociation,
          ),
        ),
        ElementStatistique(
          valeur: '${association.activites.length}',
          label: 'Activités\norganisées',
          icone: Icons.event,
          couleurIcone: AssociationsUtils.obtenirCouleurType(
            association.typeAssociation,
          ),
        ),
      ],
    );
  }

  // UI Design: Section contact
  Widget _construireSectionContact() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
                  association.typeAssociation,
                ),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Contact',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Email
          if (association.email != null) ...[
            GestureDetector(
              onTap: () => _lancerEmail(association.email!),
              child: _construireInfoContact(
                Icons.email,
                'Email',
                association.email!,
                cliquable: true,
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Téléphone
          if (association.telephone != null) ...[
            GestureDetector(
              onTap: () => _lancerTelephone(association.telephone!),
              child: _construireInfoContact(
                Icons.phone,
                'Téléphone',
                association.telephone!,
                cliquable: true,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // UI Design: Section rejoindre l'association - GRATUIT
  Widget _construireSectionRejoindre() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {}, // Cette méthode n'est plus utilisée
        style: ElevatedButton.styleFrom(
          backgroundColor: AssociationsUtils.obtenirCouleurType(
            association.typeAssociation,
          ),
          foregroundColor: CouleursApp.blanc,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_add, size: 24),
            const SizedBox(width: 12),
            Text(
              'Rejoindre l\'association',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    return Row(
      children: [
        Icon(
          icone,
          color:
              cliquable
                  ? AssociationsUtils.obtenirCouleurType(
                    association.typeAssociation,
                  )
                  : CouleursApp.texteFonce.withValues(alpha: 0.6),
          size: 20,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: CouleursApp.texteFonce.withValues(alpha: 0.6),
              ),
            ),
            Text(
              valeur,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    cliquable
                        ? AssociationsUtils.obtenirCouleurType(
                          association.typeAssociation,
                        )
                        : CouleursApp.texteFonce,
                decoration: cliquable ? TextDecoration.underline : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // UI Design: Section description de l'association
  Widget _construireSectionDescription() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
                  association.typeAssociation,
                ),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'À Propos',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            association.descriptionLongue!,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: CouleursApp.texteFonce,
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Section événements à venir
  Widget _construireSectionEvenements(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
              Icon(Icons.event, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text(
                'Événements à Venir',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...association.evenementsVenir!.asMap().entries.map((entry) {
            final index = entry.key;
            final evenement = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
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
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          evenement,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: CouleursApp.texteFonce,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _obtenirDetailsEvenement(association.id, index),
                          style: TextStyle(
                            fontSize: 12,
                            color: CouleursApp.texteFonce.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _inscrireEvenement(context, evenement),
                        icon: Icon(Icons.event_available, size: 16),
                        label: Text('S\'inscrire'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          textStyle: const TextStyle(fontSize: 12),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
                  association.typeAssociation,
                ),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Activités Organisées',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                association.activites.map((activite) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AssociationsUtils.obtenirCouleurType(
                        association.typeAssociation,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AssociationsUtils.obtenirCouleurType(
                          association.typeAssociation,
                        ).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      activite,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AssociationsUtils.obtenirCouleurType(
                          association.typeAssociation,
                        ),
                      ),
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
    // Données simulées d'actualités - à remplacer par de vraies données
    final actualites = _obtenirActualitesAssociation();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
              Icon(Icons.newspaper, color: CouleursApp.accent, size: 24),
              const SizedBox(width: 8),
              Text(
                'Actualités Internes',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...actualites.map((actualite) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: CouleursApp.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        actualite['date']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          actualite['titre']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: CouleursApp.texteFonce,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          actualite['description']!,
                          style: TextStyle(
                            fontSize: 13,
                            color: CouleursApp.texteFonce.withValues(
                              alpha: 0.8,
                            ),
                            height: 1.4,
                          ),
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
    switch (association.id) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Bouton rejoindre l'association
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _rejoindreAssociation(context),
              icon: Icon(Icons.group_add, size: 20),
              label: Text('Rejoindre ${association.nom}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AssociationsUtils.obtenirCouleurType(
                  association.typeAssociation,
                ),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Bouton s'abonner aux actualités
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _sabonnerActualites(context),
              icon: Icon(Icons.notifications_active, size: 20),
              label: Text('S\'abonner aux actualités'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AssociationsUtils.obtenirCouleurType(
                  association.typeAssociation,
                ),
                side: BorderSide(
                  color: AssociationsUtils.obtenirCouleurType(
                    association.typeAssociation,
                  ),
                  width: 2,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
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
              Icon(Icons.event_available, color: Colors.orange, size: 24),
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
                  style: TextStyle(
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
                        Icon(Icons.check_circle, color: Colors.white),
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
              child: Text('Confirmer'),
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
            Icon(Icons.notifications_active, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Abonné aux actualités de ${association.nom}'),
            ),
          ],
        ),
        backgroundColor: AssociationsUtils.obtenirCouleurType(
          association.typeAssociation,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _partagerAssociation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Partage de ${association.nom}'),
        backgroundColor: AssociationsUtils.obtenirCouleurType(
          association.typeAssociation,
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
                  association.typeAssociation,
                ),
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Rejoindre ${association.nom}',
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
                          association.typeAssociation,
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
                    association.typeAssociation,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Cotisation annuelle : ${_obtenirCotisation()}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AssociationsUtils.obtenirCouleurType(
                      association.typeAssociation,
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
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.group_add, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Demande d\'adhésion envoyée à ${association.nom}',
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AssociationsUtils.obtenirCouleurType(
                      association.typeAssociation,
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AssociationsUtils.obtenirCouleurType(
                  association.typeAssociation,
                ),
                foregroundColor: Colors.white,
              ),
              child: Text('Rejoindre'),
            ),
          ],
        );
      },
    );
  }

  // Obtenir les avantages de membre selon l'association
  List<String> _obtenirAvantagesMembre() {
    switch (association.id) {
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
    switch (association.id) {
      case '1': // AÉUQAR
        return '95\$ (inclus dans frais de scolarité)';
      case '2': // Radio UQAR
        return '25\$ par session';
      case '3': // Sport UQAR
        return '40\$ par session';
      default:
        return '20\$ par session';
    }
  }

  void _lancerEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _lancerTelephone(String telephone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: telephone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
} 
