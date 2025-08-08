// UI Design: Écran de gestion d'association pour les chefs
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/association.dart';
import '../../domain/entities/demande_adhesion.dart';
import '../../presentation/services/adhesions_service.dart';
import '../../core/di/service_locator.dart';
import 'ajouter_actualite_ecran.dart';
import 'ajouter_evenement_ecran.dart';

class GestionAssociationEcran extends StatefulWidget {
  final Association association;

  const GestionAssociationEcran({
    Key? key,
    required this.association,
  }) : super(key: key);

  @override
  State<GestionAssociationEcran> createState() => _GestionAssociationEcranState();
}

class _GestionAssociationEcranState extends State<GestionAssociationEcran> {
  late final AdhesionsService _adhesionsService;
  List<DemandeAdhesion> _demandesAdhesion = [];
  bool _chargement = true;

  @override
  void initState() {
    super.initState();
    _adhesionsService = ServiceLocator.obtenirService<AdhesionsService>();
    _chargerDemandesAdhesion();
  }

  Future<void> _chargerDemandesAdhesion() async {
    setState(() {
      _chargement = true;
    });

    // TODO: Implémenter la récupération des demandes d'adhésion
    // Pour l'instant, on utilise des données simulées
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _demandesAdhesion = [
        // Données simulées pour tester l'interface
        DemandeAdhesion(
          id: 'demande_001',
          utilisateurId: 'etud_002',
          associationId: widget.association.id,
          statut: 'en_attente',
          dateCreation: DateTime.now().subtract(const Duration(days: 2)),
          messageDemande: 'Je souhaite rejoindre cette association pour participer aux activités.',
          roledemande: 'membre',
        ),
        DemandeAdhesion(
          id: 'demande_002',
          utilisateurId: 'etud_003',
          associationId: widget.association.id,
          statut: 'en_attente',
          dateCreation: DateTime.now().subtract(const Duration(days: 1)),
          messageDemande: 'Passionné par les activités de cette association.',
          roledemande: 'benevole',
        ),
      ];
      _chargement = false;
    });
  }

  Future<void> _repondreDemande(DemandeAdhesion demande, bool accepter) async {
    try {
      // TODO: Implémenter l'acceptation/rejet des demandes
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accepter ? 'Demande acceptée avec succès !' : 'Demande rejetée.'),
          backgroundColor: accepter ? Colors.green : Colors.orange,
        ),
      );
      _chargerDemandesAdhesion(); // Recharger la liste
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _ajouterActualite() async {
    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AjouterActualiteEcran(
          association: widget.association,
        ),
      ),
    );
    if (resultat == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Actualité ajoutée avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _ajouterEvenement() async {
    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AjouterEvenementEcran(
          association: widget.association,
        ),
      ),
    );
    if (resultat == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Événement créé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion - ${widget.association.nom}'),
        backgroundColor: const Color(0xFF005499),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête simple
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.admin_panel_settings, color: Color(0xFF005499)),
                        const SizedBox(width: 8),
                        Text(
                          'Gestion de ${widget.association.nom}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005499),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gérez les demandes d\'adhésion et ajoutez du contenu',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions simples
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Actions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005499),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _ajouterActualite,
                            icon: const Icon(Icons.article),
                            label: const Text('Ajouter actualité'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00A1E4),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _ajouterEvenement,
                            icon: const Icon(Icons.event),
                            label: const Text('Ajouter événement'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005499),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Demandes d'adhésion simples
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people, color: Color(0xFF005499)),
                        const SizedBox(width: 8),
                        const Text(
                          'Demandes d\'adhésion',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005499),
                          ),
                        ),
                        const Spacer(),
                        if (_chargement)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF005499)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_demandesAdhesion.isEmpty && !_chargement)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Aucune demande en attente',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _demandesAdhesion.length,
                        itemBuilder: (context, index) {
                          final demande = _demandesAdhesion[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE9ECEF),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF005499).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFF005499),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                'Étudiant ${demande.utilisateurId}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text('Rôle: ${demande.roledemande}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: IconButton(
                                      onPressed: () => _repondreDemande(demande, true),
                                      icon: const Icon(Icons.check, color: Colors.white, size: 18),
                                      tooltip: 'Accepter',
                                      padding: const EdgeInsets.all(8),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: IconButton(
                                      onPressed: () => _repondreDemande(demande, false),
                                      icon: const Icon(Icons.close, color: Colors.white, size: 18),
                                      tooltip: 'Rejeter',
                                      padding: const EdgeInsets.all(8),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
