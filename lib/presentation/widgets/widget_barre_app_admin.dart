import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../services/authentification_service.dart';
import '../screens/admin/admin_dashboard_ecran.dart';
import '../screens/admin/admin_gestion_comptes_ecran.dart';
import '../screens/admin/admin_gestion_cantine_ecran.dart';
import '../screens/admin/admin_gestion_associations_ecran.dart';
import '../screens/utilisateur/connexion_ecran.dart';

// UI Design: AppBar spécialisée pour la navigation admin
class WidgetBarreAppAdmin extends StatelessWidget implements PreferredSizeWidget {
  final String titre;
  final String? sousTitre;
  final bool afficherBoutonRetour;
  final List<Widget>? actions;
  final VoidCallback? onRetour;
  final Widget? widgetCentre;

  const WidgetBarreAppAdmin({
    super.key,
    required this.titre,
    this.sousTitre,
    this.afficherBoutonRetour = true,
    this.actions,
    this.onRetour,
    this.widgetCentre,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: CouleursApp.principal,
      foregroundColor: CouleursApp.blanc,
      elevation: 0,
      toolbarHeight: 80,
      leading: afficherBoutonRetour
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onRetour ?? () => Navigator.pop(context),
            )
          : null,
      title: widgetCentre ?? _construireTitre(),
      actions: [
        // Actions par défaut pour navigation rapide
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) => _gererNavigationRapide(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'dashboard',
              child: Row(
                children: [
                  Icon(Icons.dashboard, color: Colors.black54),
                  SizedBox(width: 8),
                  Text('Dashboard'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'comptes',
              child: Row(
                children: [
                  Icon(Icons.people, color: Colors.black54),
                  SizedBox(width: 8),
                  Text('Gestion Comptes'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'cantine',
              child: Row(
                children: [
                  Icon(Icons.restaurant, color: Colors.black54),
                  SizedBox(width: 8),
                  Text('Gestion Cantine'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'actualites',
              child: Row(
                children: [
                  Icon(Icons.article, color: Colors.black54),
                  SizedBox(width: 8),
                  Text('Gestion Actualités'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'divider',
              enabled: false,
              child: Divider(),
            ),
            const PopupMenuItem(
              value: 'deconnexion',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Se déconnecter', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        // Actions personnalisées
        if (actions != null) ...actions!,
        const SizedBox(width: 8),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [CouleursApp.principal, CouleursApp.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _construireTitre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          titre,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (sousTitre != null)
          Text(
            sousTitre!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
      ],
    );
  }

  void _gererNavigationRapide(BuildContext context, String valeur) {
    switch (valeur) {
      case 'dashboard':
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AdminDashboardEcran()),
          (route) => false,
        );
        break;
      case 'comptes':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminGestionComptesEcran()),
        );
        break;
      case 'cantine':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminGestionCantineEcran()),
        );
        break;
      case 'actualites':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminGestionAssociationsEcran()),
        );
        break;
      case 'deconnexion':
        _afficherDialogueDeconnexion(context);
        break;
    }
  }

  void _afficherDialogueDeconnexion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                // UI Design: Déconnexion via le service d'authentification
                final authentificationService = ServiceLocator.obtenirService<AuthentificationService>();
                await authentificationService.deconnecter();
                
                // UI Design: Navigation vers l'écran de connexion avec nettoyage complet des routes
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const ConnexionEcran()),
                    (route) => false,
                  );
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Déconnexion réussie'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text('Erreur lors de la déconnexion: $e'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Se déconnecter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
} 