class DemandeAdhesion {
  final String id;
  final String utilisateurId;
  final String associationId;
  final String statut; // 'en_attente', 'acceptee', 'refusee'
  final DateTime dateCreation;
  final DateTime? dateReponse;
  final String? messageDemande; // Message de motivation de l'utilisateur
  final String? messageReponse; // Réponse du chef d'association
  final String? chefId; // ID du chef qui a traité la demande
  final String roledemande; // Rôle demandé : 'membre', 'benevole', etc.
  const DemandeAdhesion({
    required this.id,
    required this.utilisateurId,
    required this.associationId,
    required this.statut,
    required this.dateCreation,
    this.dateReponse,
    this.messageDemande,
    this.messageReponse,
    this.chefId,
    this.roledemande = 'membre',
  });
  DemandeAdhesion copyWith({
    String? id,
    String? utilisateurId,
    String? associationId,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateReponse,
    String? messageDemande,
    String? messageReponse,
    String? chefId,
    String? roledemande,
  }) {
    return DemandeAdhesion(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      associationId: associationId ?? this.associationId,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateReponse: dateReponse ?? this.dateReponse,
      messageDemande: messageDemande ?? this.messageDemande,
      messageReponse: messageReponse ?? this.messageReponse,
      chefId: chefId ?? this.chefId,
      roledemande: roledemande ?? this.roledemande,
    );
  }
  @override
  String toString() {
    return 'DemandeAdhesion(id: $id, utilisateurId: $utilisateurId, associationId: $associationId, statut: $statut, roledemande: $roledemande)';
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DemandeAdhesion && other.id == id;
  }
  @override
  int get hashCode => id.hashCode;
}