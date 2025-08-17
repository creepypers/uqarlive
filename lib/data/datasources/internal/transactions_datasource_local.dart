import '../../models/transaction_model.dart';

class TransactionsDatasourceLocal {
  // Simulation de données locales pour les transactions
  static final List<TransactionModel> _transactions = [
    // Transactions d'exemple pour différents utilisateurs
    TransactionModel(
      id: 'trans_001',
      livreId: '2', // Physique Générale (ID existant)
      vendeurId: 'etud_002', // Sophie Gagnon
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
      livreId: '3', // Chimie Organique (ID existant)
      vendeurId: 'etud_003', // Sarah Bouchard
      acheteurId: 'etud_001', // Alexandre Martin
      type: 'echange',
      statut: 'en_attente',
      dateCreation: DateTime.now().subtract(const Duration(days: 2)),
      livreEchangeId: '1', // Calcul Différentiel d'Alexandre (ID existant)
      messageAcheteur: 'Je propose mon livre de Calcul en échange',
      messageVendeur: null,
    ),
    // Nouvelles transactions pour tester l'écran des échanges
    TransactionModel(
      id: 'trans_003',
      livreId: '1', // Calcul Différentiel d'Alexandre
      vendeurId: 'etud_001', // Alexandre Martin
      acheteurId: 'etud_002', // Sophie Gagnon
      type: 'echange',
      statut: 'en_attente',
      dateCreation: DateTime.now().subtract(const Duration(hours: 6)),
      livreEchangeId: '2', // Physique Générale de Sophie
      messageAcheteur: 'Salut ! Je suis intéressée par ton livre de Calcul. Je propose ma Physique Générale en échange. Est-ce que ça te convient ?',
      messageVendeur: null,
    ),
    TransactionModel(
      id: 'trans_004',
      livreId: '101', // Introduction à l'Algorithmique d'Alexandre
      vendeurId: 'etud_001', // Alexandre Martin
      acheteurId: 'etud_004', // Marie Dubois
      type: 'achat',
      montant: 15.0,
      statut: 'confirmee',
      dateCreation: DateTime.now().subtract(const Duration(days: 1)),
      dateConfirmation: DateTime.now().subtract(const Duration(hours: 12)),
      messageAcheteur: 'Bonjour ! Votre livre est-il toujours disponible ?',
      messageVendeur: 'Oui, parfait ! On peut se rencontrer demain à la bibliothèque.',
      lieuRendezVous: 'Bibliothèque UQAR - Salle d\'étude',
      dateRendezVous: DateTime.now().add(const Duration(days: 1, hours: 14)),
    ),
    TransactionModel(
      id: 'trans_005',
      livreId: '102', // Algèbre Linéaire d'Alexandre (ID existant)
      vendeurId: 'etud_001', // Alexandre Martin
      acheteurId: 'etud_003', // Sarah Bouchard
      type: 'echange',
      statut: 'en_attente',
      dateCreation: DateTime.now().subtract(const Duration(hours: 2)),
      livreEchangeId: '3', // Chimie Organique de Sarah (ID existant)
      messageAcheteur: 'Salut Sarah ! J\'ai besoin de ton livre de Chimie Organique pour mon cours. Je peux t\'échanger contre mon Algèbre Linéaire si ça t\'intéresse.',
      messageVendeur: null,
    ),
    TransactionModel(
      id: 'trans_006',
      livreId: '2', // Physique Générale de Sophie
      vendeurId: 'etud_002', // Sophie Gagnon
      acheteurId: 'etud_005', // Catherine Roy
      type: 'achat',
      montant: 18.0,
      statut: 'completee',
      dateCreation: DateTime.now().subtract(const Duration(days: 5)),
      dateConfirmation: DateTime.now().subtract(const Duration(days: 4)),
      dateCompletion: DateTime.now().subtract(const Duration(days: 3)),
      messageAcheteur: 'Bonjour Sophie ! Votre livre de Physique est-il encore disponible ?',
      messageVendeur: 'Oui, il est en excellent état !',
      lieuRendezVous: 'Cafétéria UQAR',
      dateRendezVous: DateTime.now().subtract(const Duration(days: 3, hours: 16)),
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