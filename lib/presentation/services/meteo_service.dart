import '../../core/di/service_locator.dart';
import '../../domain/entities/meteo.dart';
import '../../domain/usercases/meteo_repository.dart';

class MeteoService {
  late final MeteoRepository _meteoRepository;

  MeteoService() {
    _meteoRepository = ServiceLocator.obtenirService<MeteoRepository>();
  }

  Future<Meteo> temperatureRimouski() {
    // Coordonnées Rimouski, QC
    return _meteoRepository.obtenirTemperaturePour(
      ville: 'Rimouski',
      latitude: 48.4333,
      longitude: -68.5230,
    );
  }

  Future<Meteo> temperatureLevis() {
    // Coordonnées Lévis, QC
    return _meteoRepository.obtenirTemperaturePour(
      ville: 'Lévis',
      latitude: 46.7382,
      longitude: -71.2465,
    );
  }
}


