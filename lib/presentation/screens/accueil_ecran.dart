import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'marketplace_ecran.dart';

// UI Design: Page d'accueil UqarLife avec AppBar, sections météo/marketplace/assos/cantine et navbar
class AccueilEcran extends StatefulWidget {
  const AccueilEcran({Key? key}) : super(key: key);

  @override
  State<AccueilEcran> createState() => _AccueilEcranState();
}

class _AccueilEcranState extends State<AccueilEcran> {
  int _indexSelectionne = 2; // Index 2 car Accueil est maintenant en 3ème position

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
                // Section marketplace
                _construireSectionMarketplace(),
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
      bottomNavigationBar: _construireNavBar(),
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



  // UI Design: Section marketplace avec scrolling horizontal
  Widget _construireSectionMarketplace() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Marketplace',
              style: StylesTexteApp.titre.copyWith(fontSize: 22),
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
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return _construireCarteMarketplace(index);
            },
          ),
        ),
      ],
    );
  }

  // UI Design: Carte pour les items marketplace
  Widget _construireCarteMarketplace(int index) {
    final items = [
      {'nom': 'Livre Physique', 'prix': '25€', 'image': Icons.book},
      {'nom': 'Calculatrice', 'prix': '15€', 'image': Icons.calculate},
      {'nom': 'Notes de cours', 'prix': '10€', 'image': Icons.description},
      {'nom': 'Laptop', 'prix': '300€', 'image': Icons.laptop},
      {'nom': 'Sac à dos', 'prix': '20€', 'image': Icons.backpack},
    ];
    
    final item = items[index];
    
    return Container(
      width: 140,
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
            child: Center(
              child: Icon(
                item['image'] as IconData,
                size: 40,
                color: CouleursApp.accent,
              ),
            ),
          ),
          Padding(
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
                  item['prix'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.principal,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  // UI Design: Section cantine avec menus et prix
  Widget _construireSectionCantine() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Menus Cantine',
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
          height: 220,
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

  // UI Design: Carte pour les menus de cantine
  Widget _construireCarteMenu(int index) {
    final menus = [
      {
        'nom': 'Menu du Jour',
        'description': 'Poutine + Salade + Dessert',
        'prix': '12.50€',
        'disponible': true,
      },
      {
        'nom': 'Menu Santé',
        'description': 'Salade quinoa + Jus + Fruit',
        'prix': '9.75€',
        'disponible': true,
      },
      {
        'nom': 'Menu Végé',
        'description': 'Burger végé + Frites + Boisson',
        'prix': '11.25€',
        'disponible': false,
      },
    ];
    
    final menu = menus[index];
    
    return Container(
      width: 180,
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
            height: 80,
            decoration: BoxDecoration(
              color: CouleursApp.principal.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.restaurant_menu,
                size: 40,
                color: CouleursApp.principal,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        menu['nom'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CouleursApp.texteFonce,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (menu['disponible'] as bool) 
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (menu['disponible'] as bool) ? 'Dispo' : 'Épuisé',
                        style: TextStyle(
                          fontSize: 10,
                          color: (menu['disponible'] as bool) ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  menu['description'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  menu['prix'] as String,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.principal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: NavBar avec le même thème que la page de connexion
  Widget _construireNavBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CouleursApp.accent.withValues(alpha: 0.7), // Bleu ciel UQAR transparent
            CouleursApp.accent, // Bleu ciel UQAR
            CouleursApp.principal, // Bleu foncé UQAR
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
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Cantine',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: _construireIconeAccueil(),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Assos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // UI Design: Icône Accueil avec mise en évidence spéciale
  Widget _construireIconeAccueil() {
    final estSelectionne = _indexSelectionne == 2;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Halo de focus pour le bouton Accueil sélectionné
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
          Icons.home,
          size: estSelectionne ? 26 : 24,
          color: estSelectionne 
              ? CouleursApp.blanc 
              : CouleursApp.blanc.withValues(alpha: 0.6),
        ),
      ],
    );
  }

  void _naviguerVers(String destination) {
    switch (destination) {
      case 'marketplace':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const MarketplaceEcran()),
        );
        break;
      default:
        // TODO: Implémenter la navigation vers les autres sections
        print('Navigation vers: $destination');
    }
  }

  void _gererNavigationNavBar(int index) {
    switch (index) {
      case 0:
        _naviguerVers('cantine');
        break;
      case 1:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MarketplaceEcran()),
        );
        break;
      case 2:
        // Déjà sur l'accueil
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