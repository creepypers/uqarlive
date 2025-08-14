// Clean Architecture: Service pour la gestion des actualités
import '../../domain/entities/actualite.dart';
import '../../domain/repositories/actualites_repository.dart';
import '../../core/di/service_locator.dart';

class ActualitesService {
  late final ActualitesRepository _actualitesRepository;

  ActualitesService() {
    _actualitesRepository = ServiceLocator.obtenirService<ActualitesRepository>();
  }

  /// Récupère toutes les actualités
  Future<List<Actualite>> obtenirActualites() async {
    try {
      return await _actualitesRepository.obtenirActualites();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des actualités: $e');
    }
  }

  /// Récupère les actualités d'une association spécifique
  Future<List<Actualite>> obtenirActualitesParAssociation(String associationId) async {
    try {
      return await _actualitesRepository.obtenirActualitesParAssociation(associationId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des actualités de l\'association: $e');
    }
  }

  /// Récupère une actualité par son ID
  Future<Actualite?> obtenirActualiteParId(String id) async {
    try {
      return await _actualitesRepository.obtenirActualiteParId(id);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'actualité: $e');
    }
  }

  /// Ajoute une nouvelle actualité
  Future<Actualite> ajouterActualite(Actualite actualite) async {
    try {
      // Validation métier
      if (actualite.description.trim().isEmpty) {
        throw Exception('La description de l\'actualité ne peut pas être vide');
      }

      if (actualite.associationId.trim().isEmpty) {
        throw Exception('L\'ID de l\'association est requis');
      }

      return await _actualitesRepository.ajouterActualite(actualite);
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de l\'actualité: $e');
    }
  }

  /// Met à jour une actualité existante
  Future<bool> mettreAJourActualite(Actualite actualite) async {
    try {
      // Validation métier
      if (actualite.description.trim().isEmpty) {
        throw Exception('La description de l\'actualité ne peut pas être vide');
      }

      return await _actualitesRepository.mettreAJourActualite(actualite);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'actualité: $e');
    }
  }

  /// Supprime une actualité
  Future<bool> supprimerActualite(String id) async {
    try {
      return await _actualitesRepository.supprimerActualite(id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'actualité: $e');
    }
  }

  /// Récupère les actualités épinglées
  Future<List<Actualite>> obtenirActualitesEpinglees() async {
    try {
      return await _actualitesRepository.obtenirActualitesEpinglees();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des actualités épinglées: $e');
    }
  }

  /// Récupère les actualités par priorité
  Future<List<Actualite>> obtenirActualitesParPriorite(String priorite) async {
    try {
      return await _actualitesRepository.obtenirActualitesParPriorite(priorite);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des actualités par priorité: $e');
    }
  }

  /// Crée une nouvelle actualité avec les paramètres fournis
  Future<Actualite> creerActualite({
    required String titre,
    required String description,
    required String associationId,
    required String auteur,
    String priorite = 'normale',
    bool estEpinglee = false,
  }) async {
    final actualite = Actualite(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID temporaire
      titre: titre,
      description: description,
      contenu: description, // Utilise la description comme contenu
      associationId: associationId,
      auteur: auteur,
      datePublication: DateTime.now(),
      priorite: priorite,
      estEpinglee: estEpinglee,
      nombreVues: 0,
      nombreLikes: 0,
    );

    return await ajouterActualite(actualite);
  }
}
