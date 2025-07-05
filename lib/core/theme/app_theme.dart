import 'package:flutter/material.dart';

// UI Design: Centralisation du thème UQAR
class CouleursApp {
  static const Color principal = Color(0xFF005499); // Bleu foncé UQAR
  static const Color accent = Color(0xFF00A1E4); // Bleu ciel UQAR
  static const Color fond = Color(0xFFF8F9FA); // Gris très clair
  static const Color texteFonce = Color(0xFF2C2C2C); // Texte foncé
  static const Color blanc = Colors.white;
}

class StylesTexteApp {
  static const TextStyle titre = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: CouleursApp.principal,
  );
  static const TextStyle champ = TextStyle(
    fontSize: 18,
    color: CouleursApp.texteFonce,
  );
  static const TextStyle bouton = TextStyle(
    fontSize: 20,
    color: CouleursApp.blanc,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle lien = TextStyle(
    fontSize: 16,
    color: CouleursApp.accent,
    decoration: TextDecoration.underline,
  );
}

class DecorationsApp {
  static BoxDecoration champTexte = BoxDecoration(
    color: CouleursApp.blanc,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: CouleursApp.principal.withValues(alpha: 0.08),
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
    ],
  );
  static ButtonStyle boutonPrincipal = ElevatedButton.styleFrom(
    backgroundColor: CouleursApp.principal,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
    textStyle: StylesTexteApp.bouton,
  );
}
