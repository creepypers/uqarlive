import '../entities/transaction.dart';
abstract class TransactionsRepository {
  Future<List<Transaction>> obtenirTransactionsParAcheteur(String acheteurId);
  Future<List<Transaction>> obtenirTransactionsParVendeur(String vendeurId);
  Future<List<Transaction>> obtenirTransactionsParLivre(String livreId);
  Future<Transaction?> obtenirTransactionParId(String transactionId);
  Future<bool> creerTransaction(Transaction transaction);
  Future<bool> modifierTransaction(Transaction transaction);
  Future<bool> confirmerTransaction(String transactionId);
  Future<bool> completerTransaction(String transactionId);
  Future<bool> annulerTransaction(String transactionId);
  Future<bool> peutAcheterLivre(String utilisateurId, String livreId);
  Future<bool> aTransactionEnCours(String livreId);
  Future<Map<String, int>> obtenirStatistiquesTransactions(String utilisateurId);
  Future<List<Transaction>> obtenirHistoriqueTransactions(String utilisateurId);
}