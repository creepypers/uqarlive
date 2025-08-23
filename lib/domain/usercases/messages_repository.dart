import '../entities/message.dart';
abstract class MessagesRepository {
  Future<List<Message>> obtenirMessagesUtilisateur(String utilisateurId);
  Future<List<Message>> obtenirConversation(String utilisateur1Id, String utilisateur2Id);
  Future<Message> envoyerMessage(Message message);
  Future<void> marquerMessageCommeLu(String messageId);
  Future<int> obtenirNombreMessagesNonLus(String utilisateurId);
  Future<void> supprimerMessage(String messageId);
  Future<List<Message>> obtenirMessagesRecents(String utilisateurId);
}