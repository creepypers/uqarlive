// UI Design: Écran de conversation pour UqarLife - Affichage des messages entre deux utilisateurs
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/utilisateur.dart';
import '../../services/messagerie_service.dart';
import '../../services/authentification_service.dart';

class ConversationEcran extends StatefulWidget {
  final String destinataireId;
  final String? destinataireNom;
  final String? destinatairePrenom;

  const ConversationEcran({
    super.key,
    required this.destinataireId,
    this.destinataireNom,
    this.destinatairePrenom,
  });

  @override
  State<ConversationEcran> createState() => _ConversationEcranState();
}

class _ConversationEcranState extends State<ConversationEcran> {
  late MessagerieService _messagerieService;
  late AuthentificationService _authentificationService;
  
  List<Message> _messages = [];
  bool _isLoading = true;
  String? _utilisateurActuelId;
  Utilisateur? _destinataire;
  
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initialiserServices();
    _chargerConversation();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // UI Design: Initialiser les services
  Future<void> _initialiserServices() async {
    try {
      _authentificationService = AuthentificationService.instance;
      _utilisateurActuelId = _authentificationService.utilisateurActuel?.id;
      
      // UI Design: Injecter le service de messagerie via le service locator
      _messagerieService = ServiceLocator.obtenirService<MessagerieService>();
      
      setState(() {});
    } catch (e) {
      _afficherErreur('Erreur d\'initialisation: $e');
    }
  }

  // UI Design: Charger la conversation
  Future<void> _chargerConversation() async {
    if (_utilisateurActuelId == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      // UI Design: Charger la conversation et les informations du destinataire
      _messages = await _messagerieService.obtenirConversation(
        _utilisateurActuelId!,
        widget.destinataireId,
      );
      
      _destinataire = await _messagerieService.obtenirExpediteur(widget.destinataireId);
      
      setState(() => _isLoading = false);
      
      // UI Design: Faire défiler vers le bas pour voir les derniers messages
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients && _messages.isNotEmpty) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _afficherErreur('Erreur lors du chargement de la conversation: $e');
    }
  }

  // UI Design: Envoyer un message
  Future<void> _envoyerMessage() async {
    if (_messageController.text.trim().isEmpty || _utilisateurActuelId == null) return;
    
    try {
      final nouveauMessage = await _messagerieService.envoyerMessageGeneral(
        expediteurId: _utilisateurActuelId!,
        destinataireId: widget.destinataireId,
        contenu: _messageController.text.trim(),
        typeMessage: 'general',
      );
      
      setState(() {
        _messages.add(nouveauMessage);
      });
      
      _messageController.clear();
      
      // UI Design: Faire défiler vers le bas pour voir le nouveau message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      _afficherErreur('Erreur lors de l\'envoi du message: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: _construireAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(CouleursApp.principal),
                    ),
                  )
                : _construireListeMessages(),
          ),
          _construireBarreSaisie(),
        ],
      ),
    );
  }

  // UI Design: Construire l'AppBar
  PreferredSizeWidget _construireAppBar() {
    final nomComplet = _destinataire != null
        ? '${_destinataire!.prenom} ${_destinataire!.nom}'
        : widget.destinataireNom != null && widget.destinatairePrenom != null
            ? '${widget.destinatairePrenom} ${widget.destinataireNom}'
            : 'Conversation';

    return AppBar(
      title: Text(
        nomComplet,
        style: StylesTexteApp.titre.copyWith(
          color: CouleursApp.blanc,
          fontSize: 20,
        ),
      ),
      backgroundColor: CouleursApp.principal,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: CouleursApp.blanc),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  // UI Design: Construire la liste des messages
  Widget _construireListeMessages() {
    if (_messages.isEmpty) {
      return _construireEtatVide();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final estMoi = message.expediteurId == _utilisateurActuelId;
        return _construireBulleMessage(message, estMoi);
      },
    );
  }

  // UI Design: Construire une bulle de message
  Widget _construireBulleMessage(Message message, bool estMoi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: estMoi ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!estMoi) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: CouleursApp.principal.withValues(alpha: 0.2),
              child: Text(
                _obtenirInitiales(message.expediteurId),
                style: TextStyle(
                  fontSize: 12,
                  color: CouleursApp.principal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: estMoi ? CouleursApp.principal : CouleursApp.blanc,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: estMoi ? const Radius.circular(20) : const Radius.circular(5),
                  bottomRight: estMoi ? const Radius.circular(5) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: CouleursApp.principal.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.contenu,
                    style: StylesTexteApp.champ.copyWith(
                      color: estMoi ? CouleursApp.blanc : CouleursApp.texteFonce,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.tempsEcoule,
                    style: TextStyle(
                      fontSize: 11,
                      color: estMoi 
                          ? CouleursApp.blanc.withValues(alpha: 0.7)
                          : CouleursApp.texteFonce.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (estMoi) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: CouleursApp.accent.withValues(alpha: 0.2),
              child: Text(
                _obtenirInitiales(_utilisateurActuelId ?? ''),
                style: TextStyle(
                  fontSize: 12,
                  color: CouleursApp.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // UI Design: Obtenir les initiales d'un utilisateur
  String _obtenirInitiales(String utilisateurId) {
    if (utilisateurId == _utilisateurActuelId) {
      final utilisateur = _authentificationService.utilisateurActuel;
      if (utilisateur != null) {
        return '${utilisateur.prenom[0]}${utilisateur.nom[0]}'.toUpperCase();
      }
    } else if (_destinataire != null) {
      return '${_destinataire!.prenom[0]}${_destinataire!.nom[0]}'.toUpperCase();
    }
    return 'UQ';
  }

  // UI Design: Construire l'état vide
  Widget _construireEtatVide() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: CouleursApp.principal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: CouleursApp.principal,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun message',
            style: StylesTexteApp.titre.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 12),
          Text(
            'Commencez la conversation en envoyant\nvotre premier message',
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

  // UI Design: Construire la barre de saisie
  Widget _construireBarreSaisie() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Tapez votre message...',
                hintStyle: StylesTexteApp.champ.copyWith(
                  color: CouleursApp.texteFonce.withValues(alpha: 0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: CouleursApp.fond,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _envoyerMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: CouleursApp.principal,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _envoyerMessage,
              icon: const Icon(
                Icons.send,
                color: CouleursApp.blanc,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
