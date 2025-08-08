import 'package:get_it/get_it.dart';
import '../../data/datasources/actualites_datasource_local.dart';
import '../../data/datasources/associations_datasource_local.dart';
import '../../data/datasources/evenements_datasource_local.dart';
import '../../data/datasources/horaires_datasource_local.dart';
import '../../data/datasources/livres_datasource_local.dart';
import '../../data/datasources/menus_datasource_local.dart';
import '../../data/datasources/salles_datasource_local.dart';
import '../../data/datasources/utilisateurs_datasource_local.dart';
import '../../data/datasources/membres_association_datasource_local.dart';
import '../../data/datasources/reservations_salle_datasource_local.dart';
import '../../data/datasources/transactions_datasource_local.dart';
import '../../data/datasources/demandes_adhesion_datasource_local.dart';
import '../../data/repositories/actualites_repository_impl.dart';
import '../../data/repositories/associations_repository_impl.dart';
import '../../data/repositories/evenements_repository_impl.dart';
import '../../data/repositories/horaires_repository_impl.dart';
import '../../presentation/services/statistiques_service.dart';
import '../../presentation/services/authentification_service.dart';
import '../../presentation/services/transactions_service.dart';
import '../../presentation/services/adhesions_service.dart';
import '../../data/repositories/livres_repository_impl.dart';
import '../../data/repositories/menus_repository_impl.dart';
import '../../data/repositories/salles_repository_impl.dart';
import '../../data/repositories/utilisateurs_repository_impl.dart';
import '../../data/repositories/membres_association_repository_impl.dart';
import '../../data/repositories/reservations_salle_repository_impl.dart';
import '../../data/repositories/transactions_repository_impl.dart';
import '../../data/repositories/demandes_adhesion_repository_impl.dart';
import '../../domain/repositories/actualites_repository.dart';
import '../../domain/repositories/associations_repository.dart';
import '../../domain/repositories/evenements_repository.dart';
import '../../domain/repositories/horaires_repository.dart';
import '../../domain/repositories/livres_repository.dart';
import '../../domain/repositories/menus_repository.dart';
import '../../domain/repositories/salles_repository.dart';
import '../../domain/repositories/utilisateurs_repository.dart';
import '../../domain/repositories/membres_association_repository.dart';
import '../../domain/repositories/reservations_salle_repository.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../../domain/repositories/demandes_adhesion_repository.dart';

final getIt = GetIt.instance;

// UI Design: Service Locator pour l'injection de dépendances - Clean Architecture
class ServiceLocator {
  static void configurerDependances() {
    // Data Sources
    getIt.registerLazySingleton<ActualitesDatasourceLocal>(
      () => ActualitesDatasourceLocal(),
    );
    getIt.registerLazySingleton<AssociationsDatasourceLocal>(
      () => AssociationsDatasourceLocal(),
    );
    getIt.registerLazySingleton<HorairesDatasourceLocal>(
      () => HorairesDatasourceLocal(),
    );
    getIt.registerLazySingleton<LivresDatasourceLocal>(
      () => LivresDatasourceLocal(),
    );
    getIt.registerLazySingleton<MenusDatasourceLocal>(
      () => MenusDatasourceLocal(),
    );
    getIt.registerLazySingleton<SallesDatasourceLocal>(
      () => SallesDatasourceLocal(),
    );
    getIt.registerLazySingleton<UtilisateursDatasourceLocal>(
      () => UtilisateursDatasourceLocal(),
    );
    getIt.registerLazySingleton<MembresAssociationDatasourceLocal>(
      () => MembresAssociationDatasourceLocal(),
    );
    getIt.registerLazySingleton<ReservationsSalleDatasourceLocal>(
      () => ReservationsSalleDatasourceLocal(),
    );
    getIt.registerLazySingleton<TransactionsDatasourceLocal>(
      () => TransactionsDatasourceLocal(),
    );
    getIt.registerLazySingleton<DemandesAdhesionDatasourceLocal>(
      () => DemandesAdhesionDatasourceLocal(),
    );

    // Repositories
    getIt.registerLazySingleton<ActualitesRepository>(
      () => ActualitesRepositoryImpl(getIt<ActualitesDatasourceLocal>()),
    );
    getIt.registerLazySingleton<AssociationsRepository>(
      () => AssociationsRepositoryImpl(getIt<AssociationsDatasourceLocal>()),
    );
    getIt.registerLazySingleton<HorairesRepository>(
      () => HorairesRepositoryImpl(getIt<HorairesDatasourceLocal>()),
    );
    getIt.registerLazySingleton<LivresRepository>(
      () => LivresRepositoryImpl(getIt<LivresDatasourceLocal>()),
    );
    getIt.registerLazySingleton<MenusRepository>(
      () => MenusRepositoryImpl(getIt<MenusDatasourceLocal>()),
    );
    getIt.registerLazySingleton<SallesRepository>(
      () => SallesRepositoryImpl(getIt<SallesDatasourceLocal>()),
    );
    getIt.registerLazySingleton<UtilisateursRepository>(
      () => UtilisateursRepositoryImpl(getIt<UtilisateursDatasourceLocal>()),
    );
    getIt.registerLazySingleton<MembresAssociationRepository>(
      () => MembresAssociationRepositoryImpl(getIt<MembresAssociationDatasourceLocal>()),
    );
    getIt.registerLazySingleton<ReservationsSalleRepository>(
      () => ReservationsSalleRepositoryImpl(getIt<ReservationsSalleDatasourceLocal>()),
    );
    getIt.registerLazySingleton<TransactionsRepository>(
      () => TransactionsRepositoryImpl(getIt<TransactionsDatasourceLocal>()),
    );
    getIt.registerLazySingleton<DemandesAdhesionRepository>(
      () => DemandesAdhesionRepositoryImpl(getIt<DemandesAdhesionDatasourceLocal>()),
    );
    getIt.registerLazySingleton<EvenementsDatasourceLocal>(
      () => EvenementsDatasourceLocal(),
    );
    getIt.registerLazySingleton<EvenementsRepository>(
      () => EvenementsRepositoryImpl(getIt<EvenementsDatasourceLocal>()),
    );
    
    // Services
    getIt.registerLazySingleton<StatistiquesService>(
      () => StatistiquesService(),
    );
    
    // Services
    getIt.registerLazySingleton<AuthentificationService>(
      () => AuthentificationService.instance,
    );
    getIt.registerLazySingleton<TransactionsService>(
      () => TransactionsService.instance,
    );
    getIt.registerLazySingleton<AdhesionsService>(
      () => AdhesionsService.instance,
    );
  }

  // Méthode pour obtenir un service
  static T obtenirService<T extends Object>() {
    return getIt<T>();
  }
}

// Fonction de configuration pour compatibilité
void configureDependencies() {
  ServiceLocator.configurerDependances();
} 