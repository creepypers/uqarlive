// UI Design: Modèle de données pour DemandeAdhesion
import '../../domain/entities/demande_adhesion.dart';

class DemandeAdhesionModel extends DemandeAdhesion {
  const DemandeAdhesionModel({
    required super.id,
    required super.utilisateurId,
    required super.associationId,
    required super.statut,
    required super.dateCreation,
    super.dateReponse,
    super.messageDemande,
    super.messageReponse,
    super.chefId,
    super.roledemande = 'membre',
  });

  // UI Design: Conversion depuis l'entité
  factory DemandeAdhesionModel.fromEntity(DemandeAdhesion entity) {
    return DemandeAdhesionModel(
      id: entity.id,
      utilisateurId: entity.utilisateurId,
      associationId: entity.associationId,
      statut: entity.statut,
      dateCreation: entity.dateCreation,
      dateReponse: entity.dateReponse,
      messageDemande: entity.messageDemande,
      messageReponse: entity.messageReponse,
      chefId: entity.chefId,
      roledemande: entity.roledemande,
    );
  }

  // UI Design: Conversion vers l'entité
  DemandeAdhesion toEntity() {
    return DemandeAdhesion(
      id: id,
      utilisateurId: utilisateurId,
      associationId: associationId,
      statut: statut,
      dateCreation: dateCreation,
      dateReponse: dateReponse,
      messageDemande: messageDemande,
      messageReponse: messageReponse,
      chefId: chefId,
      roledemande: roledemande,
    );
  }

  // UI Design: Conversion depuis Map
  factory DemandeAdhesionModel.fromMap(Map<String, dynamic> map) {
    return DemandeAdhesionModel(
      id: map['id'] as String,
      utilisateurId: map['utilisateurId'] as String,
      associationId: map['associationId'] as String,
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['dateCreation'] as String),
      dateReponse: map['dateReponse'] != null 
          ? DateTime.parse(map['dateReponse'] as String) 
          : null,
      messageDemande: map['messageDemande'] as String?,
      messageReponse: map['messageReponse'] as String?,
      chefId: map['chefId'] as String?,
      roledemande: map['roledemande'] as String? ?? 'membre',
    );
  }

  // UI Design: Conversion vers Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateurId': utilisateurId,
      'associationId': associationId,
      'statut': statut,
      'dateCreation': dateCreation.toIso8601String(),
      'dateReponse': dateReponse?.toIso8601String(),
      'messageDemande': messageDemande,
      'messageReponse': messageReponse,
      'chefId': chefId,
      'roledemande': roledemande,
    };
  }

  // UI Design: Méthode copyWith
  DemandeAdhesionModel copyWith({
    String? id,
    String? utilisateurId,
    String? associationId,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateReponse,
    String? messageDemande,
    String? messageReponse,
    String? chefId,
    String? roledemande,
  }) {
    return DemandeAdhesionModel(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      associationId: associationId ?? this.associationId,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateReponse: dateReponse ?? this.dateReponse,
      messageDemande: messageDemande ?? this.messageDemande,
      messageReponse: messageReponse ?? this.messageReponse,
      chefId: chefId ?? this.chefId,
      roledemande: roledemande ?? this.roledemande,
    );
  }
}