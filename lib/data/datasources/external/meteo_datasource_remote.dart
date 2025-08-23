import 'dart:convert';
import 'package:http/http.dart' as http;
class MeteoDatasourceRemote {
  // Retourne la température en °C pour des coordonnées
  Future<double> obtenirTemperatureCelsius({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true',
    );
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Erreur météo: ${resp.statusCode}');
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    final current = data['current_weather'] as Map<String, dynamic>?;
    if (current == null || current['temperature'] == null) {
      throw Exception('Réponse météo invalide');
    }
    return (current['temperature'] as num).toDouble();
  }
}