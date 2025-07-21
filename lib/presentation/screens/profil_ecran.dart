import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import '../widgets/widget_section_statistiques.dart';
import '../services/navigation_service.dart';

// UI Design: Page profil utilisateur avec informations personnelles et statistiques
class ProfilEcran extends StatelessWidget {
  const ProfilEcran({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: _construireAppBarProfil(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Section statistiques
              _construireSectionStatistiques(),
              const SizedBox(height: 24),
              
              // Section mes livres
              _construireSectionMesLivres(),
              const SizedBox(height: 24),
              
              // Section mes associations
              _construireSectionMesAssociations(context),
              const SizedBox(height: 24),
              
              // Section préférences
              _construireSectionPreferences(),
              const SizedBox(height: 24),
              
              // Section actions
              _construireSectionActions(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      // Plus de navbar - profil accessible uniquement via AppBar
    );
  }

  // UI Design: AppBar personnalisée avec profil intégré
  PreferredSizeWidget _construireAppBarProfil(BuildContext context) {
    return AppBar(
      backgroundColor: CouleursApp.principal,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 140,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CouleursApp.principal,
            CouleursApp.accent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
        children: [
          // Photo de profil
          Container(
                  width: 80,
                  height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CouleursApp.blanc.withValues(alpha: 0.2),
              border: Border.all(
                color: CouleursApp.blanc,
                width: 3,
              ),
            ),
            child: Icon(
              Icons.person,
                    size: 40,
              color: CouleursApp.blanc,
            ),
          ),
                const SizedBox(width: 16),
          
                // Informations profil
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
          // Nom complet
          Text(
            'Marie Dubois',
            style: TextStyle(
                          fontSize: 22,
              fontWeight: FontWeight.bold,
              color: CouleursApp.blanc,
            ),
          ),
          const SizedBox(height: 4),
          
          // Code permanent
          Text(
            'DUBM12345678',
            style: TextStyle(
                          fontSize: 14,
              color: CouleursApp.blanc.withValues(alpha: 0.9),
            ),
          ),
                      const SizedBox(height: 6),
          
          // Email
          Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: CouleursApp.blanc.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'marie.dubois@uqar.ca',
              style: TextStyle(
                            fontSize: 12,
                color: CouleursApp.blanc,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
                  ),
                ),
                
                // Boutons
                Row(
                  children: [
                    // Bouton retour
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: CouleursApp.blanc, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    // Bouton paramètres
                    IconButton(
                      icon: Icon(Icons.settings, color: CouleursApp.blanc, size: 28),
                      onPressed: () => _ouvrirParametres(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  // UI Design: Section statistiques personnelles
  Widget _construireSectionStatistiques() {
    return WidgetSectionStatistiques.marketplace(
      statistiques: [
        ElementStatistique(
          valeur: '12',
          label: 'Livres\néchangés',
          icone: Icons.swap_horiz,
          couleurIcone: CouleursApp.principal,
        ),
        ElementStatistique(
          valeur: '3',
          label: 'Associations\nrejointes',
          icone: Icons.groups,
          couleurIcone: CouleursApp.accent,
        ),
        ElementStatistique(
          valeur: '8',
          label: 'Mois\nà l\'UQAR',
          icone: Icons.school,
          couleurIcone: CouleursApp.principal,
        ),
      ],
    );
  }

  // UI Design: Section mes livres
  Widget _construireSectionMesLivres() {
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
                Icons.menu_book,
                color: CouleursApp.principal,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Mes Livres',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
              Spacer(),
              TextButton(
                onPressed: () => _gererMesLivres(),
                child: Text(
                  'Gérer',
                  style: TextStyle(color: CouleursApp.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _construireItemLigne(
            Icons.book_outlined,
            'Livres disponibles',
            '5 livres',
            CouleursApp.principal,
          ),
          const SizedBox(height: 12),
          _construireItemLigne(
            Icons.pending,
            'Échanges en cours',
            '2 demandes',
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _construireItemLigne(
            Icons.check_circle,
            'Échanges terminés',
            '12 échanges',
            Colors.green,
          ),
        ],
      ),
    );
  }

  // UI Design: Section mes associations
  Widget _construireSectionMesAssociations(BuildContext context) {
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
                Icons.groups,
                color: CouleursApp.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Mes Associations',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
              Spacer(),
              TextButton(
                onPressed: () => NavigationService.gererNavigationNavBar(context, 3),
                child: Text(
                  'Explorer',
                  style: TextStyle(color: CouleursApp.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _construireItemLigne(
            Icons.sports_soccer,
            'Association Étudiante en Informatique',
            'Membre actif',
            CouleursApp.principal,
          ),
          const SizedBox(height: 12),
          _construireItemLigne(
            Icons.palette,
            'Club Photo UQAR',
            'Membre',
            Colors.purple,
          ),
          const SizedBox(height: 12),
          _construireItemLigne(
            Icons.school,
            'Association Générale Étudiante',
            'Membre',
            CouleursApp.accent,
          ),
        ],
      ),
    );
  }

  // UI Design: Section préférences
  Widget _construireSectionPreferences() {
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
                Icons.tune,
                color: CouleursApp.principal,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Préférences',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _construireItemPreference(
            Icons.notifications,
            'Notifications',
            'Activer les notifications d\'échange',
            true,
            (value) => _basculerNotifications(value),
          ),
          const SizedBox(height: 12),
          _construireItemPreference(
            Icons.dark_mode,
            'Mode sombre',
            'Activer le thème sombre',
            false,
            (value) => _basculerModeSombre(value),
          ),
          const SizedBox(height: 12),
          _construireItemPreference(
            Icons.location_on,
            'Localisation',
            'Afficher ma localisation aux autres',
            true,
            (value) => _basculerLocalisation(value),
          ),
        ],
      ),
    );
  }

  // UI Design: Section actions
  Widget _construireSectionActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Bouton modifier profil
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _modifierProfil(),
              style: ElevatedButton.styleFrom(
                backgroundColor: CouleursApp.accent,
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
                  Icon(Icons.edit, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Modifier le profil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Bouton déconnexion
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _deconnecter(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Se déconnecter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Construire une ligne d'information
  Widget _construireItemLigne(IconData icone, String titre, String valeur, Color couleur) {
    return Row(
      children: [
        Icon(
          icone,
          color: couleur,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titre,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: CouleursApp.texteFonce,
                ),
              ),
              Text(
                valeur,
                style: TextStyle(
                  fontSize: 12,
                  color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right,
          color: CouleursApp.texteFonce.withValues(alpha: 0.4),
          size: 20,
        ),
      ],
    );
  }

  // Helper: Construire un item de préférence avec switch
  Widget _construireItemPreference(
    IconData icone,
    String titre,
    String description,
    bool valeur,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Icon(
          icone,
          color: CouleursApp.principal,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titre,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: CouleursApp.texteFonce,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: valeur,
          onChanged: onChanged,
          activeColor: CouleursApp.accent,
        ),
      ],
    );
  }

  // Actions
  void _ouvrirParametres(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paramètres - À venir'),
        backgroundColor: CouleursApp.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _gererMesLivres() {
    print('Gérer mes livres');
    // TODO: Ouvrir la page de gestion des livres
  }

  void _modifierProfil() {
    print('Modifier le profil');
    // TODO: Ouvrir la page de modification du profil
  }

  void _deconnecter() {
    print('Déconnexion');
    // TODO: Implémenter la déconnexion
  }

  void _basculerNotifications(bool value) {
    print('Notifications: $value');
    // TODO: Gérer les notifications
  }

  void _basculerModeSombre(bool value) {
    print('Mode sombre: $value');
    // TODO: Gérer le mode sombre
  }

  void _basculerLocalisation(bool value) {
    print('Localisation: $value');
    // TODO: Gérer la localisation
  }
} 