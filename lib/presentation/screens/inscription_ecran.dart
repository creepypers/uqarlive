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
    return Scaffold(
      backgroundColor: CouleursApp.blanc,
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
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                            MediaQuery.of(context).padding.top - 
                            MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: [
                    // Section supérieure avec logo et illustrations
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: Stack(
                        children: [
                          // Logo et nom de l'application au centre
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Logo UqarLive
                                _construireLogoUqarLive(),
                                const SizedBox(height: 16),
                                // Nom de l'application
                                Text(
                                  'UqarLive',
                                  style: StylesTexteApp.titre.copyWith(
                                    fontSize: 32,
                                    color: CouleursApp.blanc,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Indicateur de page
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _pageActuelle == 0
                                            ? CouleursApp.blanc
                                            : CouleursApp.blanc.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 8,
                                      height: 8,
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
                            top: 40,
                            left: 20,
                            child: _construireIllustrationFeuille(50, 35),
                          ),
                          Positioned(
                            top: 60,
                            right: 30,
                            child: _construireIllustrationFeuille(60, 45),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 40,
                            child: _construireIllustrationFeuille(70, 55),
                          ),
                          Positioned(
                            bottom: 40,
                            right: 20,
                            child: _construireIllustrationFeuille(80, 65),
                          ),
                        ],
                      ),
                    ),

                    // Section inférieure avec formulaire paginé superposé sur le dégradé
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: CouleursApp.blanc,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
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
                            const Text(
                              'Inscription',
                              style: StylesTexteApp.titre,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 24),

                            // Contenu paginé - HAUTEUR FIXE pour éviter les conflits
                            SizedBox(
                              height: 400, // Hauteur fixe pour le PageView
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

                            const SizedBox(height: 24),

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
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(32),
                                        ),
                                      ),
                                      child: Text(
                                        'Précédent',
                                        style: StylesTexteApp.bouton.copyWith(
                                          color: CouleursApp.principal,
                                        ),
                                      ),
                                    ),
                                  ),

                                if (_pageActuelle > 0) const SizedBox(width: 16),

                                // Bouton Suivant/S'inscrire
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _pageActuelle == 1 ? _gererInscription : _pageSuivante,
                                    style: DecorationsApp.boutonPrincipal,
                                    child: Text(
                                      _pageActuelle == 1 ? 'S\'inscrire' : 'Suivant',
                                      style: StylesTexteApp.bouton,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Lien "Déjà un compte ?" - STYLE COHÉRENT AVEC CONNEXION
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  text: 'Déjà un compte? ',
                                  style: TextStyle(
                                    color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                                    fontSize: 14,
                                  ),
                                  children: [
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: _retournerVersConnexion,
                                        child: const Text(
                                          'Se connecter',
                                          style: TextStyle(
                                            color: CouleursApp.accent,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Informations personnelles',
            style: StylesTexteApp.champ.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CouleursApp.texteFonce,
            ),
          ),
          const SizedBox(height: 24),

          // Champ prénom
          _construireChampTexte(
            controleur: _controleurPrenom,
            placeholderTexte: 'Prénom',
            icone: Icons.person_outline,
          ),
          const SizedBox(height: 16),

          // Champ nom
          _construireChampTexte(
            controleur: _controleurNom,
            placeholderTexte: 'Nom',
            icone: Icons.person_outline,
          ),
          const SizedBox(height: 16),

          // Champ code permanent
          _construireChampTexte(
            controleur: _controleurCodePermanent,
            placeholderTexte: 'Code permanent',
            icone: Icons.badge_outlined,
          ),
          const SizedBox(height: 16),

          // Aide pour le code permanent
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CouleursApp.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Format: 4 lettres + 8 chiffres (ex: ABCD12345678)',
              style: StylesTexteApp.champ.copyWith(
                fontSize: 12,
                color: CouleursApp.texteFonce.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirePage2() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Informations de compte',
            style: StylesTexteApp.champ.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CouleursApp.texteFonce,
            ),
          ),
          const SizedBox(height: 24),

          // Champ nom d'utilisateur
          _construireChampTexte(
            controleur: _controleurNomUtilisateur,
            placeholderTexte: 'Nom d\'utilisateur',
            icone: Icons.account_circle_outlined,
          ),
          const SizedBox(height: 16),

          // Champ email
          _construireChampTexte(
            controleur: _controleurEmail,
            placeholderTexte: 'Email',
            icone: Icons.email_outlined,
          ),
          const SizedBox(height: 16),

          // Champ mot de passe
          _construireChampTexte(
            controleur: _controleurMotDePasse,
            placeholderTexte: 'Mot de passe',
            icone: Icons.lock_outline,
            estMotDePasse: true,
          ),
          const SizedBox(height: 16),

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
    return Container(
      decoration: DecorationsApp.champTexte,
      child: TextFormField(
        controller: controleur,
        obscureText: estMotDePasse,
        style: StylesTexteApp.champ,
        decoration: InputDecoration(
          hintText: placeholderTexte,
          hintStyle: StylesTexteApp.champ.copyWith(
            color: CouleursApp.texteFonce.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            icone,
            color: CouleursApp.texteFonce.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
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
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône stylisée représentant UQAR
            Icon(Icons.school, size: 32, color: CouleursApp.principal),
            SizedBox(height: 4),
            // Petit texte "UQAR"
            Text(
              'UQAR',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: CouleursApp.principal,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 