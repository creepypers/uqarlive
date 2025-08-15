// UI Design: Service pour gerer la coherence bidirectionnelle des membres d'associations
import '../../core/di/service_locator.dart';
import '../../domain/entities/association.dart';
import '../../domain/entities/membre_association.dart';
import '../../domain/usercases/associations_repository.dart';
import '../../domain/usercases/utilisateurs_repository.dart';
import '../../domain/usercases/membres_association_repository.dart';

class GestionMembresService {
  static final GestionMembresService _instance = GestionMembresService._internal();
  factory GestionMembresService() => _instance;
  GestionMembresService._internal();

  static GestionMembresService get instance => _instance;

  AssociationsRepository? _associationsRepository;
  UtilisateursRepository? _utilisateursRepository;
  MembresAssociationRepository? _membresRepository;
  bool _estInitialise = false;

  void initialiser() {
    if (_estInitialise) return;
    _associationsRepository = ServiceLocator.obtenirService<AssociationsRepository>();
    _utilisateursRepository = ServiceLocator.obtenirService<UtilisateursRepository>();
    _membresRepository = ServiceLocator.obtenirService<MembresAssociationRepository>();
    _estInitialise = true;
  }

  AssociationsRepository get associationsRepo {
    if (_associationsRepository == null) initialiser();
    return _associationsRepository!;
  }

  UtilisateursRepository get utilisateursRepo {
    if (_utilisateursRepository == null) initialiser();
    return _utilisateursRepository!;
  }

  MembresAssociationRepository get membresRepo {
    if (_membresRepository == null) initialiser();
    return _membresRepository!;
  }

  // UI Design: Ajouter un membre a une association
  Future<bool> ajouterMembreAssociation({
    required String utilisateurId,
    required String associationId,
    String role = 'membre',
    List<String> responsabilites = const [],
  }) async {
    try {
      // Creer le nouveau membre
      final nouveauMembre = MembreAssociation(
        id: 'membre_${DateTime.now().millisecondsSinceEpoch}',
        utilisateurId: utilisateurId,
        associationId: associationId,
        role: role,
        dateAdhesion: DateTime.now(),
        estActif: true,
        responsabilites: responsabilites,
      );

      // Ajouter le membre au repository
      final ajoutReussi = await membresRepo.ajouterMembre(nouveauMembre);
      if (ajoutReussi) {
        // Mettre a jour la coherence bidirectionnelle
        await _mettreAJourCoherenceMembre(
          utilisateurId: utilisateurId,
          associationId: associationId,
          action: 'ajouter'
        );
      }
      
      return ajoutReussi;
    } catch (e) {
      return false;
    }
  }

  // UI Design: Retirer un membre d'une association
  Future<bool> retirerMembreAssociation({
    required String utilisateurId,
    required String associationId,
  }) async {
    try {
      // Recuperer le membre a supprimer
      final membre = await membresRepo.obtenirAdhesion(utilisateurId, associationId);
      if (membre == null) return false;
      
      // Supprimer le membre
      final retraitReussi = await membresRepo.supprimerMembre(membre.id);
      if (retraitReussi) {
        // Mettre a jour la coherence bidirectionnelle
        await _mettreAJourCoherenceMembre(
          utilisateurId: utilisateurId,
          associationId: associationId,
          action: 'retirer'
        );
      }
      
      return retraitReussi;
    } catch (e) {
      return false;
    }
  }

  // UI Design: Methode privee pour maintenir la coherence bidirectionnelle
  Future<void> _mettreAJourCoherenceMembre({
    required String utilisateurId,
    required String associationId,
    required String action, // 'ajouter' ou 'retirer'
  }) async {
    try {
      // Recuperer l'association et l'utilisateur actuels
      final association = await associationsRepo.obtenirAssociationParId(associationId);
      final utilisateur = await utilisateursRepo.obtenirUtilisateurParId(utilisateurId);
      
      if (association == null || utilisateur == null) return;

      if (action == 'ajouter') {
        // Ajouter l'utilisateur a la liste des membres de l'association
        final nouveauxMembres = List<String>.from(association.membresActifs);
        if (!nouveauxMembres.contains(utilisateurId)) {
          nouveauxMembres.add(utilisateurId);
        }
        
        final associationMiseAJour = association.copyWith(
          membresActifs: nouveauxMembres,
        );
        
        // Ajouter l'association a la liste des associations de l'utilisateur
        final nouvellesAssociations = List<String>.from(utilisateur.associationsMembre);
        if (!nouvellesAssociations.contains(associationId)) {
          nouvellesAssociations.add(associationId);
        }
        
        final utilisateurMiseAJour = utilisateur.copyWith(
          associationsMembre: nouvellesAssociations,
        );
        
        // Sauvegarder les modifications
        await associationsRepo.mettreAJourAssociation(associationMiseAJour);
        await utilisateursRepo.modifierUtilisateur(utilisateurMiseAJour);
        
      } else if (action == 'retirer') {
        // Retirer l'utilisateur de la liste des membres de l'association
        final nouveauxMembres = List<String>.from(association.membresActifs);
        nouveauxMembres.remove(utilisateurId);
        
        final associationMiseAJour = association.copyWith(
          membresActifs: nouveauxMembres,
        );
        
        // Retirer l'association de la liste des associations de l'utilisateur
        final nouvellesAssociations = List<String>.from(utilisateur.associationsMembre);
        nouvellesAssociations.remove(associationId);
        
        final utilisateurMiseAJour = utilisateur.copyWith(
          associationsMembre: nouvellesAssociations,
        );
        
        // Sauvegarder les modifications
        await associationsRepo.mettreAJourAssociation(associationMiseAJour);
        await utilisateursRepo.modifierUtilisateur(utilisateurMiseAJour);
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la cohérence: $e');
    }
  }

  // UI Design: Obtenir la liste des membres d'une association
  Future<List<MembreAssociation>> obtenirMembresAssociation(String associationId) async {
    return await membresRepo.obtenirMembresParAssociation(associationId);
  }

  // UI Design: Obtenir les associations d'un utilisateur
  Future<List<Association>> obtenirAssociationsUtilisateur(String utilisateurId) async {
    final utilisateur = await utilisateursRepo.obtenirUtilisateurParId(utilisateurId);
    if (utilisateur == null || utilisateur.associationsMembre.isEmpty) {
      return [];
    }
    
    final associations = <Association>[];
    for (final associationId in utilisateur.associationsMembre) {
      final association = await associationsRepo.obtenirAssociationParId(associationId);
      if (association != null) {
        associations.add(association);
      }
    }
    
    return associations;
  }

  // UI Design: Verifier si un utilisateur est membre d'une association specifique
  Future<bool> estMembreAssociation(String utilisateurId, String associationId) async {
    final utilisateur = await utilisateursRepo.obtenirUtilisateurParId(utilisateurId);
    if (utilisateur == null) return false;
    
    return utilisateur.associationsMembre.contains(associationId);
  }

  // UI Design: Obtenir le nombre de membres d'une association
  Future<int> obtenirNombreMembres(String associationId) async {
    final association = await associationsRepo.obtenirAssociationParId(associationId);
    return association?.membresActifs.length ?? 0;
  }

  // UI Design: Obtenir le nombre d'associations d'un utilisateur
  Future<int> obtenirNombreAssociations(String utilisateurId) async {
    final utilisateur = await utilisateursRepo.obtenirUtilisateurParId(utilisateurId);
    return utilisateur?.associationsMembre.length ?? 0;
  }

  // UI Design: Synchroniser les listes de membres (pour la maintenance)
  Future<bool> synchroniserListesMembres() async {
    try {
      final associations = await associationsRepo.obtenirToutesLesAssociations();
      
      for (final association in associations) {
        final membres = await membresRepo.obtenirMembresParAssociation(association.id);
        final membresActifs = membres
            .where((m) => m.estActif)
            .map((m) => m.utilisateurId)
            .toList();
        
        if (membresActifs.length != association.membresActifs.length ||
            !membresActifs.every((id) => association.membresActifs.contains(id))) {
          
          final associationMiseAJour = association.copyWith(
            membresActifs: membresActifs,
          );
          
          await associationsRepo.mettreAJourAssociation(associationMiseAJour);
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
}
