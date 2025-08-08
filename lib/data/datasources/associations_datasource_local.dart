// UI Design: Datasource local pour les associations étudiantes UQAR
class AssociationsDatasourceLocal {
  
  // Données des associations étudiantes UQAR
  List<Map<String, dynamic>> obtenirToutesLesAssociations() {
    return [
      {
        'id': 'asso_001',
        'nom': 'AEI',
        'description': 'Association des étudiants en informatique',
        'typeAssociation': 'etudiante',
        'president': 'Alexandre Martin',
        'vicePresident': 'Marie Dubois',
        'chefId': 'etud_001', // Alexandre Martin
        'nombreMembres': 3200,
        'email': 'aeuqar@uqar.ca',
        'telephone': '418-723-1986',
        'siteWeb': 'https://aeuqar.ca',
        'facebook': 'AEUQARofficiel',
        'instagram': 'aeuqar',
        'activites': [
          'Défense des droits étudiants',
          'Organisation d\'événements',
          'Services aux étudiants',
          'Représentation universitaire'
        ],
        'logoUrl': null,
        'dateCreation': '1969-09-15',
        'estActive': true,
        'localisation': 'Local J-215',
        'horairesBureau': 'Lun-Ven: 9h-16h',
        'evenementsVenir': [
          'Assemblée générale - 15 mars',
          'Soirée de financement - 22 mars',
          'Journée carrière - 5 avril'
        ],
        'cotisationAnnuelle': 45.0,
        'descriptionLongue': 'L\'AÉUQAR est l\'association générale des étudiants de l\'Université du Québec à Rimouski. Elle représente les intérêts de tous les étudiants de premier cycle et offre de nombreux services.',
        'beneficesMembers': [
          'Représentation officielle',
          'Assurance dentaire et santé',
          'Réductions dans commerces partenaires',
          'Accès aux activités étudiantes'
        ],
      },
      {
        'id': 'asso_002',
        'nom': 'Club Photo UQAR',
        'description': 'Club de photographie pour étudiants passionnés',
        'typeAssociation': 'culturelle',
        'president': 'Sophie Gagnon',
        'vicePresident': 'Martin Côté',
        'chefId': 'etud_006', // Sophie Gagnon
        'nombreMembres': 85,
        'email': 'radio@uqar.ca',
        'telephone': '418-724-1446',
        'siteWeb': 'https://radiouqar.ca',
        'facebook': 'RadioUQAR',
        'instagram': 'radiouqar',
        'activites': [
          'Émissions de radio',
          'Couverture d\'événements',
          'Formation en radiodiffusion',
          'Concerts et spectacles'
        ],
        'logoUrl': null,
        'dateCreation': '1975-01-20',
        'estActive': true,
        'localisation': 'Studio A-101',
        'horairesBureau': 'Mar-Jeu: 14h-18h',
        'evenementsVenir': [
          'Concert acoustique - 18 mars',
          'Formation micro - 25 mars',
          'Radiothon - 12 avril'
        ],
        'cotisationAnnuelle': 20.0,
        'descriptionLongue': 'Radio UQAR est la voix étudiante de l\'université. Elle diffuse 24h/24 des émissions variées animées par les étudiants et couvre tous les événements du campus.',
        'beneficesMembers': [
          'Formation gratuite en radio',
          'Accès aux équipements',
          'Opportunités de stage',
          'Réseau médiatique'
        ],
      },
      {
        'id': 'asso_003',
        'nom': 'Sport UQAR',
        'description': 'Association sportive et récréative',
        'typeAssociation': 'sportive',
        'president': 'Maxime Leblanc',
        'vicePresident': 'Catherine Roy',
        'chefId': 'etud_007', // Maxime Leblanc
        'nombreMembres': 520,
        'email': 'sport@uqar.ca',
        'telephone': '418-723-1986',
        'siteWeb': null,
        'facebook': 'SportUQAR',
        'instagram': 'sportuqar',
        'activites': [
          'Équipes sportives universitaires',
          'Tournois intramuraux',
          'Cours de conditionnement',
          'Activités de plein air'
        ],
        'logoUrl': null,
        'dateCreation': '1980-08-15',
        'estActive': true,
        'localisation': 'Centre sportif',
        'horairesBureau': 'Lun-Ven: 8h-20h',
        'evenementsVenir': [
          'Tournoi de volleyball - 20 mars',
          'Course caritative - 2 avril',
          'Initiation escalade - 15 avril'
        ],
        'cotisationAnnuelle': 35.0,
        'descriptionLongue': 'Sport UQAR promeut l\'activité physique et le sport chez les étudiants. Elle organise des compétitions, des cours et des activités pour tous les niveaux.',
        'beneficesMembers': [
          'Accès gym réduit',
          'Équipements sportifs gratuits',
          'Coaching spécialisé',
          'Participation aux compétitions'
        ],
      },
      {
        'id': 'asso_004',
        'nom': 'AGE',
        'description': 'Association générale des étudiants',
        'typeAssociation': 'academique',
        'president': 'Alexandre Martin',
        'vicePresident': 'Vincent Michaud',
        'chefId': 'etud_001', // Alexandre Martin
        'nombreMembres': 180,
        'email': 'genie@uqar.ca',
        'telephone': '418-724-1525',
        'siteWeb': 'https://genieuqar.ca',
        'facebook': 'GenieUQAR',
        'instagram': 'genie_uqar',
        'activites': [
          'Projets d\'ingénierie',
          'Conférences professionnelles',
          'Mentorat académique',
          'Concours techniques'
        ],
        'logoUrl': null,
        'dateCreation': '1985-09-01',
        'estActive': true,
        'localisation': 'Pavillon des Sciences D-201',
        'horairesBureau': 'Mer-Ven: 12h-16h',
        'evenementsVenir': [
          'Génie Olympiques - 28 mars',
          'Conférence innovation - 10 avril',
          'Salon emploi ingénierie - 25 avril'
        ],
        'cotisationAnnuelle': 25.0,
        'descriptionLongue': 'L\'association des étudiants en génie représente tous les programmes d\'ingénierie de l\'UQAR et organise des activités académiques et professionnelles.',
        'beneficesMembers': [
          'Réseau professionnel',
          'Mentorat senior',
          'Projets concrets',
          'Formations techniques'
        ],
      },
      {
        'id': '5',
        'nom': 'Théâtre UQAR',
        'description': 'Troupe de théâtre étudiante',
        'typeAssociation': 'culturelle',
        'president': 'Juliette Beaulieu',
        'vicePresident': 'Thomas Côté',
        'nombreMembres': 45,
        'email': 'theatre@uqar.ca',
        'telephone': null,
        'siteWeb': null,
        'facebook': 'TheatreUQAR',
        'instagram': 'theatre_uqar',
        'activites': [
          'Productions théâtrales',
          'Ateliers d\'improvisation',
          'Cours d\'art dramatique',
          'Festivals étudiants'
        ],
        'logoUrl': null,
        'dateCreation': '1978-02-14',
        'estActive': true,
        'localisation': 'Salle de spectacle B-110',
        'horairesBureau': 'Mer: 18h-21h',
        'evenementsVenir': [
          'Pièce: "Les Belles-Sœurs" - 30 mars',
          'Atelier impro - 8 avril',
          'Auditions nouvelles pièces - 20 avril'
        ],
        'cotisationAnnuelle': 15.0,
        'descriptionLongue': 'La troupe de théâtre UQAR permet aux étudiants passionnés d\'art dramatique de développer leurs talents et de présenter des spectacles à la communauté.',
        'beneficesMembers': [
          'Participation aux productions',
          'Formation artistique gratuite',
          'Réseau culturel',
          'Expérience scénique'
        ],
      },
      {
        'id': '6',
        'nom': 'Éco-UQAR',
        'description': 'Association environnementale et développement durable',
        'typeAssociation': 'etudiante',
        'president': 'Laurence Giguère',
        'vicePresident': 'Gabriel Morin',
        'nombreMembres': 120,
        'email': 'eco@uqar.ca',
        'telephone': null,
        'siteWeb': 'https://ecouqar.org',
        'facebook': 'EcoUQAR',
        'instagram': 'eco_uqar',
        'activites': [
          'Projets environnementaux',
          'Sensibilisation écologique',
          'Jardinage communautaire',
          'Conférences développement durable'
        ],
        'logoUrl': null,
        'dateCreation': '2005-04-22',
        'estActive': true,
        'localisation': 'Local G-305',
        'horairesBureau': 'Lun-Mer: 15h-17h',
        'evenementsVenir': [
          'Semaine de l\'environnement - 22 avril',
          'Plantation d\'arbres - 5 mai',
          'Conférence climat - 18 mai'
        ],
        'cotisationAnnuelle': 10.0,
        'descriptionLongue': 'Éco-UQAR sensibilise la communauté universitaire aux enjeux environnementaux et organise des projets concrets pour un campus plus durable.',
        'beneficesMembers': [
          'Participation aux projets verts',
          'Formation environnementale',
          'Réseau écologique',
          'Impact positif'
        ],
      },
      {
        'id': '7',
        'nom': 'Étudiants Internationaux UQAR',
        'description': 'Association des étudiants étrangers',
        'typeAssociation': 'etudiante',
        'president': 'Maria Santos',
        'vicePresident': 'Ahmed Ben Ali',
        'nombreMembres': 280,
        'email': 'international@uqar.ca',
        'telephone': '418-723-1544',
        'siteWeb': null,
        'facebook': 'EtudiantsInternationauxUQAR',
        'instagram': 'international_uqar',
        'activites': [
          'Accueil nouveaux étudiants',
          'Événements interculturels',
          'Support administratif',
          'Activités d\'intégration'
        ],
        'logoUrl': null,
        'dateCreation': '1995-01-15',
        'estActive': true,
        'localisation': 'Bureau international F-220',
        'horairesBureau': 'Mar-Jeu: 10h-15h',
        'evenementsVenir': [
          'Soirée interculturelle - 25 mars',
          'Atelier immigration - 8 avril',
          'Festival des nations - 15 mai'
        ],
        'cotisationAnnuelle': 5.0,
        'descriptionLongue': 'Cette association facilite l\'intégration des étudiants internationaux et favorise les échanges interculturels au sein de l\'université.',
        'beneficesMembers': [
          'Aide à l\'intégration',
          'Réseau international',
          'Support administratif',
          'Activités culturelles'
        ],
      },
      {
        'id': '8',
        'nom': 'AELIES',
        'description': 'Association des étudiants en lettres et sciences humaines',
        'typeAssociation': 'academique',
        'president': 'Isabelle Dufour',
        'vicePresident': 'Marc-André Bouchard',
        'nombreMembres': 380,
        'email': 'aelies@uqar.ca',
        'telephone': null,
        'siteWeb': null,
        'facebook': 'AeliesUQAR',
        'instagram': 'aelies_uqar',
        'activites': [
          'Colloques académiques',
          'Club de lecture',
          'Concours littéraires',
          'Conférences scientifiques'
        ],
        'logoUrl': null,
        'dateCreation': '1982-10-12',
        'estActive': true,
        'localisation': 'Pavillon des Lettres C-415',
        'horairesBureau': 'Lun-Mer: 13h-16h',
        'evenementsVenir': [
          'Colloque littérature québécoise - 5 avril',
          'Soirée poésie - 20 avril',
          'Conférence histoire locale - 10 mai'
        ],
        'cotisationAnnuelle': 18.0,
        'descriptionLongue': 'L\'AELIES représente les étudiants en lettres, langues et sciences humaines. Elle organise des événements académiques et culturels.',
        'beneficesMembers': [
          'Événements académiques',
          'Réseau intellectuel',
          'Publications étudiantes',
          'Bourses d\'études'
        ],
      },
    ];
  }

  // Méthodes pour filtrer les associations
  List<Map<String, dynamic>> obtenirAssociationsParType(String type) {
    if (type == 'toutes') return obtenirToutesLesAssociations();
    return obtenirToutesLesAssociations()
        .where((association) => association['typeAssociation'] == type)
        .toList();
  }

  List<Map<String, dynamic>> obtenirAssociationsActives() {
    return obtenirToutesLesAssociations()
        .where((association) => association['estActive'] == true)
        .toList();
  }

  // Méthode pour obtenir une association par ID
  Map<String, dynamic>? obtenirAssociationParId(String id) {
    try {
      return obtenirToutesLesAssociations()
          .firstWhere((association) => association['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Méthode pour rechercher par nom
  List<Map<String, dynamic>> rechercherAssociations(String recherche) {
    if (recherche.isEmpty) return obtenirToutesLesAssociations();
    
    final rechercheLower = recherche.toLowerCase();
    return obtenirToutesLesAssociations()
        .where((association) => 
            association['nom'].toString().toLowerCase().contains(rechercheLower) ||
            association['description'].toString().toLowerCase().contains(rechercheLower))
        .toList();
  }

  // Obtenir les types d'associations disponibles
  List<String> obtenirTypesAssociations() {
    return ['toutes', 'etudiante', 'culturelle', 'sportive', 'academique'];
  }

  // Obtenir les associations populaires (plus de membres)
  List<Map<String, dynamic>> obtenirAssociationsPopulaires({int limite = 5}) {
    final associations = obtenirToutesLesAssociations();
    associations.sort((a, b) => 
        (b['nombreMembres'] as int).compareTo(a['nombreMembres'] as int));
    return associations.take(limite).toList();
  }
} 