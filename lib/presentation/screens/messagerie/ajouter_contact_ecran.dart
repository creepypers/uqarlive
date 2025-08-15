// UI Design: Écran pour ajouter des contacts dans la messagerie UqarLife
// ignore_for_file: unnecessary_string_escapes, prefer_const_constructors

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/utilisateur.dart';
import '../../services/authentification_service.dart';

class AjouterContactEcran extends StatefulWidget {
  const AjouterContactEcran({super.key});

  @override
  State<AjouterContactEcran> createState() => _AjouterContactEcranState();
}

class _AjouterContactEcranState extends State<AjouterContactEcran> {
  late AuthentificationService _authentificationService;
  
  final TextEditingController _rechercheController = TextEditingController();
  List<Utilisateur> _utilisateursRecherches = [];
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
      _utilisateurActuelId = _authentificationService.utilisateurActuel?.id;
      setState(() {});
    } catch (e) {
      _afficherErreur('Erreur d\'initialisation: $e');
    }
  }

  // UI Design: Rechercher des utilisateurs
  Future<void> _rechercherUtilisateurs(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _utilisateursRecherches = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // UI Design: Simuler une recherche d'utilisateurs
      await Future.delayed(const Duration(milliseconds: 500));
      
      // UI Design: Créer des utilisateurs fictifs pour la démonstration
      final utilisateurs = [
        Utilisateur(
          id: 'etud_001',
          nom: 'Martin',
          prenom: 'Alexandre',
          email: 'alexandre.martin@uqar.ca',
          codeEtudiant: '123456',
          programme: 'Informatique',
          niveauEtude: 'Baccalauréat',
          telephone: '418-555-0101',
          dateInscription: DateTime.now().subtract(const Duration(days: 365)),
          estActif: true,
          typeUtilisateur: TypeUtilisateur.etudiant,
        ),
        Utilisateur(
          id: 'etud_002',
          nom: 'Gagnon',
          prenom: 'Sophie',
          email: 'sophie.gagnon@uqar.ca',
          codeEtudiant: '123457',
          programme: 'Biologie',
          niveauEtude: 'Baccalauréat',
          telephone: '418-555-0102',
          dateInscription: DateTime.now().subtract(const Duration(days: 300)),
          estActif: true,
          typeUtilisateur: TypeUtilisateur.etudiant,
        ),
        Utilisateur(
          id: 'etud_003',
          nom: 'Tremblay',
          prenom: 'Marc',
          email: 'marc.tremblay@uqar.ca',
          codeEtudiant: '123458',
          programme: 'Chimie',
          niveauEtude: 'Maîtrise',
          telephone: '418-555-0103',
          dateInscription: DateTime.now().subtract(const Duration(days: 200)),
          estActif: true,
          typeUtilisateur: TypeUtilisateur.etudiant,
        ),
      ];

      // UI Design: Filtrer les utilisateurs selon la recherche
      final utilisateursFiltres = utilisateurs.where((utilisateur) {
        final nomComplet = '${utilisateur.prenom} ${utilisateur.nom}'.toLowerCase();
        final email = utilisateur.email.toLowerCase();
        final queryLower = query.toLowerCase();
        
        return nomComplet.contains(queryLower) || 
               email.contains(queryLower) ||
               utilisateur.programme.toLowerCase().contains(queryLower);
      }).toList();

      // UI Design: Exclure l'utilisateur actuel
      _utilisateursRecherches = utilisateursFiltres
          .where((u) => u.id != _utilisateurActuelId)
          .toList();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _afficherErreur('Erreur lors de la recherche: $e');
    }
  }

  // UI Design: Démarrer une conversation avec un utilisateur
  void _demarrerConversation(Utilisateur utilisateur) {
    Navigator.pushNamed(
      context,
      '/conversation',
      arguments: {
        'destinataireId': utilisateur.id,
        'destinataireNom': utilisateur.nom,
        'destinatairePrenom': utilisateur.prenom,
      },
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

  // UI Design: Construire l'AppBar
  PreferredSizeWidget _construireAppBar() {
    return AppBar(
      title: Text(
        'Ajouter un contact',
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
    if (_rechercheController.text.trim().isEmpty) {
      return _construireEtatVide();
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(CouleursApp.principal),
        ),
      );
    }

    if (_utilisateursRecherches.isEmpty) {
      return _construireAucunResultat();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _utilisateursRecherches.length,
      itemBuilder: (context, index) {
        final utilisateur = _utilisateursRecherches[index];
        return _construireCarteUtilisateur(utilisateur);
      },
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

  // UI Design: Construire une carte d'utilisateur
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
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
        title: Text(
          '${utilisateur.prenom} ${utilisateur.nom}',
          style: StylesTexteApp.moyenTitre.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              utilisateur.email,
              style: StylesTexteApp.champ.copyWith(
                color: CouleursApp.texteFonce.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.school,
                  size: 14,
                  color: CouleursApp.accent,
                ),
                const SizedBox(width: 4),
                Text(
                  '${utilisateur.programme} - ${utilisateur.niveauEtude}',
                  style: TextStyle(
                    fontSize: 12,
                    color: CouleursApp.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _demarrerConversation(utilisateur),
          style: ElevatedButton.styleFrom(
            backgroundColor: CouleursApp.accent,
            foregroundColor: CouleursApp.blanc,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Message'),
        ),
      ),
    );
  }
}
