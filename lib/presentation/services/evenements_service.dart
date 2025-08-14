// Clean Architecture: Service pour la gestion des événements
import '../../domain/entities/evenement.dart';
import '../../domain/repositories/evenements_repository.dart';
import '../../core/di/service_locator.dart';

class EvenementsService {
  late final EvenementsRepository _evenementsRepository;

  EvenementsService() {
    _evenementsRepository = ServiceLocator.obtenirService<EvenementsRepository>();
  }

  /// Récupère tous les événements
  Future<List<Evenement>> obtenirEvenements() async {
    try {
      return await _evenementsRepository.obtenirEvenements();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des événements: $e');
    }
  }

  /// Récupère les événements d'une association spécifique
  Future<List<Evenement>> obtenirEvenementsParAssociation(String associationId) async {
    try {
      return await _evenementsRepository.obtenirEvenementsParAssociation(associationId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des événements de l\'association: $e');
    }
  }

  /// Récupère un événement par son ID
  Future<Evenement?> obtenirEvenementParId(String id) async {
    try {
      return await _evenementsRepository.obtenirEvenementParId(id);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'événement: $e');
    }
  }

  /// Ajoute un nouvel événement
  Future<bool> ajouterEvenement(Evenement evenement) async {
    try {
      // Validation métier
      if (evenement.dateDebut.isAfter(evenement.dateFin)) {
        throw Exception('La date de début ne peut pas être après la date de fin');
      }

      if (evenement.capaciteMaximale != null && evenement.capaciteMaximale! <= 0) {
        throw Exception('La capacité maximale doit être supérieure à 0');
      }

      return await _evenementsRepository.ajouterEvenement(evenement);
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de l\'événement: $e');
    }
  }

  /// Met à jour un événement existant
  Future<bool> mettreAJourEvenement(Evenement evenement) async {
    try {
      // Validation métier
      if (evenement.dateDebut.isAfter(evenement.dateFin)) {
        throw Exception('La date de début ne peut pas être après la date de fin');
      }

      return await _evenementsRepository.mettreAJourEvenement(evenement);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'événement: $e');
    }
  }

  /// Supprime un événement
  Future<bool> supprimerEvenement(String id) async {
    try {
      return await _evenementsRepository.supprimerEvenement(id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'événement: $e');
    }
  }

  /// Récupère les événements à venir
  Future<List<Evenement>> obtenirEvenementsAVenir() async {
    try {
      return await _evenementsRepository.obtenirEvenementsAVenir();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des événements à venir: $e');
    }
  }

  /// Récupère les événements par type
  Future<List<Evenement>> obtenirEvenementsParType(String type) async {
    try {
      return await _evenementsRepository.obtenirEvenementsParType(type);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des événements par type: $e');
    }
  }

  /// Récupère les événements dans une période donnée
  Future<List<Evenement>> obtenirEvenementsParPeriode(DateTime debut, DateTime fin) async {
    try {
      return await _evenementsRepository.obtenirEvenementsParPeriode(debut, fin);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des événements par période: $e');
    }
  }

  /// Vérifie si un utilisateur peut s'inscrire à un événement
  Future<bool> peutSInscrire(String evenementId, String utilisateurId) async {
    try {
      return await _evenementsRepository.peutSInscrire(evenementId, utilisateurId);
    } catch (e) {
      throw Exception('Erreur lors de la vérification d\'inscription: $e');
    }
  }

  /// Inscrit un utilisateur à un événement
  Future<bool> inscrireUtilisateur(String evenementId, String utilisateurId) async {
    try {
      return await _evenementsRepository.inscrireUtilisateur(evenementId, utilisateurId);
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription à l\'événement: $e');
    }
  }

  /// Désinscrit un utilisateur d'un événement
  Future<bool> desinscrireUtilisateur(String evenementId, String utilisateurId) async {
    try {
      return await _evenementsRepository.desinscrireUtilisateur(evenementId, utilisateurId);
    } catch (e) {
      throw Exception('Erreur lors de la désinscription de l\'événement: $e');
    }
  }

  /// Crée un nouvel événement avec les paramètres fournis
  Future<Evenement> creerEvenement({
    required String titre,
    required String description,
    required String lieu,
    required String organisateur,
    required String associationId,
    required DateTime dateDebut,
    required DateTime dateFin,
    required String typeEvenement,
    required int capaciteMaximale,
  }) async {
    final evenement = Evenement(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID temporaire
      titre: titre,
      description: description,
      lieu: lieu,
      organisateur: organisateur,
      associationId: associationId,
      dateDebut: dateDebut,
      dateFin: dateFin,
      typeEvenement: typeEvenement,
      capaciteMaximale: capaciteMaximale,
      nombreInscrits: 0,
      dateCreation: DateTime.now(),
    );

    final succes = await ajouterEvenement(evenement);
    if (succes) {
      return evenement;
    } else {
      throw Exception('Impossible de créer l\'événement');
    }
  }
}
