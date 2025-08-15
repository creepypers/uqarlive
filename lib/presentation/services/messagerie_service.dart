// UI Design: Service de messagerie pour UqarLife - Gestion complète des messages
import '../../domain/entities/message.dart';
import '../../domain/repositories/messages_repository.dart';
import '../../domain/repositories/utilisateurs_repository.dart';
import '../../domain/entities/utilisateur.dart';

class MessagerieService {
  final MessagesRepository _messagesRepository;
  final UtilisateursRepository _utilisateursRepository;

  MessagerieService(this._messagesRepository, this._utilisateursRepository);

  // UI Design: Envoyer un message de contact pour un livre
  Future<Message> envoyerMessageLivre({
    required String expediteurId,
    required String destinataireId,
    required String contenu,
    required String livreId,
    String? livreTitre,
  }) async {
    try {
      // UI Design: Créer le message avec référence au livre
      final message = Message(
        id: '', // Sera généré par le repository
        expediteurId: expediteurId,
        destinataireId: destinataireId,
        contenu: contenu,
        dateEnvoi: DateTime.now(),
        estLu: false,
        typeMessage: 'transaction',
        referenceId: livreId,
      );

      // UI Design: Envoyer le message via le repository
      final nouveauMessage = await _messagesRepository.envoyerMessage(message);
      
      return nouveauMessage;
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du message: $e');
    }
  }

  // UI Design: Envoyer un message de réponse à une demande d'échange
  Future<Message> envoyerMessageReponse({
    required String expediteurId,
    required String destinataireId,
    required String contenu,
    required String transactionId,
  }) async {
    try {
      // UI Design: Créer le message de réponse
      final message = Message(
        id: '',
        expediteurId: expediteurId,
        destinataireId: destinataireId,
        contenu: contenu,
        dateEnvoi: DateTime.now(),
        estLu: false,
        typeMessage: 'transaction',
        referenceId: transactionId,
      );

      // UI Design: Envoyer le message via le repository
      final nouveauMessage = await _messagesRepository.envoyerMessage(message);
      
      return nouveauMessage;
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi de la réponse: $e');
    }
  }

  // UI Design: Envoyer un message général (support, information)
  Future<Message> envoyerMessageGeneral({
    required String expediteurId,
    required String destinataireId,
    required String contenu,
    String? typeMessage,
  }) async {
    try {
      // UI Design: Créer le message général
      final message = Message(
        id: '',
        expediteurId: expediteurId,
        destinataireId: destinataireId,
        contenu: contenu,
        dateEnvoi: DateTime.now(),
        estLu: false,
        typeMessage: typeMessage ?? 'general',
      );

      // UI Design: Envoyer le message via le repository
      final nouveauMessage = await _messagesRepository.envoyerMessage(message);
      
      return nouveauMessage;
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du message général: $e');
    }
  }

  // UI Design: Obtenir la conversation entre deux utilisateurs
  Future<List<Message>> obtenirConversation(String utilisateur1Id, String utilisateur2Id) async {
    try {
      // UI Design: Récupérer la conversation via le repository
      final conversation = await _messagesRepository.obtenirConversation(utilisateur1Id, utilisateur2Id);
      
      // UI Design: Marquer automatiquement les messages comme lus
      for (final message in conversation) {
        if (message.destinataireId == utilisateur1Id && !message.estLu) {
          await _messagesRepository.marquerMessageCommeLu(message.id);
        }
      }
      
      return conversation;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la conversation: $e');
    }
  }

  // UI Design: Obtenir tous les messages d'un utilisateur
  Future<List<Message>> obtenirMessagesUtilisateur(String utilisateurId) async {
    try {
      // UI Design: Récupérer tous les messages via le repository
      return await _messagesRepository.obtenirMessagesUtilisateur(utilisateurId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des messages: $e');
    }
  }

  // UI Design: Obtenir le nombre de messages non lus
  Future<int> obtenirNombreMessagesNonLus(String utilisateurId) async {
    try {
      // UI Design: Récupérer le nombre de messages non lus via le repository
      return await _messagesRepository.obtenirNombreMessagesNonLus(utilisateurId);
    } catch (e) {
      throw Exception('Erreur lors du comptage des messages: $e');
    }
  }

  // UI Design: Marquer un message comme lu
  Future<void> marquerMessageCommeLu(String messageId) async {
    try {
      // UI Design: Marquer le message comme lu via le repository
      await _messagesRepository.marquerMessageCommeLu(messageId);
    } catch (e) {
      throw Exception('Erreur lors du marquage du message: $e');
    }
  }

  // UI Design: Supprimer un message
  Future<void> supprimerMessage(String messageId) async {
    try {
      // UI Design: Supprimer le message via le repository
      await _messagesRepository.supprimerMessage(messageId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du message: $e');
    }
  }

  // UI Design: Obtenir les messages récents (dernières 24h)
  Future<List<Message>> obtenirMessagesRecents(String utilisateurId) async {
    try {
      // UI Design: Récupérer les messages récents via le repository
      return await _messagesRepository.obtenirMessagesRecents(utilisateurId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des messages récents: $e');
    }
  }

  // UI Design: Obtenir les informations de l'expéditeur d'un message
  Future<Utilisateur?> obtenirExpediteur(String expediteurId) async {
    try {
      // UI Design: Récupérer les informations de l'utilisateur via le repository
      return await _utilisateursRepository.obtenirUtilisateurParId(expediteurId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'expéditeur: $e');
    }
  }

  // UI Design: Formater le contenu d'un message pour l'affichage
  String formaterContenuMessage(String contenu) {
    // UI Design: Nettoyer et formater le contenu du message
    return contenu.trim();
  }

  // UI Design: Valider le contenu d'un message avant envoi
  bool validerContenuMessage(String contenu) {
    // UI Design: Vérifier que le message n'est pas vide et respecte les limites
    final contenuNettoye = contenu.trim();
    return contenuNettoye.isNotEmpty && contenuNettoye.length <= 1000;
  }

  // UI Design: Obtenir le statut de lecture d'un message
  String obtenirStatutLecture(Message message) {
    if (message.estLu) {
      return 'Lu';
    } else if (message.estRecent) {
      return 'Récent';
    } else {
      return 'Non lu';
    }
  }

  // UI Design: Grouper les messages par date pour l'affichage
  Map<String, List<Message>> grouperMessagesParDate(List<Message> messages) {
    final Map<String, List<Message>> groupes = {};
    
    for (final message in messages) {
      final date = message.dateEnvoi;
      final dateCle = '${date.day}/${date.month}/${date.year}';
      
      if (groupes[dateCle] == null) {
        groupes[dateCle] = [];
      }
      groupes[dateCle]!.add(message);
    }
    
    return groupes;
  }
}
