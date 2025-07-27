import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../screens/admin_dashboard_ecran.dart';
import '../screens/admin_gestion_comptes_ecran.dart';
import '../screens/admin_gestion_cantine_ecran.dart';
import '../screens/admin_gestion_actualites_ecran.dart';
import '../screens/admin_ajouter_menu_ecran.dart';
import '../screens/admin_modifier_horaires_ecran.dart';
import '../screens/associations_ecran.dart';

// UI Design: AppBar de navigation entre les différentes sections de gestion admin
class WidgetBarreAppNavigationAdmin extends StatelessWidget implements PreferredSizeWidget {
  final String titre;
  final String? sousTitre;
  final String sectionActive; // 'dashboard', 'comptes', 'cantine', 'actualites'
  final List<Widget>? actions;
  final bool afficherBoutonRetour;

  const WidgetBarreAppNavigationAdmin({
    super.key,
    required this.titre,
    this.sousTitre,
    required this.sectionActive,
    this.actions,
    this.afficherBoutonRetour = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: CouleursApp.principal,
      foregroundColor: CouleursApp.blanc,
      elevation: 0,
      toolbarHeight: 120, // Plus de hauteur pour les onglets
      leading: afficherBoutonRetour
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminDashboardEcran()),
                  );
                }
              },
            )
          : null,
      title: _construireTitre(),
      actions: [
        // Bouton retour dashboard
        IconButton(
          icon: const Icon(Icons.dashboard, color: Colors.white),
          onPressed: () => _naviguerVersDashboard(context),
          tooltip: 'Dashboard',
        ),
        // Menu options modernisé
        PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
          ),
          onSelected: (value) => _gererAction(context, value),
          itemBuilder: (context) => [
            // Section Actions Rapides
            const PopupMenuItem(
              value: 'ajouter_menu',
              child: Row(
                children: [
                  Icon(Icons.add_circle, color: Colors.green),
                  SizedBox(width: 12),
                  Text('Ajouter Menu', style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'modifier_horaire',
              child: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.blue),
                  SizedBox(width: 12),
                  Text('Modifier Horaires', style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'ajouter_actualite',
              child: Row(
                children: [
                  Icon(Icons.article, color: Colors.orange),
                  SizedBox(width: 12),
                  Text('Ajouter Actualité', style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'nouvelle_association',
              child: Row(
                children: [
                  Icon(Icons.group_add, color: Colors.purple),
                  SizedBox(width: 12),
                  Text('Nouvelle Association', style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'modifier_association',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.indigo),
                  SizedBox(width: 12),
                  Text('Modifier Association', style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'divider1',
              enabled: false,
              child: Divider(height: 1),
            ),
            // Section Actions Générales
            const PopupMenuItem(
              value: 'actualiser',
              child: Row(
                children: [
                  Icon(Icons.refresh, color: Colors.teal),
                  SizedBox(width: 12),
                  Text('Actualiser', style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'parametres',
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.grey),
                  SizedBox(width: 12),
                  Text('Paramètres', style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'divider2',
              enabled: false,
              child: Divider(height: 1),
            ),
            const PopupMenuItem(
              value: 'deconnexion',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Se déconnecter', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
        if (actions != null) ...actions!,
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: _construireOnglets(context),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [CouleursApp.principal, CouleursApp.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
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

  Widget _construireOnglets(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _construireOnglet(
            context,
            'Dashboard',
            Icons.dashboard,
            'dashboard',
            () => _naviguerVersDashboard(context),
          ),
          _construireOnglet(
            context,
            'Comptes',
            Icons.people,
            'comptes',
            () => _naviguerVersComptes(context),
          ),
          _construireOnglet(
            context,
            'Cantine',
            Icons.restaurant,
            'cantine',
            () => _naviguerVersCantine(context),
          ),
          _construireOnglet(
            context,
            'Assos',
            Icons.groups,
            'actualites',
            () => _naviguerVersActualites(context),
          ),
        ],
      ),
    );
  }

  Widget _construireOnglet(
    BuildContext context,
    String label,
    IconData icone,
    String section,
    VoidCallback onTap,
  ) {
    final estActif = section == sectionActive;
    
    return Expanded(
      child: GestureDetector(
        onTap: estActif ? null : onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: estActif 
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icone,
                color: estActif 
                  ? Colors.white 
                  : Colors.white.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: estActif 
                    ? Colors.white 
                    : Colors.white.withValues(alpha: 0.7),
                  fontWeight: estActif ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _naviguerVersDashboard(BuildContext context) {
    if (sectionActive != 'dashboard') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardEcran()),
      );
    }
  }

  void _naviguerVersComptes(BuildContext context) {
    if (sectionActive != 'comptes') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminGestionComptesEcran()),
      );
    }
  }

  void _naviguerVersCantine(BuildContext context) {
    if (sectionActive != 'cantine') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminGestionCantineEcran()),
      );
    }
  }

  void _naviguerVersActualites(BuildContext context) {
    if (sectionActive != 'actualites') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminGestionActualitesEcran()),
      );
    }
  }

  void _gererAction(BuildContext context, String valeur) {
    switch (valeur) {
      case 'ajouter_menu':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminAjouterMenuEcran(),
          ),
        );
        break;
      case 'modifier_horaire':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminModifierHorairesEcran(),
          ),
        );
        break;
      case 'ajouter_actualite':
        _afficherModalAjouterActualite(context);
        break;
      case 'nouvelle_association':
        _afficherModalNouvelleAssociation(context);
        break;
      case 'modifier_association':
        _afficherModalModifierAssociation(context);
        break;
      case 'actualiser':
        // Déclencher un rafraîchissement de la page courante
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.refresh, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Page actualisée'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        break;
      case 'parametres':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paramètres - fonctionnalité en développement'),
            backgroundColor: Colors.orange,
          ),
        );
        break;
      case 'deconnexion':
        _afficherDialogueDeconnexion(context);
        break;
    }
  }



  void _afficherModalAjouterActualite(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.article, color: Colors.orange),
            SizedBox(width: 8),
            Text('Ajouter une Actualité', style: StylesTexteApp.moyenTitre),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Fonctionnalité en développement',
                style: StylesTexteApp.corpsNormal,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Interface d\'ajout d\'actualités avec titre, contenu et épinglage',
                        style: StylesTexteApp.corpsGris,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _afficherModalNouvelleAssociation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.group_add, color: Colors.purple),
            SizedBox(width: 8),
            Text('Nouvelle Association', style: StylesTexteApp.moyenTitre),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Fonctionnalité en développement',
                style: StylesTexteApp.corpsNormal,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.purple),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Interface de création d\'association avec description et contact',
                        style: StylesTexteApp.corpsGris,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _afficherModalModifierAssociation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Modifier Association', style: StylesTexteApp.moyenTitre),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Fonctionnalité en développement',
                style: StylesTexteApp.corpsNormal,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.indigo),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Interface de modification des informations d\'association',
                        style: StylesTexteApp.corpsGris,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
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
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/connexion',
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
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Se déconnecter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(168); // 120 + 48 pour les onglets
} 