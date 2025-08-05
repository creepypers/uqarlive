// UI Design: Écran principal du dashboard administrateur avec statistiques dynamiques
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/utilisateur.dart';
import '../widgets/widget_barre_app_navigation_admin.dart';
import '../widgets/widget_carte.dart';

import '../services/statistiques_service.dart';
import 'admin_gestion_comptes_ecran.dart';
import 'admin_gestion_cantine_ecran.dart';
import 'admin_gestion_associations_ecran.dart';

class AdminDashboardEcran extends StatefulWidget {
  const AdminDashboardEcran({super.key});

  @override
  State<AdminDashboardEcran> createState() => _AdminDashboardEcranState();
}

class _AdminDashboardEcranState extends State<AdminDashboardEcran> {
  late StatistiquesService _statistiquesService;
  StatistiquesDashboard? _statistiquesDashboard;
  bool _chargementEnCours = true;
  bool _statistiquesVisibles = true; // UI Design: Contrôle visibilité des statistiques

  @override
  void initState() {
    super.initState();
    _statistiquesService = ServiceLocator.obtenirService<StatistiquesService>();
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
        sousTitre: 'Vue d\'ensemble du système',
        sectionActive: 'dashboard',
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
            Text(
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
                child: Center(
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
        Text(
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
        Text(
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
        Text(
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
                Text(
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
              style: TextStyle(
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
            Text(
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

  // UI Design: Méthode utilitaire pour les libellés des types d'utilisateur
  String _obtenirLibelleTypeUtilisateur(TypeUtilisateur type) {
    switch (type) {
      case TypeUtilisateur.administrateur: return 'Administrateur';
      case TypeUtilisateur.etudiant: return 'Étudiant';
    }
  }
}

 