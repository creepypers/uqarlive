import '../models/demande_adhesion_model.dart';

class DemandesAdhesionDatasourceLocal {
  // Simulation de données locales pour les demandes d'adhésion
  static final List<DemandeAdhesionModel> _demandes = [
    // Demandes d'adhésion exemple
    DemandeAdhesionModel(
      id: 'demande_001',
      utilisateurId: 'etud_004', // Jean-François Bouchard
      associationId: 'asso_001', // AEI
      statut: 'en_attente',
      dateCreation: DateTime.now().subtract(const Duration(days: 3)),
      messageDemande: 'Je souhaite rejoindre l\'AEI pour participer aux activités étudiantes et contribuer à la vie de campus.',
      roledemande: 'membre',
    ),
    DemandeAdhesionModel(
      id: 'demande_002',
      utilisateurId: 'etud_005', // Sophie Gagnon
      associationId: 'asso_002', // Club Photo UQAR
      statut: 'acceptee',
      dateCreation: DateTime.now().subtract(const Duration(days: 15)),
      dateReponse: DateTime.now().subtract(const Duration(days: 12)),
      messageDemande: 'Passionnée de photographie, je veux apprendre et partager avec d\'autres étudiants.',
      messageReponse: 'Bienvenue dans notre club ! Votre passion nous intéresse.',
      chefId: 'etud_006', // Chef du Club Photo
      roledemande: 'membre',
    ),
    DemandeAdhesionModel(
      id: 'demande_003',
      utilisateurId: 'etud_007', // Martin Côté
      associationId: 'asso_004', // AGE
      statut: 'en_attente',
      dateCreation: DateTime.now().subtract(const Duration(days: 1)),
      messageDemande: 'Je veux m\'impliquer dans la vie associative et aider à organiser des événements.',
      roledemande: 'benevole',
    ),
  ];

  Future<List<DemandeAdhesionModel>> obtenirDemandesParUtilisateur(String utilisateurId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _demandes
        .where((demande) => demande.utilisateurId == utilisateurId)
        .toList()
        ..sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
  }

  Future<List<DemandeAdhesionModel>> obtenirDemandesParAssociation(String associationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _demandes
        .where((demande) => demande.associationId == associationId)
        .toList()
        ..sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
  }

  Future<List<DemandeAdhesionModel>> obtenirDemandesEnAttente(String associationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _demandes
        .where((demande) => 
            demande.associationId == associationId && 
            demande.statut == 'en_attente')
        .toList()
        ..sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
  }

  Future<DemandeAdhesionModel?> obtenirDemandeParId(String demandeId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _demandes.firstWhere((demande) => demande.id == demandeId);
    } catch (e) {
      return null;
    }
  }

  Future<void> creerDemande(DemandeAdhesionModel demande) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _demandes.add(demande);
  }

  Future<void> modifierDemande(DemandeAdhesionModel demande) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _demandes.indexWhere((d) => d.id == demande.id);
    if (index != -1) {
      _demandes[index] = demande;
    }
  }

  Future<void> changerStatutDemande(String demandeId, String nouveauStatut, String? chefId, String? messageReponse) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _demandes.indexWhere((d) => d.id == demandeId);
    if (index != -1) {
      _demandes[index] = _demandes[index].copyWith(
        statut: nouveauStatut,
        dateReponse: DateTime.now(),
        chefId: chefId,
        messageReponse: messageReponse,
      );
    }
  }

  Future<bool> peutDemanderAdhesion(String utilisateurId, String associationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Vérifier qu'il n'y a pas déjà une demande en attente
    final demandePendante = _demandes.any((demande) =>
        demande.utilisateurId == utilisateurId &&
        demande.associationId == associationId &&
        demande.statut == 'en_attente');
    
    return !demandePendante;
  }

  Future<bool> aDemandePendante(String utilisateurId, String associationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _demandes.any((demande) =>
        demande.utilisateurId == utilisateurId &&
        demande.associationId == associationId &&
        demande.statut == 'en_attente');
  }

  Future<Map<String, int>> obtenirStatistiquesDemandes(String associationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final enAttente = _demandes.where((d) => 
        d.associationId == associationId && d.statut == 'en_attente').length;
    final acceptees = _demandes.where((d) => 
        d.associationId == associationId && d.statut == 'acceptee').length;
    final refusees = _demandes.where((d) => 
        d.associationId == associationId && d.statut == 'refusee').length;
    
    return {
      'enAttente': enAttente,
      'acceptees': acceptees,
      'refusees': refusees,
      'total': enAttente + acceptees + refusees,
    };
  }
}