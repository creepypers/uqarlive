
import '../../core/di/service_locator.dart';
import '../../domain/entities/demande_adhesion.dart';
import '../../domain/entities/utilisateur.dart';
import '../../domain/entities/association.dart';
import '../../domain/usercases/demandes_adhesion_repository.dart';
import '../../domain/usercases/membres_association_repository.dart';
import '../../domain/usercases/associations_repository.dart';
import '../../domain/usercases/utilisateurs_repository.dart';
import 'gestion_membres_service.dart';

class AdhesionsService {
  static final AdhesionsService _instance = AdhesionsService._internal();
  factory AdhesionsService() => _instance;
  AdhesionsService._internal();

  static AdhesionsService get instance => _instance;

  DemandesAdhesionRepository? _demandesRepository;
  MembresAssociationRepository? _membresRepository;
  AssociationsRepository? _associationsRepository;
  UtilisateursRepository? _utilisateursRepository;
  GestionMembresService? _gestionMembresService;
  bool _estInitialise = false;

  void initialiser() {
    if (_estInitialise) return;
    _demandesRepository = ServiceLocator.obtenirService<DemandesAdhesionRepository>();
    _membresRepository = ServiceLocator.obtenirService<MembresAssociationRepository>();
    _associationsRepository = ServiceLocator.obtenirService<AssociationsRepository>();
    _utilisateursRepository = ServiceLocator.obtenirService<UtilisateursRepository>();
    _gestionMembresService = GestionMembresService.instance;
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

  AssociationsRepository get associationsRepo {
    if (_associationsRepository == null) initialiser();
    return _associationsRepository!;
  }

  UtilisateursRepository get utilisateursRepo {
    if (_utilisateursRepository == null) initialiser();
    return _utilisateursRepository!;
  }

  GestionMembresService get gestionMembres {
    if (_gestionMembresService == null) initialiser();
    return _gestionMembresService!;
  }

  
  Future<Map<String, dynamic>> peutDemanderAdhesion(Utilisateur utilisateur, Association association) async {
    // Verification 1: L'association doit etre active
    if (!association.estActive) {
      return {
        'peut': false,
        'raison': 'Cette association n\'est plus active',
        'code': 'ASSOCIATION_INACTIVE'
      };
    }

    // Verification 2: L'utilisateur ne doit pas deja etre membre
    final estDejaMembre = await gestionMembres.estMembreAssociation(utilisateur.id, association.id);
    if (estDejaMembre) {
      return {
        'peut': false,
        'raison': 'Vous etes deja membre de cette association',
        'code': 'DEJA_MEMBRE'
      };
    }

    // Verification 3: Pas de demande en attente
    final demandePendante = await demandesRepo.aDemandePendante(utilisateur.id, association.id);
    if (demandePendante) {
      return {
        'peut': false,
        'raison': 'Vous avez deja une demande en attente pour cette association',
        'code': 'DEMANDE_PENDANTE'
      };
    }

    return {
      'peut': true,
      'raison': 'Demande d\'adhesion possible',
      'code': 'ADHESION_AUTORISEE'
    };
  }

  
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

  
  Future<List<DemandeAdhesion>> obtenirMesDemandes(String utilisateurId) async {
    return await demandesRepo.obtenirDemandesParUtilisateur(utilisateurId);
  }

  
  Future<List<DemandeAdhesion>> obtenirDemandesEnAttente(String associationId) async {
    return await demandesRepo.obtenirDemandesEnAttente(associationId);
  }

  
  Future<bool> accepterDemande({
    required String demandeId,
    required String chefId,
    String? messageReponse,
  }) async {
    final success = await demandesRepo.accepterDemande(demandeId, chefId, messageReponse);
    
    if (success) {
      
      final demande = await demandesRepo.obtenirDemandeParId(demandeId);
      if (demande != null) {
        // Utiliser le service de gestion des membres pour maintenir la coherence
        final ajoutReussi = await gestionMembres.ajouterMembreAssociation(
          utilisateurId: demande.utilisateurId,
          associationId: demande.associationId,
          role: demande.roledemande,
        );
        
        if (!ajoutReussi) {
          return false;
          // Log l'erreur mais ne pas faire echouer l'acceptation de la demande
        }
      }
    }
    
    return success;
  }

  
  Future<bool> refuserDemande({
    required String demandeId,
    required String chefId,
    String? messageReponse,
  }) async {
    return await demandesRepo.refuserDemande(demandeId, chefId, messageReponse);
  }

  
  Future<bool> annulerDemande(String demandeId) async {
    return await demandesRepo.annulerDemande(demandeId);
  }

  
  Future<bool> estChefAssociation(String utilisateurId, String associationId) async {
    return await demandesRepo.estChefAssociation(utilisateurId, associationId);
  }

  
  Future<Map<String, int>> obtenirStatistiquesDemandes(String associationId) async {
    return await demandesRepo.obtenirStatistiquesDemandes(associationId);
  }

  
  Future<int> compterDemandesEnAttente(String associationId) async {
    return await demandesRepo.compterDemandesEnAttente(associationId);
  }

  
  Future<List<String>> obtenirAssociationsGerees(String utilisateurId) async {
    // Pour l'instant, utilisons les donnees hardcodees
    const chefsAssociations = {
      'etud_001': ['asso_001', 'asso_004'], // Alexandre Martin chef de AEI et AGE
      'etud_006': ['asso_002'], // Sophie Gagnon chef du Club Photo
      'etud_007': ['asso_003'], // Maxime Leblanc chef de Sport UQAR
    };
    
    return chefsAssociations[utilisateurId] ?? [];
  }

  
  Future<List<Association>> obtenirAssociationsUtilisateur(String utilisateurId) async {
    return await gestionMembres.obtenirAssociationsUtilisateur(utilisateurId);
  }

  
  Future<bool> estMembreAssociation(String utilisateurId, String associationId) async {
    return await gestionMembres.estMembreAssociation(utilisateurId, associationId);
  }
}
