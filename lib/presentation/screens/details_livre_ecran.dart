import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/livre.dart';
import '../../domain/entities/utilisateur.dart';
import '../services/authentification_service.dart';
import '../services/transactions_service.dart';

// UI Design: Page de détails d'un livre avec design UQAR et informations complètes
class DetailsLivreEcran extends StatefulWidget {
  final Livre livre;

  const DetailsLivreEcran({
    super.key,
    required this.livre,
  });

  @override
  State<DetailsLivreEcran> createState() => _DetailsLivreEcranState();
}

class _DetailsLivreEcranState extends State<DetailsLivreEcran> {
  bool _isFavoris = false;
  late final AuthentificationService _authentificationService;
  late final TransactionsService _transactionsService;
  Utilisateur? _utilisateurActuel;

  @override
  void initState() {
    super.initState();
    _authentificationService =
        ServiceLocator.obtenirService<AuthentificationService>();
    _transactionsService = ServiceLocator.obtenirService<TransactionsService>();
    _transactionsService.initialiser();
    _chargerUtilisateur();
  }

  Future<void> _chargerUtilisateur() async {
    _utilisateurActuel = _authentificationService.utilisateurActuel;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // UI Design: Obtenir les dimensions de l'écran pour l'adaptabilité
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      resizeToAvoidBottomInset:
          true, // UI Design: Éviter les débordements avec le clavier
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _construireSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(
                    screenWidth * 0.05), // UI Design: Padding adaptatif
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _construireInformationsPrincipales(),
                    SizedBox(
                        height: screenHeight *
                            0.03), // UI Design: Espacement adaptatif
                    _construireInformationsAcademiques(),
                    SizedBox(
                        height: screenHeight *
                            0.03), // UI Design: Espacement adaptatif
                    _construireInformationsProprietaire(),
                    SizedBox(
                        height: screenHeight *
                            0.03), // UI Design: Espacement adaptatif
                    if (widget.livre.description != null) ...[
                      _construireDescription(),
                      SizedBox(
                          height: screenHeight *
                              0.03), // UI Design: Espacement adaptatif
                    ],
                    if (widget.livre.edition != null) ...[
                      _construireInformationsTechniques(),
                      SizedBox(
                          height: screenHeight *
                              0.04), // UI Design: Espacement adaptatif
                    ],
                    _construireBoutonEchange(),
                    if (widget.livre.prix != null) ...[
                      SizedBox(
                          height: screenHeight *
                              0.02), // UI Design: Espacement adaptatif
                      _construireBoutonAcheter(),
                    ],
                    SizedBox(
                        height: screenHeight *
                            0.025), // UI Design: Espacement adaptatif
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI Design: SliverAppBar avec image du livre et actions
  Widget _construireSliverAppBar() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return SliverAppBar(
      expandedHeight: screenHeight * 0.35, // UI Design: Hauteur adaptative
      pinned: true,
      backgroundColor: CouleursApp.principal,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(
              screenWidth * 0.02), // UI Design: Padding adaptatif
          decoration: BoxDecoration(
            color: CouleursApp.blanc.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back,
            color: CouleursApp.principal,
            size: screenWidth * 0.05, // UI Design: Taille adaptative
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(
                screenWidth * 0.02), // UI Design: Padding adaptatif
            decoration: BoxDecoration(
              color: CouleursApp.blanc.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isFavoris ? Icons.favorite : Icons.favorite_border,
              color: _isFavoris ? Colors.red : CouleursApp.principal,
              size: screenWidth * 0.05, // UI Design: Taille adaptative
            ),
          ),
          onPressed: () {
            setState(() {
              _isFavoris = !_isFavoris;
            });
          },
        ),
        SizedBox(width: screenWidth * 0.04), // UI Design: Espacement adaptatif
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CouleursApp.principal,
                CouleursApp.accent,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Image du livre ou placeholder
              Center(
                child: Container(
                  width: screenWidth * 0.45, // UI Design: Largeur adaptative
                  height: screenHeight * 0.28, // UI Design: Hauteur adaptative
                  margin: EdgeInsets.only(
                    top: screenHeight * 0.07, // UI Design: Marge adaptative
                    bottom: screenHeight * 0.025,
                  ),
                  decoration: BoxDecoration(
                    color: CouleursApp.blanc,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book,
                        size: screenWidth * 0.2, // UI Design: Taille adaptative
                        color: CouleursApp.accent,
                      ),
                      SizedBox(
                          height: screenHeight *
                              0.02), // UI Design: Espacement adaptatif
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth *
                                0.04), // UI Design: Padding adaptatif
                        child: Text(
                          widget.livre.titre,
                          style: TextStyle(
                            fontSize: screenWidth *
                                0.04, // UI Design: Taille adaptative
                            fontWeight: FontWeight.bold,
                            color: CouleursApp.texteFonce,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Badge échange
              Positioned(
                top: screenHeight * 0.12, // UI Design: Position adaptative
                right: screenWidth * 0.1, // UI Design: Position adaptative
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        screenWidth * 0.03, // UI Design: Padding adaptatif
                    vertical: screenHeight * 0.008,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'ÉCHANGE',
                    style: TextStyle(
                      fontSize:
                          screenWidth * 0.03, // UI Design: Taille adaptative
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow
                        .ellipsis, // UI Design: Éviter le débordement de texte
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UI Design: Informations principales du livre
  Widget _construireInformationsPrincipales() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Container(
      padding:
          EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.livre.titre,
            style: StylesTexteApp.titre.copyWith(
              fontSize: screenWidth * 0.06, // UI Design: Taille adaptative
            ),
            overflow: TextOverflow
                .ellipsis, // UI Design: Éviter le débordement de texte
            maxLines: 2,
          ),
          SizedBox(
              height: screenHeight * 0.01), // UI Design: Espacement adaptatif
          Text(
            'Par ${widget.livre.auteur}',
            style: TextStyle(
              fontSize: screenWidth * 0.04, // UI Design: Taille adaptative
              color: CouleursApp.texteFonce.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
            overflow: TextOverflow
                .ellipsis, // UI Design: Éviter le débordement de texte
            maxLines: 1,
          ),
          SizedBox(
              height: screenHeight * 0.02), // UI Design: Espacement adaptatif
          Row(
            children: [
              _construireChipInfo(
                icone: Icons.school,
                texte: widget.livre.matiere,
                couleur: CouleursApp.principal,
              ),
              SizedBox(
                  width: screenWidth * 0.03), // UI Design: Espacement adaptatif
              _construireChipInfo(
                icone: Icons.calendar_today,
                texte: widget.livre.anneeEtude,
                couleur: CouleursApp.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UI Design: Informations académiques
  Widget _construireInformationsAcademiques() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Container(
      padding:
          EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.school,
                color: CouleursApp.principal,
                size: screenWidth * 0.06, // UI Design: Taille adaptative
              ),
              SizedBox(
                  width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Text(
                'Informations Académiques',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                ),
                overflow: TextOverflow
                    .ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(
              height: screenHeight * 0.02), // UI Design: Espacement adaptatif
          _construireLigneInfo('Matière', widget.livre.matiere),
          _construireLigneInfo('Année d\'études', widget.livre.anneeEtude),
          _construireLigneInfo('État du livre', widget.livre.etatLivre),
          if (widget.livre.codeCours != null)
            _construireLigneInfo('Code de cours', widget.livre.codeCours!),
        ],
      ),
    );
  }

  // UI Design: Informations du propriétaire
  Widget _construireInformationsProprietaire() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Container(
      padding:
          EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: CouleursApp.principal,
                size: screenWidth * 0.06, // UI Design: Taille adaptative
              ),
              SizedBox(
                  width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Text(
                'Propriétaire',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                ),
                overflow: TextOverflow
                    .ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(
              height: screenHeight * 0.02), // UI Design: Espacement adaptatif
          Row(
            children: [
              CircleAvatar(
                radius: screenWidth * 0.06, // UI Design: Rayon adaptatif
                backgroundColor: CouleursApp.accent.withValues(alpha: 0.2),
                child: Text(
                  widget.livre.proprietaire.split(' ').map((n) => n[0]).join(),
                  style: TextStyle(
                    color: CouleursApp.principal,
                    fontWeight: FontWeight.bold,
                    fontSize:
                        screenWidth * 0.04, // UI Design: Taille adaptative
                  ),
                ),
              ),
              SizedBox(
                  width: screenWidth * 0.04), // UI Design: Espacement adaptatif
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.livre.proprietaire,
                      style: TextStyle(
                        fontSize:
                            screenWidth * 0.04, // UI Design: Taille adaptative
                        fontWeight: FontWeight.w600,
                        color: CouleursApp.texteFonce,
                      ),
                      overflow: TextOverflow
                          .ellipsis, // UI Design: Éviter le débordement de texte
                      maxLines: 1,
                    ),
                    SizedBox(
                        height: screenHeight *
                            0.005), // UI Design: Espacement adaptatif
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: screenWidth *
                              0.04, // UI Design: Taille adaptative
                        ),
                        SizedBox(
                            width: screenWidth *
                                0.01), // UI Design: Espacement adaptatif
                        Text(
                          '4.8 (12 échanges)',
                          style: TextStyle(
                            fontSize: screenWidth *
                                0.035, // UI Design: Taille adaptative
                            color:
                                CouleursApp.texteFonce.withValues(alpha: 0.6),
                          ),
                          overflow: TextOverflow
                              .ellipsis, // UI Design: Éviter le débordement de texte
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _contacterProprietaire(),
                icon: Icon(
                  Icons.message,
                  color: CouleursApp.accent,
                  size: screenWidth * 0.06, // UI Design: Taille adaptative
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UI Design: Description du livre
  Widget _construireDescription() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Container(
      padding:
          EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                color: CouleursApp.principal,
                size: screenWidth * 0.06, // UI Design: Taille adaptative
              ),
              SizedBox(
                  width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Text(
                'Description',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                ),
                overflow: TextOverflow
                    .ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(
              height: screenHeight * 0.02), // UI Design: Espacement adaptatif
          Text(
            widget.livre.description!,
            style: TextStyle(
              fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
              color: CouleursApp.texteFonce,
              height: 1.5,
            ),
            overflow: TextOverflow
                .ellipsis, // UI Design: Éviter le débordement de texte
            maxLines: 6,
          ),
        ],
      ),
    );
  }

  // UI Design: Informations techniques (ISBN, édition)
  Widget _construireInformationsTechniques() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Container(
      padding:
          EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: CouleursApp.principal,
                size: screenWidth * 0.06, // UI Design: Taille adaptative
              ),
              SizedBox(
                  width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Text(
                'Informations Techniques',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                ),
                overflow: TextOverflow
                    .ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(
              height: screenHeight * 0.02), // UI Design: Espacement adaptatif
          if (widget.livre.edition != null)
            _construireLigneInfo('Édition', widget.livre.edition!),
        ],
      ),
    );
  }

  // UI Design: Bouton d'échange principal
  Widget _construireBoutonEchange() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _proposerEchange(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02), // UI Design: Padding adaptatif
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz,
                size: screenWidth * 0.06), // UI Design: Taille adaptative
            SizedBox(
                width: screenWidth * 0.02), // UI Design: Espacement adaptatif
            Text(
              'Proposer un échange',
              style: TextStyle(
                fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow
                  .ellipsis, // UI Design: Éviter le débordement de texte
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  // Widgets utilitaires
  Widget _construireChipInfo({
    required IconData icone,
    required String texte,
    required Color couleur,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03, // UI Design: Padding adaptatif
        vertical: screenWidth * 0.015,
      ),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: couleur.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone,
              size: screenWidth * 0.04,
              color: couleur), // UI Design: Taille adaptative
          SizedBox(
              width: screenWidth * 0.015), // UI Design: Espacement adaptatif
          Text(
            texte,
            style: TextStyle(
              fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
              color: couleur,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow
                .ellipsis, // UI Design: Éviter le débordement de texte
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _construireLigneInfo(String label, String valeur) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Padding(
      padding: EdgeInsets.only(
          bottom: screenHeight * 0.015), // UI Design: Espacement adaptatif
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: screenWidth * 0.3, // UI Design: Largeur adaptative
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow
                  .ellipsis, // UI Design: Éviter le débordement de texte
              maxLines: 1,
            ),
          ),
          Expanded(
            child: Text(
              valeur,
              style: TextStyle(
                fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                color: CouleursApp.texteFonce,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow
                  .ellipsis, // UI Design: Éviter le débordement de texte
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  // Actions
  Future<void> _proposerEchange() async {
    if (_utilisateurActuel == null) {
      _afficherErreur('Vous devez être connecté pour proposer un échange');
      return;
    }

    // Vérifier si l'échange est possible
    final verification = await _transactionsService.peutAcheterLivre(
        _utilisateurActuel!, widget.livre);

    if (!verification['peut']) {
      _afficherErreur(verification['raison']);
      return;
    }

    // TODO: Implémenter la sélection du livre à échanger
    // Pour l'instant, on affiche juste un message
    _afficherInfo(
        'Échange proposé ! Cette fonctionnalité sera bientôt disponible.');
  }

  void _contacterProprietaire() {
    // TODO: Implémenter la messagerie
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Message envoyé à ${widget.livre.proprietaire}'),
        backgroundColor: CouleursApp.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _construireBoutonAcheter() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _acheterLivre(),
        icon: Icon(Icons.shopping_cart,
            size: screenWidth * 0.055), // UI Design: Taille adaptative
        style: ElevatedButton.styleFrom(
          backgroundColor: CouleursApp.accent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02), // UI Design: Padding adaptatif
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        label: Text(
          'Acheter - ${widget.livre.prix?.toStringAsFixed(2) ?? ''} €',
          style: TextStyle(
            fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow
              .ellipsis, // UI Design: Éviter le débordement de texte
          maxLines: 1,
        ),
      ),
    );
  }

  Future<void> _acheterLivre() async {
    if (_utilisateurActuel == null) {
      _afficherErreur('Vous devez être connecté pour acheter un livre');
      return;
    }

    // Vérifier si l'achat est possible
    final verification = await _transactionsService.peutAcheterLivre(
        _utilisateurActuel!, widget.livre);

    if (!verification['peut']) {
      _afficherErreur(verification['raison']);
      return;
    }

    // Afficher dialogue de confirmation
    final confirme = await _afficherDialogueConfirmationAchat();
    if (confirme != true) return;

    // Créer la transaction
    final success = await _transactionsService.creerTransactionAchat(
      livreId: widget.livre.id,
      vendeurId: widget.livre.proprietaireId,
      acheteurId: _utilisateurActuel!.id,
      montant: widget.livre.prix!,
      messageAcheteur: 'Demande d\'achat via l\'application',
    );

    if (success) {
      _afficherSucces(
          'Demande d\'achat envoyée ! Le vendeur va recevoir votre demande.');
      Navigator.of(context).pop(); // Retourner à l'écran précédent
    } else {
      _afficherErreur('Erreur lors de la création de la demande d\'achat');
    }
  }

  // UI Design: Méthodes utilitaires pour les messages
  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _afficherSucces(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _afficherInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: CouleursApp.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // UI Design: Dialogue de confirmation d'achat
  Future<bool?> _afficherDialogueConfirmationAchat() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer l\'achat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Voulez-vous acheter ce livre ?'),
            const SizedBox(height: 8),
            Text(
              'Livre: ${widget.livre.titre}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Prix: ${widget.livre.prix?.toStringAsFixed(2) ?? ''} €'),
            const SizedBox(height: 16),
            const Text(
              'Une demande sera envoyée au vendeur qui pourra la confirmer.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: CouleursApp.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
