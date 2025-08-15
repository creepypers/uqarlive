// UI Design: Repository abstrait pour la gestion des utilisateurs
import '../entities/utilisateur.dart';

abstract class UtilisateursRepository {
  // UI Design: Authentification et gestion de session
  Future<Utilisateur?> authentifierUtilisateur(String email, String motDePasse);
  Future<Utilisateur?> obtenirUtilisateurActuel();
  Future<void> deconnecterUtilisateur();

  // UI Design: Gestion des comptes par les administrateurs
  Future<List<Utilisateur>> obtenirTousLesUtilisateurs();
  Future<List<Utilisateur>> rechercherUtilisateurs(String terme);
  Future<Utilisateur?> obtenirUtilisateurParId(String id);
  Future<Utilisateur?> obtenirUtilisateurParCodeEtudiant(String codeEtudiant);
  
  // UI Design: Modification des comptes
  Future<bool> modifierUtilisateur(Utilisateur utilisateur);
  Future<bool> changerStatutUtilisateur(String id, bool estActif);
  Future<bool> attribuerPrivileges(String id, List<String> privileges);
  Future<bool> supprimerUtilisateur(String id);

  // UI Design: Création de nouveaux comptes
  Future<bool> creerUtilisateur(Utilisateur utilisateur, String motDePasse);
  
  // UI Design: Statistiques pour le dashboard admin
  Future<Map<String, int>> obtenirStatistiquesUtilisateurs();
  Future<List<Utilisateur>> obtenirUtilisateursRecents(int limite);
  Future<List<Utilisateur>> obtenirUtilisateursActifs();
  
  // UI Design: Gestion des sessions et sécurité
  Future<void> mettreAJourDerniereConnexion(String id);
  Future<List<Utilisateur>> obtenirUtilisateursConnectes();
} 