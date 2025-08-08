import '../models/reservation_salle_model.dart';

class ReservationsSalleDatasourceLocal {
  // Simulation de données locales pour les réservations de salles
  // Chaque utilisateur ne peut avoir qu'une seule réservation active
  // Toutes les réservations sont pour aujourd'hui (jour même)
  static final List<ReservationSalleModel> _reservations = [
    // Alexandre Martin (etud_001) - Une seule réservation active pour aujourd'hui
    ReservationSalleModel(
      id: 'res_001',
      salleId: 'salle_001', // Salle A-101
      utilisateurId: 'etud_001', // Alexandre Martin
      dateReservation: DateTime.now(),
      heureDebut: DateTime.now().add(const Duration(hours: 14)), // 14h00
      heureFin: DateTime.now().add(const Duration(hours: 16)), // 16h00
      statut: 'en_attente',
      motif: 'Étude en groupe',
      description: 'Révision pour l\'examen de mathématiques',
      nombrePersonnes: 4,
      coutTotal: 0.0,
      dateCreation: DateTime.now().subtract(const Duration(hours: 2)),
      participantsIds: ['etud_003', 'etud_004', 'etud_005'],
      notesSpeciales: 'Besoin d\'un tableau',
    ),
    
    // Marie Dubois (etud_002) - Une seule réservation active pour aujourd'hui
    ReservationSalleModel(
      id: 'res_002',
      salleId: 'salle_003', // Salle C-302
      utilisateurId: 'etud_002', // Marie Dubois
      dateReservation: DateTime.now(),
      heureDebut: DateTime.now().add(const Duration(hours: 10)), // 10h00
      heureFin: DateTime.now().add(const Duration(hours: 12)), // 12h00
      statut: 'confirmee',
      motif: 'Présentation de projet',
      description: 'Soutenance de projet de fin d\'année',
      nombrePersonnes: 1,
      coutTotal: 10.0,
      dateCreation: DateTime.now().subtract(const Duration(hours: 6)),
      notesSpeciales: 'Présentation PowerPoint',
    ),
    
    // Marc Lavoie (etud_003) - Une seule réservation active pour aujourd'hui
    ReservationSalleModel(
      id: 'res_003',
      salleId: 'salle_005', // Laboratoire B-205
      utilisateurId: 'etud_003', // Marc Lavoie
      dateReservation: DateTime.now(),
      heureDebut: DateTime.now().add(const Duration(hours: 9)), // 9h00
      heureFin: DateTime.now().add(const Duration(hours: 11)), // 11h00
      statut: 'en_attente',
      motif: 'Projet informatique',
      description: 'Développement d\'application mobile',
      nombrePersonnes: 2,
      coutTotal: 15.0,
      dateCreation: DateTime.now().subtract(const Duration(hours: 12)),
      participantsIds: ['etud_006'],
    ),
    
    // Sophie Gagnon (etud_004) - Une seule réservation active pour aujourd'hui
    ReservationSalleModel(
      id: 'res_004',
      salleId: 'salle_002', // Salle A-102
      utilisateurId: 'etud_004', // Sophie Gagnon
      dateReservation: DateTime.now(),
      heureDebut: DateTime.now().add(const Duration(hours: 13)), // 13h00
      heureFin: DateTime.now().add(const Duration(hours: 15)), // 15h00
      statut: 'confirmee',
      motif: 'Révisions',
      description: 'Préparation aux examens finaux',
      nombrePersonnes: 1,
      coutTotal: 0.0,
      dateCreation: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    
    // Jean Tremblay (etud_005) - Une seule réservation active pour aujourd'hui
    ReservationSalleModel(
      id: 'res_005',
      salleId: 'salle_004', // Salle B-201
      utilisateurId: 'etud_005', // Jean Tremblay
      dateReservation: DateTime.now(),
      heureDebut: DateTime.now().add(const Duration(hours: 16)), // 16h00
      heureFin: DateTime.now().add(const Duration(hours: 18)), // 18h00
      statut: 'en_attente',
      motif: 'Étude individuelle',
      description: 'Révision pour l\'examen de chimie',
      nombrePersonnes: 1,
      coutTotal: 6.0,
      dateCreation: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    
    // Marie-Claude Bouchard (etud_006) - Une seule réservation active pour aujourd'hui
    ReservationSalleModel(
      id: 'res_006',
      salleId: 'salle_006', // Amphithéâtre
      utilisateurId: 'etud_006', // Marie-Claude Bouchard
      dateReservation: DateTime.now(),
      heureDebut: DateTime.now().add(const Duration(hours: 14)), // 14h00
      heureFin: DateTime.now().add(const Duration(hours: 17)), // 17h00
      statut: 'confirmee',
      motif: 'Présentation de groupe',
      description: 'Présentation du projet de recherche',
      nombrePersonnes: 6,
      coutTotal: 45.0,
      dateCreation: DateTime.now().subtract(const Duration(hours: 1)),
      participantsIds: ['etud_007', 'etud_008', 'etud_009'],
      notesSpeciales: 'Besoin d\'équipement de projection',
    ),
    
    // Pierre Leblanc (etud_007) - Une seule réservation active pour aujourd'hui
    ReservationSalleModel(
      id: 'res_007',
      salleId: 'salle_007', // Salle de conférence
      utilisateurId: 'etud_007', // Pierre Leblanc
      dateReservation: DateTime.now(),
      heureDebut: DateTime.now().add(const Duration(hours: 10)), // 10h00
      heureFin: DateTime.now().add(const Duration(hours: 12)), // 12h00
      statut: 'en_attente',
      motif: 'Étude de longue durée',
      description: 'Préparation de la thèse',
      nombrePersonnes: 1,
      coutTotal: 12.0,
      dateCreation: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];

  Future<List<ReservationSalleModel>> obtenirReservationsParUtilisateur(String utilisateurId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulation latence
    return _reservations
        .where((reservation) => reservation.utilisateurId == utilisateurId)
        .toList()
        ..sort((a, b) => a.dateReservation.compareTo(b.dateReservation));
  }

  Future<List<ReservationSalleModel>> obtenirReservationsParSalle(String salleId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _reservations
        .where((reservation) => reservation.salleId == salleId)
        .toList()
        ..sort((a, b) => a.dateReservation.compareTo(b.dateReservation));
  }

  Future<ReservationSalleModel?> obtenirReservationParId(String reservationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _reservations.firstWhere((reservation) => reservation.id == reservationId);
    } catch (e) {
      return null;
    }
  }

  Future<List<ReservationSalleModel>> obtenirReservationsJour(String salleId, DateTime jour) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _reservations
        .where((reservation) => 
            reservation.salleId == salleId &&
            reservation.dateReservation.day == jour.day &&
            reservation.dateReservation.month == jour.month &&
            reservation.dateReservation.year == jour.year)
        .toList()
        ..sort((a, b) => a.dateReservation.compareTo(b.dateReservation));
  }

  Future<void> ajouterReservation(ReservationSalleModel reservation) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _reservations.add(reservation);
  }

  Future<void> modifierReservation(ReservationSalleModel reservation) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _reservations.indexWhere((r) => r.id == reservation.id);
    if (index != -1) {
      _reservations[index] = reservation;
    }
  }

  Future<void> supprimerReservation(String reservationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _reservations.removeWhere((reservation) => reservation.id == reservationId);
  }

  Future<void> changerStatutReservation(String reservationId, String nouveauStatut) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _reservations.indexWhere((reservation) => reservation.id == reservationId);
    if (index != -1) {
      _reservations[index] = _reservations[index].copyWith(statut: nouveauStatut);
    }
  }

  Future<bool> verifierDisponibiliteDateTime(String salleId, DateTime debut, DateTime fin) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Vérifier s'il y a des conflits
    final conflits = _reservations.where((reservation) =>
        reservation.salleId == salleId &&
        reservation.dateReservation.day == debut.day &&
        reservation.dateReservation.month == debut.month &&
        reservation.dateReservation.year == debut.year &&
        reservation.statut != 'annulee' &&
        _dateTimeSeChevanchent(reservation, debut, fin)
    );
    
    return conflits.isEmpty;
  }

  Future<bool> verifierDisponibilite(String salleId, DateTime date, DateTime heureDebut, DateTime heureFin) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Vérifier s'il y a des conflits
    final conflits = _reservations.where((reservation) =>
        reservation.salleId == salleId &&
        reservation.dateReservation.day == date.day &&
        reservation.dateReservation.month == date.month &&
        reservation.dateReservation.year == date.year &&
        reservation.statut != 'annulee' &&
        _heuresSeChevanchent(reservation.heureDebut, reservation.heureFin, heureDebut, heureFin)
    );
    
    return conflits.isEmpty;
  }

  bool _heuresSeChevanchent(DateTime debut1, DateTime fin1, DateTime debut2, DateTime fin2) {
    return !(fin1.isBefore(debut2) || fin2.isBefore(debut1));
  }

  bool _dateTimeSeChevanchent(ReservationSalleModel reservation, DateTime debut, DateTime fin) {
    return !(reservation.heureFin.isBefore(debut) || reservation.heureDebut.isAfter(fin));
  }
}
