import '../../models/membre_association_model.dart';
class MembresAssociationDatasourceLocal {
  // Simulation de données locales pour les membres d'associations
  static final List<MembreAssociationModel> _membresAssociation = [
    // Alexandre Martin (etud_001) est membre de 3 associations
    MembreAssociationModel(
      id: 'membre_001',
      utilisateurId: 'etud_001', // Alexandre Martin
      associationId: 'asso_001', // AEI
      role: 'Chef',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 365)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_002', 
      utilisateurId: 'etud_001', // Alexandre Martin
      associationId: 'asso_004', // AGE
      role: 'Trésorier',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 90)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_003',
      utilisateurId: 'etud_001', // Alexandre Martin
      associationId: '5', // Théâtre UQAR
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 60)),
      estActif: true,
    ),
    // Marie Dubois (etud_002) - Vice-présidente AEI
    MembreAssociationModel(
      id: 'membre_004',
      utilisateurId: 'etud_002', // Marie Dubois
      associationId: 'asso_001', // AEI
      role: 'Vice-président',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 200)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_005',
      utilisateurId: 'etud_002', // Marie Dubois
      associationId: 'asso_002', // Club Photo UQAR
      role: 'Chef',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 180)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_006',
      utilisateurId: 'etud_002', // Marie Dubois
      associationId: '6', // Éco-UQAR
      role: 'Chef',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 150)),
      estActif: true,
    ),
    // Maxime Leblanc (etud_003) - Président Sport UQAR
    MembreAssociationModel(
      id: 'membre_007',
      utilisateurId: 'etud_003', // Maxime Leblanc
      associationId: 'asso_001', // AEI
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 180)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_008',
      utilisateurId: 'etud_003', // Maxime Leblanc
      associationId: 'asso_003', // Sport UQAR
      role: 'Chef',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 120)),
      estActif: true,
    ),
    // Autres membres de l'AEI
    MembreAssociationModel(
      id: 'membre_009',
      utilisateurId: 'etud_004',
      associationId: 'asso_001', // AEI
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 100)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_010',
      utilisateurId: 'etud_005',
      associationId: 'asso_001', // AEI
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 80)),
      estActif: true,
    ),
    // Membres du Club Photo UQAR
    MembreAssociationModel(
      id: 'membre_011',
      utilisateurId: 'etud_006',
      associationId: 'asso_002', // Club Photo UQAR
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 160)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_012',
      utilisateurId: 'etud_007',
      associationId: 'asso_002', // Club Photo UQAR
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 140)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_013',
      utilisateurId: 'etud_008',
      associationId: 'asso_002', // Club Photo UQAR
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 120)),
      estActif: true,
    ),
    // Membres de Sport UQAR
    MembreAssociationModel(
      id: 'membre_014',
      utilisateurId: 'etud_009',
      associationId: 'asso_003', // Sport UQAR
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 110)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_015',
      utilisateurId: 'etud_010',
      associationId: 'asso_003', // Sport UQAR
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 90)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_016',
      utilisateurId: 'etud_011',
      associationId: 'asso_003', // Sport UQAR
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 70)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_017',
      utilisateurId: 'etud_012',
      associationId: 'asso_003', // Sport UQAR
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 50)),
      estActif: true,
    ),
    // Membres de l'AGE
    MembreAssociationModel(
      id: 'membre_018',
      utilisateurId: 'etud_002',
      associationId: 'asso_004', // AGE
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 85)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_019',
      utilisateurId: 'etud_003',
      associationId: 'asso_004', // AGE
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 75)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_020',
      utilisateurId: 'etud_004',
      associationId: 'asso_004', // AGE
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 65)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_021',
      utilisateurId: 'etud_005',
      associationId: 'asso_004', // AGE
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 55)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_022',
      utilisateurId: 'etud_006',
      associationId: 'asso_004', // AGE
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 45)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_023',
      utilisateurId: 'etud_007',
      associationId: 'asso_004', // AGE
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 35)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_024',
      utilisateurId: 'etud_008',
      associationId: 'asso_004', // AGE
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 25)),
      estActif: true,
    ),
    // Membres du Théâtre UQAR
    MembreAssociationModel(
      id: 'membre_025',
      utilisateurId: 'etud_013',
      associationId: '5', // Théâtre UQAR
      role: 'Chef',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 180)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_026',
      utilisateurId: 'etud_014',
      associationId: '5', // Théâtre UQAR
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 160)),
      estActif: true,
    ),
    // Membres d'Éco-UQAR
    MembreAssociationModel(
      id: 'membre_027',
      utilisateurId: 'etud_015',
      associationId: '6', // Éco-UQAR
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 140)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_028',
      utilisateurId: 'etud_016',
      associationId: '6', // Éco-UQAR
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 120)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_029',
      utilisateurId: 'etud_017',
      associationId: '6', // Éco-UQAR
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 100)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_030',
      utilisateurId: 'etud_018',
      associationId: '6', // Éco-UQAR
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 80)),
      estActif: true,
    ),
    // Membres des Étudiants Internationaux UQAR
    MembreAssociationModel(
      id: 'membre_031',
      utilisateurId: 'etud_019',
      associationId: '7', // Étudiants Internationaux UQAR
      role: 'Chef',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 200)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_032',
      utilisateurId: 'etud_020',
      associationId: '7', // Étudiants Internationaux UQAR
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 180)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_033',
      utilisateurId: 'etud_021',
      associationId: '7', // Étudiants Internationaux UQAR
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 160)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_034',
      utilisateurId: 'etud_022',
      associationId: '7', // Étudiants Internationaux UQAR
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 140)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_035',
      utilisateurId: 'etud_023',
      associationId: '7', // Étudiants Internationaux UQAR
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 120)),
      estActif: true,
    ),
    // Membres de l'AELIES
    MembreAssociationModel(
      id: 'membre_036',
      utilisateurId: 'etud_024',
      associationId: '8', // AELIES
      role: 'Chef',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 220)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_037',
      utilisateurId: 'etud_025',
      associationId: '8', // AELIES
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 200)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_038',
      utilisateurId: 'etud_026',
      associationId: '8', // AELIES
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 180)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_039',
      utilisateurId: 'etud_027',
      associationId: '8', // AELIES
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 160)),
      estActif: true,
    ),
    MembreAssociationModel(
      id: 'membre_040',
      utilisateurId: 'etud_028',
      associationId: '8', // AELIES
      role: 'Membre',
      dateAdhesion: DateTime.now().subtract(const Duration(days: 140)),
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