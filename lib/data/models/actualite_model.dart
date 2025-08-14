import '../../domain/entities/actualite.dart';

// UI Design: Modèle pour mapper les données d'actualité depuis/vers la source de données
class ActualiteModel {
  final String id;
  final String titre;
  final String description;
  final String contenu;
  final String associationId; // ID de l'association qui publie l'actualité
  final String auteur;
  final String datePublication; // Format ISO String
  final String? dateEvenement; // Format ISO String
  final String? imageUrl;
  final List<String> tags;
  final String priorite;
  final bool estEpinglee;
  final int nombreVues;
  final int nombreLikes;

  const ActualiteModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.contenu,
    required this.associationId,
    required this.auteur,
    required this.datePublication,
    this.dateEvenement,
    this.imageUrl,
    this.tags = const [],
    required this.priorite,
    required this.estEpinglee,
    required this.nombreVues,
    required this.nombreLikes,
  });

  // UI Design: Conversion depuis Map (JSON)
  factory ActualiteModel.fromMap(Map<String, dynamic> map) {
    return ActualiteModel(
      id: map['id'] ?? '',
      titre: map['titre'] ?? '',
      description: map['description'] ?? '',
      contenu: map['contenu'] ?? '',
      associationId: map['associationId'] ?? map['nomAssociation'] ?? '', // Support des deux formats
      auteur: map['auteur'] ?? '',
      datePublication: map['datePublication'] ?? '',
      dateEvenement: map['dateEvenement'],
      imageUrl: map['imageUrl'],
      tags: List<String>.from(map['tags'] ?? []),
      priorite: map['priorite'] ?? 'normale',
      estEpinglee: map['estEpinglee'] ?? false,
      nombreVues: map['nombreVues'] ?? 0,
      nombreLikes: map['nombreLikes'] ?? 0,
    );
  }

  // UI Design: Conversion vers Map (JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'contenu': contenu,
      'associationId': associationId,
      'auteur': auteur,
      'datePublication': datePublication,
      'dateEvenement': dateEvenement,
      'imageUrl': imageUrl,
      'tags': tags,
      'priorite': priorite,
      'estEpinglee': estEpinglee,
      'nombreVues': nombreVues,
      'nombreLikes': nombreLikes,
    };
  }

  // UI Design: Conversion vers entité
  Actualite toEntity() {
    return Actualite(
      id: id,
      titre: titre,
      description: description,
      contenu: contenu,
      associationId: associationId,
      auteur: auteur,
      datePublication: DateTime.parse(datePublication),
      dateEvenement: dateEvenement != null ? DateTime.parse(dateEvenement!) : null,
      imageUrl: imageUrl,
      tags: tags,
      priorite: priorite,
      estEpinglee: estEpinglee,
      nombreVues: nombreVues,
      nombreLikes: nombreLikes,
    );
  }

  // UI Design: Création depuis entité
  factory ActualiteModel.fromEntity(Actualite actualite) {
    return ActualiteModel(
      id: actualite.id,
      titre: actualite.titre,
      description: actualite.description,
      contenu: actualite.contenu,
      associationId: actualite.associationId,
      auteur: actualite.auteur,
      datePublication: actualite.datePublication.toIso8601String(),
      dateEvenement: actualite.dateEvenement?.toIso8601String(),
      imageUrl: actualite.imageUrl,
      tags: actualite.tags,
      priorite: actualite.priorite,
      estEpinglee: actualite.estEpinglee,
      nombreVues: actualite.nombreVues,
      nombreLikes: actualite.nombreLikes,
    );
  }

  // UI Design: Copie avec modifications
  ActualiteModel copyWith({
    String? id,
    String? titre,
    String? description,
    String? contenu,
    String? associationId,
    String? auteur,
    String? datePublication,
    String? dateEvenement,
    String? imageUrl,
    List<String>? tags,
    String? priorite,
    bool? estEpinglee,
    int? nombreVues,
    int? nombreLikes,
  }) {
    return ActualiteModel(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      contenu: contenu ?? this.contenu,
      associationId: associationId ?? this.associationId,
      auteur: auteur ?? this.auteur,
      datePublication: datePublication ?? this.datePublication,
      dateEvenement: dateEvenement ?? this.dateEvenement,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      priorite: priorite ?? this.priorite,
      estEpinglee: estEpinglee ?? this.estEpinglee,
      nombreVues: nombreVues ?? this.nombreVues,
      nombreLikes: nombreLikes ?? this.nombreLikes,
    );
  }
} 