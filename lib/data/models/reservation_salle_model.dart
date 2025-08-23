import '../../domain/entities/reservation_salle.dart';
class ReservationSalleModel extends ReservationSalle {
  const ReservationSalleModel({
    required super.id,
    required super.utilisateurId,
    required super.salleId,
    required super.dateReservation,
    required super.heureDebut,
    required super.heureFin,
    required super.motif,
    super.description,
    required super.statut,
    required super.nombrePersonnes,
    required super.coutTotal,
    required super.dateCreation,
    super.participantsIds,
    super.notesSpeciales,
  });
  factory ReservationSalleModel.fromEntity(ReservationSalle entity) {
    return ReservationSalleModel(
      id: entity.id,
      utilisateurId: entity.utilisateurId,
      salleId: entity.salleId,
      dateReservation: entity.dateReservation,
      heureDebut: entity.heureDebut,
      heureFin: entity.heureFin,
      motif: entity.motif,
      description: entity.description,
      statut: entity.statut,
      nombrePersonnes: entity.nombrePersonnes,
      coutTotal: entity.coutTotal,
      dateCreation: entity.dateCreation,
      participantsIds: entity.participantsIds,
      notesSpeciales: entity.notesSpeciales,
    );
  }
  ReservationSalle toEntity() {
    return ReservationSalle(
      id: id,
      utilisateurId: utilisateurId,
      salleId: salleId,
      dateReservation: dateReservation,
      heureDebut: heureDebut,
      heureFin: heureFin,
      motif: motif,
      description: description,
      statut: statut,
      nombrePersonnes: nombrePersonnes,
      coutTotal: coutTotal,
      dateCreation: dateCreation,
      participantsIds: participantsIds,
      notesSpeciales: notesSpeciales,
    );
  }
  factory ReservationSalleModel.fromJson(Map<String, dynamic> json) {
    return ReservationSalleModel(
      id: json['id'],
      utilisateurId: json['utilisateurId'],
      salleId: json['salleId'],
      dateReservation: DateTime.parse(json['dateReservation']),
      heureDebut: DateTime.parse(json['heureDebut']),
      heureFin: DateTime.parse(json['heureFin']),
      motif: json['motif'],
      description: json['description'],
      statut: json['statut'],
      nombrePersonnes: json['nombrePersonnes'],
      coutTotal: json['coutTotal'].toDouble(),
      dateCreation: DateTime.parse(json['dateCreation']),
      participantsIds: List<String>.from(json['participantsIds'] ?? []),
      notesSpeciales: json['notesSpeciales'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utilisateurId': utilisateurId,
      'salleId': salleId,
      'dateReservation': dateReservation.toIso8601String(),
      'heureDebut': heureDebut.toIso8601String(),
      'heureFin': heureFin.toIso8601String(),
      'motif': motif,
      'description': description,
      'statut': statut,
      'nombrePersonnes': nombrePersonnes,
      'coutTotal': coutTotal,
      'dateCreation': dateCreation.toIso8601String(),
      'participantsIds': participantsIds,
      'notesSpeciales': notesSpeciales,
    };
  }
  @override
  ReservationSalleModel copyWith({
    String? id,
    String? utilisateurId,
    String? salleId,
    DateTime? dateReservation,
    DateTime? heureDebut,
    DateTime? heureFin,
    String? motif,
    String? description,
    String? statut,
    int? nombrePersonnes,
    double? coutTotal,
    DateTime? dateCreation,
    List<String>? participantsIds,
    String? notesSpeciales,
  }) {
    return ReservationSalleModel(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      salleId: salleId ?? this.salleId,
      dateReservation: dateReservation ?? this.dateReservation,
      heureDebut: heureDebut ?? this.heureDebut,
      heureFin: heureFin ?? this.heureFin,
      motif: motif ?? this.motif,
      description: description ?? this.description,
      statut: statut ?? this.statut,
      nombrePersonnes: nombrePersonnes ?? this.nombrePersonnes,
      coutTotal: coutTotal ?? this.coutTotal,
      dateCreation: dateCreation ?? this.dateCreation,
      participantsIds: participantsIds ?? this.participantsIds,
      notesSpeciales: notesSpeciales ?? this.notesSpeciales,
    );
  }
}