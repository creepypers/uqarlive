import 'package:flutter/material.dart';

// UI Design: Source de données locale unifiée pour tous les horaires
class HorairesDatasourceLocal {
  
  // UI Design: Horaires de la cantine par défaut
  static const Map<String, Map<String, String>> _horairesCantineParDefaut = {
    'Lundi': {'ouverture': '11:30', 'fermeture': '13:30'},
    'Mardi': {'ouverture': '11:30', 'fermeture': '13:30'},
    'Mercredi': {'ouverture': '11:30', 'fermeture': '13:30'},
    'Jeudi': {'ouverture': '11:30', 'fermeture': '13:30'},
    'Vendredi': {'ouverture': '11:30', 'fermeture': '13:30'},
    'Samedi': {'ouverture': 'Fermé', 'fermeture': ''},
    'Dimanche': {'ouverture': 'Fermé', 'fermeture': ''},
  };

  // UI Design: Horaires des salles (heures disponibles)
  static const Map<String, int> _configurationSalles = {
    'heureDebut': 8,        // 8h00
    'heureFin': 19,         // 19h00
    'dureeSlot': 1,         // 1 heure par slot
  };

  // UI Design: Stockage modifiable des horaires
  Map<String, Map<String, String>> _horairesCantineActuels = Map.from(_horairesCantineParDefaut);
  Map<String, List<int>> _heuresOccupeesSalles = {}; // salleId -> liste heures occupées

  // ==================== HORAIRES CANTINE ====================

  // Obtenir les horaires de la cantine
  Future<Map<String, Map<String, String>>> obtenirHorairesCantine() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return Map.from(_horairesCantineActuels);
  }

  // Modifier les horaires d'un jour spécifique pour la cantine
  Future<bool> modifierHoraireCantineJour(String jour, String ouverture, String fermeture) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (_horairesCantineActuels.containsKey(jour)) {
      _horairesCantineActuels[jour] = {
        'ouverture': ouverture,
        'fermeture': fermeture,
      };
      return true;
    }
    return false;
  }

  // Modifier tous les horaires de la cantine
  Future<bool> modifierTousLesHorairesCantine(Map<String, Map<String, String>> nouveauxHoraires) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    _horairesCantineActuels = Map.from(nouveauxHoraires);
    return true;
  }

  // Réinitialiser aux horaires par défaut de la cantine
  Future<bool> reinitialiserHorairesCantine() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    _horairesCantineActuels = Map.from(_horairesCantineParDefaut);
    return true;
  }

  // Vérifier si la cantine est ouverte à un moment donné
  bool estCantineOuverte(String jour, String heure) {
    final horaire = _horairesCantineActuels[jour];
    if (horaire == null || horaire['ouverture'] == 'Fermé') {
      return false;
    }
    
    // Pour la démo, simulation simple - en production, parser les heures
    return true; // Simplification pour la démo
  }

  // Obtenir le prochain créneau d'ouverture de la cantine
  String obtenirProchainCreneauOuvertureCantine() {
    // Simulation - en production, calculer vraiment
    return 'Demain 11:30';
  }

  // ==================== HORAIRES SALLES ====================

  // Générer les heures disponibles pour les salles
  List<Map<String, dynamic>> genererHeuresDisponiblesSalles() {
    final heureDebut = _configurationSalles['heureDebut']!;
    final heureFin = _configurationSalles['heureFin']!;
    final nombreHeures = heureFin - heureDebut;
    
    return List.generate(nombreHeures, (index) {
      final heure = heureDebut + index;
      return {
        'heure': '${heure}h',
        'valeur': heure,
        'disponible': heure != 12 && heure != 16, // 12h et 16h occupées par défaut
      };
    });
  }

  // Obtenir les heures occupées pour une salle spécifique
  Future<List<int>> obtenirHeuresOccupeesSalle(String salleId, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    // Vérifier le cache d'abord
    final cacheKey = '${salleId}_${date.toIso8601String().split('T')[0]}';
    if (_heuresOccupeesSalles.containsKey(cacheKey)) {
      return _heuresOccupeesSalles[cacheKey]!;
    }
    
    // Simulation des heures occupées par salle
    List<int> heuresOccupees;
    switch (salleId) {
      case '1': // Salle de conférence A
        heuresOccupees = [9, 14, 16]; // 9h, 14h, 16h occupées
        break;
      case '2': // Laboratoire informatique
        heuresOccupees = [10, 11, 15]; // 10h, 11h, 15h occupées
        break;
      case '3': // Salle de réunion B
        heuresOccupees = [12, 13]; // 12h, 13h occupées
        break;
      case '4': // Amphithéâtre
        heuresOccupees = [8, 9, 17, 18]; // 8h, 9h, 17h, 18h occupées
        break;
      default:
        heuresOccupees = [12, 16]; // Horaires par défaut occupés
    }
    
    // Mettre en cache
    _heuresOccupeesSalles[cacheKey] = heuresOccupees;
    return heuresOccupees;
  }

  // Vérifier la disponibilité d'une heure spécifique pour une salle
  Future<bool> estHeureSalleDisponible(String salleId, DateTime date, int heure) async {
    final heuresOccupees = await obtenirHeuresOccupeesSalle(salleId, date);
    return !heuresOccupees.contains(heure);
  }

  // Réserver une heure pour une salle
  Future<bool> reserverHeureSalle(String salleId, DateTime date, int heure, String utilisateurId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Vérifier la disponibilité
    final disponible = await estHeureSalleDisponible(salleId, date, heure);
    if (disponible) {
      // Ajouter l'heure aux heures occupées
      final cacheKey = '${salleId}_${date.toIso8601String().split('T')[0]}';
      final heuresOccupees = await obtenirHeuresOccupeesSalle(salleId, date);
      heuresOccupees.add(heure);
      _heuresOccupeesSalles[cacheKey] = heuresOccupees;
      
      return true;
    }
    return false;
  }

  // Annuler une réservation d'heure pour une salle
  Future<bool> annulerReservationHeureSalle(String salleId, DateTime date, int heure) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final cacheKey = '${salleId}_${date.toIso8601String().split('T')[0]}';
    if (_heuresOccupeesSalles.containsKey(cacheKey)) {
      _heuresOccupeesSalles[cacheKey]?.remove(heure);
      return true;
    }
    return false;
  }

  // Obtenir les créneaux libres consécutifs pour une salle
  Future<List<Map<String, dynamic>>> obtenirCreneauxLibresSalle(String salleId, DateTime date, int dureeMinimum) async {
    final heuresOccupees = await obtenirHeuresOccupeesSalle(salleId, date);
    final heureDebut = _configurationSalles['heureDebut']!;
    final heureFin = _configurationSalles['heureFin']!;
    final toutesLesHeures = List.generate(heureFin - heureDebut, (index) => heureDebut + index);
    
    List<Map<String, dynamic>> creneauxLibres = [];
    List<int> creneauActuel = [];
    
    for (int heure in toutesLesHeures) {
      if (!heuresOccupees.contains(heure)) {
        creneauActuel.add(heure);
      } else {
        if (creneauActuel.length >= dureeMinimum) {
          creneauxLibres.add({
            'debut': creneauActuel.first,
            'fin': creneauActuel.last,
            'duree': creneauActuel.length,
            'heures': List.from(creneauActuel),
          });
        }
        creneauActuel.clear();
      }
    }
    
    // Vérifier le dernier créneau
    if (creneauActuel.length >= dureeMinimum) {
      creneauxLibres.add({
        'debut': creneauActuel.first,
        'fin': creneauActuel.last,
        'duree': creneauActuel.length,
        'heures': List.from(creneauActuel),
      });
    }
    
    return creneauxLibres;
  }

  // ==================== MÉTHODES UTILITAIRES ====================

  // Obtenir la configuration des horaires des salles
  Map<String, int> obtenirConfigurationSalles() {
    return Map.from(_configurationSalles);
  }

  // Mettre à jour la configuration des horaires des salles
  Future<bool> mettreAJourConfigurationSalles(Map<String, int> nouvelleConfig) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Validation basique
    if (nouvelleConfig['heureDebut'] != null && 
        nouvelleConfig['heureFin'] != null &&
        nouvelleConfig['heureDebut']! < nouvelleConfig['heureFin']!) {
      
      // En production, sauvegarder la nouvelle configuration
      return true;
    }
    return false;
  }

  // Obtenir le statut global des horaires
  Future<Map<String, dynamic>> obtenirStatutGlobalHoraires() async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final maintenant = DateTime.now();
    final jourActuel = _obtenirJourSemaine(maintenant.weekday);
    final heureActuelle = TimeOfDay.now();
    
    return {
      'cantine': {
        'estOuverte': estCantineOuverte(jourActuel, '${heureActuelle.hour}:${heureActuelle.minute}'),
        'prochaineCreneau': obtenirProchainCreneauOuvertureCantine(),
      },
      'salles': {
        'nombreSallesDisponibles': 4, // Simulation
        'prochainCreneauLibre': '${heureActuelle.hour + 1}h00',
      },
      'derniereMiseAJour': maintenant.toIso8601String(),
    };
  }

  // Méthode utilitaire pour obtenir le jour de la semaine
  String _obtenirJourSemaine(int weekday) {
    const jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return jours[weekday - 1];
  }
} 