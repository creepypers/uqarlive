import '../../domain/entities/transaction.dart';
class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.livreId,
    required super.vendeurId,
    required super.acheteurId,
    required super.type,
    super.montant,
    required super.statut,
    required super.dateCreation,
    super.dateConfirmation,
    super.dateCompletion,
    super.livreEchangeId,
    super.messageAcheteur,
    super.messageVendeur,
    super.lieuRendezVous,
    super.dateRendezVous,
  });
  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel(
      id: entity.id,
      livreId: entity.livreId,
      vendeurId: entity.vendeurId,
      acheteurId: entity.acheteurId,
      type: entity.type,
      montant: entity.montant,
      statut: entity.statut,
      dateCreation: entity.dateCreation,
      dateConfirmation: entity.dateConfirmation,
      dateCompletion: entity.dateCompletion,
      livreEchangeId: entity.livreEchangeId,
      messageAcheteur: entity.messageAcheteur,
      messageVendeur: entity.messageVendeur,
      lieuRendezVous: entity.lieuRendezVous,
      dateRendezVous: entity.dateRendezVous,
    );
  }
  Transaction toEntity() {
    return Transaction(
      id: id,
      livreId: livreId,
      vendeurId: vendeurId,
      acheteurId: acheteurId,
      type: type,
      montant: montant,
      statut: statut,
      dateCreation: dateCreation,
      dateConfirmation: dateConfirmation,
      dateCompletion: dateCompletion,
      livreEchangeId: livreEchangeId,
      messageAcheteur: messageAcheteur,
      messageVendeur: messageVendeur,
      lieuRendezVous: lieuRendezVous,
      dateRendezVous: dateRendezVous,
    );
  }
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      livreId: map['livreId'] as String,
      vendeurId: map['vendeurId'] as String,
      acheteurId: map['acheteurId'] as String,
      type: map['type'] as String,
      montant: map['montant'] as double?,
      statut: map['statut'] as String,
      dateCreation: DateTime.parse(map['dateCreation'] as String),
      dateConfirmation: map['dateConfirmation'] != null 
          ? DateTime.parse(map['dateConfirmation'] as String) 
          : null,
      dateCompletion: map['dateCompletion'] != null 
          ? DateTime.parse(map['dateCompletion'] as String) 
          : null,
      livreEchangeId: map['livreEchangeId'] as String?,
      messageAcheteur: map['messageAcheteur'] as String?,
      messageVendeur: map['messageVendeur'] as String?,
      lieuRendezVous: map['lieuRendezVous'] as String?,
      dateRendezVous: map['dateRendezVous'] != null 
          ? DateTime.parse(map['dateRendezVous'] as String) 
          : null,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'livreId': livreId,
      'vendeurId': vendeurId,
      'acheteurId': acheteurId,
      'type': type,
      'montant': montant,
      'statut': statut,
      'dateCreation': dateCreation.toIso8601String(),
      'dateConfirmation': dateConfirmation?.toIso8601String(),
      'dateCompletion': dateCompletion?.toIso8601String(),
      'livreEchangeId': livreEchangeId,
      'messageAcheteur': messageAcheteur,
      'messageVendeur': messageVendeur,
      'lieuRendezVous': lieuRendezVous,
      'dateRendezVous': dateRendezVous?.toIso8601String(),
    };
  }
  @override
  TransactionModel copyWith({
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
    return TransactionModel(
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
}