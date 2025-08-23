import '../../domain/entities/livre.dart';
class LivreModel extends Livre {
  const LivreModel({
    required super.id,
    required super.titre,
    required super.auteur,
    required super.matiere,
    required super.anneeEtude,
    required super.etatLivre,
    required super.proprietaire,
    required super.proprietaireId,
    super.description,
    super.edition,
    super.coursAssocies,
    required super.dateAjout,
    super.estDisponible = true,
    super.imageUrl,
    super.motsClefs,
    super.prix,
  });
  // Conversion depuis Map vers LivreModel
  factory LivreModel.fromMap(Map<String, dynamic> map) {
    return LivreModel(
      id: map['id'] ?? '',
      titre: map['titre'] ?? '',
      auteur: map['auteur'] ?? '',
      matiere: map['matiere'] ?? '',
      anneeEtude: map['anneeEtude'] ?? '',
      etatLivre: map['etatLivre'] ?? '',
      proprietaire: map['proprietaire'] ?? '',
      proprietaireId: map['proprietaireId'] ?? '',
      description: map['description'],
      edition: map['edition'],
      coursAssocies: map['coursAssocies'],
      dateAjout: map['dateAjout'] != null 
          ? DateTime.parse(map['dateAjout'])
          : DateTime.now(),
      estDisponible: map['estDisponible'] ?? true,
      imageUrl: map['imageUrl'],
      motsClefs: map['motsClefs'] != null 
          ? List<String>.from(map['motsClefs'])
          : null,
      prix: map['prix'] != null ? (map['prix'] as num).toDouble() : null,
    );
  }
  // Conversion depuis LivreModel vers Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'auteur': auteur,
      'matiere': matiere,
      'anneeEtude': anneeEtude,
      'etatLivre': etatLivre,
      'proprietaire': proprietaire,
      'proprietaireId': proprietaireId,
      'description': description,
      'edition': edition,
      'coursAssocies': coursAssocies,
      'dateAjout': dateAjout.toIso8601String(),
      'estDisponible': estDisponible,
      'imageUrl': imageUrl,
      'motsClefs': motsClefs,
      'prix': prix,
    };
  }
  // Conversion depuis entité Livre vers LivreModel
  factory LivreModel.fromEntity(Livre livre) {
    return LivreModel(
      id: livre.id,
      titre: livre.titre,
      auteur: livre.auteur,
      matiere: livre.matiere,
      anneeEtude: livre.anneeEtude,
      etatLivre: livre.etatLivre,
      proprietaire: livre.proprietaire,
      proprietaireId: livre.proprietaireId,
      description: livre.description,
      edition: livre.edition,
      coursAssocies: livre.coursAssocies,
      dateAjout: livre.dateAjout,
      estDisponible: livre.estDisponible,
      imageUrl: livre.imageUrl,
      motsClefs: livre.motsClefs,
      prix: livre.prix,
    );
  }
  // Conversion vers entité Livre
  Livre toEntity() {
    return Livre(
      id: id,
      titre: titre,
      auteur: auteur,
      matiere: matiere,
      anneeEtude: anneeEtude,
      etatLivre: etatLivre,
      proprietaire: proprietaire,
      proprietaireId: proprietaireId,
      description: description,
      edition: edition,
      coursAssocies: coursAssocies,
      dateAjout: dateAjout,
      estDisponible: estDisponible,
      imageUrl: imageUrl,
      motsClefs: motsClefs,
      prix: prix,
    );
  }
  // Méthode copyWith pour LivreModel
  @override
  LivreModel copyWith({
    String? id,
    String? titre,
    String? auteur,
    String? matiere,
    String? anneeEtude,
    String? etatLivre,
    String? proprietaire,
    String? proprietaireId,
    String? description,
    String? edition,
    String? coursAssocies,
    DateTime? dateAjout,
    bool? estDisponible,
    String? imageUrl,
    List<String>? motsClefs,
    double? prix,
  }) {
    return LivreModel(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      auteur: auteur ?? this.auteur,
      matiere: matiere ?? this.matiere,
      anneeEtude: anneeEtude ?? this.anneeEtude,
      etatLivre: etatLivre ?? this.etatLivre,
      proprietaire: proprietaire ?? this.proprietaire,
      proprietaireId: proprietaireId ?? this.proprietaireId,
      description: description ?? this.description,
      edition: edition ?? this.edition,
      coursAssocies: coursAssocies ?? this.coursAssocies,
      dateAjout: dateAjout ?? this.dateAjout,
      estDisponible: estDisponible ?? this.estDisponible,
      imageUrl: imageUrl ?? this.imageUrl,
      motsClefs: motsClefs ?? this.motsClefs,
      prix: prix ?? this.prix,
    );
  }
} 