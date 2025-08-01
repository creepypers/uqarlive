// UI Design: Entité représentant un événement d'association
class Evenement {
  final String id;
  final String titre;
  final String description;
  final String typeEvenement; // 'conference', 'atelier', 'social', 'sportif', 'culturel', 'academique', 'autre'
  final String lieu;
  final String organisateur;
  final DateTime dateDebut;
  final DateTime dateFin;
  final bool estGratuit;
  final double? prix;
  final bool inscriptionRequise;
  final int? capaciteMaximale;
  final int nombreInscrits;
  final bool estActif;
  final DateTime dateCreation;

  const Evenement({
    required this.id,
    required this.titre,
    required this.description,
    required this.typeEvenement,
    required this.lieu,
    required this.organisateur,
    required this.dateDebut,
    required this.dateFin,
    this.estGratuit = true,
    this.prix,
    this.inscriptionRequise = false,
    this.capaciteMaximale,
    this.nombreInscrits = 0,
    this.estActif = true,
    required this.dateCreation,
  });

  // UI Design: Méthodes utilitaires
  bool get estAVenir => dateDebut.isAfter(DateTime.now());
  bool get estEnCours {
    final maintenant = DateTime.now();
    return maintenant.isAfter(dateDebut) && maintenant.isBefore(dateFin);
  }
  bool get estTermine => dateFin.isBefore(DateTime.now());
  bool get estComplet => inscriptionRequise && capaciteMaximale != null && nombreInscrits >= capaciteMaximale!;

  Duration get duree => dateFin.difference(dateDebut);

  String get statutEvenement {
    if (estTermine) return 'Terminé';
    if (estEnCours) return 'En cours';
    if (estAVenir) return 'À venir';
    return 'Inconnu';
  }

  // UI Design: Copie avec modifications
  Evenement copyWith({
    String? id,
    String? titre,
    String? description,
    String? typeEvenement,
    String? lieu,
    String? organisateur,
    DateTime? dateDebut,
    DateTime? dateFin,
    bool? estGratuit,
    double? prix,
    bool? inscriptionRequise,
    int? capaciteMaximale,
    int? nombreInscrits,
    bool? estActif,
    DateTime? dateCreation,
  }) {
    return Evenement(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      typeEvenement: typeEvenement ?? this.typeEvenement,
      lieu: lieu ?? this.lieu,
      organisateur: organisateur ?? this.organisateur,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      estGratuit: estGratuit ?? this.estGratuit,
      prix: prix ?? this.prix,
      inscriptionRequise: inscriptionRequise ?? this.inscriptionRequise,
      capaciteMaximale: capaciteMaximale ?? this.capaciteMaximale,
      nombreInscrits: nombreInscrits ?? this.nombreInscrits,
      estActif: estActif ?? this.estActif,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }
} 