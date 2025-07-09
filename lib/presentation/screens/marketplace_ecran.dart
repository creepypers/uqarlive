import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/livre.dart';
import '../../domain/repositories/livres_repository.dart';
import '../../data/repositories/livres_repository_impl.dart';
import '../../data/datasources/livres_datasource_local.dart';
import 'accueil_ecran.dart';
import 'details_livre_ecran.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/navigation_service.dart';

// UI Design: Plateforme d'échange de livres universitaires UqarLive
class MarketplaceEcran extends StatefulWidget {
  const MarketplaceEcran({Key? key}) : super(key: key);

  @override
  State<MarketplaceEcran> createState() => _MarketplaceEcranState();
}

class _MarketplaceEcranState extends State<MarketplaceEcran> {
  // Repository pour accéder aux données des livres
  late final LivresRepository _livresRepository;
  List<Livre> _livresDisponibles = [];
  List<Livre> _livresFiltres = [];
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
    _initialiserRepository();
    _chargerLivres();
  }

  void _initialiserRepository() {
    final datasourceLocal = LivresDatasourceLocal();
    _livresRepository = LivresRepositoryImpl(datasourceLocal);
  }

  Future<void> _chargerLivres() async {
    setState(() {
      _chargementLivres = true;
    });

    try {
      final livres = await _livresRepository.filtrerLivres(
        matiere: _matiereSelectionnee == 'Matières' ? null : _matiereSelectionnee,
        etat: _filtreEtat == 'États' ? null : _filtreEtat,
        annee: _filtreAnnee == 'Années' ? null : _filtreAnnee,
      );
      setState(() {
        _livresDisponibles = livres;
        _livresFiltres = livres;
        _chargementLivres = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des livres: $e');
      setState(() {
        _chargementLivres = false;
      });
    }
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
    return AppBar(
      backgroundColor: CouleursApp.principal,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 80,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Section titre échange de livres
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Échange de Livres',
                    style: TextStyle(
                      color: CouleursApp.blanc.withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Livres Universitaires',
                    style: TextStyle(
                      color: CouleursApp.blanc,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Bouton recherche
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CouleursApp.blanc.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.search,
                color: CouleursApp.blanc,
                size: 24,
              ),
            ),
          ],
        ),
      ),
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
                  selected: estSelectionne,
                  label: Text(
                    matiere,
                    style: TextStyle(
                      color: estSelectionne ? CouleursApp.blanc : CouleursApp.principal,
                      fontWeight: estSelectionne ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  backgroundColor: CouleursApp.blanc,
                  selectedColor: CouleursApp.principal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: CouleursApp.principal.withValues(alpha: 0.3),
                    ),
                  ),
                  onSelected: (selected) {
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
        
        // Filtres état et année
        Row(
          children: [
            Expanded(
              child: _construireDropdownFiltre(
                'État du Livre',
                _filtreEtat,
                _etatsLivre,
                (valeur) {
                  setState(() => _filtreEtat = valeur!);
                  _chargerLivres();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _construireDropdownFiltre(
                'Année d\'Étude',
                _filtreAnnee,
                _anneesEtude,
                (valeur) {
                  setState(() => _filtreAnnee = valeur!);
                  _chargerLivres();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // UI Design: Dropdown personnalisé pour filtres
  Widget _construireDropdownFiltre(
    String label,
    String valeurActuelle,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Container(
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
          value: valeurActuelle,
          isExpanded: true,
          hint: Text(label),
          icon: Icon(Icons.arrow_drop_down, color: CouleursApp.principal),
          items: options.map((String valeur) {
            return DropdownMenuItem<String>(
              value: valeur,
              child: Text(
                valeur,
                style: TextStyle(
                  color: CouleursApp.texteFonce,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // UI Design: Statistiques spécialisées pour l'échange de livres
  Widget _construireStatistiquesEchangeLivres() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CouleursApp.accent.withValues(alpha: 0.1),
            CouleursApp.principal.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CouleursApp.accent.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _construireStatItem('127', 'Livres\ndisponibles', Icons.menu_book),
          Container(
            height: 40,
            width: 1,
            color: CouleursApp.principal.withValues(alpha: 0.3),
          ),
          _construireStatItem('68', 'Échanges\nce mois', Icons.swap_horiz),
          Container(
            height: 40,
            width: 1,
            color: CouleursApp.principal.withValues(alpha: 0.3),
          ),
          _construireStatItem('45', 'Étudiants\nactifs', Icons.school),
        ],
      ),
    );
  }

  // UI Design: Item de statistique
  Widget _construireStatItem(String nombre, String label, IconData icone) {
    return Column(
      children: [
        Icon(
          icone,
          color: CouleursApp.principal,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          nombre,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CouleursApp.principal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: CouleursApp.texteFonce.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  // UI Design: Grille de livres disponibles pour l'échange
  Widget _construireGrilleLivres() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Livres Disponibles',
              style: StylesTexteApp.titre.copyWith(fontSize: 22),
            ),
            Text(
              '${_livresDisponibles.length} livres',
              style: TextStyle(
                color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_chargementLivres)
          Center(
            child: CircularProgressIndicator(
              color: CouleursApp.principal,
            ),
          )
        else if (_livresDisponibles.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.book_outlined,
                  size: 64,
                  color: CouleursApp.texteFonce.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun livre trouvé',
                  style: TextStyle(
                    fontSize: 16,
                    color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          )
        else
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
              childAspectRatio: 0.8, // Augmenté de 0.75 à 0.8 pour plus de hauteur
          ),
            itemCount: _livresDisponibles.length,
          itemBuilder: (context, index) {
              return _construireCarteLivre(_livresDisponibles[index]);
          },
        ),
      ],
    );
  }

  // UI Design: Carte de livre pour échange avec navigation vers détails
  Widget _construireCarteLivre(Livre livre) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailsLivreEcran(livre: livre),
          ),
        );
      },
      child: Container(
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Image du livre
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: CouleursApp.accent.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                        Icons.menu_book,
                      size: 50,
                      color: CouleursApp.accent,
                    ),
                  ),
                  // Badge état
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: _getCouleurEtatLivre(livre.etatLivre),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                          livre.etatLivre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                    // Badge échange
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ÉCHANGE',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
            // Informations du livre
          Expanded(
            flex: 2,
            child: Padding(
                padding: const EdgeInsets.all(10), // Réduit de 12 à 10
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Ajouté pour éviter l'overflow
                children: [
                  Text(
                      livre.titre,
                    style: TextStyle(
                        fontSize: 12, // Réduit de 13 à 12
                      fontWeight: FontWeight.w600,
                      color: CouleursApp.texteFonce,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                    const SizedBox(height: 3), // Réduit de 4 à 3
                  Text(
                      livre.auteur,
                    style: TextStyle(
                        fontSize: 10, // Réduit de 11 à 10
                      color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3), // Réduit de 4 à 3
                    Text(
                      livre.matiere,
                      style: TextStyle(
                        fontSize: 10, // Réduit de 11 à 10
                        color: CouleursApp.principal,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1, // Ajouté pour éviter l'overflow
                      overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Flexible( // Ajouté Flexible pour éviter l'overflow horizontal
                          child: Text(
                            livre.proprietaire,
                            style: TextStyle(
                              fontSize: 10, // Réduit de 11 à 10
                              color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          livre.anneeEtude,
                          style: TextStyle(
                            fontSize: 9, // Réduit de 10 à 9
                            color: CouleursApp.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  // Couleur selon l'état du livre
  Color _getCouleurEtatLivre(String etat) {
    switch (etat) {
      case 'Excellent':
        return Colors.green;
      case 'Très bon':
        return Colors.blue;
      case 'Bon':
        return Colors.orange;
      case 'Acceptable':
        return Colors.red.shade300;
      default:
        return Colors.grey;
    }
  }
} 