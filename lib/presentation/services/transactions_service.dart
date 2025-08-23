import '../../core/di/service_locator.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/livre.dart';
import '../../domain/entities/utilisateur.dart';
import '../../domain/usercases/transactions_repository.dart';
import '../../domain/usercases/livres_repository.dart';
class TransactionsService {
  static final TransactionsService _instance = TransactionsService._internal();
  factory TransactionsService() => _instance;
  TransactionsService._internal();
  static TransactionsService get instance => _instance;
  TransactionsRepository? _transactionsRepository;
  LivresRepository? _livresRepository;
  bool _estInitialise = false;
  void initialiser() {
    if (_estInitialise) return;
    _transactionsRepository = ServiceLocator.obtenirService<TransactionsRepository>();
    _livresRepository = ServiceLocator.obtenirService<LivresRepository>();
    _estInitialise = true;
  }
  TransactionsRepository get transactionsRepository {
    if (_transactionsRepository == null) initialiser();
    return _transactionsRepository!;
  }
  LivresRepository get livresRepository {
    if (_livresRepository == null) initialiser();
    return _livresRepository!;
  }
  Future<Map<String, dynamic>> peutAcheterLivre(Utilisateur utilisateur, Livre livre) async {
    // Vérification 1: L'utilisateur ne peut pas acheter son propre livre
    if (utilisateur.id == livre.proprietaireId) {
      return {
        'peut': false,
        'raison': 'Vous ne pouvez pas acheter votre propre livre',
        'code': 'PROPRIETAIRE_IDENTIQUE'
      };
    }
    // Vérification 2: Le livre doit être disponible
    if (!livre.estDisponible) {
      return {
        'peut': false,
        'raison': 'Ce livre n\'est plus disponible',
        'code': 'LIVRE_INDISPONIBLE'
      };
    }
    // Vérification 3: Le livre doit être en vente ou échangeable
    if (livre.prix == null || livre.prix == 0) {
      return {
        'peut': false,
        'raison': 'Ce livre n\'est pas en vente',
        'code': 'LIVRE_NON_VENDABLE'
      };
    }
    // Vérification 4: Pas de transaction en cours pour ce livre
    final transactionEnCours = await transactionsRepository.aTransactionEnCours(livre.id);
    if (transactionEnCours) {
      return {
        'peut': false,
        'raison': 'Une transaction est déjà en cours pour ce livre',
        'code': 'TRANSACTION_EN_COURS'
      };
    }
    return {
      'peut': true,
      'raison': 'Achat possible',
      'code': 'ACHAT_AUTORISE'
    };
  }
  Future<bool> creerTransactionAchat({
    required String livreId,
    required String vendeurId,
    required String acheteurId,
    required double montant,
    String? messageAcheteur,
  }) async {
    final transaction = Transaction(
      id: 'trans_${DateTime.now().millisecondsSinceEpoch}',
      livreId: livreId,
      vendeurId: vendeurId,
      acheteurId: acheteurId,
      type: 'achat',
      montant: montant,
      statut: 'en_attente',
      dateCreation: DateTime.now(),
      messageAcheteur: messageAcheteur,
    );
    return await transactionsRepository.creerTransaction(transaction);
  }
  Future<bool> creerTransactionEchange({
    required String livreId,
    required String vendeurId,
    required String acheteurId,
    required String livreEchangeId,
    String? messageAcheteur,
  }) async {
    final transaction = Transaction(
      id: 'trans_${DateTime.now().millisecondsSinceEpoch}',
      livreId: livreId,
      vendeurId: vendeurId,
      acheteurId: acheteurId,
      type: 'echange',
      statut: 'en_attente',
      dateCreation: DateTime.now(),
      livreEchangeId: livreEchangeId,
      messageAcheteur: messageAcheteur,
    );
    return await transactionsRepository.creerTransaction(transaction);
  }
  Future<List<Transaction>> obtenirMesTransactions(String utilisateurId) async {
    final achats = await transactionsRepository.obtenirTransactionsParAcheteur(utilisateurId);
    final ventes = await transactionsRepository.obtenirTransactionsParVendeur(utilisateurId);
    final toutes = [...achats, ...ventes];
    toutes.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
    return toutes;
  }
  Future<bool> confirmerTransaction(String transactionId) async {
    return await transactionsRepository.confirmerTransaction(transactionId);
  }
  Future<bool> completerTransaction(String transactionId) async {
    final success = await transactionsRepository.completerTransaction(transactionId);
    if (success) {
      // Marquer le livre comme vendu/échangé
      final transaction = await transactionsRepository.obtenirTransactionParId(transactionId);
      if (transaction != null) {
        await livresRepository.marquerLivreEchange(transaction.livreId);
      }
    }
    return success;
  }
  Future<bool> annulerTransaction(String transactionId) async {
    return await transactionsRepository.annulerTransaction(transactionId);
  }
  Future<bool> proposerEchange(
    String acheteurId,
    String livreEchangeId,
    String livreId,
    String messageAcheteur,
  ) async {
    // Obtenir les infos du livre pour récupérer le vendeurId
    final livre = await livresRepository.obtenirLivreParId(livreId);
    if (livre == null) return false;
    return await creerTransactionEchange(
      livreId: livreId,
      vendeurId: livre.proprietaireId,
      acheteurId: acheteurId,
      livreEchangeId: livreEchangeId,
      messageAcheteur: messageAcheteur,
    );
  }
  Future<Map<String, int>> obtenirStatistiques(String utilisateurId) async {
    return await transactionsRepository.obtenirStatistiquesTransactions(utilisateurId);
  }
}