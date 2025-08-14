// UI Design: Service pour gérer les demandes d'adhésion aux associations
import '../../core/di/service_locator.dart';
import '../../domain/entities/demande_adhesion.dart';
import '../../domain/entities/utilisateur.dart';
import '../../domain/entities/association.dart';
import '../../domain/entities/membre_association.dart';
import '../../domain/repositories/demandes_adhesion_repository.dart';
import '../../domain/repositories/membres_association_repository.dart';

class AdhesionsService {
  static final AdhesionsService _instance = AdhesionsService._internal();
  factory AdhesionsService() => _instance;
  AdhesionsService._internal();

  static AdhesionsService get instance => _instance;

  DemandesAdhesionRepository? _demandesRepository;
  MembresAssociationRepository? _membresRepository;
  bool _estInitialise = false;

  void initialiser() {
    if (_estInitialise) return;
    _demandesRepository = ServiceLocator.obtenirService<DemandesAdhesionRepository>();
    _membresRepository = ServiceLocator.obtenirService<MembresAssociationRepository>();
    _estInitialise = true;
  }

  DemandesAdhesionRepository get demandesRepo {
    if (_demandesRepository == null) initialiser();
    return _demandesRepository!;
  }

  MembresAssociationRepository get membresRepo {
    if (_membresRepository == null) initialiser();
    return _membresRepository!;
  }

  // UI Design: Vérifier si un utilisateur peut demander l'adhésion
  Future<Map<String, dynamic>> peutDemanderAdhesion(Utilisateur utilisateur, Association association) async {
    // Vérification 1: L'association doit être active
    if (!association.estActive) {
      return {
        'peut': false,
        'raison': 'Cette association n\'est plus active',
        'code': 'ASSOCIATION_INACTIVE'
      };
    }

    // Vérification 2: L'utilisateur ne doit pas déjà être membre
    final estDejaMembre = await membresRepo.estMembreActif(utilisateur.id, association.id);
    if (estDejaMembre) {
      return {
        'peut': false,
        'raison': 'Vous êtes déjà membre de cette association',
        'code': 'DEJA_MEMBRE'
      };
    }

    // Vérification 3: Pas de demande en attente
    final demandePendante = await demandesRepo.aDemandePendante(utilisateur.id, association.id);
    if (demandePendante) {
      return {
        'peut': false,
        'raison': 'Vous avez déjà une demande en attente pour cette association',
        'code': 'DEMANDE_PENDANTE'
      };
    }

    return {
      'peut': true,
      'raison': 'Demande d\'adhésion possible',
      'code': 'ADHESION_AUTORISEE'
    };
  }

  // UI Design: Créer une demande d'adhésion
  Future<bool> creerDemandeAdhesion({
    required String utilisateurId,
    required String associationId,
    String? messageDemande,
    String roledemande = 'membre',
  }) async {
    final demande = DemandeAdhesion(
      id: 'demande_${DateTime.now().millisecondsSinceEpoch}',
      utilisateurId: utilisateurId,
      associationId: associationId,
      statut: 'en_attente',
      dateCreation: DateTime.now(),
      messageDemande: messageDemande,
      roledemande: roledemande,
    );

    return await demandesRepo.creerDemande(demande);
  }

  // UI Design: Obtenir les demandes d'un utilisateur
  Future<List<DemandeAdhesion>> obtenirMesDemandes(String utilisateurId) async {
    return await demandesRepo.obtenirDemandesParUtilisateur(utilisateurId);
  }

  // UI Design: Obtenir les demandes en attente pour une association (pour les chefs)
  Future<List<DemandeAdhesion>> obtenirDemandesEnAttente(String associationId) async {
    return await demandesRepo.obtenirDemandesEnAttente(associationId);
  }

  // UI Design: Accepter une demande (chef d'association)
  Future<bool> accepterDemande({
    required String demandeId,
    required String chefId,
    String? messageReponse,
  }) async {
    final success = await demandesRepo.accepterDemande(demandeId, chefId, messageReponse);
    
    if (success) {
      // UI Design: Créer automatiquement le membership quand la demande est acceptée
      final demande = await demandesRepo.obtenirDemandeParId(demandeId);
      if (demande != null) {
        final nouveauMembre = MembreAssociation(
          id: 'membre_${DateTime.now().millisecondsSinceEpoch}',
          utilisateurId: demande.utilisateurId,
          associationId: demande.associationId,
          role: demande.roledemande,
          dateAdhesion: DateTime.now(),
          estActif: true,
          responsabilites: const [],
        );
        
        // Ajouter le nouveau membre au repository
        final ajoutReussi = await membresRepo.ajouterMembre(nouveauMembre);
        if (!ajoutReussi) {
          // Log l'erreur mais ne pas faire échouer l'acceptation de la demande
        }
      }
    }
    
    return success;
  }

  // UI Design: Refuser une demande (chef d'association)
  Future<bool> refuserDemande({
    required String demandeId,
    required String chefId,
    String? messageReponse,
  }) async {
    return await demandesRepo.refuserDemande(demandeId, chefId, messageReponse);
  }

  // UI Design: Annuler sa propre demande
  Future<bool> annulerDemande(String demandeId) async {
    return await demandesRepo.annulerDemande(demandeId);
  }

  // UI Design: Vérifier si un utilisateur est chef d'association
  Future<bool> estChefAssociation(String utilisateurId, String associationId) async {
    return await demandesRepo.estChefAssociation(utilisateurId, associationId);
  }

  // UI Design: Obtenir les statistiques des demandes (pour les chefs)
  Future<Map<String, int>> obtenirStatistiquesDemandes(String associationId) async {
    return await demandesRepo.obtenirStatistiquesDemandes(associationId);
  }

  // UI Design: Compter les demandes en attente (pour les notifications)
  Future<int> compterDemandesEnAttente(String associationId) async {
    return await demandesRepo.compterDemandesEnAttente(associationId);
  }

  // UI Design: Obtenir toutes les associations où l'utilisateur est chef
  Future<List<String>> obtenirAssociationsGerees(String utilisateurId) async {
    // Pour l'instant, utilisons les données hardcodées
    const chefsAssociations = {
      'etud_001': ['asso_001', 'asso_004'], // Alexandre Martin chef de AEI et AGE
      'etud_006': ['asso_002'], // Sophie Gagnon chef du Club Photo
      'etud_007': ['asso_003'], // Maxime Leblanc chef de Sport UQAR
    };
    
    return chefsAssociations[utilisateurId] ?? [];
  }
}