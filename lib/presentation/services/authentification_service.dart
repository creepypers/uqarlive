// UI Design: Service d'authentification pour centraliser la gestion de l'utilisateur connecté
import '../../core/di/service_locator.dart';
import '../../domain/entities/utilisateur.dart';
import '../../domain/repositories/utilisateurs_repository.dart';

class AuthentificationService {
  static AuthentificationService? _instance;
  static AuthentificationService get instance {
    _instance ??= AuthentificationService._();
    return _instance!;
  }
  
  AuthentificationService._();

  final UtilisateursRepository _utilisateursRepository = 
      ServiceLocator.obtenirService<UtilisateursRepository>();

  Utilisateur? _utilisateurActuel;

  // UI Design: Getter pour l'utilisateur connecté
  Utilisateur? get utilisateurActuel => _utilisateurActuel;
  
  // UI Design: Vérifier si un utilisateur est connecté
  bool get estConnecte => _utilisateurActuel != null;
  
  // UI Design: Authentifier un utilisateur
  Future<Utilisateur?> authentifier(String email, String motDePasse) async {
    try {
      final utilisateur = await _utilisateursRepository.authentifierUtilisateur(email, motDePasse);
      _utilisateurActuel = utilisateur;
      return utilisateur;
    } catch (e) {
      return null;
    }
  }

  // UI Design: Charger l'utilisateur actuel (au démarrage de l'app)
  Future<void> chargerUtilisateurActuel() async {
    try {
      _utilisateurActuel = await _utilisateursRepository.obtenirUtilisateurActuel();
    } catch (e) {
      _utilisateurActuel = null;
    }
  }

  // UI Design: Déconnecter l'utilisateur
  Future<void> deconnecter() async {
    try {
      await _utilisateursRepository.deconnecterUtilisateur();
      _utilisateurActuel = null;
    } catch (e) {
      // Gérer l'erreur si nécessaire
    }
  }

  // UI Design: Mettre à jour l'utilisateur actuel après modification
  Future<void> actualiserUtilisateurActuel() async {
    if (_utilisateurActuel != null) {
      try {
        final utilisateurMisAJour = await _utilisateursRepository.obtenirUtilisateurParId(_utilisateurActuel!.id);
        if (utilisateurMisAJour != null) {
          _utilisateurActuel = utilisateurMisAJour;
        }
      } catch (e) {
        // Gérer l'erreur si nécessaire
      }
    }
  }

  // UI Design: Vérifier si l'utilisateur connecté a un privilège spécifique
  bool aPrivilege(String privilege) {
    return _utilisateurActuel?.aPrivilege(privilege) ?? false;
  }

  // UI Design: Vérifier si l'utilisateur connecté est admin
  bool get estAdministrateur {
    return aPrivilege('admin') || _utilisateurActuel?.typeUtilisateur == TypeUtilisateur.administrateur;
  }

  // UI Design: Modifier les privilèges d'un utilisateur (admin seulement)
  Future<bool> modifierPrivileges(String utilisateurId, List<String> nouveauxPrivileges) async {
    // Vérifier que l'utilisateur connecté est admin
    if (!estAdministrateur) {
      return false;
    }

    try {
      final utilisateur = await _utilisateursRepository.obtenirUtilisateurParId(utilisateurId);
      if (utilisateur == null) return false;

      // Vérifier qu'on ne retire pas les privilèges admin du dernier admin
      if (utilisateur.aPrivilege('admin') && !nouveauxPrivileges.contains('admin')) {
        final tousUtilisateurs = await _utilisateursRepository.obtenirTousLesUtilisateurs();
        final admins = tousUtilisateurs.where((u) => u.aPrivilege('admin') || u.typeUtilisateur == 'admin').toList();
        if (admins.length <= 1) {
          return false; // Ne pas retirer le dernier admin
        }
      }

      final utilisateurModifie = utilisateur.copyWith(privileges: nouveauxPrivileges);
      return await _utilisateursRepository.modifierUtilisateur(utilisateurModifie);
    } catch (e) {
      return false;
    }
  }

  // UI Design: Promouvoir un utilisateur admin (admin seulement)
  Future<bool> promouvoirAdmin(String utilisateurId) async {
    if (!estAdministrateur) return false;

    final utilisateur = await _utilisateursRepository.obtenirUtilisateurParId(utilisateurId);
    if (utilisateur == null) return false;

    final nouveauxPrivileges = List<String>.from(utilisateur.privileges);
    if (!nouveauxPrivileges.contains('admin')) {
      nouveauxPrivileges.add('admin');
    }

    return await modifierPrivileges(utilisateurId, nouveauxPrivileges);
  }

  // UI Design: Rétrograder un admin (admin seulement, sauf dernier admin)
  Future<bool> retrograderAdmin(String utilisateurId) async {
    if (!estAdministrateur) return false;

    final utilisateur = await _utilisateursRepository.obtenirUtilisateurParId(utilisateurId);
    if (utilisateur == null) return false;

    final nouveauxPrivileges = List<String>.from(utilisateur.privileges)
        ..remove('admin');

    return await modifierPrivileges(utilisateurId, nouveauxPrivileges);
  }

  // UI Design: Obtenir les initiales de l'utilisateur pour l'avatar
  String obtenirInitiales() {
    if (_utilisateurActuel == null) return '??';
    return '${_utilisateurActuel!.prenom[0]}${_utilisateurActuel!.nom[0]}';
  }

  // UI Design: Obtenir le nom complet de l'utilisateur
  String obtenirNomComplet() {
    if (_utilisateurActuel == null) return 'Utilisateur inconnu';
    return '${_utilisateurActuel!.prenom} ${_utilisateurActuel!.nom}';
  }
}