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
    // UI Design: Obtenir les dimensions de l'écran pour l'adaptabilité
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;
    
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      resizeToAvoidBottomInset: true, // UI Design: Éviter les débordements avec le clavier
      appBar: WidgetBarreAppNavigationAdmin(
        titre: 'Gestion des Comptes',
        sousTitre: 'Administration des utilisateurs',
        sectionActive: 'comptes',
      ),
      body: SafeArea(
        child: _chargementEnCours
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _afficherModalNouvelUtilisateur,
        backgroundColor: CouleursApp.principal,
        icon: Icon(Icons.person_add, color: Colors.white, size: screenWidth * 0.06), // UI Design: Taille adaptative
        label: Text(
          'Nouveau', 
          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04), // UI Design: Taille adaptative
        ),
      ),
    );
  }

  // UI Design: Section des statistiques dynamiques
  Widget _construireStatistiques() {
    if (_statistiques == null) return const SizedBox.shrink();
    
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      color: CouleursApp.blanc,
      padding: EdgeInsets.all(screenWidth * 0.04), // UI Design: Padding adaptatif
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statistiques Utilisateurs',
                style: StylesTexteApp.titrePage.copyWith(
                  fontSize: screenWidth * 0.055, // UI Design: Taille adaptative
                ),
                overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
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
                  size: screenWidth * 0.06, // UI Design: Taille adaptative
                ),
                tooltip: _statistiquesVisibles ? 'Masquer les statistiques' : 'Afficher les statistiques',
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
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
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.025), // UI Design: Padding adaptatif
                  child: Center(
                    child: Text(
                      'Statistiques masquées - Cliquez sur l\'œil pour les afficher',
                      style: StylesTexteApp.corpsGris.copyWith(
                        fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                      maxLines: 2,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // UI Design: Barre de recherche améliorée
  Widget _construireBarreRecherche() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04), // UI Design: Padding adaptatif
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
              style: TextStyle(fontSize: screenWidth * 0.04), // UI Design: Taille adaptative
              decoration: InputDecoration(
                hintText: 'Rechercher par nom, email ou code...',
                hintStyle: TextStyle(fontSize: screenWidth * 0.04), // UI Design: Taille adaptative
                prefixIcon: Icon(Icons.search, color: CouleursApp.principal, size: screenWidth * 0.06), // UI Design: Taille adaptative
                suffixIcon: _filtreRecherche.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: screenWidth * 0.06), // UI Design: Taille adaptative
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
                  borderSide: const BorderSide(color: CouleursApp.principal, width: 2),
                ),
                filled: true,
                fillColor: CouleursApp.fond,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04, // UI Design: Padding adaptatif
                  vertical: screenHeight * 0.015, // UI Design: Padding adaptatif
                ),
              ),
              onChanged: (valeur) {
                setState(() {
                  _filtreRecherche = valeur;
                  _appliquerFiltres();
                });
              },
            ),
          ),
          SizedBox(width: screenWidth * 0.03), // UI Design: Espacement adaptatif
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03, // UI Design: Padding adaptatif
              vertical: screenWidth * 0.02,
            ),
            decoration: BoxDecoration(
              color: CouleursApp.principal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_utilisateursFiltres.length} résultat(s)',
              style: StylesTexteApp.corpsNormal.copyWith(
                color: CouleursApp.principal,
                fontWeight: FontWeight.w600,
                fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
              ),
              overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Onglets pour filtrer par type d'utilisateur
  Widget _construireOnglets() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    return Container(
      color: CouleursApp.blanc,
      child: TabBar(
        controller: _tabController,
        labelColor: CouleursApp.principal,
        unselectedLabelColor: Colors.grey,
        indicatorColor: CouleursApp.principal,
        labelStyle: TextStyle(fontSize: screenWidth * 0.035), // UI Design: Taille adaptative
        unselectedLabelStyle: TextStyle(fontSize: screenWidth * 0.035), // UI Design: Taille adaptative
        onTap: (index) {
          setState(() {
            _ongletActif = ['tous', 'etudiants', 'admins'][index];
            _appliquerFiltres();
          });
        },
        tabs: [
          Tab(
            icon: Icon(Icons.people, size: screenWidth * 0.06), // UI Design: Taille adaptative
            text: 'Tous (${_statistiques?.totalUtilisateurs ?? 0})',
          ),
          Tab(
            icon: Icon(Icons.school, size: screenWidth * 0.06), // UI Design: Taille adaptative
            text: 'Étudiants (${_statistiques?.etudiants ?? 0})',
          ),
          Tab(
            icon: Icon(Icons.admin_panel_settings, size: screenWidth * 0.06), // UI Design: Taille adaptative
            text: 'Admins (${_statistiques?.administrateurs ?? 0})',
          ),
        ],
      ),
    );
  }

  // UI Design: Liste des utilisateurs avec design moderne
  Widget _construireListeUtilisateurs(String typeFiltre) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
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
      padding: EdgeInsets.all(screenWidth * 0.04), // UI Design: Padding adaptatif
      itemCount: utilisateursFiltres.length,
      itemBuilder: (context, index) {
        final utilisateur = utilisateursFiltres[index];
        return _construireCarteUtilisateur(utilisateur);
      },
    );
  }

  // UI Design: Carte utilisateur modernisée
  Widget _construireCarteUtilisateur(Utilisateur utilisateur) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Card(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015), // UI Design: Marge adaptative
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _afficherDetailsUtilisateur(utilisateur),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04), // UI Design: Padding adaptatif
          child: Row(
            children: [
              // Avatar utilisateur
              CircleAvatar(
                radius: screenWidth * 0.075, // UI Design: Taille adaptative
                backgroundColor: _obtenirCouleurTypeUtilisateur(utilisateur.typeUtilisateur),
                child: Text(
                  '${utilisateur.prenom[0]}${utilisateur.nom[0]}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.04), // UI Design: Espacement adaptatif
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
                            style: StylesTexteApp.moyenTitre.copyWith(
                              fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                            ),
                            overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                            maxLines: 1,
                          ),
                        ),
                        _construireBadgeStatut(utilisateur),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.005), // UI Design: Espacement adaptatif
                    Text(
                      utilisateur.email,
                      style: StylesTexteApp.corpsNormal.copyWith(
                        color: Colors.grey[600],
                        fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                      ),
                      overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                      maxLines: 1,
                    ),
                    SizedBox(height: screenHeight * 0.005), // UI Design: Espacement adaptatif
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02, // UI Design: Padding adaptatif
                            vertical: screenWidth * 0.01,
                          ),
                          decoration: BoxDecoration(
                            color: _obtenirCouleurTypeUtilisateur(utilisateur.typeUtilisateur).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _obtenirLibelleTypeUtilisateur(utilisateur.typeUtilisateur),
                            style: TextStyle(
                              color: _obtenirCouleurTypeUtilisateur(utilisateur.typeUtilisateur),
                              fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
                        Text(
                          utilisateur.codeEtudiant,
                          style: StylesTexteApp.petitGris.copyWith(
                            fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
                          ),
                          overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Menu actions
              PopupMenuButton<String>(
                onSelected: (action) => _gererActionUtilisateur(utilisateur, action),
                icon: Icon(Icons.more_vert, size: screenWidth * 0.06), // UI Design: Taille adaptative
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'modifier',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: screenWidth * 0.05), // UI Design: Taille adaptative
                        SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
                        Text(
                          'Modifier',
                          style: TextStyle(fontSize: screenWidth * 0.035), // UI Design: Taille adaptative
                        ),
                      ],
                    ),
                  ),
                  // UI Design: Option pour attribuer des privilèges admin (seulement pour les étudiants)
                  if (utilisateur.typeUtilisateur == TypeUtilisateur.etudiant)
                    PopupMenuItem(
                      value: 'attribuer_admin',
                      child: Row(
                        children: [
                          Icon(Icons.admin_panel_settings, color: Colors.orange, size: screenWidth * 0.05), // UI Design: Taille adaptative
                          SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
                          Text(
                            'Promouvoir Admin',
                            style: TextStyle(color: Colors.orange, fontSize: screenWidth * 0.035), // UI Design: Taille adaptative
                          ),
                        ],
                      ),
                    ),
                  // UI Design: Option pour gérer les privilèges (seulement pour les admins)
                  if (utilisateur.typeUtilisateur == TypeUtilisateur.administrateur)
                    PopupMenuItem(
                      value: 'gerer_privileges',
                      child: Row(
                        children: [
                          Icon(Icons.security, color: Colors.blue, size: screenWidth * 0.05), // UI Design: Taille adaptative
                          SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
                          Text(
                            'Gérer privilèges',
                            style: TextStyle(color: Colors.blue, fontSize: screenWidth * 0.035), // UI Design: Taille adaptative
                          ),
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
                          size: screenWidth * 0.05, // UI Design: Taille adaptative
                        ),
                        SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
                        Text(
                          utilisateur.estActif ? 'Suspendre' : 'Activer',
                          style: TextStyle(
                            color: utilisateur.estActif ? Colors.red : Colors.green,
                            fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'supprimer',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: screenWidth * 0.05), // UI Design: Taille adaptative
                        SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
                        Text(
                          'Supprimer', 
                          style: TextStyle(color: Colors.red, fontSize: screenWidth * 0.035), // UI Design: Taille adaptative
                        ),
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.015, // UI Design: Padding adaptatif
        vertical: screenWidth * 0.01,
      ),
      decoration: BoxDecoration(
        color: utilisateur.estActif ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        utilisateur.estActif ? 'Actif' : 'Suspendu',
        style: TextStyle(
          color: Colors.white,
          fontSize: screenWidth * 0.025, // UI Design: Taille adaptative
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
        maxLines: 1,
      ),
    );
  }

  // UI Design: Message vide avec call-to-action
  Widget _construireMessageVide() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.1), // UI Design: Padding adaptatif
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: screenWidth * 0.2, // UI Design: Taille adaptative
              color: CouleursApp.principal.withValues(alpha: 0.3),
            ),
            SizedBox(height: screenHeight * 0.025), // UI Design: Espacement adaptatif
            Text(
              'Aucun utilisateur trouvé',
              style: TextStyle(
                fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                fontWeight: FontWeight.w600,
                color: CouleursApp.texteFonce,
              ),
              overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
              maxLines: 1,
            ),
            SizedBox(height: screenHeight * 0.01), // UI Design: Espacement adaptatif
            Text(
              'Modifiez vos critères de recherche ou ajoutez un nouvel utilisateur',
              style: StylesTexteApp.corpsGris.copyWith(
                fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
              maxLines: 2,
            ),
            SizedBox(height: screenHeight * 0.025), // UI Design: Espacement adaptatif
            ElevatedButton.icon(
              onPressed: _afficherModalNouvelUtilisateur,
              icon: Icon(Icons.add, size: screenWidth * 0.05), // UI Design: Taille adaptative
              label: Text(
                'Ajouter un utilisateur',
                style: TextStyle(fontSize: screenWidth * 0.04), // UI Design: Taille adaptative
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CouleursApp.principal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05, // UI Design: Padding adaptatif
                  vertical: screenHeight * 0.015, // UI Design: Padding adaptatif
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
      case 'attribuer_admin':
        _confirmerPromotionAdmin(utilisateur);
        break;
      case 'gerer_privileges':
        _afficherGestionPrivileges(utilisateur);
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
        title: const Text('Confirmer la suppression', style: StylesTexteApp.moyenTitre),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'utilisateur "${utilisateur.prenom} ${utilisateur.nom}" ?\n\nCette action est irréversible.',
          style: StylesTexteApp.corpsNormal,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: StylesTexteApp.lienPrincipal),
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

  // UI Design: Confirmer la promotion d'un étudiant en administrateur
  void _confirmerPromotionAdmin(Utilisateur utilisateur) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.orange),
            SizedBox(width: 8),
            Text('Promouvoir Administrateur', style: StylesTexteApp.moyenTitre),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir promouvoir "${utilisateur.prenom} ${utilisateur.nom}" en administrateur ?',
              style: StylesTexteApp.corpsNormal,
            ),
            const SizedBox(height: 16),
            Text(
              'Cette action lui donnera accès à :',
              style: StylesTexteApp.corpsNormal.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...[
              '• Gestion des comptes utilisateurs',
              '• Administration de la cantine',
              '• Gestion des actualités',
              '• Modération du contenu',
              '• Accès aux statistiques'
            ].map((privilege) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                privilege,
                style: StylesTexteApp.corpsNormal.copyWith(
                  color: CouleursApp.texteFonce.withValues(alpha: 0.8),
                ),
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: StylesTexteApp.lienPrincipal),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _promouvoirEnAdmin(utilisateur);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Promouvoir'),
          ),
        ],
      ),
    );
  }

  // UI Design: Promouvoir un utilisateur en administrateur
  Future<void> _promouvoirEnAdmin(Utilisateur utilisateur) async {
    try {
      // Créer un nouvel utilisateur avec le type administrateur et tous les privilèges
      final utilisateurAdmin = utilisateur.copyWith(
        typeUtilisateur: TypeUtilisateur.administrateur,
        privileges: [
          PrivilegesUtilisateur.gestionComptes,
          PrivilegesUtilisateur.gestionCantine,
          PrivilegesUtilisateur.gestionActualites,
          PrivilegesUtilisateur.gestionAssociations,
          PrivilegesUtilisateur.gestionSalles,
          PrivilegesUtilisateur.gestionLivres,
          PrivilegesUtilisateur.moderationContenu,
          PrivilegesUtilisateur.statistiques,
        ],
      );

      final succes = await _utilisateursRepository.modifierUtilisateur(utilisateurAdmin);
      
      if (succes) {
        await _chargerDonnees(); // Recharger les données
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.admin_panel_settings, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${utilisateur.prenom} ${utilisateur.nom} a été promu administrateur avec succès !',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la promotion de l\'utilisateur'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // UI Design: Afficher l'écran de gestion des privilèges pour un administrateur
  void _afficherGestionPrivileges(Utilisateur utilisateur) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.security, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Privilèges de ${utilisateur.prenom} ${utilisateur.nom}',
                style: StylesTexteApp.moyenTitre,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Privilèges actuels:',
                style: StylesTexteApp.corpsNormal.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ...[
                {'code': PrivilegesUtilisateur.gestionComptes, 'nom': 'Gestion des comptes'},
                {'code': PrivilegesUtilisateur.gestionCantine, 'nom': 'Gestion de la cantine'},
                {'code': PrivilegesUtilisateur.gestionActualites, 'nom': 'Gestion des actualités'},
                {'code': PrivilegesUtilisateur.gestionAssociations, 'nom': 'Gestion des associations'},
                {'code': PrivilegesUtilisateur.gestionSalles, 'nom': 'Gestion des salles'},
                {'code': PrivilegesUtilisateur.gestionLivres, 'nom': 'Gestion des livres'},
                {'code': PrivilegesUtilisateur.moderationContenu, 'nom': 'Modération du contenu'},
                {'code': PrivilegesUtilisateur.statistiques, 'nom': 'Accès aux statistiques'},
              ].map((privilege) => CheckboxListTile(
                title: Text(privilege['nom']!, style: StylesTexteApp.corpsNormal),
                value: utilisateur.privileges.contains(privilege['code']),
                onChanged: null, // Read-only pour l'instant
                dense: true,
                activeColor: CouleursApp.principal,
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer', style: StylesTexteApp.lienPrincipal),
          ),
          // TODO: Ajouter la fonctionnalité de modification des privilèges
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Modification des privilèges - Fonctionnalité à venir'),
                  backgroundColor: CouleursApp.accent,
                ),
              );
            },
            child: const Text('Modifier', style: StylesTexteApp.lienPrincipal),
          ),
        ],
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