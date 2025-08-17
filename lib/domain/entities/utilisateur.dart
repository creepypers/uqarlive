// UI Design: Entité représentant un utilisateur de l'application
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
  final List<String> associationsMembre; // UI Design: Liste des IDs des associations dont l'utilisateur est membre

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
    this.associationsMembre = const [], // UI Design: Initialiser avec une liste vide
  });

  // UI Design: Méthode utilitaire pour vérifier si l'utilisateur est admin
  bool get estAdmin => typeUtilisateur == TypeUtilisateur.administrateur;

  // UI Design: Méthode utilitaire pour vérifier si l'utilisateur a un privilège spécifique
  bool aPrivilege(String privilege) => privileges.contains(privilege);

  // UI Design: Getter pour vérifier si l'utilisateur est membre d'associations
  bool get estMembreAssociations => associationsMembre.isNotEmpty;

  // UI Design: Getter pour le nombre d'associations dont l'utilisateur est membre
  int get nombreAssociations => associationsMembre.length;

  // UI Design: Copie avec modifications
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
    List<String>? associationsMembre, // UI Design: Ajouter associationsMembre
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
      associationsMembre: associationsMembre ?? this.associationsMembre, // UI Design: Copier associationsMembre
    );
  }
}

// UI Design: Énumération des types d'utilisateurs
enum TypeUtilisateur {
  etudiant,
  administrateur,
}

// UI Design: Constantes pour les privilèges
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