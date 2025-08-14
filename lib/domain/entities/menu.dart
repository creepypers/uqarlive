// UI Design: Entité Menu pour la cantine universitaire UQAR
class Menu {
  final String id;
  final String nom;
  final String description;
  final double prix;
  final bool estDisponible;
  final List<String> ingredients;
  final String? allergenes;
  final String categorie; // "plat", "dessert", "boisson", "snack"
  final int? calories;
  final bool estVegetarien;
  final bool estVegan;
  final String? imageUrl;
  final DateTime dateAjout;
  final String? nutritionInfo;
  final double? note; // Note sur 5

  const Menu({
    required this.id,
    required this.nom,
    required this.description,
    required this.prix,
    required this.estDisponible,
    required this.ingredients,
    this.allergenes,
    required this.categorie,
    this.calories,
    this.estVegetarien = false,
    this.estVegan = false,
    this.imageUrl,
    required this.dateAjout,
    this.nutritionInfo,
    this.note,
  });

  // Getter pour le prix formaté
  String get prixFormatte => '${prix.toStringAsFixed(2)}€';

  // Getter pour vérifier si c'est un menu du jour
  bool get estMenuDuJour => categorie == 'menu_jour';

  // Getter pour les badges (végétarien, vegan, etc.)
  List<String> get badges {
    List<String> result = [];
    if (estVegan) {
      result.add('VEGAN');
    } else if (estVegetarien) {
      result.add('VÉGÉ');
    }
    if (!estDisponible) result.add('ÉPUISÉ');
    if (note != null && note! >= 4.5) result.add('POPULAIRE');
    return result;
  }

  // Méthode pour copier avec modifications
  Menu copyWith({
    String? id,
    String? nom,
    String? description,
    double? prix,
    bool? estDisponible,
    List<String>? ingredients,
    String? allergenes,
    String? categorie,
    int? calories,
    bool? estVegetarien,
    bool? estVegan,
    String? imageUrl,
    DateTime? dateAjout,
    String? nutritionInfo,
    double? note,
  }) {
    return Menu(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      prix: prix ?? this.prix,
      estDisponible: estDisponible ?? this.estDisponible,
      ingredients: ingredients ?? this.ingredients,
      allergenes: allergenes ?? this.allergenes,
      categorie: categorie ?? this.categorie,
      calories: calories ?? this.calories,
      estVegetarien: estVegetarien ?? this.estVegetarien,
      estVegan: estVegan ?? this.estVegan,
      imageUrl: imageUrl ?? this.imageUrl,
      dateAjout: dateAjout ?? this.dateAjout,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      note: note ?? this.note,
    );
  }

  @override
  String toString() {
    return 'Menu(id: $id, nom: $nom, prix: $prix, categorie: $categorie, estDisponible: $estDisponible)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Menu && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 