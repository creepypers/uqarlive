import '../../domain/entities/salle.dart';
import '../../domain/usercases/salles_repository.dart';
import '../datasources/internal/salles_datasource_local.dart';

// Implémentation du repository pour les salles de révision
class SallesRepositoryImpl implements SallesRepository {
  final SallesDatasourceLocal _datasourceLocal;

  SallesRepositoryImpl(this._datasourceLocal);

  @override
  Future<List<Salle>> obtenirToutesLesSalles() async {
    try {
      return await _datasourceLocal.obtenirToutesLesSalles();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des salles: $e');
    }
  }

  @override
  Future<List<Salle>> obtenirSallesDisponibles() async {
    try {
      return await _datasourceLocal.obtenirSallesDisponibles();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des salles disponibles: $e');
    }
  }

  @override
  Future<Salle?> obtenirSalleParId(String id) async {
    try {
      return await _datasourceLocal.obtenirSalleParId(id);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la salle: $e');
    }
  }

  @override
  Future<bool> reserverSalle(
    String salleId, 
    String utilisateurId, 
    DateTime dateReservation,
    DateTime heureDebut,
    DateTime heureFin,
  ) async {
    try {
      // Vérifier d'abord la disponibilité
      final estDisponible = await verifierDisponibilite(
        salleId, 
        dateReservation, 
        heureDebut, 
        heureFin
      );
      
      if (!estDisponible) {
        return false;
      }
      
      return await _datasourceLocal.reserverSalle(
        salleId, 
        utilisateurId, 
        dateReservation,
        heureDebut,
        heureFin,
      );
    } catch (e) {
      throw Exception('Erreur lors de la réservation: $e');
    }
  }

  @override
  Future<bool> annulerReservation(String salleId) async {
    try {
      return await _datasourceLocal.annulerReservation(salleId);
    } catch (e) {
      throw Exception('Erreur lors de l\'annulation de la réservation: $e');
    }
  }

  @override
  Future<List<Salle>> obtenirReservationsUtilisateur(String utilisateurId) async {
    try {
      return await _datasourceLocal.obtenirReservationsUtilisateur(utilisateurId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réservations: $e');
    }
  }

  @override
  Future<bool> verifierDisponibilite(
    String salleId,
    DateTime dateReservation,
    DateTime heureDebut,
    DateTime heureFin,
  ) async {
    try {
      return await _datasourceLocal.verifierDisponibilite(
        salleId, 
        dateReservation, 
        heureDebut, 
        heureFin
      );
    } catch (e) {
      throw Exception('Erreur lors de la vérification de disponibilité: $e');
    }
  }
} 