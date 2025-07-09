import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/livre.dart';
import '../../domain/repositories/livres_repository.dart';
import '../../data/repositories/livres_repository_impl.dart';
import '../../data/datasources/livres_datasource_local.dart';
import 'marketplace_ecran.dart';
import 'details_livre_ecran.dart';
import 'cantine_ecran.dart';
import '../widgets/navbar_widget.dart';
import '../services/navigation_service.dart';

// UI Design: Page d'accueil UqarLive avec AppBar, sections échange de livres/assos/cantine et navbar
class AccueilEcran extends StatefulWidget {
  const AccueilEcran({Key? key}) : super(key: key);

  @override
  State<AccueilEcran> createState() => _AccueilEcranState();
}

class _AccueilEcranState extends State<AccueilEcran> {
  // Repository pour accéder aux données des livres
  late final LivresRepository _livresRepository;
  List<Livre> _livresRecents = [];
  bool _chargementLivres = false;

  @override
  void initState() {
    super.initState();
    _initialiserRepository();
    _chargerLivresRecents();
  }

  void _initialiserRepository() {
    final datasourceLocal = LivresDatasourceLocal();
    _livresRepository = LivresRepositoryImpl(datasourceLocal);
  }

  Future<void> _chargerLivresRecents() async {
    setState(() {
      _chargementLivres = true;
    });

    try {
      final livres = await _livresRepository.obtenirLivresDisponibles();
      setState(() {
        _livresRecents = livres.take(5).toList(); // Prendre les 5 premiers
        _chargementLivres = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des livres récents: $e');
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
                // Section échange de livres
                _construireSectionEchangeLivres(),
                const SizedBox(height: 24),
                
                // Section associations
                _construireSectionAssociations(),
                const SizedBox(height: 24),
                
                // Section cantine
                _construireSectionCantine(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavBarWidget(
        indexSelectionne: 2, // Accueil
        onTap: (index) => NavigationService.gererNavigationNavBar(context, index),
      ),
    );
  }

  // UI Design: AppBar avec bienvenue utilisateur et température - design roundy
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
            // Section bienvenue
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue',
                    style: TextStyle(
                      color: CouleursApp.blanc.withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Marie Dubois', // TODO: Récupérer le nom de l'utilisateur connecté
                    style: TextStyle(
                      color: CouleursApp.blanc,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Section température
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: CouleursApp.blanc.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.ac_unit,
                    color: CouleursApp.blanc,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '-5°C',
                        style: TextStyle(
                          color: CouleursApp.blanc,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rimouski',
                        style: TextStyle(
                          color: CouleursApp.blanc.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI Design: Section échange de livres avec Clean Architecture
  Widget _construireSectionEchangeLivres() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                  'Échange de Livres',
              style: StylesTexteApp.titre.copyWith(fontSize: 22),
                ),
                Text(
                  'Livres universitaires récents',
                  style: TextStyle(
                    fontSize: 14,
                    color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => _naviguerVers('marketplace'),
              child: Text(
                'Voir tout',
                style: StylesTexteApp.lien,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190, // Augmenté pour éviter l'overflow
          child: _chargementLivres
              ? Center(
                  child: CircularProgressIndicator(
                    color: CouleursApp.principal,
                  ),
                )
              : _livresRecents.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun livre disponible',
                        style: TextStyle(
                          color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                        ),
                      ),
                    )
                  : ListView.builder(
            scrollDirection: Axis.horizontal,
                      itemCount: _livresRecents.length,
            itemBuilder: (context, index) {
                        return _construireCarteLivre(_livresRecents[index]);
            },
          ),
        ),
      ],
    );
  }

  // UI Design: Carte pour les livres - utilise l'entité Livre avec navigation
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
        width: 150, // Augmenté pour plus d'espace
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
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
                size: 40,
                color: CouleursApp.accent,
              ),
                  ),
                  // Badge échange
                  Positioned(
                    top: 8,
                    right: 8,
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                      livre.titre,
                  style: TextStyle(
                        fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CouleursApp.texteFonce,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                    const SizedBox(height: 3),
                Text(
                      livre.auteur,
                      style: TextStyle(
                        fontSize: 10,
                        color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            livre.matiere,
                  style: TextStyle(
                              fontSize: 10,
                    color: CouleursApp.principal,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          livre.anneeEtude.split(' ')[0], // "1ère" au lieu de "1ère année"
                          style: TextStyle(
                            fontSize: 9,
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

  // UI Design: Section associations avec scrolling horizontal
  Widget _construireSectionAssociations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Associations',
              style: StylesTexteApp.titre.copyWith(fontSize: 22),
            ),
            TextButton(
              onPressed: () => _naviguerVers('associations'),
              child: Text(
                'Voir tout',
                style: StylesTexteApp.lien,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              return _construireCarteAssociation(index);
            },
          ),
        ),
      ],
    );
  }

  // UI Design: Carte pour les associations
  Widget _construireCarteAssociation(int index) {
    final associations = [
      {'nom': 'Club Informatique', 'membres': '156', 'couleur': CouleursApp.accent},
      {'nom': 'Association Étudiante', 'membres': '230', 'couleur': CouleursApp.principal},
      {'nom': 'Club Sport', 'membres': '89', 'couleur': Colors.green},
      {'nom': 'Club Théâtre', 'membres': '45', 'couleur': Colors.purple},
    ];
    
    final asso = associations[index];
    
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (asso['couleur'] as Color).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: asso['couleur'] as Color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  asso['nom'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CouleursApp.texteFonce,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${asso['membres']} membres',
            style: TextStyle(
              fontSize: 12,
              color: CouleursApp.texteFonce.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Section cantine avec scrolling horizontal
  Widget _construireSectionCantine() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cantine',
              style: StylesTexteApp.titre.copyWith(fontSize: 22),
            ),
            TextButton(
              onPressed: () => _naviguerVers('cantine'),
              child: Text(
                'Voir tout',
                style: StylesTexteApp.lien,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200, // Augmenté de 180 à 200 pour éviter l'overflow
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return _construireCarteMenu(index);
            },
          ),
        ),
      ],
    );
  }

  // UI Design: Carte pour les menus cantine - optimisée contre l'overflow
  Widget _construireCarteMenu(int index) {
    final menus = [
      {
        'nom': 'Menu Étudiant',
        'description': 'Plat principal + accompagnement + dessert',
        'prix': '8.50€',
        'disponible': true,
      },
      {
        'nom': 'Menu Sandwich',
        'description': 'Sandwich fait maison + chips + boisson',
        'prix': '6.00€',
        'disponible': true,
      },
      {
        'nom': 'Menu Végétarien',
        'description': 'Plat végé + salade + fruit bio',
        'prix': '7.50€',
        'disponible': false,
      },
    ];
    
    final menu = menus[index];
    
    return Container(
      width: 180, // Augmenté pour plus d'espace
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(14), // Réduit de 16 à 14
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Ajouté pour éviter l'overflow
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
              Expanded( // Ajouté Expanded pour éviter l'overflow horizontal
                      child: Text(
                        menu['nom'] as String,
                        style: TextStyle(
                    fontSize: 14, // Réduit de 16 à 14
                    fontWeight: FontWeight.w600,
                          color: CouleursApp.texteFonce,
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Réduit
                      decoration: BoxDecoration(
                        color: (menu['disponible'] as bool) 
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (menu['disponible'] as bool) ? 'Dispo' : 'Épuisé',
                        style: TextStyle(
                    fontSize: 9, // Réduit de 10 à 9
                          color: (menu['disponible'] as bool) ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 6), // Réduit de 8 à 6
                Text(
                  menu['description'] as String,
                  style: TextStyle(
              fontSize: 11, // Réduit de 12 à 11
                    color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                  ),
            maxLines: 3, // Augmenté de 2 à 3 pour plus de flexibilité
                  overflow: TextOverflow.ellipsis,
                ),
          const Spacer(),
                Text(
                  menu['prix'] as String,
                  style: TextStyle(
              fontSize: 16, // Réduit de 18 à 16
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.principal,
            ),
          ),
        ],
      ),
    );
  }

  void _naviguerVers(String destination) {
    switch (destination) {
      case 'marketplace':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const MarketplaceEcran()),
        );
        break;
      case 'livres':
        // TODO: Implémenter la navigation vers la section échange de livres
        print('Navigation vers: $destination');
        break;
      case 'cantine':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const CantineEcran()),
        );
        break;
      case 'associations':
        // TODO: Implémenter la navigation vers la section associations
        print('Navigation vers: $destination');
        break;
      case 'profil':
        // TODO: Implémenter la navigation vers le profil
        print('Navigation vers: $destination');
        break;
      default:
        // TODO: Implémenter la navigation vers les autres sections
        print('Navigation vers: $destination');
    }
  }
} 