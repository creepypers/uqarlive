import 'package:get_it/get_it.dart';
import '../../data/datasources/internal/actualites_datasource_local.dart';
import '../../data/datasources/internal/associations_datasource_local.dart';
import '../../data/datasources/internal/evenements_datasource_local.dart';
import '../../data/datasources/internal/horaires_datasource_local.dart';
import '../../data/datasources/internal/livres_datasource_local.dart';
import '../../data/datasources/internal/menus_datasource_local.dart';
import '../../data/datasources/internal/salles_datasource_local.dart';
import '../../data/datasources/internal/utilisateurs_datasource_local.dart';
import '../../data/datasources/internal/membres_association_datasource_local.dart';
import '../../data/datasources/internal/reservations_salle_datasource_local.dart';
import '../../data/datasources/internal/transactions_datasource_local.dart';
import '../../data/datasources/internal/demandes_adhesion_datasource_local.dart';
import '../../data/datasources/internal/messages_datasource_local.dart';
import '../../data/repositories/actualites_repository_impl.dart';
import '../../data/repositories/associations_repository_impl.dart';
import '../../data/repositories/evenements_repository_impl.dart';
import '../../data/repositories/horaires_repository_impl.dart';
import '../../presentation/services/statistiques_service.dart';
import '../../presentation/services/authentification_service.dart';
import '../../presentation/services/transactions_service.dart';
import '../../presentation/services/adhesions_service.dart';
import '../../presentation/services/gestion_membres_service.dart';
import '../../presentation/services/messagerie_service.dart';
import '../../data/datasources/external/meteo_datasource_remote.dart';
import '../../domain/usercases/meteo_repository.dart';
import '../../data/repositories/meteo_repository_impl.dart';
import '../../presentation/services/meteo_service.dart';
import '../../data/repositories/livres_repository_impl.dart';
import '../../data/repositories/menus_repository_impl.dart';
import '../../data/repositories/salles_repository_impl.dart';
import '../../data/repositories/utilisateurs_repository_impl.dart';
import '../../data/repositories/membres_association_repository_impl.dart';
import '../../data/repositories/reservations_salle_repository_impl.dart';
import '../../data/repositories/transactions_repository_impl.dart';
import '../../data/repositories/demandes_adhesion_repository_impl.dart';
import '../../data/repositories/messages_repository_impl.dart';
import '../../domain/usercases/actualites_repository.dart';
import '../../domain/usercases/associations_repository.dart';
import '../../domain/usercases/evenements_repository.dart';
import '../../domain/usercases/horaires_repository.dart';
import '../../domain/usercases/livres_repository.dart';
import '../../domain/usercases/menus_repository.dart';
import '../../domain/usercases/salles_repository.dart';
import '../../domain/usercases/utilisateurs_repository.dart';
import '../../domain/usercases/membres_association_repository.dart';
import '../../domain/usercases/reservations_salle_repository.dart';
import '../../domain/usercases/transactions_repository.dart';
import '../../domain/usercases/demandes_adhesion_repository.dart';
import '../../domain/usercases/messages_repository.dart';
final getIt = GetIt.instance;
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
    getIt.registerLazySingleton<MessagesDatasourceLocal>(
      () => MessagesDatasourceLocal(),
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
    getIt.registerLazySingleton<MessagesRepository>(
      () => MessagesRepositoryImpl(getIt<MessagesDatasourceLocal>()),
    );
    // Meteo
    getIt.registerLazySingleton<MeteoDatasourceRemote>(() => MeteoDatasourceRemote());
    getIt.registerLazySingleton<MeteoRepository>(() => MeteoRepositoryImpl(getIt<MeteoDatasourceRemote>()));
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
    getIt.registerLazySingleton<GestionMembresService>(
      () => GestionMembresService.instance,
    );
    getIt.registerLazySingleton<MeteoService>(
      () => MeteoService(),
    );
    getIt.registerLazySingleton<MessagerieService>(
      () => MessagerieService(
        getIt<MessagesRepository>(),
        getIt<UtilisateursRepository>(),
      ),
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