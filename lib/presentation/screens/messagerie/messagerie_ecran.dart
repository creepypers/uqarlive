// UI Design: Écran de messagerie principal pour UqarLife
// ignore_for_file: unused_import, prefer_final_fields, unused_field, prefer_const_constructors, unused_local_variable

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/utilisateur.dart';
import '../../../domain/repositories/utilisateurs_repository.dart';
import '../../services/messagerie_service.dart';
import '../../services/authentification_service.dart';
import 'conversation_ecran.dart';
import 'ajouter_contact_ecran.dart';

class MessagerieEcran extends StatefulWidget {
  const MessagerieEcran({super.key});

  @override
  State<MessagerieEcran> createState() => _MessagerieEcranState();
}

class _MessagerieEcranState extends State<MessagerieEcran> with TickerProviderStateMixin {
  late TabController _tabController;
  late MessagerieService _messagerieService;
  late AuthentificationService _authentificationService;
  
  List<Message> _messages = [];
  List<Message> _conversations = [];
  bool _isLoading = true;
  String? _utilisateurActuelId;
  
  final TextEditingController _rechercheController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _destinataireController = TextEditingController();
  
  // UI Design: Variables pour la recherche
  List<Message> _messagesFiltres = [];
  List<Message> _conversationsFiltrees = [];
  bool _rechercheActive = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initialiserServices();
    _chargerMessages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rechercheController.dispose();
    _messageController.dispose();
    _destinataireController.dispose();
    super.dispose();
  }

  // UI Design: Initialiser les services
  Future<void> _initialiserServices() async {
    try {
      // UI Design: Initialiser les services de messagerie et d'authentification
      _authentificationService = AuthentificationService.instance;
      _utilisateurActuelId = _authentificationService.utilisateurActuel?.id;
      
      // UI Design: Injecter le service de messagerie via le service locator
      _messagerieService = ServiceLocator.obtenirService<MessagerieService>();
      
      setState(() {});
    } catch (e) {
      _afficherErreur('Erreur d\'initialisation: $e');
    }
  }

  // UI Design: Charger les messages de l'utilisateur
  Future<void> _chargerMessages() async {
    if (_utilisateurActuelId == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      // UI Design: Utiliser le service de messagerie
      _messages = await _messagerieService.obtenirMessagesUtilisateur(_utilisateurActuelId!);
      _conversations = await _messagerieService.obtenirMessagesRecents(_utilisateurActuelId!);
      
      // UI Design: Initialiser les listes filtrées
      _messagesFiltres = List.from(_messages);
      _conversationsFiltrees = List.from(_conversations);
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _afficherErreur('Erreur lors du chargement des messages: $e');
    }
  }

  // UI Design: Implémenter la recherche
  void _rechercherMessages(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _rechercheActive = false;
        _messagesFiltres = List.from(_messages);
        _conversationsFiltrees = List.from(_conversations);
      });
      return;
    }

    setState(() {
      _rechercheActive = true;
      final queryLower = query.toLowerCase();
      
      // UI Design: Filtrer les messages
      _messagesFiltres = _messages.where((message) {
        return message.contenu.toLowerCase().contains(queryLower);
      }).toList();
      
      // UI Design: Filtrer les conversations
      _conversationsFiltrees = _conversations.where((conversation) {
        return conversation.contenu.toLowerCase().contains(queryLower);
      }).toList();
    });
  }

  // UI Design: Afficher une erreur
  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // UI Design: Afficher un succès
  void _afficherSucces(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // UI Design: Rechercher un utilisateur par email ou nom
  Future<String?> _rechercherUtilisateur(String query) async {
    if (query.trim().isEmpty) return null;
    
    try {
      // UI Design: Utiliser le repository des utilisateurs pour rechercher
      final utilisateursRepository = ServiceLocator.obtenirService<UtilisateursRepository>();
      final utilisateurs = await utilisateursRepository.rechercherUtilisateurs(query.trim());
      if (utilisateurs.isNotEmpty) {
        return utilisateurs.first.id;
      }
      return null;
    } catch (e) {
      _afficherErreur('Erreur lors de la recherche: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: _construireAppBar(),
      body: Column(
        children: [
          _construireBarreRecherche(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _construireOngletMessages(),
                _construireOngletConversations(),
                _construireOngletContacts(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _construireFloatingActionButton(),
    );
  }

  // UI Design: Construire l'AppBar
  PreferredSizeWidget _construireAppBar() {
    return AppBar(
      title: Text(
        'Messagerie',
        style: StylesTexteApp.titre.copyWith(
          color: CouleursApp.blanc,
          fontSize: 24,
        ),
      ),
      backgroundColor: CouleursApp.principal,
      elevation: 0,
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: CouleursApp.accent,
        indicatorWeight: 3,
        labelColor: CouleursApp.blanc,
        unselectedLabelColor: CouleursApp.blanc.withValues(alpha: 0.7),
        tabs: const [
          Tab(
            icon: Icon(Icons.message),
            text: 'Messages',
          ),
          Tab(
            icon: Icon(Icons.chat_bubble),
            text: 'Conversations',
          ),
          Tab(
            icon: Icon(Icons.people),
            text: 'Contacts',
          ),
        ],
      ),
    );
  }

  // UI Design: Construire la barre de recherche
  Widget _construireBarreRecherche() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _rechercheController,
        decoration: InputDecoration(
          hintText: 'Rechercher dans les messages...',
          hintStyle: StylesTexteApp.champ.copyWith(
            color: CouleursApp.texteFonce.withValues(alpha: 0.5),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: CouleursApp.principal,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        onChanged: _rechercherMessages,
      ),
    );
  }

  // UI Design: Construire l'onglet Messages
  Widget _construireOngletMessages() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(CouleursApp.principal),
        ),
      );
    }

    final messagesAAfficher = _rechercheActive ? _messagesFiltres : _messages;

    if (messagesAAfficher.isEmpty) {
      return _construireEtatVide(
        icon: Icons.message_outlined,
        titre: _rechercheActive ? 'Aucun résultat' : 'Aucun message',
        description: _rechercheActive 
            ? 'Aucun message ne correspond à votre recherche'
            : 'Vous n\'avez pas encore reçu de messages',
        couleur: CouleursApp.principal,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messagesAAfficher.length,
      itemBuilder: (context, index) {
        final message = messagesAAfficher[index];
        return _construireCarteMessage(message);
      },
    );
  }

  // UI Design: Construire l'onglet Conversations
  Widget _construireOngletConversations() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(CouleursApp.principal),
        ),
      );
    }

    final conversationsAAfficher = _rechercheActive ? _conversationsFiltrees : _conversations;

    if (conversationsAAfficher.isEmpty) {
      return _construireEtatVide(
        icon: Icons.chat_bubble_outline,
        titre: _rechercheActive ? 'Aucun résultat' : 'Aucune conversation',
        description: _rechercheActive 
            ? 'Aucune conversation ne correspond à votre recherche'
            : 'Commencez une conversation avec d\'autres étudiants',
        couleur: CouleursApp.accent,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: conversationsAAfficher.length,
      itemBuilder: (context, index) {
        final conversation = conversationsAAfficher[index];
        return _construireCarteConversation(conversation);
      },
    );
  }

  // UI Design: Construire l'onglet Contacts
  Widget _construireOngletContacts() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: CouleursApp.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline,
              size: 60,
              color: CouleursApp.accent,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Contacts',
            style: StylesTexteApp.titre.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 12),
          Text(
            'Gérez vos contacts et\ncréez de nouvelles conversations',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: CouleursApp.texteFonce.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // UI Design: Implémenter l'ajout de contacts
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AjouterContactEcran(),
                ),
              );
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Ajouter un contact'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CouleursApp.accent,
              foregroundColor: CouleursApp.blanc,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Construire une carte de message
  Widget _construireCarteMessage(Message message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: CouleursApp.principal.withValues(alpha: 0.2),
          child: Text(
            _obtenirInitialesUtilisateur(message.expediteurId),
            style:const TextStyle(
              color: CouleursApp.principal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          _obtenirNomUtilisateur(message.expediteurId),
          style: StylesTexteApp.moyenTitre.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message.contenu,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: StylesTexteApp.champ.copyWith(
                color: CouleursApp.texteFonce.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: CouleursApp.texteFonce.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  message.tempsEcoule,
                  style: TextStyle(
                    fontSize: 12,
                    color: CouleursApp.texteFonce.withValues(alpha: 0.5),
                  ),
                ),
                const Spacer(),
                if (!message.estLu)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: CouleursApp.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
        onTap: () {
          // UI Design: Ouvrir la conversation
          _ouvrirConversation(message.expediteurId, message.destinataireId);
        },
      ),
    );
  }

  // UI Design: Construire une carte de conversation
  Widget _construireCarteConversation(Message conversation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.accent.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: CouleursApp.accent.withValues(alpha: 0.2),
          child: Text(
            _obtenirInitialesUtilisateur(conversation.expediteurId),
            style:const TextStyle(
              color: CouleursApp.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          _obtenirNomUtilisateur(conversation.expediteurId),
          style: StylesTexteApp.moyenTitre.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Dernier message: ${conversation.contenu}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: StylesTexteApp.champ.copyWith(
            color: CouleursApp.texteFonce.withValues(alpha: 0.7),
          ),
        ),
        trailing: Text(
          conversation.tempsEcoule,
          style: TextStyle(
            fontSize: 12,
            color: CouleursApp.texteFonce.withValues(alpha: 0.5),
          ),
        ),
        onTap: () {
          // UI Design: Ouvrir la conversation
          _ouvrirConversation(conversation.expediteurId, conversation.destinataireId);
        },
      ),
    );
  }

      // UI Design: Obtenir les initiales d'un utilisateur
  String _obtenirInitialesUtilisateur(String utilisateurId) {
    if (utilisateurId == _utilisateurActuelId) {
      final utilisateur = _authentificationService.utilisateurActuel;
      if (utilisateur != null) {
        return '${utilisateur.prenom[0]}${utilisateur.nom[0]}'.toUpperCase();
      }
    }
    
    // UI Design: Retourner des initiales par défaut
    return 'UQ';
  }

  // UI Design: Obtenir le nom d'un utilisateur
  String _obtenirNomUtilisateur(String utilisateurId) {
    if (utilisateurId == _utilisateurActuelId) {
      final utilisateur = _authentificationService.utilisateurActuel;
      if (utilisateur != null) {
        return '${utilisateur.prenom} ${utilisateur.nom}';
      }
    }
    
    // UI Design: Retourner un nom par défaut
    return 'Utilisateur';
  }

  // UI Design: Ouvrir une conversation
  void _ouvrirConversation(String expediteurId, String destinataireId) {
    final destinataireIdFinal = expediteurId == _utilisateurActuelId 
        ? destinataireId 
        : expediteurId;
    
    final destinataireNom = _obtenirNomUtilisateur(destinataireIdFinal);
    final parties = destinataireNom.split(' ');
    final destinatairePrenom = parties.isNotEmpty ? parties.first : '';
    final destinataireNomFinal = parties.length > 1 ? parties.sublist(1).join(' ') : '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationEcran(
          destinataireId: destinataireIdFinal,
          destinataireNom: destinataireNomFinal,
          destinatairePrenom: destinatairePrenom,
        ),
      ),
    );
  }

  // UI Design: Construire l'état vide
  Widget _construireEtatVide({
    required IconData icon,
    required String titre,
    required String description,
    required Color couleur,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: couleur.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 60,
              color: couleur,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            titre,
            style: StylesTexteApp.titre.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: CouleursApp.texteFonce.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Construire le FloatingActionButton
  Widget _construireFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        _afficherModalNouveauMessage();
      },
      backgroundColor: CouleursApp.accent,
      child: const Icon(
        Icons.edit,
        color: CouleursApp.blanc,
      ),
    );
  }

  // UI Design: Afficher le modal de nouveau message
  void _afficherModalNouveauMessage() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _construireModalNouveauMessage(),
    );
  }

  // UI Design: Construire le modal de nouveau message
  Widget _construireModalNouveauMessage() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Titre
          Text(
            'Nouveau message',
            style: StylesTexteApp.titre.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 20),
          
          // Destinataire
          TextFormField(
            controller: _destinataireController,
            decoration: InputDecoration(
              labelText: 'Destinataire',
              hintText: 'Entrez l\'email ou le nom',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          
          // Message
          TextFormField(
            controller: _messageController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Message',
              hintText: 'Tapez votre message...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          
          // Boutons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_messageController.text.trim().isEmpty) {
                      _afficherErreur('Veuillez saisir un message');
                      return;
                    }
                    
                    // UI Design: Envoyer le message
                    try {
                      // UI Design: Vérifier que le destinataire est spécifié
                      final destinataireQuery = _destinataireController.text.trim();
                      if (destinataireQuery.isEmpty) {
                        _afficherErreur('Veuillez spécifier un destinataire');
                        return;
                      }

                      // UI Design: Rechercher l'utilisateur destinataire
                      final destinataireId = await _rechercherUtilisateur(destinataireQuery);
                      if (destinataireId == null) {
                        _afficherErreur('Destinataire non trouvé. Vérifiez l\'email ou le nom.');
                        return;
                      }

                      // UI Design: Vérifier que l'utilisateur ne s'envoie pas un message à lui-même
                      if (destinataireId == _utilisateurActuelId) {
                        _afficherErreur('Vous ne pouvez pas vous envoyer un message à vous-même');
                        return;
                      }

                      // UI Design: Envoyer le message via le service de messagerie
                      final message = await _messagerieService.envoyerMessageGeneral(
                        expediteurId: _utilisateurActuelId!,
                        destinataireId: destinataireId,
                        contenu: _messageController.text.trim(),
                        typeMessage: 'general',
                      );

                      Navigator.pop(context);
                      _afficherSucces('Message envoyé à ${_obtenirNomUtilisateur(destinataireId)} !');
                      _messageController.clear();
                      _destinataireController.clear();
                      
                      // UI Design: Recharger les messages
                      await _chargerMessages();
                    } catch (e) {
                      _afficherErreur('Erreur lors de l\'envoi: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CouleursApp.principal,
                    foregroundColor: CouleursApp.blanc,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Envoyer'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
