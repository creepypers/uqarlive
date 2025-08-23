class Livre {
  final String id;
  final String titre;
  final String auteur;
  final String matiere;
  final String anneeEtude;
  final String etatLivre;
  final String proprietaire; // Nom du propriétaire pour affichage
  final String proprietaireId; // ID de l'utilisateur propriétaire
  final String? description;
  final String? edition;
  final String? coursAssocies;
  final DateTime dateAjout;
  final bool estDisponible;
  final String? imageUrl;
  final List<String>? motsClefs;
  final double? prix;
  const Livre({
    required this.id,
    required this.titre,
    required this.auteur,
    required this.matiere,
    required this.anneeEtude,
    required this.etatLivre,
    required this.proprietaire,
    required this.proprietaireId,
    this.description,
    this.edition,
    this.coursAssocies,
    required this.dateAjout,
    this.estDisponible = true,
    this.imageUrl,
    this.motsClefs,
    this.prix,
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
    return Livre(
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
  @override
  String toString() {
    return 'Livre(id: $id, titre: $titre, auteur: $auteur, matiere: $matiere, anneeEtude: $anneeEtude, etatLivre: $etatLivre, proprietaire: $proprietaire, proprietaireId: $proprietaireId)';
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Livre && other.id == id;
  }
  @override
  int get hashCode => id.hashCode;
} 