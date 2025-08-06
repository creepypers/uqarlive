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
      final livresModels = await _datasourceLocal.obtenirTousLesLivres();
      return livresModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Livre?> obtenirLivreParId(String id) async {
    try {
      final livreModel = await _datasourceLocal.obtenirLivreParId(id);
      return livreModel?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Livre>> obtenirLivresParMatiere(String matiere) async {
    try {
      final livresModels = await _datasourceLocal.obtenirLivresParMatiere(matiere);
      return livresModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Livre>> obtenirLivresParEtat(String etat) async {
    try {
      final livresModels = await _datasourceLocal.obtenirLivresParEtat(etat);
      return livresModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Livre>> obtenirLivresParAnnee(String annee) async {
    try {
      final livresModels = await _datasourceLocal.obtenirLivresParAnnee(annee);
      return livresModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Livre>> rechercherLivres(String recherche) async {
    try {
      final livresModels = await _datasourceLocal.rechercherLivres(recherche);
      return livresModels.map((model) => model.toEntity()).toList();
    } catch (e) {
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
      List<LivreModel> livresModels = await _datasourceLocal.obtenirTousLesLivres();

      // Filtrer par matière
      if (matiere != null && matiere != 'Toutes') {
        livresModels = livresModels.where((livre) => livre.matiere == matiere).toList();
      }

      // Filtrer par état
      if (etat != null && etat != 'Tous') {
        livresModels = livresModels.where((livre) => livre.etatLivre == etat).toList();
      }

      // Filtrer par année
      if (annee != null && annee != 'Toutes') {
        livresModels = livresModels.where((livre) => livre.anneeEtude == annee).toList();
      }

      // Filtrer par recherche
      if (recherche != null && recherche.isNotEmpty) {
        final rechercheLowerCase = recherche.toLowerCase();
        livresModels = livresModels.where((livre) {
          return livre.titre.toLowerCase().contains(rechercheLowerCase) ||
              livre.auteur.toLowerCase().contains(rechercheLowerCase) ||
              livre.matiere.toLowerCase().contains(rechercheLowerCase) ||
              (livre.coursAssocies?.toLowerCase().contains(rechercheLowerCase) ?? false);
        }).toList();
      }

      return livresModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> ajouterLivre(Livre livre) async {
    try {
      final livreModel = LivreModel.fromEntity(livre);
      return await _datasourceLocal.ajouterLivre(livreModel);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> modifierLivre(Livre livre) async {
    try {
      final livreModel = LivreModel.fromEntity(livre);
      return await _datasourceLocal.modifierLivre(livreModel);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> supprimerLivre(String id) async {
    try {
      return await _datasourceLocal.supprimerLivre(id);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> marquerLivreEchange(String id) async {
    try {
      final livre = await _datasourceLocal.obtenirLivreParId(id);
      if (livre != null) {
        final livreModifie = livre.copyWith(estDisponible: false);
        return await _datasourceLocal.modifierLivre(livreModifie);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> marquerLivreDisponible(String id) async {
    try {
      final livre = await _datasourceLocal.obtenirLivreParId(id);
      if (livre != null) {
        final livreModifie = livre.copyWith(estDisponible: true);
        return await _datasourceLocal.modifierLivre(livreModifie);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Livre>> obtenirLivresParProprietaire(String proprietaire) async {
    try {
      // UI Design: Utiliser la nouvelle méthode qui filtre par ID
      final livresModels = await _datasourceLocal.obtenirLivresParProprietaire(proprietaire);
      return livresModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Livre>> obtenirLivresDisponibles() async {
    try {
      final livresModels = await _datasourceLocal.obtenirLivresDisponibles();
      return livresModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Livre>> obtenirLivresParCours(String cours) async {
    try {
      final livresModels = await _datasourceLocal.obtenirLivresParCours(cours);
      return livresModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      return [];
    }
  }
}