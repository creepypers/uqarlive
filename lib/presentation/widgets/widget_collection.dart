import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// UI Design: Widget Collection unifié avec gestion d'états intégrée
class WidgetCollection<T> extends StatelessWidget {
  final List<T> elements;
  final bool enChargement;
  final Widget Function(BuildContext, T, int) constructeurElement;
  final TypeCollection type;
  final Widget? etatVide;
  final String? messageEtatVide;
  final IconData? iconeEtatVide;
  final EdgeInsets padding;
  
  // Propriétés pour liste horizontale
  final double? hauteur;
  final double espacementHorizontal;
  
  // Propriétés pour grille
  final int nombreColonnes;
  final double espacementColonnes;
  final double espacementLignes;
  final double ratioAspect;
  final bool reduireHauteur;
  
  // Propriétés pour liste verticale
  final double espacementVertical;
  final bool separerElements;

  const WidgetCollection({
    super.key,
    required this.elements,
    required this.constructeurElement,
    this.type = TypeCollection.listeVerticale,
    this.enChargement = false,
    this.etatVide,
    this.messageEtatVide,
    this.iconeEtatVide,
    this.padding = EdgeInsets.zero,
    
    // Liste horizontale
    this.hauteur = 190,
    this.espacementHorizontal = 16,
    
    // Grille
    this.nombreColonnes = 2,
    this.espacementColonnes = 16,
    this.espacementLignes = 16,
    this.ratioAspect = 0.8,
    this.reduireHauteur = true,
    
    // Liste verticale
    this.espacementVertical = 12,
    this.separerElements = false,
  });

  // Factory constructor pour liste horizontale
  factory WidgetCollection.listeHorizontale({
    required List<T> elements,
    required Widget Function(BuildContext, T, int) constructeurElement,
    bool enChargement = false,
    double hauteur = 190,
    double espacementHorizontal = 16,
    Widget? etatVide,
    String? messageEtatVide,
    IconData? iconeEtatVide,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return WidgetCollection<T>(
      elements: elements,
      constructeurElement: constructeurElement,
      type: TypeCollection.listeHorizontale,
      enChargement: enChargement,
      hauteur: hauteur,
      espacementHorizontal: espacementHorizontal,
      etatVide: etatVide,
      messageEtatVide: messageEtatVide,
      iconeEtatVide: iconeEtatVide,
      padding: padding,
    );
  }

  // Factory constructor pour grille
  factory WidgetCollection.grille({
    required List<T> elements,
    required Widget Function(BuildContext, T, int) constructeurElement,
    bool enChargement = false,
    int nombreColonnes = 2,
    double espacementColonnes = 16,
    double espacementLignes = 16,
    double ratioAspect = 0.8,
    bool reduireHauteur = true,
    Widget? etatVide,
    String? messageEtatVide,
    IconData? iconeEtatVide,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return WidgetCollection<T>(
      elements: elements,
      constructeurElement: constructeurElement,
      type: TypeCollection.grille,
      enChargement: enChargement,
      nombreColonnes: nombreColonnes,
      espacementColonnes: espacementColonnes,
      espacementLignes: espacementLignes,
      ratioAspect: ratioAspect,
      reduireHauteur: reduireHauteur,
      etatVide: etatVide,
      messageEtatVide: messageEtatVide,
      iconeEtatVide: iconeEtatVide,
      padding: padding,
    );
  }

  // Factory constructor pour liste verticale
  factory WidgetCollection.listeVerticale({
    required List<T> elements,
    required Widget Function(BuildContext, T, int) constructeurElement,
    bool enChargement = false,
    double espacementVertical = 12,
    bool separerElements = false,
    Widget? etatVide,
    String? messageEtatVide,
    IconData? iconeEtatVide,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return WidgetCollection<T>(
      elements: elements,
      constructeurElement: constructeurElement,
      type: TypeCollection.listeVerticale,
      enChargement: enChargement,
      espacementVertical: espacementVertical,
      separerElements: separerElements,
      etatVide: etatVide,
      messageEtatVide: messageEtatVide,
      iconeEtatVide: iconeEtatVide,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: _construireContenu(),
    );
  }

  Widget _construireContenu() {
    // État de chargement
    if (enChargement) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: CircularProgressIndicator(
            color: CouleursApp.principal,
          ),
        ),
      );
    }

    // État vide
    if (elements.isEmpty) {
      return _construireEtatVide();
    }

    // Contenu selon le type
    switch (type) {
      case TypeCollection.listeHorizontale:
        return _construireListeHorizontale();
      case TypeCollection.grille:
        return _construireGrille();
      case TypeCollection.listeVerticale:
        return _construireListeVerticale();
    }
  }

  Widget _construireEtatVide() {
    if (etatVide != null) return etatVide!;
    
    return Center(
      child: _WidgetEtatVide(
        icone: iconeEtatVide ?? _obtenirIconeParDefaut(),
        titre: messageEtatVide ?? _obtenirMessageParDefaut(),
      ),
    );
  }

  Widget _construireListeHorizontale() {
    return SizedBox(
      height: hauteur,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: elements.length,
        separatorBuilder: (context, index) => SizedBox(width: espacementHorizontal),
        itemBuilder: (context, index) {
          return constructeurElement(context, elements[index], index);
        },
      ),
    );
  }

  Widget _construireGrille() {
    return GridView.builder(
      shrinkWrap: reduireHauteur,
      physics: reduireHauteur 
          ? const NeverScrollableScrollPhysics() 
          : const ScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: nombreColonnes,
        crossAxisSpacing: espacementColonnes,
        mainAxisSpacing: espacementLignes,
        childAspectRatio: ratioAspect,
      ),
      itemCount: elements.length,
      itemBuilder: (context, index) {
        return constructeurElement(context, elements[index], index);
      },
    );
  }

  Widget _construireListeVerticale() {
    if (separerElements) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: elements.length,
        separatorBuilder: (context, index) => SizedBox(height: espacementVertical),
        itemBuilder: (context, index) {
          return constructeurElement(context, elements[index], index);
        },
      );
    } else {
      return Builder(
        builder: (context) {
          return Column(
            children: elements.asMap().entries.map((entry) {
              int index = entry.key;
              T element = entry.value;
              
              return Column(
                children: [
                  constructeurElement(context, element, index),
                  if (index < elements.length - 1) SizedBox(height: espacementVertical),
                ],
              );
            }).toList(),
          );
        },
      );
    }
  }

  IconData _obtenirIconeParDefaut() {
    switch (type) {
      case TypeCollection.listeHorizontale:
        return Icons.view_list;
      case TypeCollection.grille:
        return Icons.grid_view_outlined;
      case TypeCollection.listeVerticale:
        return Icons.inbox_outlined;
    }
  }

  String _obtenirMessageParDefaut() {
    switch (type) {
      case TypeCollection.listeHorizontale:
        return 'Aucun élément dans la liste';
      case TypeCollection.grille:
        return 'Aucun élément trouvé';
      case TypeCollection.listeVerticale:
        return 'Aucun élément disponible';
    }
  }

  // Factory constructors pour états vides spécifiques
  static Widget etatVideAucunLivre() {
    return const _WidgetEtatVide(
      icone: Icons.menu_book_outlined,
      titre: 'Aucun livre disponible',
      sousTitre: 'Il n\'y a pas de livres à échanger pour le moment. Soyez le premier à en proposer un !',
    );
  }

  static Widget etatVideAucunMenu() {
    return const _WidgetEtatVide(
      icone: Icons.restaurant_outlined,
      titre: 'Aucun menu disponible',
      sousTitre: 'La cantine n\'a pas encore publié ses menus pour aujourd\'hui.',
    );
  }

  static Widget etatVideAucunResultat() {
    return const _WidgetEtatVide(
      icone: Icons.search_off,
      titre: 'Aucun résultat',
      sousTitre: 'Essayez de modifier vos critères de recherche.',
    );
  }

  static Widget etatVideAucuneConnexion() {
    return const _WidgetEtatVide(
      icone: Icons.wifi_off,
      titre: 'Pas de connexion',
      sousTitre: 'Vérifiez votre connexion internet et réessayez.',
    );
  }
}

// Widget État Vide intégré dans Collection
class _WidgetEtatVide extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String? sousTitre;
  final Color? couleurIcone;
  final Color? couleurTitre;

  const _WidgetEtatVide({
    required this.icone,
    required this.titre,
    this.sousTitre,
    this.couleurIcone,
    this.couleurTitre,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icone,
            size: 80,
            color: couleurIcone ?? CouleursApp.principal.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 20),
          Text(
            titre,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: couleurTitre ?? CouleursApp.texteFonce,
            ),
            textAlign: TextAlign.center,
          ),
          if (sousTitre != null) ...[
            const SizedBox(height: 8),
            Text(
              sousTitre!,
              style: TextStyle(
                fontSize: 14,
                color: CouleursApp.texteFonce.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Énumération des types de collection
enum TypeCollection {
  listeHorizontale,
  grille,
  listeVerticale,
} 