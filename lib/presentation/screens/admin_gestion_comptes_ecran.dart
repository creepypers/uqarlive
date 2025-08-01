// UI Design: Écran de gestion des comptes utilisateurs avec statistiques dynamiques
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/utilisateur.dart';
import '../../domain/repositories/utilisateurs_repository.dart';
import '../widgets/widget_barre_app_navigation_admin.dart';
import '../widgets/widget_section_statistiques.dart';
import '../services/statistiques_service.dart';
import 'modifier_profil_ecran.dart';

class AdminGestionComptesEcran extends StatefulWidget {
  const AdminGestionComptesEcran({super.key});

  @override
  State<AdminGestionComptesEcran> createState() => _AdminGestionComptesEcranState();
}

class _AdminGestionComptesEcranState extends State<AdminGestionComptesEcran>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UtilisateursRepository _utilisateursRepository;
  late StatistiquesService _statistiquesService;
  
  List<Utilisateur> _utilisateurs = [];
  List<Utilisateur> _utilisateursFiltres = [];
  StatistiquesGlobales? _statistiques;
  bool _chargementEnCours = true;
  bool _statistiquesVisibles = true; // UI Design: Contrôle visibilité des statistiques
  String _filtreRecherche = '';
  String _ongletActif = 'tous';

  final TextEditingController _controleurRecherche = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _utilisateursRepository = ServiceLocator.obtenirService<UtilisateursRepository>();
    _statistiquesService = StatistiquesService();
    _chargerDonnees();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controleurRecherche.dispose();
    super.dispose();
  }

  Future<void> _chargerDonnees() async {
    try {
      setState(() => _chargementEnCours = true);
      
      final results = await Future.wait([
        _utilisateursRepository.obtenirTousLesUtilisateurs(),
        _statistiquesService.obtenirStatistiquesGlobales(),
      ]);

      setState(() {
        _utilisateurs = results[0] as List<Utilisateur>;
        _statistiques = results[1] as StatistiquesGlobales;
        _appliquerFiltres();
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

  void _appliquerFiltres() {
    _utilisateursFiltres = _utilisateurs.where((utilisateur) {
      // Filtre par recherche
      final rechercheOk = _filtreRecherche.isEmpty ||
          utilisateur.nom.toLowerCase().contains(_filtreRecherche.toLowerCase()) ||
          utilisateur.prenom.toLowerCase().contains(_filtreRecherche.toLowerCase()) ||
          utilisateur.email.toLowerCase().contains(_filtreRecherche.toLowerCase()) ||
          utilisateur.codeEtudiant.toLowerCase().contains(_filtreRecherche.toLowerCase());

      // Filtre par onglet
      final ongletOk = switch (_ongletActif) {
        'tous' => true,
        'etudiants' => utilisateur.typeUtilisateur == TypeUtilisateur.etudiant,
        'admins' => utilisateur.typeUtilisateur == TypeUtilisateur.administrateur,
        _ => true,
      };

      return rechercheOk && ongletOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: WidgetBarreAppNavigationAdmin(
        titre: 'Gestion des Comptes',
        sousTitre: 'Administration des utilisateurs',
        sectionActive: 'comptes',
      ),
      body: _chargementEnCours
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _construireStatistiques(),
                _construireBarreRecherche(),
                _construireOnglets(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _construireListeUtilisateurs('tous'),
                      _construireListeUtilisateurs('etudiants'),
                      _construireListeUtilisateurs('admins'),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _afficherModalNouvelUtilisateur,
        backgroundColor: CouleursApp.principal,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Nouveau', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // UI Design: Section des statistiques dynamiques
  Widget _construireStatistiques() {
    if (_statistiques == null) return const SizedBox.shrink();
    
    return Container(
      color: CouleursApp.blanc,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statistiques Utilisateurs',
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
              ? WidgetSectionStatistiques(
                  statistiques: [
                    {
                      'titre': 'Total',
                      'valeur': _statistiques!.totalUtilisateurs.toString(),
                      'icone': Icons.people,
                      'couleur': CouleursApp.principal,
                      'tendance': '+${_statistiques!.totalUtilisateurs}',
                    },
                    {
                      'titre': 'Actifs',
                      'valeur': _statistiques!.utilisateursActifs.toString(),
                      'icone': Icons.check_circle,
                      'couleur': Colors.green,
                      'tendance': '${((_statistiques!.utilisateursActifs / _statistiques!.totalUtilisateurs) * 100).toStringAsFixed(1)}%',
                    },
                    {
                      'titre': 'Admins',
                      'valeur': _statistiques!.administrateurs.toString(),
                      'icone': Icons.admin_panel_settings,
                      'couleur': CouleursApp.accent,
                      'tendance': 'Admin',
                    },
                    {
                      'titre': 'Étudiants',
                      'valeur': _statistiques!.etudiants.toString(),
                      'icone': Icons.school,
                      'couleur': Colors.orange,
                      'tendance': 'Étudiants',
                    },
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
      ),
    );
  }

  // UI Design: Barre de recherche améliorée
  Widget _construireBarreRecherche() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controleurRecherche,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom, email ou code...',
                prefixIcon: Icon(Icons.search, color: CouleursApp.principal),
                suffixIcon: _filtreRecherche.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controleurRecherche.clear();
                          setState(() {
                            _filtreRecherche = '';
                            _appliquerFiltres();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: CouleursApp.principal.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: CouleursApp.principal, width: 2),
                ),
                filled: true,
                fillColor: CouleursApp.fond,
              ),
              onChanged: (valeur) {
                setState(() {
                  _filtreRecherche = valeur;
                  _appliquerFiltres();
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: CouleursApp.principal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_utilisateursFiltres.length} résultat(s)',
              style: StylesTexteApp.corpsNormal.copyWith(
                color: CouleursApp.principal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Onglets pour filtrer par type d'utilisateur
  Widget _construireOnglets() {
    return Container(
      color: CouleursApp.blanc,
      child: TabBar(
        controller: _tabController,
        labelColor: CouleursApp.principal,
        unselectedLabelColor: Colors.grey,
        indicatorColor: CouleursApp.principal,
        onTap: (index) {
          setState(() {
            _ongletActif = ['tous', 'etudiants', 'admins'][index];
            _appliquerFiltres();
          });
        },
        tabs: [
          Tab(
            icon: Icon(Icons.people),
            text: 'Tous (${_statistiques?.totalUtilisateurs ?? 0})',
          ),
          Tab(
            icon: Icon(Icons.school),
            text: 'Étudiants (${_statistiques?.etudiants ?? 0})',
          ),
          Tab(
            icon: Icon(Icons.admin_panel_settings),
            text: 'Admins (${_statistiques?.administrateurs ?? 0})',
          ),
        ],
      ),
    );
  }

  // UI Design: Liste des utilisateurs avec design moderne
  Widget _construireListeUtilisateurs(String typeFiltre) {
    final utilisateursFiltres = _utilisateurs.where((u) {
      final rechercheOk = _filtreRecherche.isEmpty ||
          u.nom.toLowerCase().contains(_filtreRecherche.toLowerCase()) ||
          u.prenom.toLowerCase().contains(_filtreRecherche.toLowerCase()) ||
          u.email.toLowerCase().contains(_filtreRecherche.toLowerCase()) ||
          u.codeEtudiant.toLowerCase().contains(_filtreRecherche.toLowerCase());

      final typeOk = typeFiltre == 'tous' || 
          (typeFiltre == 'etudiants' && u.typeUtilisateur == TypeUtilisateur.etudiant) ||
          (typeFiltre == 'admins' && u.typeUtilisateur == TypeUtilisateur.administrateur);
      
      return rechercheOk && typeOk;
    }).toList();

    if (utilisateursFiltres.isEmpty) {
      return _construireMessageVide();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: utilisateursFiltres.length,
      itemBuilder: (context, index) {
        final utilisateur = utilisateursFiltres[index];
        return _construireCarteUtilisateur(utilisateur);
      },
    );
  }

  // UI Design: Carte utilisateur modernisée
  Widget _construireCarteUtilisateur(Utilisateur utilisateur) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _afficherDetailsUtilisateur(utilisateur),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar utilisateur
              CircleAvatar(
                radius: 30,
                backgroundColor: _obtenirCouleurTypeUtilisateur(utilisateur.typeUtilisateur),
                child: Text(
                  '${utilisateur.prenom[0]}${utilisateur.nom[0]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Informations utilisateur
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${utilisateur.prenom} ${utilisateur.nom}',
                            style: StylesTexteApp.moyenTitre,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _construireBadgeStatut(utilisateur),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      utilisateur.email,
                      style: StylesTexteApp.corpsNormal.copyWith(color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _obtenirCouleurTypeUtilisateur(utilisateur.typeUtilisateur).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _obtenirLibelleTypeUtilisateur(utilisateur.typeUtilisateur),
                            style: TextStyle(
                              color: _obtenirCouleurTypeUtilisateur(utilisateur.typeUtilisateur),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          utilisateur.codeEtudiant,
                          style: StylesTexteApp.petitGris,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Menu actions
              PopupMenuButton<String>(
                onSelected: (action) => _gererActionUtilisateur(utilisateur, action),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'modifier',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: utilisateur.estActif ? 'suspendre' : 'activer',
                    child: Row(
                      children: [
                        Icon(
                          utilisateur.estActif ? Icons.block : Icons.check_circle,
                          color: utilisateur.estActif ? Colors.red : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          utilisateur.estActif ? 'Suspendre' : 'Activer',
                          style: TextStyle(
                            color: utilisateur.estActif ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'supprimer',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UI Design: Badge de statut utilisateur
  Widget _construireBadgeStatut(Utilisateur utilisateur) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: utilisateur.estActif ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        utilisateur.estActif ? 'Actif' : 'Suspendu',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // UI Design: Message vide avec call-to-action
  Widget _construireMessageVide() {
    return Center(
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
              'Aucun utilisateur trouvé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CouleursApp.texteFonce,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Modifiez vos critères de recherche ou ajoutez un nouvel utilisateur',
              style: StylesTexteApp.corpsGris,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _afficherModalNouvelUtilisateur,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un utilisateur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CouleursApp.principal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI Design: Méthodes utilitaires
  Color _obtenirCouleurTypeUtilisateur(TypeUtilisateur type) {
    switch (type) {
      case TypeUtilisateur.administrateur: return CouleursApp.accent;
      case TypeUtilisateur.etudiant: return CouleursApp.principal;
    }
  }

  String _obtenirLibelleTypeUtilisateur(TypeUtilisateur type) {
    switch (type) {
      case TypeUtilisateur.administrateur: return 'Administrateur';
      case TypeUtilisateur.etudiant: return 'Étudiant';
    }
  }

  // UI Design: Méthodes d'interaction
  void _afficherDetailsUtilisateur(Utilisateur utilisateur) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModifierProfilEcran(utilisateur: utilisateur),
      ),
    ).then((resultat) {
      if (resultat == true) {
        _chargerDonnees(); // Recharger si modifié
      }
    });
  }

  void _gererActionUtilisateur(Utilisateur utilisateur, String action) {
    switch (action) {
      case 'modifier':
        _afficherDetailsUtilisateur(utilisateur);
        break;
      case 'suspendre':
      case 'activer':
        _toggleStatutUtilisateur(utilisateur);
        break;
      case 'supprimer':
        _confirmerSuppressionUtilisateur(utilisateur);
        break;
    }
  }

  void _toggleStatutUtilisateur(Utilisateur utilisateur) {
    // TODO: Implémenter la modification du statut
    setState(() {
      final index = _utilisateurs.indexWhere((u) => u.id == utilisateur.id);
      if (index != -1) {
        _utilisateurs[index] = utilisateur.copyWith(estActif: !utilisateur.estActif);
        _appliquerFiltres();
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          utilisateur.estActif 
              ? 'Utilisateur ${utilisateur.prenom} ${utilisateur.nom} suspendu'
              : 'Utilisateur ${utilisateur.prenom} ${utilisateur.nom} activé',
        ),
        backgroundColor: utilisateur.estActif ? Colors.orange : Colors.green,
      ),
    );
  }

  void _confirmerSuppressionUtilisateur(Utilisateur utilisateur) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la suppression', style: StylesTexteApp.moyenTitre),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'utilisateur "${utilisateur.prenom} ${utilisateur.nom}" ?\n\nCette action est irréversible.',
          style: StylesTexteApp.corpsNormal,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: StylesTexteApp.lienPrincipal),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _supprimerUtilisateur(utilisateur);
            },
            child: Text(
              'Supprimer',
              style: StylesTexteApp.lienPrincipal.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _supprimerUtilisateur(Utilisateur utilisateur) {
    // TODO: Implémenter la suppression
    setState(() {
      _utilisateurs.removeWhere((u) => u.id == utilisateur.id);
      _appliquerFiltres();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Utilisateur "${utilisateur.prenom} ${utilisateur.nom}" supprimé'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // UI Design: Navigation vers ModifierProfilEcran pour créer un nouvel utilisateur
  void _afficherModalNouvelUtilisateur() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ModifierProfilEcran(), // Aucun utilisateur = mode création
      ),
    ).then((resultat) {
      if (resultat == true) {
        _chargerDonnees(); // Recharger si un nouvel utilisateur a été créé
      }
    });
  }
} 