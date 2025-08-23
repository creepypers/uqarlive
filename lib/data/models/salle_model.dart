import '../../domain/entities/salle.dart';
// Modèle de données pour une salle de révision
class SalleModel extends Salle {
  const SalleModel({
    required super.id,
    required super.nom,
    required super.description,
    required super.capaciteMax,
    required super.equipements,
    required super.etage,
    required super.batiment,
    required super.estDisponible,
    super.reserveePar,
    super.dateReservation,
    super.heureDebut,
    super.heureFin,
    required super.tarifParHeure,
  });
  // Conversion depuis JSON
  factory SalleModel.fromJson(Map<String, dynamic> json) {
    return SalleModel(
      id: json['id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String,
      capaciteMax: json['capaciteMax'] as int,
      equipements: List<String>.from(json['equipements'] as List),
      etage: json['etage'] as String,
      batiment: json['batiment'] as String,
      estDisponible: json['estDisponible'] as bool,
      reserveePar: json['reserveePar'] as String?,
      dateReservation: json['dateReservation'] != null 
        ? DateTime.parse(json['dateReservation'] as String)
        : null,
      heureDebut: json['heureDebut'] != null 
        ? DateTime.parse(json['heureDebut'] as String)
        : null,
      heureFin: json['heureFin'] != null 
        ? DateTime.parse(json['heureFin'] as String)
        : null,
      tarifParHeure: (json['tarifParHeure'] as num).toDouble(),
    );
  }
  // Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'capaciteMax': capaciteMax,
      'equipements': equipements,
      'etage': etage,
      'batiment': batiment,
      'estDisponible': estDisponible,
      'reserveePar': reserveePar,
      'dateReservation': dateReservation?.toIso8601String(),
      'heureDebut': heureDebut?.toIso8601String(),
      'heureFin': heureFin?.toIso8601String(),
      'tarifParHeure': tarifParHeure,
    };
  }
  // Créer une copie avec des modifications
  SalleModel copyWith({
    String? id,
    String? nom,
    String? description,
    int? capaciteMax,
    List<String>? equipements,
    String? etage,
    String? batiment,
    bool? estDisponible,
    String? reserveePar,
    DateTime? dateReservation,
    DateTime? heureDebut,
    DateTime? heureFin,
    double? tarifParHeure,
  }) {
    return SalleModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      capaciteMax: capaciteMax ?? this.capaciteMax,
      equipements: equipements ?? this.equipements,
      etage: etage ?? this.etage,
      batiment: batiment ?? this.batiment,
      estDisponible: estDisponible ?? this.estDisponible,
      reserveePar: reserveePar ?? this.reserveePar,
      dateReservation: dateReservation ?? this.dateReservation,
      heureDebut: heureDebut ?? this.heureDebut,
      heureFin: heureFin ?? this.heureFin,
      tarifParHeure: tarifParHeure ?? this.tarifParHeure,
    );
  }
} 