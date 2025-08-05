import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import '../services/navigation_service.dart';
import '../services/authentification_service.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/utilisateur.dart';
import 'modifier_profil_ecran.dart';
import 'gerer_livres_ecran.dart';
import 'salles_ecran.dart';
import 'connexion_ecran.dart';


// UI Design: Page profil utilisateur avec informations personnelles et statistiques - OPTIMISÉ avec widgets réutilisables
class ProfilEcran extends StatefulWidget {
  const ProfilEcran({super.key});

  @override
  State<ProfilEcran> createState() => _ProfilEcranState();
}

class _ProfilEcranState extends State<ProfilEcran> {
  late AuthentificationService _authentificationService;
  Utilisateur? _utilisateurActuel;
  bool _chargementEnCours = true;

  @override
  void initState() {
    super.initState();
    _authentificationService = ServiceLocator.obtenirService<AuthentificationService>();
    _chargerUtilisateurActuel();
  }

  Future<void> _chargerUtilisateurActuel() async {
    setState(() => _chargementEnCours = true);
    await _authentificationService.chargerUtilisateurActuel();
    setState(() {
      _utilisateurActuel = _authentificationService.utilisateurActuel;
      _chargementEnCours = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // UI Design: Affichage d'un indicateur de chargement si les données ne sont pas encore disponibles
    if (_chargementEnCours || _utilisateurActuel == null) {
      return Scaffold(
        backgroundColor: CouleursApp.fond,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: WidgetBarreAppPersonnalisee(
        titre: '${_utilisateurActuel!.prenom} ${_utilisateurActuel!.nom}', // UI Design: Nom dynamique
        sousTitre: '${_utilisateurActuel!.codeEtudiant}\n${_utilisateurActuel!.programme}', // UI Design: Informations dynamiques
        hauteurBarre: 140,
        afficherProfil: false,
        afficherBoutonRetour: true,
        widgetFin: Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: CouleursApp.blanc,
              width: 3,
            ),
            gradient: LinearGradient(
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
              _authentificationService.obtenirInitiales(), // UI Design: Initiales dynamiques
              style: TextStyle(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Section statistiques dynamiques - UI Design: Basées sur l'utilisateur connecté
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
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
                    _construireStatistique('12', 'Livres\néchangés', Icons.swap_horiz, CouleursApp.principal),
                    _construireStatistique('3', 'Associations\nrejointes', Icons.groups, CouleursApp.accent),
                    _construireStatistique(
                      _calculerDureeInscription(),
                      'Mois\nà l\'UQAR', 
                      Icons.school, 
                      CouleursApp.principal
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Section mes livres - VERSION OPTIMISÉE
              _construireSectionLivres(context),
              const SizedBox(height: 24),
              
              // Section mes réservations - NOUVELLE
              _construireSectionReservations(context),
              const SizedBox(height: 24),
              

              
              // Section mes associations - VERSION OPTIMISÉE
              _construireSectionAssociations(context),
              const SizedBox(height: 24),
              
              // Section actions - BOUTONS PRINCIPAUX
              _construireSectionActions(context),
              const SizedBox(height: 20),
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

  // Actions - OPTIMISÉES
  void _ouvrirModifierProfil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ModifierProfilEcran(),
      ),
    );
  }

  void _deconnecter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déconnexion'),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // UI Design: Utiliser le service d'authentification pour se déconnecter
              await _authentificationService.deconnecter();
              
              // Retour à l'écran de connexion
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const ConnexionEcran()),
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Déconnexion réussie'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Se déconnecter', style: TextStyle(color: CouleursApp.blanc)),
          ),
        ],
      ),
    );
  }



  // UI Design: Helper pour créer une statistique
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

  // UI Design: Section mes livres - FONCTIONNELLE
  Widget _construireSectionLivres(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
              Icon(Icons.menu_book, color: CouleursApp.principal, size: 24),
              const SizedBox(width: 12),
              Text('Mes Livres', style: StylesTexteApp.titre.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _construireInfoLivre('5', 'Disponibles', CouleursApp.accent),
              _construireInfoLivre('2', 'En cours', Colors.orange),
              _construireInfoLivre('12', 'Terminés', Colors.green),
              _construireInfoLivre('2', 'En vente', CouleursApp.principal),
            ],
          ),
          const SizedBox(height: 20),
          
          // UI Design: Sous-section livres en vente intégrée
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CouleursApp.principal.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CouleursApp.principal.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.sell, color: CouleursApp.principal, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Mes Livres en Vente',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CouleursApp.principal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Liste des livres en vente (simulés)
                _construireLivreEnVente('Calcul Différentiel', '12,50 €', 'En vente'),
                const SizedBox(height: 8),
                _construireLivreEnVente('Physique Générale', '18,00 €', 'Vendu'),
                
                const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
                              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GererLivresEcran()),
                ),
              style: OutlinedButton.styleFrom(
                      side: BorderSide(color: CouleursApp.principal),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
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

  // UI Design: Helper pour info livre
  Widget _construireInfoLivre(String nombre, String type, Color couleur) {
    return Column(
      children: [
        Text(
          nombre,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: couleur),
        ),
        Text(
          type,
          style: TextStyle(fontSize: 12, color: CouleursApp.texteFonce.withValues(alpha: 0.6)),
        ),
      ],
    );
  }

  // UI Design: Section mes réservations - NOUVELLE
  Widget _construireSectionReservations(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
              Icon(Icons.event_seat, color: CouleursApp.accent, size: 24),
              const SizedBox(width: 12),
              Text('Mes Réservations', style: StylesTexteApp.titre.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Liste des réservations (simulées)
          _construireReservation('Salle 302A', 'Aujourd\'hui 14h-16h', 'Confirmée', Colors.green),
          const SizedBox(height: 12),
          _construireReservation('Salle 105B', 'Demain 10h-12h', 'En attente', Colors.orange),
          
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SallesEcran()),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: CouleursApp.accent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
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

  // UI Design: Helper pour une réservation
  Widget _construireReservation(String salle, String creneau, String statut, Color couleurStatut) {
    return Row(
      children: [
        Icon(Icons.meeting_room, color: CouleursApp.accent, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                salle,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: CouleursApp.texteFonce),
              ),
              Text(
                creneau,
                style: TextStyle(fontSize: 12, color: CouleursApp.texteFonce.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: couleurStatut.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statut,
            style: TextStyle(
              fontSize: 11,
              color: couleurStatut,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
                 Builder(
           builder: (context) => IconButton(
             icon: Icon(Icons.more_vert, color: CouleursApp.texteFonce.withValues(alpha: 0.5), size: 18),
             onPressed: () => _gererReservation(salle),
           ),
         ),
      ],
    );
  }



  // UI Design: Helper pour un livre en vente
  Widget _construireLivreEnVente(String titre, String prix, String statut) {
    return Row(
      children: [
        Icon(Icons.menu_book, color: CouleursApp.principal, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titre,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: CouleursApp.texteFonce),
              ),
              Text(
                prix,
                style: TextStyle(fontSize: 12, color: CouleursApp.accent, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statut == 'En vente' ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statut,
            style: TextStyle(
              fontSize: 11,
              color: statut == 'En vente' ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: CouleursApp.texteFonce.withValues(alpha: 0.5), size: 18),
                     onPressed: () => _gererLivreEnVente(titre),
        ),
      ],
    );
  }

  // Actions pour les réservations
  void _gererReservations(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gérer mes réservations', style: StylesTexteApp.titre.copyWith(fontSize: 18)),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.list, color: CouleursApp.accent),
              title: const Text('Voir toutes mes réservations'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Affichage de toutes les réservations - À venir')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.add, color: CouleursApp.principal),
              title: const Text('Nouvelle réservation'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Redirection vers les salles - À venir')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _gererReservation(String salle) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Réservation - $salle', style: StylesTexteApp.titre.copyWith(fontSize: 18)),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.edit, color: CouleursApp.accent),
              title: const Text('Modifier la réservation'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Modification de la réservation $salle'),
                    backgroundColor: CouleursApp.accent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Annuler la réservation'),
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

  void _confirmerAnnulationReservation(String salle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Annuler la réservation'),
        content: Text('Êtes-vous sûr de vouloir annuler votre réservation pour $salle ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Réservation $salle annulée'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Oui, annuler', style: TextStyle(color: CouleursApp.blanc)),
          ),
        ],
      ),
    );
  }

  // Actions pour les livres en vente
  void _gererLivresEnVente(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gérer mes ventes', style: StylesTexteApp.titre.copyWith(fontSize: 18)),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.list, color: CouleursApp.principal),
              title: const Text('Voir tous mes livres en vente'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Affichage de tous les livres en vente - À venir')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.add, color: CouleursApp.accent),
              title: const Text('Mettre un livre en vente'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Redirection vers mes livres - À venir')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _gererLivreEnVente(String titre) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Livre - $titre', style: StylesTexteApp.titre.copyWith(fontSize: 18)),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.edit, color: CouleursApp.accent),
              title: const Text('Modifier le prix'),
              onTap: () {
                Navigator.pop(context);
                _modifierPrixLivre(titre);
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_shopping_cart, color: Colors.orange),
              title: const Text('Retirer de la vente'),
              onTap: () {
                Navigator.pop(context);
                _retirerDeLaVente(titre);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _modifierPrixLivre(String titre) {
    final prixController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier le prix'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Livre: $titre'),
            const SizedBox(height: 16),
            TextFormField(
              controller: prixController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Nouveau prix (€)',
                hintText: 'Ex: 12.50',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Prix de "$titre" modifié à ${prixController.text} €'),
                  backgroundColor: CouleursApp.accent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: CouleursApp.accent),
            child: Text('Confirmer', style: TextStyle(color: CouleursApp.blanc)),
          ),
        ],
      ),
    );
  }

  void _retirerDeLaVente(String titre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Retirer de la vente'),
        content: Text('Êtes-vous sûr de vouloir retirer "$titre" de la vente ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"$titre" retiré de la vente'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Oui, retirer', style: TextStyle(color: CouleursApp.blanc)),
          ),
        ],
      ),
    );
  }

  // UI Design: Section mes associations - FONCTIONNELLE
  Widget _construireSectionAssociations(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
              Icon(Icons.groups, color: CouleursApp.principal, size: 24),
              const SizedBox(width: 12),
              Text('Mes Associations', style: StylesTexteApp.titre.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          _construireAssociation('AEI', 'Membre actif', Icons.school, CouleursApp.principal),
          const SizedBox(height: 12),
          _construireAssociation('Club Photo', 'Membre', Icons.camera_alt, CouleursApp.accent),
          const SizedBox(height: 12),
          _construireAssociation('AGE', 'Membre', Icons.groups_2, CouleursApp.principal),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => NavigationService.gererNavigationNavBar(context, 3),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: CouleursApp.accent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Explorer les associations',
                style: TextStyle(color: CouleursApp.accent, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Helper pour association
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: CouleursApp.texteFonce),
              ),
              Text(
                statut,
                style: TextStyle(fontSize: 12, color: CouleursApp.texteFonce.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // UI Design: Calculer la durée d'inscription dynamiquement
  String _calculerDureeInscription() {
    if (_utilisateurActuel == null) return '0';
    final difference = DateTime.now().difference(_utilisateurActuel!.dateInscription);
    return (difference.inDays / 30).round().toString();
  }

  // UI Design: Section actions - BOUTONS PRINCIPAUX
  Widget _construireSectionActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
              child: Text(
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