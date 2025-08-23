class MembreAssociation {
  final String id;
  final String utilisateurId;
  final String associationId;
  final String role; // 'membre', 'president', 'vice_president', 'tresorier', 'secretaire', 'membre_bureau'
  final DateTime dateAdhesion;
  final bool estActif;
  final double? cotisationPayee;
  final DateTime? dateFinAdhesion;
  final List<String> responsabilites;
  const MembreAssociation({
    required this.id,
    required this.utilisateurId,
    required this.associationId,
    required this.role,
    required this.dateAdhesion,
    this.estActif = true,
    this.cotisationPayee,
    this.dateFinAdhesion,
    this.responsabilites = const [],
  });
  bool get estMembreBureau => ['president', 'vice_president', 'tresorier', 'secretaire', 'membre_bureau'].contains(role);
  bool get estPresident => role == 'president';
  bool get estVicePresident => role == 'vice_president';
  Duration get dureeAdhesion => DateTime.now().difference(dateAdhesion);
  int get dureeAdhesionEnMois => (dureeAdhesion.inDays / 30).round();
  String get roleFormate {
    final roleLower = role.toLowerCase();
    switch (roleLower) {
      case 'president':
      case 'président':
        return 'Président';
      case 'vice_president':
      case 'vice-président':
      case 'vice président':
        return 'Vice-Président';
      case 'tresorier':
      case 'trésorier':
        return 'Trésorier';
      case 'secretaire':
      case 'secrétaire':
        return 'Secrétaire';
      case 'membre_bureau':
      case 'membre du bureau':
        return 'Membre du Bureau';
      case 'chef':
        return 'Chef';
      case 'membre':
      case 'membre actif':
        return 'Membre';
      default: 
        // Si le rôle n'est pas reconnu, retourner tel quel avec première lettre majuscule
        return role.isEmpty ? 'Membre' : '${role[0].toUpperCase()}${role.substring(1)}';
    }
  }
  MembreAssociation copyWith({
    String? id,
    String? utilisateurId,
    String? associationId,
    String? role,
    DateTime? dateAdhesion,
    bool? estActif,
    double? cotisationPayee,
    DateTime? dateFinAdhesion,
    List<String>? responsabilites,
  }) {
    return MembreAssociation(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      associationId: associationId ?? this.associationId,
      role: role ?? this.role,
      dateAdhesion: dateAdhesion ?? this.dateAdhesion,
      estActif: estActif ?? this.estActif,
      cotisationPayee: cotisationPayee ?? this.cotisationPayee,
      dateFinAdhesion: dateFinAdhesion ?? this.dateFinAdhesion,
      responsabilites: responsabilites ?? this.responsabilites,
    );
  }
  @override
  String toString() {
    return 'MembreAssociation(id: $id, utilisateurId: $utilisateurId, associationId: $associationId, role: $role, actif: $estActif)';
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MembreAssociation && other.id == id;
  }
  @override
  int get hashCode => id.hashCode;
}