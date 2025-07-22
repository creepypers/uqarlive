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
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: WidgetBarreAppPersonnalisee(
        titre: menu.nom,
        sousTitre: _obtenirNomCategorie(menu.categorie),
        afficherProfil: false,
        widgetFin: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: CouleursApp.blanc),
              onPressed: () => Navigator.pop(context),
            ),
            IconButton(
              icon: Icon(Icons.favorite_border, color: CouleursApp.blanc),
              onPressed: () => _ajouterAuxFavoris(context),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section En-tête avec image et prix
              _construireEnTete(),
              const SizedBox(height: 16),
              
              // Section Informations nutritionnelles
              _construireSectionNutrition(),
              const SizedBox(height: 24),
              
              // Section Ingrédients et allergènes
              _construireSectionIngredients(),
              const SizedBox(height: 24),
              
              // Section Note et avis si disponible
              if (menu.note != null) ...[
                _construireSectionNote(),
                const SizedBox(height: 24),
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
  Widget _construireEnTete() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CouleursApp.blanc.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _obtenirIconeCategorie(menu.categorie),
                  size: 40,
                  color: CouleursApp.blanc,
                ),
              ),
              const SizedBox(width: 16),
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.nom,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CouleursApp.blanc,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      menu.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: CouleursApp.blanc.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              // Prix
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: CouleursApp.blanc,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${menu.prix.toStringAsFixed(2)} \$',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _obtenirCouleurCategorie(menu.categorie),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Badges
          Row(
            children: [
              ...menu.badges.map((badge) => Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CouleursApp.blanc.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: CouleursApp.blanc,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
              if (!menu.estDisponible)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ÉPUISÉ',
                    style: TextStyle(
                      color: CouleursApp.blanc,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
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
  Widget _construireSectionIngredients() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Ingrédients & Allergènes',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Ingrédients
          _construireInfoSection(
            'Ingrédients',
            menu.ingredients.join(', '),
            Icons.grain,
            Colors.brown,
          ),
          
          if (menu.allergenes != null) ...[
            const SizedBox(height: 16),
            _construireInfoSection(
              'Allergènes',
              menu.allergenes!,
              Icons.warning,
              Colors.red,
            ),
          ],
          
          if (menu.nutritionInfo != null) ...[
            const SizedBox(height: 16),
            _construireInfoSection(
              'Informations nutritionnelles',
              menu.nutritionInfo!,
              Icons.info,
              CouleursApp.accent,
            ),
          ],
        ],
      ),
    );
  }

  // UI Design: Section note et avis
  Widget _construireSectionNote() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Évaluation',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Note
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < (menu.note?.round() ?? 0) ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 20,
                  );
                }),
              ),
              const SizedBox(width: 8),
              Text(
                '${menu.note?.toStringAsFixed(1)} / 5.0',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CouleursApp.texteFonce,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper: Construire une section d'information
  Widget _construireInfoSection(String titre, String contenu, IconData icone, Color couleur) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icone, color: couleur, size: 16),
            const SizedBox(width: 6),
            Text(
              titre,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: CouleursApp.texteFonce,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          contenu,
          style: TextStyle(
            fontSize: 13,
            color: CouleursApp.texteFonce.withValues(alpha: 0.8),
            height: 1.3,
          ),
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