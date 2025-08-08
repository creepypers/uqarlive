import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../datasources/transactions_datasource_local.dart';
import '../models/transaction_model.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  final TransactionsDatasourceLocal _datasourceLocal;

  const TransactionsRepositoryImpl(this._datasourceLocal);

  @override
  Future<List<Transaction>> obtenirTransactionsParAcheteur(String acheteurId) async {
    final models = await _datasourceLocal.obtenirTransactionsParAcheteur(acheteurId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Transaction>> obtenirTransactionsParVendeur(String vendeurId) async {
    final models = await _datasourceLocal.obtenirTransactionsParVendeur(vendeurId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Transaction>> obtenirTransactionsParLivre(String livreId) async {
    final models = await _datasourceLocal.obtenirTransactionsParLivre(livreId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Transaction?> obtenirTransactionParId(String transactionId) async {
    final model = await _datasourceLocal.obtenirTransactionParId(transactionId);
    return model?.toEntity();
  }

  @override
  Future<bool> creerTransaction(Transaction transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await _datasourceLocal.creerTransaction(model);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> modifierTransaction(Transaction transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await _datasourceLocal.modifierTransaction(model);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> confirmerTransaction(String transactionId) async {
    try {
      await _datasourceLocal.changerStatutTransaction(transactionId, 'confirmee');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> completerTransaction(String transactionId) async {
    try {
      await _datasourceLocal.changerStatutTransaction(transactionId, 'completee');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> annulerTransaction(String transactionId) async {
    try {
      await _datasourceLocal.changerStatutTransaction(transactionId, 'annulee');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> peutAcheterLivre(String utilisateurId, String livreId) async {
    // Cette méthode nécessite le proprietaireId, on va le récupérer via le livre
    // Pour l'instant, on retourne true et on laissera la logique dans l'UI
    return true;
  }

  @override
  Future<bool> aTransactionEnCours(String livreId) async {
    return await _datasourceLocal.aTransactionEnCours(livreId);
  }

  @override
  Future<Map<String, int>> obtenirStatistiquesTransactions(String utilisateurId) async {
    return await _datasourceLocal.obtenirStatistiquesTransactions(utilisateurId);
  }

  @override
  Future<List<Transaction>> obtenirHistoriqueTransactions(String utilisateurId) async {
    final achats = await obtenirTransactionsParAcheteur(utilisateurId);
    final ventes = await obtenirTransactionsParVendeur(utilisateurId);
    
    final historique = [...achats, ...ventes]
        .where((t) => t.statut == 'completee' || t.statut == 'annulee')
        .toList();
    
    historique.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
    return historique;
  }
}