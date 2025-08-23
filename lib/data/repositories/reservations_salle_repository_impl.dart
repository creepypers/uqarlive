import '../../domain/entities/reservation_salle.dart';
import '../../domain/usercases/reservations_salle_repository.dart';
import '../datasources/internal/reservations_salle_datasource_local.dart';
import '../models/reservation_salle_model.dart';
class ReservationsSalleRepositoryImpl implements ReservationsSalleRepository {
  final ReservationsSalleDatasourceLocal _datasourceLocal;
  const ReservationsSalleRepositoryImpl(this._datasourceLocal);
  @override
  Future<List<ReservationSalle>> obtenirReservationsParUtilisateur(String utilisateurId) async {
    final models = await _datasourceLocal.obtenirReservationsParUtilisateur(utilisateurId);
    return models.map((model) => model.toEntity()).toList();
  }
  @override
  Future<List<ReservationSalle>> obtenirReservationsParSalle(String salleId) async {
    final models = await _datasourceLocal.obtenirReservationsParSalle(salleId);
    return models.map((model) => model.toEntity()).toList();
  }
  @override
  Future<ReservationSalle?> obtenirReservationParId(String reservationId) async {
    try {
      final model = await _datasourceLocal.obtenirReservationParId(reservationId);
      return model?.toEntity();
    } catch (e) {
      return null;
    }
  }
  @override
  Future<bool> creerReservation(ReservationSalle reservation) async {
    try {
      final model = ReservationSalleModel.fromEntity(reservation);
      await _datasourceLocal.ajouterReservation(model);
      return true;
    } catch (e) {
      return false;
    }
  }
  @override
  Future<bool> modifierReservation(ReservationSalle reservation) async {
    try {
      final model = ReservationSalleModel.fromEntity(reservation);
      await _datasourceLocal.modifierReservation(model);
      return true;
    } catch (e) {
      return false;
    }
  }
  @override
  Future<bool> confirmerReservation(String reservationId) async {
    try {
      await _datasourceLocal.changerStatutReservation(reservationId, 'Confirmée');
      return true;
    } catch (e) {
      return false;
    }
  }
  @override
  Future<bool> annulerReservation(String reservationId) async {
    try {
      await _datasourceLocal.changerStatutReservation(reservationId, 'Annulée');
      return true;
    } catch (e) {
      return false;
    }
  }
  @override
  Future<bool> terminerReservation(String reservationId) async {
    try {
      await _datasourceLocal.changerStatutReservation(reservationId, 'Terminée');
      return true;
    } catch (e) {
      return false;
    }
  }
  @override
  Future<List<ReservationSalle>> obtenirReservationsJour(String salleId, DateTime jour) async {
    final models = await _datasourceLocal.obtenirReservationsJour(salleId, jour);
    return models.map((model) => model.toEntity()).toList();
  }
  @override
  Future<bool> verifierDisponibilite(String salleId, DateTime debut, DateTime fin) async {
    return await _datasourceLocal.verifierDisponibiliteDateTime(salleId, debut, fin);
  }
  @override
  Future<List<ReservationSalle>> obtenirHistoriqueReservations(String utilisateurId) async {
    final models = await _datasourceLocal.obtenirReservationsParUtilisateur(utilisateurId);
    final historique = models.where((r) => r.dateReservation.isBefore(DateTime.now()));
    return historique.map((model) => model.toEntity()).toList();
  }
  @override
  Future<Map<String, int>> obtenirStatistiquesReservations(String utilisateurId) async {
    final models = await _datasourceLocal.obtenirReservationsParUtilisateur(utilisateurId);
    return {
      'total': models.length,
      'confirmees': models.where((r) => r.statut == 'Confirmée').length,
      'enAttente': models.where((r) => r.statut == 'En attente').length,
      'annulees': models.where((r) => r.statut == 'Annulée').length,
    };
  }
}