// UI Design: Écran principal du dashboard administrateur
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/utilisateur.dart';
import '../../domain/repositories/utilisateurs_repository.dart';
import '../widgets/widget_barre_app_personnalisee.dart';

import '../widgets/widget_section_statistiques.dart';
import '../widgets/widget_collection.dart';
import 'admin_gestion_comptes_ecran.dart';
import 'admin_gestion_cantine_ecran.dart';
import 'admin_gestion_actualites_ecran.dart';

class AdminDashboardEcran extends StatefulWidget {
  const AdminDashboardEcran({super.key});

  @override
  State<AdminDashboardEcran> createState() => _AdminDashboardEcranState();
}

class _AdminDashboardEcranState extends State<AdminDashboardEcran> {
  late UtilisateursRepository _utilisateursRepository;
  Map<String, int> _statistiques = {};
  List<Utilisateur> _utilisateursRecents = [];
  bool _chargementEnCours = true;

  @override
  void initState() {
    super.initState();
    _utilisateursRepository = ServiceLocator.obtenirService<UtilisateursRepository>();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    try {
      setState(() => _chargementEnCours = true);
      
      final statistiques = await _utilisateursRepository.obtenirStatistiquesUtilisateurs();
      final utilisateursRecents = await _utilisateursRepository.obtenirUtilisateursRecents(5);
      
      setState(() {
        _statistiques = statistiques;
        _utilisateursRecents = utilisateursRecents;
        _chargementEnCours = false;
      });
    } catch (e) {
      setState(() => _chargementEnCours = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des données: $e'),
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
      appBar: WidgetBarreAppPersonnalisee(
        titre: 'Dashboard Admin',
        sousTitre: 'Gestion de l\'application UqarLive',
        afficherBoutonRetour: true,
      ),
      body: _chargementEnCours 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _construireStatistiquesGenerales(),
                const SizedBox(height: 24),
                _construireSectionsGestion(),
                const SizedBox(height: 24),
                _construireUtilisateursRecents(),
                const SizedBox(height: 24),
                _construireActionsRapides(),
              ],
            ),
          ),
    );
  }

  // UI Design: Section des statistiques générales avec widget réutilisable
  Widget _construireStatistiquesGenerales() {
    return WidgetSectionStatistiques.associations(
      titre: 'Statistiques Générales',
      statistiques: [
        ElementStatistique(
          valeur: _statistiques['total']?.toString() ?? '0',
          label: 'Utilisateurs Total',
          icone: Icons.people,
          couleurIcone: CouleursApp.blanc,
        ),
        ElementStatistique(
          valeur: _statistiques['actifs']?.toString() ?? '0',
          label: 'Comptes Actifs',
          icone: Icons.verified_user,
          couleurIcone: CouleursApp.blanc,
        ),
        ElementStatistique(
          valeur: _statistiques['administrateurs']?.toString() ?? '0',
          label: 'Administrateurs',
          icone: Icons.admin_panel_settings,
          couleurIcone: CouleursApp.blanc,
        ),
        ElementStatistique(
          valeur: _statistiques['inactifs']?.toString() ?? '0',
          label: 'Comptes Suspendus',
          icone: Icons.block,
          couleurIcone: CouleursApp.blanc,
        ),
      ],
    );
  }

  // UI Design: Sections de gestion principales
  Widget _construireSectionsGestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                    Text(
              'Gestion',
              style: StylesTexteApp.titrePage,
            ),
        const SizedBox(height: 16),
        WidgetCollection.grille(
          elements: [
            _CarteGestionData(
              'Gestion des Comptes',
              'Gérer les utilisateurs et leurs privilèges',
              Icons.account_circle,
              CouleursApp.principal,
              () => _naviguerVersGestionComptes(),
            ),
            _CarteGestionData(
              'Gestion Cantine',
              'Gérer les menus et horaires',
              Icons.restaurant,
              CouleursApp.accent,
              () => _naviguerVersGestionCantine(),
            ),
            _CarteGestionData(
              'Actualités & Assos',
              'Gérer les actualités et événements',
              Icons.newspaper,
              Colors.orange,
              () => _naviguerVersGestionActualites(),
            ),
            _CarteGestionData(
              'Modération',
              'Modérer le contenu de l\'app',
              Icons.gavel,
              Colors.red,
              () => _afficherMessageModeration(),
            ),
          ],
          constructeurElement: (context, data, index) => _construireCarteGestion(
            data.titre,
            data.description,
            data.icone,
            data.couleur,
            data.onTap,
          ),
          nombreColonnes: 2,
          espacementColonnes: 16,
          espacementLignes: 16,
          ratioAspect: 1.1,
        ),
      ],
    );
  }

  Widget _construireCarteGestion(
    String titre,
    String description,
    IconData icone,
    Color couleur,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [couleur.withValues(alpha: 0.1), couleur.withValues(alpha: 0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: couleur.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icone,
                  size: 32,
                  color: couleur,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                titre,
                style: StylesTexteApp.moyenTitre.copyWith(
                  color: couleur,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: StylesTexteApp.corpsGris,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UI Design: Liste des utilisateurs récents
  Widget _construireUtilisateursRecents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nouveaux Utilisateurs',
              style: StylesTexteApp.grandTitre,
            ),
            TextButton(
              onPressed: _naviguerVersGestionComptes,
              child: Text(
                'Voir tout',
                style: StylesTexteApp.lienPrincipal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        WidgetCollection.listeVerticale(
          elements: _utilisateursRecents,
          constructeurElement: (context, utilisateur, index) => _construireCarteUtilisateur(utilisateur),
          espacementVertical: 8,
          messageEtatVide: 'Aucun nouvel utilisateur récemment',
          iconeEtatVide: Icons.people_outline,
        ),
      ],
    );
  }

  Widget _construireCarteUtilisateur(Utilisateur utilisateur) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: utilisateur.estActif ? CouleursApp.principal : Colors.grey,
          child: Text(
            '${utilisateur.prenom[0]}${utilisateur.nom[0]}',
            style: StylesTexteApp.moyenBlanc.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          '${utilisateur.prenom} ${utilisateur.nom}',
          style: StylesTexteApp.moyenTitre,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${utilisateur.programme} • ${utilisateur.codeEtudiant}',
              style: StylesTexteApp.corpsGris,
            ),
            Text(
              'Inscrit le ${_formaterDate(utilisateur.dateInscription)}',
              style: StylesTexteApp.petitGris,
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: utilisateur.estActif ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            utilisateur.estActif ? 'Actif' : 'Suspendu',
            style: StylesTexteApp.petitBlanc.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // UI Design: Actions rapides
  Widget _construireActionsRapides() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions Rapides',
          style: StylesTexteApp.grandTitre,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _actualiserDonnees,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualiser'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CouleursApp.principal,
                  foregroundColor: CouleursApp.blanc,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _exporterRapport,
                icon: const Icon(Icons.download),
                label: const Text('Exporter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CouleursApp.accent,
                  foregroundColor: CouleursApp.blanc,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // UI Design: Méthodes de navigation
  void _naviguerVersGestionComptes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminGestionComptesEcran(),
      ),
    );
  }

  void _naviguerVersGestionCantine() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminGestionCantineEcran(),
      ),
    );
  }

  void _naviguerVersGestionActualites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminGestionActualitesEcran(),
      ),
    );
  }

  void _afficherMessageModeration() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modération', style: StylesTexteApp.moyenTitre),
        content: const Text('La fonctionnalité de modération sera disponible prochainement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: StylesTexteApp.lienPrincipal),
          ),
        ],
      ),
    );
  }

  void _actualiserDonnees() {
    _chargerDonnees();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text('Données actualisées avec succès !'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _exporterRapport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Export des rapports en cours...'),
        backgroundColor: CouleursApp.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formaterDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// UI Design: Classe de données pour les cartes de gestion
class _CarteGestionData {
  final String titre;
  final String description;
  final IconData icone;
  final Color couleur;
  final VoidCallback onTap;

  _CarteGestionData(this.titre, this.description, this.icone, this.couleur, this.onTap);
} 