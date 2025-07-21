import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import '../widgets/widget_carte.dart';
import '../widgets/widget_collection.dart';
import '../services/navigation_service.dart';
import '../../data/datasources/salles_datasource_local.dart';
import '../../data/repositories/salles_repository_impl.dart';
import '../../domain/entities/salle.dart';

// UI Design: Page de gestion et réservation des salles de révision
class SallesEcran extends StatefulWidget {
  const SallesEcran({Key? key}) : super(key: key);

  @override
  State<SallesEcran> createState() => _SallesEcranState();
}

class _SallesEcranState extends State<SallesEcran> {
  late SallesRepositoryImpl _sallesRepository;
  List<Salle> _salles = [];
  List<Salle> _sallesFiltrees = [];
  bool _isLoading = true;
  String _filtreActuel = 'toutes'; // 'toutes', 'disponibles', 'reservees'
  String _recherche = '';

  @override
  void initState() {
    super.initState();
    _sallesRepository = SallesRepositoryImpl(SallesDatasourceLocal());
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
            
            // Liste des salles avec gestion de l'état de chargement
            Expanded(
              child: WidgetCollection<Salle>.listeVerticale(
                elements: _sallesFiltrees,
                enChargement: _isLoading,
                constructeurElement: (context, salle, index) => _construireCarteSalle(salle),
                espacementVertical: 8, // Réduit pour les cartes compactes
                messageEtatVide: 'Aucune salle trouvée\nEssayez de modifier vos filtres',
                iconeEtatVide: Icons.meeting_room_outlined,
                padding: const EdgeInsets.symmetric(horizontal: 16),
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

  // UI Design: Carte de salle avec ancien design et créneaux horaires
  Widget _construireCarteSalle(Salle salle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec statut
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: salle.estDisponible ? CouleursApp.principal : Colors.grey,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.meeting_room,
                  color: CouleursApp.blanc,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        salle.nom,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CouleursApp.blanc,
                        ),
                      ),
                      Text(
                        '${salle.batiment} • ${salle.etage}',
                        style: TextStyle(
                          fontSize: 14,
                          color: CouleursApp.blanc.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CouleursApp.blanc.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    salle.estDisponible ? 'Disponible' : 'Réservée',
                    style: TextStyle(
                      fontSize: 12,
                      color: CouleursApp.blanc,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  salle.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: CouleursApp.texteFonce.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Informations
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: CouleursApp.principal),
                    const SizedBox(width: 4),
                    Text('${salle.capaciteMax} places', style: TextStyle(fontSize: 12, color: CouleursApp.principal)),
                    const SizedBox(width: 16),
                    Icon(Icons.schedule, size: 16, color: CouleursApp.accent),
                    const SizedBox(width: 4),
                    Text('Gratuit', style: TextStyle(fontSize: 12, color: CouleursApp.accent, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),

                // Créneaux horaires disponibles
                if (salle.estDisponible) ...[
                  Text(
                    'Heures disponibles aujourd\'hui :',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: CouleursApp.texteFonce,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _construireGrilleHeures(salle),
                  const SizedBox(height: 12),
                ],
                
                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _voirDetailsSalle(salle),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CouleursApp.principal,
                          side: BorderSide(color: CouleursApp.principal),
                        ),
                        child: const Text('Détails'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: salle.estDisponible ? () => _choisirCreneauEtReserver(salle) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: salle.estDisponible ? CouleursApp.accent : Colors.grey,
                          foregroundColor: CouleursApp.blanc,
                        ),
                        child: Text(salle.estDisponible ? 'Réserver' : 'Indisponible'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Grille d'heures disponibles
  Widget _construireGrilleHeures(Salle salle) {
    final heuresDisponibles = _genererHeuresDisponibles();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, // 6 carrés par ligne
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1.2,
      ),
      itemCount: heuresDisponibles.length,
      itemBuilder: (context, index) {
        final heure = heuresDisponibles[index];
        final estDisponible = heure['disponible'] as bool;
        
        return Container(
          decoration: BoxDecoration(
            color: estDisponible 
              ? CouleursApp.principal.withValues(alpha: 0.1) 
              : Colors.grey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: estDisponible 
                ? CouleursApp.principal.withValues(alpha: 0.4)
                : Colors.grey.withValues(alpha: 0.5),
            ),
          ),
          child: Center(
            child: Text(
              heure['heure'] as String,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: estDisponible 
                  ? CouleursApp.principal 
                  : Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }

  // Générer la liste des heures disponibles
  List<Map<String, dynamic>> _genererHeuresDisponibles() {
    final now = DateTime.now();
    final heureActuelle = now.hour;
    List<Map<String, dynamic>> heures = [];
    
    // Heures de 8h à 19h (12 heures au total)
    for (int heure = 8; heure < 20; heure++) {
      heures.add({
        'heure': '${heure}h',
        'valeur': heure,
        'disponible': heure > heureActuelle, // Disponible si dans le futur
      });
    }
    
    return heures;
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
                          : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: salle.estDisponible 
                  ? CouleursApp.accent 
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
  Set<int> _heuresSelectionnees = <int>{};

  // UI Design: Modal de sélection des heures
  Widget _construireModalCreneaux(Salle salle) {
    final heuresDisponibles = _genererHeuresDisponibles();
    
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
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
                          'Sélectionner les heures',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CouleursApp.texteFonce,
                          ),
                        ),
                        Text(
                          '${salle.nom} • Gratuit',
                          style: TextStyle(
                            fontSize: 14,
                            color: CouleursApp.texteFonce.withValues(alpha: 0.7),
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
              
              // Grille d'heures sélectionnables
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4 carrés par ligne dans le modal
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5,
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
                    ? () => _confirmerReservationHeures(salle, _heuresSelectionnees.toList())
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
            ],
          ),
        );
      },
    );
  }

  // Confirmer la réservation avec heures sélectionnées
  void _confirmerReservationHeures(Salle salle, List<int> heuresSelectionnees) {
    Navigator.pop(context);
    
    // Trier les heures
    heuresSelectionnees.sort();
    final heuresTexte = heuresSelectionnees.map((h) => '${h}h').join(', ');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la réservation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Salle : ${salle.nom}'),
            Text('Heures : $heuresTexte'),
            Text('Durée : ${heuresSelectionnees.length} heure${heuresSelectionnees.length > 1 ? 's' : ''}'),
            Text('Prix : Gratuit', style: TextStyle(color: CouleursApp.accent, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              'Confirmer cette réservation ?',
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
              _reserverSalleAvecHeures(salle, heuresSelectionnees);
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
} 