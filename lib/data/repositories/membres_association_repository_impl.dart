import '../../domain/entities/membre_association.dart';
import '../../domain/repositories/membres_association_repository.dart';
import '../datasources/membres_association_datasource_local.dart';
import '../models/membre_association_model.dart';

class MembresAssociationRepositoryImpl implements MembresAssociationRepository {
  final MembresAssociationDatasourceLocal _datasourceLocal;

  const MembresAssociationRepositoryImpl(this._datasourceLocal);

  @override
  Future<List<MembreAssociation>> obtenirMembresParUtilisateur(String utilisateurId) async {
    final models = await _datasourceLocal.obtenirMembresParUtilisateur(utilisateurId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<MembreAssociation>> obtenirMembresParAssociation(String associationId) async {
    final models = await _datasourceLocal.obtenirMembresParAssociation(associationId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<MembreAssociation?> obtenirAdhesion(String utilisateurId, String associationId) async {
    final models = await _datasourceLocal.obtenirMembresParUtilisateur(utilisateurId);
    try {
      final model = models.firstWhere((m) => m.associationId == associationId);
      return model.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> ajouterMembre(MembreAssociation membre) async {
    try {
      final model = MembreAssociationModel.fromEntity(membre);
      await _datasourceLocal.ajouterMembre(model);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> modifierMembre(MembreAssociation membre) async {
    try {
      final model = MembreAssociationModel.fromEntity(membre);
      await _datasourceLocal.modifierMembre(model);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> supprimerMembre(String membreId) async {
    try {
      await _datasourceLocal.supprimerMembre(membreId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> changerRole(String membreId, String nouveauRole) async {
    try {
      await _datasourceLocal.modifierRoleMembre(membreId, nouveauRole);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<MembreAssociation>> obtenirMembresBureau(String associationId) async {
    final models = await _datasourceLocal.obtenirMembresParAssociation(associationId);
    final bureau = models.where((m) => ['Président', 'Vice-président', 'Secrétaire', 'Trésorier'].contains(m.role));
    return bureau.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> compterMembresActifs(String associationId) async {
    final models = await _datasourceLocal.obtenirMembresParAssociation(associationId);
    return models.length;
  }

  @override
  Future<Map<String, int>> obtenirStatistiquesAdhesions(String utilisateurId) async {
    final models = await _datasourceLocal.obtenirMembresParUtilisateur(utilisateurId);
    return {
      'total': models.length,
      'actives': models.where((m) => m.estActif).length,
      'bureau': models.where((m) => ['Président', 'Vice-président', 'Secrétaire', 'Trésorier'].contains(m.role)).length,
    };
  }
}