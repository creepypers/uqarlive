import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'accueil_ecran.dart';

// UI Design: Écran d'inscription avec design UQAR et fond dégradé bleu UQAR
class InscriptionEcran extends StatefulWidget {
  const InscriptionEcran({super.key});

  @override
  State<InscriptionEcran> createState() => _InscriptionEcranState();
}

class _InscriptionEcranState extends State<InscriptionEcran> {
  final TextEditingController _controleurPrenom = TextEditingController();
  final TextEditingController _controleurNom = TextEditingController();
  final TextEditingController _controleurCodePermanent =
      TextEditingController();
  final TextEditingController _controleurNomUtilisateur =
      TextEditingController();
  final TextEditingController _controleurEmail = TextEditingController();
  final TextEditingController _controleurMotDePasse = TextEditingController();
  final TextEditingController _controleurConfirmerMotDePasse =
      TextEditingController();
  final GlobalKey<FormState> _cleFormulaire = GlobalKey<FormState>();

  // Contrôle de la pagination
  int _pageActuelle = 0;
  final PageController _controleurPage = PageController();

  @override
  void dispose() {
    _controleurPrenom.dispose();
    _controleurNom.dispose();
    _controleurCodePermanent.dispose();
    _controleurNomUtilisateur.dispose();
    _controleurEmail.dispose();
    _controleurMotDePasse.dispose();
    _controleurConfirmerMotDePasse.dispose();
    _controleurPage.dispose();
    super.dispose();
  }

  void _gererInscription() {
    if (_cleFormulaire.currentState!.validate()) {
      if (_controleurMotDePasse.text != _controleurConfirmerMotDePasse.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Les mots de passe ne correspondent pas'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      // UI Design: Connexion automatique après inscription réussie
      // Navigation directe vers l'accueil avec message de bienvenue
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AccueilEcran()),
        (route) => false, // Supprime toutes les routes précédentes
      );
      
      // Message de bienvenue après connexion automatique
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Bienvenue ${_controleurPrenom.text} ${_controleurNom.text} ! Vous êtes maintenant connecté(e).'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // TODO: Implémenter la logique d'inscription réelle
    }
  }

  void _retournerVersConnexion() {
    // Vérifier s'il y a des données saisies
    bool aDonneesSaisies = _controleurPrenom.text.isNotEmpty ||
        _controleurNom.text.isNotEmpty ||
        _controleurCodePermanent.text.isNotEmpty ||
        _controleurNomUtilisateur.text.isNotEmpty ||
        _controleurEmail.text.isNotEmpty ||
        _controleurMotDePasse.text.isNotEmpty;

    if (aDonneesSaisies) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quitter l\'inscription'),
          content: const Text('Vos données saisies seront perdues. Continuer ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Fermer le dialogue
                Navigator.pop(context); // Retour à la connexion
              },
              style: ElevatedButton.styleFrom(backgroundColor: CouleursApp.accent),
              child: const Text('Continuer', style: TextStyle(color: CouleursApp.blanc)),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _pageSuivante() {
    if (_pageActuelle < 1) {
      // Valider la page actuelle avant de passer à la suivante
      if (_validerPageActuelle()) {
        setState(() {
          _pageActuelle++;
        });
        _controleurPage.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _pagePrecedente() {
    if (_pageActuelle > 0) {
      setState(() {
        _pageActuelle--;
      });
      _controleurPage.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validerPageActuelle() {
    if (_pageActuelle == 0) {
      // Valider page 1: Prénom, Nom, Code permanent
      if (_controleurPrenom.text.isEmpty || _controleurPrenom.text.length < 2) {
        _afficherErreur('Le prénom doit contenir au moins 2 caractères');
        return false;
      }
      if (_controleurNom.text.isEmpty || _controleurNom.text.length < 2) {
        _afficherErreur('Le nom doit contenir au moins 2 caractères');
        return false;
      }
      if (_controleurCodePermanent.text.isEmpty ||
          !RegExp(
            r'^[A-Z]{4}[0-9]{8}$',
          ).hasMatch(_controleurCodePermanent.text.toUpperCase())) {
        _afficherErreur('Code permanent invalide (ex: ABCD12345678)');
        return false;
      }
    }
    return true;
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
      backgroundColor: CouleursApp.blanc,
      resizeToAvoidBottomInset: true, // UI Design: Éviter les débordements avec le clavier
      body: Stack(
        children: [
          // Background divisé en 2 parties
          Column(
            children: [
              // Partie supérieure avec dégradé (2/3 du background)
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        CouleursApp.accent.withValues(alpha: 0.7), // Bleu ciel UQAR transparent
                        CouleursApp.accent, // Bleu ciel UQAR
                        CouleursApp.principal, // Bleu foncé UQAR
                      ],
                    ),
                  ),
                ),
              ),
              // Partie inférieure blanche (1/3 du background)
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  color: CouleursApp.blanc,
                ),
              ),
            ],
          ),
          
          // Contenu par-dessus le background  
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: viewInsets.bottom + padding.bottom + screenHeight * 0.025, // UI Design: Padding adaptatif pour éviter les débordements
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - padding.top - padding.bottom,
                ),
                child: Column(
                  children: [
                    // Section supérieure avec logo et illustrations
                    SizedBox(
                      height: screenHeight * 0.35, // UI Design: Hauteur adaptative
                      child: Stack(
                        children: [
                          // Logo et nom de l'application au centre
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Logo UqarLive
                                _construireLogoUqarLive(),
                                SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
                                // Nom de l'application
                                Text(
                                  'UqarLive',
                                  style: StylesTexteApp.titre.copyWith(
                                    fontSize: screenWidth * 0.08, // UI Design: Taille adaptative
                                    color: CouleursApp.blanc,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                                  maxLines: 1,
                                ),
                                SizedBox(height: screenHeight * 0.01), // UI Design: Espacement adaptatif
                                // Indicateur de page
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: screenWidth * 0.02, // UI Design: Taille adaptative
                                      height: screenWidth * 0.02, // UI Design: Taille adaptative
                                      decoration: BoxDecoration(
                                        color: _pageActuelle == 0
                                            ? CouleursApp.blanc
                                            : CouleursApp.blanc.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
                                    Container(
                                      width: screenWidth * 0.02, // UI Design: Taille adaptative
                                      height: screenWidth * 0.02, // UI Design: Taille adaptative
                                      decoration: BoxDecoration(
                                        color: _pageActuelle == 1
                                            ? CouleursApp.blanc
                                            : CouleursApp.blanc.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Illustration de feuilles stylisées
                          Positioned(
                            top: screenHeight * 0.05, // UI Design: Position adaptative
                            left: screenWidth * 0.05, // UI Design: Position adaptative
                            child: _construireIllustrationFeuille(screenWidth * 0.12, screenHeight * 0.04), // UI Design: Taille adaptative
                          ),
                          Positioned(
                            top: screenHeight * 0.07, // UI Design: Position adaptative
                            right: screenWidth * 0.075, // UI Design: Position adaptative
                            child: _construireIllustrationFeuille(screenWidth * 0.15, screenHeight * 0.055), // UI Design: Taille adaptative
                          ),
                          Positioned(
                            bottom: screenHeight * 0.025, // UI Design: Position adaptative
                            left: screenWidth * 0.1, // UI Design: Position adaptative
                            child: _construireIllustrationFeuille(screenWidth * 0.175, screenHeight * 0.068), // UI Design: Taille adaptative
                          ),
                          Positioned(
                            bottom: screenHeight * 0.05, // UI Design: Position adaptative
                            right: screenWidth * 0.05, // UI Design: Position adaptative
                            child: _construireIllustrationFeuille(screenWidth * 0.2, screenHeight * 0.08), // UI Design: Taille adaptative
                          ),
                        ],
                      ),
                    ),

                    // Section inférieure avec formulaire paginé superposé sur le dégradé
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: screenHeight * 0.025), // UI Design: Marge adaptative
                      padding: EdgeInsets.all(screenWidth * 0.08), // UI Design: Padding adaptatif
                      decoration: BoxDecoration(
                        color: CouleursApp.blanc,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(screenWidth * 0.125), // UI Design: Rayon adaptatif
                          topRight: Radius.circular(screenWidth * 0.125), // UI Design: Rayon adaptatif
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: CouleursApp.principal.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, -10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _cleFormulaire,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Titre
                            Text(
                              'Inscription',
                              style: StylesTexteApp.titre.copyWith(
                                fontSize: screenWidth * 0.055, // UI Design: Taille adaptative
                              ),
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                              maxLines: 1,
                            ),
                            SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif

                            // Contenu paginé - HAUTEUR ADAPTATIVE pour éviter les conflits
                            SizedBox(
                              height: screenHeight * 0.5, // UI Design: Hauteur adaptative
                              child: PageView(
                                controller: _controleurPage,
                                onPageChanged: (index) {
                                  setState(() {
                                    _pageActuelle = index;
                                  });
                                },
                                children: [
                                  // Page 1: Informations personnelles
                                  _construirePage1(),
                                  // Page 2: Informations de compte
                                  _construirePage2(),
                                ],
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif

                            // Boutons de navigation
                            Row(
                              children: [
                                // Bouton Précédent
                                if (_pageActuelle > 0)
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _pagePrecedente,
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: CouleursApp.principal),
                                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02), // UI Design: Padding adaptatif
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(32),
                                        ),
                                      ),
                                      child: Text(
                                        'Précédent',
                                        style: StylesTexteApp.bouton.copyWith(
                                          color: CouleursApp.principal,
                                          fontSize: screenWidth * 0.04, // UI Design: Taille adaptative
                                        ),
                                        overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),

                                if (_pageActuelle > 0) SizedBox(width: screenWidth * 0.04), // UI Design: Espacement adaptatif

                                // Bouton Suivant/S'inscrire
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _pageActuelle == 1 ? _gererInscription : _pageSuivante,
                                    style: DecorationsApp.boutonPrincipal,
                                    child: Text(
                                      _pageActuelle == 1 ? 'S\'inscrire' : 'Suivant',
                                      style: StylesTexteApp.bouton.copyWith(
                                        fontSize: screenWidth * 0.04, // UI Design: Taille adaptative
                                      ),
                                      overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif

                            // Lien "Déjà un compte ?" - STYLE COHÉRENT AVEC CONNEXION
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  text: 'Déjà un compte? ',
                                  style: TextStyle(
                                    color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                                    fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                                  ),
                                  children: [
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: _retournerVersConnexion,
                                        child: Text(
                                          'Se connecter',
                                          style: TextStyle(
                                            color: CouleursApp.accent,
                                            fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.underline,
                                          ),
                                          overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.025), // UI Design: Espacement adaptatif
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirePage1() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Informations personnelles',
            style: StylesTexteApp.champ.copyWith(
              fontSize: screenWidth * 0.04, // UI Design: Taille adaptative
              fontWeight: FontWeight.w600,
              color: CouleursApp.texteFonce,
            ),
            overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
            maxLines: 1,
          ),
          SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif

          // Champ prénom
          _construireChampTexte(
            controleur: _controleurPrenom,
            placeholderTexte: 'Prénom',
            icone: Icons.person_outline,
          ),
          SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif

          // Champ nom
          _construireChampTexte(
            controleur: _controleurNom,
            placeholderTexte: 'Nom',
            icone: Icons.person_outline,
          ),
          SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif

          // Champ code permanent
          _construireChampTexte(
            controleur: _controleurCodePermanent,
            placeholderTexte: 'Code permanent',
            icone: Icons.badge_outlined,
          ),
          SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif

          // Aide pour le code permanent
          Container(
            padding: EdgeInsets.all(screenWidth * 0.03), // UI Design: Padding adaptatif
            decoration: BoxDecoration(
              color: CouleursApp.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Format: 4 lettres + 8 chiffres (ex: ABCD12345678)',
              style: StylesTexteApp.champ.copyWith(
                fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
                color: CouleursApp.texteFonce.withValues(alpha: 0.7),
              ),
              overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirePage2() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Informations de compte',
            style: StylesTexteApp.champ.copyWith(
              fontSize: screenWidth * 0.04, // UI Design: Taille adaptative
              fontWeight: FontWeight.w600,
              color: CouleursApp.texteFonce,
            ),
            overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
            maxLines: 1,
          ),
          SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif

          // Champ nom d'utilisateur
          _construireChampTexte(
            controleur: _controleurNomUtilisateur,
            placeholderTexte: 'Nom d\'utilisateur',
            icone: Icons.account_circle_outlined,
          ),
          SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif

          // Champ email
          _construireChampTexte(
            controleur: _controleurEmail,
            placeholderTexte: 'Email',
            icone: Icons.email_outlined,
          ),
          SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif

          // Champ mot de passe
          _construireChampTexte(
            controleur: _controleurMotDePasse,
            placeholderTexte: 'Mot de passe',
            icone: Icons.lock_outline,
            estMotDePasse: true,
          ),
          SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif

          // Champ confirmer mot de passe
          _construireChampTexte(
            controleur: _controleurConfirmerMotDePasse,
            placeholderTexte: 'Confirmer le mot de passe',
            icone: Icons.lock_outline,
            estMotDePasse: true,
          ),
        ],
      ),
    );
  }

  Widget _construireChampTexte({
    required TextEditingController controleur,
    required String placeholderTexte,
    required IconData icone,
    bool estMotDePasse = false,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      decoration: DecorationsApp.champTexte,
      child: TextFormField(
        controller: controleur,
        obscureText: estMotDePasse,
        style: StylesTexteApp.champ.copyWith(
          fontSize: screenWidth * 0.04, // UI Design: Taille adaptative
        ),
        decoration: InputDecoration(
          hintText: placeholderTexte,
          hintStyle: StylesTexteApp.champ.copyWith(
            color: CouleursApp.texteFonce.withValues(alpha: 0.5),
            fontSize: screenWidth * 0.04, // UI Design: Taille adaptative
          ),
          prefixIcon: Icon(
            icone,
            color: CouleursApp.texteFonce.withValues(alpha: 0.5),
            size: screenWidth * 0.05, // UI Design: Taille adaptative
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, // UI Design: Padding adaptatif
            vertical: screenHeight * 0.025, // UI Design: Padding adaptatif
          ),
        ),
        validator: (valeur) {
          if (valeur == null || valeur.isEmpty) {
            return 'Ce champ est requis';
          }
          return null;
        },
      ),
    );
  }

  Widget _construireIllustrationFeuille(double largeur, double hauteur) {
    return Container(
      width: largeur,
      height: hauteur,
      decoration: BoxDecoration(
        color: CouleursApp.principal.withOpacity(0.3),
        borderRadius: BorderRadius.circular(hauteur / 2),
      ),
      child: Center(
        child: Container(
          width: largeur * 0.7,
          height: hauteur * 0.7,
          decoration: BoxDecoration(
            color: CouleursApp.principal.withOpacity(0.5),
            borderRadius: BorderRadius.circular(hauteur / 3),
          ),
        ),
      ),
    );
  }

  Widget _construireLogoUqarLive() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      width: screenWidth * 0.2, // UI Design: Taille adaptative
      height: screenWidth * 0.2, // UI Design: Taille adaptative
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(screenWidth * 0.05), // UI Design: Rayon adaptatif
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône stylisée représentant UQAR
            Icon(
              Icons.school, 
              size: screenWidth * 0.08, // UI Design: Taille adaptative
              color: CouleursApp.principal
            ),
            SizedBox(height: screenHeight * 0.005), // UI Design: Espacement adaptatif
            // Petit texte "UQAR"
            Text(
              'UQAR',
              style: TextStyle(
                fontSize: screenWidth * 0.025, // UI Design: Taille adaptative
                fontWeight: FontWeight.bold,
                color: CouleursApp.principal,
              ),
              overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
} 