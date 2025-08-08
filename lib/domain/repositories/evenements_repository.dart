// Clean Architecture: Interface du repository pour les événements
import '../entities/evenement.dart';

abstract class EvenementsRepository {
  /// Récupère tous les événements
  Future<List<Evenement>> obtenirEvenements();
  
  /// Récupère les événements d'une association spécifique
  Future<List<Evenement>> obtenirEvenementsParAssociation(String associationId);
  
  /// Récupère un événement par son ID
  Future<Evenement?> obtenirEvenementParId(String id);
  
  /// Ajoute un nouvel événement
  Future<Evenement> ajouterEvenement(Evenement evenement);
  
  /// Met à jour un événement existant
  Future<Evenement> mettreAJourEvenement(Evenement evenement);
  
  /// Supprime un événement
  Future<bool> supprimerEvenement(String id);
  
  /// Récupère les événements à venir
  Future<List<Evenement>> obtenirEvenementsAVenir();
  
  /// Récupère les événements par type
  Future<List<Evenement>> obtenirEvenementsParType(String type);
  
  /// Récupère les événements dans une période donnée
  Future<List<Evenement>> obtenirEvenementsParPeriode(DateTime debut, DateTime fin);
  
  /// Vérifie si un utilisateur peut s'inscrire à un événement
  Future<bool> peutSInscrire(String evenementId, String utilisateurId);
  
  /// Inscrit un utilisateur à un événement
  Future<bool> inscrireUtilisateur(String evenementId, String utilisateurId);
  
  /// Désinscrit un utilisateur d'un événement
  Future<bool> desinscrireUtilisateur(String evenementId, String utilisateurId);
} 