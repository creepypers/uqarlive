import '../../domain/entities/livre.dart';

// UI Design: Modèle Livre pour la conversion entre Map et entité Livre
class LivreModel extends Livre {
  const LivreModel({
    required super.id,
    required super.titre,
    required super.auteur,
    required super.matiere,
    required super.anneeEtude,
    required super.etatLivre,
    required super.proprietaire,
    super.description,
    super.isbn,
    super.edition,
    super.coursAssocies,
    required super.dateAjout,
    super.estDisponible = true,
    super.imageUrl,
    super.motsClefs,
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
      description: map['description'],
      isbn: map['isbn'],
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
      'description': description,
      'isbn': isbn,
      'edition': edition,
      'coursAssocies': coursAssocies,
      'dateAjout': dateAjout.toIso8601String(),
      'estDisponible': estDisponible,
      'imageUrl': imageUrl,
      'motsClefs': motsClefs,
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
      description: livre.description,
      isbn: livre.isbn,
      edition: livre.edition,
      coursAssocies: livre.coursAssocies,
      dateAjout: livre.dateAjout,
      estDisponible: livre.estDisponible,
      imageUrl: livre.imageUrl,
      motsClefs: livre.motsClefs,
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
      description: description,
      isbn: isbn,
      edition: edition,
      coursAssocies: coursAssocies,
      dateAjout: dateAjout,
      estDisponible: estDisponible,
      imageUrl: imageUrl,
      motsClefs: motsClefs,
    );
  }

  // Méthode copyWith pour LivreModel
  LivreModel copyWith({
    String? id,
    String? titre,
    String? auteur,
    String? matiere,
    String? anneeEtude,
    String? etatLivre,
    String? proprietaire,
    String? description,
    String? isbn,
    String? edition,
    String? coursAssocies,
    DateTime? dateAjout,
    bool? estDisponible,
    String? imageUrl,
    List<String>? motsClefs,
  }) {
    return LivreModel(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      auteur: auteur ?? this.auteur,
      matiere: matiere ?? this.matiere,
      anneeEtude: anneeEtude ?? this.anneeEtude,
      etatLivre: etatLivre ?? this.etatLivre,
      proprietaire: proprietaire ?? this.proprietaire,
      description: description ?? this.description,
      isbn: isbn ?? this.isbn,
      edition: edition ?? this.edition,
      coursAssocies: coursAssocies ?? this.coursAssocies,
      dateAjout: dateAjout ?? this.dateAjout,
      estDisponible: estDisponible ?? this.estDisponible,
      imageUrl: imageUrl ?? this.imageUrl,
      motsClefs: motsClefs ?? this.motsClefs,
    );
  }
} 