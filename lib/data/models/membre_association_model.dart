// UI Design: Modèle de données pour MembreAssociation
import '../../domain/entities/membre_association.dart';

class MembreAssociationModel extends MembreAssociation {
  const MembreAssociationModel({
    required super.id,
    required super.utilisateurId,
    required super.associationId,
    required super.role,
    required super.dateAdhesion,
    super.estActif,
    super.cotisationPayee,
    super.dateFinAdhesion,
    super.responsabilites,
  });

  // UI Design: Conversion depuis l'entité
  factory MembreAssociationModel.fromEntity(MembreAssociation entity) {
    return MembreAssociationModel(
      id: entity.id,
      utilisateurId: entity.utilisateurId,
      associationId: entity.associationId,
      role: entity.role,
      dateAdhesion: entity.dateAdhesion,
      estActif: entity.estActif,
      cotisationPayee: entity.cotisationPayee,
      dateFinAdhesion: entity.dateFinAdhesion,
      responsabilites: entity.responsabilites,
    );
  }

  // UI Design: Conversion vers l'entité
  MembreAssociation toEntity() {
    return MembreAssociation(
      id: id,
      utilisateurId: utilisateurId,
      associationId: associationId,
      role: role,
      dateAdhesion: dateAdhesion,
      estActif: estActif,
      cotisationPayee: cotisationPayee,
      dateFinAdhesion: dateFinAdhesion,
      responsabilites: responsabilites,
    );
  }

  // UI Design: Conversion depuis JSON
  factory MembreAssociationModel.fromJson(Map<String, dynamic> json) {
    return MembreAssociationModel(
      id: json['id'],
      utilisateurId: json['utilisateurId'],
      associationId: json['associationId'],
      role: json['role'],
      dateAdhesion: DateTime.parse(json['dateAdhesion']),
      estActif: json['estActif'] ?? true,
      cotisationPayee: json['cotisationPayee']?.toDouble(),
      dateFinAdhesion: json['dateFinAdhesion'] != null 
          ? DateTime.parse(json['dateFinAdhesion']) 
          : null,
      responsabilites: List<String>.from(json['responsabilites'] ?? []),
    );
  }

  // UI Design: Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utilisateurId': utilisateurId,
      'associationId': associationId,
      'role': role,
      'dateAdhesion': dateAdhesion.toIso8601String(),
      'estActif': estActif,
      'cotisationPayee': cotisationPayee,
      'dateFinAdhesion': dateFinAdhesion?.toIso8601String(),
      'responsabilites': responsabilites,
    };
  }

  // UI Design: Méthode copyWith
  @override
  MembreAssociationModel copyWith({
    String? id,
    String? utilisateurId,
    String? associationId,
    String? role,
    DateTime? dateAdhesion,
    bool? estActif,
    double? cotisationPayee,
    DateTime? dateFinAdhesion,
    List<String>? responsabilites,
  }) {
    return MembreAssociationModel(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      associationId: associationId ?? this.associationId,
      role: role ?? this.role,
      dateAdhesion: dateAdhesion ?? this.dateAdhesion,
      estActif: estActif ?? this.estActif,
      cotisationPayee: cotisationPayee ?? this.cotisationPayee,
      dateFinAdhesion: dateFinAdhesion ?? this.dateFinAdhesion,
      responsabilites: responsabilites ?? this.responsabilites,
    );
  }
}