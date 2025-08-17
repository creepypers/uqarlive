// Entité représentant les horaires d'ouverture
class Horaire {
  final String jour;
  final Map<String, PlageHoraire> periodes;
  final bool estOuvert;

  const Horaire({
    required this.jour,
    required this.periodes,
    required this.estOuvert,
  });

  // Copier avec modifications
  Horaire copyWith({
    String? jour,
    Map<String, PlageHoraire>? periodes,
    bool? estOuvert,
  }) {
    return Horaire(
      jour: jour ?? this.jour,
      periodes: periodes ?? this.periodes,
      estOuvert: estOuvert ?? this.estOuvert,
    );
  }
}

// Value object pour une plage horaire
class PlageHoraire {
  final String debut;
  final String fin;

  const PlageHoraire({
    required this.debut,
    required this.fin,
  });

  // Copier avec modifications
  PlageHoraire copyWith({
    String? debut,
    String? fin,
  }) {
    return PlageHoraire(
      debut: debut ?? this.debut,
      fin: fin ?? this.fin,
    );
  }
} 