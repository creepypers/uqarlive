import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/utils/associations_utils.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/utilisateur.dart';
import '../../services/messagerie_service.dart';
import '../../services/authentification_service.dart';
import '../../widgets/widget_barre_app_personnalisee.dart';
import 'conversation_ecran.dart';
import 'ajouter_contact_ecran.dart';
class ConversationsEcran extends StatefulWidget {
  const ConversationsEcran({super.key});
  @override
  State<ConversationsEcran> createState() => _ConversationsEcranState();
}
class _ConversationsEcranState extends State<ConversationsEcran> {
  late MessagerieService _messagerieService;
  late AuthentificationService _authentificationService;
  List<Message> _messages = [];
  List<Message> _conversations = [];
  List<Message> _messagesFiltres = [];
  Utilisateur? _utilisateurActuel;
  String? _utilisateurActuelId;
  bool _isLoading = true;
  String _recherche = '';
  final TextEditingController _rechercheController = TextEditingController();
  final Map<String, String> _nomsUtilisateurs = {};
  final Map<String, String> _initialesUtilisateurs = {};
  @override
  void initState() {
    super.initState();
    _initialiserServices();
    _chargerDonnees();
  }
  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }
  void _initialiserServices() {
    _messagerieService = ServiceLocator.obtenirService<MessagerieService>();
    _authentificationService = ServiceLocator.obtenirService<AuthentificationService>();
  }
  Future<void> _chargerDonnees() async {
    setState(() => _isLoading = true);
    try {
      await _authentificationService.chargerUtilisateurActuel();
      _utilisateurActuel = _authentificationService.utilisateurActuel;
      _utilisateurActuelId = _utilisateurActuel?.id;
      if (_utilisateurActuelId != null) {
        await _chargerMessages();
      }
    } catch (e) {
      _afficherErreur('Erreur lors du chargement: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  Future<void> _chargerMessages() async {
    try {
      final messages = await _messagerieService.obtenirMessagesUtilisateur(_utilisateurActuelId!);
      final Map<String, Message> conversationsMap = {};
      for (final message in messages) {
        final autreUtilisateurId = message.expediteurId == _utilisateurActuelId 
            ? message.destinataireId 
            : message.expediteurId;
        // Garder le message le plus récent pour chaque conversation
        if (!conversationsMap.containsKey(autreUtilisateurId) || 
            message.dateEnvoi.isAfter(conversationsMap[autreUtilisateurId]!.dateEnvoi)) {
          conversationsMap[autreUtilisateurId] = message;
        }
      }
      final conversations = conversationsMap.values.toList();
      conversations.sort((a, b) => b.dateEnvoi.compareTo(a.dateEnvoi));
      await _chargerInformationsUtilisateurs(conversations);
      setState(() {
        _messages = messages;
        _conversations = conversations;
        _messagesFiltres = conversations;
      });
    } catch (e) {
      _afficherErreur('Erreur lors du chargement des messages: $e');
    }
  }
  Future<void> _chargerInformationsUtilisateurs(List<Message> conversations) async {
    try {
      for (final message in conversations) {
        final autreUtilisateurId = message.expediteurId == _utilisateurActuelId 
            ? message.destinataireId 
            : message.expediteurId;
        if (!_nomsUtilisateurs.containsKey(autreUtilisateurId)) {
          final utilisateur = await _authentificationService.obtenirUtilisateurParId(autreUtilisateurId);
          if (utilisateur != null) {
            _nomsUtilisateurs[autreUtilisateurId] = '${utilisateur.prenom} ${utilisateur.nom}';
            _initialesUtilisateurs[autreUtilisateurId] = '${utilisateur.prenom[0]}${utilisateur.nom[0]}';
          } else {
            _nomsUtilisateurs[autreUtilisateurId] = _genererNomFallback(autreUtilisateurId);
            _initialesUtilisateurs[autreUtilisateurId] = _genererInitialesFallback(autreUtilisateurId);
          }
        }
      }
    } catch (e) {
      for (final message in conversations) {
        final autreUtilisateurId = message.expediteurId == _utilisateurActuelId 
            ? message.destinataireId 
            : message.expediteurId;
        if (!_nomsUtilisateurs.containsKey(autreUtilisateurId)) {
          _nomsUtilisateurs[autreUtilisateurId] = _genererNomFallback(autreUtilisateurId);
          _initialesUtilisateurs[autreUtilisateurId] = _genererInitialesFallback(autreUtilisateurId);
        }
      }
    }
  }
  String _genererNomFallback(String utilisateurId) {
    if (utilisateurId.startsWith('etud_')) {
      return 'Étudiant ${utilisateurId.substring(5, 8)}';
    } else if (utilisateurId.startsWith('prof_')) {
      return 'Professeur ${utilisateurId.substring(5, 8)}';
    } else if (utilisateurId.startsWith('admin_')) {
      return 'Admin ${utilisateurId.substring(6, 9)}';
    }
    return 'Utilisateur ${utilisateurId.substring(0, 3)}';
  }
  String _genererInitialesFallback(String utilisateurId) {
    if (utilisateurId.startsWith('etud_')) {
      return 'É${utilisateurId.substring(5, 6)}';
    } else if (utilisateurId.startsWith('prof_')) {
      return 'P${utilisateurId.substring(5, 6)}';
    } else if (utilisateurId.startsWith('admin_')) {
      return 'A${utilisateurId.substring(6, 7)}';
    }
    return 'UQ';
  }
  void _rechercherMessages(String terme) {
    setState(() {
      _recherche = terme.toLowerCase().trim();
      if (_recherche.isEmpty) {
        _messagesFiltres = _conversations;
      } else {
        _messagesFiltres = _conversations.where((msg) {
          final expediteurNom = _obtenirNomUtilisateur(msg.expediteurId);
          final destinataireNom = _obtenirNomUtilisateur(msg.destinataireId);
          final contenu = msg.contenu.toLowerCase();
          return expediteurNom.toLowerCase().contains(_recherche) ||
                 destinataireNom.toLowerCase().contains(_recherche) ||
                 contenu.contains(_recherche);
        }).toList();
      }
    });
  }
  void _ouvrirConversation(String destinataireId) {
    _conversations.firstWhere(
      (msg) => msg.expediteurId == destinataireId || msg.destinataireId == destinataireId,
      orElse: () => _messages.firstWhere(
        (msg) => msg.expediteurId == destinataireId || msg.destinataireId == destinataireId,
      ),
    );
    final destinataireNom = _obtenirNomUtilisateur(destinataireId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationEcran(
          destinataireId: destinataireId,
          destinataireNom: destinataireNom,
          destinatairePrenom: '',
        ),
      ),
    );
  }
  void _ouvrirAjouterContact() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AjouterContactEcran(),
      ),
    );
  }
  String _obtenirNomUtilisateur(String utilisateurId) {
    if (utilisateurId == _utilisateurActuelId) {
      return 'Moi';
    }
    return _nomsUtilisateurs[utilisateurId] ?? _genererNomFallback(utilisateurId);
  }
  String _obtenirInitialesUtilisateur(String utilisateurId) {
    if (utilisateurId == _utilisateurActuelId) {
      return 'M';
    }
    return _initialesUtilisateurs[utilisateurId] ?? 
           TransactionsUtils.obtenirInitialesUtilisateur(utilisateurId);
  }
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
      appBar: WidgetBarreAppPersonnalisee(
        titre: 'Conversations',
        sousTitre: 'Vos échanges',
        afficherBoutonRetour: true,
        widgetFin: IconButton(
          onPressed: _ouvrirAjouterContact,
          icon: const Icon(Icons.person_add, color: Colors.white),
          tooltip: 'Ajouter un contact',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barre de recherche moderne
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CouleursApp.blanc,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: CouleursApp.principal.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _rechercheController,
                onChanged: _rechercherMessages,
                decoration: InputDecoration(
                  hintText: '🔍 Rechercher dans vos conversations...',
                  hintStyle: TextStyle(
                    color: CouleursApp.texteFonce.withValues(alpha: 0.5),
                    fontSize: 16,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: const Icon(
                      Icons.search,
                      color: CouleursApp.principal,
                      size: 22,
                    ),
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
            ),
            // Liste des conversations
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(CouleursApp.principal),
                      ),
                    )
                  : _messagesFiltres.isEmpty
                      ? _construireEtatVide()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _messagesFiltres.length,
                          itemBuilder: (context, index) {
                            final message = _messagesFiltres[index];
                            final destinataireId = message.expediteurId == _utilisateurActuelId
                                ? message.destinataireId
                                : message.expediteurId;
                            return _construireCarteConversation(message, destinataireId);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _construireEtatVide() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: CouleursApp.principal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 50,
              color: CouleursApp.principal,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Aucune conversation',
            style: StylesTexteApp.titre.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez par envoyer un message\nou ajoutez des contacts',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: CouleursApp.texteFonce.withValues(alpha: 0.6),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _ouvrirAjouterContact,
            icon: const Icon(Icons.person_add, size: 18),
            label: const Text('Ajouter un contact'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CouleursApp.principal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }
  Widget _construireCarteConversation(Message message, String destinataireId) {
    final estExpediteur = message.expediteurId == _utilisateurActuelId;
    final destinataireNom = _obtenirNomUtilisateur(destinataireId);
    final initiales = _obtenirInitialesUtilisateur(destinataireId);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _ouvrirConversation(destinataireId),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar avec indicateur de statut
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: CouleursApp.principal.withValues(alpha: 0.1),
                      child: Text(
                        initiales,
                        style: const TextStyle(
                          color: CouleursApp.principal,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    // Indicateur de statut (en ligne/hors ligne)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: CouleursApp.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: CouleursApp.blanc, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Informations de la conversation
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête avec nom et heure
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              destinataireNom,
                              style: StylesTexteApp.titre.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: CouleursApp.fond,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatterDate(message.dateEnvoi),
                              style: TextStyle(
                                fontSize: 11,
                                color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Contenu du message
                      Text(
                        message.contenu,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Indicateur de statut du message
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: estExpediteur 
                                  ? CouleursApp.principal.withValues(alpha: 0.1)
                                  : CouleursApp.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  estExpediteur ? Icons.done_all : Icons.call_received,
                                  size: 12,
                                  color: estExpediteur ? CouleursApp.principal : CouleursApp.accent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  estExpediteur ? 'Envoyé' : 'Reçu',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: estExpediteur ? CouleursApp.principal : CouleursApp.accent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Indicateur de type de message
                          if (message.typeMessage == 'general')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: CouleursApp.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Général',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: CouleursApp.accent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  String _formatterDate(DateTime date) {
    final maintenant = DateTime.now();
    final difference = maintenant.difference(date);
    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'À l\'instant';
    }
  }
}