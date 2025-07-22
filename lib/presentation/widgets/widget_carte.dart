import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/livre.dart';
import '../../domain/entities/menu.dart';

// UI Design: Widget Carte unifié avec système de badges intégré
class WidgetCarte extends StatelessWidget {
  final String titre;
  final String sousTitre;
  final String? texteSupplementaire;
  final IconData icone;
  final Color? couleurIcone;
  final Color? couleurFond;
  final List<WidgetBadge> badges;
  final Widget? piedDePage;
  final VoidCallback? onTap;
  final double? largeur;
  final double? hauteur;
  final bool modeListe;
  final double? tailleIcone;
  final bool modeHorizontal;

  const WidgetCarte({
    super.key,
    required this.titre,
    required this.sousTitre,
    this.texteSupplementaire,
    required this.icone,
    this.couleurIcone,
    this.couleurFond,
    this.badges = const [],
    this.piedDePage,
    this.onTap,
    this.largeur,
    this.hauteur,
    this.modeListe = false,
    this.tailleIcone,
    this.modeHorizontal = false,
  });

  // Factory constructor pour les livres
  factory WidgetCarte.livre({
    required Livre livre,
    double? largeur,
    double? hauteur,
    VoidCallback? onTap,
    bool modeListe = false,
    bool afficherBadgeEchange = true,
    bool afficherBadgeEtat = true,
  }) {
    List<WidgetBadge> badges = [];
    if (afficherBadgeEtat) {
      badges.add(WidgetBadge.etatLivre(texte: livre.etatLivre));
    }
    if (afficherBadgeEchange) {
      badges.add(const WidgetBadge.echange());
    }

    return WidgetCarte(
      titre: livre.titre,
      sousTitre: livre.auteur,
      texteSupplementaire: modeListe ? null : livre.matiere,
      icone: Icons.menu_book,
      couleurIcone: CouleursApp.principal,
      couleurFond: CouleursApp.principal.withValues(alpha: 0.07),
      badges: badges,
      piedDePage: _construirePiedPageLivre(livre, modeListe),
      onTap: onTap ?? () => _naviguerVersDetailsLivre(livre),
      largeur: largeur ?? (modeListe ? 150 : null),
      hauteur: hauteur ?? (modeListe ? 185 : null),
      modeListe: modeListe,
      tailleIcone: modeListe ? 40 : 50,
      modeHorizontal: false,
    );
  }

  // Factory constructor pour les menus
  factory WidgetCarte.menu({
    required Menu menu,
    double? largeur,
    double? hauteur,
    VoidCallback? onTap,
    bool modeListe = false,
  }) {
    List<WidgetBadge> badges = [
      WidgetBadge(
        texte: '${menu.prix.toStringAsFixed(2)}\$',
        couleurFond: Colors.green,
        tailleFonte: 10,
      ),
    ];

    if (menu.estVegetarien) {
      badges.add(
        WidgetBadge(
          texte: 'VÉG',
          couleurFond: Colors.green.shade600,
          tailleFonte: 8,
        ),
      );
    }

    Color couleurCategorie = _obtenirCouleurCategorie(menu.categorie);
    IconData iconeCategorie = _obtenirIconeCategorie(menu.categorie);

    return WidgetCarte(
      titre: menu.nom,
      sousTitre: menu.description,
      icone: iconeCategorie,
      couleurIcone: couleurCategorie,
      couleurFond: couleurCategorie.withValues(alpha: 0.1),
      badges: badges,
      piedDePage: _construirePiedPageMenu(menu),
      onTap: onTap,
      largeur: largeur ?? (modeListe ? 180 : null),
      hauteur:
          hauteur ??
          (modeListe
              ? 185
              : null), // UI Design: Hauteur par défaut cohérente avec les livres
      modeListe: modeListe,
      tailleIcone: modeListe ? 40 : 50,
      modeHorizontal: false,
    );
  }

  // Factory constructor pour les associations
  factory WidgetCarte.association({
    required String nom,
    required String description,
    required IconData icone,
    Color? couleurIcone,
    VoidCallback? onTap,
    double? largeur,
    double? hauteur,
    bool modeHorizontal = false,
  }) {
    return WidgetCarte(
      titre: nom,
      sousTitre: description,
      icone: icone,
      couleurIcone: couleurIcone ?? CouleursApp.principal,
      couleurFond: (couleurIcone ?? CouleursApp.principal).withValues(
        alpha: 0.1,
      ),
      onTap: onTap,
      largeur: largeur ?? (modeHorizontal ? 280 : 140),
      hauteur: hauteur ?? (modeHorizontal ? 80 : 115),
      modeListe: true,
      tailleIcone: modeHorizontal ? 28 : 22,
      modeHorizontal: modeHorizontal,
    );
  }

  // Factory constructor pour les salles de révision
  factory WidgetCarte.salle({
    required String nom,
    required String description,
    required String localisation,
    required int capacite,
    required double tarif,
    required bool estDisponible,
    required List<String> equipements,
    VoidCallback? onTapDetails,
    VoidCallback? onTapReserver,
    String? heureLibre,
    double? largeur,
    double? hauteur,
  }) {
    List<WidgetBadge> badges = [
      WidgetBadge(
        texte: estDisponible ? 'Disponible' : 'Réservée',
        couleurFond: estDisponible ? Colors.green : Colors.grey,
        tailleFonte: 10,
      ),
    ];

    return WidgetCarte(
      titre: nom,
      sousTitre: description,
      texteSupplementaire: localisation,
      icone: Icons.meeting_room,
      couleurIcone: estDisponible ? CouleursApp.principal : Colors.grey,
      couleurFond: estDisponible 
          ? CouleursApp.principal.withValues(alpha: 0.1)
          : Colors.grey.withValues(alpha: 0.1),
      badges: badges,
      piedDePage: _construirePiedPageSalle(capacite, equipements, heureLibre, onTapDetails, onTapReserver),
      onTap: onTapDetails,
      largeur: largeur,
      hauteur: hauteur ?? 185, // UI Design: Réduit de 220 à 185 pour éviter overflow
      modeListe: false,
      tailleIcone: 45,
      modeHorizontal: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: largeur,
        height: hauteur,
        margin: modeListe ? const EdgeInsets.only(right: 16) : null,
        decoration: BoxDecoration(
          color: CouleursApp.blanc,
          borderRadius: BorderRadius.circular(16),
          border:
              modeListe && hauteur != null && hauteur! <= 115
                  ? Border.all(
                    color: CouleursApp.principal.withValues(alpha: 0.2),
                  )
                  : null,
          boxShadow: [
            BoxShadow(
              color: CouleursApp.principal.withValues(
                alpha: modeListe ? 0.08 : 0.1,
              ),
              blurRadius: modeListe ? 8 : 12,
              offset: Offset(0, modeListe ? 2 : 4),
            ),
          ],
        ),
        child: _construireContenu(),
      ),
    );
  }

  Widget _construireContenu() {
    // Pour les cartes d'associations en mode HORIZONTAL (rectangulaires)
    if (modeListe && modeHorizontal) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            // Icône à gauche
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: couleurFond,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icone, color: couleurIcone, size: tailleIcone),
            ),
            const SizedBox(width: 12),
            // Informations à droite
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titre,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CouleursApp.texteFonce,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sousTitre,
                    style: TextStyle(
                      fontSize: 12,
                      color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Pour les cartes d'associations en mode VERTICAL (format carré)
    if (modeListe && hauteur != null && hauteur! <= 115) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: couleurFond,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icone, color: couleurIcone, size: tailleIcone),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                titre,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: CouleursApp.texteFonce,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                sousTitre,
                style: TextStyle(
                  fontSize: 9,
                  color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    // Pour les cartes standards (livres, menus) en mode liste
    if (modeListe) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section icône avec badges - hauteur fixe en mode liste
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: couleurFond,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icone,
                    size: tailleIcone ?? 40,
                    color: couleurIcone,
                  ),
                ),
                // Badges positionnés
                ...badges.asMap().entries.map((entry) {
                  int index = entry.key;
                  WidgetBadge badge = entry.value;

                  return Positioned(
                    top: 8,
                    right: index == 0 ? 8 : null,
                    left: index == 1 ? 8 : null,
                    child: badge,
                  );
                }),
              ],
            ),
          ),
          // Section informations - hauteur flexible restante
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titre,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: CouleursApp.texteFonce,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sousTitre,
                    style: TextStyle(
                      fontSize: 9,
                      color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  if (piedDePage != null)
                    SizedBox(height: 16, child: piedDePage!),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Pour les cartes standards (livres, menus) en mode grille
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section icône avec badges
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              color: couleurFond,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icone,
                    size: tailleIcone ?? 45,
                    color: couleurIcone,
                  ),
                ),
                // Badges positionnés
                ...badges.asMap().entries.map((entry) {
                  int index = entry.key;
                  WidgetBadge badge = entry.value;

                  return Positioned(
                    top: 8,
                    right: index == 0 ? 8 : null,
                    left: index == 1 ? 8 : null,
                    child: badge,
                  );
                }),
              ],
            ),
          ),
        ),
        // Section informations
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titre,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CouleursApp.texteFonce,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  sousTitre,
                  style: TextStyle(
                    fontSize: 9,
                    color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                    height: 1.1,
                  ),
                  maxLines: texteSupplementaire != null ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (texteSupplementaire != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    texteSupplementaire!,
                    style: TextStyle(
                      fontSize: 9,
                      color: CouleursApp.principal,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const Spacer(),
                if (piedDePage != null) piedDePage!,
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Méthodes statiques pour construire les pieds de page
  static Widget _construirePiedPageLivre(Livre livre, bool modeListe) {
    if (livre.prix == null) return const SizedBox.shrink();
    return SizedBox(
      height: 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '${livre.prix!.toStringAsFixed(2).replaceAll('.', ',')} €',
            style: TextStyle(
              fontSize: 14,
              color: CouleursApp.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _construirePiedPageMenu(Menu menu) {
    return SizedBox(
      height: 14, // UI Design: Hauteur contrôlée similaire aux livres
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center, // UI Design: Centre verticalement
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 11, // UI Design: Réduit de 12 à 11
            color: CouleursApp.accent,
          ),
          const SizedBox(width: 3), // UI Design: Réduit de 4 à 3
          Flexible(
            child: Text(
              menu.categorie.toUpperCase(),
              style: TextStyle(
                fontSize: 9, // UI Design: Réduit de 10 à 9
                color: CouleursApp.accent,
                fontWeight: FontWeight.w500,
                height: 1.0, // UI Design: Hauteur de ligne compacte
              ),
              maxLines: 1, // UI Design: Force 1 ligne
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          if (menu.note != null) ...[
            Icon(
              Icons.star,
              size: 11, // UI Design: Réduit de 12 à 11
              color: Colors.orange,
            ),
            const SizedBox(width: 2),
            Text(
              menu.note!.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 9, // UI Design: Réduit de 10 à 9
                color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
                height: 1.0, // UI Design: Hauteur de ligne compacte
              ),
              maxLines: 1, // UI Design: Force 1 ligne
            ),
          ],
        ],
      ),
    );
  }

  static Widget _construirePiedPageSalle(int capacite, List<String> equipements, String? heureLibre, VoidCallback? onTapDetails, VoidCallback? onTapReserver) {
    return SizedBox(
      height: 14, // UI Design: Hauteur contrôlée similaire aux autres cartes
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Capacité
          Icon(Icons.people_outline, size: 11, color: CouleursApp.accent),
          const SizedBox(width: 4),
          Text(
            '$capacite places',
            style: TextStyle(
              fontSize: 9,
              color: CouleursApp.texteFonce.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
            maxLines: 1,
          ),
          const Spacer(),
          // Indication équipements (juste le nombre)
          if (equipements.isNotEmpty) 
            Text(
              '${equipements.length} équip.',
              style: TextStyle(
                fontSize: 8,
                color: CouleursApp.principal,
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
              maxLines: 1,
            ),
        ],
      ),
    );
  }

  // Méthodes statiques pour les couleurs et icônes
  static Color _obtenirCouleurCategorie(String categorie) {
    switch (categorie) {
      case 'menu_jour':
        return CouleursApp.principal;
      case 'plat':
        return CouleursApp.accent;
      case 'snack':
        return Colors.orange;
      case 'dessert':
        return Colors.pink;
      case 'boisson':
        return Colors.blue;
      default:
        return CouleursApp.principal;
    }
  }

  static IconData _obtenirIconeCategorie(String categorie) {
    switch (categorie) {
      case 'menu_jour':
        return Icons.restaurant_menu;
      case 'plat':
        return Icons.lunch_dining;
      case 'snack':
        return Icons.fastfood;
      case 'dessert':
        return Icons.cake;
      case 'boisson':
        return Icons.local_drink;
      default:
        return Icons.restaurant;
    }
  }

  static void _naviguerVersDetailsLivre(Livre livre) {
    // Note: Cette méthode sera appelée depuis un contexte où nous n'avons pas accès au context
    // Il faudra passer le context via onTap ou utiliser un navigator global
  }
}

// UI Design: Widget Badge intégré pour différents types de badges
class WidgetBadge extends StatelessWidget {
  final String texte;
  final Color? couleurFond;
  final Color? couleurTexte;
  final double tailleFonte;
  final FontWeight poidsFonte;
  final EdgeInsets rembourrage;
  final double rayonBordure;

  const WidgetBadge({
    super.key,
    required this.texte,
    this.couleurFond,
    this.couleurTexte = Colors.white,
    this.tailleFonte = 10,
    this.poidsFonte = FontWeight.w600,
    this.rembourrage = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.rayonBordure = 12,
  });

  // Factory constructors pour différents types de badges
  const WidgetBadge.etatLivre({
    super.key,
    required this.texte,
    this.couleurTexte = Colors.white,
    this.tailleFonte = 10,
    this.poidsFonte = FontWeight.w600,
    this.rembourrage = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.rayonBordure = 12,
  }) : couleurFond = null;

  const WidgetBadge.echange({
    super.key,
    this.texte = 'ÉCHANGE',
    this.couleurFond = Colors.green,
    this.couleurTexte = Colors.white,
    this.tailleFonte = 8,
    this.poidsFonte = FontWeight.bold,
    this.rembourrage = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.rayonBordure = 8,
  });

  const WidgetBadge.vente({
    super.key,
    this.texte = 'VENTE',
    this.couleurFond = Colors.blue,
    this.couleurTexte = Colors.white,
    this.tailleFonte = 8,
    this.poidsFonte = FontWeight.bold,
    this.rembourrage = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.rayonBordure = 8,
  });

  @override
  Widget build(BuildContext context) {
    Color couleurFondFinale = couleurFond ?? _obtenirCouleurEtatLivre(texte);

    return Container(
      padding: rembourrage,
      decoration: BoxDecoration(
        color: couleurFondFinale,
        borderRadius: BorderRadius.circular(rayonBordure),
      ),
      child: Text(
        texte,
        style: TextStyle(
          fontSize: tailleFonte,
          color: couleurTexte,
          fontWeight: poidsFonte,
        ),
      ),
    );
  }

  // Couleur selon l'état du livre
  Color _obtenirCouleurEtatLivre(String etat) {
    switch (etat) {
      case 'Excellent':
        return Colors.green;
      case 'Très bon':
        return Colors.blue;
      case 'Bon':
        return Colors.orange;
      case 'Acceptable':
        return Colors.red.shade300;
      default:
        return Colors.grey;
    }
  }
}
