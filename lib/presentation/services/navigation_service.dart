import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../screens/accueil_ecran.dart';
import '../screens/marketplace_ecran.dart';
import '../screens/cantine_ecran.dart';

// UI Design: Service de navigation centralisé pour éviter la duplication
class NavigationService {
  
  /// Gérer la navigation de la NavBar
  static void gererNavigationNavBar(BuildContext context, int index) {
    switch (index) {
      case 0: // Cantine
        _naviguerVers(context, const CantineEcran());
        break;
      case 1: // Livres (Marketplace)
        _naviguerVers(context, const MarketplaceEcran());
        break;
      case 2: // Accueil
        _naviguerVersAccueil(context);
        break;
      case 3: // Associations
        _naviguerVersAssociations(context);
        break;
      case 4: // Profil
        _naviguerVersProfil(context);
        break;
    }
  }

  /// Navigation vers une page avec remplacement (pour éviter accumulation)
  static void _naviguerVers(BuildContext context, Widget destination) {
    // Vérifier si on est déjà sur la page cible
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final targetRoute = destination.runtimeType.toString();
    
    if (currentRoute != targetRoute) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => destination),
      );
    }
  }

  /// Navigation vers l'accueil
  static void _naviguerVersAccueil(BuildContext context) {
    // Si on est déjà sur l'accueil, ne rien faire
    final currentWidget = context.widget;
    if (currentWidget.runtimeType.toString() == 'AccueilEcran') {
      return;
    }
    
    // Sinon, naviguer vers l'accueil
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AccueilEcran()),
      (route) => false, // Supprime toutes les routes précédentes
    );
  }

  /// Navigation vers les associations (à implémenter)
  static void _naviguerVersAssociations(BuildContext context) {
    // TODO: Implémenter la page associations
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Page Associations - À venir'),
        backgroundColor: CouleursApp.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Navigation vers le profil (à implémenter)
  static void _naviguerVersProfil(BuildContext context) {
    // TODO: Implémenter la page profil
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Page Profil - À venir'),
        backgroundColor: CouleursApp.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Obtenir l'index de la NavBar selon la page courante
  static int obtenirIndexCourant(BuildContext context) {
    final currentWidget = context.widget;
    final widgetType = currentWidget.runtimeType.toString();
    
    switch (widgetType) {
      case 'CantineEcran':
        return 0;
      case 'MarketplaceEcran':
        return 1;
      case 'AccueilEcran':
        return 2;
      // Pour les pages associations et profil quand elles existeront
      default:
        return 2; // Par défaut, accueil
    }
  }
} 