import '../../domain/entities/evenement.dart';

class EvenementsDatasourceLocal {
  // UI Design: Données d'exemple pour les événements
  static final List<Evenement> _evenements = [
    Evenement(
      id: '1',
      titre: 'Conférence Intelligence Artificielle',
      description: 'Une conférence sur les dernières avancées en IA et leur impact sur l\'industrie.',
      typeEvenement: 'conference',
      lieu: 'Amphithéâtre A-101',
      organisateur: 'Association des étudiants en informatique',
      dateDebut: DateTime.now().add(const Duration(days: 15)),
      dateFin: DateTime.now().add(const Duration(days: 15, hours: 3)),
      estGratuit: true,
      inscriptionRequise: true,
      capaciteMaximale: 100,
      nombreInscrits: 45,
      dateCreation: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Evenement(
      id: '2',
      titre: 'Atelier Développement Mobile',
      description: 'Apprenez à développer des applications mobiles avec Flutter.',
      typeEvenement: 'atelier',
      lieu: 'Laboratoire informatique B-205',
      organisateur: 'Club de programmation UQAR',
      dateDebut: DateTime.now().add(const Duration(days: 7)),
      dateFin: DateTime.now().add(const Duration(days: 7, hours: 4)),
      estGratuit: false,
      prix: 15.0,
      inscriptionRequise: true,
      capaciteMaximale: 25,
      nombreInscrits: 18,
      dateCreation: DateTime.now().subtract(const Duration(days: 20)),
    ),
    Evenement(
      id: '3',
      titre: 'Soirée Networking',
      description: 'Rencontrez des professionnels de l\'industrie et élargissez votre réseau.',
      typeEvenement: 'social',
      lieu: 'Salle des étudiants',
      organisateur: 'Association générale des étudiants',
      dateDebut: DateTime.now().add(const Duration(days: 3)),
      dateFin: DateTime.now().add(const Duration(days: 3, hours: 3)),
      estGratuit: true,
      inscriptionRequise: false,
      dateCreation: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  // UI Design: Récupérer tous les événements
  Future<List<Evenement>> obtenirTousLesEvenements() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulation latence
    return List.from(_evenements);
  }

  // UI Design: Récupérer les événements à venir
  Future<List<Evenement>> obtenirEvenementsAVenir() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final maintenant = DateTime.now();
    return _evenements.where((event) => event.dateDebut.isAfter(maintenant)).toList();
  }

  // UI Design: Récupérer les événements par type
  Future<List<Evenement>> obtenirEvenementsParType(String type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _evenements.where((event) => event.typeEvenement == type).toList();
  }

  // UI Design: Récupérer un événement par son ID
  Future<Evenement?> obtenirEvenementParId(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _evenements.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  // UI Design: Rechercher des événements
  Future<List<Evenement>> rechercherEvenements(String terme) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final termeMin = terme.toLowerCase();
    return _evenements.where((event) => 
      event.titre.toLowerCase().contains(termeMin) ||
      event.description.toLowerCase().contains(termeMin) ||
      event.organisateur.toLowerCase().contains(termeMin)
    ).toList();
  }

  // Clean Architecture: Récupérer par association (simulation via organisateur)
  Future<List<Evenement>> obtenirEvenementsParAssociation(String associationIdOuNom) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Hypothèse: on identifie l'association via le champ organisateur (nom)
    return _evenements.where((e) => e.organisateur == associationIdOuNom).toList();
  }

  // Clean Architecture: Ajouter un événement
  Future<Evenement> ajouterEvenement(Evenement evenement) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _evenements.add(evenement);
    return evenement;
  }

  // Clean Architecture: Mettre à jour un événement
  Future<Evenement> mettreAJourEvenement(Evenement evenement) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _evenements.indexWhere((e) => e.id == evenement.id);
    if (index != -1) {
      _evenements[index] = evenement;
    } else {
      _evenements.add(evenement);
    }
    return evenement;
  }

  // Clean Architecture: Supprimer un événement
  Future<bool> supprimerEvenement(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final before = _evenements.length;
    _evenements.removeWhere((e) => e.id == id);
    return _evenements.length < before;
  }

  // Clean Architecture: Récupérer par période
  Future<List<Evenement>> obtenirEvenementsParPeriode(DateTime debut, DateTime fin) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _evenements.where((e) => !e.dateDebut.isAfter(fin) && !e.dateFin.isBefore(debut)).toList();
  }

  // Clean Architecture: Gestion des inscriptions
  Future<bool> peutSInscrire(String evenementId, String utilisateurId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final ev = _evenements.firstWhere((e) => e.id == evenementId, orElse: () => throw Exception('Événement introuvable'));
    if (!ev.inscriptionRequise) return true;
    if (ev.capaciteMaximale == null) return true;
    return ev.nombreInscrits < ev.capaciteMaximale!;
  }

  Future<bool> inscrireUtilisateur(String evenementId, String utilisateurId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _evenements.indexWhere((e) => e.id == evenementId);
    if (index == -1) return false;
    final ev = _evenements[index];
    if (ev.capaciteMaximale != null && ev.nombreInscrits >= ev.capaciteMaximale!) return false;
    _evenements[index] = ev.copyWith(nombreInscrits: ev.nombreInscrits + 1);
    return true;
  }

  Future<bool> desinscrireUtilisateur(String evenementId, String utilisateurId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _evenements.indexWhere((e) => e.id == evenementId);
    if (index == -1) return false;
    final ev = _evenements[index];
    if (ev.nombreInscrits <= 0) return false;
    _evenements[index] = ev.copyWith(nombreInscrits: ev.nombreInscrits - 1);
    return true;
  }
} 