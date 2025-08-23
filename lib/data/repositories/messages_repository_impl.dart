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
      final List<MessageModel> messagesModel = await _messagesDatasource.obtenirMessagesUtilisateur(utilisateurId);
      return messagesModel.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des messages: $e');
    }
  }
  @override
  Future<List<Message>> obtenirConversation(String utilisateur1Id, String utilisateur2Id) async {
    try {
      final List<MessageModel> messagesModel = await _messagesDatasource.obtenirConversation(utilisateur1Id, utilisateur2Id);
      return messagesModel.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la conversation: $e');
    }
  }
  @override
  Future<Message> envoyerMessage(Message message) async {
    try {
      final messageModel = MessageModel.fromEntity(message);
      final nouveauMessageModel = await _messagesDatasource.envoyerMessage(messageModel);
      return nouveauMessageModel.toEntity();
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du message: $e');
    }
  }
  @override
  Future<void> marquerMessageCommeLu(String messageId) async {
    try {
      await _messagesDatasource.marquerMessageCommeLu(messageId);
    } catch (e) {
      throw Exception('Erreur lors du marquage du message: $e');
    }
  }
  @override
  Future<int> obtenirNombreMessagesNonLus(String utilisateurId) async {
    try {
      return await _messagesDatasource.obtenirNombreMessagesNonLus(utilisateurId);
    } catch (e) {
      throw Exception('Erreur lors du comptage des messages: $e');
    }
  }
  @override
  Future<void> supprimerMessage(String messageId) async {
    try {
      await _messagesDatasource.supprimerMessage(messageId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du message: $e');
    }
  }
  @override
  Future<List<Message>> obtenirMessagesRecents(String utilisateurId) async {
    try {
      final List<MessageModel> messagesModel = await _messagesDatasource.obtenirMessagesRecents(utilisateurId);
      return messagesModel.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des messages récents: $e');
    }
  }
}