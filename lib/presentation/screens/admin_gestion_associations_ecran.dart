// UI Design: Écran de gestion des associations avec sous-sections pour actualités, événements et membres
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/association.dart';
import '../../domain/entities/actualite.dart';
import '../../domain/entities/evenement.dart';
import '../../domain/repositories/associations_repository.dart';
import '../../domain/repositories/actualites_repository.dart';
import '../../domain/repositories/evenements_repository.dart';
import '../widgets/widget_barre_app_navigation_admin.dart';
import '../widgets/widget_carte.dart';
import '../widgets/widget_collection.dart';
import 'admin_ajouter_association_ecran.dart';
import 'admin_ajouter_actualite_ecran.dart';
import 'admin_ajouter_evenement_ecran.dart';

class AdminGestionAssociationsEcran extends StatefulWidget {
  const AdminGestionAssociationsEcran({super.key});

  @override
  State<AdminGestionAssociationsEcran> createState() => _AdminGestionAssociationsEcranState();
}

class _AdminGestionAssociationsEcranState extends State<AdminGestionAssociationsEcran> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AssociationsRepository _associationsRepository;
  late ActualitesRepository _actualitesRepository;
  late EvenementsRepository _evenementsRepository;
  
  List<Association> _associations = [];
  List<Actualite> _actualites = [];
  List<Evenement> _evenements = [];
  bool _chargementEnCours = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _associationsRepository = ServiceLocator.obtenirService<AssociationsRepository>();
    _actualitesRepository = ServiceLocator.obtenirService<ActualitesRepository>();
    _evenementsRepository = ServiceLocator.obtenirService<EvenementsRepository>();
    _chargerDonnees();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _chargerDonnees() async {
    try {
      setState(() => _chargementEnCours = true);
      
      final associations = await _associationsRepository.obtenirToutesLesAssociations();
      final actualites = await _actualitesRepository.obtenirToutesLesActualites();
      final evenements = await _evenementsRepository.obtenirTousLesEvenements();
      
      setState(() {
        _associations = associations;
        _actualites = actualites;
        _evenements = evenements;
        _chargementEnCours = false;
      });
    } catch (e) {
      setState(() => _chargementEnCours = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: const WidgetBarreAppNavigationAdmin(
        titre: 'Gestion Associations',
        sousTitre: 'Gérer les associations, actualités et événements',
        sectionActive: 'associations',
      ),
      body: _chargementEnCours 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // UI Design: Barre d'onglets avec thème UQAR
              Container(
                color: CouleursApp.blanc,
                child: TabBar(
                  controller: _tabController,
                  labelColor: CouleursApp.principal,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: CouleursApp.principal,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.groups),
                      text: 'Associations',
                    ),
                    Tab(
                      icon: Icon(Icons.newspaper),
                      text: 'Actualités',
                    ),
                    Tab(
                      icon: Icon(Icons.event),
                      text: 'Événements',
                    ),
                  ],
                ),
              ),
              // UI Design: Contenu des onglets
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _construireOngletAssociations(),
                    _construireOngletActualites(),
                    _construireOngletEvenements(),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  // UI Design: Onglet des associations
  Widget _construireOngletAssociations() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Associations',
                style: StylesTexteApp.titrePage,
              ),
              ElevatedButton.icon(
                onPressed: _ajouterAssociation,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CouleursApp.principal,
                  foregroundColor: CouleursApp.blanc,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _associations.isEmpty
            ? _construireMessageVide('Aucune association', Icons.groups_outlined)
            : WidgetCollection<Association>.grille(
                elements: _associations,
                constructeurElement: (context, association, index) {
                  return GestureDetector(
                    onLongPress: () => _afficherMenuAssociation(association),
                    child: WidgetCarte.association(
                      nom: association.nom,
                      description: association.description,
                      icone: Icons.groups,
                      couleurIcone: CouleursApp.principal,
                      onTap: () => _modifierAssociation(association), // UI Design: Clic direct pour modifier
                      largeur: (MediaQuery.of(context).size.width - 48) / 2 - 6, // UI Design: Largeur calculée pour éviter le débordement
                      hauteur: 120,
                    ),
                  );
                },
                nombreColonnes: 2,
                espacementColonnes: 8,
                espacementLignes: 8,
              ),
        ],
      ),
    );
  }

  // UI Design: Onglet des actualités
  Widget _construireOngletActualites() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Actualités',
                style: StylesTexteApp.titrePage,
              ),
              ElevatedButton.icon(
                onPressed: _ajouterActualite,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CouleursApp.principal,
                  foregroundColor: CouleursApp.blanc,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _actualites.isEmpty
            ? _construireMessageVide('Aucune actualité', Icons.newspaper_outlined)
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _actualites.length,
                itemBuilder: (context, index) {
                  final actualite = _actualites[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const CircleAvatar(
                        backgroundColor: CouleursApp.principal,
                        child: Icon(
                          Icons.newspaper,
                          color: CouleursApp.blanc,
                        ),
                      ),
                      title: Text(
                        actualite.titre,
                        style: StylesTexteApp.moyenTitre,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            actualite.contenu,
                            style: StylesTexteApp.corpsGris,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Publié le ${_formaterDate(actualite.datePublication)}',
                            style: StylesTexteApp.petitGris,
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) => _gererActualite(actualite, value),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'modifier',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Modifier'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'supprimer',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Supprimer', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }

  // UI Design: Onglet des événements
  Widget _construireOngletEvenements() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Événements',
                style: StylesTexteApp.titrePage,
              ),
              ElevatedButton.icon(
                onPressed: _ajouterEvenement,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CouleursApp.principal,
                  foregroundColor: CouleursApp.blanc,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _evenements.isEmpty
            ? _construireMessageVide('Aucun événement', Icons.event_outlined)
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _evenements.length,
                itemBuilder: (context, index) {
                  final evenement = _evenements[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar de l'événement
                          CircleAvatar(
                            backgroundColor: _obtenirCouleurStatut(evenement.statutEvenement),
                            child: Icon(
                              _obtenirIconeType(evenement.typeEvenement),
                              color: CouleursApp.blanc,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Contenu principal (titre, description, détails)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  evenement.titre,
                                  style: StylesTexteApp.moyenTitre,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  evenement.description,
                                  style: StylesTexteApp.corpsGris,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                // Lieu et date
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        evenement.lieu,
                                        style: StylesTexteApp.petitGris,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formaterDate(evenement.dateDebut),
                                      style: StylesTexteApp.petitGris,
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _obtenirCouleurStatut(evenement.statutEvenement),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        evenement.statutEvenement,
                                        style: StylesTexteApp.petitBlanc,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Menu des actions
                          PopupMenuButton<String>(
                            onSelected: (value) => _gererEvenement(evenement, value),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'modifier',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Modifier'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'supprimer',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Supprimer', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }

  // UI Design: Message vide réutilisable
  Widget _construireMessageVide(String message, IconData icone) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icone,
              size: 80,
              color: CouleursApp.principal.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CouleursApp.texteFonce,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Cliquez sur "Ajouter" pour créer le premier élément',
              style: StylesTexteApp.corpsGris,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Méthodes de gestion
  Future<void> _ajouterAssociation() async {
    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminAjouterAssociationEcran(),
      ),
    );
    
    if (resultat == true) {
      _chargerDonnees(); // Recharger les données après ajout
    }
  }

  Future<void> _ajouterActualite() async {
    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminAjouterActualiteEcran(),
      ),
    );
    
    if (resultat == true) {
      _chargerDonnees(); // Recharger les données après ajout
    }
  }

  Future<void> _ajouterEvenement() async {
    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminAjouterEvenementEcran(),
      ),
    );
    
    if (resultat == true) {
      _chargerDonnees(); // Recharger les données après ajout
    }
  }

  void _ouvrirDetailsAssociation(Association association) {
    // TODO: Implémenter l'ouverture des détails d'association
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouverture des détails de ${association.nom}'),
        backgroundColor: CouleursApp.principal,
      ),
    );
  }

  void _afficherMenuAssociation(Association association) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              association.nom,
              style: StylesTexteApp.moyenTitre,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: CouleursApp.principal),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                _modifierAssociation(association);
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility, color: CouleursApp.accent),
              title: const Text('Voir les détails'),
              onTap: () {
                Navigator.pop(context);
                _ouvrirDetailsAssociation(association);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmerSuppressionAssociation(association);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _modifierAssociation(Association association) async {
    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminAjouterAssociationEcran(
          associationAModifier: association,
        ),
      ),
    );
    
    if (resultat == true) {
      _chargerDonnees(); // Recharger les données après modification
    }
  }

  void _confirmerSuppressionAssociation(Association association) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression', style: StylesTexteApp.moyenTitre),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'association "${association.nom}" ?',
          style: StylesTexteApp.corpsNormal,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: StylesTexteApp.lienPrincipal),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _supprimerAssociation(association);
            },
            child: Text(
              'Supprimer',
              style: StylesTexteApp.lienPrincipal.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _supprimerAssociation(Association association) {
    // TODO: Implémenter la suppression d'association dans le repository
    setState(() {
      _associations.remove(association);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Association "${association.nom}" supprimée'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _gererActualite(Actualite actualite, String action) {
    switch (action) {
      case 'modifier':
        _modifierActualite(actualite);
        break;
      case 'supprimer':
        _confirmerSuppressionActualite(actualite);
        break;
    }
  }

  Future<void> _modifierActualite(Actualite actualite) async {
    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminAjouterActualiteEcran(
          actualiteAModifier: actualite,
        ),
      ),
    );
    
    if (resultat == true) {
      _chargerDonnees(); // Recharger les données après modification
    }
  }

  void _confirmerSuppressionActualite(Actualite actualite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression', style: StylesTexteApp.moyenTitre),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'actualité "${actualite.titre}" ?',
          style: StylesTexteApp.corpsNormal,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: StylesTexteApp.lienPrincipal),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _supprimerActualite(actualite);
            },
            child: Text(
              'Supprimer',
              style: StylesTexteApp.lienPrincipal.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _supprimerActualite(Actualite actualite) {
    // TODO: Implémenter la suppression d'actualité
    setState(() {
      _actualites.remove(actualite);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Actualité "${actualite.titre}" supprimée'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formaterDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // UI Design: Méthodes utilitaires pour les événements
  Color _obtenirCouleurStatut(String statut) {
    switch (statut) {
      case 'À venir':
        return CouleursApp.principal;
      case 'En cours':
        return Colors.green;
      case 'Terminé':
        return Colors.grey;
      default:
        return CouleursApp.accent;
    }
  }

  IconData _obtenirIconeType(String type) {
    switch (type) {
      case 'conference':
        return Icons.mic;
      case 'atelier':
        return Icons.build;
      case 'social':
        return Icons.people;
      case 'sportif':
        return Icons.sports;
      case 'culturel':
        return Icons.theater_comedy;
      case 'academique':
        return Icons.school;
      default:
        return Icons.event;
    }
  }

  void _gererEvenement(Evenement evenement, String action) {
    switch (action) {
      case 'modifier':
        _modifierEvenement(evenement);
        break;
      case 'supprimer':
        _confirmerSuppressionEvenement(evenement);
        break;
    }
  }

  Future<void> _modifierEvenement(Evenement evenement) async {
    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminAjouterEvenementEcran(
          evenementAModifier: evenement,
        ),
      ),
    );
    
    if (resultat == true) {
      _chargerDonnees(); // Recharger les données après modification
    }
  }

  void _confirmerSuppressionEvenement(Evenement evenement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression', style: StylesTexteApp.moyenTitre),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'événement "${evenement.titre}" ?',
          style: StylesTexteApp.corpsNormal,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: StylesTexteApp.lienPrincipal),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _supprimerEvenement(evenement);
            },
            child: Text(
              'Supprimer',
              style: StylesTexteApp.lienPrincipal.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _supprimerEvenement(Evenement evenement) {
    // TODO: Implémenter la suppression d'événement dans le repository
    setState(() {
      _evenements.remove(evenement);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Événement "${evenement.titre}" supprimé'),
        backgroundColor: Colors.green,
      ),
    );
  }
} 