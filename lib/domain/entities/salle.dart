// Entité représentant une salle de révision
class Salle {
  final String id;
  final String nom;
  final String description;
  final int capaciteMax;
  final List<String> equipements;
  final String etage;
  final String batiment;
  final bool estDisponible;
  final String? reserveePar;
  final DateTime? dateReservation;
  final DateTime? heureDebut;
  final DateTime? heureFin;
  final double tarifParHeure;

  const Salle({
    required this.id,
    required this.nom,
    required this.description,
    required this.capaciteMax,
    required this.equipements,
    required this.etage,
    required this.batiment,
    required this.estDisponible,
    this.reserveePar,
    this.dateReservation,
    this.heureDebut,
    this.heureFin,
    required this.tarifParHeure,
  });
} 