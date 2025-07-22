import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'connexion_ecran.dart';

// UI Design: Écran de chargement avec fond noir et logo UqarLive
class EcranChargement extends StatefulWidget {
  const EcranChargement({super.key});

  @override
  State<EcranChargement> createState() => _EcranChargementState();
}

class _EcranChargementState extends State<EcranChargement>
    with SingleTickerProviderStateMixin {
  late AnimationController _controleurAnimation;
  late Animation<double> _animationOpacite;

  @override
  void initState() {
    super.initState();
    _controleurAnimation = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animationOpacite = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controleurAnimation, curve: Curves.easeInOut),
    );

    _controleurAnimation.forward();
    _naviguerVersConnexion();
  }

  void _naviguerVersConnexion() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ConnexionEcran()),
      );
    }
  }

  @override
  void dispose() {
    _controleurAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _animationOpacite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo UqarLive
              _construireLogoUqarLive(),
              const SizedBox(height: 24),
              // Nom de l'application
              Text(
                'UqarLive',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: 48,
                  color: CouleursApp.blanc,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Sous-titre
              Text(
                'Université du Québec à Rimouski',
                style: StylesTexteApp.champ.copyWith(
                  color: CouleursApp.blanc.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              // Indicateur de chargement
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CouleursApp.accent),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construireLogoUqarLive() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.accent.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône stylisée représentant UQAR
            Icon(Icons.school, size: 48, color: CouleursApp.principal),
            const SizedBox(height: 8),
            // Petit texte "UQAR"
            Text(
              'UQAR',
              style: TextStyle(
                fontSize: 16,
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
