// UI Design: Source de données locale unifiée pour tous les événements et activités
class EvenementsDatasourceLocal {
  
  // UI Design: Types d'événements
  static const Map<String, String> _typesEvenements = {
    'reunion': 'Réunion',
    'lancement': 'Lancement',
    'enregistrement': 'Enregistrement',
    'formation': 'Formation',
    'tournoi': 'Tournoi',
    'activite_exterieure': 'Activité extérieure',
    'competition': 'Compétition',
    'conference': 'Conférence',
    'atelier': 'Atelier',
    'collecte': 'Collecte',
    'soiree': 'Soirée',
  };

  // UI Design: Événements des associations
  static const Map<String, List<Map<String, dynamic>>> _evenementsAssociations = {
    '1': [ // AÉUQAR
      {
        'id': 'ev_1_1',
        'date': '13 janvier 2025',
        'dateEvenement': '2025-01-25',
        'titre': 'Réunion mensuelle',
        'description': 'Prochaine réunion prévue le 25 janvier pour planifier les activités de février.',
        'lieu': 'Salle communautaire',
        'heure': '19h00',
        'details': 'Salle communautaire - 19h00 • Places limitées',
        'type': 'reunion',
        'placesLimitees': true,
        'priorite': 'normale',
        'association': 'AÉUQAR',
        'associationId': '1',
      },
      {
        'id': 'ev_1_2',
        'date': '9 janvier 2025',
        'dateEvenement': '2025-01-09',
        'titre': 'Nouveau projet en cours',
        'description': 'Lancement d\'une initiative pour améliorer l\'engagement étudiant sur le campus.',
        'lieu': 'Campus principal',
        'heure': '20h30',
        'details': 'Campus principal - 20h30 • Inscription gratuite',
        'type': 'lancement',
        'inscriptionGratuite': true,
        'priorite': 'haute',
        'association': 'AÉUQAR',
        'associationId': '1',
      }
    ],
    '2': [ // Radio UQAR
      {
        'id': 'ev_2_1',
        'date': '15 janvier 2025',
        'dateEvenement': '2025-01-15',
        'titre': 'Session d\'enregistrement ouverte',
        'description': 'Venez enregistrer vos créations musicales dans notre nouveau studio.',
        'lieu': 'Studio A',
        'heure': '18h00',
        'details': 'Studio A - 18h00 • Apportez vos instruments',
        'type': 'enregistrement',
        'materielRequis': 'Instruments personnels',
        'priorite': 'normale',
        'association': 'Radio UQAR',
        'associationId': '2',
      },
      {
        'id': 'ev_2_2',
        'date': '20 janvier 2025',
        'dateEvenement': '2025-01-20',
        'titre': 'Formation technique radio',
        'description': 'Atelier sur les techniques de diffusion et d\'animation radio.',
        'lieu': 'Local 102',
        'heure': '16h00',
        'details': 'Local 102 - 16h00 • Matériel fourni',
        'type': 'formation',
        'materielFourni': true,
        'priorite': 'normale',
        'association': 'Radio UQAR',
        'associationId': '2',
      }
    ],
    '3': [ // Sport UQAR
      {
        'id': 'ev_3_1',
        'date': '18 janvier 2025',
        'dateEvenement': '2025-01-18',
        'titre': 'Tournoi de volleyball',
        'description': 'Compétition amicale entre équipes étudiantes.',
        'lieu': 'Gymnase principal',
        'heure': '14h00',
        'details': 'Gymnase principal - 14h00 • Équipes de 6',
        'type': 'tournoi',
        'tailleEquipe': 6,
        'priorite': 'haute',
        'association': 'Sport UQAR',
        'associationId': '3',
      },
      {
        'id': 'ev_3_2',
        'date': '22 janvier 2025',
        'dateEvenement': '2025-01-22',
        'titre': 'Randonnée en raquettes',
        'description': 'Sortie hivernale en groupe dans les sentiers locaux.',
        'lieu': 'Départ campus',
        'heure': '9h00',
        'details': 'Départ campus - 9h00 • Inscription 15 CAD',
        'type': 'activite_exterieure',
        'coutInscription': 15,
        'priorite': 'normale',
        'association': 'Sport UQAR',
        'associationId': '3',
      }
    ],
    '4': [ // Génie UQAR
      {
        'id': 'ev_4_1',
        'date': '25 janvier 2025',
        'dateEvenement': '2025-01-25',
        'titre': 'Génie Olympiques 2025',
        'description': 'Compétition annuelle d\'ingénierie avec défis techniques.',
        'lieu': 'Laboratoires Génie',
        'heure': '13h00',
        'details': 'Laboratoires Génie - 13h00 • Équipes de 4',
        'type': 'competition',
        'tailleEquipe': 4,
        'priorite': 'haute',
        'association': 'Génie UQAR',
        'associationId': '4',
      }
    ],
  };

  // UI Design: Événements mis en avant sur l'accueil
  static const List<Map<String, dynamic>> _evenementsAccueil = [
    {
      'id': 'acc_1',
      'titre': 'Tournoi Gaming Inter-Programmes',
      'association': 'Étudiants Informatique',
      'associationId': '5',
      'date': '25 Jan',
      'dateEvenement': '2025-01-25',
      'priorite': 'haute',
      'description': 'Compétition de jeux vidéo entre tous les programmes d\'études.',
      'lieu': 'Laboratoire informatique',
      'heure': '14h00',
      'type': 'competition',
      'estEvenement': true,
      'estAccueil': true,
    },
    {
      'id': 'acc_2',
      'titre': 'Atelier Gestion du Stress',
      'association': 'AGEUQAR',
      'associationId': '1',
      'date': '24 Jan',
      'dateEvenement': '2025-01-24',
      'priorite': 'haute',
      'description': 'Techniques de relaxation et gestion du stress en période d\'examens.',
      'lieu': 'Salle communautaire',
      'heure': '15h00',
      'type': 'atelier',
      'estEvenement': true,
      'estAccueil': true,
    },
    {
      'id': 'acc_3',
      'titre': 'Collecte Banque Alimentaire',
      'association': 'Association Humanitaire',
      'associationId': '6',
      'date': 'En cours',
      'dateFin': '2025-01-31',
      'priorite': 'normale',
      'description': 'Collecte de denrées non périssables pour les étudiants dans le besoin.',
      'lieu': 'Hall principal',
      'type': 'collecte',
      'estEvenement': false,
      'estAccueil': true,
    },
    {
      'id': 'acc_4',
      'titre': 'Soirée Cinéma Horreur',
      'association': 'Club Cinéma',
      'associationId': '7',
      'date': '26 Jan',
      'dateEvenement': '2025-01-26',
      'priorite': 'normale',
      'description': 'Projection de films d\'horreur classiques avec pop-corn gratuit.',
      'lieu': 'Amphithéâtre',
      'heure': '20h00',
      'type': 'soiree',
      'estEvenement': true,
      'estAccueil': true,
    },
    {
      'id': 'acc_5',
      'titre': 'Conférence IA et Avenir',
      'association': 'Café Philo',
      'associationId': '8',
      'date': '27 Jan',
      'dateEvenement': '2025-01-27',
      'priorite': 'basse',
      'description': 'Débat sur l\'impact de l\'intelligence artificielle sur le marché du travail.',
      'lieu': 'Salle de conférence A',
      'heure': '18h30',
      'type': 'conference',
      'estEvenement': true,
      'estAccueil': true,
    },
  ];

  // UI Design: Actualités des associations
  static const List<Map<String, dynamic>> _actualitesAssociations = [
    {
      'id': 'act_1',
      'associationId': '1',
      'association': 'AÉUQAR',
      'date': '15 jan',
      'titre': 'Nouvelle assurance dentaire étendue',
      'description': 'Couverture dentaire améliorée pour tous les membres avec nouveaux avantages orthodontiques et remboursements élargis.',
      'type': 'annonce',
      'importance': 'haute',
      'priorite': 'haute',
    },
    {
      'id': 'act_2',
      'associationId': '2',
      'association': 'Radio UQAR',
      'date': '12 jan',
      'titre': 'Nouveau studio d\'enregistrement',
      'description': 'Équipement professionnel installé pour améliorer la qualité des émissions étudiantes et podcasts.',
      'type': 'equipement',
      'importance': 'moyenne',
      'priorite': 'normale',
    },
    {
      'id': 'act_3',
      'associationId': '3',
      'association': 'Sport UQAR',
      'date': '14 jan',
      'titre': 'Tournoi inter-universitaire',
      'description': 'Inscription ouverte pour le championnat provincial de volleyball en mars. Places limitées.',
      'type': 'competition',
      'importance': 'haute',
      'priorite': 'haute',
      'placesLimitees': true,
    },
    {
      'id': 'act_4',
      'associationId': '4',
      'association': 'Génie UQAR',
      'date': '13 jan',
      'titre': 'Génie Olympiques 2025',
      'description': 'Compétition annuelle d\'ingénierie avec défis techniques et prix pour les meilleures équipes.',
      'type': 'competition',
      'importance': 'haute',
      'priorite': 'haute',
    },
  ];

  // ==================== ÉVÉNEMENTS ASSOCIATIONS ====================

  // Obtenir les événements d'une association
  Future<List<Map<String, dynamic>>> obtenirEvenementsAssociation(String associationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_evenementsAssociations[associationId] ?? []);
  }

  // Obtenir tous les événements des associations
  Future<List<Map<String, dynamic>>> obtenirTousLesEvenementsAssociations() async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    List<Map<String, dynamic>> tousLesEvenements = [];
    _evenementsAssociations.forEach((associationId, evenements) {
      for (var evenement in evenements) {
        tousLesEvenements.add(Map<String, dynamic>.from(evenement));
      }
    });
    
    return tousLesEvenements;
  }

  // Obtenir les détails d'un événement d'association
  Future<String> obtenirDetailsEvenementAssociation(String associationId, int evenementIndex) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    final evenements = _evenementsAssociations[associationId];
    if (evenements != null && evenementIndex < evenements.length) {
      return evenements[evenementIndex]['details'] ?? 'Détails à venir';
    }
    
    return 'Lieu et horaire à confirmer';
  }

  // ==================== ÉVÉNEMENTS ACCUEIL ====================

  // Obtenir les événements pour l'accueil (limité à 3)
  Future<List<Map<String, dynamic>>> obtenirEvenementsAccueil({int limite = 3}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Trier par priorité et date
    final evenementsTries = List<Map<String, dynamic>>.from(_evenementsAccueil);
    evenementsTries.sort((a, b) {
      // Priorité d'abord (haute > normale > basse)
      final prioriteOrder = {'haute': 3, 'normale': 2, 'basse': 1};
      final prioriteA = prioriteOrder[a['priorite']] ?? 1;
      final prioriteB = prioriteOrder[b['priorite']] ?? 1;
      
      if (prioriteA != prioriteB) {
        return prioriteB.compareTo(prioriteA);
      }
      
      // Puis par date si même priorité
      return a['date'].toString().compareTo(b['date'].toString());
    });
    
    return evenementsTries.take(limite).toList();
  }

  // Obtenir tous les événements de l'accueil
  Future<List<Map<String, dynamic>>> obtenirTousLesEvenementsAccueil() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.from(_evenementsAccueil);
  }

  // ==================== ACTUALITÉS ====================

  // Obtenir les actualités des associations
  Future<List<Map<String, dynamic>>> obtenirActualitesAssociations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_actualitesAssociations);
  }

  // Obtenir les actualités d'une association spécifique
  Future<List<Map<String, dynamic>>> obtenirActualitesParAssociation(String associationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _actualitesAssociations.where((actualite) => actualite['associationId'] == associationId).toList();
  }

  // ==================== RECHERCHE ET FILTRAGE ====================

  // Obtenir tous les événements (associations + accueil)
  Future<List<Map<String, dynamic>>> obtenirTousLesEvenements() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final evenementsAssociations = await obtenirTousLesEvenementsAssociations();
    final evenementsAccueil = await obtenirTousLesEvenementsAccueil();
    
    // Fusionner les deux listes
    final tousLesEvenements = [...evenementsAssociations, ...evenementsAccueil];
    
    return tousLesEvenements;
  }

  // Rechercher dans tous les événements
  Future<List<Map<String, dynamic>>> rechercherEvenements(String terme) async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    final tousLesEvenements = await obtenirTousLesEvenements();
    final termeLower = terme.toLowerCase();
    
    return tousLesEvenements.where((evenement) {
      return evenement['titre'].toString().toLowerCase().contains(termeLower) ||
             evenement['description'].toString().toLowerCase().contains(termeLower) ||
             evenement['association'].toString().toLowerCase().contains(termeLower) ||
             (evenement['type']?.toString().toLowerCase().contains(termeLower) ?? false);
    }).toList();
  }

  // Obtenir les événements par type
  Future<List<Map<String, dynamic>>> obtenirEvenementsParType(String type) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final tousLesEvenements = await obtenirTousLesEvenements();
    return tousLesEvenements.where((evenement) => evenement['type'] == type).toList();
  }

  // Obtenir les événements par priorité
  Future<List<Map<String, dynamic>>> obtenirEvenementsParPriorite(String priorite) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final tousLesEvenements = await obtenirTousLesEvenements();
    return tousLesEvenements.where((evenement) => evenement['priorite'] == priorite).toList();
  }

  // Obtenir les événements à venir
  Future<List<Map<String, dynamic>>> obtenirEvenementsAVenir() async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    final tousLesEvenements = await obtenirTousLesEvenements();
    final maintenant = DateTime.now();
    
    return tousLesEvenements.where((evenement) {
      if (evenement['dateEvenement'] == null) {
        return false;
      }
      
      try {
        final dateEvenement = DateTime.parse(evenement['dateEvenement']);
        return dateEvenement.isAfter(maintenant);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // ==================== MÉTHODES UTILITAIRES ====================

  // Obtenir les types d'événements disponibles
  Map<String, String> obtenirTypesEvenements() {
    return Map.from(_typesEvenements);
  }

  // Obtenir les statistiques des événements
  Future<Map<String, dynamic>> obtenirStatistiquesEvenements() async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final tousLesEvenements = await obtenirTousLesEvenements();
    final evenementsAVenir = await obtenirEvenementsAVenir();
    
    // Compter par type
    final parType = <String, int>{};
    for (var evenement in tousLesEvenements) {
      final type = evenement['type'] ?? 'autre';
      parType[type] = (parType[type] ?? 0) + 1;
    }
    
    // Compter par priorité
    final parPriorite = <String, int>{};
    for (var evenement in tousLesEvenements) {
      final priorite = evenement['priorite'] ?? 'normale';
      parPriorite[priorite] = (parPriorite[priorite] ?? 0) + 1;
    }
    
    return {
      'total': tousLesEvenements.length,
      'aVenir': evenementsAVenir.length,
      'associations': _evenementsAssociations.length,
      'accueil': _evenementsAccueil.length,
      'actualites': _actualitesAssociations.length,
      'parType': parType,
      'parPriorite': parPriorite,
      'derniereMiseAJour': DateTime.now().toIso8601String(),
    };
  }

  // Ajouter un nouvel événement (pour les admins)
  Future<bool> ajouterEvenement(Map<String, dynamic> nouvelEvenement) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Validation basique
    if (nouvelEvenement['titre'] != null && 
        nouvelEvenement['description'] != null &&
        nouvelEvenement['associationId'] != null) {
      
      // En production, sauvegarder l'événement
      return true;
    }
    return false;
  }

  // Modifier un événement existant (pour les admins)
  Future<bool> modifierEvenement(String eventId, Map<String, dynamic> modifications) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // En production, appliquer les modifications
    return true;
  }

  // Supprimer un événement (pour les admins)
  Future<bool> supprimerEvenement(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    // En production, supprimer l'événement
    return true;
  }
} 