import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/menu.dart';
import '../../../presentation/widgets/widget_barre_app_navigation_admin.dart';

// UI Design: Écran d'ajout/modification de menu pour la cantine
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
  
  // Contrôleurs pour les champs de texte
  final _nomMenuController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _allergenesController = TextEditingController();
  final _nutritionInfoController = TextEditingController();
  
  String _categorieSelectionnee = 'plat_principal';
  List<String> _ingredients = [];
  bool _estDisponible = true;
  bool _estVegetarien = false;
  bool _estVegan = false;
  bool _isLoading = false;

  // Liste des catégories disponibles
  final List<Map<String, String>> _categories = const [
    {'value': 'menu_jour', 'label': 'Menu du jour'},
    {'value': 'entree', 'label': 'Entrée'},
    {'value': 'plat_principal', 'label': 'Plat principal'},
    {'value': 'accompagnement', 'label': 'Accompagnement'},
    {'value': 'dessert', 'label': 'Dessert'},
    {'value': 'boisson', 'label': 'Boisson'},
    {'value': 'snack', 'label': 'Snack'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.menuAModifier != null) {
      // Vérifier si la catégorie existe dans la liste des catégories disponibles
      final categorieExiste = _categories.any((cat) => cat['value'] == widget.menuAModifier!.categorie);
      
      // Pré-remplir les champs si on modifie un menu existant
      _nomMenuController.text = widget.menuAModifier!.nom;
      _descriptionController.text = widget.menuAModifier!.description;
      _prixController.text = widget.menuAModifier!.prix.toString();
      _caloriesController.text = widget.menuAModifier!.calories?.toString() ?? '';
      _allergenesController.text = widget.menuAModifier!.allergenes ?? '';
      _nutritionInfoController.text = widget.menuAModifier!.nutritionInfo ?? '';
      _categorieSelectionnee = categorieExiste ? widget.menuAModifier!.categorie : 'plat_principal';
      _ingredients = List.from(widget.menuAModifier!.ingredients);
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
    // UI Design: Obtenir les dimensions de l'écran pour l'adaptabilité
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;
    
    final estModification = widget.menuAModifier != null;
    
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      resizeToAvoidBottomInset: true, // UI Design: Éviter les débordements avec le clavier
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
            left: screenWidth * 0.04, // UI Design: Padding adaptatif
            right: screenWidth * 0.04,
            top: screenHeight * 0.02,
            bottom: viewInsets.bottom + padding.bottom + screenHeight * 0.025, // UI Design: Padding adaptatif pour éviter les débordements
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

  // UI Design: Section d'information
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

  // UI Design: Section informations du menu
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
            items: _categories.map((categorie) => DropdownMenuItem(
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

  // UI Design: Section options et disponibilité
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

  // UI Design: Boutons d'action
  Widget _construireBoutonsAction() {
    return Column(
      children: [
        // Bouton ajouter
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _ajouterMenu,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
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

      // Simuler l'ajout
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // Afficher confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Menu "${_nomMenuController.text}" ajouté avec succès !'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );

      // Retourner à l'écran précédent
      Navigator.pop(context);
    }
  }
} 