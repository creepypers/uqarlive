import '../entities/actualite.dart';

// UI Design: Interface du repository pour les actualités d'associations
abstract class ActualitesRepository {
  
  // UI Design: Récupérer toutes les actualités
  Future<List<Actualite>> obtenirToutesLesActualites();
  
  // UI Design: Récupérer les actualités épinglées (prioritaires)
  Future<List<Actualite>> obtenirActualitesEpinglees();
  
  // UI Design: Récupérer les actualités d'une association spécifique
  Future<List<Actualite>> obtenirActualitesParAssociation(String nomAssociation);
  
  // UI Design: Rechercher des actualités par terme
  Future<List<Actualite>> rechercherActualites(String terme);
  
  // UI Design: Récupérer une actualité par son ID
  Future<Actualite?> obtenirActualiteParId(String id);
  
  // UI Design: Liker une actualité
  Future<bool> likerActualite(String id);
  
  // UI Design: Marquer une actualité comme vue
  Future<bool> marquerCommeVue(String id);
} 