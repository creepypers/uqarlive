import '../../../domain/entities/evenement.dart';
class EvenementsDatasourceLocal {
  static final List<Evenement> _evenementsStockes = [];
  static bool _donneesSeedees = false;
  static final List<Evenement> _evenementsParDefaut = [
    Evenement(
      id: '1',
      titre: 'Conférence Intelligence Artificielle',
      description: 'Une conférence sur les dernières avancées en IA et leur impact sur l\'industrie.',
      typeEvenement: 'conference',
      lieu: 'Amphithéâtre A-101',
      organisateur: 'Association des étudiants en informatique',
      associationId: 'asso_001', // AEI
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
      associationId: 'asso_001', // AEI
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
      associationId: 'asso_004', // AGE
      dateDebut: DateTime.now().add(const Duration(days: 3)),
      dateFin: DateTime.now().add(const Duration(days: 3, hours: 3)),
      estGratuit: true,
      inscriptionRequise: false,
      dateCreation: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];
  void _initialiserDonnees() {
    if (!_donneesSeedees && _evenementsStockes.isEmpty) {
      // Charger les données par défaut seulement si aucun événement n'existe
      _evenementsStockes.addAll(_evenementsParDefaut);
      _donneesSeedees = true;
    }
  }
  Future<List<Evenement>> obtenirTousLesEvenements() async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 500)); // Simulation latence
    return List.from(_evenementsStockes);
  }
  Future<List<Evenement>> obtenirEvenementsAVenir() async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 300));
    final maintenant = DateTime.now();
    return _evenementsStockes.where((event) => event.dateDebut.isAfter(maintenant)).toList();
  }
  Future<List<Evenement>> obtenirEvenementsParType(String type) async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 300));
    return _evenementsStockes.where((event) => event.typeEvenement == type).toList();
  }
  Future<Evenement?> obtenirEvenementParId(String id) async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _evenementsStockes.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }
  Future<List<Evenement>> rechercherEvenements(String terme) async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 400));
    final termeMin = terme.toLowerCase();
    return _evenementsStockes.where((event) => 
      event.titre.toLowerCase().contains(termeMin) ||
      event.description.toLowerCase().contains(termeMin) ||
      event.organisateur.toLowerCase().contains(termeMin)
    ).toList();
  }
  Future<List<Evenement>> obtenirEvenementsParAssociation(String associationId) async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 300));
    // Utiliser le champ associationId pour filtrer
    return _evenementsStockes.where((e) => e.associationId == associationId).toList();
  }
  Future<Evenement> ajouterEvenement(Evenement evenement) async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 200));
    _evenementsStockes.add(evenement);
    return evenement;
  }
  Future<Evenement> mettreAJourEvenement(Evenement evenement) async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _evenementsStockes.indexWhere((e) => e.id == evenement.id);
    if (index != -1) {
      _evenementsStockes[index] = evenement;
    } else {
      _evenementsStockes.add(evenement);
    }
    return evenement;
  }
  Future<bool> supprimerEvenement(String id) async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 150));
    final before = _evenementsStockes.length;
    _evenementsStockes.removeWhere((e) => e.id == id);
    return _evenementsStockes.length < before;
  }
  Future<List<Evenement>> obtenirEvenementsParPeriode(DateTime debut, DateTime fin) async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 250));
    return _evenementsStockes.where((e) => !e.dateDebut.isAfter(fin) && !e.dateFin.isBefore(debut)).toList();
  }
  Future<bool> peutSInscrire(String evenementId, String utilisateurId) async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 120));
    final ev = _evenementsStockes.firstWhere((e) => e.id == evenementId, orElse: () => throw Exception('Événement introuvable'));
    if (!ev.inscriptionRequise) return true;
    if (ev.capaciteMaximale == null) return true;
    return ev.nombreInscrits < ev.capaciteMaximale!;
  }
  Future<bool> inscrireUtilisateur(String evenementId, String utilisateurId) async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _evenementsStockes.indexWhere((e) => e.id == evenementId);
    if (index == -1) return false;
    final ev = _evenementsStockes[index];
    if (ev.capaciteMaximale != null && ev.nombreInscrits >= ev.capaciteMaximale!) return false;
    _evenementsStockes[index] = ev.copyWith(nombreInscrits: ev.nombreInscrits + 1);
    return true;
  }
  Future<bool> desinscrireUtilisateur(String evenementId, String utilisateurId) async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _evenementsStockes.indexWhere((e) => e.id == evenementId);
    if (index == -1) return false;
    final ev = _evenementsStockes[index];
    if (ev.nombreInscrits <= 0) return false;
    _evenementsStockes[index] = ev.copyWith(nombreInscrits: ev.nombreInscrits - 1);
    return true;
  }
  static void effacerTousLesEvenements() {
    _evenementsStockes.clear();
    _donneesSeedees = false;
  }
  static void rechargerDonneesParDefaut() {
    _evenementsStockes.clear();
    _donneesSeedees = false;
  }
  static int get nombreEvenements => _evenementsStockes.length;
} 