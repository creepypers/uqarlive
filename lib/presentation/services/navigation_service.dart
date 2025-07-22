import 'package:flutter/material.dart';
import '../screens/accueil_ecran.dart';
import '../screens/marketplace_ecran.dart';
import '../screens/cantine_ecran.dart';
import '../screens/associations_ecran.dart';
import '../screens/profil_ecran.dart';
import '../screens/salles_ecran.dart';

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
        _naviguerVers(context, const AssociationsEcran());
        break;
      case 4: // Salles
        _naviguerVers(context, const SallesEcran());
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

  /// Navigation vers les associations
  static void _naviguerVersAssociations(BuildContext context) {
    _naviguerVers(context, const AssociationsEcran());
  }

  /// Navigation vers le profil
  static void _naviguerVersProfil(BuildContext context) {
    _naviguerVers(context, const ProfilEcran());
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
      case 'AssociationsEcran':
        return 3;
      case 'SallesEcran':
        return 4;
      default:
        return 2; // Par défaut, accueil
    }
  }
} 