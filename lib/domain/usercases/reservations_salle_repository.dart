import '../entities/reservation_salle.dart';
abstract class ReservationsSalleRepository {
  Future<List<ReservationSalle>> obtenirReservationsParUtilisateur(String utilisateurId);
  Future<List<ReservationSalle>> obtenirReservationsParSalle(String salleId);
  Future<ReservationSalle?> obtenirReservationParId(String reservationId);
  Future<bool> creerReservation(ReservationSalle reservation);
  Future<bool> modifierReservation(ReservationSalle reservation);
  Future<bool> annulerReservation(String reservationId);
  Future<bool> confirmerReservation(String reservationId);
  Future<bool> terminerReservation(String reservationId);
  Future<List<ReservationSalle>> obtenirReservationsJour(String salleId, DateTime jour);
  Future<bool> verifierDisponibilite(String salleId, DateTime debut, DateTime fin);
  Future<List<ReservationSalle>> obtenirHistoriqueReservations(String utilisateurId);
  Future<Map<String, int>> obtenirStatistiquesReservations(String utilisateurId);
}