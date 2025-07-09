import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// UI Design: NavBar réutilisable avec design UQAR et navigation centralisée
class NavBarWidget extends StatelessWidget {
  final int indexSelectionne;
  final Function(int) onTap;

  const NavBarWidget({
    Key? key,
    required this.indexSelectionne,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        currentIndex: indexSelectionne,
        onTap: onTap,
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
            icon: Icon(Icons.menu_book), // Icône livres cohérente
            label: 'Livres',
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
    final estSelectionne = indexSelectionne == 2;
    
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
} 