// UI Design: Écran de gestion des comptes utilisateurs avec design moderne et épuré
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/utilisateur.dart';
import '../../../domain/repositories/utilisateurs_repository.dart';
    import '../../../presentation/widgets/widget_barre_app_navigation_admin.dart';
import '../../../presentation/widgets/widget_section_statistiques.dart';
import '../../../presentation/services/statistiques_service.dart';
import '../../../presentation/screens/utilisateur/profil_ecran.dart';
import '../../../presentation/screens/utilisateur/modifier_profil_ecran.dart';

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
  bool _statistiquesVisibles = false;
  
  List<Utilisateur> _utilisateurs = [];
  List<Utilisateur> _utilisateursFiltres = [];
  StatistiquesGlobales? _statistiques;
  bool _chargementEnCours = true;
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
    
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      resizeToAvoidBottomInset: true,
      appBar: const WidgetBarreAppNavigationAdmin(
        titre: 'Gestion des Comptes',
        sousTitre: 'Administration des utilisateurs',
        sectionActive: 'comptes',
      ),
      body: _chargementEnCours
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _construireStatistiquesModernes(),
                    _construireBarreRechercheModerne(),
                    _construireOngletsModernes(),
                    // Contenu scrollable des onglets
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.65,
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
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _afficherModalNouvelUtilisateur,
        backgroundColor: CouleursApp.principal,
        icon: Icon(Icons.person_add, color: Colors.white, size: screenWidth * 0.06),
        label: Text(
          'Nouveau', 
          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
        ),
      ),
    );
  }

  // UI Design: Section des statistiques avec design moderne
  Widget _construireStatistiquesModernes() {
    if (_statistiques == null) return const SizedBox.shrink();
    
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: CouleursApp.principal,
                    size: screenWidth * 0.06,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Text(
                    'Vue d\'ensemble',
                    style: StylesTexteApp.titrePage.copyWith(
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              IconButton(
                tooltip: _statistiquesVisibles ? 'Masquer les statistiques' : 'Afficher les statistiques',
                onPressed: () => setState(() => _statistiquesVisibles = !_statistiquesVisibles),
                icon: Icon(
                  _statistiquesVisibles ? Icons.visibility_off : Icons.visibility,
                  color: CouleursApp.principal,
                  size: screenWidth * 0.06,
                ),
              ),
            ],
          ),
          if (_statistiquesVisibles) ...[
            SizedBox(height: screenHeight * 0.025),
            Row(
              children: [
                Expanded(
                  child: _construireCarteStatistique(
                    'Total',
                    _statistiques!.totalUtilisateurs.toString(),
                    Icons.people,
                    CouleursApp.principal,
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: _construireCarteStatistique(
                    'Actifs',
                    _statistiques!.utilisateursActifs.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Row(
              children: [
                Expanded(
                  child: _construireCarteStatistique(
                    'Étudiants',
                    _statistiques!.etudiants.toString(),
                    Icons.school,
                    Colors.orange,
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: _construireCarteStatistique(
                    'Admins',
                    _statistiques!.administrateurs.toString(),
                    Icons.admin_panel_settings,
                    CouleursApp.accent,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // UI Design: Carte statistique moderne
  Widget _construireCarteStatistique(String titre, String valeur, IconData icone, Color couleur) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: couleur.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: couleur, size: screenWidth * 0.05),
              SizedBox(width: screenWidth * 0.02),
              Text(
                titre,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            valeur,
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: couleur,
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Barre de recherche moderne
  Widget _construireBarreRechercheModerne() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controleurRecherche,
              style: TextStyle(fontSize: screenWidth * 0.04),
              decoration: InputDecoration(
                hintText: 'Rechercher un utilisateur...',
                hintStyle: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: CouleursApp.texteFonce.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: CouleursApp.principal,
                  size: screenWidth * 0.06,
                ),
                suffixIcon: _filtreRecherche.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: screenWidth * 0.06,
                          color: CouleursApp.texteFonce.withValues(alpha: 0.5),
                        ),
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
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: CouleursApp.fond,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.015,
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
          SizedBox(width: screenWidth * 0.03),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenWidth * 0.02,
            ),
            decoration: BoxDecoration(
              color: CouleursApp.principal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_utilisateursFiltres.length}',
              style: TextStyle(
                color: CouleursApp.principal,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.035,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Onglets modernes
  Widget _construireOngletsModernes() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: CouleursApp.principal,
        unselectedLabelColor: CouleursApp.texteFonce.withValues(alpha: 0.5),
        indicatorColor: CouleursApp.principal,
        indicatorWeight: 3,
        labelStyle: TextStyle(
          fontSize: screenWidth * 0.035,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: screenWidth * 0.035,
          fontWeight: FontWeight.w500,
        ),
        onTap: (index) {
          setState(() {
            _ongletActif = ['tous', 'etudiants', 'admins'][index];
            _appliquerFiltres();
          });
        },
        tabs: [
          Tab(
            icon: Icon(Icons.people, size: screenWidth * 0.06),
            text: 'Tous (${_statistiques?.totalUtilisateurs ?? 0})',
          ),
          Tab(
            icon: Icon(Icons.school, size: screenWidth * 0.06),
            text: 'Étudiants (${_statistiques?.etudiants ?? 0})',
          ),
          Tab(
            icon: Icon(Icons.admin_panel_settings, size: screenWidth * 0.06),
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
      return _construireMessageVideModerne();
    }

    return ListView.builder(
      padding: EdgeInsets.all(screenWidth * 0.04),
      itemCount: utilisateursFiltres.length,
      itemBuilder: (context, index) {
        final utilisateur = utilisateursFiltres[index];
        return _construireCarteUtilisateurModerne(utilisateur);
      },
    );
  }

  // UI Design: Carte utilisateur moderne et épurée
  Widget _construireCarteUtilisateurModerne(Utilisateur utilisateur) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _afficherDetailsUtilisateur(utilisateur),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Row(
              children: [
                // Avatar moderne
                Container(
                  width: screenWidth * 0.15,
                  height: screenWidth * 0.15,
                  decoration: BoxDecoration(
                    color: _obtenirCouleurTypeUtilisateur(utilisateur.typeUtilisateur),
                    borderRadius: BorderRadius.circular(screenWidth * 0.075),
                    boxShadow: [
                      BoxShadow(
                        color: _obtenirCouleurTypeUtilisateur(utilisateur.typeUtilisateur).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${utilisateur.prenom[0]}${utilisateur.nom[0]}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
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
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w600,
                                color: CouleursApp.texteFonce,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          _construireBadgeStatutModerne(utilisateur),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        utilisateur.email,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.025,
                              vertical: screenWidth * 0.015,
                            ),
                            decoration: BoxDecoration(
                              color: _obtenirCouleurTypeUtilisateur(utilisateur.typeUtilisateur).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _obtenirCouleurTypeUtilisateur(utilisateur.typeUtilisateur).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _obtenirLibelleTypeUtilisateur(utilisateur.typeUtilisateur),
                              style: TextStyle(
                                color: _obtenirCouleurTypeUtilisateur(utilisateur.typeUtilisateur),
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                              vertical: screenWidth * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: CouleursApp.gris.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              utilisateur.codeEtudiant,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Menu actions moderne
                PopupMenuButton<String>(
                  onSelected: (action) => _gererActionUtilisateur(utilisateur, action),
                  icon: Icon(
                    Icons.more_vert,
                    size: screenWidth * 0.06,
                    color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                  ),
                  itemBuilder: (context) => [
                    _construireMenuItem('modifier', 'Modifier', Icons.edit, null),
                    if (utilisateur.typeUtilisateur == TypeUtilisateur.etudiant)
                      _construireMenuItem('attribuer_admin', 'Promouvoir Admin', Icons.admin_panel_settings, Colors.orange),
                    if (utilisateur.typeUtilisateur == TypeUtilisateur.administrateur)
                      _construireMenuItem('gerer_privileges', 'Gérer privilèges', Icons.security, Colors.blue),
                    _construireMenuItem(
                      utilisateur.estActif ? 'suspendre' : 'activer',
                      utilisateur.estActif ? 'Suspendre' : 'Activer',
                      utilisateur.estActif ? Icons.block : Icons.check_circle,
                      utilisateur.estActif ? Colors.red : Colors.green,
                    ),
                    _construireMenuItem('supprimer', 'Supprimer', Icons.delete, Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // UI Design: Menu item moderne
  PopupMenuItem<String> _construireMenuItem(String value, String text, IconData icon, Color? color) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: screenWidth * 0.05,
            color: color ?? CouleursApp.texteFonce.withValues(alpha: 0.7),
          ),
          SizedBox(width: screenWidth * 0.03),
          Text(
            text,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: color ?? CouleursApp.texteFonce,
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Badge de statut moderne
  Widget _construireBadgeStatutModerne(Utilisateur utilisateur) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenWidth * 0.01,
      ),
      decoration: BoxDecoration(
        color: utilisateur.estActif ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (utilisateur.estActif ? Colors.green : Colors.red).withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        utilisateur.estActif ? 'Actif' : 'Suspendu',
        style: TextStyle(
          color: Colors.white,
          fontSize: screenWidth * 0.025,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // UI Design: Message vide moderne
  Widget _construireMessageVideModerne() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.25,
              height: screenWidth * 0.25,
              decoration: BoxDecoration(
                color: CouleursApp.principal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(screenWidth * 0.125),
              ),
              child: Icon(
                Icons.people_outline,
                size: screenWidth * 0.12,
                color: CouleursApp.principal.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              'Aucun utilisateur trouvé',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600,
                color: CouleursApp.texteFonce,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              'Modifiez vos critères de recherche\nou ajoutez un nouvel utilisateur',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: CouleursApp.texteFonce.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.04),
            ElevatedButton.icon(
              onPressed: _afficherModalNouvelUtilisateur,
              icon: Icon(Icons.add, size: screenWidth * 0.05),
              label: Text(
                'Ajouter un utilisateur',
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CouleursApp.principal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenHeight * 0.015,
                ),
                elevation: 2,
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
      case TypeUtilisateur.administrateur: return 'Admin';
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
        _chargerDonnees();
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
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmerSuppressionUtilisateur(Utilisateur utilisateur) {
    showDialog(
      context: context,
      builder: (context) => LayoutBuilder(builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth * 0.9;
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: dialogWidth),
          child: AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('Confirmer la suppression'),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'utilisateur "${utilisateur.prenom} ${utilisateur.nom}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _supprimerUtilisateur(utilisateur);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Supprimer'),
          ),
        ],
          ),
        );
      }),
    );
  }

  void _supprimerUtilisateur(Utilisateur utilisateur) {
    setState(() {
      _utilisateurs.removeWhere((u) => u.id == utilisateur.id);
      _appliquerFiltres();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Utilisateur "${utilisateur.prenom} ${utilisateur.nom}" supprimé'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmerPromotionAdmin(Utilisateur utilisateur) {
    showDialog(
      context: context,
      builder: (context) => LayoutBuilder(builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth * 0.9;
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: dialogWidth),
          child: AlertDialog(
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.orange),
            SizedBox(width: 8),
            Text('Promouvoir Administrateur'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir promouvoir "${utilisateur.prenom} ${utilisateur.nom}" en administrateur ?',
            ),
            SizedBox(height: 16),
            Text(
              'Cette action lui donnera accès à :',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            ...[
              '• Gestion des comptes utilisateurs',
              '• Administration de la cantine',
              '• Gestion des actualités',
              '• Modération du contenu',
              '• Accès aux statistiques'
            ].map((privilege) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(privilege),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
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
            child: Text('Promouvoir'),
          ),
        ],
          ),
        );
      }),
    );
  }

  Future<void> _promouvoirEnAdmin(Utilisateur utilisateur) async {
    try {
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
        await _chargerDonnees();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.white),
                  SizedBox(width: 8),
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
            SnackBar(
              content: Text('Erreur lors de la promotion de l\'utilisateur'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
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
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _afficherGestionPrivileges(Utilisateur utilisateur) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.security, color: Colors.blue),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Privilèges de ${utilisateur.prenom} ${utilisateur.nom}',
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
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
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
                title: Text(privilege['nom']!),
                value: utilisateur.privileges.contains(privilege['code']),
                onChanged: null,
                dense: true,
                activeColor: CouleursApp.principal,
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Modification des privilèges - Fonctionnalité à venir'),
                  backgroundColor: CouleursApp.accent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _afficherModalNouvelUtilisateur() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ModifierProfilEcran(),
      ),
    ).then((resultat) {
      if (resultat == true) {
        _chargerDonnees();
      }
    });
  }
} 