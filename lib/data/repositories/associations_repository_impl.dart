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
      print('Erreur lors de l\'obtention des associations: $e');
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
      print('Erreur lors de l\'obtention de l\'association par ID: $e');
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
      print('Erreur lors de l\'obtention des associations par type: $e');
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
      print('Erreur lors de l\'obtention des associations actives: $e');
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
      print('Erreur lors de la recherche d\'associations: $e');
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
      print('Erreur lors de l\'obtention des associations populaires: $e');
      return [];
    }
  }

  @override
  Future<List<String>> obtenirTypesAssociations() async {
    try {
      return _datasourceLocal.obtenirTypesAssociations();
    } catch (e) {
      print('Erreur lors de l\'obtention des types d\'associations: $e');
      return ['toutes'];
    }
  }
} 