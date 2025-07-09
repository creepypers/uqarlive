// UI Design: Datasource local pour les livres universitaires disponibles à l'échange
class LivresDatasourceLocal {
  
  // Données des livres universitaires disponibles pour l'échange
  List<Map<String, dynamic>> obtenirTousLesLivres() {
    return [
      {
        'id': '1',
        'titre': 'Calcul Différentiel et Intégral',
        'auteur': 'James Stewart',
        'matiere': 'Mathématiques',
        'anneeEtude': '1ère année',
        'etatLivre': 'Très bon',
        'proprietaire': 'Marie L.',
        'coursAssocies': 'MAT-1000',
        'description': 'Manuel complet avec exercices corrigés',
        'isbn': '978-0-538-73552-0',
        'edition': '7ème édition',
        'dateAjout': '2024-01-15',
        'estDisponible': true,
        'imageUrl': null,
        'motsClefs': ['calcul', 'mathématiques', 'intégrale', 'dérivée'],
      },
      {
        'id': '2',
        'titre': 'Physique Générale 1',
        'auteur': 'Serway & Jewett',
        'matiere': 'Physique',
        'anneeEtude': '1ère année',
        'etatLivre': 'Excellent',
        'proprietaire': 'Pierre M.',
        'coursAssocies': 'PHY-1001',
        'description': 'Tome 1 - Mécanique et thermodynamique',
        'isbn': '978-2-8041-8932-4',
        'edition': '9ème édition',
        'dateAjout': '2024-01-18',
        'estDisponible': true,
        'imageUrl': null,
        'motsClefs': ['physique', 'mécanique', 'thermodynamique'],
      },
      {
        'id': '3',
        'titre': 'Chimie Organique',
        'auteur': 'Clayden',
        'matiere': 'Chimie',
        'anneeEtude': '2ème année',
        'etatLivre': 'Bon',
        'proprietaire': 'Sarah B.',
        'coursAssocies': 'CHM-2010',
        'description': 'Livre de référence en chimie organique',
        'isbn': '978-0-19-927029-3',
        'edition': '2ème édition',
        'dateAjout': '2024-01-20',
        'estDisponible': true,
        'imageUrl': null,
        'motsClefs': ['chimie', 'organique', 'molécules', 'réactions'],
      },
      {
        'id': '4',
        'titre': 'Programmation en Java',
        'auteur': 'Deitel & Deitel',
        'matiere': 'Informatique',
        'anneeEtude': '2ème année',
        'etatLivre': 'Très bon',
        'proprietaire': 'Alex D.',
        'coursAssocies': 'INF-2005',
        'description': 'Guide complet de programmation Java',
        'isbn': '978-0-13-257566-9',
        'edition': '10ème édition',
        'dateAjout': '2024-01-22',
        'estDisponible': true,
        'imageUrl': null,
        'motsClefs': ['java', 'programmation', 'informatique', 'orienté objet'],
      },
      {
        'id': '5',
        'titre': 'Analyse Microéconomique',
        'auteur': 'Hal Varian',
        'matiere': 'Économie',
        'anneeEtude': '2ème année',
        'etatLivre': 'Excellent',
        'proprietaire': 'Julie R.',
        'coursAssocies': 'ECO-2001',
        'description': 'Théorie microéconomique moderne',
        'isbn': '978-2-8041-4688-4',
        'edition': '8ème édition',
        'dateAjout': '2024-01-25',
        'estDisponible': true,
        'imageUrl': null,
        'motsClefs': ['économie', 'microéconomie', 'marché', 'demande'],
      },
      {
        'id': '6',
        'titre': 'Biologie Moléculaire',
        'auteur': 'Watson et al.',
        'matiere': 'Biologie',
        'anneeEtude': '3ème année',
        'etatLivre': 'Bon',
        'proprietaire': 'Marc T.',
        'coursAssocies': 'BIO-3010',
        'description': 'Biologie moléculaire du gène',
        'isbn': '978-2-7445-0182-8',
        'edition': '7ème édition',
        'dateAjout': '2024-01-28',
        'estDisponible': true,
        'imageUrl': null,
        'motsClefs': ['biologie', 'moléculaire', 'ADN', 'génétique'],
      },
      {
        'id': '7',
        'titre': 'Résistance des Matériaux',
        'auteur': 'Ferdinand Beer',
        'matiere': 'Génie',
        'anneeEtude': '2ème année',
        'etatLivre': 'Acceptable',
        'proprietaire': 'Emma S.',
        'coursAssocies': 'GEN-2050',
        'description': 'Mécanique des matériaux solides',
        'isbn': '978-2-10-054397-4',
        'edition': '6ème édition',
        'dateAjout': '2024-01-30',
        'estDisponible': true,
        'imageUrl': null,
        'motsClefs': ['génie', 'matériaux', 'mécanique', 'résistance'],
      },
      {
        'id': '8',
        'titre': 'Histoire du Québec',
        'auteur': 'Jacques Lacoursière',
        'matiere': 'Histoire',
        'anneeEtude': '1ère année',
        'etatLivre': 'Très bon',
        'proprietaire': 'Tom L.',
        'coursAssocies': 'HIS-1010',
        'description': 'Histoire du Québec contemporain',
        'isbn': '978-2-7644-0960-7',
        'edition': '4ème édition',
        'dateAjout': '2024-02-02',
        'estDisponible': true,
        'imageUrl': null,
        'motsClefs': ['histoire', 'québec', 'canada', 'contemporain'],
      },
      {
        'id': '9',
        'titre': 'Droit Constitutionnel',
        'auteur': 'Henri Brun',
        'matiere': 'Droit',
        'anneeEtude': '1ère année',
        'etatLivre': 'Excellent',
        'proprietaire': 'Lisa M.',
        'coursAssocies': 'DRT-1001',
        'description': 'Droit constitutionnel canadien',
        'isbn': '978-2-89127-500-9',
        'edition': '6ème édition',
        'dateAjout': '2024-02-05',
        'estDisponible': true,
        'imageUrl': null,
        'motsClefs': ['droit', 'constitutionnel', 'canada', 'loi'],
      },
      {
        'id': '10',
        'titre': 'Littérature Française',
        'auteur': 'André Lagarde',
        'matiere': 'Lettres',
        'anneeEtude': '1ère année',
        'etatLivre': 'Bon',
        'proprietaire': 'David K.',
        'coursAssocies': 'LET-1005',
        'description': 'Anthologie de la littérature française',
        'isbn': '978-2-04-730192-4',
        'edition': '5ème édition',
        'dateAjout': '2024-02-08',
        'estDisponible': true,
        'imageUrl': null,
        'motsClefs': ['littérature', 'français', 'anthologie', 'classique'],
      },
    ];
  }

  // Méthodes pour filtrer les livres
  List<Map<String, dynamic>> obtenirLivresParMatiere(String matiere) {
    if (matiere == 'Toutes') return obtenirTousLesLivres();
    return obtenirTousLesLivres()
        .where((livre) => livre['matiere'] == matiere)
        .toList();
  }

  List<Map<String, dynamic>> obtenirLivresParEtat(String etat) {
    if (etat == 'Tous') return obtenirTousLesLivres();
    return obtenirTousLesLivres()
        .where((livre) => livre['etatLivre'] == etat)
        .toList();
  }

  List<Map<String, dynamic>> obtenirLivresParAnnee(String annee) {
    if (annee == 'Toutes') return obtenirTousLesLivres();
    return obtenirTousLesLivres()
        .where((livre) => livre['anneeEtude'] == annee)
        .toList();
  }

  // Méthode pour obtenir un livre par ID
  Map<String, dynamic>? obtenirLivreParId(String id) {
    try {
      return obtenirTousLesLivres().firstWhere((livre) => livre['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Méthode pour rechercher des livres
  List<Map<String, dynamic>> rechercherLivres(String recherche) {
    final rechercheLowerCase = recherche.toLowerCase();
    return obtenirTousLesLivres().where((livre) {
      return livre['titre'].toLowerCase().contains(rechercheLowerCase) ||
          livre['auteur'].toLowerCase().contains(rechercheLowerCase) ||
          livre['matiere'].toLowerCase().contains(rechercheLowerCase) ||
          livre['coursAssocies'].toLowerCase().contains(rechercheLowerCase);
    }).toList();
  }
} 