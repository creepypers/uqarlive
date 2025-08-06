import '../models/membre_association_model.dart';

class MembresAssociationDatasourceLocal {
  // Simulation de données locales pour les membres d'associations
  static List<MembreAssociationModel> _membresAssociation = [
    // Alexandre Martin (etud_001) est membre de 3 associations
    MembreAssociationModel(
      id: 'membre_001',
      utilisateurId: 'etud_001', // Alexandre Martin
      associationId: 'asso_001', // AEI
      role: 'Membre actif',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 365)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_002', 
      utilisateurId: 'etud_001', // Alexandre Martin
      associationId: 'asso_002', // Club Photo UQAR
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 180)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_003',
      utilisateurId: 'etud_001', // Alexandre Martin
      associationId: 'asso_004', // AGE
      role: 'Trésorier',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 90)),
      estActif: true,
    ),
    // Autres utilisateurs
    MembreAssociationModel(
      id: 'membre_004',
      utilisateurId: 'etud_002', // Marie Dubois
      associationId: 'asso_001', // AEI
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 200)),
      estActif: true,
    ),
  ];

  Future<List<MembreAssociationModel>> obtenirMembresParUtilisateur(String utilisateurId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulation latence
    return _membresAssociation
        .where((membre) => membre.utilisateurId == utilisateurId && membre.estActif)
        .toList();
  }

  Future<List<MembreAssociationModel>> obtenirMembresParAssociation(String associationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _membresAssociation
        .where((membre) => membre.associationId == associationId && membre.estActif)
        .toList();
  }

  Future<void> ajouterMembre(MembreAssociationModel membre) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _membresAssociation.add(membre);
  }

  Future<void> supprimerMembre(String membreId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _membresAssociation.removeWhere((membre) => membre.id == membreId);
  }

  Future<void> modifierMembre(MembreAssociationModel membre) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _membresAssociation.indexWhere((m) => m.id == membre.id);
    if (index != -1) {
      _membresAssociation[index] = membre;
    }
  }

  Future<void> modifierRoleMembre(String membreId, String nouveauRole) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _membresAssociation.indexWhere((membre) => membre.id == membreId);
    if (index != -1) {
      _membresAssociation[index] = _membresAssociation[index].copyWith(role: nouveauRole);
    }
  }

  Future<bool> estMembreActif(String utilisateurId, String associationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _membresAssociation.any((membre) => 
        membre.utilisateurId == utilisateurId && 
        membre.associationId == associationId && 
        membre.estActif);
  }
}