import 'package:flutter/material.dart';
import '../../domain/repositories/horaires_repository.dart';
import '../datasources/horaires_datasource_local.dart';

class HorairesRepositoryImpl implements HorairesRepository {
  final HorairesDatasourceLocal _datasource;

  HorairesRepositoryImpl(this._datasource);

  @override
  Map<String, TimeOfDay> obtenirHorairesCantine(String jour) {
    return _datasource.obtenirHorairesCantine(jour);
  }

  @override
  Map<String, Map<String, TimeOfDay>> obtenirTousLesHorairesCantine() {
    return _datasource.obtenirTousLesHorairesCantine();
  }

  @override
  Future<void> mettreAJourHorairesCantine(
    String jour,
    TimeOfDay heureOuverture,
    TimeOfDay heureFermeture,
  ) {
    return _datasource.mettreAJourHorairesCantine(
      jour,
      heureOuverture,
      heureFermeture,
    );
  }

  @override
  bool estCantineOuverte({DateTime? dateVerification}) {
    return _datasource.estCantineOuverte(dateVerification: dateVerification);
  }

  @override
  String obtenirStatutCantineFormatte() {
    return _datasource.obtenirStatutCantineFormatte();
  }
} 