import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import '../widgets/widget_carte.dart';
import '../widgets/widget_collection.dart';
import '../services/navigation_service.dart';
import '../services/authentification_service.dart';
import '../../core/di/service_locator.dart';
import '../../domain/repositories/salles_repository.dart';
import '../../domain/repositories/reservations_salle_repository.dart';
import '../../domain/entities/salle.dart';
import '../../domain/entities/reservation_salle.dart';

// UI Design: Page de gestion et réservation des salles de révision
class SallesEcran extends StatefulWidget {
  const SallesEcran({super.key});

  @override
  State<SallesEcran> createState() => _SallesEcranState();
}

class _SallesEcranState extends State<SallesEcran> {
  late SallesRepository _sallesRepository;
  late ReservationsSalleRepository _reservationsSalleRepository;
  late AuthentificationService _authentificationService;
  List<Salle> _salles = [];
  List<Salle> _sallesFiltrees = [];
  List<ReservationSalle> _mesReservations = [];
  bool _isLoading = true;
  String _filtreActuel = 'toutes'; // 'toutes', 'disponibles', 'reservees'
  String _recherche = '';

  @override
  void initState() {
    super.initState();
    // UI Design: Injection de dépendances via ServiceLocator - Clean Architecture
    _sallesRepository = ServiceLocator.obtenirService<SallesRepository>();
    _reservationsSalleRepository = ServiceLocator.obtenirService<ReservationsSalleRepository>();
    _authentificationService = ServiceLocator.obtenirService<AuthentificationService>();
    _chargerSalles();
  }

  Future<void> _chargerSalles() async {
    setState(() => _isLoading = true);
    try {
      final salles = await _sallesRepository.obtenirToutesLesSalles();
      final utilisateur = _authentificationService.utilisateurActuel;
      
      if (utilisateur != null) {
        _mesReservations = await _reservationsSalleRepository.obtenirReservationsParUtilisateur(utilisateur.id);
      }
      
      setState(() {
        _salles = salles;
        _appliquerFiltres();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _afficherErreur('Erreur lors du chargement des salles');
    }
  }

  void _appliquerFiltres() {
    List<Salle> sallesFiltrees = List.from(_salles);

    // Filtrer par statut
    switch (_filtreActuel) {
      case 'disponibles':
        // Une salle est disponible si elle n'a pas de réservation active
        sallesFiltrees = sallesFiltrees.where((salle) {
          final reservationsPourCetteSalle = _mesReservations.where(
            (reservation) => reservation.salleId == salle.id && 
                           reservation.statut != 'annulee' &&
                           reservation.statut != 'terminee'
          ).toList();
          return reservationsPourCetteSalle.isEmpty;
        }).toList();
        break;
      case 'reservees':
        // Une salle est réservée si elle a une réservation active de l'utilisateur
        sallesFiltrees = sallesFiltrees.where((salle) {
          final reservationsPourCetteSalle = _mesReservations.where(
            (reservation) => reservation.salleId == salle.id && 
                           reservation.statut != 'annulee' &&
                           reservation.statut != 'terminee'
          ).toList();
          return reservationsPourCetteSalle.isNotEmpty;
        }).toList();
        break;
    }

    // Filtrer par recherche
    if (_recherche.isNotEmpty) {
      sallesFiltrees = sallesFiltrees.where((salle) =>
        salle.nom.toLowerCase().contains(_recherche.toLowerCase()) ||
        salle.description.toLowerCase().contains(_recherche.toLowerCase()) ||
        salle.batiment.toLowerCase().contains(_recherche.toLowerCase())
      ).toList();
    }

    setState(() => _sallesFiltrees = sallesFiltrees);
  }

  // UI Design: Helper pour déterminer si une salle est disponible
  bool _estSalleDisponible(Salle salle) {
    final reservationsActives = _mesReservations.where(
      (reservation) => reservation.salleId == salle.id && 
                      reservation.statut != 'annulee' &&
                      reservation.statut != 'terminee'
    ).toList();
    return reservationsActives.isEmpty;
  }

  // UI Design: Helper pour obtenir l'heure libre d'une salle
  String? _obtenirHeureLibre(Salle salle) {
    final reservationsActives = _mesReservations.where(
      (reservation) => reservation.salleId == salle.id && 
                      reservation.statut != 'annulee' &&
                      reservation.statut != 'terminee'
    ).toList();
    
    if (reservationsActives.isNotEmpty) {
      // Retourner l'heure de fin de la première réservation active
      final premiereReservation = reservationsActives.first;
      return '${premiereReservation.heureFin.hour.toString().padLeft(2, '0')}:${premiereReservation.heureFin.minute.toString().padLeft(2, '0')}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // UI Design: Obtenir les dimensions de l'écran pour l'adaptabilité
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      resizeToAvoidBottomInset: true, // UI Design: Éviter les débordements avec le clavier
      appBar: WidgetBarreAppPersonnalisee(
        titre: 'Salles de Révision',
        sousTitre: '${_salles.length} salles disponibles',
        widgetFin: IconButton(
          icon: Icon(Icons.filter_list, color: CouleursApp.blanc, size: screenWidth * 0.06), // UI Design: Taille adaptative
          onPressed: () => _ouvrirFiltres(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barre de recherche et filtres (toujours affichées)
            _construireBarreRecherche(),
            SizedBox(height: screenHeight * 0.01), // UI Design: Espacement adaptatif
            _construireFiltresRapides(),
            SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
            
            // Liste des salles avec gestion de l'état de chargement - SCROLLABLE
            Expanded(
              child: WidgetCollection<Salle>.listeVerticale(
                elements: _sallesFiltrees,
                enChargement: _isLoading,
                constructeurElement: (context, salle, index) => WidgetCarte.salle(
                  nom: salle.nom,
                  description: salle.description,
                  localisation: '${salle.batiment} • ${salle.etage}',
                  capacite: salle.capaciteMax,
                  tarif: salle.tarifParHeure,
                  estDisponible: _estSalleDisponible(salle),
                  equipements: salle.equipements,
                  heureLibre: _obtenirHeureLibre(salle),
                  onTapDetails: () => _voirDetailsSalle(salle),
                  onTapReserver: () => _reserverSalle(salle),
                ),
                espacementVertical: screenHeight * 0.01, // UI Design: Espacement adaptatif
                messageEtatVide: 'Aucune salle trouvée\nEssayez de modifier vos filtres',
                iconeEtatVide: Icons.meeting_room_outlined,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04, // UI Design: Padding adaptatif
                  vertical: screenHeight * 0.01,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavBarWidget(
        indexSelectionne: 4, // Index pour les salles
        onTap: (index) => NavigationService.gererNavigationNavBar(context, index),
      ),
    );
  }

  // UI Design: Barre de recherche
  Widget _construireBarreRecherche() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04), // UI Design: Marge adaptative
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Padding adaptatif
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        style: TextStyle(fontSize: screenWidth * 0.04), // UI Design: Taille adaptative
        onChanged: (value) {
          setState(() {
            _recherche = value;
            _appliquerFiltres();
          });
        },
        decoration: InputDecoration(
          hintText: 'Rechercher une salle...',
          hintStyle: TextStyle(
            fontSize: screenWidth * 0.04, // UI Design: Taille adaptative
            color: CouleursApp.texteFonce.withValues(alpha: 0.6),
          ),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: CouleursApp.principal, size: screenWidth * 0.06), // UI Design: Taille adaptative
          suffixIcon: _recherche.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: CouleursApp.principal, size: screenWidth * 0.06), // UI Design: Taille adaptative
                onPressed: () {
                  setState(() {
                    _recherche = '';
                    _appliquerFiltres();
                  });
                },
              )
            : null,
        ),
      ),
    );
  }

  // UI Design: Filtres rapides
  Widget _construireFiltresRapides() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    // Calculer les vraies statistiques basées sur les réservations
    final reservationsActives = _mesReservations.where(
      (reservation) => reservation.statut != 'annulee' && reservation.statut != 'terminee'
    ).toList();
    
    final sallesReservees = _salles.where((salle) {
      return reservationsActives.any((reservation) => reservation.salleId == salle.id);
    }).length;
    
    final sallesDisponibles = _salles.length - sallesReservees;
    
    return Container(
      height: screenHeight * 0.05, // UI Design: Hauteur adaptative
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Marge adaptative
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _construireBoutonFiltre('toutes', 'Toutes (${_salles.length})'),
          SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
          _construireBoutonFiltre('disponibles', 'Disponibles ($sallesDisponibles)'),
          SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
          _construireBoutonFiltre('reservees', 'Réservées ($sallesReservees)'),
        ],
      ),
    );
  }

  Widget _construireBoutonFiltre(String filtre, String label) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    final estActif = _filtreActuel == filtre;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filtreActuel = filtre;
          _appliquerFiltres();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, // UI Design: Padding adaptatif
          vertical: screenHeight * 0.01,
        ),
        decoration: BoxDecoration(
          color: estActif ? CouleursApp.principal : CouleursApp.blanc,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: estActif ? CouleursApp.principal : CouleursApp.principal.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: estActif ? CouleursApp.blanc : CouleursApp.principal,
            fontWeight: estActif ? FontWeight.bold : FontWeight.normal,
            fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
          ),
          overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
          maxLines: 1,
        ),
      ),
    );
  }

  // UI Design: Génère les heures disponibles pour la réservation
  List<Map<String, dynamic>> _genererHeuresDisponibles() {
    return List.generate(12, (index) {
      final heure = 8 + index; // 8h à 19h
      return {
        'heure': '${heure}h',
        'valeur': heure,
        'disponible': heure != 12 && heure != 16, // 12h et 16h occupées
      };
      });
    }

  // Actions
  void _ouvrirFiltres() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Filtres avancés - À venir'),
        backgroundColor: CouleursApp.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _voirDetailsSalle(Salle salle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _construireDetailsSalle(salle),
    );
  }

  Widget _construireDetailsSalle(Salle salle) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      height: screenHeight * 0.8, // UI Design: Hauteur adaptative
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: screenWidth * 0.1, // UI Design: Largeur adaptative
              height: screenHeight * 0.005, // UI Design: Hauteur adaptative
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.025), // UI Design: Espacement adaptatif
          
          // Titre
          Text(
            salle.nom,
            style: StylesTexteApp.titre.copyWith(
              fontSize: screenWidth * 0.06, // UI Design: Taille adaptative
            ),
            overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
            maxLines: 1,
          ),
          SizedBox(height: screenHeight * 0.01), // UI Design: Espacement adaptatif
          Text(
            '${salle.batiment} • ${salle.etage}',
            style: TextStyle(
              fontSize: screenWidth * 0.04, // UI Design: Taille adaptative
              color: CouleursApp.texteFonce.withValues(alpha: 0.6),
            ),
            overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
            maxLines: 1,
          ),
          SizedBox(height: screenHeight * 0.025), // UI Design: Espacement adaptatif
          
          // Description
          Text(
            'Description',
            style: StylesTexteApp.titre.copyWith(
              fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
            ),
            overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
            maxLines: 1,
          ),
          SizedBox(height: screenHeight * 0.01), // UI Design: Espacement adaptatif
          Text(
            salle.description,
            style: TextStyle(
              fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
              color: CouleursApp.texteFonce.withValues(alpha: 0.8),
              height: 1.5,
            ),
            overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
            maxLines: 3,
          ),
          SizedBox(height: screenHeight * 0.025), // UI Design: Espacement adaptatif
          
          // Équipements
          Text(
            'Équipements disponibles',
            style: StylesTexteApp.titre.copyWith(
              fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
            ),
            overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
            maxLines: 1,
          ),
          SizedBox(height: screenHeight * 0.015), // UI Design: Espacement adaptatif
          Wrap(
            spacing: screenWidth * 0.02, // UI Design: Espacement adaptatif
            runSpacing: screenWidth * 0.02, // UI Design: Espacement adaptatif
            children: salle.equipements.map((equipement) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03, // UI Design: Padding adaptatif
                  vertical: screenWidth * 0.02,
                ),
                decoration: BoxDecoration(
                  color: CouleursApp.principal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CouleursApp.principal.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  equipement,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
                    color: CouleursApp.principal,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                  maxLines: 1,
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          
          // Bouton réserver
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _estSalleDisponible(salle) 
                ? () {
                    Navigator.pop(context);
                    _choisirCreneauEtReserver(salle);
                  }
                : _utilisateurADejaReservation() && _obtenirReservationActive()?.salleId == salle.id
                  ? () {
                      Navigator.pop(context);
                      _gererMaReservation(salle);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _estSalleDisponible(salle) 
                  ? CouleursApp.accent 
                  : _utilisateurADejaReservation() && _obtenirReservationActive()?.salleId == salle.id
                    ? CouleursApp.principal // Ma réservation
                  : Colors.grey,
                foregroundColor: CouleursApp.blanc,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02), // UI Design: Padding adaptatif
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _estSalleDisponible(salle) 
                  ? 'Réserver cette salle'
                  : _utilisateurADejaReservation() && _obtenirReservationActive()?.salleId == salle.id
                    ? 'Modifier ma réservation'
                  : 'Salle indisponible',
                style: TextStyle(
                  fontSize: screenWidth * 0.04, // UI Design: Taille adaptative
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Méthode pour choisir un créneau et réserver
  void _choisirCreneauEtReserver(Salle salle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _construireModalCreneaux(salle),
    );
  }

  // État pour les heures sélectionnées
  final Set<int> _heuresSelectionnees = <int>{};

  // UI Design: Modal de sélection des heures - SCROLLABLE pour éviter overflow
  Widget _construireModalCreneaux(Salle salle, {bool estModification = false}) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    final heuresDisponibles = _genererHeuresDisponibles();
    
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.8, // UI Design: Hauteur adaptative
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête
                  Row(
                    children: [
                      Icon(Icons.schedule, color: CouleursApp.principal, size: screenWidth * 0.06), // UI Design: Taille adaptative
                      SizedBox(width: screenWidth * 0.03), // UI Design: Espacement adaptatif
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              estModification ? 'Modifier les heures' : 'Sélectionner les heures',
                              style: TextStyle(
                                fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                                fontWeight: FontWeight.bold,
                                color: CouleursApp.texteFonce,
                              ),
                              overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: CouleursApp.texteFonce, size: screenWidth * 0.06), // UI Design: Taille adaptative
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.025), // UI Design: Espacement adaptatif
                  
                  // Instructions
                  Text(
                    'Cliquez sur les heures que vous souhaitez réserver :',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                      fontWeight: FontWeight.w600,
                      color: CouleursApp.texteFonce,
                    ),
                    overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                    maxLines: 2,
                  ),
                  SizedBox(height: screenHeight * 0.015), // UI Design: Espacement adaptatif
                  
                  // Grille d'heures sélectionnables - OPTIMISÉE pour éviter overflow
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 carrés par ligne pour plus d'espace
                      crossAxisSpacing: screenWidth * 0.02, // UI Design: Espacement adaptatif
                      mainAxisSpacing: screenHeight * 0.01, // UI Design: Espacement adaptatif
                      childAspectRatio: 1.8, // Plus large pour éviter l'overflow
                    ),
                    itemCount: heuresDisponibles.length,
                    itemBuilder: (context, index) {
                      final heure = heuresDisponibles[index];
                      final heureValeur = heure['valeur'] as int;
                      final estDisponible = heure['disponible'] as bool;
                      final estSelectionne = _heuresSelectionnees.contains(heureValeur);
                      
                      return InkWell(
                        onTap: estDisponible ? () {
                          setState(() {
                            if (estSelectionne) {
                              _heuresSelectionnees.remove(heureValeur);
                            } else {
                              _heuresSelectionnees.add(heureValeur);
                            }
                          });
                        } : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: !estDisponible 
                              ? Colors.grey.withValues(alpha: 0.3)
                              : estSelectionne 
                                ? CouleursApp.accent
                                : CouleursApp.principal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: !estDisponible 
                                ? Colors.grey.withValues(alpha: 0.5)
                                : estSelectionne 
                                  ? CouleursApp.accent
                                  : CouleursApp.principal.withValues(alpha: 0.4),
                              width: estSelectionne ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (estSelectionne)
                                  Icon(
                                    Icons.check,
                                    color: CouleursApp.blanc,
                                    size: screenWidth * 0.04, // UI Design: Taille adaptative
                                  ),
                                SizedBox(height: screenHeight * 0.002), // UI Design: Espacement adaptatif
                                Text(
                                  heure['heure'] as String,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
                                    fontWeight: FontWeight.w600,
                                    color: !estDisponible 
                                      ? Colors.grey
                                      : estSelectionne 
                                        ? CouleursApp.blanc
                                        : CouleursApp.principal,
                                  ),
                                  overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: screenHeight * 0.025), // UI Design: Espacement adaptatif
                  
                  // Bouton de confirmation
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _heuresSelectionnees.isNotEmpty 
                        ? () => _confirmerReservationHeures(salle, _heuresSelectionnees.toList(), estModification)
                        : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CouleursApp.accent,
                        foregroundColor: CouleursApp.blanc,
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015), // UI Design: Padding adaptatif
                      ),
                      child: Text(
                        _heuresSelectionnees.isEmpty 
                          ? 'Sélectionnez au moins une heure'
                          : 'Réserver ${_heuresSelectionnees.length} heure${_heuresSelectionnees.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04, // UI Design: Taille adaptative
                        ),
                        overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                        maxLines: 1,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025), // UI Design: Espace en bas pour le scroll
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Confirmer la réservation avec heures sélectionnées
  void _confirmerReservationHeures(Salle salle, List<int> heuresSelectionnees, [bool estModification = false]) {
    Navigator.pop(context);
    
    // Trier les heures
    heuresSelectionnees.sort();
    final heuresTexte = heuresSelectionnees.map((h) => '${h}h').join(', ');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(estModification ? 'Confirmer la modification' : 'Confirmer la réservation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Salle : ${salle.nom}'),
            Text('Heures : $heuresTexte'),
            Text('Durée : ${heuresSelectionnees.length} heure${heuresSelectionnees.length > 1 ? 's' : ''}'),
            Text(
              estModification ? 'Confirmer cette modification ?' : 'Confirmer cette réservation ?',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (estModification) {
                _modifierReservationAvecHeures(salle, heuresSelectionnees);
              } else {
              _reserverSalleAvecHeures(salle, heuresSelectionnees);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CouleursApp.accent,
              foregroundColor: CouleursApp.blanc,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  Future<void> _modifierReservationAvecHeures(Salle salle, List<int> heuresSelectionnees) async {
    final utilisateur = _authentificationService.utilisateurActuel;
    if (utilisateur == null) {
      _afficherErreur('Vous devez être connecté pour modifier');
      return;
    }

    // Trouver la réservation existante pour cette salle
    final reservationExistante = _mesReservations.firstWhere(
      (reservation) => reservation.salleId == salle.id,
      orElse: () => throw Exception('Aucune réservation trouvée pour cette salle'),
    );

    // Pour simplifier, on utilise la première et dernière heure comme début et fin
    heuresSelectionnees.sort();
    final heureDebut = heuresSelectionnees.first;
    final heureFin = heuresSelectionnees.last + 1; // +1 pour inclure l'heure complète
    
    final maintenant = DateTime.now();
    final dateReservation = DateTime(maintenant.year, maintenant.month, maintenant.day, heureDebut);
    final dateFin = DateTime(maintenant.year, maintenant.month, maintenant.day, heureFin);
    
    try {
      // D'abord annuler l'ancienne réservation
      final annulationSuccess = await _reservationsSalleRepository.annulerReservation(reservationExistante.id);
      if (!annulationSuccess) {
        _afficherErreur('Erreur lors de la modification');
        return;
      }
      
      // Créer la nouvelle réservation
      final nouvelleReservation = ReservationSalle(
        id: 'res_${DateTime.now().millisecondsSinceEpoch}',
        utilisateurId: utilisateur.id,
        salleId: salle.id,
        dateReservation: dateReservation,
        heureDebut: dateReservation,
        heureFin: dateFin,
        motif: reservationExistante.motif,
        description: reservationExistante.description ?? 'Réservation modifiée',
        statut: 'en_attente',
        nombrePersonnes: reservationExistante.nombrePersonnes,
        coutTotal: salle.tarifParHeure * (heureFin - heureDebut),
        dateCreation: DateTime.now(),
      );

      final success = await _reservationsSalleRepository.creerReservation(nouvelleReservation);

      if (success) {
        final heuresTexte = heuresSelectionnees.map((h) => '${h}h').join(', ');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${salle.nom} modifiée pour $heuresTexte'),
              backgroundColor: CouleursApp.accent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        _chargerSalles(); // Recharger les salles
      } else {
        _afficherErreur('Erreur lors de la modification');
      }
    } catch (e) {
      _afficherErreur('Erreur lors de la modification: $e');
    }
  }

  // UI Design: Vérifier si l'utilisateur a déjà une réservation active
  bool _utilisateurADejaReservation() {
    final reservationsActives = _mesReservations.where(
      (reservation) => reservation.statut != 'annulee' && 
                      reservation.statut != 'terminee' &&
                      reservation.heureDebut.isAfter(DateTime.now())
    ).toList();
    return reservationsActives.isNotEmpty;
  }



  // UI Design: Helper pour obtenir le nom d'une salle
  String _obtenirNomSalle(String salleId) {
    final salle = _salles.firstWhere(
      (s) => s.id == salleId,
      orElse: () => const Salle(
        id: '', 
        nom: 'Salle inconnue', 
        description: '',
        capaciteMax: 0,
        equipements: [],
        etage: '',
        batiment: '',
        estDisponible: false,
        tarifParHeure: 0,
      ),
    );
    return salle.nom;
  }

  // UI Design: Vérifier si une salle est disponible pour un créneau donné
  bool _estSalleDisponiblePourCreneau(String salleId, DateTime debut, DateTime fin) {
    // Vérifier les réservations existantes pour cette salle
    final reservationsConflictuelles = _mesReservations.where((reservation) {
      return reservation.salleId == salleId &&
             reservation.statut != 'annulee' &&
             reservation.statut != 'terminee' &&
             ((reservation.heureDebut.isBefore(fin) && reservation.heureFin.isAfter(debut)) ||
              (reservation.heureDebut.isAtSameMomentAs(debut) || reservation.heureFin.isAtSameMomentAs(fin)));
    }).toList();
    
    return reservationsConflictuelles.isEmpty;
  }

  // UI Design: Obtenir la réservation active de l'utilisateur
  ReservationSalle? _obtenirReservationActive() {
    final reservationsActives = _mesReservations.where(
      (reservation) => reservation.statut != 'annulee' && 
                      reservation.statut != 'terminee' &&
                      reservation.heureDebut.isAfter(DateTime.now())
    ).toList();
    return reservationsActives.isNotEmpty ? reservationsActives.first : null;
  }

  Future<void> _reserverSalleAvecHeures(Salle salle, List<int> heuresSelectionnees) async {
    // Réinitialiser la sélection
    setState(() {
      _heuresSelectionnees.clear();
    });

    final utilisateur = _authentificationService.utilisateurActuel;
    if (utilisateur == null) {
      _afficherErreur('Vous devez être connecté pour réserver');
      return;
    }

    // Vérifier si l'utilisateur a déjà une réservation active
    if (_utilisateurADejaReservation()) {
      final reservationActive = _obtenirReservationActive();
      _afficherErreur('Vous avez déjà une réservation active pour ${_obtenirNomSalle(reservationActive?.salleId ?? '')}. Vous ne pouvez avoir qu\'une seule réservation à la fois. Annulez-la d\'abord pour en créer une nouvelle.');
      return;
    }

    // Pour simplifier, on utilise la première et dernière heure comme début et fin
    heuresSelectionnees.sort();
    final heureDebut = heuresSelectionnees.first;
    final heureFin = heuresSelectionnees.last + 1; // +1 pour inclure l'heure complète
    
    final maintenant = DateTime.now();
    final dateReservation = DateTime(maintenant.year, maintenant.month, maintenant.day, heureDebut);
    final dateFin = DateTime(maintenant.year, maintenant.month, maintenant.day, heureFin);
    
    // Vérifier que la réservation est pour aujourd'hui et que l'heure n'est pas passée
    if (dateReservation.isBefore(DateTime.now())) {
      _afficherErreur('Vous ne pouvez réserver que pour des créneaux futurs aujourd\'hui');
      return;
    }
    
    // Vérifier si la salle est disponible pour ce créneau
    if (!_estSalleDisponiblePourCreneau(salle.id, dateReservation, dateFin)) {
      _afficherErreur('Cette salle n\'est pas disponible pour le créneau sélectionné');
      return;
    }
    
    try {
      final reservation = ReservationSalle(
        id: 'res_${DateTime.now().millisecondsSinceEpoch}',
        utilisateurId: utilisateur.id,
        salleId: salle.id,
        dateReservation: dateReservation,
        heureDebut: dateReservation,
        heureFin: dateFin,
        motif: 'etude_groupe',
        description: 'Réservation via l\'application',
        statut: 'en_attente',
        nombrePersonnes: 1,
        coutTotal: salle.tarifParHeure * (heureFin - heureDebut),
        dateCreation: DateTime.now(),
      );

      final success = await _reservationsSalleRepository.creerReservation(reservation);

      if (success) {
        final heuresTexte = heuresSelectionnees.map((h) => '${h}h').join(', ');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${salle.nom} réservée pour $heuresTexte'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        _chargerSalles(); // Recharger les salles
      } else {
        _afficherErreur('Erreur lors de la réservation');
      }
    } catch (e) {
      _afficherErreur('Erreur lors de la réservation: $e');
    }
  }

  Future<void> _reserverSalle(Salle salle) async {
    final utilisateur = _authentificationService.utilisateurActuel;
    if (utilisateur == null) {
      _afficherErreur('Vous devez être connecté pour réserver');
      return;
    }

    // Vérifier si l'utilisateur a déjà une réservation active
    if (_utilisateurADejaReservation()) {
      final reservationActive = _obtenirReservationActive();
      _afficherErreur('Vous avez déjà une réservation active pour ${_obtenirNomSalle(reservationActive?.salleId ?? '')}. Vous ne pouvez avoir qu\'une seule réservation à la fois. Annulez-la d\'abord pour en créer une nouvelle.');
      return;
    }

    try {
      final maintenant = DateTime.now();
      final dateReservation = DateTime(maintenant.year, maintenant.month, maintenant.day);
      final heureDebut = DateTime(maintenant.year, maintenant.month, maintenant.day, 14); // 14h
      final heureFin = DateTime(maintenant.year, maintenant.month, maintenant.day, 16); // 16h
      
      // Vérifier que la réservation est pour aujourd'hui et que l'heure n'est pas passée
      if (heureDebut.isBefore(DateTime.now())) {
        _afficherErreur('Vous ne pouvez réserver que pour des créneaux futurs aujourd\'hui');
        return;
      }

      // Vérifier si la salle est disponible pour ce créneau
      if (!_estSalleDisponiblePourCreneau(salle.id, heureDebut, heureFin)) {
        _afficherErreur('Cette salle n\'est pas disponible pour le créneau sélectionné');
        return;
      }

      final reservation = ReservationSalle(
        id: 'res_${DateTime.now().millisecondsSinceEpoch}',
        utilisateurId: utilisateur.id,
        salleId: salle.id,
        dateReservation: dateReservation,
        heureDebut: heureDebut,
        heureFin: heureFin,
        motif: 'etude_groupe',
        description: 'Réservation via l\'application',
        statut: 'en_attente',
        nombrePersonnes: 1,
        coutTotal: salle.tarifParHeure * 2, // 2 heures
        dateCreation: DateTime.now(),
      );

      final success = await _reservationsSalleRepository.creerReservation(reservation);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Salle "${salle.nom}" réservée avec succès !'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        _chargerSalles(); // Recharger les salles
      } else {
        _afficherErreur('Erreur lors de la réservation');
      }
    } catch (e) {
      _afficherErreur('Erreur lors de la réservation: $e');
    }
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // UI Design: Gérer ma réservation existante
  void _gererMaReservation(Salle salle) {
    final reservationActive = _obtenirReservationActive();
    if (reservationActive == null) {
      _afficherErreur('Aucune réservation active trouvée');
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                const Icon(Icons.event_seat, color: CouleursApp.principal, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ma réservation - ${salle.nom}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CouleursApp.texteFonce,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: CouleursApp.texteFonce),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Informations de la réservation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CouleursApp.principal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CouleursApp.principal.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Réservation actuelle :',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CouleursApp.principal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Date : ${_formaterDate(reservationActive.dateReservation)}'),
                  Text('Heure : ${_formaterHeure(reservationActive.heureDebut)} - ${_formaterHeure(reservationActive.heureFin)}'),
                  Text('Durée : ${_calculerDuree(reservationActive.heureDebut, reservationActive.heureFin)}'),
                  Text('Statut : ${reservationActive.statut}'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Actions
            ListTile(
              leading: const Icon(Icons.edit, color: CouleursApp.accent),
              title: const Text('Modifier le créneau'),
              subtitle: const Text('Changer les heures de réservation'),
              onTap: () {
                Navigator.pop(context);
                _modifierCreneauReservation(salle);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Annuler la réservation'),
              subtitle: const Text('Libérer la salle'),
              onTap: () {
                Navigator.pop(context);
                _confirmerAnnulationReservation(salle);
              },
            ),
          ],
        ),
      ),
    );
  }

  // UI Design: Helpers pour formatage
  String _formaterDate(DateTime date) {
    final maintenant = DateTime.now();
    if (date.day == maintenant.day && date.month == maintenant.month && date.year == maintenant.year) {
      return 'Aujourd\'hui';
    } else if (date.day == maintenant.day + 1 && date.month == maintenant.month && date.year == maintenant.year) {
      return 'Demain';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formaterHeure(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}h${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _calculerDuree(DateTime debut, DateTime fin) {
    final duree = fin.difference(debut);
    final heures = duree.inHours;
    final minutes = duree.inMinutes % 60;
    if (minutes == 0) {
      return '$heures heure${heures > 1 ? 's' : ''}';
    }
    return '${heures}h${minutes.toString().padLeft(2, '0')}';
  }

  // UI Design: Modifier le créneau de réservation
  void _modifierCreneauReservation(Salle salle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _construireModalCreneaux(salle, estModification: true),
    );
  }

  // UI Design: Confirmer l'annulation de réservation
  void _confirmerAnnulationReservation(Salle salle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: Text('Êtes-vous sûr de vouloir annuler votre réservation pour ${salle.nom} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _annulerReservationActive();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }



  // UI Design: Annuler la réservation active de l'utilisateur
  Future<void> _annulerReservationActive() async {
    final reservationActive = _obtenirReservationActive();
    if (reservationActive == null) {
      _afficherErreur('Aucune réservation active à annuler');
      return;
    }

    try {
      final success = await _reservationsSalleRepository.annulerReservation(reservationActive.id);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Réservation annulée avec succès'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        _chargerSalles(); // Recharger les salles
      } else {
        _afficherErreur('Erreur lors de l\'annulation');
      }
    } catch (e) {
      _afficherErreur('Erreur lors de l\'annulation: $e');
    }
  }


} 