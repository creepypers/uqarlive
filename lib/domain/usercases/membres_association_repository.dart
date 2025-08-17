// UI Design: Repository abstrait pour la gestion des membres d'associations
import '../entities/membre_association.dart';

abstract class MembresAssociationRepository {
  // UI Design: Gestion des adhésions
  Future<List<MembreAssociation>> obtenirMembresParUtilisateur(String utilisateurId);
  Future<List<MembreAssociation>> obtenirMembresParAssociation(String associationId);
  Future<MembreAssociation?> obtenirAdhesion(String utilisateurId, String associationId);
  
  // UI Design: Création et modification d'adhésions
  Future<bool> ajouterMembre(MembreAssociation membre);
  Future<bool> modifierMembre(MembreAssociation membre);
  Future<bool> supprimerMembre(String membreId);
  
  // UI Design: Gestion des rôles
  Future<bool> changerRole(String membreId, String nouveauRole);
  Future<List<MembreAssociation>> obtenirMembresBureau(String associationId);
  
  // UI Design: Vérifications
  Future<bool> estMembreActif(String utilisateurId, String associationId);
  
  // UI Design: Statistiques
  Future<int> compterMembresActifs(String associationId);
  Future<Map<String, int>> obtenirStatistiquesAdhesions(String utilisateurId);
}