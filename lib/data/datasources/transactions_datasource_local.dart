import '../models/transaction_model.dart';

class TransactionsDatasourceLocal {
  // Simulation de données locales pour les transactions
  static final List<TransactionModel> _transactions = [
    // Transactions d'exemple pour différents utilisateurs
    TransactionModel(
      id: 'trans_001',
      livreId: 'livre_002', // Physique Générale
      vendeurId: 'etud_002', // Marie Dubois
      acheteurId: 'etud_001', // Alexandre Martin
      type: 'achat',
      montant: 25.0,
      statut: 'completee',
      dateCreation: DateTime.now().subtract(const Duration(days: 10)),
      dateConfirmation: DateTime.now().subtract(const Duration(days: 9)),
      dateCompletion: DateTime.now().subtract(const Duration(days: 8)),
      messageAcheteur: 'Livre en bon état ?',
      messageVendeur: 'Oui, très peu utilisé !',
      lieuRendezVous: 'Bibliothèque UQAR',
      dateRendezVous: DateTime.now().subtract(const Duration(days: 8, hours: 2)),
    ),
    TransactionModel(
      id: 'trans_002',
      livreId: 'livre_005', // Programmation Java
      vendeurId: 'etud_003', // Pierre Tremblay
      acheteurId: 'etud_001', // Alexandre Martin
      type: 'echange',
      statut: 'en_attente',
      dateCreation: DateTime.now().subtract(const Duration(days: 2)),
      livreEchangeId: 'livre_001', // Calcul Différentiel d'Alexandre
      messageAcheteur: 'Je propose mon livre de Calcul en échange',
      messageVendeur: null,
    ),
  ];

  Future<List<TransactionModel>> obtenirTransactionsParAcheteur(String acheteurId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _transactions
        .where((transaction) => transaction.acheteurId == acheteurId)
        .toList()
        ..sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
  }

  Future<List<TransactionModel>> obtenirTransactionsParVendeur(String vendeurId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _transactions
        .where((transaction) => transaction.vendeurId == vendeurId)
        .toList()
        ..sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
  }

  Future<List<TransactionModel>> obtenirTransactionsParLivre(String livreId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _transactions
        .where((transaction) => transaction.livreId == livreId)
        .toList()
        ..sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
  }

  Future<TransactionModel?> obtenirTransactionParId(String transactionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _transactions.firstWhere((transaction) => transaction.id == transactionId);
    } catch (e) {
      return null;
    }
  }

  Future<void> creerTransaction(TransactionModel transaction) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _transactions.add(transaction);
  }

  Future<void> modifierTransaction(TransactionModel transaction) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    }
  }

  Future<void> changerStatutTransaction(String transactionId, String nouveauStatut) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      _transactions[index] = _transactions[index].copyWith(
        statut: nouveauStatut,
        dateConfirmation: nouveauStatut == 'confirmee' ? DateTime.now() : _transactions[index].dateConfirmation,
        dateCompletion: nouveauStatut == 'completee' ? DateTime.now() : _transactions[index].dateCompletion,
      );
    }
  }

  Future<bool> peutAcheterLivre(String utilisateurId, String livreId, String proprietaireId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Vérifier que l'utilisateur n'est pas le propriétaire
    if (utilisateurId == proprietaireId) {
      return false;
    }
    
    // Vérifier qu'il n'y a pas déjà une transaction en cours pour ce livre
    final transactionEnCours = _transactions.any((transaction) =>
        transaction.livreId == livreId &&
        (transaction.statut == 'en_attente' || transaction.statut == 'confirmee'));
    
    return !transactionEnCours;
  }

  Future<bool> aTransactionEnCours(String livreId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _transactions.any((transaction) =>
        transaction.livreId == livreId &&
        (transaction.statut == 'en_attente' || transaction.statut == 'confirmee'));
  }

  Future<Map<String, int>> obtenirStatistiquesTransactions(String utilisateurId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final ventesTerminees = _transactions.where((t) => 
        t.vendeurId == utilisateurId && t.statut == 'completee').length;
    final achatsTermines = _transactions.where((t) => 
        t.acheteurId == utilisateurId && t.statut == 'completee').length;
    final enCours = _transactions.where((t) => 
        (t.vendeurId == utilisateurId || t.acheteurId == utilisateurId) && 
        (t.statut == 'en_attente' || t.statut == 'confirmee')).length;
    
    return {
      'ventesTerminees': ventesTerminees,
      'achatsTermines': achatsTermines,
      'enCours': enCours,
      'total': ventesTerminees + achatsTermines,
    };
  }
}