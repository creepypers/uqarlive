import '../../domain/entities/horaire.dart';

class HoraireModel extends Horaire {
  HoraireModel({
    required String jour,
    required Map<String, PlageHoraire> periodes,
    required bool estOuvert,
  }) : super(
          jour: jour,
          periodes: periodes,
          estOuvert: estOuvert,
        );

  // Depuis Map
  factory HoraireModel.fromMap(Map<String, dynamic> map) {
    return HoraireModel(
      jour: map['jour'] as String,
      periodes: (map['periodes'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          PlageHoraireModel.fromMap(value as Map<String, dynamic>),
        ),
      ),
      estOuvert: map['estOuvert'] as bool,
    );
  }

  // Vers Map
  Map<String, dynamic> toMap() {
    return {
      'jour': jour,
      'periodes': periodes.map(
        (key, value) => MapEntry(
          key,
          (value as PlageHoraireModel).toMap(),
        ),
      ),
      'estOuvert': estOuvert,
    };
  }
}

class PlageHoraireModel extends PlageHoraire {
  PlageHoraireModel({
    required String debut,
    required String fin,
  }) : super(
          debut: debut,
          fin: fin,
        );

  // Depuis Map
  factory PlageHoraireModel.fromMap(Map<String, dynamic> map) {
    return PlageHoraireModel(
      debut: map['debut'] as String,
      fin: map['fin'] as String,
    );
  }

  // Vers Map
  Map<String, dynamic> toMap() {
    return {
      'debut': debut,
      'fin': fin,
    };
  }
} 