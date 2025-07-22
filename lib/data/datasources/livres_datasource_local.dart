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
        'edition': '7ème édition',
        'dateAjout': '2024-01-15',
        'estDisponible': true,
        'imageUrl': null,
        'motsClefs': ['calcul', 'mathématiques', 'intégrale', 'dérivée'],
        'prix': 12.50,
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
        'edition': '9ème édition',
        'dateAjout': '2024-01-18',
        'estDisponible': true,
        'imageUrl': null,
        'motsClefs': ['physique', 'mécanique', 'thermodynamique'],
        'prix': 18.00,
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
        'edition': '2ème édition',
        'dateAjout': '2024-01-20',
        'estDisponible': true,
        'imageUrl': null,
        'motsClefs': ['chimie', 'organique', 'molécules', 'réactions'],
        'prix': 20.99,
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
        'edition': '10ème édition',
        'dateAjout': '2024-01-22',
        'estDisponible': true,
        'imageUrl': null,
        'motsClefs': ['java', 'programmation', 'informatique', 'orienté objet'],
        'prix': 15.75,
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
        'edition': '5ème édition',
        'dateAjout': '2024-02-08',
        'estDisponible': true,
        'imageUrl': null,
        'motsClefs': ['littérature', 'français', 'anthologie', 'classique'],
      },
      {
        'id': '11',
        'titre': 'Introduction à la Programmation Python',
        'auteur': 'Guido van Rossum',
        'matiere': 'Informatique',
        'anneeEtude': '1ère année',
        'etatLivre': 'Excellent',
        'proprietaire': 'Nina P.',
        'coursAssocies': 'INF-1001',
        'description': 'Apprendre Python de zéro',
        'edition': '1ère édition',
        'dateAjout': '2024-02-10',
        'estDisponible': true,
        'imageUrl': null,
        'motsClefs': ['python', 'programmation', 'débutant'],
        'prix': 9.99,
      },
      {
        'id': '12',
        'titre': 'Statistiques pour Sciences Sociales',
        'auteur': 'Paul Smith',
        'matiere': 'Sciences Sociales',
        'anneeEtude': '2ème année',
        'etatLivre': 'Très bon',
        'proprietaire': 'Lucas G.',
        'coursAssocies': 'SOC-2002',
        'description': 'Outils statistiques appliqués',
        'edition': '3ème édition',
        'dateAjout': '2024-02-12',
        'estDisponible': true,
        'imageUrl': null,
        'motsClefs': ['statistiques', 'sciences sociales', 'analyse'],
        'prix': 13.50,
      },
      {
        'id': '13',
        'titre': 'Littérature Québécoise Moderne',
        'auteur': 'Marie Tremblay',
        'matiere': 'Français',
        'anneeEtude': '3ème année',
        'etatLivre': 'Bon',
        'proprietaire': 'Sophie L.',
        'coursAssocies': 'FRA-3003',
        'description': 'Analyse des œuvres contemporaines',
        'edition': '2ème édition',
        'dateAjout': '2024-02-14',
        'estDisponible': true,
        'imageUrl': null,
        'motsClefs': ['littérature', 'québécoise', 'analyse'],
      },
      {
        'id': '14',
        'titre': 'Gestion de Projet Agile',
        'auteur': 'Jean-Pierre Martin',
        'matiere': 'Administration',
        'anneeEtude': 'Maîtrise',
        'etatLivre': 'Très bon',
        'proprietaire': 'Amélie D.',
        'coursAssocies': 'ADM-5001',
        'description': 'Méthodologies agiles pour managers',
        'edition': '1ère édition',
        'dateAjout': '2024-02-16',
        'estDisponible': true,
        'imageUrl': null,
        'motsClefs': ['agile', 'gestion', 'projet'],
        'prix': 22.00,
      },
      {
        'id': '15',
        'titre': 'Chimie Physique Avancée',
        'auteur': 'Lucie Bernard',
        'matiere': 'Chimie',
        'anneeEtude': '4ème année',
        'etatLivre': 'Acceptable',
        'proprietaire': 'Olivier F.',
        'coursAssocies': 'CHM-4004',
        'description': 'Pour étudiants avancés en chimie',
        'edition': '4ème édition',
        'dateAjout': '2024-02-18',
        'estDisponible': true,
        'imageUrl': null,
        'motsClefs': ['chimie', 'physique', 'avancé'],
        'prix': 17.25,
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