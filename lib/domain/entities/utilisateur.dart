class Utilisateur {
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
  const Utilisateur({
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
    this.privileges = const [],
    this.derniereConnexion,
    this.photoUrl,
    this.associationsMembre = const [], 
    required this.motDePasse, 
  });
  bool get estAdmin => typeUtilisateur == TypeUtilisateur.administrateur;
  bool aPrivilege(String privilege) => privileges.contains(privilege);
  bool get estMembreAssociations => associationsMembre.isNotEmpty;
  int get nombreAssociations => associationsMembre.length;
  Utilisateur copyWith({
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
    return Utilisateur(
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
enum TypeUtilisateur {
  etudiant,
  administrateur,
}
class PrivilegesUtilisateur {
  static const String admin = 'admin';
  static const String gestionComptes = 'gestion_comptes';
  static const String gestionCantine = 'gestion_cantine';
  static const String gestionActualites = 'gestion_actualites';
  static const String gestionAssociations = 'gestion_associations';
  static const String gestionSalles = 'gestion_salles';
  static const String gestionLivres = 'gestion_livres';
  static const String moderationContenu = 'moderation_contenu';
  static const String statistiques = 'statistiques';
} 