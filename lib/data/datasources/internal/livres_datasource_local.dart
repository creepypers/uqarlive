import '../../models/livre_model.dart';
class LivresDatasourceLocal {
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
    // Ajout de 10 livres supplémentaires pour atteindre 15 livres
    LivreModel(
      id: '4',
      titre: 'Biologie Cellulaire',
      auteur: 'Alberts et al.',
      matiere: 'Biologie',
      anneeEtude: '1ère année',
      etatLivre: 'Excellent',
      proprietaire: 'Marie-Claude Tremblay',
      proprietaireId: 'etud_004',
      coursAssocies: 'BIO-1000',
      description: 'Manuel de biologie cellulaire moderne',
      edition: '6ème édition',
      dateAjout: DateTime.parse('2024-01-22'),
      estDisponible: true,
      imageUrl: null,
      motsClefs: ['biologie', 'cellule', 'molécule', 'génétique'],
      prix: 35.00,
    ),
    LivreModel(
      id: '5',
      titre: 'Économie Microéconomique',
      auteur: 'Pindyck & Rubinfeld',
      matiere: 'Économie',
      anneeEtude: '1ère année',
      etatLivre: 'Très bon',
      proprietaire: 'Jean-François Dubois',
      proprietaireId: 'etud_005',
      coursAssocies: 'ECO-1000',
      description: 'Principes de microéconomie',
      edition: '8ème édition',
      dateAjout: DateTime.parse('2024-01-25'),
      estDisponible: true,
      imageUrl: null,
      motsClefs: ['économie', 'microéconomie', 'marché', 'prix'],
      prix: 28.50,
    ),
    LivreModel(
      id: '6',
      titre: 'Psychologie Cognitive',
      auteur: 'Sternberg',
      matiere: 'Psychologie',
      anneeEtude: '2ème année',
      etatLivre: 'Bon',
      proprietaire: 'Émilie Lavoie',
      proprietaireId: 'etud_006',
      coursAssocies: 'PSY-2000',
      description: 'Introduction à la psychologie cognitive',
      edition: '5ème édition',
      dateAjout: DateTime.parse('2024-01-28'),
      estDisponible: true,
      imageUrl: null,
      motsClefs: ['psychologie', 'cognition', 'mémoire', 'attention'],
      prix: 32.00,
    ),
    LivreModel(
      id: '7',
      titre: 'Géographie Physique',
      auteur: 'Strahler',
      matiere: 'Géographie',
      anneeEtude: '1ère année',
      etatLivre: 'Excellent',
      proprietaire: 'Pierre Moreau',
      proprietaireId: 'etud_007',
      coursAssocies: 'GEO-1000',
      description: 'Les systèmes de la nature',
      edition: '4ème édition',
      dateAjout: DateTime.parse('2024-01-30'),
      estDisponible: true,
      imageUrl: null,
      motsClefs: ['géographie', 'physique', 'climat', 'relief'],
      prix: 26.75,
    ),
    LivreModel(
      id: '8',
      titre: 'Histoire du Québec',
      auteur: 'Linteau et al.',
      matiere: 'Histoire',
      anneeEtude: '1ère année',
      etatLivre: 'Très bon',
      proprietaire: 'Isabelle Roy',
      proprietaireId: 'etud_008',
      coursAssocies: 'HIS-1000',
      description: 'Histoire du Québec contemporain',
      edition: '3ème édition',
      dateAjout: DateTime.parse('2024-02-01'),
      estDisponible: true,
      imageUrl: null,
      motsClefs: ['histoire', 'Québec', 'Canada', 'société'],
      prix: 24.00,
    ),
    LivreModel(
      id: '9',
      titre: 'Sociologie Générale',
      auteur: 'Giddens',
      matiere: 'Sociologie',
      anneeEtude: '1ère année',
      etatLivre: 'Bon',
      proprietaire: 'Marc-André Gagnon',
      proprietaireId: 'etud_009',
      coursAssocies: 'SOC-1000',
      description: 'Introduction à la sociologie',
      edition: '7ème édition',
      dateAjout: DateTime.parse('2024-02-03'),
      estDisponible: true,
      imageUrl: null,
      motsClefs: ['sociologie', 'société', 'culture', 'institutions'],
      prix: 30.00,
    ),
    LivreModel(
      id: '10',
      titre: 'Philosophie Éthique',
      auteur: 'Rachels',
      matiere: 'Philosophie',
      anneeEtude: '2ème année',
      etatLivre: 'Excellent',
      proprietaire: 'Sophie Deschamps',
      proprietaireId: 'etud_010',
      coursAssocies: 'PHI-2000',
      description: 'Éléments de philosophie morale',
      edition: '6ème édition',
      dateAjout: DateTime.parse('2024-02-05'),
      estDisponible: true,
      imageUrl: null,
      motsClefs: ['philosophie', 'éthique', 'morale', 'valeurs'],
      prix: 27.50,
    ),
    LivreModel(
      id: '11',
      titre: 'Linguistique Générale',
      auteur: 'Fromkin et al.',
      matiere: 'Linguistique',
      anneeEtude: '2ème année',
      etatLivre: 'Très bon',
      proprietaire: 'Nicolas Bouchard',
      proprietaireId: 'etud_011',
      coursAssocies: 'LIN-2000',
      description: 'Introduction à la linguistique',
      edition: '8ème édition',
      dateAjout: DateTime.parse('2024-02-07'),
      estDisponible: true,
      imageUrl: null,
      motsClefs: ['linguistique', 'langue', 'grammaire', 'phonétique'],
      prix: 29.99,
    ),
    LivreModel(
      id: '12',
      titre: 'Statistiques Appliquées',
      auteur: 'Moore & McCabe',
      matiere: 'Statistiques',
      anneeEtude: '2ème année',
      etatLivre: 'Bon',
      proprietaire: 'Alexandre Martin',
      proprietaireId: 'etud_001',
      coursAssocies: 'STA-2000',
      description: 'Introduction à la pratique des statistiques',
      edition: '5ème édition',
      dateAjout: DateTime.parse('2024-02-10'),
      estDisponible: true,
      imageUrl: null,
      motsClefs: ['statistiques', 'probabilité', 'inférence', 'données'],
      prix: 33.00,
    ),
    LivreModel(
      id: '13',
      titre: 'Gestion des Ressources Humaines',
      auteur: 'Dessler',
      matiere: 'Gestion',
      anneeEtude: '3ème année',
      etatLivre: 'Excellent',
      proprietaire: 'Marie-Claude Tremblay',
      proprietaireId: 'etud_004',
      coursAssocies: 'GES-3000',
      description: 'Fondements de la GRH',
      edition: '4ème édition',
      dateAjout: DateTime.parse('2024-02-12'),
      estDisponible: true,
      imageUrl: null,
      motsClefs: ['gestion', 'ressources humaines', 'personnel', 'organisation'],
      prix: 31.50,
    ),
    LivreModel(
      id: '14',
      titre: 'Marketing Stratégique',
      auteur: 'Kotler & Keller',
      matiere: 'Marketing',
      anneeEtude: '3ème année',
      etatLivre: 'Très bon',
      proprietaire: 'Jean-François Dubois',
      proprietaireId: 'etud_005',
      coursAssocies: 'MAR-3000',
      description: 'Principes du marketing',
      edition: '15ème édition',
      dateAjout: DateTime.parse('2024-02-15'),
      estDisponible: true,
      imageUrl: null,
      motsClefs: ['marketing', 'stratégie', 'consommateur', 'marque'],
      prix: 45.00,
    ),
    LivreModel(
      id: '15',
      titre: 'Droit Commercial',
      auteur: 'Lluelles & Moore',
      matiere: 'Droit',
      anneeEtude: '2ème année',
      etatLivre: 'Bon',
      proprietaire: 'Émilie Lavoie',
      proprietaireId: 'etud_006',
      coursAssocies: 'DRO-2000',
      description: 'Droit des affaires au Québec',
      edition: '6ème édition',
      dateAjout: DateTime.parse('2024-02-18'),
      estDisponible: true,
      imageUrl: null,
      motsClefs: ['droit', 'commercial', 'affaires', 'contrat'],
      prix: 38.75,
    ),
  ];
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
  String genererIdLivre() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'livre_$timestamp';
  }
} 