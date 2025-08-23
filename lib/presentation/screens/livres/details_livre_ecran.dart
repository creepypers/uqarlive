import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/livre.dart';
import '../../../domain/entities/utilisateur.dart';
import '../../../domain/usercases/livres_repository.dart';
import '../../../presentation/services/authentification_service.dart';
import '../../../presentation/services/transactions_service.dart';
import 'selectionner_livre_echange_ecran.dart';
import '../messagerie/conversation_ecran.dart';
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
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      resizeToAvoidBottomInset:
          true, 
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _construireSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(
                    screenWidth * 0.05), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _construireInformationsPrincipales(),
                    SizedBox(
                        height: screenHeight *
                            0.03), 
                    _construireInformationsAcademiques(),
                    SizedBox(
                        height: screenHeight *
                            0.03), 
                    _construireInformationsProprietaire(),
                    SizedBox(
                        height: screenHeight *
                            0.03), 
                    if (widget.livre.description != null) ...[
                      _construireDescription(),
                      SizedBox(
                          height: screenHeight *
                              0.03), 
                    ],
                    if (widget.livre.edition != null) ...[
                      _construireInformationsTechniques(),
                      SizedBox(
                          height: screenHeight *
                              0.04), 
                    ],
                    _construireBoutonEchange(),
                    if (widget.livre.prix != null) ...[
                      SizedBox(
                          height: screenHeight *
                              0.02), 
                      _construireBoutonAcheter(),
                    ],
                    SizedBox(
                        height: screenHeight *
                            0.025), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _construireSliverAppBar() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return SliverAppBar(
      expandedHeight: screenHeight * 0.35, 
      pinned: true,
      backgroundColor: CouleursApp.principal,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(
              screenWidth * 0.02), 
          decoration: BoxDecoration(
            color: CouleursApp.blanc.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back,
            color: CouleursApp.principal,
            size: screenWidth * 0.05, 
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(
                screenWidth * 0.02), 
            decoration: BoxDecoration(
              color: CouleursApp.blanc.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isFavoris ? Icons.favorite : Icons.favorite_border,
              color: _isFavoris ? Colors.red : CouleursApp.principal,
              size: screenWidth * 0.05, 
            ),
          ),
          onPressed: () {
            setState(() {
              _isFavoris = !_isFavoris;
            });
          },
        ),
        SizedBox(width: screenWidth * 0.04), 
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
                  width: screenWidth * 0.45, 
                  height: screenHeight * 0.28, 
                  margin: EdgeInsets.only(
                    top: screenHeight * 0.07, 
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
                        size: screenWidth * 0.2, 
                        color: CouleursApp.accent,
                      ),
                      SizedBox(
                          height: screenHeight *
                              0.02), 
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth *
                                0.04), 
                        child: Text(
                          widget.livre.titre,
                          style: TextStyle(
                            fontSize: screenWidth *
                                0.04, 
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
                top: screenHeight * 0.12, 
                right: screenWidth * 0.1, 
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        screenWidth * 0.03, 
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
                          screenWidth * 0.03, 
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow
                        .ellipsis, 
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
  Widget _construireInformationsPrincipales() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return Container(
      padding:
          EdgeInsets.all(screenWidth * 0.05), 
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
              fontSize: screenWidth * 0.06, 
            ),
            overflow: TextOverflow
                .ellipsis, 
            maxLines: 2,
          ),
          SizedBox(
              height: screenHeight * 0.01), 
          Text(
            'Par ${widget.livre.auteur}',
            style: TextStyle(
              fontSize: screenWidth * 0.04, 
              color: CouleursApp.texteFonce.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
            overflow: TextOverflow
                .ellipsis, 
            maxLines: 1,
          ),
          SizedBox(
              height: screenHeight * 0.02), 
          Row(
            children: [
              _construireChipInfo(
                icone: Icons.school,
                texte: widget.livre.matiere,
                couleur: CouleursApp.principal,
              ),
              SizedBox(
                  width: screenWidth * 0.03), 
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
  Widget _construireInformationsAcademiques() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return Container(
      padding:
          EdgeInsets.all(screenWidth * 0.05), 
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
                size: screenWidth * 0.06, 
              ),
              SizedBox(
                  width: screenWidth * 0.02), 
              Text(
                'Informations Académiques',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, 
                ),
                overflow: TextOverflow
                    .ellipsis, 
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(
              height: screenHeight * 0.02), 
          _construireLigneInfo('Matière', widget.livre.matiere),
          _construireLigneInfo('Année d\'études', widget.livre.anneeEtude),
          _construireLigneInfo('État du livre', widget.livre.etatLivre),
          if (widget.livre.codeCours != null)
            _construireLigneInfo('Code de cours', widget.livre.codeCours!),
        ],
      ),
    );
  }
  Widget _construireInformationsProprietaire() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return Container(
      padding:
          EdgeInsets.all(screenWidth * 0.05), 
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
                size: screenWidth * 0.06, 
              ),
              SizedBox(
                  width: screenWidth * 0.02), 
              Text(
                'Propriétaire',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, 
                ),
                overflow: TextOverflow
                    .ellipsis, 
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(
              height: screenHeight * 0.02), 
          Row(
            children: [
              CircleAvatar(
                radius: screenWidth * 0.06, 
                backgroundColor: CouleursApp.accent.withValues(alpha: 0.2),
                child: Text(
                  widget.livre.proprietaire.split(' ').map((n) => n[0]).join(),
                  style: TextStyle(
                    color: CouleursApp.principal,
                    fontWeight: FontWeight.bold,
                    fontSize:
                        screenWidth * 0.04, 
                  ),
                ),
              ),
              SizedBox(
                  width: screenWidth * 0.04), 
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.livre.proprietaire,
                      style: TextStyle(
                        fontSize:
                            screenWidth * 0.04, 
                        fontWeight: FontWeight.w600,
                        color: CouleursApp.texteFonce,
                      ),
                      overflow: TextOverflow
                          .ellipsis, 
                      maxLines: 1,
                    ),
                    SizedBox(
                        height: screenHeight *
                            0.005), 
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: screenWidth *
                              0.04, 
                        ),
                        SizedBox(
                            width: screenWidth *
                                0.01), 
                        Text(
                          '4.8 (12 échanges)',
                          style: TextStyle(
                            fontSize: screenWidth *
                                0.035, 
                            color:
                                CouleursApp.texteFonce.withValues(alpha: 0.6),
                          ),
                          overflow: TextOverflow
                              .ellipsis, 
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
                  size: screenWidth * 0.06, 
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _construireDescription() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return Container(
      padding:
          EdgeInsets.all(screenWidth * 0.05), 
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
                size: screenWidth * 0.06, 
              ),
              SizedBox(
                  width: screenWidth * 0.02), 
              Text(
                'Description',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, 
                ),
                overflow: TextOverflow
                    .ellipsis, 
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(
              height: screenHeight * 0.02), 
          Text(
            widget.livre.description!,
            style: TextStyle(
              fontSize: screenWidth * 0.035, 
              color: CouleursApp.texteFonce,
              height: 1.5,
            ),
            overflow: TextOverflow
                .ellipsis, 
            maxLines: 6,
          ),
        ],
      ),
    );
  }
  Widget _construireInformationsTechniques() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return Container(
      padding:
          EdgeInsets.all(screenWidth * 0.05), 
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
                size: screenWidth * 0.06, 
              ),
              SizedBox(
                  width: screenWidth * 0.02), 
              Text(
                'Informations Techniques',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, 
                ),
                overflow: TextOverflow
                    .ellipsis, 
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(
              height: screenHeight * 0.02), 
          if (widget.livre.edition != null)
            _construireLigneInfo('Édition', widget.livre.edition!),
        ],
      ),
    );
  }
  Widget _construireBoutonEchange() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _afficherOptionsContact(),
        style: ElevatedButton.styleFrom(
          backgroundColor: CouleursApp.principal,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.contact_support,
                size: screenWidth * 0.06), 
            SizedBox(
                width: screenWidth * 0.02), 
            Text(
              'Contacter le propriétaire',
              style: TextStyle(
                fontSize: screenWidth * 0.045, 
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow
                  .ellipsis, 
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
        horizontal: screenWidth * 0.03, 
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
              color: couleur), 
          SizedBox(
              width: screenWidth * 0.015), 
          Text(
            texte,
            style: TextStyle(
              fontSize: screenWidth * 0.03, 
              color: couleur,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow
                .ellipsis, 
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
          bottom: screenHeight * 0.015), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: screenWidth * 0.3, 
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: screenWidth * 0.035, 
                color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow
                  .ellipsis, 
              maxLines: 1,
            ),
          ),
          Expanded(
            child: Text(
              valeur,
              style: TextStyle(
                fontSize: screenWidth * 0.035, 
                color: CouleursApp.texteFonce,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow
                  .ellipsis, 
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
    await _ouvrirSelectionLivreEchange();
  }
  Future<void> _afficherOptionsContact() async {
    if (_utilisateurActuel == null) {
      _afficherErreur('Vous devez être connecté pour contacter le propriétaire');
      return;
    }
    // Vérifier si l'utilisateur a des livres pour l'échange
    final mesLivres = await _livresRepository.obtenirLivresParProprietaire(_utilisateurActuel!.id);
    final livresDisponibles = mesLivres.where((livre) => livre.estDisponible && livre.id != widget.livre.id).toList();
    final peutEchanger = livresDisponibles.isNotEmpty;
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _construireModalOptionsContact(peutEchanger),
      );
    }
  }
  void _contacterProprietaire() {
    _ouvrirMessagerieContact();
  }
  Widget _construireModalOptionsContact(bool peutEchanger) {
    MediaQuery.of(context);
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
            'Contacter le propriétaire',
            style: StylesTexteApp.titre.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            'Choisissez comment contacter le propriétaire de "${widget.livre.titre}"',
            style: StylesTexteApp.champ.copyWith(
              color: CouleursApp.texteFonce.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          // Option 1: Message général
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _ouvrirMessagerieContact();
              },
              icon: const Icon(Icons.message, color: CouleursApp.blanc),
              label: const Text('Envoyer un message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CouleursApp.principal,
                foregroundColor: CouleursApp.blanc,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Option 2: Proposer un échange (si possible)
          if (peutEchanger) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _proposerEchange();
                },
                icon: const Icon(Icons.swap_horiz, color: CouleursApp.blanc),
                label: const Text('Proposer un échange'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CouleursApp.accent,
                  foregroundColor: CouleursApp.blanc,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Bouton Annuler
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Annuler'),
            ),
          ),
          const SizedBox(height: 20),
        ],
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
            size: screenWidth * 0.055), 
        style: ElevatedButton.styleFrom(
          backgroundColor: CouleursApp.accent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        label: Text(
          'Acheter - \$${widget.livre.prix?.toStringAsFixed(2) ?? ''}',
          style: TextStyle(
            fontSize: screenWidth * 0.045, 
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow
              .ellipsis, 
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
            Text('Prix: \$${widget.livre.prix?.toStringAsFixed(2) ?? ''}'),
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
  void _ouvrirMessagerieContact() {
    if (_utilisateurActuel == null) {
      _afficherErreur('Vous devez être connecté pour contacter le propriétaire');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationEcran(
          destinataireId: widget.livre.proprietaireId,
          destinataireNom: widget.livre.proprietaire,
          destinatairePrenom: '', // Le nom complet est dans proprietaire
        ),
      ),
    );
  }
}