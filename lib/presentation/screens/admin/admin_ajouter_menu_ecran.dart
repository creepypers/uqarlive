import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/menu_categories.dart';
import '../../../domain/entities/menu.dart';
import '../../../domain/usercases/menus_repository.dart';
import '../../../core/di/service_locator.dart';
import '../../../presentation/widgets/widget_barre_app_navigation_admin.dart';


class AdminAjouterMenuEcran extends StatefulWidget {
  final Menu? menuAModifier;
  
  const AdminAjouterMenuEcran({
    super.key,
    this.menuAModifier,
  });

  @override
  State<AdminAjouterMenuEcran> createState() => _AdminAjouterMenuEcranState();
}

class _AdminAjouterMenuEcranState extends State<AdminAjouterMenuEcran> {
  final _formKey = GlobalKey<FormState>();
  late final MenusRepository _menusRepository;
  
  // Contrôleurs pour les champs de texte
  final _nomMenuController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _allergenesController = TextEditingController();
  final _nutritionInfoController = TextEditingController();
  
  String _categorieSelectionnee = 'plat_principal';

  bool _estDisponible = true;
  bool _estVegetarien = false;
  bool _estVegan = false;
  bool _isLoading = false;

  // Catégorie sélectionnée (utilise l'utilitaire MenuCategories)

  @override
  void initState() {
    super.initState();
    _menusRepository = ServiceLocator.obtenirService<MenusRepository>();
    if (widget.menuAModifier != null) {
      // Vérifier si la catégorie existe dans les catégories disponibles
      final categorieExiste = MenuCategories.estCategorieValide(widget.menuAModifier!.categorie);
      
      // Pré-remplir les champs si on modifie un menu existant
      _nomMenuController.text = widget.menuAModifier!.nom;
      _descriptionController.text = widget.menuAModifier!.description;
      _prixController.text = widget.menuAModifier!.prix.toString();
      _caloriesController.text = widget.menuAModifier!.calories?.toString() ?? '';
      _allergenesController.text = widget.menuAModifier!.allergenes ?? '';
      _nutritionInfoController.text = widget.menuAModifier!.nutritionInfo ?? '';
      _categorieSelectionnee = categorieExiste ? widget.menuAModifier!.categorie : MenuCategories.categorieDefaut;

      _estDisponible = widget.menuAModifier!.estDisponible;
      _estVegetarien = widget.menuAModifier!.estVegetarien;
      _estVegan = widget.menuAModifier!.estVegan;
    }
  }

  @override
  void dispose() {
    _nomMenuController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    _caloriesController.dispose();
    _allergenesController.dispose();
    _nutritionInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;
    
    final estModification = widget.menuAModifier != null;
    
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      resizeToAvoidBottomInset: true, 
      appBar: WidgetBarreAppNavigationAdmin(
        titre: estModification ? 'Modifier le Menu' : 'Ajouter un Menu',
        sousTitre: estModification 
          ? 'Modification de "${widget.menuAModifier!.nom}"'
          : 'Nouveau menu pour la cantine',
        sectionActive: 'cantine',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: screenWidth * 0.04, 
            right: screenWidth * 0.04,
            top: screenHeight * 0.02,
            bottom: viewInsets.bottom + padding.bottom + screenHeight * 0.025, 
          ),
          child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section d'information
                  _construireSectionInformation(),
                  const SizedBox(height: 24),
                  
                  // Informations du menu
                  _construireSectionInformationsMenu(),
                  const SizedBox(height: 24),
                  
                  // Options et disponibilité
                  _construireSectionOptions(),
                  const SizedBox(height: 32),
                  
                  // Boutons d'action
                  _construireBoutonsAction(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
    );
  }

  
  Widget _construireSectionInformation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.add_circle,
              color: Colors.green,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nouveau Menu',
                  style: StylesTexteApp.moyenTitre.copyWith(color: Colors.green),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ajoutez un nouveau menu à la carte de la cantine',
                  style: StylesTexteApp.corpsGris,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _construireSectionInformationsMenu() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(24),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CouleursApp.principal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: CouleursApp.principal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Informations du menu',
                style: StylesTexteApp.moyenTitre,
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Nom du menu
          _construireChampTexte(
            controller: _nomMenuController,
            label: 'Nom du menu *',
            icone: Icons.restaurant_menu,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le nom du menu est requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Description
          _construireChampTexte(
            controller: _descriptionController,
            label: 'Description',
            icone: Icons.description,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          
          // Catégorie
          DropdownButtonFormField<String>(
            value: _categorieSelectionnee,
            decoration: InputDecoration(
              labelText: 'Catégorie *',
              prefixIcon: const Icon(Icons.category, color: CouleursApp.principal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: CouleursApp.principal.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: CouleursApp.principal.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: CouleursApp.principal, width: 2),
              ),
              filled: true,
              fillColor: CouleursApp.blanc,
            ),
            items: MenuCategories.categories.map((categorie) => DropdownMenuItem(
              value: categorie['value'],
              child: Text(categorie['label']!),
            )).toList(),
            onChanged: (valeur) {
              if (valeur != null) {
                setState(() => _categorieSelectionnee = valeur);
              }
            },
            validator: (valeur) {
              if (valeur == null || valeur.isEmpty) {
                return 'Veuillez sélectionner une catégorie';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Prix et calories
          Row(
            children: [
              Expanded(
                child: _construireChampTexte(
                  controller: _prixController,
                  label: 'Prix (CAD) *',
                  icone: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le prix est requis';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Prix invalide';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _construireChampTexte(
                  controller: _caloriesController,
                  label: 'Calories',
                  icone: Icons.local_fire_department,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  
  Widget _construireSectionOptions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.accent.withValues(alpha: 0.08),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CouleursApp.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings,
                  color: CouleursApp.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Options et disponibilité',
                style: StylesTexteApp.moyenTitre,
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Disponibilité
          SwitchListTile(
            title: const Text('Menu disponible'),
            subtitle: const Text('Le menu peut être commandé'),
            value: _estDisponible,
            onChanged: (valeur) {
              setState(() => _estDisponible = valeur);
            },
            activeColor: Colors.green,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 20),
          
          // Options alimentaires
          const Text(
            'Options alimentaires',
            style: StylesTexteApp.petitTitre,
          ),
          const SizedBox(height: 12),
          
          SwitchListTile(
            title: const Text('Végétarien'),
            subtitle: const Text('Menu sans viande'),
            value: _estVegetarien,
            onChanged: (valeur) {
              setState(() => _estVegetarien = valeur);
            },
            activeColor: Colors.green,
            contentPadding: EdgeInsets.zero,
          ),
          
          SwitchListTile(
            title: const Text('Vegan'),
            subtitle: const Text('Sans produits animaux'),
            value: _estVegan,
            onChanged: (valeur) {
              setState(() => _estVegan = valeur);
            },
            activeColor: Colors.green,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  
  Widget _construireBoutonsAction() {
    return Column(
      children: [
        // Bouton ajouter
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _ajouterMenu,
            style: ElevatedButton.styleFrom(
              backgroundColor: CouleursApp.principal,
              foregroundColor: CouleursApp.blanc,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: CouleursApp.blanc,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_circle, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        widget.menuAModifier != null ? 'Modifier le menu' : 'Ajouter le menu',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Bouton ajouter au menu du jour (seulement si on modifie un menu existant)
        if (widget.menuAModifier != null) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _ajouterAuMenuDuJour,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: CouleursApp.blanc,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
              ),
              icon: const Icon(Icons.star, size: 20),
              label: const Text(
                'Ajouter au Menu du Jour',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Bouton annuler
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: CouleursApp.principal,
              side: const BorderSide(color: CouleursApp.principal, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel, size: 20),
                SizedBox(width: 8),
                Text(
                  'Annuler',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper: Construire un champ de texte
  Widget _construireChampTexte({
    required TextEditingController controller,
    required String label,
    required IconData icone,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icone, color: CouleursApp.principal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: CouleursApp.principal.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: CouleursApp.principal.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: CouleursApp.principal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: CouleursApp.blanc,
      ),
    );
  }

  // Actions
  void _ajouterMenu() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (widget.menuAModifier != null) {
          // Modification d'un menu existant
          final menuModifie = Menu(
            id: widget.menuAModifier!.id,
            nom: _nomMenuController.text,
            description: _descriptionController.text,
            prix: double.parse(_prixController.text),
            estDisponible: _estDisponible,
            ingredients: [], 
            allergenes: _allergenesController.text.isEmpty ? null : _allergenesController.text,
            categorie: _categorieSelectionnee,
            calories: _caloriesController.text.isEmpty ? null : int.parse(_caloriesController.text),
            estVegetarien: _estVegetarien,
            estVegan: _estVegan,
            imageUrl: widget.menuAModifier!.imageUrl,
            dateAjout: widget.menuAModifier!.dateAjout,
            nutritionInfo: _nutritionInfoController.text.isEmpty ? null : _nutritionInfoController.text,
            note: widget.menuAModifier!.note,
          );

          await _menusRepository.mettreAJourMenu(menuModifie);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Menu "${_nomMenuController.text}" modifié avec succès !'),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            );
          }
        } else {
          // Ajout d'un nouveau menu
          final nouveauMenu = Menu(
            id: 'menu_${DateTime.now().millisecondsSinceEpoch}',
            nom: _nomMenuController.text,
            description: _descriptionController.text,
            prix: double.parse(_prixController.text),
            estDisponible: _estDisponible,
            ingredients: [],  
            allergenes: _allergenesController.text.isEmpty ? null : _allergenesController.text,
            categorie: _categorieSelectionnee,
            calories: _caloriesController.text.isEmpty ? null : int.parse(_caloriesController.text),
            estVegetarien: _estVegetarien,
            estVegan: _estVegan,
            imageUrl: null,
            dateAjout: DateTime.now(),
            nutritionInfo: _nutritionInfoController.text.isEmpty ? null : _nutritionInfoController.text,
            note: 0.0,
          );

          await _menusRepository.ajouterMenu(nouveauMenu);

          if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Menu "${_nomMenuController.text}" ajouté avec succès !'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
          }
        }

        // Retourner à l'écran précédent avec un indicateur de succès
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Erreur: $e'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        }
      }
    }
  }

  
  void _ajouterAuMenuDuJour() async {
    if (widget.menuAModifier == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      
      await _menusRepository.definirMenuDuJour(widget.menuAModifier!.id);

      setState(() {
        _isLoading = false;
      });

      // Afficher confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.star, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Menu "${widget.menuAModifier!.nom}" ajouté au menu du jour !'),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }

      // Retourner à l'écran précédent avec un indicateur de succès
      if (mounted) {
        Navigator.pop(context, 'menu_du_jour_ajoute');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Afficher erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Erreur lors de l\'ajout au menu du jour: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    }
  }
} 
