class ReservationSalle {
  final String id;
  final String utilisateurId;
  final String salleId;
  final DateTime dateReservation;
  final DateTime heureDebut;
  final DateTime heureFin;
  final String motif; // 'etude_groupe', 'reunion', 'presentation', 'autre'
  final String? description;
  final String statut; // 'en_attente', 'confirmee', 'annulee', 'terminee'
  final int nombrePersonnes;
  final double coutTotal;
  final DateTime dateCreation;
  final List<String> participantsIds; // IDs des autres participants
  final String? notesSpeciales;
  const ReservationSalle({
    required this.id,
    required this.utilisateurId,
    required this.salleId,
    required this.dateReservation,
    required this.heureDebut,
    required this.heureFin,
    required this.motif,
    this.description,
    required this.statut,
    required this.nombrePersonnes,
    required this.coutTotal,
    required this.dateCreation,
    this.participantsIds = const [],
    this.notesSpeciales,
  });
  Duration get duree => heureFin.difference(heureDebut);
  int get dureeEnHeures => duree.inHours;
  int get dureeEnMinutes => duree.inMinutes;
  bool get estEnAttente => statut == 'en_attente';
  bool get estConfirmee => statut == 'confirmee';
  bool get estAnnulee => statut == 'annulee';
  bool get estTerminee => statut == 'terminee';
  bool get estAVenir => heureDebut.isAfter(DateTime.now());
  bool get estEnCours {
    final maintenant = DateTime.now();
    return maintenant.isAfter(heureDebut) && maintenant.isBefore(heureFin);
  }
  bool get estPassee => heureFin.isBefore(DateTime.now());
  String get motifFormate {
    switch (motif) {
      case 'etude_groupe': return 'Étude en groupe';
      case 'reunion': return 'Réunion';
      case 'presentation': return 'Présentation';
      case 'autre': return 'Autre';
      default: return 'Non spécifié';
    }
  }
  String get statutFormate {
    switch (statut) {
      case 'en_attente': return 'En attente';
      case 'confirmee': return 'Confirmée';
      case 'annulee': return 'Annulée';
      case 'terminee': return 'Terminée';
      default: return 'Inconnu';
    }
  }
  ReservationSalle copyWith({
    String? id,
    String? utilisateurId,
    String? salleId,
    DateTime? dateReservation,
    DateTime? heureDebut,
    DateTime? heureFin,
    String? motif,
    String? description,
    String? statut,
    int? nombrePersonnes,
    double? coutTotal,
    DateTime? dateCreation,
    List<String>? participantsIds,
    String? notesSpeciales,
  }) {
    return ReservationSalle(
      id: id ?? this.id,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      salleId: salleId ?? this.salleId,
      dateReservation: dateReservation ?? this.dateReservation,
      heureDebut: heureDebut ?? this.heureDebut,
      heureFin: heureFin ?? this.heureFin,
      motif: motif ?? this.motif,
      description: description ?? this.description,
      statut: statut ?? this.statut,
      nombrePersonnes: nombrePersonnes ?? this.nombrePersonnes,
      coutTotal: coutTotal ?? this.coutTotal,
      dateCreation: dateCreation ?? this.dateCreation,
      participantsIds: participantsIds ?? this.participantsIds,
      notesSpeciales: notesSpeciales ?? this.notesSpeciales,
    );
  }
  @override
  String toString() {
    return 'ReservationSalle(id: $id, utilisateurId: $utilisateurId, salleId: $salleId, date: $dateReservation, statut: $statut)';
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReservationSalle && other.id == id;
  }
  @override
  int get hashCode => id.hashCode;
}