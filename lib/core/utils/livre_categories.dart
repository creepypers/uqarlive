// UI Design: Utilitaires pour les catégories de livres - Clean Architecture
class LivreCategories {
  // Matières disponibles pour les livres
  static const List<String> matieres = [
    'Matières',
    'Mathématiques', 
    'Physique', 
    'Chimie', 
    'Biologie', 
    'Informatique', 
    'Génie', 
    'Économie', 
    'Droit', 
    'Lettres', 
    'Histoire'
  ];

  // États possibles pour les livres
  static const List<String> etatsLivre = [
    'États', 
    'Excellent', 
    'Très bon', 
    'Bon', 
    'Acceptable'
  ];

  // Années d'étude disponibles
  static const List<String> anneesEtude = [
    'Années', 
    '1ère année', 
    '2ème année', 
    '3ème année', 
    'Maîtrise', 
    'Doctorat'
  ];

  // Vérifier si une matière est valide
  static bool estMatiereValide(String matiere) {
    return matieres.contains(matiere);
  }

  // Vérifier si un état est valide
  static bool estEtatValide(String etat) {
    return etatsLivre.contains(etat);
  }

  // Vérifier si une année d'étude est valide
  static bool estAnneeEtudeValide(String annee) {
    return anneesEtude.contains(annee);
  }

  // Obtenir toutes les matières (sans 'Matières')
  static List<String> get matieresValides => 
      matieres.where((matiere) => matiere != 'Matières').toList();

  // Obtenir tous les états (sans 'États')
  static List<String> get etatsValides => 
      etatsLivre.where((etat) => etat != 'États').toList();

  // Obtenir toutes les années (sans 'Années')
  static List<String> get anneesValides => 
      anneesEtude.where((annee) => annee != 'Années').toList();

  // Valeurs par défaut
  static const String matiereDefaut = 'Matières';
  static const String etatDefaut = 'États';
  static const String anneeDefaut = 'Années';
}
