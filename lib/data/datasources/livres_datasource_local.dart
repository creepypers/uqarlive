// UI Design: Datasource local pour les livres universitaires disponibles à l'échange
import '../models/livre_model.dart';

class LivresDatasourceLocal {
  // UI Design: Liste interne des livres avec gestion dynamique
  final List<LivreModel> _livres = [
    // Quelques livres d'exemple avec différents propriétaires
    LivreModel(
      id: '1',
      titre: 'Calcul Différentiel et Intégral',
      auteur: 'James Stewart',
      matiere: 'Mathématiques',
      anneeEtude: '1ère année',
      etatLivre: 'Très bon',
      proprietaire: 'Alexandre Martin',
      proprietaireId: 'etud_001', // Alexandre Martin
      coursAssocies: 'MAT-1000',
      description: 'Manuel complet avec exercices corrigés',
      edition: '7ème édition',
      dateAjout: DateTime.parse('2024-01-15'),
      estDisponible: true,
      imageUrl: null,
      motsClefs: ['calcul', 'mathématiques', 'intégrale', 'dérivée'],
      prix: 12.50,
    ),
    LivreModel(
      id: '2',
      titre: 'Physique Générale 1',
      auteur: 'Serway & Jewett',
      matiere: 'Physique',
      anneeEtude: '1ère année',
      etatLivre: 'Excellent',
      proprietaire: 'Sophie Gagnon',
      proprietaireId: 'etud_002', // Sophie Gagnon
      coursAssocies: 'PHY-1001',
      description: 'Tome 1 - Mécanique et thermodynamique',
      edition: '9ème édition',
      dateAjout: DateTime.parse('2024-01-18'),
      estDisponible: true,
      imageUrl: null,
      motsClefs: ['physique', 'mécanique', 'thermodynamique'],
      prix: 18.00,
    ),
    // Quelques livres pour Alexandre Martin (etud_001) pour les tests
    LivreModel(
      id: '101',
      titre: 'Introduction à l\'Algorithmique',
      auteur: 'Cormen, Leiserson, Rivest',
      matiere: 'Informatique',
      anneeEtude: '2ème année',
      etatLivre: 'Bon',
      proprietaire: 'Alexandre Martin',
      proprietaireId: 'etud_001',
      coursAssocies: 'INF-2010',
      description: 'Manuel de référence en algorithmique',
      edition: '3ème édition',
      dateAjout: DateTime.parse('2024-01-10'),
      estDisponible: true,
      imageUrl: null,
      motsClefs: ['algorithme', 'informatique', 'structure', 'données'],
      prix: 25.00,
    ),
    LivreModel(
      id: '102',
      titre: 'Algèbre Linéaire',
      auteur: 'Gilbert Strang',
      matiere: 'Mathématiques',
      anneeEtude: '2ème année',
      etatLivre: 'Très bon',
      proprietaire: 'Alexandre Martin',
      proprietaireId: 'etud_001',
      coursAssocies: 'MAT-2001',
      description: 'Cours complet d\'algèbre linéaire avec applications',
      edition: '4ème édition',
      dateAjout: DateTime.parse('2024-01-08'),
      estDisponible: false, // Actuellement échangé
      imageUrl: null,
      motsClefs: ['algèbre', 'linéaire', 'matrices', 'vecteurs'],
      prix: 22.50,
    ),
    LivreModel(
      id: '3',
      titre: 'Chimie Organique',
      auteur: 'Clayden',
      matiere: 'Chimie',
      anneeEtude: '2ème année',
      etatLivre: 'Bon',
      proprietaire: 'Sarah Bouchard',
      proprietaireId: 'etud_003',
      coursAssocies: 'CHM-2010',
      description: 'Livre de référence en chimie organique',
      edition: '2ème édition',
      dateAjout: DateTime.parse('2024-01-20'),
      estDisponible: true,
      imageUrl: null,
      motsClefs: ['chimie', 'organique', 'molécules', 'réactions'],
      prix: 20.99,
    ),
  ];

  // UI Design: Méthodes pour la gestion des livres
  Future<List<LivreModel>> obtenirTousLesLivres() async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_livres);
  }

  Future<List<LivreModel>> obtenirLivresParProprietaire(String proprietaireId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _livres.where((livre) => livre.proprietaireId == proprietaireId).toList();
  }

  Future<bool> ajouterLivre(LivreModel livre) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _livres.add(livre);
    return true;
  }

  Future<bool> modifierLivre(LivreModel livre) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _livres.indexWhere((l) => l.id == livre.id);
    if (index != -1) {
      _livres[index] = livre;
      return true;
    }
    return false;
  }

  Future<bool> supprimerLivre(String livreId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _livres.indexWhere((l) => l.id == livreId);
    if (index != -1) {
      _livres.removeAt(index);
      return true;
    }
    return false;
  }

  Future<LivreModel?> obtenirLivreParId(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _livres.firstWhere((livre) => livre.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<LivreModel>> rechercherLivres(String terme) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final termeLower = terme.toLowerCase();
    return _livres.where((livre) => 
      livre.titre.toLowerCase().contains(termeLower) ||
      livre.auteur.toLowerCase().contains(termeLower) ||
      livre.matiere.toLowerCase().contains(termeLower) ||
      (livre.coursAssocies?.toLowerCase().contains(termeLower) ?? false)
    ).toList();
  }

  Future<List<LivreModel>> obtenirLivresParMatiere(String matiere) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _livres.where((livre) => livre.matiere == matiere).toList();
  }

  Future<List<LivreModel>> obtenirLivresParEtat(String etat) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _livres.where((livre) => livre.etatLivre == etat).toList();
  }

  Future<List<LivreModel>> obtenirLivresParAnnee(String annee) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _livres.where((livre) => livre.anneeEtude == annee).toList();
  }

  Future<List<LivreModel>> obtenirLivresDisponibles() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _livres.where((livre) => livre.estDisponible).toList();
  }

  Future<List<LivreModel>> obtenirLivresParCours(String cours) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _livres.where((livre) => livre.coursAssocies == cours).toList();
  }

  // UI Design: Générer un nouvel ID unique pour les livres
  String genererIdLivre() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'livre_$timestamp';
  }
} 