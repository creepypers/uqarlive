import '../../domain/repositories/livres_repository.dart';
import '../../domain/repositories/associations_repository.dart';
import '../../domain/repositories/menus_repository.dart';
import '../../domain/repositories/salles_repository.dart';
import '../../domain/repositories/actualites_repository.dart';
import '../../data/repositories/livres_repository_impl.dart';
import '../../data/repositories/associations_repository_impl.dart';
import '../../data/repositories/menus_repository_impl.dart';
import '../../data/repositories/salles_repository_impl.dart';
import '../../data/repositories/actualites_repository_impl.dart';
import '../../domain/entities/utilisateur.dart';
import '../../domain/repositories/utilisateurs_repository.dart';
import '../../data/datasources/utilisateurs_datasource_local.dart';
import '../../data/repositories/utilisateurs_repository_impl.dart';
import '../../data/datasources/livres_datasource_local.dart';
import '../../data/datasources/associations_datasource_local.dart';
import '../../data/datasources/menus_datasource_local.dart';
import '../../data/datasources/salles_datasource_local.dart';
import '../../data/datasources/actualites_datasource_local.dart';

// UI Design: Service Locator pour injection de dépendances - Clean Architecture
class ServiceLocator {
  static final Map<Type, dynamic> _services = {};
  static bool _isConfigured = false;

  /// Configure toutes les dépendances de l'application
  static void configurerDependances() {
    if (_isConfigured) return;

    // Configuration des datasources (Data Layer)
    _services[LivresDatasourceLocal] = LivresDatasourceLocal();
    _services[AssociationsDatasourceLocal] = AssociationsDatasourceLocal();
    _services[MenusDatasourceLocal] = MenusDatasourceLocal();
    _services[SallesDatasourceLocal] = SallesDatasourceLocal();
    _services[ActualitesDatasourceLocal] = ActualitesDatasourceLocal();

    // Configuration des repositories (Data Layer → Domain Interface)
    _services[LivresRepository] = LivresRepositoryImpl(
      _services[LivresDatasourceLocal] as LivresDatasourceLocal,
    );
    _services[AssociationsRepository] = AssociationsRepositoryImpl(
      _services[AssociationsDatasourceLocal] as AssociationsDatasourceLocal,
    );
    _services[MenusRepository] = MenusRepositoryImpl(
      _services[MenusDatasourceLocal] as MenusDatasourceLocal,
    );
    _services[SallesRepository] = SallesRepositoryImpl(
      _services[SallesDatasourceLocal] as SallesDatasourceLocal,
    );
    _services[ActualitesRepository] = ActualitesRepositoryImpl(
      _services[ActualitesDatasourceLocal] as ActualitesDatasourceLocal,
    );

    _isConfigured = true;
    print('✅ ServiceLocator: Toutes les dépendances configurées');
  }

  /// Récupère une instance du service demandé
  static T obtenirService<T>() {
    if (!_isConfigured) {
      throw Exception(
        'ServiceLocator non configuré. Appelez configurerDependances() d\'abord.',
      );
    }

    final service = _services[T];
    if (service == null) {
      throw Exception('Service de type $T non trouvé dans ServiceLocator');
    }

    return service as T;
  }

  /// Vérifie si un service est enregistré
  static bool estEnregistre<T>() {
    return _services.containsKey(T);
  }

  /// Réinitialise toutes les dépendances (pour les tests)
  static void reinitialiser() {
    _services.clear();
    _isConfigured = false;
  }

  /// Enregistre manuellement un service (pour les tests ou cas spéciaux)
  static void enregistrerService<T>(T service) {
    _services[T] = service;
  }

  /// Affiche la liste de tous les services enregistrés (debug)
  static void afficherServicesEnregistres() {
    print('🔍 Services enregistrés dans ServiceLocator:');
    for (final type in _services.keys) {
      print('  - $type: ${_services[type].runtimeType}');
    }
  }
} 