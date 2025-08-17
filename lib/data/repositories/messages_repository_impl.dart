// UI Design: Implémentation du repository pour la gestion des messages dans UqarLife
import '../../domain/entities/message.dart';
import '../../domain/usercases/messages_repository.dart';
import '../datasources/internal/messages_datasource_local.dart';
import '../models/message_model.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  final MessagesDatasourceLocal _messagesDatasource;

  MessagesRepositoryImpl(this._messagesDatasource);

  @override
  Future<List<Message>> obtenirMessagesUtilisateur(String utilisateurId) async {
    try {
      // UI Design: Utiliser le datasource local pour obtenir les messages
      final List<MessageModel> messagesModel = await _messagesDatasource.obtenirMessagesUtilisateur(utilisateurId);
      
      // UI Design: Convertir les modèles en entités
      return messagesModel.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des messages: $e');
    }
  }

  @override
  Future<List<Message>> obtenirConversation(String utilisateur1Id, String utilisateur2Id) async {
    try {
      // UI Design: Utiliser le datasource local pour obtenir la conversation
      final List<MessageModel> messagesModel = await _messagesDatasource.obtenirConversation(utilisateur1Id, utilisateur2Id);
      
      // UI Design: Convertir les modèles en entités
      return messagesModel.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la conversation: $e');
    }
  }

  @override
  Future<Message> envoyerMessage(Message message) async {
    try {
      // UI Design: Convertir l'entité en modèle pour le datasource
      final messageModel = MessageModel.fromEntity(message);
      
      // UI Design: Envoyer le message via le datasource
      final nouveauMessageModel = await _messagesDatasource.envoyerMessage(messageModel);
      
      // UI Design: Retourner l'entité du nouveau message
      return nouveauMessageModel.toEntity();
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du message: $e');
    }
  }

  @override
  Future<void> marquerMessageCommeLu(String messageId) async {
    try {
      // UI Design: Marquer le message comme lu via le datasource
      await _messagesDatasource.marquerMessageCommeLu(messageId);
    } catch (e) {
      throw Exception('Erreur lors du marquage du message: $e');
    }
  }

  @override
  Future<int> obtenirNombreMessagesNonLus(String utilisateurId) async {
    try {
      // UI Design: Obtenir le nombre de messages non lus via le datasource
      return await _messagesDatasource.obtenirNombreMessagesNonLus(utilisateurId);
    } catch (e) {
      throw Exception('Erreur lors du comptage des messages: $e');
    }
  }

  @override
  Future<void> supprimerMessage(String messageId) async {
    try {
      // UI Design: Supprimer le message via le datasource
      await _messagesDatasource.supprimerMessage(messageId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du message: $e');
    }
  }

  @override
  Future<List<Message>> obtenirMessagesRecents(String utilisateurId) async {
    try {
      // UI Design: Obtenir les messages récents via le datasource
      final List<MessageModel> messagesModel = await _messagesDatasource.obtenirMessagesRecents(utilisateurId);
      
      // UI Design: Convertir les modèles en entités
      return messagesModel.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des messages récents: $e');
    }
  }
}
