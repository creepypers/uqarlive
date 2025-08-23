import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/association.dart';
import '../../../domain/entities/actualite.dart';
import '../../../domain/entities/evenement.dart';
import '../../../domain/usercases/associations_repository.dart';
import '../../../domain/usercases/actualites_repository.dart';
import '../../../domain/usercases/evenements_repository.dart';
import '../../widgets/widget_barre_app_navigation_admin.dart';
import '../../widgets/widget_carte.dart';
import '../../widgets/widget_collection.dart';
import 'admin_ajouter_association_ecran.dart';
import '../associations/details_association_ecran.dart';
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
      final actualites = await _actualitesRepository.obtenirActualites();
      final evenements = await _evenementsRepository.obtenirEvenements();
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
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      resizeToAvoidBottomInset: true, 
      appBar: const WidgetBarreAppNavigationAdmin(
        titre: 'Gestion Associations',
        sousTitre: 'Gérer les associations, actualités et événements',
        sectionActive: 'associations',
      ),
      body: SafeArea(
        child: _chargementEnCours 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: CouleursApp.blanc,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: CouleursApp.principal,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: CouleursApp.principal,
                    labelStyle: TextStyle(
                      fontSize: screenWidth * 0.035, 
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: screenWidth * 0.035, 
                      fontWeight: FontWeight.normal,
                    ),
                    tabs: [
                      Tab(
                        icon: Icon(Icons.groups, size: screenWidth * 0.06), 
                        text: 'Associations',
                      ),
                      Tab(
                        icon: Icon(Icons.newspaper, size: screenWidth * 0.06), 
                        text: 'Actualités',
                      ),
                      Tab(
                        icon: Icon(Icons.event, size: screenWidth * 0.06), 
                        text: 'Événements',
                      ),
                    ],
                  ),
                ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _ajouterAssociation(),
        backgroundColor: CouleursApp.principal,
        foregroundColor: CouleursApp.blanc,
        child: Icon(Icons.add, size: screenWidth * 0.06), 
      ),
    );
  }
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
                      onTap: () => _modifierAssociation(association), 
                      largeur: (MediaQuery.of(context).size.width - 48) / 2 - 6, 
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
                      onLongPress: () => _afficherMenuActualite(actualite),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }
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
                  return GestureDetector(
                    onLongPress: () => _afficherMenuEvenement(evenement),
                    child: Card(
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
                        ],
                      ),
                    ),
                  ),
                );
                },
              ),
        ],
      ),
    );
  }
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
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _construireDialogueAjoutActualite(),
    );
    if (result != null) {
      try {
        final nouvelleActualite = Actualite(
          id: 'actu_admin_${DateTime.now().millisecondsSinceEpoch}',
          titre: result['titre'],
          description: result['titre'],
          contenu: result['contenu'],
          associationId: result['associationId'] ?? 'admin_general',
          auteur: 'Administrateur UQAR',
          datePublication: DateTime.now(),
          priorite: result['priorite'] ?? 'normale',
          estEpinglee: result['estEpinglee'] ?? false,
          nombreVues: 0,
          nombreLikes: 0,
          tags: [],
        );
        final actualiteAjoutee = await _actualitesRepository.ajouterActualite(nouvelleActualite);
        if (mounted) {
          if (actualiteAjoutee.id.isNotEmpty) {
            _chargerDonnees();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  Future<void> _ajouterEvenement() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _construireDialogueAjoutEvenement(),
    );
    if (result != null) {
      try {
        final nouvelEvenement = Evenement(
          id: 'event_admin_${DateTime.now().millisecondsSinceEpoch}',
          titre: result['titre'],
          description: result['description'],
          typeEvenement: result['typeEvenement'] ?? 'academique',
          lieu: result['lieu'],
          organisateur: 'Administration UQAR',
          associationId: result['associationId'] ?? 'admin_general',
          dateDebut: result['dateDebut'],
          dateFin: result['dateFin'],
          estGratuit: result['estGratuit'] ?? true,
          prix: result['estGratuit'] == false ? result['tarif']?.toDouble() : null,
          inscriptionRequise: result['necessiteInscription'] ?? false,
          capaciteMaximale: result['capaciteMaximale'],
          dateCreation: DateTime.now(),
        );
        final succes = await _evenementsRepository.ajouterEvenement(nouvelEvenement);
        if (mounted) {
          if (succes) {
            _chargerDonnees();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  void _ouvrirDetailsAssociation(Association association) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailsAssociationEcran(association: association),
      ),
    );
  }
  void _afficherMenuEvenement(Evenement evenement) {
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
              evenement.titre,
              style: StylesTexteApp.moyenTitre,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: CouleursApp.principal),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                _modifierEvenement(evenement);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmerSuppressionEvenement(evenement);
              },
            ),
          ],
        ),
      ),
    );
  }
  void _afficherMenuActualite(Actualite actualite) {
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
              actualite.titre,
              style: StylesTexteApp.moyenTitre,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: CouleursApp.principal),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                _modifierActualite(actualite);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmerSuppressionActualite(actualite);
              },
            ),
          ],
        ),
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
  void _confirmerSuppressionActualite(Actualite actualite) {
    showDialog(
      context: context,
      builder: (context) => LayoutBuilder(builder: (context, constraints) {
        final w = MediaQuery.of(context).size.width * 0.9;
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: w),
          child: AlertDialog(
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
      }),
    );
  }
  void _confirmerSuppressionAssociation(Association association) {
    showDialog(
      context: context,
      builder: (context) => LayoutBuilder(builder: (context, constraints) {
        final w = MediaQuery.of(context).size.width * 0.9;
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: w),
          child: AlertDialog(
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
      }),
    );
  }
  void _supprimerAssociation(Association association) async {
    final succes = await _associationsRepository.supprimerAssociation(association.id);
    if (mounted) {
      if (succes) {
        setState(() {
          _associations.remove(association);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Association "${association.nom}" supprimée'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression de "${association.nom}"'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  Future<void> _modifierActualite(Actualite actualite) async {
    await _ouvrirDialogueModificationActualite(actualite);
  }
  Future<void> _ouvrirDialogueModificationActualite(Actualite actualite) async {
    final formKey = GlobalKey<FormState>();
    final controleurTitre = TextEditingController(text: actualite.titre);
    final controleurDescription = TextEditingController(text: actualite.description);
    String prioriteSelectionnee = actualite.priorite;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'actualité'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: controleurTitre,
                  decoration: const InputDecoration(labelText: 'Titre'),
                  validator: (value) => value?.isEmpty == true ? 'Titre requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controleurDescription,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) => value?.isEmpty == true ? 'Description requise' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: prioriteSelectionnee,
                  decoration: const InputDecoration(labelText: 'Priorité'),
                  items: ['normale', 'moyenne', 'haute', 'urgente'].map((priorite) {
                    return DropdownMenuItem(value: priorite, child: Text(priorite));
                  }).toList(),
                  onChanged: (value) => prioriteSelectionnee = value!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
    if (result == true) {
      final actualiteModifiee = Actualite(
        id: actualite.id,
        titre: controleurTitre.text,
        description: controleurDescription.text,
        contenu: actualite.contenu,
        associationId: actualite.associationId,
        auteur: actualite.auteur,
        datePublication: actualite.datePublication,
        priorite: prioriteSelectionnee,
        estEpinglee: actualite.estEpinglee,
        nombreVues: actualite.nombreVues,
        nombreLikes: actualite.nombreLikes,
      );
      try {
        await _actualitesRepository.mettreAJourActualite(actualiteModifiee);
        await _chargerDonnees();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Actualité modifiée avec succès'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la modification'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
  void _supprimerActualite(Actualite actualite) async {
    final succes = await _actualitesRepository.supprimerActualite(actualite.id);
    if (mounted) {
      if (succes) {
        setState(() {
          _actualites.remove(actualite);
        });
      }
    }
  }
  String _formaterDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
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
  Future<void> _modifierEvenement(Evenement evenement) async {
    await _ouvrirDialogueModificationEvenement(evenement);
  }
  Future<void> _ouvrirDialogueModificationEvenement(Evenement evenement) async {
    final formKey = GlobalKey<FormState>();
    final controleurTitre = TextEditingController(text: evenement.titre);
    final controleurDescription = TextEditingController(text: evenement.description);
    final controleurLieu = TextEditingController(text: evenement.lieu);
    final controleurPrix = TextEditingController(text: evenement.prix?.toString() ?? '0');
    String typeEvenementSelectionne = evenement.typeEvenement;
    DateTime dateSelectionnee = evenement.dateDebut;
    TimeOfDay heureSelectionnee = TimeOfDay.fromDateTime(evenement.dateDebut);
    bool inscriptionRequise = evenement.inscriptionRequise;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Modifier l\'événement'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: controleurTitre,
                    decoration: const InputDecoration(labelText: 'Titre'),
                    validator: (value) => value?.isEmpty == true ? 'Titre requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controleurDescription,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    validator: (value) => value?.isEmpty == true ? 'Description requise' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controleurLieu,
                    decoration: const InputDecoration(labelText: 'Lieu'),
                    validator: (value) => value?.isEmpty == true ? 'Lieu requis' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: typeEvenementSelectionne,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: ['conference', 'atelier', 'social', 'sport', 'culture', 'academique'].map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) => setDialogState(() => typeEvenementSelectionne = value!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            if (!mounted) return;
                            final date = await showDatePicker(
                              context: context,
                              initialDate: dateSelectionnee,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null && mounted) {
                              setDialogState(() => dateSelectionnee = date);
                            }
                          },
                          child: Text('Date: ${dateSelectionnee.day}/${dateSelectionnee.month}/${dateSelectionnee.year}'),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            if (!mounted) return;
                            final heure = await showTimePicker(
                              context: context,
                              initialTime: heureSelectionnee,
                            );
                            if (heure != null && mounted) {
                              setDialogState(() => heureSelectionnee = heure);
                            }
                          },
                          child: Text('Heure: ${heureSelectionnee.format(context)}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controleurPrix,
                    decoration: const InputDecoration(labelText: 'Prix (CAD)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Prix requis';
                      if (double.tryParse(value!) == null) return 'Prix invalide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Inscription requise'),
                    value: inscriptionRequise,
                    onChanged: (value) => setDialogState(() => inscriptionRequise = value!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Modifier'),
            ),
          ],
        ),
      ),
    );
    if (result == true) {
      final dateEvenement = DateTime(
        dateSelectionnee.year,
        dateSelectionnee.month,
        dateSelectionnee.day,
        heureSelectionnee.hour,
        heureSelectionnee.minute,
      );
      final evenementModifie = Evenement(
        id: evenement.id,
        titre: controleurTitre.text,
        description: controleurDescription.text,
        organisateur: evenement.organisateur,
        associationId: evenement.associationId,
        dateDebut: dateEvenement,
        dateFin: dateEvenement.add(const Duration(hours: 2)),
        lieu: controleurLieu.text,
        typeEvenement: typeEvenementSelectionne,
        dateCreation: evenement.dateCreation,
        prix: double.parse(controleurPrix.text),
        inscriptionRequise: inscriptionRequise,
      );
      try {
        await _evenementsRepository.mettreAJourEvenement(evenementModifie);
        await _chargerDonnees();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Événement modifié avec succès'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la modification'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
  void _confirmerSuppressionEvenement(Evenement evenement) {
    showDialog(
      context: context,
      builder: (context) => LayoutBuilder(builder: (context, constraints) {
        final w = MediaQuery.of(context).size.width * 0.9;
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: w),
          child: AlertDialog(
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
      }),
    );
  }
  void _supprimerEvenement(Evenement evenement) async {
    final succes = await _evenementsRepository.supprimerEvenement(evenement.id);
    if (mounted) {
      if (succes) {
        setState(() {
          _evenements.remove(evenement);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Événement "${evenement.titre}" supprimé'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression de "${evenement.titre}"'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  Widget _construireDialogueAjoutActualite() {
    final TextEditingController titreController = TextEditingController();
    final TextEditingController contenuController = TextEditingController();
    String? associationSelectionnee;
    String prioriteSelectionnee = 'normale'; 
    bool estEpinglee = false;
    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Nouvelle Actualité'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titreController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contenuController,
                decoration: const InputDecoration(
                  labelText: 'Contenu',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: prioriteSelectionnee,
                isExpanded: true, 
                decoration: const InputDecoration(
                  labelText: 'Niveau de priorité *',
                  border: OutlineInputBorder(),
                  prefixIcon:  Icon(Icons.priority_high, color: CouleursApp.principal),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'normale',
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: Colors.green, size: 16),
                        SizedBox(width: 8),
                        Text('Normale'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'moyenne',
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: Colors.orange, size: 16),
                        SizedBox(width: 8),
                        Text('Moyenne'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'haute',
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: Colors.red, size: 16),
                        SizedBox(width: 8),
                        Text('Haute'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'urgente',
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: Colors.purple, size: 16),
                        SizedBox(width: 8),
                        Text('Urgente'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    prioriteSelectionnee = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: associationSelectionnee,
                isExpanded: true, 
                decoration: const InputDecoration(
                  labelText: 'Association (optionnel)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Actualité générale'),
                  ),
                  ..._associations.map((assoc) => DropdownMenuItem(
                    value: assoc.id,
                    child: Text(assoc.nom),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    associationSelectionnee = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Épingler l\'actualité'),
                value: estEpinglee,
                onChanged: (value) {
                  setState(() {
                    estEpinglee = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titreController.text.trim().isEmpty || contenuController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez remplir tous les champs obligatoires'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.of(context).pop({
                'titre': titreController.text.trim(),
                'contenu': contenuController.text.trim(),
                'associationId': associationSelectionnee,
                'estEpinglee': estEpinglee,
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: CouleursApp.principal),
            child: const Text('Créer', style: TextStyle(color: CouleursApp.blanc)),
          ),
        ],
      ),
    );
  }
  Widget _construireDialogueAjoutEvenement() {
    final TextEditingController titreController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController lieuController = TextEditingController();
    final TextEditingController capaciteController = TextEditingController();
    final TextEditingController tarifController = TextEditingController();
    DateTime? dateDebut;
    DateTime? dateFin;
    String? associationSelectionnee;
    bool estGratuit = true;
    bool necessiteInscription = false;
    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Nouvel Événement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titreController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lieuController,
                decoration: const InputDecoration(
                  labelText: 'Lieu',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        if (!mounted) return;
                        final currentContext = context;
                        final date = await showDatePicker(
                          context: currentContext,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null && mounted) {
                          final time = await showTimePicker(
                            context: currentContext,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null && mounted) {
                            setState(() {
                              dateDebut = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                            });
                          }
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        dateDebut != null 
                          ? 'Début: ${dateDebut!.day}/${dateDebut!.month} ${dateDebut!.hour}:${dateDebut!.minute.toString().padLeft(2, '0')}'
                          : 'Date début',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        if (!mounted) return;
                        final currentContext = context;
                        final date = await showDatePicker(
                          context: currentContext,
                          initialDate: dateDebut ?? DateTime.now(),
                          firstDate: dateDebut ?? DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null && mounted) {
                          final time = await showTimePicker(
                            context: currentContext,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null && mounted) {
                            setState(() {
                              dateFin = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                            });
                          }
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        dateFin != null 
                          ? 'Fin: ${dateFin!.day}/${dateFin!.month} ${dateFin!.hour}:${dateFin!.minute.toString().padLeft(2, '0')}'
                          : 'Date fin',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: associationSelectionnee,
                isExpanded: true, 
                decoration: const InputDecoration(
                  labelText: 'Association (optionnel)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Événement général'),
                  ),
                  ..._associations.map((assoc) => DropdownMenuItem(
                    value: assoc.id,
                    child: Text(assoc.nom),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    associationSelectionnee = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: capaciteController,
                decoration: const InputDecoration(
                  labelText: 'Capacité maximale (optionnel)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Événement gratuit'),
                value: estGratuit,
                onChanged: (value) {
                  setState(() {
                    estGratuit = value ?? true;
                  });
                },
              ),
              if (!estGratuit) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: tarifController,
                  decoration: const InputDecoration(
                    labelText: 'Tarif (CAD)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
              CheckboxListTile(
                title: const Text('Inscription requise'),
                value: necessiteInscription,
                onChanged: (value) {
                  setState(() {
                    necessiteInscription = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titreController.text.trim().isEmpty || 
                  descriptionController.text.trim().isEmpty ||
                  lieuController.text.trim().isEmpty ||
                  dateDebut == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez remplir tous les champs obligatoires'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.of(context).pop({
                'titre': titreController.text.trim(),
                'description': descriptionController.text.trim(),
                'lieu': lieuController.text.trim(),
                'dateDebut': dateDebut,
                'dateFin': dateFin ?? dateDebut!.add(const Duration(hours: 2)),
                'associationId': associationSelectionnee,
                'capaciteMaximale': capaciteController.text.isEmpty ? null : int.tryParse(capaciteController.text),
                'tarif': estGratuit ? 0.0 : (tarifController.text.isEmpty ? 0.0 : double.tryParse(tarifController.text) ?? 0.0),
                'estGratuit': estGratuit,
                'necessiteInscription': necessiteInscription,
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: CouleursApp.principal),
            child: const Text('Créer', style: TextStyle(color: CouleursApp.blanc)),
          ),
        ],
      ),
    );
  }
} 