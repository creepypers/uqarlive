import '../../domain/entities/evenement.dart';
class EvenementModel {
  final String id;
  final String titre;
  final String description;
  final String typeEvenement;
  final String lieu;
  final String organisateur;
  final String associationId; // ID de l'association organisatrice
  final String dateDebut; // Format ISO String
  final String dateFin; // Format ISO String
  final bool estGratuit;
  final double? prix;
  final bool inscriptionRequise;
  final int? capaciteMaximale;
  final int nombreInscrits;
  final bool estActif;
  final String dateCreation; // Format ISO String
  const EvenementModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.typeEvenement,
    required this.lieu,
    required this.organisateur,
    required this.associationId,
    required this.dateDebut,
    required this.dateFin,
    this.estGratuit = true,
    this.prix,
    this.inscriptionRequise = false,
    this.capaciteMaximale,
    this.nombreInscrits = 0,
    this.estActif = true,
    required this.dateCreation,
  });
  factory EvenementModel.fromMap(Map<String, dynamic> map) {
    return EvenementModel(
      id: map['id'] ?? '',
      titre: map['titre'] ?? '',
      description: map['description'] ?? '',
      typeEvenement: map['typeEvenement'] ?? 'autre',
      lieu: map['lieu'] ?? '',
      organisateur: map['organisateur'] ?? '',
      associationId: map['associationId'] ?? '',
      dateDebut: map['dateDebut'] ?? '',
      dateFin: map['dateFin'] ?? '',
      estGratuit: map['estGratuit'] ?? true,
      prix: map['prix']?.toDouble(),
      inscriptionRequise: map['inscriptionRequise'] ?? false,
      capaciteMaximale: map['capaciteMaximale']?.toInt(),
      nombreInscrits: map['nombreInscrits'] ?? 0,
      estActif: map['estActif'] ?? true,
      dateCreation: map['dateCreation'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'typeEvenement': typeEvenement,
      'lieu': lieu,
      'organisateur': organisateur,
      'associationId': associationId,
      'dateDebut': dateDebut,
      'dateFin': dateFin,
      'estGratuit': estGratuit,
      'prix': prix,
      'inscriptionRequise': inscriptionRequise,
      'capaciteMaximale': capaciteMaximale,
      'nombreInscrits': nombreInscrits,
      'estActif': estActif,
      'dateCreation': dateCreation,
    };
  }
  Evenement toEntity() {
    return Evenement(
      id: id,
      titre: titre,
      description: description,
      typeEvenement: typeEvenement,
      lieu: lieu,
      organisateur: organisateur,
      associationId: associationId,
      dateDebut: DateTime.parse(dateDebut),
      dateFin: DateTime.parse(dateFin),
      estGratuit: estGratuit,
      prix: prix,
      inscriptionRequise: inscriptionRequise,
      capaciteMaximale: capaciteMaximale,
      nombreInscrits: nombreInscrits,
      estActif: estActif,
      dateCreation: DateTime.parse(dateCreation),
    );
  }
  factory EvenementModel.fromEntity(Evenement evenement) {
    return EvenementModel(
      id: evenement.id,
      titre: evenement.titre,
      description: evenement.description,
      typeEvenement: evenement.typeEvenement,
      lieu: evenement.lieu,
      organisateur: evenement.organisateur,
      associationId: evenement.associationId,
      dateDebut: evenement.dateDebut.toIso8601String(),
      dateFin: evenement.dateFin.toIso8601String(),
      estGratuit: evenement.estGratuit,
      prix: evenement.prix,
      inscriptionRequise: evenement.inscriptionRequise,
      capaciteMaximale: evenement.capaciteMaximale,
      nombreInscrits: evenement.nombreInscrits,
      estActif: evenement.estActif,
      dateCreation: evenement.dateCreation.toIso8601String(),
    );
  }
  EvenementModel copyWith({
    String? id,
    String? titre,
    String? description,
    String? typeEvenement,
    String? lieu,
    String? organisateur,
    String? associationId,
    String? dateDebut,
    String? dateFin,
    bool? estGratuit,
    double? prix,
    bool? inscriptionRequise,
    int? capaciteMaximale,
    int? nombreInscrits,
    bool? estActif,
    String? dateCreation,
  }) {
    return EvenementModel(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      typeEvenement: typeEvenement ?? this.typeEvenement,
      lieu: lieu ?? this.lieu,
      organisateur: organisateur ?? this.organisateur,
      associationId: associationId ?? this.associationId,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      estGratuit: estGratuit ?? this.estGratuit,
      prix: prix ?? this.prix,
      inscriptionRequise: inscriptionRequise ?? this.inscriptionRequise,
      capaciteMaximale: capaciteMaximale ?? this.capaciteMaximale,
      nombreInscrits: nombreInscrits ?? this.nombreInscrits,
      estActif: estActif ?? this.estActif,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }
}