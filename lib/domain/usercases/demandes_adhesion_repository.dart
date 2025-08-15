// UI Design: Repository abstrait pour la gestion des demandes d'adhésion
import '../entities/demande_adhesion.dart';

abstract class DemandesAdhesionRepository {
  // UI Design: Gestion des demandes
  Future<List<DemandeAdhesion>> obtenirDemandesParUtilisateur(String utilisateurId);
  Future<List<DemandeAdhesion>> obtenirDemandesParAssociation(String associationId);
  Future<List<DemandeAdhesion>> obtenirDemandesEnAttente(String associationId);
  Future<DemandeAdhesion?> obtenirDemandeParId(String demandeId);
  
  // UI Design: Création et gestion de demandes
  Future<bool> creerDemande(DemandeAdhesion demande);
  Future<bool> accepterDemande(String demandeId, String chefId, String? messageReponse);
  Future<bool> refuserDemande(String demandeId, String chefId, String? messageReponse);
  Future<bool> annulerDemande(String demandeId);
  
  // UI Design: Vérifications métier
  Future<bool> peutDemanderAdhesion(String utilisateurId, String associationId);
  Future<bool> aDemandePendante(String utilisateurId, String associationId);
  Future<bool> estChefAssociation(String utilisateurId, String associationId);
  
  // UI Design: Statistiques
  Future<Map<String, int>> obtenirStatistiquesDemandes(String associationId);
  Future<int> compterDemandesEnAttente(String associationId);
}