import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import '../widgets/widget_section_statistiques.dart';
import '../services/navigation_service.dart';
import 'modifier_profil_ecran.dart';
import 'gerer_livres_ecran.dart';
import 'connexion_ecran.dart';
import 'marketplace_ecran.dart';

// UI Design: Page profil utilisateur avec informations personnelles et statistiques - OPTIMISÉ avec widgets réutilisables
class ProfilEcran extends StatelessWidget {
  const ProfilEcran({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: WidgetBarreAppPersonnalisee(
        titre: 'Marie Dubois',
        sousTitre: 'DUBM12345678\nInformatique',
        hauteurBarre: 140,
        afficherProfil: false,
        afficherBoutonRetour: true,
        widgetFin: Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: CouleursApp.blanc,
              width: 3,
            ),
            gradient: LinearGradient(
              colors: [
                CouleursApp.accent,
                CouleursApp.principal,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'MD', // Initiales Marie Dubois
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CouleursApp.blanc,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Section statistiques - VERSION SIMPLE ET FONCTIONNELLE
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CouleursApp.accent.withValues(alpha: 0.1), 
                      CouleursApp.principal.withValues(alpha: 0.1)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: CouleursApp.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _construireStatistique('12', 'Livres\néchangés', Icons.swap_horiz, CouleursApp.principal),
                    _construireStatistique('3', 'Associations\nrejointes', Icons.groups, CouleursApp.accent),
                    _construireStatistique('8', 'Mois\nà l\'UQAR', Icons.school, CouleursApp.principal),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Section mes livres - VERSION OPTIMISÉE
              _construireSectionLivres(context),
              const SizedBox(height: 24),
              
              // Section mes associations - VERSION OPTIMISÉE
              _construireSectionAssociations(context),
              const SizedBox(height: 24),
              
              // Section actions - BOUTONS PRINCIPAUX
              _construireSectionActions(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBarWidget(
        indexSelectionne: 2, // Index pour le profil
        onTap: (index) => NavigationService.gererNavigationNavBar(context, index),
      ),
    );
  }

  // Actions - OPTIMISÉES
  void _ouvrirModifierProfil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ModifierProfilEcran(),
      ),
    );
  }

  void _deconnecter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déconnexion'),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Retour à l'écran de connexion
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const ConnexionEcran()),
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Déconnexion réussie'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Se déconnecter', style: TextStyle(color: CouleursApp.blanc)),
          ),
        ],
      ),
    );
  }



  // UI Design: Helper pour créer une statistique
  Widget _construireStatistique(String valeur, String label, IconData icone, Color couleur) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
            color: couleur.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icone, size: 24, color: couleur),
        ),
        const SizedBox(height: 8),
        Text(
          valeur,
                  style: TextStyle(
            fontSize: 20,
                    fontWeight: FontWeight.bold,
            color: couleur,
          ),
        ),
          Text(
          label,
            style: TextStyle(
            fontSize: 11,
            color: CouleursApp.texteFonce.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // UI Design: Section mes livres - FONCTIONNELLE
  Widget _construireSectionLivres(BuildContext context) {
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
              Icon(Icons.menu_book, color: CouleursApp.principal, size: 24),
              const SizedBox(width: 12),
              Text('Mes Livres', style: StylesTexteApp.titre.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _construireInfoLivre('5', 'Disponibles', CouleursApp.accent),
              _construireInfoLivre('2', 'En cours', Colors.orange),
              _construireInfoLivre('12', 'Terminés', Colors.green),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
                              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GererLivresEcran()),
                ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: CouleursApp.accent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Gérer mes livres',
                style: TextStyle(color: CouleursApp.accent, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Helper pour info livre
  Widget _construireInfoLivre(String nombre, String type, Color couleur) {
    return Column(
      children: [
        Text(
          nombre,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: couleur),
        ),
        Text(
          type,
          style: TextStyle(fontSize: 12, color: CouleursApp.texteFonce.withValues(alpha: 0.6)),
        ),
      ],
    );
  }

  // UI Design: Section mes associations - FONCTIONNELLE
  Widget _construireSectionAssociations(BuildContext context) {
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
              Icon(Icons.groups, color: CouleursApp.principal, size: 24),
              const SizedBox(width: 12),
              Text('Mes Associations', style: StylesTexteApp.titre.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          _construireAssociation('AEI', 'Membre actif', Icons.school, CouleursApp.principal),
          const SizedBox(height: 12),
          _construireAssociation('Club Photo', 'Membre', Icons.camera_alt, CouleursApp.accent),
          const SizedBox(height: 12),
          _construireAssociation('AGE', 'Membre', Icons.groups_2, CouleursApp.principal),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => NavigationService.gererNavigationNavBar(context, 3),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: CouleursApp.accent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Explorer les associations',
                style: TextStyle(color: CouleursApp.accent, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Helper pour association
  Widget _construireAssociation(String nom, String statut, IconData icone, Color couleur) {
    return Row(
      children: [
        Icon(icone, color: couleur, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nom,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: CouleursApp.texteFonce),
              ),
              Text(
                statut,
                style: TextStyle(fontSize: 12, color: CouleursApp.texteFonce.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // UI Design: Section actions - BOUTONS PRINCIPAUX
  Widget _construireSectionActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _ouvrirModifierProfil(context),
              style: ElevatedButton.styleFrom(
        backgroundColor: CouleursApp.accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Modifier le profil',
                style: TextStyle(
                  color: CouleursApp.blanc,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _deconnecter(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Se déconnecter',
                style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 