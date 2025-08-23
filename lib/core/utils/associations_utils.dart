import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
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
class LivresUtils {
  /// Obtenir l'icône selon la matière du livre
  static IconData obtenirIconeMatiere(String matiere) {
    switch (matiere.toLowerCase()) {
      case 'mathématiques':
      case 'maths':
        return Icons.functions;
      case 'physique':
        return Icons.science;
      case 'chimie':
        return Icons.science_outlined;
      case 'biologie':
        return Icons.biotech;
      case 'informatique':
        return Icons.computer;
      case 'économie':
        return Icons.trending_up;
      case 'histoire':
        return Icons.history_edu;
      case 'littérature':
        return Icons.book;
      case 'philosophie':
        return Icons.psychology;
      default:
        return Icons.school;
    }
  }
  /// Obtenir la couleur selon la matière du livre
  static Color obtenirCouleurMatiere(String matiere) {
    switch (matiere.toLowerCase()) {
      case 'mathématiques':
      case 'maths':
        return const Color(0xFFE91E63); // Rose
      case 'physique':
        return const Color(0xFF9C27B0); // Violet
      case 'chimie':
        return const Color(0xFF673AB7); // Violet foncé
      case 'biologie':
        return const Color(0xFF4CAF50); // Vert
      case 'informatique':
        return const Color(0xFF2196F3); // Bleu
      case 'économie':
        return const Color(0xFFFF9800); // Orange
      case 'histoire':
        return const Color(0xFF795548); // Marron
      case 'littérature':
        return const Color(0xFF607D8B); // Bleu gris
      case 'philosophie':
        return const Color(0xFF9E9E9E); // Gris
      default:
        return CouleursApp.principal;
    }
  }
  /// Obtenir le nom lisible de la matière
  static String obtenirNomMatiere(String matiere) {
    switch (matiere.toLowerCase()) {
      case 'mathématiques':
      case 'maths':
        return 'Mathématiques';
      case 'physique':
        return 'Physique';
      case 'chimie':
        return 'Chimie';
      case 'biologie':
        return 'Biologie';
      case 'informatique':
        return 'Informatique';
      case 'économie':
        return 'Économie';
      case 'histoire':
        return 'Histoire';
      case 'littérature':
        return 'Littérature';
      case 'philosophie':
        return 'Philosophie';
      default:
        return matiere;
    }
  }
  /// Obtenir la couleur selon l'état du livre
  static Color obtenirCouleurEtat(String etat) {
    switch (etat.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'très bon':
      case 'tres bon':
        return Colors.lightGreen;
      case 'bon':
        return Colors.orange;
      case 'acceptable':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  /// Obtenir l'icône selon l'état du livre
  static IconData obtenirIconeEtat(String etat) {
    switch (etat.toLowerCase()) {
      case 'excellent':
        return Icons.star;
      case 'très bon':
      case 'tres bon':
        return Icons.star_half;
      case 'bon':
        return Icons.star_border;
      case 'acceptable':
        return Icons.star_outline;
      default:
        return Icons.star_border;
    }
  }
  /// Liste complète des matières disponibles pour les livres
  static const List<String> matieresDisponibles = [
    'Mathématiques',
    'Physique',
    'Chimie',
    'Biologie',
    'Informatique',
    'Économie',
    'Histoire',
    'Littérature',
    'Philosophie',
    'Statistiques',
    'Autres'
  ];
  /// Liste complète des années d'étude disponibles
  static const List<String> anneesEtudeDisponibles = [
    '1ère année',
    '2ème année',
    '3ème année',
    '4ème année',
    'Maîtrise',
    'Doctorat'
  ];
  /// Obtenir l'icône selon l'année d'étude
  static IconData obtenirIconeAnnee(String annee) {
    if (annee.contains('1ère') || annee.contains('1ere')) {
      return Icons.looks_one;
    } else if (annee.contains('2ème') || annee.contains('2eme')) {
      return Icons.looks_two;
    } else if (annee.contains('3ème') || annee.contains('3eme')) {
      return Icons.looks_3;
    } else if (annee.contains('4ème') || annee.contains('4eme')) {
      return Icons.looks_4;
    } else if (annee.contains('Maîtrise') || annee.contains('Maitrise')) {
      return Icons.school;
    } else if (annee.contains('Doctorat')) {
      return Icons.psychology;
    }
    return Icons.grade;
  }
  /// Obtenir la couleur selon l'année d'étude
  static Color obtenirCouleurAnnee(String annee) {
    if (annee.contains('1ère') || annee.contains('1ere')) {
      return const Color(0xFFE91E63); // Rose
    } else if (annee.contains('2ème') || annee.contains('2eme')) {
      return const Color(0xFF9C27B0); // Violet
    } else if (annee.contains('3ème') || annee.contains('3eme')) {
      return const Color(0xFF673AB7); // Violet foncé
    } else if (annee.contains('4ème') || annee.contains('4eme')) {
      return const Color(0xFF3F51B5); // Indigo
    } else if (annee.contains('Maîtrise') || annee.contains('Maitrise')) {
      return const Color(0xFF2196F3); // Bleu
    } else if (annee.contains('Doctorat')) {
      return const Color(0xFF00BCD4); // Cyan
    }
    return CouleursApp.accent;
  }
}
class TransactionsUtils {
  /// Obtenir la couleur selon le statut de la transaction
  static Color obtenirCouleurStatut(String statut) {
    switch (statut.toLowerCase()) {
      case 'en_attente':
        return Colors.orange;
      case 'confirmee':
        return CouleursApp.accent;
      case 'en_cours':
        return CouleursApp.principal;
      case 'terminee':
      case 'completee':
        return Colors.green;
      case 'annulee':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  /// Obtenir le texte lisible du statut
  static String obtenirTexteStatut(String statut) {
    switch (statut.toLowerCase()) {
      case 'en_attente':
        return 'En attente';
      case 'confirmee':
        return 'Confirmée';
      case 'en_cours':
        return 'En cours';
      case 'terminee':
      case 'completee':
        return 'Terminée';
      case 'annulee':
        return 'Annulée';
      default:
        return statut;
    }
  }
  /// Obtenir l'icône selon le statut de la transaction
  static IconData obtenirIconeStatut(String statut) {
    switch (statut.toLowerCase()) {
      case 'en_attente':
        return Icons.schedule;
      case 'confirmee':
        return Icons.check_circle;
      case 'en_cours':
        return Icons.sync;
      case 'terminee':
      case 'completee':
        return Icons.done_all;
      case 'annulee':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
  /// Formater une date pour l'affichage
  static String formaterDate(DateTime date) {
    final maintenant = DateTime.now();
    final difference = maintenant.difference(date);
    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'À l\'instant';
    }
  }
  /// Formater une date complète
  static String formaterDateComplete(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  /// Obtenir les initiales d'un utilisateur
  static String obtenirInitialesUtilisateur(String? utilisateurId) {
    if (utilisateurId == null) return '?';
    // IDs connus pour les tests
    final idsConnus = {
      'etud_001': 'AM', // Alexandre Martin
      'etud_002': 'SG', // Sophie Gagnon
      'etud_003': 'SB', // Sarah Bouchard
      'etud_004': 'MT', // Marie-Claude Tremblay
      'etud_005': 'JD', // Jean-François Dubois
      'etud_006': 'EL', // Émilie Lavoie
      'etud_007': 'PM', // Pierre Moreau
      'etud_008': 'IR', // Isabelle Roy
      'etud_009': 'MG', // Marc-André Gagnon
      'etud_010': 'SD', // Sophie Deschamps
      'etud_011': 'NB', // Nicolas Bouchard
      'admin_001': 'AD', // Admin
      'mod_001': 'MO', // Modérateur
    };
    return idsConnus[utilisateurId] ?? 
           (utilisateurId.length >= 2 ? utilisateurId.substring(0, 2).toUpperCase() : utilisateurId.toUpperCase());
  }
}