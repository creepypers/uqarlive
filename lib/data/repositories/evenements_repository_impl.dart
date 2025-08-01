import '../../domain/entities/evenement.dart';
import '../../domain/repositories/evenements_repository.dart';
import '../datasources/evenements_datasource_local.dart';

class EvenementsRepositoryImpl implements EvenementsRepository {
  final EvenementsDatasourceLocal _datasource;

  EvenementsRepositoryImpl(this._datasource);

  @override
  Future<List<Evenement>> obtenirTousLesEvenements() {
    return _datasource.obtenirTousLesEvenements();
  }

  @override
  Future<List<Evenement>> obtenirEvenementsAVenir() {
    return _datasource.obtenirEvenementsAVenir();
  }

  @override
  Future<List<Evenement>> obtenirEvenementsParType(String type) {
    return _datasource.obtenirEvenementsParType(type);
  }

  @override
  Future<Evenement?> obtenirEvenementParId(String id) {
    return _datasource.obtenirEvenementParId(id);
  }

  @override
  Future<List<Evenement>> rechercherEvenements(String terme) {
    return _datasource.rechercherEvenements(terme);
  }
} 