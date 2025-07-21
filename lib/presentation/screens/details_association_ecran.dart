import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/association.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import '../widgets/widget_section_statistiques.dart';
import '../services/navigation_service.dart';
import '../utils/associations_utils.dart';

// UI Design: Page de détails complète d'une association UQAR
class DetailsAssociationEcran extends StatelessWidget {
  final Association association;

  const DetailsAssociationEcran({
    Key? key,
    required this.association,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: WidgetBarreAppPersonnalisee(
        titre: association.nom,
        sousTitre: AssociationsUtils.obtenirNomType(association.typeAssociation),
        widgetFin: IconButton(
          icon: Icon(Icons.share, color: CouleursApp.blanc),
          onPressed: () => _partagerAssociation(context),
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
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CouleursApp.blanc,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'À Propos',
                        style: StylesTexteApp.titre.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        association.descriptionLongue!,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Section Contact
              if (association.aDesContacts) ...[
                _construireSectionContact(),
                const SizedBox(height: 24),
              ],
              
              // Section Rejoindre l'association - GRATUIT
              _construireSectionRejoindre(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBarWidget(
        indexSelectionne: 3, // Associations
        onTap: (index) => NavigationService.gererNavigationNavBar(context, index),
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
            AssociationsUtils.obtenirCouleurType(association.typeAssociation).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AssociationsUtils.obtenirCouleurType(association.typeAssociation).withValues(alpha: 0.3),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          couleurIcone: AssociationsUtils.obtenirCouleurType(association.typeAssociation),
        ),
        ElementStatistique(
          valeur: '$anneesExistence',
          label: 'Années\nd\'existence',
          icone: Icons.cake,
          couleurIcone: AssociationsUtils.obtenirCouleurType(association.typeAssociation),
        ),
        ElementStatistique(
          valeur: '${association.activites.length}',
          label: 'Activités\norganisées',
          icone: Icons.event,
          couleurIcone: AssociationsUtils.obtenirCouleurType(association.typeAssociation),
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
                color: AssociationsUtils.obtenirCouleurType(association.typeAssociation),
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
        onPressed: () => _rejoindreAssociation(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AssociationsUtils.obtenirCouleurType(association.typeAssociation),
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
              'Rejoindre ${association.nom} - GRATUIT',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Construire une info de contact
  Widget _construireInfoContact(IconData icone, String label, String valeur, {bool cliquable = false}) {
    return Row(
      children: [
        Icon(
          icone,
          color: cliquable ? AssociationsUtils.obtenirCouleurType(association.typeAssociation) : CouleursApp.texteFonce.withValues(alpha: 0.6),
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
                color: cliquable ? AssociationsUtils.obtenirCouleurType(association.typeAssociation) : CouleursApp.texteFonce,
                decoration: cliquable ? TextDecoration.underline : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Actions
  void _partagerAssociation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Partage de ${association.nom}'),
        backgroundColor: AssociationsUtils.obtenirCouleurType(association.typeAssociation),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _rejoindreAssociation() {
    print('Rejoindre ${association.nom}');
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