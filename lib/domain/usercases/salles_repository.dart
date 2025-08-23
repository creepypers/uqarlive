import '../entities/salle.dart';
// Repository abstrait pour la gestion des salles de révision
abstract class SallesRepository {
  // Obtenir toutes les salles
  Future<List<Salle>> obtenirToutesLesSalles();
  // Obtenir les salles disponibles
  Future<List<Salle>> obtenirSallesDisponibles();
  // Obtenir une salle par ID
  Future<Salle?> obtenirSalleParId(String id);
  // Réserver une salle
  Future<bool> reserverSalle(
    String salleId, 
    String utilisateurId, 
    DateTime dateReservation,
    DateTime heureDebut,
    DateTime heureFin,
  );
  // Annuler une réservation
  Future<bool> annulerReservation(String salleId);
  // Obtenir les réservations d'un utilisateur
  Future<List<Salle>> obtenirReservationsUtilisateur(String utilisateurId);
  // Vérifier la disponibilité d'une salle
  Future<bool> verifierDisponibilite(
    String salleId,
    DateTime dateReservation,
    DateTime heureDebut,
    DateTime heureFin,
  );
} 