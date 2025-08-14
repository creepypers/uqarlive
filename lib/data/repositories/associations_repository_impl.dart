import '../../domain/entities/association.dart';
import '../../domain/repositories/associations_repository.dart';
import '../datasources/associations_datasource_local.dart';
import '../models/association_model.dart';

// UI Design: Implémentation du repository des associations - couche data
class AssociationsRepositoryImpl implements AssociationsRepository {
  final AssociationsDatasourceLocal _datasourceLocal;

  AssociationsRepositoryImpl(this._datasourceLocal);

  @override
  Future<List<Association>> obtenirToutesLesAssociations() async {
    try {
      final associationsMap = _datasourceLocal.obtenirToutesLesAssociations();
      return associationsMap
          .map((map) => AssociationModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Association?> obtenirAssociationParId(String id) async {
    try {
      final associationMap = _datasourceLocal.obtenirAssociationParId(id);
      if (associationMap != null) {
        return AssociationModel.fromMap(associationMap).toEntity();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Association>> obtenirAssociationsParType(String type) async {
    try {
      final associationsMap = _datasourceLocal.obtenirAssociationsParType(type);
      return associationsMap
          .map((map) => AssociationModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Association>> obtenirAssociationsActives() async {
    try {
      final associationsMap = _datasourceLocal.obtenirAssociationsActives();
      return associationsMap
          .map((map) => AssociationModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Association>> rechercherAssociations(String recherche) async {
    try {
      final associationsMap = _datasourceLocal.rechercherAssociations(recherche);
      return associationsMap
          .map((map) => AssociationModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Association>> obtenirAssociationsPopulaires({int limite = 5}) async {
    try {
      final associationsMap = _datasourceLocal.obtenirAssociationsPopulaires(limite: limite);
      return associationsMap
          .map((map) => AssociationModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<String>> obtenirTypesAssociations() async {
    try {
      return _datasourceLocal.obtenirTypesAssociations();
    } catch (e) {
      return ['toutes'];
    }
  }

  @override
  Future<bool> ajouterAssociation(Association association) async {
    try {
      final associationModel = AssociationModel.fromEntity(association);
      return _datasourceLocal.ajouterAssociation(associationModel.toMap());
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> mettreAJourAssociation(Association association) async {
    try {
      final associationModel = AssociationModel.fromEntity(association);
      return _datasourceLocal.mettreAJourAssociation(associationModel.toMap());
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> supprimerAssociation(String id) async {
    try {
      return _datasourceLocal.supprimerAssociation(id);
    } catch (e) {
      return false;
    }
  }
} 