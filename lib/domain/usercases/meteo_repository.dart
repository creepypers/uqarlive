import '../entities/meteo.dart';

abstract class MeteoRepository {
  Future<Meteo> obtenirTemperaturePour({required String ville, required double latitude, required double longitude});
}


