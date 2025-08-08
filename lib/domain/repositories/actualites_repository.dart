// Clean Architecture: Interface du repository pour les actualités
import '../entities/actualite.dart';

abstract class ActualitesRepository {
  /// Récupère toutes les actualités
  Future<List<Actualite>> obtenirActualites();
  
  /// Récupère les actualités d'une association spécifique
  Future<List<Actualite>> obtenirActualitesParAssociation(String associationId);
  
  /// Récupère une actualité par son ID
  Future<Actualite?> obtenirActualiteParId(String id);
  
  /// Ajoute une nouvelle actualité
  Future<Actualite> ajouterActualite(Actualite actualite);
  
  /// Met à jour une actualité existante
  Future<Actualite> mettreAJourActualite(Actualite actualite);
  
  /// Supprime une actualité
  Future<bool> supprimerActualite(String id);
  
  /// Récupère les actualités épinglées
  Future<List<Actualite>> obtenirActualitesEpinglees();
  
  /// Récupère les actualités par priorité
  Future<List<Actualite>> obtenirActualitesParPriorite(String priorite);
} 