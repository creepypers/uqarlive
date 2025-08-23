import '../entities/utilisateur.dart';
abstract class UtilisateursRepository {
  Future<Utilisateur?> authentifierUtilisateur(String email, String motDePasse);
  Future<Utilisateur?> obtenirUtilisateurActuel();
  Future<void> deconnecterUtilisateur();
  Future<List<Utilisateur>> obtenirTousLesUtilisateurs();
  Future<List<Utilisateur>> rechercherUtilisateurs(String terme);
  Future<Utilisateur?> obtenirUtilisateurParId(String id);
  Future<Utilisateur?> obtenirUtilisateurParCodeEtudiant(String codeEtudiant);
  Future<bool> modifierUtilisateur(Utilisateur utilisateur);
  Future<bool> changerStatutUtilisateur(String id, bool estActif);
  Future<bool> attribuerPrivileges(String id, List<String> privileges);
  Future<bool> supprimerUtilisateur(String id);
  Future<bool> creerUtilisateur(Utilisateur utilisateur, String motDePasse);
  Future<Map<String, int>> obtenirStatistiquesUtilisateurs();
  Future<List<Utilisateur>> obtenirUtilisateursRecents(int limite);
  Future<List<Utilisateur>> obtenirUtilisateursActifs();
  Future<void> mettreAJourDerniereConnexion(String id);
  Future<List<Utilisateur>> obtenirUtilisateursConnectes();
} 