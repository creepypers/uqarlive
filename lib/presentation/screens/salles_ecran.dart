import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import '../widgets/widget_carte.dart';
import '../widgets/widget_collection.dart';
import '../services/navigation_service.dart';
import '../../core/di/service_locator.dart';
import '../../domain/repositories/salles_repository.dart';
import '../../domain/entities/salle.dart';

// UI Design: Page de gestion et réservation des salles de révision
class SallesEcran extends StatefulWidget {
  const SallesEcran({super.key});

  @override
  State<SallesEcran> createState() => _SallesEcranState();
}

class _SallesEcranState extends State<SallesEcran> {
  late SallesRepository _sallesRepository;
  List<Salle> _salles = [];
  List<Salle> _sallesFiltrees = [];
  bool _isLoading = true;
  String _filtreActuel = 'toutes'; // 'toutes', 'disponibles', 'reservees'
  String _recherche = '';

  @override
  void initState() {
    super.initState();
    // UI Design: Injection de dépendances via ServiceLocator - Clean Architecture
    _sallesRepository = ServiceLocator.obtenirService<SallesRepository>();
    _chargerSalles();
  }

  Future<void> _chargerSalles() async {
    setState(() => _isLoading = true);
    try {
      final salles = await _sallesRepository.obtenirToutesLesSalles();
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
        sallesFiltrees = sallesFiltrees.where((s) => s.estDisponible).toList();
        break;
      case 'reservees':
        sallesFiltrees = sallesFiltrees.where((s) => !s.estDisponible).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: WidgetBarreAppPersonnalisee(
        titre: 'Salles de Révision',
        sousTitre: '${_salles.length} salles disponibles',
        widgetFin: IconButton(
          icon: Icon(Icons.filter_list, color: CouleursApp.blanc),
          onPressed: () => _ouvrirFiltres(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barre de recherche et filtres (toujours affichées)
            _construireBarreRecherche(),
            const SizedBox(height: 8),
            _construireFiltresRapides(),
            const SizedBox(height: 16),
            
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
                  estDisponible: salle.estDisponible,
                  equipements: salle.equipements,
                  heureLibre: salle.estDisponible ? null : '14h30',
                  onTapDetails: () => _voirDetailsSalle(salle),
                  onTapReserver: () => _reserverSalle(salle),
                ),
                espacementVertical: 8,
                messageEtatVide: 'Aucune salle trouvée\nEssayez de modifier vos filtres',
                iconeEtatVide: Icons.meeting_room_outlined,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
        onChanged: (value) {
          setState(() {
            _recherche = value;
            _appliquerFiltres();
          });
        },
        decoration: InputDecoration(
          hintText: 'Rechercher une salle...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: CouleursApp.principal),
          suffixIcon: _recherche.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: CouleursApp.principal),
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
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _construireBoutonFiltre('toutes', 'Toutes (${_salles.length})'),
          const SizedBox(width: 8),
          _construireBoutonFiltre(
            'disponibles', 
            'Disponibles (${_salles.where((s) => s.estDisponible).length})'
          ),
          const SizedBox(width: 8),
          _construireBoutonFiltre(
            'reservees', 
            'Réservées (${_salles.where((s) => !s.estDisponible).length})'
          ),
        ],
      ),
    );
  }

  Widget _construireBoutonFiltre(String filtre, String label) {
    final estActif = _filtreActuel == filtre;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filtreActuel = filtre;
          _appliquerFiltres();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            fontSize: 12,
          ),
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Titre
          Text(
            salle.nom,
            style: StylesTexteApp.titre.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            '${salle.batiment} • ${salle.etage}',
            style: TextStyle(
              fontSize: 16,
              color: CouleursApp.texteFonce.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          
          // Description
          Text(
            'Description',
            style: StylesTexteApp.titre.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            salle.description,
            style: TextStyle(
              fontSize: 14,
              color: CouleursApp.texteFonce.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          
          // Équipements
          Text(
            'Équipements disponibles',
            style: StylesTexteApp.titre.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: salle.equipements.map((equipement) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    fontSize: 12,
                    color: CouleursApp.principal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          
          // Bouton réserver
          SizedBox(
            width: double.infinity,
                                  child: ElevatedButton(
                        onPressed: salle.estDisponible 
                          ? () {
                              Navigator.pop(context);
                              _choisirCreneauEtReserver(salle);
                            }
                : (salle.reserveePar == 'DUBM12345678') // Si c'est ma réservation
                  ? () {
                      Navigator.pop(context);
                      _gererMaReservation(salle);
                    }
                          : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: salle.estDisponible 
                  ? CouleursApp.accent 
                  : (salle.reserveePar == 'DUBM12345678')
                    ? CouleursApp.principal // Ma réservation
                  : Colors.grey,
                foregroundColor: CouleursApp.blanc,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                salle.estDisponible 
                  ? 'Réserver cette salle'
                  : (salle.reserveePar == 'DUBM12345678')
                    ? 'Modifier ma réservation'
                  : 'Salle indisponible',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
    final heuresDisponibles = _genererHeuresDisponibles();
    
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  Icon(Icons.schedule, color: CouleursApp.principal, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          estModification ? 'Modifier les heures' : 'Sélectionner les heures',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CouleursApp.texteFonce,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: CouleursApp.texteFonce),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Instructions
              Text(
                'Cliquez sur les heures que vous souhaitez réserver :',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CouleursApp.texteFonce,
                ),
              ),
              const SizedBox(height: 12),
              
                  // Grille d'heures sélectionnables - OPTIMISÉE pour éviter overflow
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 carrés par ligne pour plus d'espace
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
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
                                size: 16,
                              ),
                            const SizedBox(height: 2),
                            Text(
                              heure['heure'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: !estDisponible 
                                  ? Colors.grey
                                  : estSelectionne 
                                    ? CouleursApp.blanc
                                    : CouleursApp.principal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    _heuresSelectionnees.isEmpty 
                      ? 'Sélectionnez au moins une heure'
                      : 'Réserver ${_heuresSelectionnees.length} heure${_heuresSelectionnees.length > 1 ? 's' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
                  const SizedBox(height: 20), // Espace en bas pour le scroll
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
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
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
            child: Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  Future<void> _modifierReservationAvecHeures(Salle salle, List<int> heuresSelectionnees) async {
    // Réinitialiser la sélection
    setState(() {
      _heuresSelectionnees.clear();
    });

    // Pour simplifier, on utilise la première et dernière heure comme début et fin
    heuresSelectionnees.sort();
    final heureDebut = heuresSelectionnees.first;
    final heureFin = heuresSelectionnees.last + 1; // +1 pour inclure l'heure complète
    
    final maintenant = DateTime.now();
    final dateReservation = DateTime(maintenant.year, maintenant.month, maintenant.day, heureDebut);
    final dateFin = DateTime(maintenant.year, maintenant.month, maintenant.day, heureFin);
    
    // D'abord annuler l'ancienne réservation, puis créer la nouvelle
    final annulationSuccess = await _sallesRepository.annulerReservation(salle.id);
    if (!annulationSuccess) {
      _afficherErreur('Erreur lors de la modification');
      return;
    }
    
    final success = await _sallesRepository.reserverSalle(
      salle.id,
      'DUBM12345678', // ID utilisateur actuel
      DateTime.now(),
      dateReservation,
      dateFin,
    );

    if (success) {
      final heuresTexte = heuresSelectionnees.map((h) => '${h}h').join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${salle.nom} modifiée pour $heuresTexte'),
          backgroundColor: CouleursApp.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _chargerSalles(); // Recharger les salles
    } else {
      _afficherErreur('Erreur lors de la modification');
    }
  }

  Future<void> _reserverSalleAvecHeures(Salle salle, List<int> heuresSelectionnees) async {
    // Réinitialiser la sélection
    setState(() {
      _heuresSelectionnees.clear();
    });

    // Pour simplifier, on utilise la première et dernière heure comme début et fin
    heuresSelectionnees.sort();
    final heureDebut = heuresSelectionnees.first;
    final heureFin = heuresSelectionnees.last + 1; // +1 pour inclure l'heure complète
    
    final maintenant = DateTime.now();
    final dateReservation = DateTime(maintenant.year, maintenant.month, maintenant.day, heureDebut);
    final dateFin = DateTime(maintenant.year, maintenant.month, maintenant.day, heureFin);
    
    final success = await _sallesRepository.reserverSalle(
      salle.id,
      'DUBM12345678', // ID utilisateur actuel
      DateTime.now(),
      dateReservation,
      dateFin,
    );

    if (success) {
      final heuresTexte = heuresSelectionnees.map((h) => '${h}h').join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${salle.nom} réservée pour $heuresTexte (Gratuit)'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _chargerSalles(); // Recharger les salles
    } else {
      _afficherErreur('Erreur lors de la réservation');
    }
  }

  Future<void> _reserverSalle(Salle salle) async {
    // Simuler une réservation
    final success = await _sallesRepository.reserverSalle(
      salle.id,
      'DUBM12345678', // ID utilisateur actuel
      DateTime.now(),
      DateTime.now().add(const Duration(hours: 1)),
      DateTime.now().add(const Duration(hours: 3)),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Salle "${salle.nom}" réservée avec succès !'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _chargerSalles(); // Recharger les salles
    } else {
      _afficherErreur('Erreur lors de la réservation');
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
                Icon(Icons.event_seat, color: CouleursApp.principal, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ma réservation - ${salle.nom}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CouleursApp.texteFonce,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: CouleursApp.texteFonce),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Informations de la réservation
            if (salle.heureDebut != null && salle.heureFin != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CouleursApp.principal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CouleursApp.principal.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Réservation actuelle :',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CouleursApp.principal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Date : ${_formaterDate(salle.dateReservation!)}'),
                    Text('Heure : ${_formaterHeure(salle.heureDebut!)} - ${_formaterHeure(salle.heureFin!)}'),
                    Text('Durée : ${_calculerDuree(salle.heureDebut!, salle.heureFin!)}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Actions
            ListTile(
              leading: Icon(Icons.edit, color: CouleursApp.accent),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Êtes-vous sûr de vouloir annuler votre réservation pour :'),
            const SizedBox(height: 8),
            Text('• Salle : ${salle.nom}'),
            if (salle.heureDebut != null && salle.heureFin != null) ...[
              Text('• Créneau : ${_formaterHeure(salle.heureDebut!)} - ${_formaterHeure(salle.heureFin!)}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non, garder'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _annulerReservation(salle);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Oui, annuler', style: TextStyle(color: CouleursApp.blanc)),
          ),
        ],
      ),
    );
  }

  // UI Design: Annuler la réservation
  Future<void> _annulerReservation(Salle salle) async {
    final success = await _sallesRepository.annulerReservation(salle.id);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Réservation de "${salle.nom}" annulée'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _chargerSalles(); // Recharger les salles
    } else {
      _afficherErreur('Erreur lors de l\'annulation');
    }
  }
} 