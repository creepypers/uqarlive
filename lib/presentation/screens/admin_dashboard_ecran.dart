// UI Design: Écran principal du dashboard administrateur avec statistiques dynamiques
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/utilisateur.dart';
import '../widgets/widget_barre_app_navigation_admin.dart';
import '../widgets/widget_carte.dart';

import '../services/statistiques_service.dart';
import '../services/authentification_service.dart';
import 'admin_gestion_comptes_ecran.dart';
import 'admin_gestion_cantine_ecran.dart';
import 'admin_gestion_associations_ecran.dart';
import 'connexion_ecran.dart';

class AdminDashboardEcran extends StatefulWidget {
  const AdminDashboardEcran({super.key});

  @override
  State<AdminDashboardEcran> createState() => _AdminDashboardEcranState();
}

class _AdminDashboardEcranState extends State<AdminDashboardEcran> {
  late StatistiquesService _statistiquesService;
  late AuthentificationService _authentificationService;
  StatistiquesDashboard? _statistiquesDashboard;
  Utilisateur? _utilisateurActuel;
  bool _chargementEnCours = true;
  bool _statistiquesVisibles = true; // UI Design: Contrôle visibilité des statistiques

  @override
  void initState() {
    super.initState();
    _statistiquesService = ServiceLocator.obtenirService<StatistiquesService>();
    _authentificationService = ServiceLocator.obtenirService<AuthentificationService>();
    _utilisateurActuel = _authentificationService.utilisateurActuel;
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    try {
      setState(() => _chargementEnCours = true);
      
      final statistiquesDashboard = await _statistiquesService.obtenirStatistiquesDashboard();
      
      setState(() {
        _statistiquesDashboard = statistiquesDashboard;
        _chargementEnCours = false;
      });
    } catch (e) {
      setState(() => _chargementEnCours = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: WidgetBarreAppNavigationAdmin(
        titre: 'Dashboard Admin',
        sousTitre: _utilisateurActuel != null 
            ? 'Connecté en tant que ${_utilisateurActuel!.prenom} ${_utilisateurActuel!.nom}'
            : 'Vue d\'ensemble du système',
        sectionActive: 'dashboard',
        // UI Design: Actions admin supplémentaires
        actions: [
          PopupMenuButton<String>(
            onSelected: (action) => _gererActionAdmin(action),
            icon: const Icon(Icons.more_vert, color: CouleursApp.blanc),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profil',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Mon Profil'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'privileges',
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Gérer mes privilèges'),
                  ],
                ),
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
        ],
      ),
      body: _chargementEnCours
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _chargerDonnees,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _construireStatistiquesGenerales(),
                    const SizedBox(height: 20),
                    _construireStatistiquesDetaillees(),
                    const SizedBox(height: 20),
                    _construireSectionsGestion(),
                    const SizedBox(height: 20),
                    _construireActiviteRecente(),
                    const SizedBox(height: 8), // UI Design: Padding final pour éviter overflow
                  ],
                ),
              ),
            ),
    );
  }

  // UI Design: Statistiques générales en cartes
  Widget _construireStatistiquesGenerales() {
    if (_statistiquesDashboard == null) return const SizedBox.shrink();
    
    final stats = _statistiquesDashboard!.statistiquesGlobales;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Vue d\'ensemble',
              style: StylesTexteApp.titrePage,
            ),
            // UI Design: Bouton pour masquer/afficher les statistiques
            IconButton(
              onPressed: () {
                setState(() {
                  _statistiquesVisibles = !_statistiquesVisibles;
                });
              },
              icon: Icon(
                _statistiquesVisibles ? Icons.visibility_off : Icons.visibility,
                color: CouleursApp.principal,
              ),
              tooltip: _statistiquesVisibles ? 'Masquer les statistiques' : 'Afficher les statistiques',
            ),
          ],
        ),
        const SizedBox(height: 16),
        // UI Design: Affichage conditionnel des statistiques
        _statistiquesVisibles
            ? GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _construireCarteStatistique(
                    'Utilisateurs',
                    stats.totalUtilisateurs.toString(),
                    Icons.people,
                    CouleursApp.principal,
                    '+${_statistiquesDashboard!.nouvellesInscriptionsHebdo} cette semaine',
                  ),
                  _construireCarteStatistique(
                    'Associations',
                    stats.totalAssociations.toString(),
                    Icons.groups,
                    Colors.orange,
                    '${stats.associationsActives} actives',
                  ),
                  _construireCarteStatistique(
                    'Événements',
                    stats.totalEvenements.toString(),
                    Icons.event,
                    Colors.green,
                    '${stats.evenementsAVenir} à venir',
                  ),
                  _construireCarteStatistique(
                    'Actualités',
                    stats.totalActualites.toString(),
                    Icons.newspaper,
                    CouleursApp.accent,
                    '${stats.actualitesEpinglees} épinglées',
                  ),
                ],
              )
            : // UI Design: Message quand les statistiques sont masquées
            Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: const Center(
                  child: Text(
                    'Statistiques masquées - Cliquez sur l\'œil pour les afficher',
                    style: StylesTexteApp.corpsGris,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
      ],
    );
  }

  // UI Design: Carte de statistique individuelle
  Widget _construireCarteStatistique(String titre, String valeur, IconData icone, Color couleur, String detail) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              couleur.withValues(alpha: 0.1),
              couleur.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icone, color: couleur, size: 30),
                Text(
                  valeur,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: couleur,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              titre,
              style: StylesTexteApp.moyenTitre.copyWith(
                color: CouleursApp.texteFonce,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              detail,
              style: StylesTexteApp.petitGris,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // UI Design: Statistiques détaillées en section
  Widget _construireStatistiquesDetaillees() {
    if (_statistiquesDashboard == null) return const SizedBox.shrink();
    
    final stats = _statistiquesDashboard!.statistiquesGlobales;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistiques détaillées',
          style: StylesTexteApp.titrePage,
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _construireLigneStatistique('Livres disponibles', '${stats.livresDisponibles}/${stats.totalLivres}'),
                const Divider(),
                _construireLigneStatistique('Salles occupées', '${stats.sallesOccupees}/${stats.totalSalles}'),
                const Divider(),
                _construireLigneStatistique('Menus du jour', '${stats.menusJour}/${stats.totalMenus}'),
                const Divider(),
                _construireLigneStatistique('Taux d\'activité', '${(_statistiquesDashboard!.tauxActiviteUtilisateurs * 100).toStringAsFixed(1)}%'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // UI Design: Ligne de statistique individuelle
  Widget _construireLigneStatistique(String libelle, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(libelle, style: StylesTexteApp.corpsNormal),
          Text(
            valeur,
            style: StylesTexteApp.corpsNormal.copyWith(
              fontWeight: FontWeight.bold,
              color: CouleursApp.principal,
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Sections de gestion avec navigation
  Widget _construireSectionsGestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gestion du système',
          style: StylesTexteApp.titrePage,
        ),
        const SizedBox(height: 16),
        // UI Design: Utilisation du composant WidgetCarte existant pour éviter l'overflow
        Center(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
            WidgetCarte.association(
              nom: 'Comptes',
              description: 'Gérer les utilisateurs',
              icone: Icons.people,
              couleurIcone: CouleursApp.principal,
              onTap: () => _naviguerVersGestionComptes(),
            ),
            WidgetCarte.association(
              nom: 'Cantine',
              description: 'Gérer les menus',
              icone: Icons.restaurant,
              couleurIcone: Colors.green,
              onTap: () => _naviguerVersGestionCantine(),
            ),
            WidgetCarte.association(
              nom: 'Associations',
              description: 'Gérer associations & événements',
              icone: Icons.groups,
              couleurIcone: Colors.orange,
              onTap: () => _naviguerVersGestionAssociations(),
            ),
            WidgetCarte.association(
              nom: 'Modération',
              description: 'Contenu & Signalements',
              icone: Icons.gavel,
              couleurIcone: Colors.red,
              onTap: () => _afficherMessageDeveloppement(),
            ),
          ],
        ),
        ),
      ],
    );
  }

  // UI Design: Carte de gestion individuelle
  Widget _construireCarteGestion(String titre, String description, IconData icone, Color couleur, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icone, color: couleur, size: 28),
              const SizedBox(height: 8),
              Text(
                titre,
                style: StylesTexteApp.moyenTitre.copyWith(color: couleur),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: StylesTexteApp.petitGris,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UI Design: Section d'activité récente
  Widget _construireActiviteRecente() {
    if (_statistiquesDashboard == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activité récente',
          style: StylesTexteApp.titrePage,
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Derniers utilisateurs inscrits',
                  style: StylesTexteApp.moyenTitre,
                ),
                const SizedBox(height: 12),
                _statistiquesDashboard!.derniersUtilisateurs.isEmpty
                    ? _construireMessageVide()
                    : Column(
                        children: _statistiquesDashboard!.derniersUtilisateurs.take(3).map((utilisateurData) {
                          final utilisateur = utilisateurData as Utilisateur;
                          return _construireCarteUtilisateurCompacte(utilisateur);
                        }).toList(),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // UI Design: Carte utilisateur compacte
  Widget _construireCarteUtilisateurCompacte(Utilisateur utilisateur) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CouleursApp.fond,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: CouleursApp.principal,
            child: Text(
              '${utilisateur.prenom[0]}${utilisateur.nom[0]}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${utilisateur.prenom} ${utilisateur.nom}',
                  style: StylesTexteApp.corpsNormal.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  utilisateur.email,
                  style: StylesTexteApp.petitGris,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: CouleursApp.principal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _obtenirLibelleTypeUtilisateur(utilisateur.typeUtilisateur),
              style: const TextStyle(
                color: CouleursApp.principal,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Message vide
  Widget _construireMessageVide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 60,
              color: CouleursApp.principal.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            const Text(
              'Aucune activité récente',
              style: StylesTexteApp.corpsGris,
            ),
          ],
        ),
      ),
    );
  }

  // UI Design: Méthodes de navigation
  void _naviguerVersGestionComptes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminGestionComptesEcran()),
    );
  }

  void _naviguerVersGestionCantine() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminGestionCantineEcran()),
    );
  }

  void _naviguerVersGestionAssociations() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminGestionAssociationsEcran()),
    );
  }

  void _afficherMessageDeveloppement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité en cours de développement'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // UI Design: Gestionnaire d'actions admin
  void _gererActionAdmin(String action) {
    switch (action) {
      case 'profil':
        _afficherProfilAdmin();
        break;
      case 'privileges':
        _afficherGestionPrivileges();
        break;
      case 'deconnexion':
        _confirmerDeconnexion();
        break;
    }
  }

  // UI Design: Afficher le profil de l'admin connecté
  void _afficherProfilAdmin() {
    if (_utilisateurActuel == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: CouleursApp.principal,
              child: Text(
                '${_utilisateurActuel!.prenom[0]}${_utilisateurActuel!.nom[0]}',
                style: const TextStyle(color: CouleursApp.blanc, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_utilisateurActuel!.prenom} ${_utilisateurActuel!.nom}'),
                  Text(
                    'Administrateur',
                    style: StylesTexteApp.petitGris.copyWith(color: Colors.orange),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _construireInfoProfil('Email', _utilisateurActuel!.email),
            _construireInfoProfil('Code Étudiant', _utilisateurActuel!.codeEtudiant),
            _construireInfoProfil('Programme', _utilisateurActuel!.programme),
            _construireInfoProfil('Privilèges', '${_utilisateurActuel!.privileges.length} privilège(s)'),
            _construireInfoProfil('Dernière connexion', 
              _utilisateurActuel!.derniereConnexion != null 
                ? _formatDate(_utilisateurActuel!.derniereConnexion!)
                : 'Jamais'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _construireInfoProfil(String label, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: StylesTexteApp.corpsNormal.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              valeur,
              style: StylesTexteApp.corpsNormal,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // UI Design: Afficher la gestion des privilèges
  void _afficherGestionPrivileges() {
    if (_utilisateurActuel == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.orange),
            SizedBox(width: 8),
            Text('Mes Privilèges'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Privilèges attribués à votre compte:',
                style: StylesTexteApp.corpsNormal.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ...[
                {'code': PrivilegesUtilisateur.gestionComptes, 'nom': 'Gestion des comptes'},
                {'code': PrivilegesUtilisateur.gestionCantine, 'nom': 'Gestion de la cantine'},
                {'code': PrivilegesUtilisateur.gestionActualites, 'nom': 'Gestion des actualités'},
                {'code': PrivilegesUtilisateur.gestionAssociations, 'nom': 'Gestion des associations'},
                {'code': PrivilegesUtilisateur.gestionSalles, 'nom': 'Gestion des salles'},
                {'code': PrivilegesUtilisateur.gestionLivres, 'nom': 'Gestion des livres'},
                {'code': PrivilegesUtilisateur.moderationContenu, 'nom': 'Modération du contenu'},
                {'code': PrivilegesUtilisateur.statistiques, 'nom': 'Accès aux statistiques'},
              ].map((privilege) => Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _utilisateurActuel!.privileges.contains(privilege['code'])
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _utilisateurActuel!.privileges.contains(privilege['code'])
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _utilisateurActuel!.privileges.contains(privilege['code']!)
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: _utilisateurActuel!.privileges.contains(privilege['code']!)
                          ? Colors.green
                          : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        privilege['nom']!,
                        style: StylesTexteApp.corpsNormal,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // UI Design: Confirmer la déconnexion
  void _confirmerDeconnexion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Déconnexion'),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter de votre session administrateur ?',
          style: StylesTexteApp.corpsNormal,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authentificationService.deconnecter();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const ConnexionEcran()),
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Déconnexion réussie'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Se déconnecter', style: TextStyle(color: CouleursApp.blanc)),
          ),
        ],
      ),
    );
  }

  // UI Design: Méthode utilitaire pour les libellés des types d'utilisateur
  String _obtenirLibelleTypeUtilisateur(TypeUtilisateur type) {
    switch (type) {
      case TypeUtilisateur.administrateur: return 'Administrateur';
      case TypeUtilisateur.etudiant: return 'Étudiant';
    }
  }
}

 