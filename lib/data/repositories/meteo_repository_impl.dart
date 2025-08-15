import '../../domain/entities/meteo.dart';
import '../../domain/repositories/meteo_repository.dart';
import '../datasources/external/meteo_datasource_remote.dart';

class MeteoRepositoryImpl implements MeteoRepository {
  final MeteoDatasourceRemote _remote;
  MeteoRepositoryImpl(this._remote);

  @override
  Future<Meteo> obtenirTemperaturePour({
    required String ville,
    required double latitude,
    required double longitude,
  }) async {
    final temp = await _remote.obtenirTemperatureCelsius(
      latitude: latitude,
      longitude: longitude,
    );
    return Meteo(ville: ville, temperatureCelsius: temp, mesureA: DateTime.now());
  }
}


