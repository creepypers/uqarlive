import '../../domain/entities/utilisateur.dart';
import '../../domain/usercases/utilisateurs_repository.dart';
import '../di/service_locator.dart';

class UtilisateursUtils {
  static UtilisateursRepository? _repository;

  // Obtenir le repository des utilisateurs
  static UtilisateursRepository get _utilisateursRepository {
    _repository ??= ServiceLocator.obtenirService<UtilisateursRepository>();
    return _repository!;
  }

  // Obtenir tous les utilisateurs actifs
  static Future<List<Utilisateur>> obtenirUtilisateursActifs() async {
    try {
      final utilisateurs = await _utilisateursRepository.obtenirTousLesUtilisateurs();
      return utilisateurs.where((u) => u.estActif).toList();
    } catch (e) {
      return [];
    }
  }

  // Obtenir seulement les étudiants actifs
  static Future<List<Utilisateur>> obtenirEtudiantsActifs() async {
    try {
      final utilisateurs = await _utilisateursRepository.obtenirTousLesUtilisateurs();
      return utilisateurs.where((u) => 
        u.estActif && u.typeUtilisateur == TypeUtilisateur.etudiant
      ).toList();
    } catch (e) {
      return [];
    }
  }

  // Obtenir seulement les administrateurs actifs
  static Future<List<Utilisateur>> obtenirAdministrateursActifs() async {
    try {
      final utilisateurs = await _utilisateursRepository.obtenirTousLesUtilisateurs();
      return utilisateurs.where((u) => 
        u.estActif && u.typeUtilisateur == TypeUtilisateur.administrateur
      ).toList();
    } catch (e) {
      return [];
    }
  }

  // Obtenir un utilisateur par son ID
  static Future<Utilisateur?> obtenirUtilisateurParId(String id) async {
    try {
      return await _utilisateursRepository.obtenirUtilisateurParId(id);
    } catch (e) {
      return null;
    }
  }

  // Obtenir un utilisateur par son code étudiant
  static Future<Utilisateur?> obtenirUtilisateurParCodeEtudiant(String codeEtudiant) async {
    try {
      return await _utilisateursRepository.obtenirUtilisateurParCodeEtudiant(codeEtudiant);
    } catch (e) {
      return null;
    }
  }

  // Rechercher des utilisateurs par terme
  static Future<List<Utilisateur>> rechercherUtilisateurs(String terme) async {
    try {
      return await _utilisateursRepository.rechercherUtilisateurs(terme);
    } catch (e) {
      return [];
    }
  }

  // Obtenir les utilisateurs récents
  static Future<List<Utilisateur>> obtenirUtilisateursRecents(int limite) async {
    try {
      return await _utilisateursRepository.obtenirUtilisateursRecents(limite);
    } catch (e) {
      return [];
    }
  }

  // Obtenir les utilisateurs connectés récemment
  static Future<List<Utilisateur>> obtenirUtilisateursConnectes() async {
    try {
      return await _utilisateursRepository.obtenirUtilisateursConnectes();
    } catch (e) {
      return [];
    }
  }

  // Formater le nom complet d'un utilisateur
  static String formaterNomComplet(Utilisateur utilisateur) {
    return '${utilisateur.prenom} ${utilisateur.nom}';
  }

  // Formater le nom court d'un utilisateur (prénom + initiale du nom)
  static String formaterNomCourt(Utilisateur utilisateur) {
    if (utilisateur.nom.isNotEmpty) {
      return '${utilisateur.prenom} ${utilisateur.nom[0]}.';
    }
    return utilisateur.prenom;
  }

  // Vérifier si un utilisateur a un privilège spécifique
  static bool aPrivilege(Utilisateur utilisateur, String privilege) {
    return utilisateur.privileges.contains(privilege);
  }

  // Vérifier si un utilisateur est membre d'une association
  static bool estMembreAssociation(Utilisateur utilisateur, String associationId) {
    return utilisateur.associationsMembre.contains(associationId);
  }

  // Obtenir le nombre d'associations d'un utilisateur
  static int nombreAssociations(Utilisateur utilisateur) {
    return utilisateur.associationsMembre.length;
  }
}
