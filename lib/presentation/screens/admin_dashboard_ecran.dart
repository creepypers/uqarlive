// UI Design: Écran principal du dashboard administrateur
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/utilisateur.dart';
import '../../domain/repositories/utilisateurs_repository.dart';
import '../widgets/widget_barre_app_navigation_admin.dart';
import '../widgets/widget_carte.dart';
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
      appBar: WidgetBarreAppNavigationAdmin(
        titre: 'Dashboard Admin',
        sousTitre: 'Gestion de l\'application UqarLive',
        sectionActive: 'dashboard',
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

  // UI Design: Sections de gestion principales avec cartes réutilisables
  Widget _construireSectionsGestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestion',
          style: StylesTexteApp.titrePage,
        ),
        const SizedBox(height: 16),
        // UI Design: Utilisation de Row et Wrap pour éviter les problèmes de grille
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _construireCarteGestionAvecWidget(
              'Gestion des Comptes',
              'Gérer les utilisateurs et leurs privilèges',
              Icons.account_circle,
              CouleursApp.principal,
              () => _naviguerVersGestionComptes(),
            ),
            _construireCarteGestionAvecWidget(
              'Gestion Cantine',
              'Gérer les menus et horaires',
              Icons.restaurant,
              CouleursApp.accent,
              () => _naviguerVersGestionCantine(),
            ),
            _construireCarteGestionAvecWidget(
              'Actualités & Assos',
              'Gérer les actualités et événements',
              Icons.newspaper,
              Colors.orange,
              () => _naviguerVersGestionActualites(),
            ),
            _construireCarteGestionAvecWidget(
              'Modération',
              'Modérer le contenu de l\'app',
              Icons.gavel,
              Colors.red,
              () => _afficherMessageModeration(),
            ),
          ],
        ),
      ],
    );
  }

  // UI Design: Utilisation de WidgetCarte réutilisable pour les cartes de gestion
  Widget _construireCarteGestionAvecWidget(
    String titre,
    String description,
    IconData icone,
    Color couleur,
    VoidCallback onTap,
  ) {
    // Calcul de la largeur pour 2 colonnes avec espacement
    final largeur = (MediaQuery.of(context).size.width - 48) / 2; // 16px padding + 16px spacing
    
    return SizedBox(
      width: largeur,
      height: 140, // UI Design: Hauteur fixe pour uniformité
      child: WidgetCarte.association(
        nom: titre,
        description: description,
        icone: icone,
        couleurIcone: couleur,
        onTap: onTap,
        largeur: largeur,
        hauteur: 140,
        modeHorizontal: false,
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
        // UI Design: Utilisation de Column au lieu de ListView pour éviter les problèmes de viewport
        _utilisateursRecents.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 80,
                      color: CouleursApp.principal.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Aucun nouvel utilisateur récemment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: CouleursApp.texteFonce,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: _utilisateursRecents.asMap().entries.map((entry) {
                final index = entry.key;
                final utilisateur = entry.value;
                return Column(
                  children: [
                    _construireCarteUtilisateur(utilisateur),
                    if (index < _utilisateursRecents.length - 1) 
                      const SizedBox(height: 8),
                  ],
                );
              }).toList(),
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



  String _formaterDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

 