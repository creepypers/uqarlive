import 'package:flutter/material.dart';
class HorairesDatasourceLocal {
  // Singleton pattern
  static final HorairesDatasourceLocal _instance = HorairesDatasourceLocal._internal();
  factory HorairesDatasourceLocal() => _instance;
  HorairesDatasourceLocal._internal();
  // Horaires par défaut de la cantine
  final Map<String, Map<String, TimeOfDay>> _horairesCantine = {
    'Lundi': {
      'ouverture': const TimeOfDay(hour: 7, minute: 30),
      'fermeture': const TimeOfDay(hour: 19, minute: 0),
    },
    'Mardi': {
      'ouverture': const TimeOfDay(hour: 7, minute: 30),
      'fermeture': const TimeOfDay(hour: 19, minute: 0),
    },
    'Mercredi': {
      'ouverture': const TimeOfDay(hour: 7, minute: 30),
      'fermeture': const TimeOfDay(hour: 19, minute: 0),
    },
    'Jeudi': {
      'ouverture': const TimeOfDay(hour: 7, minute: 30),
      'fermeture': const TimeOfDay(hour: 19, minute: 0),
    },
    'Vendredi': {
      'ouverture': const TimeOfDay(hour: 7, minute: 30),
      'fermeture': const TimeOfDay(hour: 17, minute: 0),
    },
    'Samedi': {
      'ouverture': const TimeOfDay(hour: 9, minute: 0),
      'fermeture': const TimeOfDay(hour: 14, minute: 0),
    },
    'Dimanche': {
      'ouverture': const TimeOfDay(hour: 9, minute: 0),
      'fermeture': const TimeOfDay(hour: 14, minute: 0),
    },
  };
  // Horaires spéciaux (jours fériés, événements)
  final List<Map<String, dynamic>> _horairesSpeciaux = [
    {
      'date': DateTime(2024, 1, 1),
      'nom': 'Jour de l\'An',
      'estFerme': true,
    },
    {
      'date': DateTime(2024, 4, 1),
      'nom': 'Pâques',
      'estFerme': true,
    },
    // Ajoutez d'autres horaires spéciaux ici
  ];
  // Obtenir les horaires de la cantine pour un jour spécifique
  Map<String, TimeOfDay> obtenirHorairesCantine(String jour) {
    return _horairesCantine[jour] ?? {
      'ouverture': const TimeOfDay(hour: 9, minute: 0),
      'fermeture': const TimeOfDay(hour: 17, minute: 0),
    };
  }
  // Obtenir tous les horaires de la cantine
  Map<String, Map<String, TimeOfDay>> obtenirTousLesHorairesCantine() {
    return _horairesCantine;
  }
  // Mettre à jour les horaires de la cantine
  Future<void> mettreAJourHorairesCantine(
    String jour,
    TimeOfDay heureOuverture,
    TimeOfDay heureFermeture,
  ) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));
    _horairesCantine[jour] = {
      'ouverture': heureOuverture,
      'fermeture': heureFermeture,
    };
  }
  // Vérifier si la cantine est ouverte à un moment donné
  bool estCantineOuverte({DateTime? dateVerification}) {
    final maintenant = dateVerification ?? DateTime.now();
    final jourSemaine = _obtenirJourSemaine(maintenant);
    // Vérifier les horaires spéciaux d'abord
    for (var horaire in _horairesSpeciaux) {
      if (_memeJour(horaire['date'], maintenant)) {
        return !horaire['estFerme'];
      }
    }
    // Vérifier les horaires normaux
    final horairesJour = obtenirHorairesCantine(jourSemaine);
    final heureActuelle = TimeOfDay.fromDateTime(maintenant);
    return _estHeureDansIntervalle(
      heureActuelle,
      horairesJour['ouverture']!,
      horairesJour['fermeture']!,
    );
  }
  // Helpers
  String _obtenirJourSemaine(DateTime date) {
    const jours = [
      'Dimanche',
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
    ];
    return jours[date.weekday % 7];
  }
  bool _memeJour(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  bool _estHeureDansIntervalle(
    TimeOfDay heure,
    TimeOfDay debut,
    TimeOfDay fin,
  ) {
    final heureEnMinutes = heure.hour * 60 + heure.minute;
    final debutEnMinutes = debut.hour * 60 + debut.minute;
    final finEnMinutes = fin.hour * 60 + fin.minute;
    return heureEnMinutes >= debutEnMinutes && heureEnMinutes <= finEnMinutes;
  }
  // Obtenir le statut actuel formaté
  String obtenirStatutCantineFormatte() {
    if (estCantineOuverte()) {
      final maintenant = DateTime.now();
      final jourSemaine = _obtenirJourSemaine(maintenant);
      final horaires = obtenirHorairesCantine(jourSemaine);
      return 'Ouvert jusqu\'à ${_formatterHeure(horaires['fermeture']!)}';
    } else {
      return 'Fermé';
    }
  }
  String _formatterHeure(TimeOfDay heure) {
    final minute = heure.minute.toString().padLeft(2, '0');
    return '${heure.hour}h$minute';
  }
} 