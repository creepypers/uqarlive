import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/utilisateur.dart';
import '../../widgets/widget_barre_app_navigation_admin.dart';
import '../../widgets/widget_carte.dart';
import '../../services/statistiques_service.dart';
import '../../services/authentification_service.dart';
import 'admin_gestion_comptes_ecran.dart';
import 'admin_gestion_cantine_ecran.dart';
import '../../../presentation/screens/admin/admin_gestion_associations_ecran.dart';
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
  bool _statistiquesVisibles = true; 
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
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      resizeToAvoidBottomInset: true, 
      appBar: WidgetBarreAppNavigationAdmin(
        titre: 'Dashboard Admin',
        sousTitre: _utilisateurActuel != null 
            ? 'Connecté en tant que ${_utilisateurActuel!.prenom} ${_utilisateurActuel!.nom}'
            : 'Vue d\'ensemble du système',
        sectionActive: 'dashboard',
      ),
      body: SafeArea(
        child: _chargementEnCours
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _chargerDonnees,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.04, 
                    right: screenWidth * 0.04,
                    top: screenHeight * 0.02,
                    bottom: viewInsets.bottom + padding.bottom + screenHeight * 0.025, 
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _construireStatistiquesGenerales(),
                      SizedBox(height: screenHeight * 0.025), 
                      _construireStatistiquesDetaillees(),
                      SizedBox(height: screenHeight * 0.025), 
                      _construireSectionsGestion(),
                      SizedBox(height: screenHeight * 0.025), 
                      _construireActiviteRecente(),
                      SizedBox(height: screenHeight * 0.01), 
                    ],
                  ),
                ),
              ),
      ),
    );
  }
  Widget _construireStatistiquesGenerales() {
    if (_statistiquesDashboard == null) return const SizedBox.shrink();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final stats = _statistiquesDashboard!.statistiquesGlobales;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Vue d\'ensemble',
              style: StylesTexteApp.titrePage.copyWith(
                fontSize: screenWidth * 0.055, 
              ),
              overflow: TextOverflow.ellipsis, 
              maxLines: 1,
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _statistiquesVisibles = !_statistiquesVisibles;
                });
              },
              icon: Icon(
                _statistiquesVisibles ? Icons.visibility_off : Icons.visibility,
                color: CouleursApp.principal,
                size: screenWidth * 0.06, 
              ),
              tooltip: _statistiquesVisibles ? 'Masquer les statistiques' : 'Afficher les statistiques',
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02), 
        _statistiquesVisibles
            ? GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: screenWidth * 0.04, 
                crossAxisSpacing: screenWidth * 0.04, 
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
            : 
            Container(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.025), 
                child: Center(
                  child: Text(
                    'Statistiques masquées - Cliquez sur l\'œil pour les afficher',
                    style: StylesTexteApp.corpsGris.copyWith(
                      fontSize: screenWidth * 0.035, 
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis, 
                    maxLines: 2,
                  ),
                ),
              ),
      ],
    );
  }
  Widget _construireCarteStatistique(String titre, String valeur, IconData icone, Color couleur, String detail) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04), 
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
                Icon(icone, color: couleur, size: screenWidth * 0.075), 
                Text(
                  valeur,
                  style: TextStyle(
                    fontSize: screenWidth * 0.06, 
                    fontWeight: FontWeight.bold,
                    color: couleur,
                  ),
                  overflow: TextOverflow.ellipsis, 
                  maxLines: 1,
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01), 
            Text(
              titre,
              style: StylesTexteApp.moyenTitre.copyWith(
                color: CouleursApp.texteFonce,
                fontSize: screenWidth * 0.04, 
              ),
              overflow: TextOverflow.ellipsis, 
              maxLines: 1,
            ),
            SizedBox(height: screenHeight * 0.005), 
            Text(
              detail,
              style: StylesTexteApp.petitGris.copyWith(
                fontSize: screenWidth * 0.03, 
              ),
              overflow: TextOverflow.ellipsis, 
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
  Widget _construireStatistiquesDetaillees() {
    if (_statistiquesDashboard == null) return const SizedBox.shrink();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final stats = _statistiquesDashboard!.statistiquesGlobales;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques détaillées',
          style: StylesTexteApp.titrePage.copyWith(
            fontSize: screenWidth * 0.055, 
          ),
          overflow: TextOverflow.ellipsis, 
          maxLines: 1,
        ),
        SizedBox(height: screenHeight * 0.02), 
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05), 
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
  Widget _construireLigneStatistique(String libelle, String valeur) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded( 
            child: Text(
              libelle, 
              style: StylesTexteApp.corpsNormal.copyWith(
                fontSize: screenWidth * 0.035, 
              ),
              overflow: TextOverflow.ellipsis, 
              maxLines: 1,
            ),
          ),
          Text(
            valeur,
            style: StylesTexteApp.corpsNormal.copyWith(
              fontWeight: FontWeight.bold,
              color: CouleursApp.principal,
              fontSize: screenWidth * 0.035, 
            ),
            overflow: TextOverflow.ellipsis, 
            maxLines: 1,
          ),
        ],
      ),
    );
  }
  Widget _construireSectionsGestion() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestion du système',
          style: StylesTexteApp.titrePage.copyWith(
            fontSize: screenWidth * 0.055, 
          ),
          overflow: TextOverflow.ellipsis, 
          maxLines: 1,
        ),
        SizedBox(height: screenHeight * 0.02), 
        Center(
          child: Wrap(
            spacing: screenWidth * 0.03, 
            runSpacing: screenWidth * 0.03, 
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
                nom: 'Privilèges',
                description: 'Gérer admins & privilèges',
                icone: Icons.admin_panel_settings,
                couleurIcone: Colors.red,
                onTap: () => _afficherGestionComptes(),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _construireActiviteRecente() {
    if (_statistiquesDashboard == null) return const SizedBox.shrink();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activité récente',
          style: StylesTexteApp.titrePage.copyWith(
            fontSize: screenWidth * 0.055, 
          ),
          overflow: TextOverflow.ellipsis, 
          maxLines: 1,
        ),
        SizedBox(height: screenHeight * 0.02), 
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Derniers utilisateurs inscrits',
                  style: StylesTexteApp.moyenTitre.copyWith(
                    fontSize: screenWidth * 0.045, 
                  ),
                  overflow: TextOverflow.ellipsis, 
                  maxLines: 1,
                ),
                SizedBox(height: screenHeight * 0.015), 
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
  Widget _construireCarteUtilisateurCompacte(Utilisateur utilisateur) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.01), 
      padding: EdgeInsets.all(screenWidth * 0.03), 
      decoration: BoxDecoration(
        color: CouleursApp.fond,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: screenWidth * 0.05, 
            backgroundColor: CouleursApp.principal,
            child: Text(
              '${utilisateur.prenom[0]}${utilisateur.nom[0]}',
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.04, 
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.03), 
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${utilisateur.prenom} ${utilisateur.nom}',
                  style: StylesTexteApp.corpsNormal.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.04, 
                  ),
                  overflow: TextOverflow.ellipsis, 
                  maxLines: 1,
                ),
                Text(
                  utilisateur.email,
                  style: StylesTexteApp.petitGris.copyWith(
                    fontSize: screenWidth * 0.035, 
                  ),
                  overflow: TextOverflow.ellipsis, 
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02, 
              vertical: screenWidth * 0.01,
            ),
            decoration: BoxDecoration(
              color: CouleursApp.principal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _obtenirLibelleTypeUtilisateur(utilisateur.typeUtilisateur),
              style: TextStyle(
                color: CouleursApp.principal,
                fontSize: screenWidth * 0.03, 
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis, 
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
  Widget _construireMessageVide() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05), 
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: screenWidth * 0.15, 
              color: CouleursApp.principal.withValues(alpha: 0.3),
            ),
            SizedBox(height: screenHeight * 0.015), 
            Text(
              'Aucune activité récente',
              style: StylesTexteApp.corpsGris.copyWith(
                fontSize: screenWidth * 0.04, 
              ),
              overflow: TextOverflow.ellipsis, 
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
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
  String _obtenirLibelleTypeUtilisateur(TypeUtilisateur type) {
    switch (type) {
      case TypeUtilisateur.administrateur: return 'Administrateur';
      case TypeUtilisateur.etudiant: return 'Étudiant';
    }
  }
  void _afficherGestionComptes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminGestionComptesEcran()),
    );
  }
}