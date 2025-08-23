import '../../domain/entities/message.dart';
import '../../domain/usercases/messages_repository.dart';
import '../../domain/usercases/utilisateurs_repository.dart';
import '../../domain/entities/utilisateur.dart';
class MessagerieService {
  final MessagesRepository _messagesRepository;
  final UtilisateursRepository _utilisateursRepository;
  MessagerieService(this._messagesRepository, this._utilisateursRepository);
  Future<Message> envoyerMessageLivre({
    required String expediteurId,
    required String destinataireId,
    required String contenu,
    required String livreId,
    String? livreTitre,
  }) async {
    try {
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
      final nouveauMessage = await _messagesRepository.envoyerMessage(message);
      return nouveauMessage;
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du message: $e');
    }
  }
  Future<Message> envoyerMessageReponse({
    required String expediteurId,
    required String destinataireId,
    required String contenu,
    required String transactionId,
  }) async {
    try {
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
      final nouveauMessage = await _messagesRepository.envoyerMessage(message);
      return nouveauMessage;
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi de la réponse: $e');
    }
  }
  Future<Message> envoyerMessageGeneral({
    required String expediteurId,
    required String destinataireId,
    required String contenu,
    String? typeMessage,
  }) async {
    try {
      final message = Message(
        id: '',
        expediteurId: expediteurId,
        destinataireId: destinataireId,
        contenu: contenu,
        dateEnvoi: DateTime.now(),
        estLu: false,
        typeMessage: typeMessage ?? 'general',
      );
      final nouveauMessage = await _messagesRepository.envoyerMessage(message);
      return nouveauMessage;
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du message général: $e');
    }
  }
  Future<List<Message>> obtenirConversation(String utilisateur1Id, String utilisateur2Id) async {
    try {
      final conversation = await _messagesRepository.obtenirConversation(utilisateur1Id, utilisateur2Id);
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
  Future<List<Message>> obtenirMessagesUtilisateur(String utilisateurId) async {
    try {
      return await _messagesRepository.obtenirMessagesUtilisateur(utilisateurId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des messages: $e');
    }
  }
  Future<int> obtenirNombreMessagesNonLus(String utilisateurId) async {
    try {
      return await _messagesRepository.obtenirNombreMessagesNonLus(utilisateurId);
    } catch (e) {
      throw Exception('Erreur lors du comptage des messages: $e');
    }
  }
  Future<void> marquerMessageCommeLu(String messageId) async {
    try {
      await _messagesRepository.marquerMessageCommeLu(messageId);
    } catch (e) {
      throw Exception('Erreur lors du marquage du message: $e');
    }
  }
  Future<void> supprimerMessage(String messageId) async {
    try {
      await _messagesRepository.supprimerMessage(messageId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du message: $e');
    }
  }
  Future<List<Message>> obtenirMessagesRecents(String utilisateurId) async {
    try {
      return await _messagesRepository.obtenirMessagesRecents(utilisateurId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des messages récents: $e');
    }
  }
  Future<Utilisateur?> obtenirExpediteur(String expediteurId) async {
    try {
      return await _utilisateursRepository.obtenirUtilisateurParId(expediteurId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'expéditeur: $e');
    }
  }
  String formaterContenuMessage(String contenu) {
    return contenu.trim();
  }
  bool validerContenuMessage(String contenu) {
    final contenuNettoye = contenu.trim();
    return contenuNettoye.isNotEmpty && contenuNettoye.length <= 1000;
  }
  String obtenirStatutLecture(Message message) {
    if (message.estLu) {
      return 'Lu';
    } else if (message.estRecent) {
      return 'Récent';
    } else {
      return 'Non lu';
    }
  }
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