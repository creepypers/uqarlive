import 'package:flutter/material.dart';
import '../../domain/repositories/horaires_repository.dart';
import '../datasources/horaires_datasource_local.dart';

// UI Design: Implémentation du repository pour les horaires de cantine
class HorairesRepositoryImpl implements HorairesRepository {
  final HorairesDatasourceLocal _datasourceLocal;

  HorairesRepositoryImpl(this._datasourceLocal);

  @override
  Future<Map<String, TimeOfDay>> obtenirHorairesCantine(String jour) async {
    try {
      return _datasourceLocal.obtenirHorairesCantine(jour);
    } catch (e) {
      throw Exception('Erreur lors du chargement des horaires pour $jour: $e');
    }
  }

  @override
  Future<Map<String, Map<String, TimeOfDay>>> obtenirTousLesHorairesCantine() async {
    try {
      return _datasourceLocal.obtenirTousLesHorairesCantine();
    } catch (e) {
      throw Exception('Erreur lors du chargement de tous les horaires: $e');
    }
  }

  @override
  Future<bool> mettreAJourHorairesCantine(String jour, TimeOfDay ouverture, TimeOfDay fermeture) async {
    try {
      await _datasourceLocal.mettreAJourHorairesCantine(jour, ouverture, fermeture);
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour des horaires pour $jour: $e');
    }
  }

  @override
  Future<bool> mettreAJourTousLesHoraires(Map<String, Map<String, TimeOfDay>> horaires) async {
    try {
      for (final entry in horaires.entries) {
        final jour = entry.key;
        final horaireJour = entry.value;
        await _datasourceLocal.mettreAJourHorairesCantine(
          jour,
          horaireJour['ouverture']!,
          horaireJour['fermeture']!,
        );
      }
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de tous les horaires: $e');
    }
  }

  @override
  Future<bool> definirHorairesUniformes(TimeOfDay ouverture, TimeOfDay fermeture) async {
    try {
      final jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
      for (final jour in jours) {
        await _datasourceLocal.mettreAJourHorairesCantine(jour, ouverture, fermeture);
      }
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la définition des horaires uniformes: $e');
    }
  }

  @override
  Future<bool> definirHorairesJoursSemaine(TimeOfDay ouverture, TimeOfDay fermeture) async {
    try {
      final joursSemaine = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'];
      for (final jour in joursSemaine) {
        await _datasourceLocal.mettreAJourHorairesCantine(jour, ouverture, fermeture);
      }
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la définition des horaires des jours de semaine: $e');
    }
  }

  @override
  Future<bool> fermerCantine(String jour) async {
    try {
      // UI Design: Définir des horaires spéciaux pour indiquer la fermeture
      await _datasourceLocal.mettreAJourHorairesCantine(
        jour,
        const TimeOfDay(hour: 0, minute: 0),
        const TimeOfDay(hour: 0, minute: 0),
      );
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la fermeture de la cantine pour $jour: $e');
    }
  }

  @override
  Future<bool> reouvrir(String jour, TimeOfDay ouverture, TimeOfDay fermeture) async {
    try {
      await _datasourceLocal.mettreAJourHorairesCantine(jour, ouverture, fermeture);
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la réouverture de la cantine pour $jour: $e');
    }
  }
}