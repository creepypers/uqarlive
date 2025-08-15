// UI Design: Implémentation du repository utilisateurs
import '../../domain/entities/utilisateur.dart';
import '../../domain/repositories/utilisateurs_repository.dart';
import '../datasources/internal/utilisateurs_datasource_local.dart';
import '../models/utilisateur_model.dart';

class UtilisateursRepositoryImpl implements UtilisateursRepository {
  final UtilisateursDatasourceLocal _datasource;

  const UtilisateursRepositoryImpl(this._datasource);

  @override
  Future<Utilisateur?> authentifierUtilisateur(String email, String motDePasse) async {
    final utilisateurModel = await _datasource.authentifierUtilisateur(email, motDePasse);
    return utilisateurModel?.toEntity();
  }

  @override
  Future<Utilisateur?> obtenirUtilisateurActuel() async {
    final utilisateurModel = await _datasource.obtenirUtilisateurActuel();
    return utilisateurModel?.toEntity();
  }

  @override
  Future<void> deconnecterUtilisateur() async {
    await _datasource.deconnecterUtilisateur();
  }

  @override
  Future<List<Utilisateur>> obtenirTousLesUtilisateurs() async {
    final utilisateursModels = await _datasource.obtenirTousLesUtilisateurs();
    return utilisateursModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Utilisateur>> rechercherUtilisateurs(String terme) async {
    final utilisateursModels = await _datasource.rechercherUtilisateurs(terme);
    return utilisateursModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Utilisateur?> obtenirUtilisateurParId(String id) async {
    final utilisateurModel = await _datasource.obtenirUtilisateurParId(id);
    return utilisateurModel?.toEntity();
  }

  @override
  Future<Utilisateur?> obtenirUtilisateurParCodeEtudiant(String codeEtudiant) async {
    final utilisateurModel = await _datasource.obtenirUtilisateurParCodeEtudiant(codeEtudiant);
    return utilisateurModel?.toEntity();
  }

  @override
  Future<bool> modifierUtilisateur(Utilisateur utilisateur) async {
    final utilisateurModel = UtilisateurModel.fromEntity(utilisateur);
    return await _datasource.modifierUtilisateur(utilisateurModel);
  }

  @override
  Future<bool> changerStatutUtilisateur(String id, bool estActif) async {
    return await _datasource.changerStatutUtilisateur(id, estActif);
  }

  @override
  Future<bool> attribuerPrivileges(String id, List<String> privileges) async {
    return await _datasource.attribuerPrivileges(id, privileges);
  }

  @override
  Future<bool> supprimerUtilisateur(String id) async {
    return await _datasource.supprimerUtilisateur(id);
  }

  @override
  Future<bool> creerUtilisateur(Utilisateur utilisateur, String motDePasse) async {
    final utilisateurModel = UtilisateurModel.fromEntity(utilisateur);
    return await _datasource.creerUtilisateur(utilisateurModel, motDePasse);
  }

  @override
  Future<Map<String, int>> obtenirStatistiquesUtilisateurs() async {
    return await _datasource.obtenirStatistiquesUtilisateurs();
  }

  @override
  Future<List<Utilisateur>> obtenirUtilisateursRecents(int limite) async {
    final utilisateursModels = await _datasource.obtenirUtilisateursRecents(limite);
    return utilisateursModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Utilisateur>> obtenirUtilisateursActifs() async {
    final utilisateursModels = await _datasource.obtenirUtilisateursActifs();
    return utilisateursModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> mettreAJourDerniereConnexion(String id) async {
    await _datasource.mettreAJourDerniereConnexion(id);
  }

  @override
  Future<List<Utilisateur>> obtenirUtilisateursConnectes() async {
    final utilisateursModels = await _datasource.obtenirUtilisateursConnectes();
    return utilisateursModels.map((model) => model.toEntity()).toList();
  }
} 