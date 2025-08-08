import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/utilisateur.dart';
import '../services/authentification_service.dart';
import '../../domain/repositories/utilisateurs_repository.dart';
import '../../core/di/service_locator.dart';
import '../widgets/widget_barre_app_personnalisee.dart';

// UI Design: Écran de gestion des privilèges administrateur
class GestionPrivilegesAdminEcran extends StatefulWidget {
  const GestionPrivilegesAdminEcran({super.key});

  @override
  State<GestionPrivilegesAdminEcran> createState() => _GestionPrivilegesAdminEcranState();
}

class _GestionPrivilegesAdminEcranState extends State<GestionPrivilegesAdminEcran> {
  late final AuthentificationService _authentificationService;
  late final UtilisateursRepository _utilisateursRepository;
  List<Utilisateur> _utilisateurs = [];
  bool _chargementEnCours = true;

  @override
  void initState() {
    super.initState();
    _authentificationService = ServiceLocator.obtenirService<AuthentificationService>();
    _utilisateursRepository = ServiceLocator.obtenirService<UtilisateursRepository>();
    _chargerUtilisateurs();
  }

  Future<void> _chargerUtilisateurs() async {
    setState(() => _chargementEnCours = true);
    
    try {
      final utilisateurs = await _utilisateursRepository.obtenirTousLesUtilisateurs();
      setState(() => _utilisateurs = utilisateurs);
    } catch (e) {
      _afficherErreur('Erreur lors du chargement des utilisateurs');
    }
    
    setState(() => _chargementEnCours = false);
  }

  @override
  Widget build(BuildContext context) {
    // Vérifier que l'utilisateur connecté est admin
    if (!_authentificationService.estAdministrateur) {
      return Scaffold(
        backgroundColor: CouleursApp.fond,
        appBar: WidgetBarreAppPersonnalisee(
          titre: 'Accès Refusé',
          sousTitre: 'Zone administrateur',
          afficherBoutonRetour: true,
          hauteurBarre: 120,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Accès réservé aux administrateurs',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: WidgetBarreAppPersonnalisee(
        titre: 'Gestion Privilèges',
        sousTitre: 'Administration système',
        afficherBoutonRetour: true,
        hauteurBarre: 120,
      ),
      body: _chargementEnCours
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _chargerUtilisateurs,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _construireResume(),
                    const SizedBox(height: 24),
                    _construireListeUtilisateurs(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _construireResume() {
    final admins = _utilisateurs.where((u) => u.aPrivilege('admin') || u.typeUtilisateur == 'admin').length;
    final etudiants = _utilisateurs.where((u) => u.typeUtilisateur == 'etudiant').length;
    final professeurs = _utilisateurs.where((u) => u.typeUtilisateur == 'professeur').length;

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
          Row(
            children: [
              const Icon(Icons.admin_panel_settings, color: CouleursApp.principal, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Statistiques Utilisateurs',
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
              _construireStatistique('$admins', 'Admins', Icons.security, Colors.red),
              _construireStatistique('$professeurs', 'Professeurs', Icons.school, CouleursApp.accent),
              _construireStatistique('$etudiants', 'Étudiants', Icons.person, CouleursApp.principal),
              _construireStatistique('${_utilisateurs.length}', 'Total', Icons.people, Colors.grey),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: couleur.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icone, size: 20, color: couleur),
        ),
        const SizedBox(height: 8),
        Text(
          valeur,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: couleur,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: CouleursApp.texteFonce.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _construireListeUtilisateurs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people, color: CouleursApp.principal, size: 24),
            const SizedBox(width: 12),
            const Text(
              'Gestion des Utilisateurs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CouleursApp.texteFonce,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._utilisateurs.map((utilisateur) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _construireCarteUtilisateur(utilisateur),
            )).toList(),
      ],
    );
  }

  Widget _construireCarteUtilisateur(Utilisateur utilisateur) {
    final estAdmin = utilisateur.aPrivilege('admin') || utilisateur.typeUtilisateur == 'admin';
    final estUtilisateurActuel = _authentificationService.utilisateurActuel?.id == utilisateur.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        border: estAdmin ? Border.all(color: Colors.red.withValues(alpha: 0.3), width: 2) : null,
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
              CircleAvatar(
                backgroundColor: estAdmin ? Colors.red : CouleursApp.principal,
                child: Text(
                  '${utilisateur.prenom[0]}${utilisateur.nom[0]}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${utilisateur.prenom} ${utilisateur.nom}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: CouleursApp.texteFonce,
                          ),
                        ),
                        if (estUtilisateurActuel) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: CouleursApp.accent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Vous',
                              style: TextStyle(fontSize: 10, color: CouleursApp.accent),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      utilisateur.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      'Type: ${utilisateur.typeUtilisateur}',
                      style: TextStyle(
                        fontSize: 12,
                        color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  if (estAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ADMIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (utilisateur.privileges.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: utilisateur.privileges.map((privilege) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _obtenirCouleurPrivilege(privilege).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  privilege,
                  style: TextStyle(
                    fontSize: 11,
                    color: _obtenirCouleurPrivilege(privilege),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (!estAdmin && !estUtilisateurActuel)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _promouvoirAdmin(utilisateur),
                    icon: const Icon(Icons.security, size: 16),
                    label: const Text('Promouvoir Admin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              if (estAdmin && !estUtilisateurActuel) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _retrograderAdmin(utilisateur),
                    icon: const Icon(Icons.remove_circle, size: 16),
                    label: const Text('Retirer Admin'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
              if (estUtilisateurActuel)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: CouleursApp.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Votre compte',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CouleursApp.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _obtenirCouleurPrivilege(String privilege) {
    switch (privilege) {
      case 'admin':
        return Colors.red;
      case 'moderateur':
        return Colors.orange;
      case 'professeur':
        return CouleursApp.accent;
      default:
        return CouleursApp.principal;
    }
  }

  Future<void> _promouvoirAdmin(Utilisateur utilisateur) async {
    final confirme = await _afficherDialogueConfirmation(
      'Promouvoir Administrateur',
      'Voulez-vous vraiment promouvoir ${utilisateur.prenom} ${utilisateur.nom} en tant qu\'administrateur ?\n\nCette action lui donnera tous les privilèges administratifs.',
      'Promouvoir',
      Colors.red,
    );

    if (confirme == true) {
      final success = await _authentificationService.promouvoirAdmin(utilisateur.id);
      if (success) {
        _afficherSucces('${utilisateur.prenom} ${utilisateur.nom} a été promu administrateur');
        _chargerUtilisateurs();
      } else {
        _afficherErreur('Erreur lors de la promotion');
      }
    }
  }

  Future<void> _retrograderAdmin(Utilisateur utilisateur) async {
    final confirme = await _afficherDialogueConfirmation(
      'Retirer Privilèges Admin',
      'Voulez-vous vraiment retirer les privilèges administrateur de ${utilisateur.prenom} ${utilisateur.nom} ?\n\nCette action retirera tous ses privilèges administratifs.',
      'Retirer',
      Colors.orange,
    );

    if (confirme == true) {
      final success = await _authentificationService.retrograderAdmin(utilisateur.id);
      if (success) {
        _afficherSucces('Privilèges administrateur retirés de ${utilisateur.prenom} ${utilisateur.nom}');
        _chargerUtilisateurs();
      } else {
        _afficherErreur('Erreur : Impossible de retirer le dernier administrateur');
      }
    }
  }

  Future<bool?> _afficherDialogueConfirmation(String titre, String message, String actionLabel, Color couleur) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titre),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: couleur,
              foregroundColor: Colors.white,
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
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