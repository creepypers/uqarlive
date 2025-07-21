import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// UI Design: Utilitaires centralisés pour les associations UQAR
class AssociationsUtils {
  
  /// Obtenir l'icône selon le type d'association
  static IconData obtenirIconeType(String type) {
    switch (type) {
      case 'etudiante':
        return Icons.groups;
      case 'culturelle':
        return Icons.palette;
      case 'sportive':
        return Icons.sports_soccer;
      case 'academique':
        return Icons.school;
      default:
        return Icons.groups;
    }
  }

  /// Obtenir la couleur selon le type d'association
  static Color obtenirCouleurType(String type) {
    switch (type) {
      case 'etudiante':
        return CouleursApp.principal; // Bleu UQAR
      case 'culturelle':
        return const Color(0xFFFF6B6B); // Rouge culture
      case 'sportive':
        return const Color(0xFF4ECDC4); // Vert sport
      case 'academique':
        return const Color(0xFF45B7D1); // Bleu académique
      default:
        return CouleursApp.principal;
    }
  }

  /// Obtenir le nom lisible du type d'association
  static String obtenirNomType(String type) {
    switch (type) {
      case 'etudiante':
        return 'Étudiante';
      case 'culturelle':
        return 'Culturelle';
      case 'sportive':
        return 'Sportive';
      case 'academique':
        return 'Académique';
      default:
        return 'Autre';
    }
  }
} 