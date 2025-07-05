import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// UI Design: Écran de connexion avec design UQAR et fond dégradé violet/bleu
class ConnexionEcran extends StatefulWidget {
  const ConnexionEcran({Key? key}) : super(key: key);

  @override
  State<ConnexionEcran> createState() => _ConnexionEcranState();
}

class _ConnexionEcranState extends State<ConnexionEcran> {
  final TextEditingController _controleurNomUtilisateur =
      TextEditingController();
  final TextEditingController _controleurMotDePasse = TextEditingController();
  final GlobalKey<FormState> _cleFormulaire = GlobalKey<FormState>();

  @override
  void dispose() {
    _controleurNomUtilisateur.dispose();
    _controleurMotDePasse.dispose();
    super.dispose();
  }

  void _gererConnexion() {
    if (_cleFormulaire.currentState!.validate()) {
      // TODO: Implémenter la logique de connexion
      print('Connexion avec: ${_controleurNomUtilisateur.text}');
    }
  }

  void _gererMotDePasseOublie() {
    // TODO: Implémenter la logique de mot de passe oublié
    print('Mot de passe oublié');
  }

  void _gererCreerCompte() {
    // TODO: Naviguer vers l'écran d'inscription
    print('Créer un compte');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                // Section supérieure avec fond dégradé et illustration
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFB794F6), // Violet clair
                          Color(0xFF9F7AEA), // Violet moyen
                          CouleursApp.accent, // Bleu UQAR
                        ],
                      ),
                    ),
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
                                  fontSize: 40,
                                  color: CouleursApp.blanc,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Illustration de feuilles stylisées
                        Positioned(
                          top: 80,
                          left: 20,
                          child: _construireIllustrationFeuille(60, 40),
                        ),
                        Positioned(
                          top: 120,
                          right: 30,
                          child: _construireIllustrationFeuille(80, 60),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 40,
                          child: _construireIllustrationFeuille(100, 80),
                        ),
                        Positioned(
                          bottom: 60,
                          right: 20,
                          child: _construireIllustrationFeuille(120, 100),
                        ),
                      ],
                    ),
                  ),
                ),

                // Section inférieure avec formulaire
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _cleFormulaire,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Titre "Connexion"
                          Text(
                            'Connexion',
                            style: StylesTexteApp.titre,
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 40),

                          // Champ nom d'utilisateur
                          _construireChampTexte(
                            controleur: _controleurNomUtilisateur,
                            placeholderTexte: 'Nom d\'utilisateur',
                            icone: Icons.person_outline,
                          ),
                          const SizedBox(height: 20),

                          // Champ mot de passe
                          _construireChampTexte(
                            controleur: _controleurMotDePasse,
                            placeholderTexte: 'Mot de passe',
                            icone: Icons.lock_outline,
                            estMotDePasse: true,
                          ),
                          const SizedBox(height: 16),

                          // Lien "Mot de passe oublié"
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _gererMotDePasseOublie,
                              child: Text(
                                'Mot de passe oublié?',
                                style: StylesTexteApp.lien,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Bouton de connexion
                          ElevatedButton(
                            onPressed: _gererConnexion,
                            style: DecorationsApp.boutonPrincipal,
                            child: Text(
                              'Se connecter',
                              style: StylesTexteApp.bouton,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Lien "Créer un compte"
                          Center(
                            child: TextButton(
                              onPressed: _gererCreerCompte,
                              child: Text(
                                'Créer un compte',
                                style: StylesTexteApp.lien.copyWith(
                                  color: CouleursApp.texteFonce,
                                  decoration: TextDecoration.none,
                                ),
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
          ),
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
    return Container(
      decoration: DecorationsApp.champTexte,
      child: TextFormField(
        controller: controleur,
        obscureText: estMotDePasse,
        style: StylesTexteApp.champ,
        decoration: InputDecoration(
          hintText: placeholderTexte,
          hintStyle: StylesTexteApp.champ.copyWith(
            color: CouleursApp.texteFonce.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            icone,
            color: CouleursApp.texteFonce.withOpacity(0.5),
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône stylisée représentant UQAR
            Icon(Icons.school, size: 32, color: CouleursApp.principal),
            const SizedBox(height: 4),
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
