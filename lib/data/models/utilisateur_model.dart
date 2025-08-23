import '../../domain/entities/utilisateur.dart';
class UtilisateurModel {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String codeEtudiant;
  final String programme;
  final String niveauEtude;
  final String telephone;
  final DateTime dateInscription;
  final bool estActif;
  final TypeUtilisateur typeUtilisateur;
  final List<String> privileges;
  final DateTime? derniereConnexion;
  final String? photoUrl;
  final List<String> associationsMembre; 
  final String motDePasse; 
  const UtilisateurModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.codeEtudiant,
    required this.programme,
    required this.niveauEtude,
    required this.telephone,
    required this.dateInscription,
    required this.estActif,
    required this.typeUtilisateur,
    required this.privileges,
    this.derniereConnexion,
    this.photoUrl,
    this.associationsMembre = const [], 
    required this.motDePasse, 
  });
  factory UtilisateurModel.fromMap(Map<String, dynamic> map) {
    return UtilisateurModel(
      id: map['id'] ?? '',
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      email: map['email'] ?? '',
      codeEtudiant: map['codeEtudiant'] ?? '',
      programme: map['programme'] ?? '',
      niveauEtude: map['niveauEtude'] ?? '',
      telephone: map['telephone'] ?? '',
      dateInscription: DateTime.parse(map['dateInscription']),
      estActif: map['estActif'] ?? true,
      typeUtilisateur: TypeUtilisateur.values.firstWhere(
        (type) => type.toString().split('.').last == map['typeUtilisateur'],
        orElse: () => TypeUtilisateur.etudiant,
      ),
      privileges: List<String>.from(map['privileges'] ?? []),
      derniereConnexion: map['derniereConnexion'] != null 
          ? DateTime.parse(map['derniereConnexion']) 
          : null,
      photoUrl: map['photoUrl'],
      associationsMembre: List<String>.from(map['associationsMembre'] ?? []), 
      motDePasse: map['motDePasse'] ?? '', 
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'codeEtudiant': codeEtudiant,
      'programme': programme,
      'niveauEtude': niveauEtude,
      'telephone': telephone,
      'dateInscription': dateInscription.toIso8601String(),
      'estActif': estActif,
      'typeUtilisateur': typeUtilisateur.toString().split('.').last,
      'privileges': privileges,
      'derniereConnexion': derniereConnexion?.toIso8601String(),
      'photoUrl': photoUrl,
      'associationsMembre': associationsMembre, 
      'motDePasse': motDePasse, 
    };
  }
  Utilisateur toEntity() {
    return Utilisateur(
      id: id,
      nom: nom,
      prenom: prenom,
      email: email,
      codeEtudiant: codeEtudiant,
      programme: programme,
      niveauEtude: niveauEtude,
      telephone: telephone,
      dateInscription: dateInscription,
      estActif: estActif,
      typeUtilisateur: typeUtilisateur,
      privileges: privileges,
      derniereConnexion: derniereConnexion,
      photoUrl: photoUrl,
      associationsMembre: associationsMembre, 
      motDePasse: motDePasse, 
    );
  }
  factory UtilisateurModel.fromEntity(Utilisateur utilisateur) {
    return UtilisateurModel(
      id: utilisateur.id,
      nom: utilisateur.nom,
      prenom: utilisateur.prenom,
      email: utilisateur.email,
      codeEtudiant: utilisateur.codeEtudiant,
      programme: utilisateur.programme,
      niveauEtude: utilisateur.niveauEtude,
      telephone: utilisateur.telephone,
      dateInscription: utilisateur.dateInscription,
      estActif: utilisateur.estActif,
      typeUtilisateur: utilisateur.typeUtilisateur,
      privileges: utilisateur.privileges,
      derniereConnexion: utilisateur.derniereConnexion,
      photoUrl: utilisateur.photoUrl,
      associationsMembre: utilisateur.associationsMembre, 
      motDePasse: utilisateur.motDePasse, 
    );
  }
  UtilisateurModel copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? email,
    String? codeEtudiant,
    String? programme,
    String? niveauEtude,
    String? telephone,
    DateTime? dateInscription,
    bool? estActif,
    TypeUtilisateur? typeUtilisateur,
    List<String>? privileges,
    DateTime? derniereConnexion,
    String? photoUrl,
    List<String>? associationsMembre,
    String? motDePasse, 
  }) {
    return UtilisateurModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      codeEtudiant: codeEtudiant ?? this.codeEtudiant,
      programme: programme ?? this.programme,
      niveauEtude: niveauEtude ?? this.niveauEtude,
      telephone: telephone ?? this.telephone,
      dateInscription: dateInscription ?? this.dateInscription,
      estActif: estActif ?? this.estActif,
      typeUtilisateur: typeUtilisateur ?? this.typeUtilisateur,
      privileges: privileges ?? this.privileges,
      derniereConnexion: derniereConnexion ?? this.derniereConnexion,
      photoUrl: photoUrl ?? this.photoUrl,
      associationsMembre: associationsMembre ?? this.associationsMembre,
      motDePasse: motDePasse ?? this.motDePasse, 
    );
  }
} 