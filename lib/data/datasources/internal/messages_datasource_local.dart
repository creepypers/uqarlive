// UI Design: Datasource local pour la gestion des messages dans UqarLife
import '../../models/message_model.dart';

class MessagesDatasourceLocal {
  // UI Design: Liste des messages en mémoire (simulation d'une base de données locale)
  static final List<MessageModel> _messages = [
    // UI Design: Messages d'exemple pour les transactions de livres
    MessageModel(
      id: 'msg_001',
      expediteurId: 'etud_002',
      destinataireId: 'etud_001',
      contenu: 'Bonjour ! Je suis intéressé par votre livre "Calcul Différentiel et Intégral". Est-il toujours disponible ?',
      dateEnvoi: DateTime.now().subtract(const Duration(hours: 2)),
      estLu: false,
      typeMessage: 'transaction',
      referenceId: '1', // ID du livre
    ),
    MessageModel(
      id: 'msg_002',
      expediteurId: 'etud_001',
      destinataireId: 'etud_002',
      contenu: 'Oui, le livre est toujours disponible ! Je peux vous le proposer en échange contre un livre de physique.',
      dateEnvoi: DateTime.now().subtract(const Duration(hours: 1)),
      estLu: true,
      typeMessage: 'transaction',
      referenceId: '1',
    ),
    MessageModel(
      id: 'msg_003',
      expediteurId: 'etud_003',
      destinataireId: 'etud_001',
      contenu: 'Salut ! J\'ai "Physique Générale" de Halliday. Ça vous intéresserait pour un échange ?',
      dateEnvoi: DateTime.now().subtract(const Duration(minutes: 30)),
      estLu: false,
      typeMessage: 'transaction',
      referenceId: '2',
    ),
    MessageModel(
      id: 'msg_004',
      expediteurId: 'etud_004',
      destinataireId: 'etud_001',
      contenu: 'Bonjour Alexandre, votre livre "Chimie Organique" m\'intéresse beaucoup. Pouvez-vous me donner plus de détails sur son état ?',
      dateEnvoi: DateTime.now().subtract(const Duration(minutes: 15)),
      estLu: false,
      typeMessage: 'transaction',
      referenceId: '3',
    ),
    // UI Design: Messages généraux
    MessageModel(
      id: 'msg_005',
      expediteurId: 'admin_001',
      destinataireId: 'etud_001',
      contenu: 'Bienvenue sur UqarLife ! N\'hésitez pas à nous contacter si vous avez des questions.',
      dateEnvoi: DateTime.now().subtract(const Duration(days: 1)),
      estLu: true,
      typeMessage: 'general',
    ),
    MessageModel(
      id: 'msg_006',
      expediteurId: 'etud_002',
      destinataireId: 'etud_001',
      contenu: 'Salut Alexandre ! Comment ça va ?',
      dateEnvoi: DateTime.now().subtract(const Duration(hours: 3)),
      estLu: false,
      typeMessage: 'general',
    ),
    MessageModel(
      id: 'msg_007',
      expediteurId: 'etud_001',
      destinataireId: 'etud_002',
      contenu: 'Salut Sophie ! Ça va bien, merci ! Et toi ?',
      dateEnvoi: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      estLu: true,
      typeMessage: 'general',
    ),
    MessageModel(
      id: 'msg_008',
      expediteurId: 'etud_003',
      destinataireId: 'etud_001',
      contenu: 'Hey ! Tu as des nouvelles de l\'examen de maths ?',
      dateEnvoi: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      estLu: false,
      typeMessage: 'general',
    ),
    MessageModel(
      id: 'msg_009',
      expediteurId: 'etud_004',
      destinataireId: 'etud_001',
      contenu: 'Bonjour ! As-tu des informations sur le prochain événement de l\'association ?',
      dateEnvoi: DateTime.now().subtract(const Duration(minutes: 45)),
      estLu: false,
      typeMessage: 'general',
    ),
    MessageModel(
      id: 'msg_010',
      expediteurId: 'etud_001',
      destinataireId: 'etud_004',
      contenu: 'Oui ! Il y a une réunion demain à 18h. Tu veux que je t\'envoie les détails ?',
      dateEnvoi: DateTime.now().subtract(const Duration(minutes: 30)),
      estLu: true,
      typeMessage: 'general',
    ),
  ];

  // UI Design: Méthode pour obtenir tous les messages d'un utilisateur
  Future<List<MessageModel>> obtenirMessagesUtilisateur(String utilisateurId) async {
    try {
      // UI Design: Simuler un délai réseau
      await Future.delayed(const Duration(milliseconds: 300));
      
      // UI Design: Retourner les messages où l'utilisateur est expéditeur ou destinataire
      return _messages.where((message) => 
        (message.expediteurId == utilisateurId) || 
        (message.destinataireId == utilisateurId)
      ).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des messages: $e');
    }
  }

  // UI Design: Méthode pour obtenir la conversation entre deux utilisateurs
  Future<List<MessageModel>> obtenirConversation(String utilisateur1Id, String utilisateur2Id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      
      return _messages.where((message) => 
        (message.expediteurId == utilisateur1Id && message.destinataireId == utilisateur2Id) ||
        (message.expediteurId == utilisateur2Id && message.destinataireId == utilisateur1Id)
      ).toList()
        ..sort((a, b) => a.dateEnvoi.compareTo(b.dateEnvoi));
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la conversation: $e');
    }
  }

  // UI Design: Méthode pour envoyer un nouveau message
  Future<MessageModel> envoyerMessage(MessageModel message) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // UI Design: Générer un ID unique pour le nouveau message
      final nouveauMessage = MessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        expediteurId: message.expediteurId,
        destinataireId: message.destinataireId,
        contenu: message.contenu,
        dateEnvoi: DateTime.now(),
        estLu: false,
        typeMessage: message.typeMessage,
        referenceId: message.referenceId,
        pieceJointe: message.pieceJointe,
      );
      
      // UI Design: Ajouter le message à la liste locale et le sauvegarder
      _messages.add(nouveauMessage);
      await _sauvegarderMessages();
      
      return nouveauMessage;
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du message: $e');
    }
  }

  // UI Design: Méthode pour marquer un message comme lu
  Future<void> marquerMessageCommeLu(String messageId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final index = _messages.indexWhere((message) => message.id == messageId);
      if (index != -1) {
        final message = _messages[index];
        _messages[index] = MessageModel(
          id: message.id,
          expediteurId: message.expediteurId,
          destinataireId: message.destinataireId,
          contenu: message.contenu,
          dateEnvoi: message.dateEnvoi,
          estLu: true,
          typeMessage: message.typeMessage,
          referenceId: message.referenceId,
          pieceJointe: message.pieceJointe,
        );
      }
    } catch (e) {
      throw Exception('Erreur lors du marquage du message: $e');
    }
  }

  // UI Design: Méthode pour obtenir le nombre de messages non lus
  Future<int> obtenirNombreMessagesNonLus(String utilisateurId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      return _messages.where((message) => 
        message.destinataireId == utilisateurId && !message.estLu
      ).length;
    } catch (e) {
      throw Exception('Erreur lors du comptage des messages: $e');
    }
  }

  // UI Design: Méthode pour supprimer un message
  Future<void> supprimerMessage(String messageId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      
      _messages.removeWhere((message) => message.id == messageId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du message: $e');
    }
  }

  // UI Design: Méthode pour obtenir les messages récents (dernières 24h)
  Future<List<MessageModel>> obtenirMessagesRecents(String utilisateurId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      
      final maintenant = DateTime.now();
      final vingtQuatreHeures = maintenant.subtract(const Duration(hours: 24));
      
      return _messages.where((message) => 
        (message.expediteurId == utilisateurId || message.destinataireId == utilisateurId) &&
        message.dateEnvoi.isAfter(vingtQuatreHeures)
      ).toList()
        ..sort((a, b) => b.dateEnvoi.compareTo(a.dateEnvoi));
    } catch (e) {
      throw Exception('Erreur lors de la récupération des messages récents: $e');
    }
  }

  // UI Design: Méthode pour sauvegarder les messages (simulation de persistance)
  Future<void> _sauvegarderMessages() async {
    try {
      // UI Design: Simuler la sauvegarde en base de données
      await Future.delayed(const Duration(milliseconds: 100));
      // En production, ici on sauvegarderait dans une vraie base de données
      // Pour l'instant, on garde en mémoire
    } catch (e) {
      // Ignorer les erreurs de sauvegarde pour l'instant
    }
  }
}
