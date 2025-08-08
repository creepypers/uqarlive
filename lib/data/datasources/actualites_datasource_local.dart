import '../models/actualite_model.dart';
import '../../domain/entities/actualite.dart';

// UI Design: Source de données locale simulée pour les actualités d'associations
class ActualitesDatasourceLocal {
  
  // UI Design: Données simulées d'actualités d'associations étudiantes UQAR
  static final List<Map<String, dynamic>> _actualitesSimulees = [
    {
      'id': '1',
      'titre': 'Tournoi de Gaming Inter-Programmes',
      'description': 'Grande compétition de jeux vidéo entre tous les programmes de l\'UQAR',
      'contenu': 'L\'Association des Étudiants en Informatique organise un tournoi de gaming épique ! Inscriptions ouvertes pour League of Legends, Valorant, et FIFA. Prizes à gagner et pizza gratuite pour tous les participants.',
      'nomAssociation': 'Association Étudiants Informatique',
      'auteur': 'Alex Tremblay',
      'datePublication': '2025-01-15T10:30:00Z',
      'dateEvenement': '2025-01-25T18:00:00Z',
      'imageUrl': null,
      'tags': ['gaming', 'compétition', 'informatique'],
      'priorite': 'haute',
      'estEpinglee': true,
      'nombreVues': 245,
      'nombreLikes': 89,
    },
    {
      'id': '2',
      'titre': 'Soirée Cinéma Horreur',
      'description': 'Marathon de films d\'horreur classiques avec popcorn illimité',
      'contenu': 'Le Club de Cinéma UQAR vous invite à une soirée frissons garantis ! Au programme : The Shining, Psycho, et Get Out. Ambiance tamisée, couvertures fournies, et concours du meilleur cri.',
      'nomAssociation': 'Club de Cinéma UQAR',
      'auteur': 'Sarah Leblanc',
      'datePublication': '2025-01-14T16:45:00Z',
      'dateEvenement': '2025-01-20T19:30:00Z',
      'imageUrl': null,
      'tags': ['cinéma', 'horreur', 'soirée'],
      'priorite': 'normale',
      'estEpinglee': false,
      'nombreVues': 156,
      'nombreLikes': 67,
    },
    {
      'id': '3',
      'titre': 'Campagne de Sensibilisation Environnementale',
      'description': 'Journée d\'action pour un campus plus vert',
      'contenu': 'Rejoignez-nous pour nettoyer le campus, planter des arbres, et découvrir des astuces écolo ! Gants et outils fournis. Collation zéro déchet offerte à tous les bénévoles.',
      'nomAssociation': 'Éco-Étudiants UQAR',
      'auteur': 'Marie Dubois',
      'datePublication': '2025-01-13T09:15:00Z',
      'dateEvenement': '2025-01-22T13:00:00Z',
      'imageUrl': null,
      'tags': ['environnement', 'bénévolat', 'campus'],
      'priorite': 'normale',
      'estEpinglee': false,
      'nombreVues': 198,
      'nombreLikes': 134,
    },
    {
      'id': '4',
      'titre': 'Concours de Photographie "Rimouski en Hiver"',
      'description': 'Immortalisez la beauté hivernale de notre région',
      'contenu': 'Le Collectif Photo UQAR lance son concours annuel ! Thème : "Rimouski sous la neige". Prix : 500 cad pour le gagnant, expo au campus, et publication dans le journal étudiant.',
      'nomAssociation': 'Collectif Photo UQAR',
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
      'nomAssociation': 'AGEUQAR',
      'auteur': 'Julie Martin',
      'datePublication': '2025-01-11T11:30:00Z',
      'dateEvenement': '2025-01-24T14:00:00Z',
      'imageUrl': null,
      'tags': ['bien-être', 'examens', 'atelier'],
      'priorite': 'haute',
      'estEpinglee': true,
      'nombreVues': 324,
      'nombreLikes': 156,
    },
    {
      'id': '6',
      'titre': 'Collecte de Fonds pour Banque Alimentaire',
      'description': 'Aidons ensemble les familles dans le besoin',
      'contenu': 'L\'Association Humanitaire UQAR organise une grande collecte ! Déposez vos dons non-périssables dans les boîtes du campus. Objectif : 1000 articles avant la fin janvier.',
      'nomAssociation': 'Association Humanitaire UQAR',
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
      'nomAssociation': 'Club de Ultimate UQAR',
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
      'nomAssociation': 'Café Philosophique UQAR',
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

  // UI Design: Récupérer toutes les actualités
  Future<List<ActualiteModel>> obtenirToutesLesActualites() async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _actualitesSimulees
        .map((data) => ActualiteModel.fromMap(data))
        .toList();
  }

  // UI Design: Récupérer les actualités épinglées
  Future<List<ActualiteModel>> obtenirActualitesEpinglees() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _actualitesSimulees
        .where((data) => data['estEpinglee'] == true)
        .map((data) => ActualiteModel.fromMap(data))
        .toList();
  }

  // UI Design: Récupérer les actualités par association
  Future<List<ActualiteModel>> obtenirActualitesParAssociation(String nomAssociation) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    return _actualitesSimulees
        .where((data) => data['nomAssociation'] == nomAssociation)
        .map((data) => ActualiteModel.fromMap(data))
        .toList();
  }

  // UI Design: Rechercher des actualités
  Future<List<ActualiteModel>> rechercherActualites(String terme) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final termeMinuscule = terme.toLowerCase();
    return _actualitesSimulees
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
    await Future.delayed(const Duration(milliseconds: 300));
    
    final data = _actualitesSimulees.firstWhere(
      (actualite) => actualite['id'] == id,
      orElse: () => <String, dynamic>{},
    );
    
    return data.isNotEmpty ? ActualiteModel.fromMap(data) : null;
  }

  // UI Design: Liker une actualité (simulation)
  Future<bool> likerActualite(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final index = _actualitesSimulees.indexWhere((data) => data['id'] == id);
    if (index != -1) {
      _actualitesSimulees[index]['nombreLikes'] = 
          (_actualitesSimulees[index]['nombreLikes'] as int) + 1;
      return true;
    }
    return false;
  }

  // UI Design: Marquer une actualité comme vue
  Future<bool> marquerCommeVue(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final index = _actualitesSimulees.indexWhere((data) => data['id'] == id);
    if (index != -1) {
      _actualitesSimulees[index]['nombreVues'] = 
          (_actualitesSimulees[index]['nombreVues'] as int) + 1;
      return true;
    }
    return false;
  }

  // Clean Architecture: Ajouter une actualité
  Future<ActualiteModel> ajouterActualite(Actualite actualite) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final model = ActualiteModel.fromEntity(actualite);
    _actualitesSimulees.add(model.toMap());
    return model;
  }

  // Clean Architecture: Mettre à jour une actualité
  Future<ActualiteModel> mettreAJourActualite(Actualite actualite) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _actualitesSimulees.indexWhere((a) => a['id'] == actualite.id);
    final model = ActualiteModel.fromEntity(actualite);
    if (index != -1) {
      _actualitesSimulees[index] = model.toMap();
    } else {
      _actualitesSimulees.add(model.toMap());
    }
    return model;
  }

  // Clean Architecture: Supprimer une actualité
  Future<bool> supprimerActualite(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final before = _actualitesSimulees.length;
    _actualitesSimulees.removeWhere((a) => a['id'] == id);
    return _actualitesSimulees.length < before;
  }

  // Clean Architecture: Récupérer par priorité
  Future<List<ActualiteModel>> obtenirActualitesParPriorite(String priorite) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _actualitesSimulees
        .where((data) => (data['priorite'] ?? 'normale') == priorite)
        .map((data) => ActualiteModel.fromMap(data))
        .toList();
  }
} 