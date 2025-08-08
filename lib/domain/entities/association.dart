// UI Design: Entité Association pour les associations étudiantes UQAR
class Association {
  final String id;
  final String nom;
  final String description;
  final String typeAssociation; // "etudiante", "culturelle", "sportive", "academique"
  final String? president;
  final String? vicePresident;
  final String? chefId; // ID du chef/président de l'association
  final int nombreMembres;
  final String? email;
  final String? telephone;
  final String? siteWeb;
  final String? facebook;
  final String? instagram;
  final List<String> activites;
  final String? logoUrl;
  final DateTime dateCreation;
  final bool estActive;
  final String? localisation; // Local ou bâtiment
  final String? horairesBureau;
  final List<String>? evenementsVenir;
  final double? cotisationAnnuelle;
  final String? descriptionLongue;
  final List<String>? beneficesMembers; // Avantages d'être membre

  const Association({
    required this.id,
    required this.nom,
    required this.description,
    required this.typeAssociation,
    this.president,
    this.vicePresident,
    this.chefId,
    required this.nombreMembres,
    this.email,
    this.telephone,
    this.siteWeb,
    this.facebook,
    this.instagram,
    required this.activites,
    this.logoUrl,
    required this.dateCreation,
    this.estActive = true,
    this.localisation,
    this.horairesBureau,
    this.evenementsVenir,
    this.cotisationAnnuelle,
    this.descriptionLongue,
    this.beneficesMembers,
  });

  // Getter pour le nombre de membres formaté
  String get nombreMembresFormatte {
    if (nombreMembres >= 1000) {
      return '${(nombreMembres / 1000).toStringAsFixed(1)}k';
    }
    return nombreMembres.toString();
  }

  // Getter pour vérifier si l'association a des contacts
  bool get aDesContacts => 
      email != null || telephone != null || siteWeb != null;

  // Getter pour vérifier si l'association a des réseaux sociaux
  bool get aDesReseauxSociaux => 
      facebook != null || instagram != null;

  // Getter pour obtenir la couleur selon le type
  String get couleurType {
    switch (typeAssociation) {
      case 'etudiante':
        return '#005499'; // Bleu principal UQAR
      case 'culturelle':
        return '#FF6B6B'; // Rouge culture
      case 'sportive':
        return '#4ECDC4'; // Vert sport
      case 'academique':
        return '#45B7D1'; // Bleu académique
      default:
        return '#005499';
    }
  }

  // Méthode pour copier avec modifications
  Association copyWith({
    String? id,
    String? nom,
    String? description,
    String? typeAssociation,
    String? president,
    String? vicePresident,
    String? chefId,
    int? nombreMembres,
    String? email,
    String? telephone,
    String? siteWeb,
    String? facebook,
    String? instagram,
    List<String>? activites,
    String? logoUrl,
    DateTime? dateCreation,
    bool? estActive,
    String? localisation,
    String? horairesBureau,
    List<String>? evenementsVenir,
    double? cotisationAnnuelle,
    String? descriptionLongue,
    List<String>? beneficesMembers,
  }) {
    return Association(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      typeAssociation: typeAssociation ?? this.typeAssociation,
      president: president ?? this.president,
      vicePresident: vicePresident ?? this.vicePresident,
      chefId: chefId ?? this.chefId,
      nombreMembres: nombreMembres ?? this.nombreMembres,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      siteWeb: siteWeb ?? this.siteWeb,
      facebook: facebook ?? this.facebook,
      instagram: instagram ?? this.instagram,
      activites: activites ?? this.activites,
      logoUrl: logoUrl ?? this.logoUrl,
      dateCreation: dateCreation ?? this.dateCreation,
      estActive: estActive ?? this.estActive,
      localisation: localisation ?? this.localisation,
      horairesBureau: horairesBureau ?? this.horairesBureau,
      evenementsVenir: evenementsVenir ?? this.evenementsVenir,
      cotisationAnnuelle: cotisationAnnuelle ?? this.cotisationAnnuelle,
      descriptionLongue: descriptionLongue ?? this.descriptionLongue,
      beneficesMembers: beneficesMembers ?? this.beneficesMembers,
    );
  }

  @override
  String toString() {
    return 'Association(id: $id, nom: $nom, type: $typeAssociation, membres: $nombreMembres, active: $estActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Association && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 