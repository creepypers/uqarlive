import 'package:flutter/material.dart';

// UI Design: Centralisation du thème UQAR (redondance supprimée)

class StylesTexteApp {
  // UI Design: Styles de base existants
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

  // UI Design: Styles étendus pour tous les widgets
  static const TextStyle titrePage = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: CouleursApp.texteFonce,
  );
  static const TextStyle grandTitre = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: CouleursApp.texteFonce,
  );
  static const TextStyle moyenTitre = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: CouleursApp.texteFonce,
  );
  static const TextStyle petitTitre = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: CouleursApp.texteFonce,
  );
  
  // Styles de texte blanc
  static const TextStyle titrePageBlanc = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: CouleursApp.blanc,
  );
  static const TextStyle grandTitreBlanc = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: CouleursApp.blanc,
  );
  static const TextStyle moyenBlanc = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: CouleursApp.blanc,
  );
  static const TextStyle petitBlanc = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: CouleursApp.blanc,
  );
  
  // Styles de corps de texte
  static const TextStyle corpsNormal = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: CouleursApp.texteFonce,
  );
  static const TextStyle corpsGris = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );
  static const TextStyle petitCorps = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: CouleursApp.texteFonce,
  );
  static const TextStyle petitGris = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );
  
  // Styles de liens
  static const TextStyle lienPrincipal = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: CouleursApp.principal,
  );
  static const TextStyle lienAccent = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: CouleursApp.accent,
  );
}

// UI Design: Centralisation du thème UQAR complet
class CouleursApp {
  static const Color principal = Color(0xFF005499); // Bleu foncé UQAR
  static const Color accent = Color(0xFF00A1E4); // Bleu ciel UQAR
  static const Color fond = Color(0xFFF8F9FA); // Gris très clair
  static const Color texteFonce = Color(0xFF2C2C2C); // Texte foncé
  static const Color blanc = Colors.white;
  static const Color gris = Colors.grey; // UI Design: Ajouté pour compatibilité
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
