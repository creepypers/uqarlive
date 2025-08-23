import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/menu_categories.dart';
import '../../../domain/entities/menu.dart';
import '../../../presentation/widgets/navbar_widget.dart';
import '../../../presentation/widgets/widget_barre_app_personnalisee.dart';
import '../../../presentation/services/navigation_service.dart';
class DetailsMenuEcran extends StatelessWidget {
  final Menu menu;
  const DetailsMenuEcran({
    super.key,
    required this.menu,
  });
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      resizeToAvoidBottomInset: true,
      appBar: WidgetBarreAppPersonnalisee(
        titre: menu.nom,
        sousTitre: MenuCategories.obtenirNomCategorie(menu.categorie),
        afficherProfil: false,
        widgetFin: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: CouleursApp.blanc, size: screenWidth * 0.06),
              onPressed: () => Navigator.pop(context),
            ),
            IconButton(
              icon: Icon(Icons.favorite_border, color: CouleursApp.blanc, size: screenWidth * 0.06),
              onPressed: () => _ajouterAuxFavoris(context),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: viewInsets.bottom + padding.bottom + screenHeight * 0.025,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section En-tête avec image et prix
              _construireEnTete(context),
              SizedBox(height: screenHeight * 0.02), 
              // Section Informations nutritionnelles
              _construireSectionNutrition(context),
              SizedBox(height: screenHeight * 0.03), 
              // Section Ingrédients et allergènes
              _construireSectionIngredients(context),
              SizedBox(height: screenHeight * 0.03), 
              // Section Note et avis si disponible
              if (menu.note != null) ...[
                _construireSectionNote(context),
                SizedBox(height: screenHeight * 0.03), 
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
  Widget _construireEnTete(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04), 
      padding: EdgeInsets.all(screenWidth * 0.05), 
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MenuCategories.obtenirCouleurCategorie(menu.categorie),
            MenuCategories.obtenirCouleurCategorie(menu.categorie).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MenuCategories.obtenirCouleurCategorie(menu.categorie).withValues(alpha: 0.3),
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
                padding: EdgeInsets.all(screenWidth * 0.04), 
                decoration: BoxDecoration(
                  color: CouleursApp.blanc.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  MenuCategories.obtenirIconeCategorie(menu.categorie),
                  size: screenWidth * 0.1, 
                  color: CouleursApp.blanc,
                ),
              ),
              SizedBox(width: screenWidth * 0.04), 
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.nom,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05, 
                        fontWeight: FontWeight.bold,
                        color: CouleursApp.blanc,
                      ),
                      overflow: TextOverflow.ellipsis, 
                      maxLines: 2,
                    ),
                    SizedBox(height: screenHeight * 0.005), 
                    Text(
                      menu.description,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035, 
                        color: CouleursApp.blanc.withValues(alpha: 0.9),
                      ),
                      overflow: TextOverflow.ellipsis, 
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              // Prix
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03, 
                  vertical: screenWidth * 0.02,
                ),
                decoration: BoxDecoration(
                  color: CouleursApp.blanc,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${menu.prix.toStringAsFixed(2)} \$',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045, 
                    fontWeight: FontWeight.bold,
                    color: MenuCategories.obtenirCouleurCategorie(menu.categorie),
                  ),
                  overflow: TextOverflow.ellipsis, 
                  maxLines: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02), 
          // Badges
          Row(
            children: [
              ...menu.badges.map((badge) => Container(
                margin: EdgeInsets.only(right: screenWidth * 0.02), 
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02, 
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
                    fontSize: screenWidth * 0.025, 
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis, 
                  maxLines: 1,
                ),
              )),
              if (!menu.estDisponible)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02, 
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
                      fontSize: screenWidth * 0.025, 
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis, 
                    maxLines: 1,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _construireSectionNutrition(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec titre et icône
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.025),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.monitor_heart,
                  color: Colors.orange,
                  size: screenWidth * 0.06,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations nutritionnelles',
                      style: StylesTexteApp.titre.copyWith(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.w700,
                        color: CouleursApp.texteFonce,
                      ),
                    ),
                    Text(
                      'Données nutritionnelles de ${menu.nom}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.025),
          // Grille de statistiques modernes
          Row(
            children: [
              Expanded(
                child: _construireCarteStatistiqueMenu(
                  menu.calories != null ? '${menu.calories}' : 'N/A',
                  'Calories\n(kcal)',
                  Icons.local_fire_department,
                  Colors.orange,
                  'Énergie',
                  context,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: _construireCarteStatistiqueMenu(
                  menu.estVegetarien ? 'Oui' : 'Non',
                  'Végétarien',
                  Icons.eco,
                  Colors.green,
                  'Option végé',
                  context,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            children: [
              Expanded(
                child: _construireCarteStatistiqueMenu(
                  menu.estVegan ? 'Oui' : 'Non',
                  'Vegan',
                  Icons.nature,
                  Colors.green.shade700,
                  '100% végé',
                  context,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: _construireCarteStatistiqueMenu(
                  '${menu.prix.toStringAsFixed(2)} \$',
                  'Prix',
                  Icons.attach_money,
                  MenuCategories.obtenirCouleurCategorie(menu.categorie),
                  'Coût',
                  context,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _construireCarteStatistiqueMenu(String valeur, String label, IconData icone, Color couleur, String description, BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            couleur.withValues(alpha: 0.15),
            couleur.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: couleur.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: couleur.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.025),
                decoration: BoxDecoration(
                  color: couleur.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icone,
                  color: couleur,
                  size: screenWidth * 0.055,
                ),
              ),
              SizedBox(width: screenWidth * 0.025),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: screenWidth * 0.038,
                    color: CouleursApp.texteFonce.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.025),
          Text(
            valeur,
            style: TextStyle(
              fontSize: screenWidth * 0.065,
              fontWeight: FontWeight.bold,
              color: couleur,
            ),
          ),
          SizedBox(height: screenWidth * 0.015),
          Text(
            description,
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: CouleursApp.texteFonce.withValues(alpha: 0.6),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  Widget _construireSectionIngredients(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), 
      padding: EdgeInsets.all(screenWidth * 0.05), 
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
                color: MenuCategories.obtenirCouleurCategorie(menu.categorie),
                size: screenWidth * 0.06, 
              ),
              SizedBox(width: screenWidth * 0.02), 
              Text(
                'Ingrédients & Allergènes',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, 
                ),
                overflow: TextOverflow.ellipsis, 
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02), 
          // Ingrédients
          _construireInfoSection(
            'Ingrédients',
            menu.ingredients.join(', '),
            Icons.grain,
            Colors.brown,
            context,
          ),
          if (menu.allergenes != null) ...[
            SizedBox(height: screenHeight * 0.02), 
            _construireInfoSection(
              'Allergènes',
              menu.allergenes!,
              Icons.warning,
              Colors.red,
              context,
            ),
          ],
          if (menu.nutritionInfo != null) ...[
            SizedBox(height: screenHeight * 0.02), 
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
  Widget _construireSectionNote(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), 
      padding: EdgeInsets.all(screenWidth * 0.05), 
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
                size: screenWidth * 0.06, 
              ),
              SizedBox(width: screenWidth * 0.02), 
              Text(
                'Évaluation',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, 
                ),
                overflow: TextOverflow.ellipsis, 
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02), 
          Row(
            children: [
              // Note
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < (menu.note?.round() ?? 0) ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                      size: screenWidth * 0.05, 
                  );
                }),
              ),
              SizedBox(width: screenWidth * 0.02), 
              Text(
                '${menu.note?.toStringAsFixed(1)} / 5.0',
                style: TextStyle(
                  fontSize: screenWidth * 0.04, 
                  fontWeight: FontWeight.w600,
                  color: CouleursApp.texteFonce,
                ),
                overflow: TextOverflow.ellipsis, 
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
            Icon(icone, color: couleur, size: screenWidth * 0.04), 
            SizedBox(width: screenWidth * 0.015), 
            Text(
              titre,
              style: TextStyle(
                fontSize: screenWidth * 0.035, 
                fontWeight: FontWeight.w600,
                color: CouleursApp.texteFonce,
              ),
              overflow: TextOverflow.ellipsis, 
              maxLines: 1,
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.008), 
        Text(
          contenu,
          style: TextStyle(
            fontSize: screenWidth * 0.033, 
            color: CouleursApp.texteFonce.withValues(alpha: 0.8),
            height: 1.3,
          ),
            overflow: TextOverflow.ellipsis, 
          maxLines: 4,
        ),
      ],
    );
  }
  // Actions
  void _ajouterAuxFavoris(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${menu.nom} ajouté aux favoris'),
        backgroundColor: MenuCategories.obtenirCouleurCategorie(menu.categorie),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
} 