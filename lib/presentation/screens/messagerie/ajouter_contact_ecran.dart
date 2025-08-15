// UI Design: Écran pour ajouter des contacts dans la messagerie UqarLife
// ignore_for_file: unnecessary_string_escapes, prefer_const_constructors

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/utilisateur.dart';
import '../../../domain/repositories/utilisateurs_repository.dart';
import '../../services/authentification_service.dart';
import '../../widgets/widget_barre_app_personnalisee.dart';
import '../../widgets/widget_collection.dart';
import 'conversation_ecran.dart';

class AjouterContactEcran extends StatefulWidget {
  const AjouterContactEcran({super.key});

  @override
  State<AjouterContactEcran> createState() => _AjouterContactEcranState();
}

class _AjouterContactEcranState extends State<AjouterContactEcran> {
  late AuthentificationService _authentificationService;
  late UtilisateursRepository _utilisateursRepository;
  
  final TextEditingController _rechercheController = TextEditingController();
  List<Utilisateur> _tousUtilisateurs = [];
  List<Utilisateur> _utilisateursFiltres = [];
  bool _isLoading = false;
  String? _utilisateurActuelId;

  @override
  void initState() {
    super.initState();
    _initialiserServices();
  }

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  // UI Design: Initialiser les services
  Future<void> _initialiserServices() async {
    try {
      _authentificationService = AuthentificationService.instance;
      _utilisateursRepository = ServiceLocator.obtenirService<UtilisateursRepository>();
      _utilisateurActuelId = _authentificationService.utilisateurActuel?.id;
      
      // UI Design: Charger tous les utilisateurs au démarrage
      await _chargerTousUtilisateurs();
      
      setState(() {});
    } catch (e) {
      _afficherErreur('Erreur d\'initialisation: $e');
    }
  }

  // UI Design: Charger tous les utilisateurs
  Future<void> _chargerTousUtilisateurs() async {
    try {
      setState(() => _isLoading = true);
      
      // UI Design: Charger tous les utilisateurs depuis le repository
      final utilisateurs = await _utilisateursRepository.obtenirTousLesUtilisateurs();
      
      // UI Design: Exclure l'utilisateur actuel et filtrer les utilisateurs actifs
      _tousUtilisateurs = utilisateurs
          .where((u) => u.id != _utilisateurActuelId && u.estActif)
          .toList();
      
      // UI Design: Initialiser la liste filtrée avec tous les utilisateurs
      _utilisateursFiltres = List.from(_tousUtilisateurs);
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _afficherErreur('Erreur lors du chargement des utilisateurs: $e');
    }
  }

  // UI Design: Rechercher des utilisateurs
  void _rechercherUtilisateurs(String query) {
    if (query.trim().isEmpty) {
      setState(() => _utilisateursFiltres = _tousUtilisateurs);
      return;
    }

    final queryLower = query.toLowerCase();
    final utilisateursFiltres = _tousUtilisateurs.where((utilisateur) {
      final nomComplet = '${utilisateur.prenom} ${utilisateur.nom}'.toLowerCase();
      final email = utilisateur.email.toLowerCase();
      final programme = utilisateur.programme.toLowerCase();
      
      return nomComplet.contains(queryLower) || 
             email.contains(queryLower) ||
             programme.contains(queryLower);
    }).toList();

    setState(() => _utilisateursFiltres = utilisateursFiltres);
  }

  // UI Design: Démarrer une conversation avec un utilisateur
  void _demarrerConversation(Utilisateur utilisateur) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationEcran(
          destinataireId: utilisateur.id,
          destinataireNom: utilisateur.nom,
          destinatairePrenom: utilisateur.prenom,
        ),
      ),
    );
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
          _construireBarreRecherche(),
          Expanded(
            child: _construireListeUtilisateurs(),
          ),
        ],
      ),
    );
  }

  // UI Design: Construire l'AppBar personnalisé
  PreferredSizeWidget _construireAppBar() {
    return WidgetBarreAppPersonnalisee(
      titre: 'Ajouter un contact',
      sousTitre: 'Trouver de nouveaux contacts',
      afficherBoutonRetour: true,
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
          hintText: 'Rechercher par nom, email ou programme...',
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
        onChanged: _rechercherUtilisateurs,
      ),
    );
  }

  // UI Design: Construire la liste des utilisateurs
  Widget _construireListeUtilisateurs() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(CouleursApp.principal),
        ),
      );
    }

    if (_utilisateursFiltres.isEmpty) {
      if (_rechercheController.text.trim().isEmpty) {
        return _construireEtatVide();
      } else {
        return _construireAucunResultat();
      }
    }

    // UI Design: Utiliser WidgetCollection pour afficher la liste
    return WidgetCollection<Utilisateur>.listeVerticale(
      elements: _utilisateursFiltres,
      enChargement: false,
      constructeurElement: (context, utilisateur, index) => _construireCarteUtilisateur(utilisateur),
      espacementVertical: 12,
      messageEtatVide: 'Aucun utilisateur trouvé',
      iconeEtatVide: Icons.person_search,
      padding: const EdgeInsets.all(16),
    );
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
              color: CouleursApp.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_search,
              size: 60,
              color: CouleursApp.accent,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Rechercher des contacts',
            style: StylesTexteApp.titre.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 12),
          Text(
            'Tapez un nom, email ou programme\npour trouver d\'autres étudiants',
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

  // UI Design: Construire l'état aucun résultat
  Widget _construireAucunResultat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: CouleursApp.texteFonce.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 60,
              color: CouleursApp.texteFonce.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun résultat',
            style: StylesTexteApp.titre.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun utilisateur ne correspond\à votre recherche',
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

  // UI Design: Construire une carte d'utilisateur avec layout flexible
  Widget _construireCarteUtilisateur(Utilisateur utilisateur) {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 25,
              backgroundColor: CouleursApp.principal.withValues(alpha: 0.2),
              child: Text(
                '${utilisateur.prenom[0]}${utilisateur.nom[0]}'.toUpperCase(),
                style: TextStyle(
                  color: CouleursApp.principal,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Informations utilisateur
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom complet
                  Text(
                    '${utilisateur.prenom} ${utilisateur.nom}',
                    style: StylesTexteApp.moyenTitre.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 3),
                  
                  // Email
                  Text(
                    utilisateur.email,
                    style: StylesTexteApp.champ.copyWith(
                      color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 3),
                  
                  // Programme et niveau
                  Row(
                    children: [
                      Icon(
                        Icons.school,
                        size: 12,
                        color: CouleursApp.accent,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${utilisateur.programme} - ${utilisateur.niveauEtude}',
                          style: TextStyle(
                            fontSize: 10,
                            color: CouleursApp.accent,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Bouton Message
            SizedBox(
              width: 60,
              child: ElevatedButton(
                onPressed: () => _demarrerConversation(utilisateur),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CouleursApp.accent,
                  foregroundColor: CouleursApp.blanc,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text('Msg', style: TextStyle(fontSize: 9)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
