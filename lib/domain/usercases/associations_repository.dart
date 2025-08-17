import '../entities/association.dart';

// UI Design: Repository abstrait pour les associations étudiantes - couche domain
abstract class AssociationsRepository {
  /// Obtenir toutes les associations
  Future<List<Association>> obtenirToutesLesAssociations();

  /// Obtenir une association par son ID
  Future<Association?> obtenirAssociationParId(String id);

  /// Obtenir les associations par type
  Future<List<Association>> obtenirAssociationsParType(String type);

  /// Obtenir uniquement les associations actives
  Future<List<Association>> obtenirAssociationsActives();

  /// Rechercher des associations par nom/description
  Future<List<Association>> rechercherAssociations(String recherche);

  /// Obtenir les associations populaires (plus de membres)
  Future<List<Association>> obtenirAssociationsPopulaires({int limite = 5});

  /// Obtenir les types d'associations disponibles
  Future<List<String>> obtenirTypesAssociations();

  /// Ajouter une nouvelle association
  Future<bool> ajouterAssociation(Association association);

  /// Modifier une association existante
  Future<bool> mettreAJourAssociation(Association association);

  /// Supprimer une association
  Future<bool> supprimerAssociation(String id);
} 