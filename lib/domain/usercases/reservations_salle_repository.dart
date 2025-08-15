// UI Design: Repository abstrait pour la gestion des réservations de salles
import '../entities/reservation_salle.dart';

abstract class ReservationsSalleRepository {
  // UI Design: Gestion des réservations
  Future<List<ReservationSalle>> obtenirReservationsParUtilisateur(String utilisateurId);
  Future<List<ReservationSalle>> obtenirReservationsParSalle(String salleId);
  Future<ReservationSalle?> obtenirReservationParId(String reservationId);
  
  // UI Design: Création et modification de réservations
  Future<bool> creerReservation(ReservationSalle reservation);
  Future<bool> modifierReservation(ReservationSalle reservation);
  Future<bool> annulerReservation(String reservationId);
  
  // UI Design: Gestion des statuts
  Future<bool> confirmerReservation(String reservationId);
  Future<bool> terminerReservation(String reservationId);
  
  // UI Design: Disponibilité et planning
  Future<List<ReservationSalle>> obtenirReservationsJour(String salleId, DateTime jour);
  Future<bool> verifierDisponibilite(String salleId, DateTime debut, DateTime fin);
  
  // UI Design: Statistiques et historique
  Future<List<ReservationSalle>> obtenirHistoriqueReservations(String utilisateurId);
  Future<Map<String, int>> obtenirStatistiquesReservations(String utilisateurId);
}