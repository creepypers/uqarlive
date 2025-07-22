import '../models/salle_model.dart';

// Datasource locale pour les salles de révision
class SallesDatasourceLocal {
  // Liste des 7 salles de révision
  static final List<SalleModel> _salles = [
    SalleModel(
      id: '1',
      nom: 'Salle de Révision A',
      description: 'Salle calme avec vue sur le fleuve, idéale pour les études individuelles',
      capaciteMax: 4,
      equipements: ['WiFi', 'Tableau blanc', 'Prise électrique', 'Éclairage LED'],
      etage: '1er étage',
      batiment: 'Pavillon des Humanités',
      estDisponible: true,
      tarifParHeure: 5.0,
    ),
    SalleModel(
      id: '2',
      nom: 'Salle de Révision B',
      description: 'Espace spacieux pour les groupes d\'étude et projets collaboratifs',
      capaciteMax: 8,
      equipements: ['WiFi', 'Écran de projection', 'Tableaux blancs', 'Climatisation'],
      etage: '2e étage',
      batiment: 'Pavillon des Sciences',
      estDisponible: true,
      tarifParHeure: 8.0,
    ),
    SalleModel(
      id: '3',
      nom: 'Salle de Révision C',
      description: 'Salle insonorisée parfaite pour les présentations orales',
      capaciteMax: 6,
      equipements: ['WiFi', 'Système audio', 'Caméra web', 'Tableau interactif'],
      etage: '1er étage',
      batiment: 'Pavillon des Arts',
      estDisponible: true,
      tarifParHeure: 7.0,
    ),
    SalleModel(
      id: '4',
      nom: 'Salle de Révision D',
      description: 'Petite salle cosy pour études concentrées en solo ou en duo',
      capaciteMax: 2,
      equipements: ['WiFi', 'Lampe de bureau', 'Prise USB', 'Silence garanti'],
      etage: '3e étage',
      batiment: 'Bibliothèque centrale',
      estDisponible: true,
      tarifParHeure: 3.0,
    ),
    SalleModel(
      id: '5',
      nom: 'Salle de Révision E',
      description: 'Salle moderne avec équipements high-tech pour projets numériques',
      capaciteMax: 6,
      equipements: ['WiFi ultra-rapide', 'Écrans multiples', 'Station de charge', 'Ordinateurs'],
      etage: '2e étage',
      batiment: 'Pavillon Informatique',
      estDisponible: true,
      tarifParHeure: 10.0,
    ),
    SalleModel(
      id: '6',
      nom: 'Salle de Révision F',
      description: 'Grande salle modulable pour événements étudiants et conférences',
      capaciteMax: 12,
      equipements: ['WiFi', 'Projecteur HD', 'Système de son', 'Tables modulables'],
      etage: 'Rez-de-chaussée',
      batiment: 'Centre étudiant',
      estDisponible: true,
      tarifParHeure: 15.0,
    ),
    SalleModel(
      id: '7',
      nom: 'Salle de Révision G',
      description: 'Salle zen avec ambiance relaxante pour études de longue durée',
      capaciteMax: 4,
      equipements: ['WiFi', 'Éclairage tamisé', 'Plantes vertes', 'Fauteuils confortables'],
      etage: '1er étage',
      batiment: 'Pavillon Bien-être',
      estDisponible: true,
      tarifParHeure: 6.0,
    ),
  ];

  // Obtenir toutes les salles
  Future<List<SalleModel>> obtenirToutesLesSalles() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulation réseau
    return List.from(_salles);
  }

  // Obtenir les salles disponibles
  Future<List<SalleModel>> obtenirSallesDisponibles() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _salles.where((salle) => salle.estDisponible).toList();
  }

  // Obtenir une salle par ID
  Future<SalleModel?> obtenirSalleParId(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _salles.firstWhere((salle) => salle.id == id);
    } catch (e) {
      return null;
    }
  }

  // Réserver une salle
  Future<bool> reserverSalle(
    String salleId,
    String utilisateurId,
    DateTime dateReservation,
    DateTime heureDebut,
    DateTime heureFin,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final index = _salles.indexWhere((salle) => salle.id == salleId);
    if (index == -1) return false;
    
    // Mettre à jour la salle avec les informations de réservation
    _salles[index] = _salles[index].copyWith(
      estDisponible: false,
      reserveePar: utilisateurId,
      dateReservation: dateReservation,
      heureDebut: heureDebut,
      heureFin: heureFin,
    );
    
    return true;
  }

  // Annuler une réservation
  Future<bool> annulerReservation(String salleId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _salles.indexWhere((salle) => salle.id == salleId);
    if (index == -1) return false;
    
    // Remettre la salle disponible
    _salles[index] = _salles[index].copyWith(
      estDisponible: true,
      reserveePar: null,
      dateReservation: null,
      heureDebut: null,
      heureFin: null,
    );
    
    return true;
  }

  // Obtenir les réservations d'un utilisateur
  Future<List<SalleModel>> obtenirReservationsUtilisateur(String utilisateurId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _salles.where((salle) => salle.reserveePar == utilisateurId).toList();
  }

  // Vérifier la disponibilité d'une salle
  Future<bool> verifierDisponibilite(
    String salleId,
    DateTime dateReservation,
    DateTime heureDebut,
    DateTime heureFin,
  ) async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    final salle = await obtenirSalleParId(salleId);
    if (salle == null) return false;
    
    // Si la salle n'est pas disponible
    if (!salle.estDisponible) {
      // Vérifier si c'est pour la même date et s'il y a conflit d'horaires
      if (salle.dateReservation != null && 
          salle.heureDebut != null && 
          salle.heureFin != null) {
        
        final memeJour = salle.dateReservation!.day == dateReservation.day &&
                        salle.dateReservation!.month == dateReservation.month &&
                        salle.dateReservation!.year == dateReservation.year;
        
        if (memeJour) {
          // Vérifier le conflit d'horaires
          final conflitHoraire = (heureDebut.isBefore(salle.heureFin!) && 
                                 heureFin.isAfter(salle.heureDebut!));
          return !conflitHoraire;
        }
      }
      return false;
    }
    
    return true;
  }
} 