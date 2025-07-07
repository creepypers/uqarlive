import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'accueil_ecran.dart';

// UI Design: Page marketplace UqarLive avec filtres et grille d'items
class MarketplaceEcran extends StatefulWidget {
  const MarketplaceEcran({Key? key}) : super(key: key);

  @override
  State<MarketplaceEcran> createState() => _MarketplaceEcranState();
}

class _MarketplaceEcranState extends State<MarketplaceEcran> {
  int _indexSelectionne = 1; // Index 1 car Marketplace est en 2ème position
  String _categorieSelectionnee = 'Tous';
  String _filtreEtat = 'Tous';
  String _filtrePrix = 'Tous';

  final List<String> _categories = [
    'Tous', 'Livres', 'Électronique', 'Vêtements', 'Fournitures', 'Sport'
  ];

  final List<String> _etats = ['Tous', 'Neuf', 'Très bon', 'Bon', 'Acceptable'];
  final List<String> _prix = ['Tous', '< 10€', '10-25€', '25-50€', '> 50€'];

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
                
                // Statistiques marketplace
                _construireStatistiques(),
                const SizedBox(height: 24),
                
                // Grille d'items
                _construireGrilleItems(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _construireNavBar(),
    );
  }

  // UI Design: AppBar avec bienvenue utilisateur - même style que accueil
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
            // Section titre marketplace
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Marketplace',
                    style: TextStyle(
                      color: CouleursApp.blanc.withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Livres & Échanges',
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

  // UI Design: Section filtres avec chips pour catégories et dropdowns
  Widget _construireSectionFiltres() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres',
          style: StylesTexteApp.titre.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),
        
        // Filtres par catégorie (chips horizontaux)
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final categorie = _categories[index];
              final estSelectionne = _categorieSelectionnee == categorie;
              
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  selected: estSelectionne,
                  label: Text(
                    categorie,
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
                      _categorieSelectionnee = categorie;
                    });
                  },
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Filtres état et prix
        Row(
          children: [
            Expanded(
              child: _construireDropdownFiltre(
                'État',
                _filtreEtat,
                _etats,
                (valeur) => setState(() => _filtreEtat = valeur!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _construireDropdownFiltre(
                'Prix',
                _filtrePrix,
                _prix,
                (valeur) => setState(() => _filtrePrix = valeur!),
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

  // UI Design: Statistiques marketplace avec compteurs
  Widget _construireStatistiques() {
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
          _construireStatItem('156', 'Articles\ndisponibles', Icons.inventory),
          Container(
            height: 40,
            width: 1,
            color: CouleursApp.principal.withValues(alpha: 0.3),
          ),
          _construireStatItem('42', 'Échanges\nce mois', Icons.swap_horiz),
          Container(
            height: 40,
            width: 1,
            color: CouleursApp.principal.withValues(alpha: 0.3),
          ),
          _construireStatItem('89', 'Vendeurs\nactifs', Icons.people),
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

  // UI Design: Grille d'items marketplace
  Widget _construireGrilleItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Articles Récents',
              style: StylesTexteApp.titre.copyWith(fontSize: 22),
            ),
            Text(
              '${_obtenirItemsFiltres().length} résultats',
              style: TextStyle(
                color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: _obtenirItemsFiltres().length,
          itemBuilder: (context, index) {
            return _construireCarteItem(_obtenirItemsFiltres()[index]);
          },
        ),
      ],
    );
  }

  // UI Design: Carte d'item marketplace
  Widget _construireCarteItem(Map<String, dynamic> item) {
    return Container(
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
          // Image de l'item
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
                      item['icone'] as IconData,
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
                        color: _getCouleurEtat(item['etat'] as String),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item['etat'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Informations de l'item
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['nom'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CouleursApp.texteFonce,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['vendeur'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['prix'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CouleursApp.principal,
                        ),
                      ),
                      if (item['type'] == 'echange')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Échange',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
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
    );
  }

  // UI Design: NavBar avec même thème que l'accueil
  Widget _construireNavBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CouleursApp.accent.withValues(alpha: 0.7),
            CouleursApp.accent,
            CouleursApp.principal,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _indexSelectionne,
        onTap: (index) {
          setState(() {
            _indexSelectionne = index;
          });
          _gererNavigationNavBar(index);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: CouleursApp.blanc,
        unselectedItemColor: CouleursApp.blanc.withValues(alpha: 0.6),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          shadows: [
            Shadow(
              offset: Offset(0, 1),
              blurRadius: 2,
              color: Colors.black26,
            ),
          ],
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Cantine',
          ),
          BottomNavigationBarItem(
            icon: _construireIconeMarketplace(),
            label: 'Marketplace',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Assos',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // UI Design: Icône Marketplace avec mise en évidence spéciale
  Widget _construireIconeMarketplace() {
    final estSelectionne = _indexSelectionne == 1;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Halo de focus pour le bouton Marketplace sélectionné
        if (estSelectionne)
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: CouleursApp.blanc.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          ),
        // Icône principale
        Icon(
          Icons.storefront,
          size: estSelectionne ? 26 : 24,
          color: estSelectionne 
              ? CouleursApp.blanc 
              : CouleursApp.blanc.withValues(alpha: 0.6),
        ),
      ],
    );
  }

  // Données des items marketplace
  List<Map<String, dynamic>> _obtenirTousLesItems() {
    return [
      {
        'nom': 'Physique Université Tome 1',
        'prix': '45€',
        'vendeur': 'Marie L.',
        'categorie': 'Livres',
        'etat': 'Très bon',
        'type': 'vente',
        'icone': Icons.book,
      },
      {
        'nom': 'MacBook Pro 13" 2019',
        'prix': '800€',
        'vendeur': 'Pierre M.',
        'categorie': 'Électronique',
        'etat': 'Bon',
        'type': 'vente',
        'icone': Icons.laptop_mac,
      },
      {
        'nom': 'Calculatrice TI-84',
        'prix': 'Échange',
        'vendeur': 'Sarah B.',
        'categorie': 'Fournitures',
        'etat': 'Neuf',
        'type': 'echange',
        'icone': Icons.calculate,
      },
      {
        'nom': 'Manteau d\'hiver North Face',
        'prix': '120€',
        'vendeur': 'Alex D.',
        'categorie': 'Vêtements',
        'etat': 'Très bon',
        'type': 'vente',
        'icone': Icons.checkroom,
      },
      {
        'nom': 'Notes Mathématiques',
        'prix': '15€',
        'vendeur': 'Julie R.',
        'categorie': 'Livres',
        'etat': 'Bon',
        'type': 'vente',
        'icone': Icons.description,
      },
      {
        'nom': 'Raquette de Tennis',
        'prix': '35€',
        'vendeur': 'Marc T.',
        'categorie': 'Sport',
        'etat': 'Bon',
        'type': 'vente',
        'icone': Icons.sports_tennis,
      },
      {
        'nom': 'Sac à dos Jansport',
        'prix': '25€',
        'vendeur': 'Emma S.',
        'categorie': 'Fournitures',
        'etat': 'Très bon',
        'type': 'vente',
        'icone': Icons.backpack,
      },
      {
        'nom': 'Chimie Organique',
        'prix': 'Échange',
        'vendeur': 'Tom L.',
        'categorie': 'Livres',
        'etat': 'Acceptable',
        'type': 'echange',
        'icone': Icons.science,
      },
    ];
  }

  // Filtrage des items selon les critères sélectionnés
  List<Map<String, dynamic>> _obtenirItemsFiltres() {
    List<Map<String, dynamic>> items = _obtenirTousLesItems();
    
    // Filtre par catégorie
    if (_categorieSelectionnee != 'Tous') {
      items = items.where((item) => item['categorie'] == _categorieSelectionnee).toList();
    }
    
    // Filtre par état
    if (_filtreEtat != 'Tous') {
      items = items.where((item) => item['etat'] == _filtreEtat).toList();
    }
    
    // Filtre par prix (simplifié pour la démo)
    if (_filtrePrix != 'Tous') {
      // Logique de filtrage par prix pourrait être implémentée ici
    }
    
    return items;
  }

  // Couleur selon l'état de l'item
  Color _getCouleurEtat(String etat) {
    switch (etat) {
      case 'Neuf':
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

  void _naviguerVers(String destination) {
    print('Navigation vers: $destination');
  }

  void _gererNavigationNavBar(int index) {
    switch (index) {
      case 0:
        _naviguerVers('cantine');
        break;
      case 1:
        // Déjà sur marketplace
        break;
      case 2:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AccueilEcran()),
        );
        break;
      case 3:
        _naviguerVers('associations');
        break;
      case 4:
        _naviguerVers('profil');
        break;
    }
  }
} 