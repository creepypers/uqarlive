// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../presentation/widgets/navbar_widget.dart';
import '../../../presentation/widgets/widget_barre_app_personnalisee.dart';
import '../../../presentation/services/navigation_service.dart';
import '../../../presentation/services/authentification_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/utilisateur.dart';
import '../../../domain/entities/livre.dart';
import '../../../domain/entities/association.dart';
import '../../../domain/usercases/livres_repository.dart';
import '../../../domain/usercases/associations_repository.dart';

import '../../../domain/usercases/membres_association_repository.dart';
import '../../../domain/entities/reservation_salle.dart';
import '../../../domain/usercases/reservations_salle_repository.dart';

import 'modifier_profil_ecran.dart';
import '../livres/gerer_livres_ecran.dart';
import '../salles_ecran.dart';
import '../associations/details_association_ecran.dart';
import 'connexion_ecran.dart';



class ProfilEcran extends StatefulWidget {
  const ProfilEcran({super.key});

  @override
  State<ProfilEcran> createState() => _ProfilEcranState();
}

class _ProfilEcranState extends State<ProfilEcran> {
  late AuthentificationService _authentificationService;
  late LivresRepository _livresRepository;
  late AssociationsRepository _associationsRepository;
  late MembresAssociationRepository _membresAssociationRepository;
  late ReservationsSalleRepository _reservationsSalleRepository;

  Utilisateur? _utilisateurActuel;
  List<Livre> _mesLivres = [];

  List<Association> _mesAssociations = [];
  List<ReservationSalle> _mesReservations = [];
  // Stocker les informations de membership pour les badges
  final Map<String, String> _rolesAssociations = {};
  int _nombreLivresEnVente = 0;
  int _nombreLivresEchanges = 0;
  int _nombreAssociations = 0;
  bool _chargementEnCours = true;

  @override
  void initState() {
    super.initState();
    _authentificationService = ServiceLocator.obtenirService<AuthentificationService>();
    _livresRepository = ServiceLocator.obtenirService<LivresRepository>();
    _associationsRepository = ServiceLocator.obtenirService<AssociationsRepository>();
    _membresAssociationRepository = ServiceLocator.obtenirService<MembresAssociationRepository>();
    _reservationsSalleRepository = ServiceLocator.obtenirService<ReservationsSalleRepository>();

    _chargerUtilisateurActuel();
  }

  Future<void> _chargerUtilisateurActuel() async {
    setState(() => _chargementEnCours = true);
    await _authentificationService.chargerUtilisateurActuel();
    _utilisateurActuel = _authentificationService.utilisateurActuel;
    
    if (_utilisateurActuel != null) {
              await Future.wait([
          _chargerStatistiques(),
          _chargerMesAssociations(),
          _chargerMesReservations(),
        ]);
    }
    
    setState(() => _chargementEnCours = false);
  }

  
  Future<void> _chargerStatistiques() async {
    if (_utilisateurActuel == null) return;
    
    try {
      // Charger tous les livres de l'utilisateur
      _mesLivres = await _livresRepository.obtenirLivresParProprietaire(_utilisateurActuel!.id);
      
      // Calculer les statistiques
      _nombreLivresEnVente = _mesLivres.where((livre) => livre.prix != null && livre.prix! > 0).length;
      _nombreLivresEchanges = _mesLivres.where((livre) => !livre.estDisponible).length;
      
      // Le nombre d'associations sera calculé lors du chargement des vraies associations
      _nombreAssociations = _mesAssociations.length;
    } catch (e) {
      // Gérer l'erreur si nécessaire
    }
  }

  
  Future<void> _chargerMesAssociations() async {
    if (_utilisateurActuel == null) return;
    
    try {
      // Récupérer les memberships de l'utilisateur
      final memberships = await _membresAssociationRepository.obtenirMembresParUtilisateur(_utilisateurActuel!.id);
      
      // Récupérer les détails des associations pour chaque membership
      final List<Association> associations = [];
      _rolesAssociations.clear(); // Réinitialiser les rôles
      
      for (final membership in memberships) {
        try {
          final toutesAssociations = await _associationsRepository.obtenirAssociationsPopulaires(limite: 50);
          final association = toutesAssociations.firstWhere(
            (assoc) => assoc.id == membership.associationId,
            orElse: () => throw Exception('Association non trouvée'),
          );
          associations.add(association);
          
          // Stocker le rôle formaté de l'utilisateur dans cette association
          _rolesAssociations[association.id] = membership.roleFormate;
        } catch (e) {
          // Ignorer si l'association n'est pas trouvée
        }
      }
      
      _mesAssociations = associations;
      _nombreAssociations = _mesAssociations.length;
    } catch (e) {
      _mesAssociations = [];
      _nombreAssociations = 0;
      _rolesAssociations.clear();
    }
  }

  

  
  Future<void> _chargerMesReservations() async {
    if (_utilisateurActuel == null) return;
    
    try {
      // Récupérer les vraies réservations de l'utilisateur
      _mesReservations = await _reservationsSalleRepository.obtenirReservationsParUtilisateur(_utilisateurActuel!.id);
      
      // Filtrer pour ne garder que les réservations futures et actuelles
      final maintenant = DateTime.now();
      _mesReservations = _mesReservations.where((reservation) => 
        reservation.dateReservation.isAfter(maintenant.subtract(const Duration(days: 1)))
      ).toList();
      
    } catch (e) {
      _mesReservations = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;
    
    
    if (_chargementEnCours || _utilisateurActuel == null) {
      return const Scaffold(
        backgroundColor: CouleursApp.fond,
        resizeToAvoidBottomInset: true, 
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      resizeToAvoidBottomInset: true, 
      appBar: WidgetBarreAppPersonnalisee(
        titre: '${_utilisateurActuel!.prenom} ${_utilisateurActuel!.nom}', 
        sousTitre: '${_utilisateurActuel!.codeEtudiant}\n${_utilisateurActuel!.programme}', 
        hauteurBarre: 140,
        afficherProfil: false,
        afficherBoutonRetour: true,
        utilisateurConnecte: _utilisateurActuel, 
        widgetFin: Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: CouleursApp.blanc,
              width: 3,
            ),
            gradient: const LinearGradient(
              colors: [
                CouleursApp.accent,
                CouleursApp.principal,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _authentificationService.obtenirInitiales(), 
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CouleursApp.blanc,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: padding.bottom + viewInsets.bottom + 16, 
            left: 16,
            right: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02), 
              
              // Section statistiques dynamiques - UI Design: Basées sur l'utilisateur connecté
              Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02), 
                padding: EdgeInsets.all(screenWidth * 0.04), 
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CouleursApp.accent.withValues(alpha: 0.1), 
                      CouleursApp.principal.withValues(alpha: 0.1)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: CouleursApp.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _construireStatistique('$_nombreLivresEchanges', 'Livres\néchangés', Icons.swap_horiz, CouleursApp.principal),
                    _construireStatistique('$_nombreAssociations', 'Associations\nrejointes', Icons.groups, CouleursApp.accent),
                    _construireStatistique(
                      _calculerDureeInscription(),
                      'Mois\nà l\'UQAR', 
                      Icons.school, 
                      CouleursApp.principal
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03), 
              
              // Section mes livres - VERSION OPTIMISÉE
              _construireSectionLivres(context),
              SizedBox(height: screenHeight * 0.03), 
              
              // Section mes réservations - MISE À JOUR
              _construireSectionReservations(context),
              SizedBox(height: screenHeight * 0.03), 
              
              // Section mes associations - VERSION OPTIMISÉE
              _construireSectionAssociations(context),
              SizedBox(height: screenHeight * 0.03), 
              
              // Section actions - BOUTONS PRINCIPAUX
              _construireSectionActions(context),
              SizedBox(height: screenHeight * 0.02), 
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBarWidget(
        indexSelectionne: 2, // Index pour le profil
        onTap: (index) => NavigationService.gererNavigationNavBar(context, index),
      ),
    );
  }

  
  String _formaterDate(DateTime date) {
    final maintenant = DateTime.now();
    final difference = date.difference(maintenant).inDays;
    
    if (difference == 0) return 'Aujourd\'hui';
    if (difference == 1) return 'Demain';
    if (difference == 2) return 'Après-demain';
    
    return '${date.day}/${date.month}';
  }

  
  String _obtenirNomSalle(String salleId) {
    final nomsDesalles = {
      'salle_001': 'Salle A-101',
      'salle_002': 'Salle A-102', 
      'salle_003': 'Salle C-302',
      'salle_004': 'Salle B-201',
      'salle_005': 'Laboratoire B-205',
      'salle_006': 'Amphithéâtre',
      'salle_007': 'Salle de conférence',
    };
    return nomsDesalles[salleId] ?? 'Salle inconnue';
  }

  
  Color _obtenirCouleurStatutReservation(String statut) {
    switch (statut) {
      case 'Confirmée':
        return Colors.green;
      case 'En attente':
        return Colors.orange;
      case 'Annulée':
        return Colors.red;
      case 'Terminée':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  
  String _formaterHeure(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }


  // Actions - OPTIMISÉES
  void _ouvrirModifierProfil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModifierProfilEcran(utilisateur: _utilisateurActuel),
      ),
    );
  }

  // Ouvrir une association spécifique
  void _ouvrirAssociation(Association association) {
    // Navigation vers l'écran de détails de l'association spécifique
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsAssociationEcran(association: association),
      ),
    );
  }

  void _deconnecter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              
              await _authentificationService.deconnecter();
              
              // Retour à l'écran de connexion
              if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Déconnexion réussie'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const ConnexionEcran()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Se déconnecter', style: TextStyle(color: CouleursApp.blanc)),
          ),
        ],
      ),
    );
  }



  
  Widget _construireStatistique(String valeur, String label, IconData icone, Color couleur) {
    return Flexible( 
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
              color: couleur.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, size: 24, color: couleur),
          ),
          const SizedBox(height: 8),
          Text(
            valeur,
                    style: TextStyle(
              fontSize: 20,
                      fontWeight: FontWeight.bold,
              color: couleur,
            ),
            overflow: TextOverflow.ellipsis, 
            maxLines: 1,
          ),
            Text(
            label,
              style: TextStyle(
              fontSize: 11,
              color: CouleursApp.texteFonce.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis, 
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  
  Widget _construireSectionLivres(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02), 
      padding: EdgeInsets.all(screenWidth * 0.04), 
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book, color: CouleursApp.principal, size: 24),
              const SizedBox(width: 12),
              Expanded( 
                child: Text(
                  'Mes Livres', 
                  style: StylesTexteApp.titre.copyWith(fontSize: 18),
                  overflow: TextOverflow.ellipsis, 
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _construireInfoLivre('${_mesLivres.where((l) => l.estDisponible && (l.prix == null || l.prix == 0)).length}', 'Disponibles', CouleursApp.accent),
              _construireInfoLivre('$_nombreLivresEchanges', 'En cours', Colors.orange),
              _construireInfoLivre('${_mesLivres.length}', 'Total', Colors.green),
              _construireInfoLivre('$_nombreLivresEnVente', 'Vendus', Colors.orange),
            ],
          ),
          const SizedBox(height: 20),
          
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CouleursApp.principal.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CouleursApp.principal.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.menu_book, color: CouleursApp.principal, size: 20),
                    SizedBox(width: 8),
                    Expanded( 
                      child: Text(
                        'Mes Livres Récents',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CouleursApp.principal,
                        ),
                        overflow: TextOverflow.ellipsis, 
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Liste des livres récents (tous types)
                if (_mesLivres.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Aucun livre ajouté',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  ..._mesLivres.take(3).map((livre) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: GestureDetector(
                      onLongPress: () => _gererLivreEnVente(livre),
                      child: _construireLivreEnVente(
                        livre.titre,
                        livre.prix != null && livre.prix! > 0 
                          ? '\$${livre.prix!.toStringAsFixed(2)}' 
                          : 'Gratuit',
                        livre.estDisponible 
                          ? (livre.prix != null && livre.prix! > 0 ? 'En vente' : 'Disponible')
                          : 'Vendu',
                      ),
                    ),
                  )).toList(),
                
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GererLivresEcran()),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: CouleursApp.principal),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Ajouter un livre',
                      style: TextStyle(
                        color: CouleursApp.principal,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _construireInfoLivre(String nombre, String type, Color couleur) {
    return Flexible( 
      child: Column(
        children: [
          Text(
            nombre,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: couleur),
            overflow: TextOverflow.ellipsis, 
            maxLines: 1,
          ),
          Text(
            type,
            style: TextStyle(fontSize: 12, color: CouleursApp.texteFonce.withValues(alpha: 0.6)),
            overflow: TextOverflow.ellipsis, 
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  
  Widget _construireSectionReservations(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    // Filtrer les réservations actives (non annulées, non terminées, futures)
    final reservationsActives = _mesReservations.where((reservation) {
      return reservation.statut != 'annulee' && 
             reservation.statut != 'terminee' &&
             reservation.heureDebut.isAfter(DateTime.now());
    }).toList();
    
    // Ne garder que la réservation la plus récente (une seule réservation active)
    final reservationActive = reservationsActives.isNotEmpty 
        ? [reservationsActives.reduce((a, b) => a.dateCreation.isAfter(b.dateCreation) ? a : b)]
        : <ReservationSalle>[];
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02), 
      padding: EdgeInsets.all(screenWidth * 0.04), 
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_seat, color: CouleursApp.accent, size: 24),
              const SizedBox(width: 12),
              Expanded( 
                child: Text(
                  'Mes Réservations', 
                  style: StylesTexteApp.titre.copyWith(fontSize: 18),
                  overflow: TextOverflow.ellipsis, 
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Liste des réservations actives
          if (reservationActive.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_seat_outlined,
                      color: Colors.grey,
                      size: 48,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Aucune réservation active',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Réservez une salle pour commencer',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...reservationActive.map((reservation) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _construireReservationModerne(
                reservation,
              ),
            )).toList(),
          
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SallesEcran()),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: CouleursApp.accent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Réserver une salle',
                style: TextStyle(
                  color: CouleursApp.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _construireReservationModerne(ReservationSalle reservation) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: CouleursApp.fond,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _obtenirCouleurStatutReservation(reservation.statut).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: _obtenirCouleurStatutReservation(reservation.statut).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.meeting_room,
                  color: _obtenirCouleurStatutReservation(reservation.statut),
                  size: screenWidth * 0.05,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _obtenirNomSalle(reservation.salleId),
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                        color: CouleursApp.texteFonce,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Text(
                      '${_formaterDate(reservation.dateReservation)} • ${_formaterHeure(reservation.heureDebut)} - ${_formaterHeure(reservation.heureFin)}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.025,
                  vertical: screenWidth * 0.015,
                ),
                decoration: BoxDecoration(
                  color: _obtenirCouleurStatutReservation(reservation.statut).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _obtenirLibelleStatut(reservation.statut),
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: _obtenirCouleurStatutReservation(reservation.statut),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (reservation.description != null) ...[
            SizedBox(height: screenWidth * 0.02),
            Text(
              reservation.description!,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  
  String _obtenirLibelleStatut(String statut) {
    switch (statut) {
      case 'en_attente':
        return 'En attente';
      case 'confirmee':
        return 'Confirmée';
      case 'annulee':
        return 'Annulée';
      case 'terminee':
        return 'Terminée';
      default:
        return statut;
    }
  }

  
  Widget _construireLivreEnVente(String titre, String prix, String statut) {
    return Row(
      children: [
        const Icon(Icons.menu_book, color: CouleursApp.principal, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titre,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: CouleursApp.texteFonce),
                overflow: TextOverflow.ellipsis, 
                maxLines: 1,
              ),
              Text(
                prix,
                style: const TextStyle(fontSize: 12, color: CouleursApp.accent, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis, 
                maxLines: 1,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statut == 'En vente' ? Colors.green.withValues(alpha: 0.1) :
                statut == 'Vendu' ? Colors.orange.withValues(alpha: 0.1) :
                statut == 'Disponible' ? Colors.blue.withValues(alpha: 0.1) :
                Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statut,
            style: TextStyle(
              fontSize: 11,
              color: statut == 'En vente' ? Colors.green :
                     statut == 'Vendu' ? Colors.orange :
                     statut == 'Disponible' ? Colors.blue :
                     Colors.grey,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis, 
            maxLines: 1,
          ),
        ),
        // Supprimé le bouton kebab - remplacé par long press
      ],
    );
  }

  void _gererLivreEnVente(Livre livre) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Livre - ${livre.titre}', style: StylesTexteApp.titre.copyWith(fontSize: 18)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: CouleursApp.accent),
              title: const Text('Modifier le prix'),
              onTap: () {
                Navigator.pop(context);
                _modifierPrixLivre(livre);
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_shopping_cart, color: Colors.orange),
              title: const Text('Retirer de la vente'),
              onTap: () {
                Navigator.pop(context);
                _retirerDeLaVente(livre);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _modifierPrixLivre(Livre livre) {
    final prixController = TextEditingController(text: livre.prix?.toString() ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le prix'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Livre: ${livre.titre}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: prixController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nouveau prix (\$)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _sauvegarderNouveauPrix(livre, double.tryParse(prixController.text) ?? 0.0);
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  Future<void> _sauvegarderNouveauPrix(Livre livre, double nouveauPrix) async {
    try {
      
      final livreModifie = livre.copyWith(prix: nouveauPrix);

      await _livresRepository.modifierLivre(livreModifie);
      
      
      final index = _mesLivres.indexWhere((l) => l.id == livre.id);
      if (index != -1) {
        _mesLivres[index] = livreModifie;
      }
      
      
      await _rechargerDonnees();
      
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prix de "${livre.titre}" mis à jour avec succès !'),
          backgroundColor: CouleursApp.accent,
        ),
      );
    } catch (e) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _retirerDeLaVente(Livre livre) async {
    try {
      
      final livreModifie = livre.copyWith(estDisponible: false);

      await _livresRepository.modifierLivre(livreModifie);
      
      
      final index = _mesLivres.indexWhere((l) => l.id == livre.id);
      if (index != -1) {
        _mesLivres[index] = livreModifie;
      }
      
      
      await _rechargerDonnees();
      
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${livre.titre}" retiré de la vente avec succès !'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du retrait: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  
  Future<void> _rechargerDonnees() async {
    try {
      await Future.wait([
        _chargerStatistiques(),
        _chargerMesAssociations(),
        _chargerMesReservations(),
      ]);
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }

  
  Widget _construireSectionAssociations(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02), 
      padding: EdgeInsets.all(screenWidth * 0.04), 
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups, color: CouleursApp.principal, size: 24),
              const SizedBox(width: 12),
              Expanded( 
                child: Text(
                  'Mes Associations', 
                  style: StylesTexteApp.titre.copyWith(fontSize: 18),
                  overflow: TextOverflow.ellipsis, 
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Affichage des vraies associations
          if (_mesAssociations.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Aucune association rejointe',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ...List.generate(_mesAssociations.length, (index) {
              final association = _mesAssociations[index];
              final couleurs = [CouleursApp.principal, CouleursApp.accent, Colors.purple, Colors.orange, Colors.green];
              final couleur = couleurs[index % couleurs.length];
              final icones = [Icons.school, Icons.camera_alt, Icons.groups_2, Icons.sports, Icons.science];
              final icone = icones[index % icones.length];
               
               // Obtenir le rôle de l'utilisateur dans cette association
               final role = _rolesAssociations[association.id] ?? 'Membre';
              
              return Padding(
                padding: EdgeInsets.only(bottom: index < _mesAssociations.length - 1 ? 12.0 : 0),
                 child: InkWell(
                   onTap: () => _ouvrirAssociation(association),
                   borderRadius: BorderRadius.circular(8),
                child: _construireAssociation(
                  association.nom,
                     role, // Rôle dynamique depuis le membership
                  icone,
                  couleur,
                   ),
                ),
              );
            }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => NavigationService.gererNavigationNavBar(context, 3),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: CouleursApp.accent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                 'Voir mes associations',
                style: TextStyle(color: CouleursApp.accent, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _construireAssociation(String nom, String statut, IconData icone, Color couleur) {
    return Row(
      children: [
        Icon(icone, color: couleur, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nom,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: CouleursApp.texteFonce),
                overflow: TextOverflow.ellipsis, 
                maxLines: 1,
              ),
              Text(
                statut,
                style: TextStyle(fontSize: 12, color: CouleursApp.texteFonce.withValues(alpha: 0.6)),
                overflow: TextOverflow.ellipsis, 
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  
  String _calculerDureeInscription() {
    if (_utilisateurActuel == null) return '0';
    final difference = DateTime.now().difference(_utilisateurActuel!.dateInscription);
    return (difference.inDays / 30).round().toString();
  }

  
  Widget _construireSectionActions(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02), 
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _ouvrirModifierProfil(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: CouleursApp.accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Modifier le profil',
                style: TextStyle(
                  color: CouleursApp.blanc,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _deconnecter(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Se déconnecter',
                style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
