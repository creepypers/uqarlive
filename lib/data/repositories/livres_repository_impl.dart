import '../../domain/entities/livre.dart';
import '../../domain/repositories/livres_repository.dart';
import '../datasources/livres_datasource_local.dart';
import '../models/livre_model.dart';

// UI Design: Implémentation du repository des livres - couche data
class LivresRepositoryImpl implements LivresRepository {
  final LivresDatasourceLocal _datasourceLocal;

  LivresRepositoryImpl(this._datasourceLocal);

  @override
  Future<List<Livre>> obtenirTousLesLivres() async {
    try {
      final livresMap = _datasourceLocal.obtenirTousLesLivres();
      return livresMap
          .map((map) => LivreModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      print('Erreur lors de l\'obtention des livres: $e');
      return [];
    }
  }

  @override
  Future<Livre?> obtenirLivreParId(String id) async {
    try {
      final livreMap = _datasourceLocal.obtenirLivreParId(id);
      if (livreMap != null) {
        return LivreModel.fromMap(livreMap).toEntity();
      }
      return null;
    } catch (e) {
      print('Erreur lors de l\'obtention du livre par ID: $e');
      return null;
    }
  }

  @override
  Future<List<Livre>> obtenirLivresParMatiere(String matiere) async {
    try {
      final livresMap = _datasourceLocal.obtenirLivresParMatiere(matiere);
      return livresMap
          .map((map) => LivreModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      print('Erreur lors de l\'obtention des livres par matière: $e');
      return [];
    }
  }

  @override
  Future<List<Livre>> obtenirLivresParEtat(String etat) async {
    try {
      final livresMap = _datasourceLocal.obtenirLivresParEtat(etat);
      return livresMap
          .map((map) => LivreModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      print('Erreur lors de l\'obtention des livres par état: $e');
      return [];
    }
  }

  @override
  Future<List<Livre>> obtenirLivresParAnnee(String annee) async {
    try {
      final livresMap = _datasourceLocal.obtenirLivresParAnnee(annee);
      return livresMap
          .map((map) => LivreModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      print('Erreur lors de l\'obtention des livres par année: $e');
      return [];
    }
  }

  @override
  Future<List<Livre>> rechercherLivres(String recherche) async {
    try {
      final livresMap = _datasourceLocal.rechercherLivres(recherche);
      return livresMap
          .map((map) => LivreModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      print('Erreur lors de la recherche des livres: $e');
      return [];
    }
  }

  @override
  Future<List<Livre>> filtrerLivres({
    String? matiere,
    String? etat,
    String? annee,
    String? recherche,
  }) async {
    try {
      List<Map<String, dynamic>> livresMap = _datasourceLocal.obtenirTousLesLivres();

      // Filtrer par matière
      if (matiere != null && matiere != 'Toutes') {
        livresMap = livresMap.where((livre) => livre['matiere'] == matiere).toList();
      }

      // Filtrer par état
      if (etat != null && etat != 'Tous') {
        livresMap = livresMap.where((livre) => livre['etatLivre'] == etat).toList();
      }

      // Filtrer par année
      if (annee != null && annee != 'Toutes') {
        livresMap = livresMap.where((livre) => livre['anneeEtude'] == annee).toList();
      }

      // Filtrer par recherche
      if (recherche != null && recherche.isNotEmpty) {
        final rechercheLowerCase = recherche.toLowerCase();
        livresMap = livresMap.where((livre) {
          return livre['titre'].toLowerCase().contains(rechercheLowerCase) ||
              livre['auteur'].toLowerCase().contains(rechercheLowerCase) ||
              livre['matiere'].toLowerCase().contains(rechercheLowerCase) ||
              livre['coursAssocies'].toLowerCase().contains(rechercheLowerCase);
        }).toList();
      }

      return livresMap
          .map((map) => LivreModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      print('Erreur lors du filtrage des livres: $e');
      return [];
    }
  }

  @override
  Future<bool> ajouterLivre(Livre livre) async {
    try {
      // TODO: Implémenter l'ajout d'un livre (nécessite un datasource modifiable)
      print('Ajout du livre: ${livre.titre}');
      return true;
    } catch (e) {
      print('Erreur lors de l\'ajout du livre: $e');
      return false;
    }
  }

  @override
  Future<bool> modifierLivre(Livre livre) async {
    try {
      // TODO: Implémenter la modification d'un livre (nécessite un datasource modifiable)
      print('Modification du livre: ${livre.titre}');
      return true;
    } catch (e) {
      print('Erreur lors de la modification du livre: $e');
      return false;
    }
  }

  @override
  Future<bool> supprimerLivre(String id) async {
    try {
      // TODO: Implémenter la suppression d'un livre (nécessite un datasource modifiable)
      print('Suppression du livre avec ID: $id');
      return true;
    } catch (e) {
      print('Erreur lors de la suppression du livre: $e');
      return false;
    }
  }

  @override
  Future<bool> marquerLivreEchange(String id) async {
    try {
      // TODO: Implémenter le marquage d'un livre comme échangé
      print('Marquage du livre comme échangé: $id');
      return true;
    } catch (e) {
      print('Erreur lors du marquage du livre comme échangé: $e');
      return false;
    }
  }

  @override
  Future<bool> marquerLivreDisponible(String id) async {
    try {
      // TODO: Implémenter le marquage d'un livre comme disponible
      print('Marquage du livre comme disponible: $id');
      return true;
    } catch (e) {
      print('Erreur lors du marquage du livre comme disponible: $e');
      return false;
    }
  }

  @override
  Future<List<Livre>> obtenirLivresParProprietaire(String proprietaire) async {
    try {
      final livresMap = _datasourceLocal.obtenirTousLesLivres();
      final livresFiltres = livresMap
          .where((livre) => livre['proprietaire'] == proprietaire)
          .toList();
      return livresFiltres
          .map((map) => LivreModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      print('Erreur lors de l\'obtention des livres par propriétaire: $e');
      return [];
    }
  }

  @override
  Future<List<Livre>> obtenirLivresDisponibles() async {
    try {
      final livresMap = _datasourceLocal.obtenirTousLesLivres();
      final livresDisponibles = livresMap
          .where((livre) => livre['estDisponible'] == true)
          .toList();
      return livresDisponibles
          .map((map) => LivreModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      print('Erreur lors de l\'obtention des livres disponibles: $e');
      return [];
    }
  }

  @override
  Future<List<Livre>> obtenirLivresParCours(String cours) async {
    try {
      final livresMap = _datasourceLocal.obtenirTousLesLivres();
      final livresCours = livresMap
          .where((livre) => livre['coursAssocies'] == cours)
          .toList();
      return livresCours
          .map((map) => LivreModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      print('Erreur lors de l\'obtention des livres par cours: $e');
      return [];
    }
  }
} 