import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// Classe pour représenter une statistique individuelle
class ElementStatistique {
  final String valeur;
  final String label;
  final IconData? icone;
  final Color? couleurIcone;

  const ElementStatistique({
    required this.valeur,
    required this.label,
    this.icone,
    this.couleurIcone,
  });
}

// UI Design: Widget ultra-polyvalent pour toutes les sections statistiques/infos
class WidgetSectionStatistiques extends StatelessWidget {
  final String? titre;
  final IconData? iconeTitre;
  final List<ElementStatistique> statistiques;
  final TypeSectionStatistiques typeStyling;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const WidgetSectionStatistiques({
    Key? key,
    this.titre,
    this.iconeTitre,
    required this.statistiques,
    this.typeStyling = TypeSectionStatistiques.associationsStyle,
    this.margin,
    this.padding,
  }) : super(key: key);

  // Factory constructor pour le style Associations (gradient bleu foncé)
  const WidgetSectionStatistiques.associations({
    Key? key,
    required String titre,
    required List<ElementStatistique> statistiques,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) : this(
          key: key,
          titre: titre,
          statistiques: statistiques,
          typeStyling: TypeSectionStatistiques.associationsStyle,
          margin: margin,
          padding: padding,
        );

  // Factory constructor pour le style Marketplace (gradient clair avec icônes)
  const WidgetSectionStatistiques.marketplace({
    Key? key,
    required List<ElementStatistique> statistiques,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) : this(
          key: key,
          statistiques: statistiques,
          typeStyling: TypeSectionStatistiques.marketplaceStyle,
          margin: margin,
          padding: padding,
        );

  // Factory constructor pour le style Cantine (infos pratiques en grille)
  const WidgetSectionStatistiques.cantine({
    Key? key,
    required String titre,
    required IconData iconeTitre,
    required List<ElementStatistique> statistiques,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) : this(
          key: key,
          titre: titre,
          iconeTitre: iconeTitre,
          statistiques: statistiques,
          typeStyling: TypeSectionStatistiques.cantineStyle,
          margin: margin,
          padding: padding,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(16),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: _obtenirDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titre != null) ...[
            _construireTitre(),
            const SizedBox(height: 16),
          ],
          _construireContenuStatistiques(),
        ],
      ),
    );
  }

  BoxDecoration _obtenirDecoration() {
    switch (typeStyling) {
      case TypeSectionStatistiques.associationsStyle:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [CouleursApp.principal, CouleursApp.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: CouleursApp.principal.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        );
      case TypeSectionStatistiques.marketplaceStyle:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              CouleursApp.accent.withValues(alpha: 0.1),
              CouleursApp.principal.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CouleursApp.accent.withValues(alpha: 0.3),
          ),
        );
      case TypeSectionStatistiques.cantineStyle:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              CouleursApp.accent.withValues(alpha: 0.1),
              CouleursApp.principal.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CouleursApp.accent.withValues(alpha: 0.3),
            width: 1,
          ),
        );
    }
  }

  Widget _construireTitre() {
    switch (typeStyling) {
      case TypeSectionStatistiques.associationsStyle:
        return Center(
          child: Text(
            titre!,
            style: StylesTexteApp.titre.copyWith(
              color: CouleursApp.blanc,
              fontSize: 20,
            ),
          ),
        );
      case TypeSectionStatistiques.cantineStyle:
        return Row(
          children: [
            Icon(
              iconeTitre!,
              color: CouleursApp.principal,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              titre!,
              style: StylesTexteApp.titre.copyWith(fontSize: 18),
            ),
          ],
        );
      default:
        return Text(
          titre!,
          style: StylesTexteApp.titre.copyWith(fontSize: 18),
        );
    }
  }

  Widget _construireContenuStatistiques() {
    switch (typeStyling) {
      case TypeSectionStatistiques.associationsStyle:
        return _construireStyleAssociations();
      case TypeSectionStatistiques.marketplaceStyle:
        return _construireStyleMarketplace();
      case TypeSectionStatistiques.cantineStyle:
        return _construireStyleCantine();
    }
  }

  // Style Associations : 3 colonnes de chiffres simples
  Widget _construireStyleAssociations() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: statistiques.map((stat) => _construireStatistiqueAssociation(stat)).toList(),
    );
  }

  Widget _construireStatistiqueAssociation(ElementStatistique statistique) {
    return Column(
      children: [
        Text(
          statistique.valeur,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CouleursApp.blanc,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          statistique.label,
          style: TextStyle(
            fontSize: 12,
            color: CouleursApp.blanc.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  // Style Marketplace : 3 colonnes avec icônes et séparateurs
  Widget _construireStyleMarketplace() {
    final widgets = <Widget>[];
    
    for (int i = 0; i < statistiques.length; i++) {
      widgets.add(_construireStatistiqueMarketplace(statistiques[i]));
      
      // Ajouter séparateur sauf pour le dernier élément
      if (i < statistiques.length - 1) {
        widgets.add(Container(
          height: 40,
          width: 1,
          color: CouleursApp.principal.withValues(alpha: 0.3),
        ));
      }
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: widgets,
    );
  }

  Widget _construireStatistiqueMarketplace(ElementStatistique statistique) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (statistique.icone != null)
          Icon(
            statistique.icone!,
            color: statistique.couleurIcone ?? CouleursApp.principal,
            size: 24,
          ),
        if (statistique.icone != null) const SizedBox(height: 8),
        Text(
          statistique.valeur,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CouleursApp.principal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          statistique.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: CouleursApp.texteFonce.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  // Style Cantine : Grille 2x2 d'infos pratiques
  Widget _construireStyleCantine() {
    final widgets = <Widget>[];
    
    for (int i = 0; i < statistiques.length; i += 2) {
      final row = <Widget>[];
      
      row.add(Expanded(child: _construireInfoCantine(statistiques[i])));
      
      if (i + 1 < statistiques.length) {
        row.add(Expanded(child: _construireInfoCantine(statistiques[i + 1])));
      }
      
      widgets.add(Row(children: row));
      
      // Ajouter espacement sauf pour la dernière ligne
      if (i + 2 < statistiques.length) {
        widgets.add(const SizedBox(height: 12));
      }
    }
    
    return Column(children: widgets);
  }

  Widget _construireInfoCantine(ElementStatistique statistique) {
    return Row(
      children: [
        if (statistique.icone != null) ...[
          Icon(
            statistique.icone!,
            color: statistique.couleurIcone ?? CouleursApp.accent,
            size: 16,
          ),
          const SizedBox(width: 8),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              statistique.label,
              style: TextStyle(
                fontSize: 12,
                color: CouleursApp.texteFonce.withValues(alpha: 0.6),
              ),
            ),
            Text(
              statistique.valeur,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: CouleursApp.texteFonce,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Énumération pour les différents types de styling
enum TypeSectionStatistiques {
  associationsStyle,
  marketplaceStyle,
  cantineStyle,
} 