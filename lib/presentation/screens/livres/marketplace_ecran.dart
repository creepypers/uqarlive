import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/livre.dart';
import '../../../domain/repositories/livres_repository.dart';
import 'details_livre_ecran.dart';
import '../../../presentation/widgets/navbar_widget.dart';
import '../../../presentation/services/navigation_service.dart';
import '../../../presentation/widgets/widget_barre_app_personnalisee.dart';
import '../../../presentation/widgets/widget_collection.dart';
import '../../../presentation/widgets/widget_carte.dart';
import 'gerer_livres_ecran.dart';

import '../../../presentation/services/statistiques_service.dart';

// UI Design: Écran marketplace avec widgets ultra-minimalistes
class MarketplaceEcran extends StatefulWidget {
  const MarketplaceEcran({super.key});

  @override
  State<MarketplaceEcran> createState() => _MarketplaceEcranState();
}

class _MarketplaceEcranState extends State<MarketplaceEcran> {
  // Repository pour accéder aux données des livres
  late final LivresRepository _livresRepository;
  late final StatistiquesService _statistiquesService;
  List<Livre> _livresDisponibles = [];
  List<Livre> _livresFiltres = [];
  StatistiquesGlobales? _statistiques;
  bool _chargementLivres = false;

  // Variables pour les filtres
  String _matiereSelectionnee = 'Matières';
  String _filtreEtat = 'États';
  String _filtreAnnee = 'Années';
  
  // Variables pour la recherche
  final TextEditingController _controleurRecherche = TextEditingController();
  String _termeRecherche = '';

  final List<String> _matieres = [
    'Matières', 'Mathématiques', 'Physique', 'Chimie', 'Biologie', 
    'Informatique', 'Génie', 'Économie', 'Droit', 'Lettres', 'Histoire'
  ];

  final List<String> _etatsLivre = ['États', 'Excellent', 'Très bon', 'Bon', 'Acceptable'];
  final List<String> _anneesEtude = ['Années', '1ère année', '2ème année', '3ème année', 'Maîtrise', 'Doctorat'];

  @override
  void initState() {
    super.initState();
    _initialiserRepositories();
    _chargerDonnees();
  }

  @override
  void dispose() {
    _controleurRecherche.dispose();
    super.dispose();
  }

  void _initialiserRepositories() {
    // UI Design: Injection de dépendances via ServiceLocator - Clean Architecture
    _livresRepository = ServiceLocator.obtenirService<LivresRepository>();
    _statistiquesService = ServiceLocator.obtenirService<StatistiquesService>();
  }

  Future<void> _chargerDonnees() async {
    setState(() {
      _chargementLivres = true;
    });

    try {
      final results = await Future.wait([
        _livresRepository.filtrerLivres(
          matiere: _matiereSelectionnee == 'Matières' ? null : _matiereSelectionnee,
          etat: _filtreEtat == 'États' ? null : _filtreEtat,
          annee: _filtreAnnee == 'Années' ? null : _filtreAnnee,
        ),
        _statistiquesService.obtenirStatistiquesGlobales(),
      ]);

      setState(() {
        _livresDisponibles = results[0] as List<Livre>;
        _livresFiltres = results[0] as List<Livre>;
        _statistiques = results[1] as StatistiquesGlobales;
        _chargementLivres = false;
      });
    } catch (e) {
      setState(() {
        _chargementLivres = false;
      });
    }
  }

  // UI Design: Implémenter la recherche de livres par titre, auteur ou matière
  void _rechercherLivres(String terme) {
    setState(() {
      _termeRecherche = terme.toLowerCase().trim();
      _appliquerFiltres();
    });
  }

  // UI Design: Appliquer tous les filtres (recherche + filtres spécifiques)
  void _appliquerFiltres() {
    List<Livre> livresFiltres = _livresDisponibles;

    // Filtre par terme de recherche
    if (_termeRecherche.isNotEmpty) {
      livresFiltres = livresFiltres.where((livre) {
        return livre.titre.toLowerCase().contains(_termeRecherche) ||
               livre.auteur.toLowerCase().contains(_termeRecherche) ||
               livre.matiere.toLowerCase().contains(_termeRecherche);
      }).toList();
    }

    // Filtre par matière
    if (_matiereSelectionnee != 'Matières') {
      livresFiltres = livresFiltres.where((livre) => 
          livre.matiere == _matiereSelectionnee).toList();
    }

    // Filtre par état
    if (_filtreEtat != 'États') {
      livresFiltres = livresFiltres.where((livre) => 
          livre.etatLivre == _filtreEtat).toList();
    }

    // Filtre par année
    if (_filtreAnnee != 'Années') {
      livresFiltres = livresFiltres.where((livre) => 
          livre.anneeEtude == _filtreAnnee).toList();
    }

    setState(() {
      _livresFiltres = livresFiltres;
    });
  }

  // UI Design: Ouvrir l'interface de recherche
  void _ouvrirRecherche() {
    showDialog(
      context: context,
      builder: (context) => _construireDialogueRecherche(),
    );
  }

  // UI Design: Ouvrir l'écran des échanges
  void _ouvrirMesEchanges() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GererLivresEcran(),
      ),
    );
  }

  // UI Design: Construire le dialogue de recherche
  Widget _construireDialogueRecherche() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Rechercher un livre'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controleurRecherche,
            autofocus: true,
            style: StylesTexteApp.champ,
            decoration: InputDecoration(
              hintText: 'Titre, auteur, matière...',
              hintStyle: StylesTexteApp.champ.copyWith(
                color: CouleursApp.texteFonce.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: CouleursApp.principal.withValues(alpha: 0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: CouleursApp.principal.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: CouleursApp.principal, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: _rechercherLivres,
          ),
          const SizedBox(height: 16),
          if (_termeRecherche.isNotEmpty) 
            Text(
              '${_livresFiltres.length} livre(s) trouvé(s)',
              style: StylesTexteApp.champ.copyWith(
                color: CouleursApp.principal,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _controleurRecherche.clear();
            _rechercherLivres('');
            Navigator.pop(context);
          },
          child: Text(
            'Effacer',
            style: TextStyle(color: CouleursApp.texteFonce.withValues(alpha: 0.6)),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: CouleursApp.principal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Fermer', style: TextStyle(color: CouleursApp.blanc)),
        ),
      ],
    );
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
      appBar: _construireAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: viewInsets.bottom + padding.bottom + screenHeight * 0.025, // UI Design: Padding adaptatif pour éviter les débordements
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04), // UI Design: Padding adaptatif
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section filtres
                _construireSectionFiltres(),
                SizedBox(height: screenHeight * 0.025), // UI Design: Espacement adaptatif
                
                // Statistiques échange de livres
                _construireStatistiquesEchangeLivres(),
                SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
                
                // Grille de livres disponibles
                _construireGrilleLivres(),
                SizedBox(height: screenHeight * 0.025), // UI Design: Espacement adaptatif
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavBarWidget(
        indexSelectionne: 1, // Livres/Marketplace
        onTap: (index) => NavigationService.gererNavigationNavBar(context, index),
      ),
    );
  }

  // UI Design: AppBar spécialisée pour l'échange de livres
  PreferredSizeWidget _construireAppBar() {
    return WidgetBarreAppPersonnalisee(
      titre: 'Échange de Livres',
      sousTitre: 'Livres Universitaires',
      onTapFin: _ouvrirRecherche, // UI Design: Recherche implementée
      widgetFin: IconButton(
        icon: const Icon(Icons.swap_horiz, color: CouleursApp.blanc),
        onPressed: _ouvrirMesEchanges,
      ),
    );
  }

  // UI Design: Section filtres spécialisée pour les livres
  Widget _construireSectionFiltres() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres de Livres',
          style: StylesTexteApp.titre.copyWith(
            fontSize: screenWidth * 0.055, // UI Design: Taille adaptative
          ),
          overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
          maxLines: 1,
        ),
        SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
        
        // Filtres par matière (chips horizontaux)
        SizedBox(
          height: screenHeight * 0.06, // UI Design: Hauteur adaptative
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _matieres.length,
            itemBuilder: (context, index) {
              final matiere = _matieres[index];
              final estSelectionne = _matiereSelectionnee == matiere;
              
              return Container(
                margin: EdgeInsets.only(right: screenWidth * 0.03), // UI Design: Marge adaptative
                child: FilterChip(
                  label: Text(
                    matiere,
                    style: TextStyle(
                      color: estSelectionne 
                          ? CouleursApp.blanc 
                          : CouleursApp.principal,
                      fontWeight: estSelectionne ? FontWeight.bold : FontWeight.w500,
                      fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                    ),
                    overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                    maxLines: 1,
                  ),
                  selected: estSelectionne,
                  backgroundColor: CouleursApp.blanc,
                  selectedColor: CouleursApp.principal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: CouleursApp.principal.withValues(alpha: 0.3),
                    ),
                  ),
                  onSelected: (value) {
                    setState(() {
                      _matiereSelectionnee = matiere;
                    });
                    _appliquerFiltres(); // UI Design: Utiliser la fonction de filtrage locale
                  },
                ),
              );
            },
          ),
        ),
        
        SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
        
        // Filtres état et année avec DropdownButton natifs stylisés
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Padding adaptatif
                decoration: BoxDecoration(
                  color: CouleursApp.blanc,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CouleursApp.principal.withValues(alpha: 0.3),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filtreEtat,
                    isExpanded: true,
                    hint: Text(
                      'État du Livre',
                      style: TextStyle(
                        color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                        fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                      ),
                      overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                      maxLines: 1,
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: CouleursApp.principal,
                      size: screenWidth * 0.06, // UI Design: Taille adaptative
                    ),
                    onChanged: (String? newValue) {
                      setState(() => _filtreEtat = newValue!);
                      _appliquerFiltres(); // UI Design: Utiliser la fonction de filtrage locale
                    },
                    items: _etatsLivre.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: CouleursApp.texteFonce,
                            fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                          ),
                          overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.04), // UI Design: Espacement adaptatif
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Padding adaptatif
                decoration: BoxDecoration(
                  color: CouleursApp.blanc,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CouleursApp.principal.withValues(alpha: 0.3),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filtreAnnee,
                    isExpanded: true,
                    hint: Text(
                      'Année d\'Étude',
                      style: TextStyle(
                        color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                        fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                      ),
                      overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                      maxLines: 1,
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: CouleursApp.principal,
                      size: screenWidth * 0.06, // UI Design: Taille adaptative
                    ),
                    onChanged: (String? newValue) {
                      setState(() => _filtreAnnee = newValue!);
                      _appliquerFiltres(); // UI Design: Utiliser la fonction de filtrage locale
                    },
                    items: _anneesEtude.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: CouleursApp.texteFonce,
                            fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                          ),
                          overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // UI Design: Statistiques modernes et attrayantes pour l'échange de livres
  Widget _construireStatistiquesEchangeLivres() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    if (_statistiques == null) {
      return const SizedBox.shrink();
    }

         return Container(
       padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        children: [
          
          
          // Grille de statistiques moderne
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: CouleursApp.principal.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                // Première ligne de stats
                Row(
                  children: [
                    Expanded(
                      child: _construireStatistiqueModerne(
                        valeur: '${_statistiques!.livresDisponibles}',
                        label: 'Livres\nDisponibles',
                        icone: Icons.menu_book,
                        couleur: CouleursApp.principal,
                        screenWidth: screenWidth,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: CouleursApp.gris.withValues(alpha: 0.3),
                      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    ),
                    Expanded(
                      child: _construireStatistiqueModerne(
                        valeur: '${_statistiques!.livresRecents}',
                        label: 'Livres\nRécents',
                        icone: Icons.fiber_new,
                        couleur: CouleursApp.accent,
                        screenWidth: screenWidth,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 1,
                  color: CouleursApp.gris.withValues(alpha: 0.2),
                  margin: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                ),
                // Deuxième ligne de stats
                Row(
                  children: [
                    Expanded(
                      child: _construireStatistiqueModerne(
                        valeur: '${_statistiques!.utilisateursActifs}',
                        label: 'Étudiants\nActifs',
                        icone: Icons.school,
                        couleur: Colors.green,
                        screenWidth: screenWidth,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: CouleursApp.gris.withValues(alpha: 0.3),
                      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    ),
                    Expanded(
                      child: _construireStatistiqueModerne(
                        valeur: '${_livresDisponibles.length}',
                        label: 'Échanges\nPossibles',
                        icone: Icons.sync_alt,
                        couleur: Colors.orange,
                        screenWidth: screenWidth,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          

        ],
      ),
    );
  }

  // UI Design: Widget de statistique moderne et animé
  Widget _construireStatistiqueModerne({
    required String valeur,
    required String label,
    required IconData icone,
    required Color couleur,
    required double screenWidth,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: couleur.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: couleur.withValues(alpha: 0.2),
            ),
          ),
          child: Icon(
            icone,
            color: couleur,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          valeur,
          style: TextStyle(
            fontSize: screenWidth * 0.065,
            fontWeight: FontWeight.bold,
            color: couleur,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            color: CouleursApp.texteFonce.withValues(alpha: 0.7),
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // UI Design: Grille de livres disponibles pour l'échange avec WidgetCarte optimisé
  Widget _construireGrilleLivres() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Livres Disponibles',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.055, // UI Design: Taille adaptative
                ),
                overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ),
            SizedBox(width: screenWidth * 0.04), // UI Design: Espacement adaptatif
            Text(
              '(${_livresDisponibles.length})',
              style: TextStyle(
                fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                color: CouleursApp.principal.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
              maxLines: 1,
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
        WidgetCollection<Livre>.grille(
          elements: _livresDisponibles,
          enChargement: _chargementLivres,
          ratioAspect: 0.75, // UI Design: Ajuste de 1.05 à 0.75 pour éviter l'overflow (hauteur plus grande que largeur)
          nombreColonnes: 2,
          espacementColonnes: screenWidth * 0.04, // UI Design: Espacement adaptatif
          espacementLignes: screenHeight * 0.02, // UI Design: Espacement adaptatif
          constructeurElement: (context, livre, index) {
            return WidgetCarte.livre(
              livre: livre,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DetailsLivreEcran(livre: livre),
                  ),
                );
              },
            );
          },
          messageEtatVide: 'Aucun livre disponible pour l\'échange',
          iconeEtatVide: Icons.menu_book_outlined,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Padding adaptatif
        ),
      ],
    );
  }
} 