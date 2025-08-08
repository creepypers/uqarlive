import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/demande_adhesion.dart';
import '../../domain/entities/association.dart';
import '../services/adhesions_service.dart';
import '../services/authentification_service.dart';
import '../../core/di/service_locator.dart';
import '../widgets/widget_barre_app_personnalisee.dart';

// UI Design: Écran de gestion des demandes d'adhésion pour les chefs d'associations
class GestionDemandesAssociationEcran extends StatefulWidget {
  final Association association;

  const GestionDemandesAssociationEcran({
    super.key,
    required this.association,
  });

  @override
  State<GestionDemandesAssociationEcran> createState() => _GestionDemandesAssociationEcranState();
}

class _GestionDemandesAssociationEcranState extends State<GestionDemandesAssociationEcran> {
  late final AdhesionsService _adhesionsService;
  late final AuthentificationService _authentificationService;
  List<DemandeAdhesion> _demandesEnAttente = [];
  Map<String, int> _statistiques = {};
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
      final futures = await Future.wait([
        _adhesionsService.obtenirDemandesEnAttente(widget.association.id),
        _adhesionsService.obtenirStatistiquesDemandes(widget.association.id),
      ]);
      
      _demandesEnAttente = futures[0] as List<DemandeAdhesion>;
      _statistiques = futures[1] as Map<String, int>;
    } catch (e) {
      _afficherErreur('Erreur lors du chargement des données');
    }
    
    setState(() => _chargementEnCours = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: WidgetBarreAppPersonnalisee(
        titre: 'Gestion ${widget.association.nom}',
        sousTitre: 'Demandes d\'adhésion',
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
                    _construireStatistiques(),
                    const SizedBox(height: 24),
                    _construireListeDemandes(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _construireStatistiques() {
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
              Icon(Icons.analytics, color: CouleursApp.principal, size: 24),
              SizedBox(width: 12),
              Text(
                'Statistiques',
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
                '${_statistiques['enAttente'] ?? 0}',
                'En attente',
                Icons.pending,
                Colors.orange,
              ),
              _construireStatistique(
                '${_statistiques['acceptees'] ?? 0}',
                'Acceptées',
                Icons.check_circle,
                Colors.green,
              ),
              _construireStatistique(
                '${_statistiques['refusees'] ?? 0}',
                'Refusées',
                Icons.cancel,
                Colors.red,
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

  Widget _construireListeDemandes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people, color: CouleursApp.principal, size: 24),
            const SizedBox(width: 12),
            const Text(
              'Demandes en attente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CouleursApp.texteFonce,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_demandesEnAttente.length}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_demandesEnAttente.isEmpty)
          _construireAucuneDemande()
        else
          ..._demandesEnAttente.map((demande) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _construireCarteDemande(demande),
              )).toList(),
      ],
    );
  }

  Widget _construireAucuneDemande() {
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
            Icons.inbox,
            size: 48,
            color: CouleursApp.texteFonce.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune demande en attente',
            style: TextStyle(
              fontSize: 16,
              color: CouleursApp.texteFonce.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireCarteDemande(DemandeAdhesion demande) {
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
              const CircleAvatar(
                backgroundColor: CouleursApp.principal,
                child: Text(
                  'U', // TODO: Récupérer vraies initiales
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Utilisateur ${demande.utilisateurId}', // TODO: Récupérer vrai nom
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CouleursApp.texteFonce,
                      ),
                    ),
                    Text(
                      'Rôle demandé: ${demande.roledemande}',
                      style: TextStyle(
                        fontSize: 14,
                        color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formaterDate(demande.dateCreation),
                style: TextStyle(
                  fontSize: 12,
                  color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          if (demande.messageDemande != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CouleursApp.fond,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                demande.messageDemande!,
                style: const TextStyle(
                  fontSize: 14,
                  color: CouleursApp.texteFonce,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _refuserDemande(demande),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Refuser'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _accepterDemande(demande),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Accepter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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

  String _formaterDate(DateTime date) {
    final maintenant = DateTime.now();
    final difference = maintenant.difference(date).inDays;
    
    if (difference == 0) return 'Aujourd\'hui';
    if (difference == 1) return 'Hier';
    if (difference < 7) return 'Il y a $difference jours';
    
    return '${date.day}/${date.month}';
  }

  Future<void> _accepterDemande(DemandeAdhesion demande) async {
    final utilisateurActuel = _authentificationService.utilisateurActuel;
    if (utilisateurActuel == null) return;

    final success = await _adhesionsService.accepterDemande(
      demandeId: demande.id,
      chefId: utilisateurActuel.id,
      messageReponse: 'Bienvenue dans notre association !',
    );

    if (success) {
      _afficherSucces('Demande acceptée avec succès');
      _chargerDonnees();
    } else {
      _afficherErreur('Erreur lors de l\'acceptation de la demande');
    }
  }

  Future<void> _refuserDemande(DemandeAdhesion demande) async {
    final utilisateurActuel = _authentificationService.utilisateurActuel;
    if (utilisateurActuel == null) return;

    final success = await _adhesionsService.refuserDemande(
      demandeId: demande.id,
      chefId: utilisateurActuel.id,
      messageReponse: 'Nous vous remercions pour votre intérêt.',
    );

    if (success) {
      _afficherSucces('Demande refusée');
      _chargerDonnees();
    } else {
      _afficherErreur('Erreur lors du refus de la demande');
    }
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _afficherSucces(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}