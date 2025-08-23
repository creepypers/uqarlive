class Actualite {
  final String id;
  final String titre;
  final String description;
  final String contenu;
  final String associationId; // ID de l'association qui publie l'actualité
  final String auteur;
  final DateTime datePublication;
  final DateTime? dateEvenement;
  final String? imageUrl;
  final List<String> tags;
  final String priorite; // 'haute', 'normale', 'basse'
  final bool estEpinglee;
  final int nombreVues;
  final int nombreLikes;
  const Actualite({
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
  bool get estEvenement => dateEvenement != null;
  bool get estEvenementAVenir {
    if (!estEvenement) return false;
    return dateEvenement!.isAfter(DateTime.now());
  }
  Actualite copyWith({
    String? id,
    String? titre,
    String? description,
    String? contenu,
    String? associationId,
    String? auteur,
    DateTime? datePublication,
    DateTime? dateEvenement,
    String? imageUrl,
    List<String>? tags,
    String? priorite,
    bool? estEpinglee,
    int? nombreVues,
    int? nombreLikes,
  }) {
    return Actualite(
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