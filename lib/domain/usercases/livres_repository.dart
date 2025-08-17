import '../entities/livre.dart';

// UI Design: Repository abstrait pour les livres - couche domain
abstract class LivresRepository {
  
  // Obtenir tous les livres disponibles
  Future<List<Livre>> obtenirTousLesLivres();
  
  // Obtenir un livre par son ID
  Future<Livre?> obtenirLivreParId(String id);
  
  // Filtrer les livres par matière
  Future<List<Livre>> obtenirLivresParMatiere(String matiere);
  
  // Filtrer les livres par état
  Future<List<Livre>> obtenirLivresParEtat(String etat);
  
  // Filtrer les livres par année d'étude
  Future<List<Livre>> obtenirLivresParAnnee(String annee);
  
  // Rechercher des livres par titre, auteur, matière ou cours
  Future<List<Livre>> rechercherLivres(String recherche);
  
  // Filtrer les livres avec plusieurs critères
  Future<List<Livre>> filtrerLivres({
    String? matiere,
    String? etat,
    String? annee,
    String? recherche,
  });
  
  // Ajouter un nouveau livre
  Future<bool> ajouterLivre(Livre livre);
  
  // Modifier un livre existant
  Future<bool> modifierLivre(Livre livre);
  
  // Supprimer un livre
  Future<bool> supprimerLivre(String id);
  
  // Marquer un livre comme non disponible (échangé)
  Future<bool> marquerLivreEchange(String id);
  
  // Marquer un livre comme disponible à nouveau
  Future<bool> marquerLivreDisponible(String id);
  
  // Obtenir les livres d'un propriétaire spécifique
  Future<List<Livre>> obtenirLivresParProprietaire(String proprietaire);
  
  // Obtenir les livres disponibles uniquement
  Future<List<Livre>> obtenirLivresDisponibles();
  
  // Obtenir les livres par cours universitaire
  Future<List<Livre>> obtenirLivresParCours(String cours);
} 