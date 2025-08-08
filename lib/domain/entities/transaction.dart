// UI Design: Entité représentant une transaction d'achat ou d'échange de livre
class Transaction {
  final String id;
  final String livreId;
  final String vendeurId; // Propriétaire du livre
  final String acheteurId; // Utilisateur qui achète/échange
  final String type; // 'achat', 'echange'
  final double? montant; // null pour échanges
  final String statut; // 'en_attente', 'confirmee', 'completee', 'annulee'
  final DateTime dateCreation;
  final DateTime? dateConfirmation;
  final DateTime? dateCompletion;
  final String? livreEchangeId; // Pour les échanges : livre proposé en retour
  final String? messageAcheteur;
  final String? messageVendeur;
  final String? lieuRendezVous;
  final DateTime? dateRendezVous;

  const Transaction({
    required this.id,
    required this.livreId,
    required this.vendeurId,
    required this.acheteurId,
    required this.type,
    this.montant,
    required this.statut,
    required this.dateCreation,
    this.dateConfirmation,
    this.dateCompletion,
    this.livreEchangeId,
    this.messageAcheteur,
    this.messageVendeur,
    this.lieuRendezVous,
    this.dateRendezVous,
  });

  // UI Design: Méthode de copie avec modifications
  Transaction copyWith({
    String? id,
    String? livreId,
    String? vendeurId,
    String? acheteurId,
    String? type,
    double? montant,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateConfirmation,
    DateTime? dateCompletion,
    String? livreEchangeId,
    String? messageAcheteur,
    String? messageVendeur,
    String? lieuRendezVous,
    DateTime? dateRendezVous,
  }) {
    return Transaction(
      id: id ?? this.id,
      livreId: livreId ?? this.livreId,
      vendeurId: vendeurId ?? this.vendeurId,
      acheteurId: acheteurId ?? this.acheteurId,
      type: type ?? this.type,
      montant: montant ?? this.montant,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateConfirmation: dateConfirmation ?? this.dateConfirmation,
      dateCompletion: dateCompletion ?? this.dateCompletion,
      livreEchangeId: livreEchangeId ?? this.livreEchangeId,
      messageAcheteur: messageAcheteur ?? this.messageAcheteur,
      messageVendeur: messageVendeur ?? this.messageVendeur,
      lieuRendezVous: lieuRendezVous ?? this.lieuRendezVous,
      dateRendezVous: dateRendezVous ?? this.dateRendezVous,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, livreId: $livreId, vendeurId: $vendeurId, acheteurId: $acheteurId, type: $type, montant: $montant, statut: $statut)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}