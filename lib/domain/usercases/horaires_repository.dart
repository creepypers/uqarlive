import 'package:flutter/material.dart';

// UI Design: Repository abstrait pour la gestion des horaires de cantine
abstract class HorairesRepository {
  /// Obtenir les horaires d'un jour spécifique
  Future<Map<String, TimeOfDay>> obtenirHorairesCantine(String jour);

  /// Obtenir tous les horaires de la semaine
  Future<Map<String, Map<String, TimeOfDay>>> obtenirTousLesHorairesCantine();

  /// Mettre à jour les horaires d'un jour spécifique
  Future<bool> mettreAJourHorairesCantine(String jour, TimeOfDay ouverture, TimeOfDay fermeture);

  /// Mettre à jour tous les horaires de la semaine
  Future<bool> mettreAJourTousLesHoraires(Map<String, Map<String, TimeOfDay>> horaires);

  /// Définir des horaires identiques pour tous les jours
  Future<bool> definirHorairesUniformes(TimeOfDay ouverture, TimeOfDay fermeture);

  /// Définir des horaires identiques pour les jours de semaine uniquement
  Future<bool> definirHorairesJoursSemaine(TimeOfDay ouverture, TimeOfDay fermeture);

  /// Fermer la cantine pour un jour spécifique
  Future<bool> fermerCantine(String jour);

  /// Réouvrir la cantine pour un jour spécifique
  Future<bool> reouvrir(String jour, TimeOfDay ouverture, TimeOfDay fermeture);
}