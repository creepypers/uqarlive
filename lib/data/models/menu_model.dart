import '../../domain/entities/menu.dart';
class MenuModel extends Menu {
  const MenuModel({
    required super.id,
    required super.nom,
    required super.description,
    required super.prix,
    required super.estDisponible,
    required super.ingredients,
    super.allergenes,
    required super.categorie,
    super.calories,
    super.estVegetarien = false,
    super.estVegan = false,
    super.imageUrl,
    required super.dateAjout,
    super.nutritionInfo,
    super.note,
  });
  /// Créer un MenuModel à partir d'un Map
  factory MenuModel.fromMap(Map<String, dynamic> map) {
    return MenuModel(
      id: map['id'] as String,
      nom: map['nom'] as String,
      description: map['description'] as String,
      prix: (map['prix'] as num).toDouble(),
      estDisponible: map['estDisponible'] as bool,
      ingredients: List<String>.from(map['ingredients'] as List),
      allergenes: map['allergenes'] as String?,
      categorie: map['categorie'] as String,
      calories: map['calories'] as int?,
      estVegetarien: map['estVegetarien'] as bool? ?? false,
      estVegan: map['estVegan'] as bool? ?? false,
      imageUrl: map['imageUrl'] as String?,
      dateAjout: DateTime.parse(map['dateAjout'] as String),
      nutritionInfo: map['nutritionInfo'] as String?,
      note: (map['note'] as num?)?.toDouble(),
    );
  }
  /// Convertir le MenuModel en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'prix': prix,
      'estDisponible': estDisponible,
      'ingredients': ingredients,
      'allergenes': allergenes,
      'categorie': categorie,
      'calories': calories,
      'estVegetarien': estVegetarien,
      'estVegan': estVegan,
      'imageUrl': imageUrl,
      'dateAjout': dateAjout.toIso8601String(),
      'nutritionInfo': nutritionInfo,
      'note': note,
    };
  }
  /// Créer un MenuModel à partir d'une entité Menu
  factory MenuModel.fromEntity(Menu menu) {
    return MenuModel(
      id: menu.id,
      nom: menu.nom,
      description: menu.description,
      prix: menu.prix,
      estDisponible: menu.estDisponible,
      ingredients: menu.ingredients,
      allergenes: menu.allergenes,
      categorie: menu.categorie,
      calories: menu.calories,
      estVegetarien: menu.estVegetarien,
      estVegan: menu.estVegan,
      imageUrl: menu.imageUrl,
      dateAjout: menu.dateAjout,
      nutritionInfo: menu.nutritionInfo,
      note: menu.note,
    );
  }
} 