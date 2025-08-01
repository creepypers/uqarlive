import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/livre.dart';
import '../../domain/repositories/livres_repository.dart';
import 'details_livre_ecran.dart';
import '../widgets/navbar_widget.dart';
import '../services/navigation_service.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import '../widgets/widget_collection.dart';
import '../widgets/widget_carte.dart';
import '../widgets/widget_section_statistiques.dart';
import '../services/statistiques_service.dart';

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
      print('Erreur lors du chargement des données: $e');
      setState(() {
        _chargementLivres = false;
      });
    }
  }

  Future<void> _chargerLivres() async {
    await _chargerDonnees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: _construireAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section filtres
                _construireSectionFiltres(),
                const SizedBox(height: 20),
                
                // Statistiques échange de livres
                _construireStatistiquesEchangeLivres(),
                const SizedBox(height: 24),
                
                // Grille de livres disponibles
                _construireGrilleLivres(),
                const SizedBox(height: 20),
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
      onTapFin: () {
        // TODO: Implémenter la recherche
      },
    );
  }

  // UI Design: Section filtres spécialisée pour les livres
  Widget _construireSectionFiltres() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres de Livres',
          style: StylesTexteApp.titre.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),
        
        // Filtres par matière (chips horizontaux)
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _matieres.length,
            itemBuilder: (context, index) {
              final matiere = _matieres[index];
              final estSelectionne = _matiereSelectionnee == matiere;
              
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  label: Text(
                    matiere,
                    style: TextStyle(
                      color: estSelectionne 
                          ? CouleursApp.blanc 
                          : CouleursApp.principal,
                      fontWeight: estSelectionne ? FontWeight.bold : FontWeight.w500,
                    ),
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
                    _chargerLivres();
                  },
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Filtres état et année avec DropdownButton natifs stylisés
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        fontSize: 14,
                      ),
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: CouleursApp.principal,
                    ),
                    onChanged: (String? newValue) {
                      setState(() => _filtreEtat = newValue!);
                      _chargerLivres();
                    },
                    items: _etatsLivre.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: CouleursApp.texteFonce,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        fontSize: 14,
                      ),
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: CouleursApp.principal,
                    ),
                    onChanged: (String? newValue) {
                      setState(() => _filtreAnnee = newValue!);
                      _chargerLivres();
                    },
                    items: _anneesEtude.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
                        value: value,
              child: Text(
                          value,
                style: TextStyle(
                  color: CouleursApp.texteFonce,
                  fontSize: 14,
                ),
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

  // UI Design: Statistiques dynamiques pour l'échange de livres
  Widget _construireStatistiquesEchangeLivres() {
    if (_statistiques == null) {
      return const SizedBox.shrink();
    }

    return WidgetSectionStatistiques.marketplace(
      statistiques: [
        {
          'valeur': _statistiques!.livresDisponibles.toString(),
          'label': 'Livres\ndisponibles',
          'icone': Icons.menu_book,
          'couleur': CouleursApp.principal,
        },
        {
          'valeur': _statistiques!.livresRecents.toString(),
          'label': 'Livres\nrécents',
          'icone': Icons.swap_horiz,
          'couleur': CouleursApp.principal,
        },
        {
          'valeur': _statistiques!.utilisateursActifs.toString(),
          'label': 'Étudiants\nactifs',
          'icone': Icons.school,
          'couleur': CouleursApp.principal,
        },
      ],
    );
  }

  // UI Design: Grille de livres disponibles pour l'échange avec WidgetCarte optimisé
  Widget _construireGrilleLivres() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Livres Disponibles',
              style: StylesTexteApp.titre.copyWith(fontSize: 22),
            ),
            const SizedBox(width: 16),
            Text(
              '(${_livresDisponibles.length})',
              style: TextStyle(
                fontSize: 18,
                color: CouleursApp.principal.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        WidgetCollection<Livre>.grille(
          elements: _livresDisponibles,
          enChargement: _chargementLivres,
          ratioAspect: 0.75, // UI Design: Ajuste de 1.05 à 0.75 pour éviter l'overflow (hauteur plus grande que largeur)
          nombreColonnes: 2,
          espacementColonnes: 16,
          espacementLignes: 16,
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
          padding: const EdgeInsets.symmetric(horizontal: 16), // UI Design: Padding pour éviter les débordements
        ),
      ],
    );
  }
} 