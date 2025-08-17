// UI Design: Repository abstrait pour la gestion des transactions de livres
import '../entities/transaction.dart';

abstract class TransactionsRepository {
  // UI Design: Gestion des transactions
  Future<List<Transaction>> obtenirTransactionsParAcheteur(String acheteurId);
  Future<List<Transaction>> obtenirTransactionsParVendeur(String vendeurId);
  Future<List<Transaction>> obtenirTransactionsParLivre(String livreId);
  Future<Transaction?> obtenirTransactionParId(String transactionId);
  
  // UI Design: Création et modification de transactions
  Future<bool> creerTransaction(Transaction transaction);
  Future<bool> modifierTransaction(Transaction transaction);
  Future<bool> confirmerTransaction(String transactionId);
  Future<bool> completerTransaction(String transactionId);
  Future<bool> annulerTransaction(String transactionId);
  
  // UI Design: Vérifications métier
  Future<bool> peutAcheterLivre(String utilisateurId, String livreId);
  Future<bool> aTransactionEnCours(String livreId);
  
  // UI Design: Statistiques
  Future<Map<String, int>> obtenirStatistiquesTransactions(String utilisateurId);
  Future<List<Transaction>> obtenirHistoriqueTransactions(String utilisateurId);
}