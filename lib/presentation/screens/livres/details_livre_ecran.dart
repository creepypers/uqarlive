import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/livre.dart';
import '../../../domain/entities/utilisateur.dart';
import '../../../domain/repositories/livres_repository.dart';
import '../../../presentation/services/authentification_service.dart';
import '../../../presentation/services/transactions_service.dart';
import 'selectionner_livre_echange_ecran.dart';

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
  late final LivresRepository _livresRepository;
  Utilisateur? _utilisateurActuel;

  @override
  void initState() {
    super.initState();
    _authentificationService =
        ServiceLocator.obtenirService<AuthentificationService>();
    _transactionsService = ServiceLocator.obtenirService<TransactionsService>();
    _livresRepository = ServiceLocator.obtenirService<LivresRepository>();
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
          backgroundColor: CouleursApp.principal,
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

    // UI Design: Implémenter la sélection du livre à échanger
    await _ouvrirSelectionLivreEchange();
  }

  void _contacterProprietaire() {
    // UI Design: Implémenter la messagerie
    _ouvrirMessagerieContact();
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
      if (mounted) {
        _afficherSucces(
            'Demande d\'achat envoyée ! Le vendeur va recevoir votre demande.');
        Navigator.of(context).pop(); // Retourner à l'écran précédent
      }
    } else {
      if (mounted) {
        _afficherErreur('Erreur lors de la création de la demande d\'achat');
      }
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
        content: SingleChildScrollView(
          child: Column(
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

  // UI Design: Ouvrir la sélection du livre à échanger
  Future<void> _ouvrirSelectionLivreEchange() async {
    if (_utilisateurActuel == null) {
      _afficherErreur('Vous devez être connecté pour effectuer un échange');
      return;
    }

    try {
      // Récupérer les livres de l'utilisateur
      final mesLivres = await _livresRepository.obtenirLivresParProprietaire(_utilisateurActuel!.id);
      final livresDisponibles = mesLivres.where((livre) => livre.estDisponible && livre.id != widget.livre.id).toList();

      if (livresDisponibles.isEmpty) {
        if (mounted) {
          _afficherInfo('Vous n\'avez pas de livres disponibles pour l\'échange. Ajoutez-en dans votre collection !');
        }
        return;
      }

      if (mounted) {
        final livreSelectionne = await Navigator.of(context).push<Livre>(
          MaterialPageRoute(
            builder: (context) => SelectionnerLivreEchangeEcran(
              livres: livresDisponibles,
              livreACible: widget.livre,
            ),
          ),
        );

        if (livreSelectionne != null) {
          // Proposer l'échange
          await _proposerEchangeAvecLivre(livreSelectionne);
        }
      }
    } catch (e) {
      _afficherErreur('Erreur lors du chargement de vos livres: ${e.toString()}');
    }
  }



  // UI Design: Proposer l'échange avec un livre spécifique
  Future<void> _proposerEchangeAvecLivre(Livre monLivre) async {
    try {
      final resultat = await _transactionsService.proposerEchange(
        _utilisateurActuel!.id,
        monLivre.id,
        widget.livre.id,
        'Échange proposé via UqarLive',
      );

      if (resultat) {
        _afficherInfo('Échange proposé avec succès ! Le propriétaire sera notifié.');
      } else {
        _afficherErreur('Erreur lors de la proposition d\'échange.');
      }
    } catch (e) {
      _afficherErreur('Erreur technique: ${e.toString()}');
    }
  }

  // UI Design: Ouvrir la messagerie de contact
  void _ouvrirMessagerieContact() {
    if (_utilisateurActuel == null) {
      _afficherErreur('Vous devez être connecté pour contacter le propriétaire');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _construireDialogueMessage(),
    );
  }

  // UI Design: Construire le dialogue de message
  Widget _construireDialogueMessage() {
    final TextEditingController controleurMessage = TextEditingController();
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Contacter ${widget.livre.proprietaire}'),
      content: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Concernant: "${widget.livre.titre}"',
            style: StylesTexteApp.champ.copyWith(
              fontWeight: FontWeight.w500,
              color: CouleursApp.principal,
            ),
          ),
          const SizedBox(height: 16),
            SizedBox(
              height: 120, // Hauteur fixe pour éviter le débordement
              child: TextField(
            controller: controleurMessage,
                maxLines: null, // Permet l'expansion
                expands: true, // Utilise tout l'espace disponible
            autofocus: true,
            style: StylesTexteApp.champ,
            decoration: InputDecoration(
              hintText: 'Votre message...',
              hintStyle: StylesTexteApp.champ.copyWith(
                color: CouleursApp.texteFonce.withValues(alpha: 0.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: CouleursApp.principal.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: CouleursApp.principal, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
                ),
            ),
          ),
        ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (controleurMessage.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Veuillez saisir un message'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            Navigator.of(context).pop();
            await _envoyerMessage(controleurMessage.text.trim());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: CouleursApp.principal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Envoyer', style: TextStyle(color: CouleursApp.blanc)),
        ),
      ],
    );
  }

  // UI Design: Envoyer un message
  Future<void> _envoyerMessage(String contenu) async {
    try {
      // Pour l'instant, on simule l'envoi de message
      // Dans une vraie implémentation, on aurait un service de messagerie
      await Future.delayed(const Duration(milliseconds: 500));
      
      _afficherInfo('Message envoyé à ${widget.livre.proprietaire} !');
    } catch (e) {
      _afficherErreur('Erreur lors de l\'envoi du message: ${e.toString()}');
    }
  }
}
