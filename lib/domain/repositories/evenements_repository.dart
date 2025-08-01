import '../entities/evenement.dart';

// UI Design: Interface du repository pour les événements d'associations
abstract class EvenementsRepository {
  
  // UI Design: Récupérer tous les événements
  Future<List<Evenement>> obtenirTousLesEvenements();
  
  // UI Design: Récupérer les événements à venir
  Future<List<Evenement>> obtenirEvenementsAVenir();
  
  // UI Design: Récupérer les événements par type
  Future<List<Evenement>> obtenirEvenementsParType(String type);
  
  // UI Design: Récupérer un événement par son ID
  Future<Evenement?> obtenirEvenementParId(String id);
  
  // UI Design: Rechercher des événements
  Future<List<Evenement>> rechercherEvenements(String terme);
} 