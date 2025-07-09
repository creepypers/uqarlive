// UI Design: Entité Livre pour l'échange de livres universitaires entre étudiants UQAR
class Livre {
  final String id;
  final String titre;
  final String auteur;
  final String matiere;
  final String anneeEtude;
  final String etatLivre;
  final String proprietaire;
  final String? description;
  final String? isbn;
  final String? edition;
  final String? coursAssocies;
  final DateTime dateAjout;
  final bool estDisponible;
  final String? imageUrl;
  final List<String>? motsClefs;

  const Livre({
    required this.id,
    required this.titre,
    required this.auteur,
    required this.matiere,
    required this.anneeEtude,
    required this.etatLivre,
    required this.proprietaire,
    this.description,
    this.isbn,
    this.edition,
    this.coursAssocies,
    required this.dateAjout,
    this.estDisponible = true,
    this.imageUrl,
    this.motsClefs,
  });

  // Getter pour le code de cours (alias pour coursAssocies)
  String? get codeCours => coursAssocies;

  // Méthode pour copier avec modifications
  Livre copyWith({
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
    return Livre(
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

  @override
  String toString() {
    return 'Livre(id: $id, titre: $titre, auteur: $auteur, matiere: $matiere, anneeEtude: $anneeEtude, etatLivre: $etatLivre, proprietaire: $proprietaire)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Livre && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 