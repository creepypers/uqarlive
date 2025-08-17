// UI Design: Interface du repository pour la gestion des messages dans UqarLife
import '../entities/message.dart';

abstract class MessagesRepository {
  // UI Design: Obtenir tous les messages d'un utilisateur
  Future<List<Message>> obtenirMessagesUtilisateur(String utilisateurId);
  
  // UI Design: Obtenir la conversation entre deux utilisateurs
  Future<List<Message>> obtenirConversation(String utilisateur1Id, String utilisateur2Id);
  
  // UI Design: Envoyer un nouveau message
  Future<Message> envoyerMessage(Message message);
  
  // UI Design: Marquer un message comme lu
  Future<void> marquerMessageCommeLu(String messageId);
  
  // UI Design: Obtenir le nombre de messages non lus
  Future<int> obtenirNombreMessagesNonLus(String utilisateurId);
  
  // UI Design: Supprimer un message
  Future<void> supprimerMessage(String messageId);
  
  // UI Design: Obtenir les messages récents (dernières 24h)
  Future<List<Message>> obtenirMessagesRecents(String utilisateurId);
}
