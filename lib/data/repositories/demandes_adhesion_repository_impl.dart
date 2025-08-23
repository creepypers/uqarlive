import '../../domain/entities/demande_adhesion.dart';
import '../../domain/usercases/demandes_adhesion_repository.dart';
import '../datasources/internal/demandes_adhesion_datasource_local.dart';
import '../models/demande_adhesion_model.dart';
class DemandesAdhesionRepositoryImpl implements DemandesAdhesionRepository {
  final DemandesAdhesionDatasourceLocal _datasourceLocal;
  const DemandesAdhesionRepositoryImpl(this._datasourceLocal);
  @override
  Future<List<DemandeAdhesion>> obtenirDemandesParUtilisateur(String utilisateurId) async {
    final models = await _datasourceLocal.obtenirDemandesParUtilisateur(utilisateurId);
    return models.map((model) => model.toEntity()).toList();
  }
  @override
  Future<List<DemandeAdhesion>> obtenirDemandesParAssociation(String associationId) async {
    final models = await _datasourceLocal.obtenirDemandesParAssociation(associationId);
    return models.map((model) => model.toEntity()).toList();
  }
  @override
  Future<List<DemandeAdhesion>> obtenirDemandesEnAttente(String associationId) async {
    final models = await _datasourceLocal.obtenirDemandesEnAttente(associationId);
    return models.map((model) => model.toEntity()).toList();
  }
  @override
  Future<DemandeAdhesion?> obtenirDemandeParId(String demandeId) async {
    final model = await _datasourceLocal.obtenirDemandeParId(demandeId);
    return model?.toEntity();
  }
  @override
  Future<bool> creerDemande(DemandeAdhesion demande) async {
    try {
      final model = DemandeAdhesionModel.fromEntity(demande);
      await _datasourceLocal.creerDemande(model);
      return true;
    } catch (e) {
      return false;
    }
  }
  @override
  Future<bool> accepterDemande(String demandeId, String chefId, String? messageReponse) async {
    try {
      await _datasourceLocal.changerStatutDemande(demandeId, 'acceptee', chefId, messageReponse);
      return true;
    } catch (e) {
      return false;
    }
  }
  @override
  Future<bool> refuserDemande(String demandeId, String chefId, String? messageReponse) async {
    try {
      await _datasourceLocal.changerStatutDemande(demandeId, 'refusee', chefId, messageReponse);
      return true;
    } catch (e) {
      return false;
    }
  }
  @override
  Future<bool> annulerDemande(String demandeId) async {
    try {
      await _datasourceLocal.changerStatutDemande(demandeId, 'annulee', null, null);
      return true;
    } catch (e) {
      return false;
    }
  }
  @override
  Future<bool> peutDemanderAdhesion(String utilisateurId, String associationId) async {
    return await _datasourceLocal.peutDemanderAdhesion(utilisateurId, associationId);
  }
  @override
  Future<bool> aDemandePendante(String utilisateurId, String associationId) async {
    return await _datasourceLocal.aDemandePendante(utilisateurId, associationId);
  }
  @override
  Future<bool> estChefAssociation(String utilisateurId, String associationId) async {
    // Cette vérification nécessiterait l'accès aux données d'associations
    // Pour l'instant, on va simuler avec des IDs spécifiques
    const chefsAssociations = {
      'asso_001': 'etud_001', // Alexandre Martin chef de l'AEI
      'asso_002': 'etud_006', // Utilisateur chef du Club Photo
      'asso_004': 'etud_001', // Alexandre Martin chef de l'AGE aussi
    };
    await Future.delayed(const Duration(milliseconds: 100));
    return chefsAssociations[associationId] == utilisateurId;
  }
  @override
  Future<Map<String, int>> obtenirStatistiquesDemandes(String associationId) async {
    return await _datasourceLocal.obtenirStatistiquesDemandes(associationId);
  }
  @override
  Future<int> compterDemandesEnAttente(String associationId) async {
    final stats = await obtenirStatistiquesDemandes(associationId);
    return stats['enAttente'] ?? 0;
  }
}