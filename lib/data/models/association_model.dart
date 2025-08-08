import '../../domain/entities/association.dart';

// UI Design: Modèle Association pour la conversion entre Map et entité Association
class AssociationModel extends Association {
  const AssociationModel({
    required super.id,
    required super.nom,
    required super.description,
    required super.typeAssociation,
    super.president,
    super.vicePresident,
    super.chefId,
    required super.nombreMembres,
    super.email,
    super.telephone,
    super.siteWeb,
    super.facebook,
    super.instagram,
    required super.activites,
    super.logoUrl,
    required super.dateCreation,
    super.estActive = true,
    super.localisation,
    super.horairesBureau,
    super.evenementsVenir,
    super.cotisationAnnuelle,
    super.descriptionLongue,
    super.beneficesMembers,
  });

  // Conversion depuis Map vers AssociationModel
  factory AssociationModel.fromMap(Map<String, dynamic> map) {
    return AssociationModel(
      id: map['id'] ?? '',
      nom: map['nom'] ?? '',
      description: map['description'] ?? '',
      typeAssociation: map['typeAssociation'] ?? 'etudiante',
      president: map['president'],
      vicePresident: map['vicePresident'],
      chefId: map['chefId'],
      nombreMembres: map['nombreMembres'] ?? 0,
      email: map['email'],
      telephone: map['telephone'],
      siteWeb: map['siteWeb'],
      facebook: map['facebook'],
      instagram: map['instagram'],
      activites: map['activites'] != null 
          ? List<String>.from(map['activites'])
          : [],
      logoUrl: map['logoUrl'],
      dateCreation: map['dateCreation'] != null 
          ? DateTime.parse(map['dateCreation'])
          : DateTime.now(),
      estActive: map['estActive'] ?? true,
      localisation: map['localisation'],
      horairesBureau: map['horairesBureau'],
      evenementsVenir: map['evenementsVenir'] != null 
          ? List<String>.from(map['evenementsVenir'])
          : null,
      cotisationAnnuelle: map['cotisationAnnuelle']?.toDouble(),
      descriptionLongue: map['descriptionLongue'],
      beneficesMembers: map['beneficesMembers'] != null 
          ? List<String>.from(map['beneficesMembers'])
          : null,
    );
  }

  // Conversion depuis AssociationModel vers Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'typeAssociation': typeAssociation,
      'president': president,
      'vicePresident': vicePresident,
      'chefId': chefId,
      'nombreMembres': nombreMembres,
      'email': email,
      'telephone': telephone,
      'siteWeb': siteWeb,
      'facebook': facebook,
      'instagram': instagram,
      'activites': activites,
      'logoUrl': logoUrl,
      'dateCreation': dateCreation.toIso8601String(),
      'estActive': estActive,
      'localisation': localisation,
      'horairesBureau': horairesBureau,
      'evenementsVenir': evenementsVenir,
      'cotisationAnnuelle': cotisationAnnuelle,
      'descriptionLongue': descriptionLongue,
      'beneficesMembers': beneficesMembers,
    };
  }

  // Conversion depuis entité Association vers AssociationModel
  factory AssociationModel.fromEntity(Association association) {
    return AssociationModel(
      id: association.id,
      nom: association.nom,
      description: association.description,
      typeAssociation: association.typeAssociation,
      president: association.president,
      vicePresident: association.vicePresident,
      chefId: association.chefId,
      nombreMembres: association.nombreMembres,
      email: association.email,
      telephone: association.telephone,
      siteWeb: association.siteWeb,
      facebook: association.facebook,
      instagram: association.instagram,
      activites: association.activites,
      logoUrl: association.logoUrl,
      dateCreation: association.dateCreation,
      estActive: association.estActive,
      localisation: association.localisation,
      horairesBureau: association.horairesBureau,
      evenementsVenir: association.evenementsVenir,
      cotisationAnnuelle: association.cotisationAnnuelle,
      descriptionLongue: association.descriptionLongue,
      beneficesMembers: association.beneficesMembers,
    );
  }

  // Conversion vers entité Association
  Association toEntity() {
    return Association(
      id: id,
      nom: nom,
      description: description,
      typeAssociation: typeAssociation,
      president: president,
      vicePresident: vicePresident,
      chefId: chefId,
      nombreMembres: nombreMembres,
      email: email,
      telephone: telephone,
      siteWeb: siteWeb,
      facebook: facebook,
      instagram: instagram,
      activites: activites,
      logoUrl: logoUrl,
      dateCreation: dateCreation,
      estActive: estActive,
      localisation: localisation,
      horairesBureau: horairesBureau,
      evenementsVenir: evenementsVenir,
      cotisationAnnuelle: cotisationAnnuelle,
      descriptionLongue: descriptionLongue,
      beneficesMembers: beneficesMembers,
    );
  }

  // Méthode copyWith pour AssociationModel
  @override
  AssociationModel copyWith({
    String? chefId,
    String? id,
    String? nom,
    String? description,
    String? typeAssociation,
    String? president,
    String? vicePresident,
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
    return AssociationModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      typeAssociation: typeAssociation ?? this.typeAssociation,
      president: president ?? this.president,
      vicePresident: vicePresident ?? this.vicePresident,
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
} 