import '../entities/membre_association.dart';
abstract class MembresAssociationRepository {
  Future<List<MembreAssociation>> obtenirMembresParUtilisateur(String utilisateurId);
  Future<List<MembreAssociation>> obtenirMembresParAssociation(String associationId);
  Future<MembreAssociation?> obtenirAdhesion(String utilisateurId, String associationId);
  Future<bool> ajouterMembre(MembreAssociation membre);
  Future<bool> modifierMembre(MembreAssociation membre);
  Future<bool> supprimerMembre(String membreId);
  Future<bool> changerRole(String membreId, String nouveauRole);
  Future<List<MembreAssociation>> obtenirMembresBureau(String associationId);
  Future<bool> estMembreActif(String utilisateurId, String associationId);
  Future<int> compterMembresActifs(String associationId);
  Future<Map<String, int>> obtenirStatistiquesAdhesions(String utilisateurId);
}