import '../../models/actualite_model.dart';
import '../../../domain/entities/actualite.dart';

// UI Design: Source de données locale dynamique pour les actualités d'associations
class ActualitesDatasourceLocal {
  
  // UI Design: Données dynamiques d'actualités d'associations étudiantes UQAR (non-hardcodées)
  static final List<Map<String, dynamic>> _actualitesStockees = [];
  static bool _donneesSeedees = false;

  // UI Design: Données de démarrage par défaut (utilisées seulement si aucune actualité n'existe)
  static final List<Map<String, dynamic>> _actualitesParDefaut = [
    {
      'id': '1',
      'titre': 'Tournoi de Gaming Inter-Programmes',
      'description': 'Grande compétition de jeux vidéo entre tous les programmes de l\'UQAR',
      'contenu': 'L\'Association des Étudiants en Informatique organise un tournoi de gaming épique ! Inscriptions ouvertes pour League of Legends, Valorant, et FIFA. Prizes à gagner et pizza gratuite pour tous les participants.',
      'associationId': 'asso_001', // AEI
      'auteur': 'Alex Tremblay',
      'datePublication': '2025-01-15T10:30:00Z',
      'dateEvenement': '2025-01-25T18:00:00Z',
      'imageUrl': null,
      'tags': ['gaming', 'compétition', 'informatique'],
      'priorite': 'urgente',
      'estEpinglee': true,
      'nombreVues': 245,
      'nombreLikes': 89,
    },
    {
      'id': '2',
      'titre': 'Soirée Cinéma Horreur',
      'description': 'Marathon de films d\'horreur classiques avec popcorn illimité',
      'contenu': 'Le Club de Cinéma UQAR vous invite à une soirée frissons garantis ! Au programme : The Shining, Psycho, et Get Out. Ambiance tamisée, couvertures fournies, et concours du meilleur cri.',
      'associationId': 'asso_005', // Club de Cinéma UQAR
      'auteur': 'Sarah Leblanc',
      'datePublication': '2025-01-14T16:45:00Z',
      'dateEvenement': '2025-01-20T19:30:00Z',
      'imageUrl': null,
      'tags': ['cinéma', 'horreur', 'soirée'],
      'priorite': 'importante',
      'estEpinglee': false,
      'nombreVues': 156,
      'nombreLikes': 67,
    },
    {
      'id': '3',
      'titre': 'Campagne de Sensibilisation Environnementale',
      'description': 'Journée d\'action pour un campus plus vert',
      'contenu': 'Rejoignez-nous pour nettoyer le campus, planter des arbres, et découvrir des astuces écolo ! Gants et outils fournis. Collation zéro déchet offerte à tous les bénévoles.',
      'associationId': 'asso_006', // Éco-Étudiants UQAR
      'auteur': 'Marie Dubois',
      'datePublication': '2025-01-13T09:15:00Z',
      'dateEvenement': '2025-01-22T13:00:00Z',
      'imageUrl': null,
      'tags': ['environnement', 'bénévolat', 'campus'],
      'priorite': 'importante',
      'estEpinglee': true,
      'nombreVues': 198,
      'nombreLikes': 134,
    },
    {
      'id': '4',
      'titre': 'Concours de Photographie "Rimouski en Hiver"',
      'description': 'Immortalisez la beauté hivernale de notre région',
      'contenu': 'Le Collectif Photo UQAR lance son concours annuel ! Thème : "Rimouski sous la neige". Prix : 500 cad pour le gagnant, expo au campus, et publication dans le journal étudiant.',
      'associationId': 'asso_002', // Club Photo UQAR
      'auteur': 'Thomas Gagnon',
      'datePublication': '2025-01-12T14:20:00Z',
      'dateEvenement': null, // Pas d'événement spécifique
      'imageUrl': null,
      'tags': ['photographie', 'concours', 'hiver'],
      'priorite': 'normale',
      'estEpinglee': false,
      'nombreVues': 112,
      'nombreLikes': 45,
    },
    {
      'id': '5',
      'titre': 'Atelier Gestion du Stress en Période d\'Examens',
      'description': 'Techniques de relaxation et méthodes d\'étude efficaces',
      'contenu': 'L\'AGEUQAR propose un atelier gratuit avec une psychologue du campus. Au menu : techniques de respiration, planification d\'étude, et yoga de bureau. Places limitées !',
      'associationId': 'asso_003', // AGEUQAR
      'auteur': 'Julie Martin',
      'datePublication': '2025-01-11T11:30:00Z',
      'dateEvenement': '2025-01-24T14:00:00Z',
      'imageUrl': null,
      'tags': ['bien-être', 'examens', 'atelier'],
      'priorite': 'urgente',
      'estEpinglee': true,
      'nombreVues': 324,
      'nombreLikes': 156,
    },
    {
      'id': '6',
      'titre': 'Collecte de Fonds pour Banque Alimentaire',
      'description': 'Aidons ensemble les familles dans le besoin',
      'contenu': 'L\'Association Humanitaire UQAR organise une grande collecte ! Déposez vos dons non-périssables dans les boîtes du campus. Objectif : 1000 articles avant la fin janvier.',
      'associationId': 'asso_007', // Association Humanitaire UQAR
      'auteur': 'David Roy',
      'datePublication': '2025-01-10T08:45:00Z',
      'dateEvenement': null,
      'imageUrl': null,
      'tags': ['solidarité', 'collecte', 'alimentaire'],
      'priorite': 'normale',
      'estEpinglee': false,
      'nombreVues': 267,
      'nombreLikes': 198,
    },
    {
      'id': '7',
      'titre': 'Initiation au Ultimate Frisbee',
      'description': 'Découvrez ce sport dynamique et amusant',
      'contenu': 'Le Club de Ultimate UQAR ouvre ses portes aux débutants ! Séance d\'initiation gratuite au gymnase. Matériel fourni, bonne humeur garantie. Venez nombreux !',
      'associationId': 'asso_003', // Sport UQAR
      'auteur': 'Kevin Pelletier',
      'datePublication': '2025-01-09T17:00:00Z',
      'dateEvenement': '2025-01-23T17:30:00Z',
      'imageUrl': null,
      'tags': ['sport', 'ultimate', 'initiation'],
      'priorite': 'normale',
      'estEpinglee': false,
      'nombreVues': 89,
      'nombreLikes': 34,
    },
    {
      'id': '8',
      'titre': 'Café-Débat : L\'IA et l\'Avenir du Travail',
      'description': 'Discussion ouverte sur l\'intelligence artificielle',
      'contenu': 'Le Café Philo UQAR vous invite à débattre ! Sujet brûlant : "L\'IA va-t-elle remplacer nos jobs ?" Café et croissants offerts. Tous les points de vue bienvenus.',
      'associationId': 'asso_004', // AGE (général)
      'auteur': 'Émilie Lavoie',
      'datePublication': '2025-01-08T13:15:00Z',
      'dateEvenement': '2025-01-21T12:00:00Z',
      'imageUrl': null,
      'tags': ['débat', 'IA', 'philosophie'],
      'priorite': 'normale',
      'estEpinglee': false,
      'nombreVues': 143,
      'nombreLikes': 76,
    }
  ];

  // UI Design: Initialiser les données par défaut si nécessaire
  void _initialiserDonnees() {
    if (!_donneesSeedees && _actualitesStockees.isEmpty) {
      // Charger les données par défaut seulement si aucune actualité n'existe
      _actualitesStockees.addAll(_actualitesParDefaut);
      _donneesSeedees = true;
    }
  }

  // UI Design: Récupérer toutes les actualités
  Future<List<ActualiteModel>> obtenirToutesLesActualites() async {
    _initialiserDonnees();
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _actualitesStockees
        .map((data) => ActualiteModel.fromMap(data))
        .toList();
  }

  // UI Design: Récupérer les actualités épinglées
  Future<List<ActualiteModel>> obtenirActualitesEpinglees() async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _actualitesStockees
        .where((data) => data['estEpinglee'] == true)
        .map((data) => ActualiteModel.fromMap(data))
        .toList();
  }

  // UI Design: Récupérer les actualités par association
  Future<List<ActualiteModel>> obtenirActualitesParAssociation(String associationId) async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 400));
    
    return _actualitesStockees
        .where((data) => data['associationId'] == associationId)
        .map((data) => ActualiteModel.fromMap(data))
        .toList();
  }

  // UI Design: Rechercher des actualités
  Future<List<ActualiteModel>> rechercherActualites(String terme) async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 600));
    
    final termeMinuscule = terme.toLowerCase();
    return _actualitesStockees
        .where((data) {
          final titre = (data['titre'] as String).toLowerCase();
          final description = (data['description'] as String).toLowerCase();
          final tags = (data['tags'] as List<String>).join(' ').toLowerCase();
          return titre.contains(termeMinuscule) || 
                 description.contains(termeMinuscule) ||
                 tags.contains(termeMinuscule);
        })
        .map((data) => ActualiteModel.fromMap(data))
        .toList();
  }

  // UI Design: Récupérer une actualité par ID
  Future<ActualiteModel?> obtenirActualiteParId(String id) async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 300));
    
    final data = _actualitesStockees.firstWhere(
      (actualite) => actualite['id'] == id,
      orElse: () => <String, dynamic>{},
    );
    
    return data.isNotEmpty ? ActualiteModel.fromMap(data) : null;
  }

  // UI Design: Liker une actualité (dynamique)
  Future<bool> likerActualite(String id) async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 200));
    
    final index = _actualitesStockees.indexWhere((data) => data['id'] == id);
    if (index != -1) {
      _actualitesStockees[index]['nombreLikes'] = 
          (_actualitesStockees[index]['nombreLikes'] as int) + 1;
      return true;
    }
    return false;
  }

  // UI Design: Marquer une actualité comme vue
  Future<bool> marquerCommeVue(String id) async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 100));
    
    final index = _actualitesStockees.indexWhere((data) => data['id'] == id);
    if (index != -1) {
      _actualitesStockees[index]['nombreVues'] = 
          (_actualitesStockees[index]['nombreVues'] as int) + 1;
      return true;
    }
    return false;
  }

  // Clean Architecture: Ajouter une actualité (dynamique)
  Future<ActualiteModel> ajouterActualite(Actualite actualite) async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 200));
    final model = ActualiteModel.fromEntity(actualite);
    _actualitesStockees.add(model.toMap());
    return model;
  }

  // Clean Architecture: Mettre à jour une actualité (dynamique)
  Future<ActualiteModel> mettreAJourActualite(Actualite actualite) async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _actualitesStockees.indexWhere((a) => a['id'] == actualite.id);
    final model = ActualiteModel.fromEntity(actualite);
    if (index != -1) {
      _actualitesStockees[index] = model.toMap();
    } else {
      _actualitesStockees.add(model.toMap());
    }
    return model;
  }

  // Clean Architecture: Supprimer une actualité (dynamique)
  Future<bool> supprimerActualite(String id) async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 150));
    final before = _actualitesStockees.length;
    _actualitesStockees.removeWhere((a) => a['id'] == id);
    return _actualitesStockees.length < before;
  }

  // Clean Architecture: Récupérer par priorité (dynamique)
  Future<List<ActualiteModel>> obtenirActualitesParPriorite(String priorite) async {
    _initialiserDonnees();
    await Future.delayed(const Duration(milliseconds: 250));
    return _actualitesStockees
        .where((data) => (data['priorite'] ?? 'normale') == priorite)
        .map((data) => ActualiteModel.fromMap(data))
        .toList();
  }

  // UI Design: Méthodes utilitaires pour la gestion dynamique
  static void effacerToutesLesActualites() {
    _actualitesStockees.clear();
    _donneesSeedees = false;
  }

  static void rechargerDonneesParDefaut() {
    _actualitesStockees.clear();
    _donneesSeedees = false;
  }

  static int get nombreActualites => _actualitesStockees.length;
} 