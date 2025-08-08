import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/association.dart';

import '../services/adhesions_service.dart';
import '../services/authentification_service.dart';
import '../../core/di/service_locator.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import 'gestion_demandes_association_ecran.dart';

// UI Design: Tableau de bord complet pour les chefs d'associations
class TableauBordChefAssociationEcran extends StatefulWidget {
  const TableauBordChefAssociationEcran({super.key});

  @override
  State<TableauBordChefAssociationEcran> createState() => _TableauBordChefAssociationEcranState();
}

class _TableauBordChefAssociationEcranState extends State<TableauBordChefAssociationEcran> {
  late final AdhesionsService _adhesionsService;
  late final AuthentificationService _authentificationService;
  List<Association> _mesAssociations = [];
  final Map<String, int> _demandesEnAttente = {};
  bool _chargementEnCours = true;

  @override
  void initState() {
    super.initState();
    _adhesionsService = ServiceLocator.obtenirService<AdhesionsService>();
    _authentificationService = ServiceLocator.obtenirService<AuthentificationService>();
    _adhesionsService.initialiser();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    setState(() => _chargementEnCours = true);
    
    try {
      final utilisateur = _authentificationService.utilisateurActuel;
      if (utilisateur == null) return;

      // Obtenir les associations gérées par l'utilisateur
      final associationsGerees = await _adhesionsService.obtenirAssociationsGerees(utilisateur.id);
      
      // TODO: Remplacer par vraie récupération des associations
      // Pour l'instant, on simule avec les données hardcodées
      _mesAssociations = _simulerAssociations(associationsGerees);
      
      // Compter les demandes en attente pour chaque association
      for (final asso in _mesAssociations) {
        final count = await _adhesionsService.compterDemandesEnAttente(asso.id);
        _demandesEnAttente[asso.id] = count;
      }
    } catch (e) {
      _afficherErreur('Erreur lors du chargement des données');
    }
    
    setState(() => _chargementEnCours = false);
  }

  List<Association> _simulerAssociations(List<String> idsAssociations) {
    final associations = <Association>[];
    
    for (final id in idsAssociations) {
      switch (id) {
        case 'asso_001':
          associations.add(Association(
            id: id,
            nom: 'AEI',
            description: 'Association des étudiants en informatique',
            typeAssociation: 'etudiante',
            president: 'Alexandre Martin',
            nombreMembres: 45,
            email: 'aei@uqar.ca',
            dateCreation: DateTime(2020, 9, 1),
            estActive: true,
            chefId: 'etud_001',
            activites: ['Programmation', 'Hackathons', 'Conférences tech'],
          ));
          break;
        case 'asso_002':
          associations.add(Association(
            id: id,
            nom: 'Club Photo UQAR',
            description: 'Club de photographie pour étudiants passionnés',
            typeAssociation: 'culturelle',
            president: 'Sophie Gagnon',
            nombreMembres: 28,
            email: 'photo@uqar.ca',
            dateCreation: DateTime(2019, 1, 15),
            estActive: true,
            chefId: 'etud_006',
            activites: ['Séances photo', 'Expositions', 'Concours'],
          ));
          break;
        case 'asso_004':
          associations.add(Association(
            id: id,
            nom: 'AGE',
            description: 'Association générale des étudiants',
            typeAssociation: 'academique',
            president: 'Alexandre Martin',
            nombreMembres: 150,
            email: 'age@uqar.ca',
            dateCreation: DateTime(2018, 8, 20),
            estActive: true,
            chefId: 'etud_001',
            activites: ['Défense droits', 'Représentation', 'Événements'],
          ));
          break;
      }
    }
    
    return associations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: const WidgetBarreAppPersonnalisee(
        titre: 'Gestion Associations',
        sousTitre: 'Tableau de bord chef',
        afficherBoutonRetour: true,
        hauteurBarre: 120,
      ),
      body: _chargementEnCours
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _chargerDonnees,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _construireResume(),
                    const SizedBox(height: 24),
                    _construireListeAssociations(),
                    const SizedBox(height: 24),
                    _construireActionsRapides(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _construireResume() {
    final totalDemandes = _demandesEnAttente.values.fold(0, (sum, count) => sum + count);
    
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Row(
            children: [
              Icon(Icons.dashboard, color: CouleursApp.principal, size: 24),
              SizedBox(width: 12),
              Text(
                'Résumé',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CouleursApp.texteFonce,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _construireStatistique(
                '${_mesAssociations.length}',
                'Associations\ngérées',
                Icons.groups,
                CouleursApp.principal,
              ),
              _construireStatistique(
                '$totalDemandes',
                'Demandes\nen attente',
                Icons.pending_actions,
                totalDemandes > 0 ? Colors.orange : Colors.grey,
              ),
              _construireStatistique(
                '${_mesAssociations.fold(0, (sum, a) => sum + a.nombreMembres)}',
                'Membres\ntotal',
                Icons.people,
                CouleursApp.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construireStatistique(String valeur, String label, IconData icone, Color couleur) {
    return Column(
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
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: CouleursApp.texteFonce.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _construireListeAssociations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.business, color: CouleursApp.principal, size: 24),
            SizedBox(width: 12),
            Text(
              'Mes Associations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CouleursApp.texteFonce,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_mesAssociations.isEmpty)
          _construireAucuneAssociation()
        else
          ..._mesAssociations.map((association) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _construireCarteAssociation(association),
              )).toList(),
      ],
    );
  }

  Widget _construireAucuneAssociation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CouleursApp.principal.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.business_center,
            size: 48,
            color: CouleursApp.texteFonce.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune association à gérer',
            style: TextStyle(
              fontSize: 16,
              color: CouleursApp.texteFonce.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireCarteAssociation(Association association) {
    final demandesCount = _demandesEnAttente[association.id] ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _obtenirCouleurType(association.typeAssociation).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _obtenirIconeType(association.typeAssociation),
                  color: _obtenirCouleurType(association.typeAssociation),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      association.nom,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CouleursApp.texteFonce,
                      ),
                    ),
                    Text(
                      '${association.nombreMembres} membres',
                      style: TextStyle(
                        fontSize: 14,
                        color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (demandesCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$demandesCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            association.description,
            style: TextStyle(
              fontSize: 14,
              color: CouleursApp.texteFonce.withValues(alpha: 0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _ouvrirGestionDemandes(association),
                  icon: const Icon(Icons.group_add, size: 18),
                  label: Text('Demandes ($demandesCount)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: demandesCount > 0 ? Colors.orange : Colors.grey,
                    side: BorderSide(color: demandesCount > 0 ? Colors.orange : Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _gererAssociation(association),
                  icon: const Icon(Icons.settings, size: 18),
                  label: const Text('Gérer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _obtenirCouleurType(association.typeAssociation),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construireActionsRapides() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.flash_on, color: CouleursApp.principal, size: 24),
            SizedBox(width: 12),
            Text(
              'Actions Rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CouleursApp.texteFonce,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _construireActionRapide(
              'Voir toutes\nles demandes',
              Icons.pending_actions,
              Colors.orange,
              () => _voirToutesLesDemandes(),
            ),
            _construireActionRapide(
              'Statistiques\ngénérales',
              Icons.analytics,
              CouleursApp.accent,
              () => _voirStatistiques(),
            ),
            _construireActionRapide(
              'Gérer les\nmembres',
              Icons.people_alt,
              Colors.green,
              () => _gererMembres(),
            ),
            _construireActionRapide(
              'Paramètres\nassociation',
              Icons.tune,
              CouleursApp.principal,
              () => _parametresAssociation(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _construireActionRapide(String titre, IconData icone, Color couleur, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CouleursApp.blanc,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: couleur.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icone, color: couleur, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: CouleursApp.texteFonce,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _obtenirCouleurType(String type) {
    switch (type) {
      case 'etudiante':
        return CouleursApp.principal;
      case 'culturelle':
        return Colors.purple;
      case 'sportive':
        return Colors.green;
      case 'academique':
        return CouleursApp.accent;
      default:
        return Colors.grey;
    }
  }

  IconData _obtenirIconeType(String type) {
    switch (type) {
      case 'etudiante':
        return Icons.school;
      case 'culturelle':
        return Icons.palette;
      case 'sportive':
        return Icons.sports;
      case 'academique':
        return Icons.menu_book;
      default:
        return Icons.group;
    }
  }

  // Actions
  void _ouvrirGestionDemandes(Association association) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GestionDemandesAssociationEcran(association: association),
      ),
    );
  }

  void _gererAssociation(Association association) {
    _afficherInfo('Gestion détaillée de ${association.nom} - À implémenter');
  }

  void _voirToutesLesDemandes() {
    _afficherInfo('Vue globale des demandes - À implémenter');
  }

  void _voirStatistiques() {
    _afficherInfo('Statistiques détaillées - À implémenter');
  }

  void _gererMembres() {
    _afficherInfo('Gestion des membres - À implémenter');
  }

  void _parametresAssociation() {
    _afficherInfo('Paramètres association - À implémenter');
  }

  // Messages
  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _afficherInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: CouleursApp.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}