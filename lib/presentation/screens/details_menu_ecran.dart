import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/menu.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import '../widgets/widget_section_statistiques.dart';
import '../services/navigation_service.dart';

// UI Design: Page de détails complète d'un menu de la cantine UQAR
class DetailsMenuEcran extends StatelessWidget {
  final Menu menu;

  const DetailsMenuEcran({
    super.key,
    required this.menu,
  });

  @override
  Widget build(BuildContext context) {
    // UI Design: Obtenir les dimensions de l'écran pour l'adaptabilité
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;
    
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      resizeToAvoidBottomInset: true, // UI Design: Éviter les débordements avec le clavier
      appBar: WidgetBarreAppPersonnalisee(
        titre: menu.nom,
        sousTitre: _obtenirNomCategorie(menu.categorie),
        afficherProfil: false,
        widgetFin: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: CouleursApp.blanc, size: screenWidth * 0.06), // UI Design: Taille adaptative
              onPressed: () => Navigator.pop(context),
            ),
            IconButton(
              icon: Icon(Icons.favorite_border, color: CouleursApp.blanc, size: screenWidth * 0.06), // UI Design: Taille adaptative
              onPressed: () => _ajouterAuxFavoris(context),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: viewInsets.bottom + padding.bottom + screenHeight * 0.025, // UI Design: Padding adaptatif pour éviter les débordements
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section En-tête avec image et prix
              _construireEnTete(context),
              SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
              
              // Section Informations nutritionnelles
              _construireSectionNutrition(),
              SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
              
              // Section Ingrédients et allergènes
              _construireSectionIngredients(context),
              SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
              
              // Section Note et avis si disponible
              if (menu.note != null) ...[
                _construireSectionNote(context),
                SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBarWidget(
        indexSelectionne: 0, // Cantine
        onTap: (index) => NavigationService.gererNavigationNavBar(context, index),
      ),
    );
  }

  // UI Design: En-tête avec image et informations principales
  Widget _construireEnTete(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04), // UI Design: Marge adaptative
      padding: EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _obtenirCouleurCategorie(menu.categorie),
            _obtenirCouleurCategorie(menu.categorie).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _obtenirCouleurCategorie(menu.categorie).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icône catégorie
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04), // UI Design: Padding adaptatif
                decoration: BoxDecoration(
                  color: CouleursApp.blanc.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _obtenirIconeCategorie(menu.categorie),
                  size: screenWidth * 0.1, // UI Design: Taille adaptative
                  color: CouleursApp.blanc,
                ),
              ),
              SizedBox(width: screenWidth * 0.04), // UI Design: Espacement adaptatif
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.nom,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05, // UI Design: Taille adaptative
                        fontWeight: FontWeight.bold,
                        color: CouleursApp.blanc,
                      ),
                      overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                      maxLines: 2,
                    ),
                    SizedBox(height: screenHeight * 0.005), // UI Design: Espacement adaptatif
                    Text(
                      menu.description,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                        color: CouleursApp.blanc.withValues(alpha: 0.9),
                      ),
                      overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              // Prix
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03, // UI Design: Padding adaptatif
                  vertical: screenWidth * 0.02,
                ),
                decoration: BoxDecoration(
                  color: CouleursApp.blanc,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${menu.prix.toStringAsFixed(2)} \$',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                    fontWeight: FontWeight.bold,
                    color: _obtenirCouleurCategorie(menu.categorie),
                  ),
                  overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                  maxLines: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
          // Badges
          Row(
            children: [
              ...menu.badges.map((badge) => Container(
                margin: EdgeInsets.only(right: screenWidth * 0.02), // UI Design: Espacement adaptatif
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02, // UI Design: Padding adaptatif
                  vertical: screenWidth * 0.01,
                ),
                decoration: BoxDecoration(
                  color: CouleursApp.blanc.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: CouleursApp.blanc,
                    fontSize: screenWidth * 0.025, // UI Design: Taille adaptative
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                  maxLines: 1,
                ),
              )),
              if (!menu.estDisponible)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02, // UI Design: Padding adaptatif
                    vertical: screenWidth * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ÉPUISÉ',
                    style: TextStyle(
                      color: CouleursApp.blanc,
                      fontSize: screenWidth * 0.025, // UI Design: Taille adaptative
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                    maxLines: 1,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // UI Design: Section informations nutritionnelles
  Widget _construireSectionNutrition() {
    return WidgetSectionStatistiques.marketplace(
      statistiques: [
        ElementStatistique(
          valeur: menu.calories != null ? '${menu.calories}' : 'N/A',
          label: 'Calories\n(kcal)',
          icone: Icons.local_fire_department,
          couleurIcone: Colors.orange,
        ),
        ElementStatistique(
          valeur: menu.estVegetarien ? 'Oui' : 'Non',
          label: 'Végétarien',
          icone: Icons.eco,
          couleurIcone: Colors.green,
        ),
        ElementStatistique(
          valeur: menu.estVegan ? 'Oui' : 'Non',
          label: 'Vegan',
          icone: Icons.nature,
          couleurIcone: Colors.green.shade700,
        ),
      ],
    );
  }

  // UI Design: Section ingrédients et allergènes
  Widget _construireSectionIngredients(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Marge adaptative
      padding: EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant_menu,
                color: _obtenirCouleurCategorie(menu.categorie),
                size: screenWidth * 0.06, // UI Design: Taille adaptative
              ),
              SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Text(
                'Ingrédients & Allergènes',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                ),
                overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
          
          // Ingrédients
          _construireInfoSection(
            'Ingrédients',
            menu.ingredients.join(', '),
            Icons.grain,
            Colors.brown,
            context,
          ),
          
          if (menu.allergenes != null) ...[
            SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
            _construireInfoSection(
              'Allergènes',
              menu.allergenes!,
              Icons.warning,
              Colors.red,
              context,
            ),
          ],
          
          if (menu.nutritionInfo != null) ...[
            SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
            _construireInfoSection(
              'Informations nutritionnelles',
              menu.nutritionInfo!,
              Icons.info,
              CouleursApp.accent,
              context,
            ),
          ],
        ],
      ),
    );
  }

  // UI Design: Section note et avis
  Widget _construireSectionNote(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Marge adaptative
      padding: EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.orange,
                size: screenWidth * 0.06, // UI Design: Taille adaptative
              ),
              SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Text(
                'Évaluation',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                ),
                overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
          Row(
            children: [
              // Note
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < (menu.note?.round() ?? 0) ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: screenWidth * 0.05, // UI Design: Taille adaptative
                  );
                }),
              ),
              SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Text(
                '${menu.note?.toStringAsFixed(1)} / 5.0',
                style: TextStyle(
                  fontSize: screenWidth * 0.04, // UI Design: Taille adaptative
                  fontWeight: FontWeight.w600,
                  color: CouleursApp.texteFonce,
                ),
                overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper: Construire une section d'information
  Widget _construireInfoSection(String titre, String contenu, IconData icone, Color couleur, BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icone, color: couleur, size: screenWidth * 0.04), // UI Design: Taille adaptative
            SizedBox(width: screenWidth * 0.015), // UI Design: Espacement adaptatif
            Text(
              titre,
              style: TextStyle(
                fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                fontWeight: FontWeight.w600,
                color: CouleursApp.texteFonce,
              ),
              overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
              maxLines: 1,
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.008), // UI Design: Espacement adaptatif
        Text(
          contenu,
          style: TextStyle(
            fontSize: screenWidth * 0.033, // UI Design: Taille adaptative
            color: CouleursApp.texteFonce.withValues(alpha: 0.8),
            height: 1.3,
          ),
          overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
          maxLines: 4,
        ),
      ],
    );
  }

  // Méthodes utilitaires
  String _obtenirNomCategorie(String categorie) {
    switch (categorie) {
      case 'menu_jour':
        return 'Menu du Jour';
      case 'plat':
        return 'Plat Principal';
      case 'snack':
        return 'Collation';
      case 'dessert':
        return 'Dessert';
      case 'boisson':
        return 'Boisson';
      default:
        return 'Menu';
    }
  }

  Color _obtenirCouleurCategorie(String categorie) {
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

  IconData _obtenirIconeCategorie(String categorie) {
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

  // Actions
  void _ajouterAuxFavoris(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${menu.nom} ajouté aux favoris'),
        backgroundColor: _obtenirCouleurCategorie(menu.categorie),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
} 