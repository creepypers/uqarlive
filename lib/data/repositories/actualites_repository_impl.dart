import '../../domain/entities/actualite.dart';
import '../../domain/repositories/actualites_repository.dart';
import '../datasources/actualites_datasource_local.dart';

// UI Design: Implémentation du repository des actualités avec source de données locale
class ActualitesRepositoryImpl implements ActualitesRepository {
  final ActualitesDatasourceLocal _datasourceLocal;

  ActualitesRepositoryImpl(this._datasourceLocal);

  @override
  Future<List<Actualite>> obtenirToutesLesActualites() async {
    try {
      final models = await _datasourceLocal.obtenirToutesLesActualites();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des actualités: $e');
    }
  }

  @override
  Future<List<Actualite>> obtenirActualitesEpinglees() async {
    try {
      final models = await _datasourceLocal.obtenirActualitesEpinglees();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des actualités épinglées: $e');
    }
  }

  @override
  Future<List<Actualite>> obtenirActualitesParAssociation(String nomAssociation) async {
    try {
      final models = await _datasourceLocal.obtenirActualitesParAssociation(nomAssociation);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des actualités de l\'association: $e');
    }
  }

  @override
  Future<List<Actualite>> rechercherActualites(String terme) async {
    try {
      final models = await _datasourceLocal.rechercherActualites(terme);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche d\'actualités: $e');
    }
  }

  @override
  Future<Actualite?> obtenirActualiteParId(String id) async {
    try {
      final model = await _datasourceLocal.obtenirActualiteParId(id);
      return model?.toEntity();
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'actualité: $e');
    }
  }

  @override
  Future<bool> likerActualite(String id) async {
    try {
      return await _datasourceLocal.likerActualite(id);
    } catch (e) {
      throw Exception('Erreur lors du like de l\'actualité: $e');
    }
  }

  @override
  Future<bool> marquerCommeVue(String id) async {
    try {
      return await _datasourceLocal.marquerCommeVue(id);
    } catch (e) {
      throw Exception('Erreur lors du marquage comme vue: $e');
    }
  }

  @override
  Future<List<Actualite>> obtenirActualites() async {
    return await obtenirToutesLesActualites();
  }

  @override
  Future<Actualite> ajouterActualite(Actualite actualite) async {
    // TODO: Implémenter dans le datasource
    await Future.delayed(const Duration(milliseconds: 500)); // Simulation
    return actualite;
  }

  @override
  Future<Actualite> mettreAJourActualite(Actualite actualite) async {
    // TODO: Implémenter dans le datasource
    await Future.delayed(const Duration(milliseconds: 500)); // Simulation
    return actualite;
  }

  @override
  Future<bool> supprimerActualite(String id) async {
    // TODO: Implémenter dans le datasource
    await Future.delayed(const Duration(milliseconds: 500)); // Simulation
    return true;
  }

  @override
  Future<List<Actualite>> obtenirActualitesParPriorite(String priorite) async {
    // TODO: Implémenter dans le datasource
    await Future.delayed(const Duration(milliseconds: 500)); // Simulation
    return [];
  }
} 