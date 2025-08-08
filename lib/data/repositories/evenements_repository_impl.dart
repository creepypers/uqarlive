import '../../domain/entities/evenement.dart';
import '../../domain/repositories/evenements_repository.dart';
import '../datasources/evenements_datasource_local.dart';

class EvenementsRepositoryImpl implements EvenementsRepository {
  final EvenementsDatasourceLocal _datasource;

  EvenementsRepositoryImpl(this._datasource);

  @override
  Future<List<Evenement>> obtenirEvenements() {
    return _datasource.obtenirTousLesEvenements();
  }

  @override
  Future<List<Evenement>> obtenirEvenementsAVenir() {
    return _datasource.obtenirEvenementsAVenir();
  }

  @override
  Future<List<Evenement>> obtenirEvenementsParType(String type) {
    return _datasource.obtenirEvenementsParType(type);
  }

  @override
  Future<Evenement?> obtenirEvenementParId(String id) {
    return _datasource.obtenirEvenementParId(id);
  }

  Future<List<Evenement>> rechercherEvenements(String terme) {
    return _datasource.rechercherEvenements(terme);
  }

  

  @override
  Future<List<Evenement>> obtenirEvenementsParAssociation(String associationId) async {
    return _datasource.obtenirEvenementsParAssociation(associationId);
  }

  @override
  Future<Evenement> ajouterEvenement(Evenement evenement) async {
    return _datasource.ajouterEvenement(evenement);
  }

  @override
  Future<Evenement> mettreAJourEvenement(Evenement evenement) async {
    return _datasource.mettreAJourEvenement(evenement);
  }

  @override
  Future<bool> supprimerEvenement(String id) async {
    return _datasource.supprimerEvenement(id);
  }

  @override
  Future<List<Evenement>> obtenirEvenementsParPeriode(DateTime debut, DateTime fin) async {
    return _datasource.obtenirEvenementsParPeriode(debut, fin);
  }

  @override
  Future<bool> peutSInscrire(String evenementId, String utilisateurId) async {
    return _datasource.peutSInscrire(evenementId, utilisateurId);
  }

  @override
  Future<bool> inscrireUtilisateur(String evenementId, String utilisateurId) async {
    return _datasource.inscrireUtilisateur(evenementId, utilisateurId);
  }

  @override
  Future<bool> desinscrireUtilisateur(String evenementId, String utilisateurId) async {
    return _datasource.desinscrireUtilisateur(evenementId, utilisateurId);
  }
} 