import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../presentation/services/authentification_service.dart';
import '../accueil_ecran.dart';
import '../admin/admin_dashboard_ecran.dart';
import 'inscription_ecran.dart';

// UI Design: Écran de connexion avec design UQAR et fond dégradé violet/bleu
class ConnexionEcran extends StatefulWidget {
  const ConnexionEcran({super.key});

  @override
  State<ConnexionEcran> createState() => _ConnexionEcranState();
}

class _ConnexionEcranState extends State<ConnexionEcran> {
  final TextEditingController _controleurNomUtilisateur =
      TextEditingController();
  final TextEditingController _controleurMotDePasse = TextEditingController();
  final GlobalKey<FormState> _cleFormulaire = GlobalKey<FormState>();

  // UI Design: Service d'authentification
  late AuthentificationService _authentificationService;

  @override
  void initState() {
    super.initState();
    _authentificationService =
        ServiceLocator.obtenirService<AuthentificationService>();
  }

  @override
  void dispose() {
    _controleurNomUtilisateur.dispose();
    _controleurMotDePasse.dispose();
    super.dispose();
  }

  void _gererConnexion() async {
    if (_cleFormulaire.currentState!.validate()) {

      try {
        final utilisateur = await _authentificationService.authentifier(
          _controleurNomUtilisateur.text,
          _controleurMotDePasse.text,
        );

        if (utilisateur != null) {
          // Debug temporaire

          // UI Design: Redirection selon le type d'utilisateur
          if (mounted) {
            if (_authentificationService.estAdministrateur) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const AdminDashboardEcran()),
                (route) => false,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.admin_panel_settings,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text('Bienvenue Administrateur ${utilisateur.prenom} !'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AccueilEcran()),
                (route) => false,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text('Bienvenue ${utilisateur.prenom} !'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          }
        } else {
          _afficherErreurConnexion();
        }
      } catch (e) {
        _afficherErreurConnexion();
      } finally {
        // Connexion terminée
      }
    }
  }

  void _afficherErreurConnexion() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Email ou mot de passe incorrect'),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }



  void _gererMotDePasseOublie() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mot de passe oublié'),
        content: const Text(
            'Un email de réinitialisation sera envoyé à votre adresse.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email de réinitialisation envoyé'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: CouleursApp.accent),
            child: const Text('Envoyer',
                style: TextStyle(color: CouleursApp.blanc)),
          ),
        ],
      ),
    );
  }



  void _gererCreerCompte() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const InscriptionEcran()));
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
      resizeToAvoidBottomInset:
          true, // UI Design: Éviter les débordements avec le clavier
      body: SafeArea(
        child: Stack(
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
                          CouleursApp.accent.withValues(
                              alpha: 0.7), // Bleu ciel UQAR transparent
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
            SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: viewInsets.bottom +
                    padding
                        .bottom, // UI Design: Padding adaptatif pour éviter les débordements
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - padding.top - padding.bottom,
                ),
                child: Column(
                  children: [
                    // Section supérieure avec logo et illustrations
                    SizedBox(
                      height: screenHeight * 0.35,
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
                                    fontSize: screenWidth *
                                        0.1, // UI Design: Taille adaptative
                                    color: CouleursApp.blanc,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow
                                      .ellipsis, // UI Design: Éviter le débordement de texte
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          // Illustration de feuilles stylisées
                          Positioned(
                            top: 80,
                            left: screenWidth *
                                0.05, // UI Design: Position adaptative
                            child: _construireIllustrationFeuille(
                                screenWidth * 0.15, screenWidth * 0.1),
                          ),
                          Positioned(
                            top: 120,
                            right: screenWidth *
                                0.08, // UI Design: Position adaptative
                            child: _construireIllustrationFeuille(
                                screenWidth * 0.2, screenWidth * 0.15),
                          ),
                          Positioned(
                            bottom: 20,
                            left: screenWidth *
                                0.1, // UI Design: Position adaptative
                            child: _construireIllustrationFeuille(
                                screenWidth * 0.25, screenWidth * 0.2),
                          ),
                          Positioned(
                            bottom: 60,
                            right: screenWidth *
                                0.05, // UI Design: Position adaptative
                            child: _construireIllustrationFeuille(
                                screenWidth * 0.3, screenWidth * 0.25),
                          ),
                        ],
                      ),
                    ),

                    // Section inférieure avec formulaire
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                          top: screenHeight *
                              0.05), // UI Design: Marge adaptative
                      padding: EdgeInsets.fromLTRB(
                        screenWidth * 0.08, // UI Design: Padding adaptatif
                        screenHeight * 0.04,
                        screenWidth * 0.08,
                        screenHeight * 0.03,
                      ),
                      decoration: BoxDecoration(
                        color: CouleursApp.blanc,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                              screenWidth * 0.12), // UI Design: Rayon adaptatif
                          topRight: Radius.circular(screenWidth * 0.12),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Titre "Connexion"
                            Text(
                              'Connexion',
                              style: StylesTexteApp.titre.copyWith(
                                fontSize: screenWidth *
                                    0.06, // UI Design: Taille adaptative
                              ),
                              textAlign: TextAlign.left,
                              overflow: TextOverflow
                                  .ellipsis, // UI Design: Éviter le débordement de texte
                              maxLines: 1,
                            ),
                            SizedBox(
                                height: screenHeight *
                                    0.05), // UI Design: Espacement adaptatif

                            // Champ nom d'utilisateur
                            _construireChampTexte(
                              controleur: _controleurNomUtilisateur,
                              placeholderTexte: 'Nom d\'utilisateur',
                              icone: Icons.person_outline,
                            ),
                            SizedBox(
                                height: screenHeight *
                                    0.025), // UI Design: Espacement adaptatif

                            // Champ mot de passe
                            _construireChampTexte(
                              controleur: _controleurMotDePasse,
                              placeholderTexte: 'Mot de passe',
                              icone: Icons.lock_outline,
                              estMotDePasse: true,
                            ),
                            SizedBox(
                                height: screenHeight *
                                    0.02), // UI Design: Espacement adaptatif

                            // Lien "Mot de passe oublié"
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _gererMotDePasseOublie,
                                child: Text(
                                  'Mot de passe oublié?',
                                  style: TextStyle(
                                    color: CouleursApp.accent,
                                    fontSize: screenWidth *
                                        0.035, // UI Design: Taille adaptative
                                  ),
                                  overflow: TextOverflow
                                      .ellipsis, // UI Design: Éviter le débordement de texte
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            SizedBox(
                                height: screenHeight *
                                    0.04), // UI Design: Espacement adaptatif

                            // Bouton Connexion
                            _construireBoutonConnexion(),
                            SizedBox(
                                height: screenHeight *
                                    0.04), // UI Design: Espacement adaptatif

                            // Lien vers inscription
                            _construireLienInscription(),
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
            ),
          ],
        ),
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
            size: screenWidth * 0.06, // UI Design: Taille adaptative
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, // UI Design: Padding adaptatif
            vertical: screenWidth * 0.05,
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
        color: CouleursApp.principal.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(hauteur / 2),
      ),
      child: Center(
        child: Container(
          width: largeur * 0.7,
          height: hauteur * 0.7,
          decoration: BoxDecoration(
            color: CouleursApp.principal.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(hauteur / 3),
          ),
        ),
      ),
    );
  }

  Widget _construireLogoUqarLive() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Container(
      width: screenWidth * 0.2, // UI Design: Taille adaptative
      height: screenWidth * 0.2,
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(
            screenWidth * 0.05), // UI Design: Rayon adaptatif
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.3),
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
            Icon(Icons.school,
                size: screenWidth * 0.08, // UI Design: Taille adaptative
                color: CouleursApp.principal),
            SizedBox(
                height: screenWidth * 0.01), // UI Design: Espacement adaptatif
            // Petit texte "UQAR"
            Text(
              'UQAR',
              style: TextStyle(
                fontSize: screenWidth * 0.025, // UI Design: Taille adaptative
                fontWeight: FontWeight.bold,
                color: CouleursApp.principal,
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

  Widget _construireBoutonConnexion() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return ElevatedButton(
      onPressed: _gererConnexion,
      style: DecorationsApp.boutonPrincipal.copyWith(
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(
            vertical: screenWidth * 0.04, // UI Design: Padding adaptatif
            horizontal: screenWidth * 0.08,
          ),
        ),
      ),
      child: Text(
        'Se connecter',
        style: StylesTexteApp.bouton.copyWith(
          fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
        ),
        overflow:
            TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
        maxLines: 1,
      ),
    );
  }

  Widget _construireLienInscription() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Center(
      child: RichText(
        text: TextSpan(
          text: 'Pas encore de compte? ',
          style: TextStyle(
            color: CouleursApp.texteFonce.withValues(alpha: 0.7),
            fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
          ),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: _gererCreerCompte,
                child: Text(
                  'S\'inscrire',
                  style: TextStyle(
                    color: CouleursApp.accent,
                    fontSize:
                        screenWidth * 0.035, // UI Design: Taille adaptative
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
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
    );
  }
}
