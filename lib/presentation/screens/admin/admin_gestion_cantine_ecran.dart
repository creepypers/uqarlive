// UI Design: Écran de gestion de la cantine pour les administrateurs
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/menu.dart';
import '../../../domain/repositories/menus_repository.dart';
import '../../../data/datasources/horaires_datasource_local.dart';
import '../../../presentation/widgets/widget_barre_app_navigation_admin.dart';
import '../../../presentation/widgets/widget_carte.dart';
import '../../../presentation/widgets/widget_collection.dart';
import '../../../presentation/widgets/widget_section_statistiques.dart';
import '../../../presentation/screens/admin/admin_ajouter_menu_ecran.dart';
import '../../../presentation/screens/admin/admin_modifier_horaires_ecran.dart';

class AdminGestionCantineEcran extends StatefulWidget {
  const AdminGestionCantineEcran({super.key});

  @override
  State<AdminGestionCantineEcran> createState() => _AdminGestionCantineEcranState();
}

class _AdminGestionCantineEcranState extends State<AdminGestionCantineEcran> {
  late MenusRepository _menusRepository;
  late HorairesDatasourceLocal _horairesDatasource;
  List<Menu> _menus = [];
  Map<String, Map<String, String>> _horaires = {};
  bool _chargementEnCours = true;

  @override
  void initState() {
    super.initState();
    _menusRepository = ServiceLocator.obtenirService<MenusRepository>();
    _horairesDatasource = HorairesDatasourceLocal();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    try {
      setState(() => _chargementEnCours = true);
      
      // Charger menus et horaires en parallèle
      final futures = await Future.wait<dynamic>([
        _menusRepository.obtenirTousLesMenus(),
        Future.value(_horairesDatasource.obtenirTousLesHorairesCantine()),
      ]);
      
      setState(() {
        _menus = futures[0] as List<Menu>;
        _horaires = _convertirHorairesEnString(futures[1] as Map<String, Map<String, TimeOfDay>>);
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
    // UI Design: Obtenir les dimensions de l'écran pour l'adaptabilité
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;
    
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      resizeToAvoidBottomInset: true, // UI Design: Éviter les débordements avec le clavier
      appBar: const WidgetBarreAppNavigationAdmin(
        titre: 'Gestion Cantine',
        sousTitre: 'Menus et horaires',
        sectionActive: 'cantine',
      ),
      body: SafeArea(
        child: _chargementEnCours
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.04, // UI Design: Padding adaptatif
                  right: screenWidth * 0.04,
                  top: screenHeight * 0.02,
                  bottom: viewInsets.bottom + padding.bottom + screenHeight * 0.025, // UI Design: Padding adaptatif pour éviter les débordements
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _construireStatutCantine(),
                    SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
                    _construireGestionHoraires(),
                    SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
                    _construireGestionMenus(),
                  ],
                ),
              ),
        ),

      floatingActionButton: FloatingActionButton(
        onPressed: _ajouterNouveauMenu,
        backgroundColor: CouleursApp.principal,
        child: Icon(Icons.add, color: Colors.white, size: screenWidth * 0.06), // UI Design: Taille adaptative
      ),
    );
  }

  // UI Design: Statut en temps réel de la cantine avec widget réutilisable
  Widget _construireStatutCantine() {
    final maintenant = DateTime.now();
    final jourActuel = _obtenirJourSemaine(maintenant.weekday);
    final heureActuelle = TimeOfDay.now();
    
    bool estOuverte = _estCantineOuverte(jourActuel, heureActuelle);
    
    return WidgetSectionStatistiques(
      titre: 'Statut Cantine - ${estOuverte ? "OUVERTE" : "FERMÉE"}',
      iconeTitre: estOuverte ? Icons.restaurant_menu : Icons.restaurant,
      typeStyling: TypeSectionStatistiques.cantineStyle,
      statistiques: [
        ElementStatistique(
          valeur: jourActuel,
          label: 'Jour',
          icone: Icons.calendar_today,
          couleurIcone: estOuverte ? Colors.green : Colors.orange,
        ),
        ElementStatistique(
          valeur: '${heureActuelle.hour}h${heureActuelle.minute.toString().padLeft(2, '0')}',
          label: 'Heure',
          icone: Icons.access_time,
          couleurIcone: estOuverte ? Colors.green : Colors.orange,
        ),
        ElementStatistique(
          valeur: _prochainCreneauOuverture(),
          label: 'Prochaine ouverture',
          icone: Icons.schedule,
          couleurIcone: estOuverte ? Colors.green : Colors.orange,
        ),
        ElementStatistique(
          valeur: estOuverte ? 'Fermer' : 'Ouvrir',
          label: 'Action',
          icone: estOuverte ? Icons.close : Icons.play_arrow,
          couleurIcone: estOuverte ? Colors.red : Colors.green,
        ),
      ],
    );
  }

  Widget _construireInfoStatut(String titre, String valeur) {
    return Column(
      children: [
        Text(
          titre,
          style: StylesTexteApp.petitBlanc,
        ),
        const SizedBox(height: 4),
        Text(
          valeur,
          style: StylesTexteApp.moyenBlanc.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // UI Design: Gestion des horaires d'ouverture
  Widget _construireGestionHoraires() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded( // UI Design: Utiliser Expanded pour le titre
              child: const Text(
                'Horaires d\'Ouverture',
                style: StylesTexteApp.grandTitre,
              ),
            ),
            const SizedBox(width: 8), // UI Design: Espacement
            Flexible( // UI Design: Utiliser Flexible pour le bouton
              child: ElevatedButton.icon(
                onPressed: _modifierTousLesHoraires,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Modifier'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CouleursApp.accent,
                  foregroundColor: CouleursApp.blanc,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // UI Design: Padding réduit
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _horaires.entries.map((entree) {
                final jour = entree.key;
                final horaire = entree.value;
                final estFerme = horaire['ouverture'] == 'Fermé';
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          jour,
                          style: StylesTexteApp.moyenTitre,
                          maxLines: 1, // UI Design: Limiter à une ligne
                          overflow: TextOverflow.ellipsis, // UI Design: Gérer le débordement
                        ),
                      ),
                      if (estFerme)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: CouleursApp.gris.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Fermé',
                            style: StylesTexteApp.corpsGris,
                          ),
                        )
                      else
                        Expanded( // UI Design: Utiliser Expanded pour éviter le débordement
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end, // UI Design: Aligner à droite
                            children: [
                              Flexible( // UI Design: Utiliser Flexible pour le texte
                                child: Text(
                                  '${horaire['ouverture']} - ${horaire['fermeture']}',
                                  style: StylesTexteApp.corpsNormal,
                                  maxLines: 1, // UI Design: Limiter à une ligne
                                  overflow: TextOverflow.ellipsis, // UI Design: Gérer le débordement
                                ),
                              ),
                              const SizedBox(width: 4), // UI Design: Espacement réduit
                              SizedBox( // UI Design: Utiliser SizedBox pour contraindre le bouton
                                width: 32,
                                height: 32,
                                child: IconButton(
                                  onPressed: () => _modifierHoraireJour(jour),
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: CouleursApp.accent,
                                  ),
                                  padding: EdgeInsets.zero, // UI Design: Supprimer le padding
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                    maxWidth: 32,
                                    maxHeight: 32,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // UI Design: Gestion des menus
  Widget _construireGestionMenus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Menus Disponibles',
              style: StylesTexteApp.grandTitre,
            ),
            Text(
              '${_menus.length} menu(s)',
              style: StylesTexteApp.corpsGris,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_menus.isEmpty)
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.restaurant_menu,
                  size: 64,
                  color: CouleursApp.gris,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun menu disponible',
                  style: StylesTexteApp.moyenTitre.copyWith(color: CouleursApp.gris),
                ),
              ],
            ),
          )
        else
          WidgetCollection.grille(
            elements: _menus,
            constructeurElement: (context, menu, index) => WidgetCarte.menu(
              menu: menu,
              onTap: () => _modifierMenu(menu),
              hauteur: 200,
              actionsPersonnalisees: [
                IconButton(
                  onPressed: () => _modifierMenu(menu),
                  icon: const Icon(Icons.edit, color: CouleursApp.accent, size: 20),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                IconButton(
                  onPressed: () => _supprimerMenu(menu),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
            nombreColonnes: 2,
            espacementColonnes: 12,
            espacementLignes: 12,
            ratioAspect: 0.8,
            messageEtatVide: 'Aucun menu disponible',
            iconeEtatVide: Icons.restaurant_menu,
          ),
      ],
    );
  }



  // UI Design: Actions rapides
  Widget _construireActionsRapides() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions Rapides',
          style: StylesTexteApp.grandTitre,
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: [
            _construireBoutonActionRapide(
              'Menu du Jour',
              Icons.today,
              CouleursApp.principal,
              _definirMenuDuJour,
            ),
            _construireBoutonActionRapide(
              'Fermeture Urgente',
              Icons.warning,
              Colors.red,
              _fermetureUrgente,
            ),
            _construireBoutonActionRapide(
              'Mise à Jour Prix',
              Icons.euro,
              CouleursApp.accent,
              _mettreAJourPrix,
            ),
            _construireBoutonActionRapide(
              'Rapport Activité',
              Icons.analytics,
              Colors.green,
              _genererRapport,
            ),
          ],
        ),
      ],
    );
  }

  Widget _construireBoutonActionRapide(
    String titre,
    IconData icone,
    Color couleur,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: couleur,
        foregroundColor: CouleursApp.blanc,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              titre,
              style: StylesTexteApp.petitBlanc.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2, // UI Design: Limiter à 2 lignes
              overflow: TextOverflow.ellipsis, // UI Design: Gérer le débordement
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Méthodes utilitaires
  String _obtenirJourSemaine(int weekday) {
    const jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return jours[weekday - 1];
  }

  bool _estCantineOuverte(String jour, TimeOfDay heure) {
    final horaire = _horaires[jour];
    if (horaire?['ouverture'] == 'Fermé') return false;
    
    // Simulation - en production, vérifier vraiment les heures
    return true; // Pour la démo, toujours ouverte sauf weekend
  }

  String _prochainCreneauOuverture() {
    final maintenant = DateTime.now();
    final jourActuel = _obtenirJourSemaine(maintenant.weekday);
    final heureActuelle = TimeOfDay.now();
    
    // Si la cantine est ouverte aujourd'hui
    if (_estCantineOuverte(jourActuel, heureActuelle)) {
      final horaires = _horairesDatasource.obtenirHorairesCantine(jourActuel);
      final heureFermeture = horaires['fermeture']!;
      return 'Ferme à ${_formatterHeure(heureFermeture)}';
    }
    
    // Si la cantine est fermée, trouver la prochaine ouverture
    final joursSemaine = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final indexJourActuel = joursSemaine.indexOf(jourActuel);
    
    // Chercher le prochain jour d'ouverture
    for (int i = 1; i <= 7; i++) {
      final indexProchainJour = (indexJourActuel + i) % 7;
      final prochainJour = joursSemaine[indexProchainJour];
      final horairesProchainJour = _horairesDatasource.obtenirHorairesCantine(prochainJour);
      
      if (horairesProchainJour['ouverture'] != null) {
        final heureOuverture = horairesProchainJour['ouverture']!;
        return 'Lundi à ${_formatterHeure(heureOuverture)}'; // UI Design: Simplifier pour l'affichage
      }
    }
    
    return 'Fermé ce week-end';
  }

  // UI Design: Convertir les horaires TimeOfDay en String pour l'affichage
  Map<String, Map<String, String>> _convertirHorairesEnString(Map<String, Map<String, TimeOfDay>> horairesTimeOfDay) {
    final Map<String, Map<String, String>> horairesString = {};
    
    horairesTimeOfDay.forEach((jour, horaire) {
      horairesString[jour] = {
        'ouverture': _formatterHeure(horaire['ouverture']!),
        'fermeture': _formatterHeure(horaire['fermeture']!),
      };
    });
    
    return horairesString;
  }

  String _formatterHeure(TimeOfDay heure) {
    final minute = heure.minute.toString().padLeft(2, '0');
    return '${heure.hour}:$minute';
  }

  // UI Design: Actions de gestion
  void _changerStatutCantine(bool nouvelEtat) {
    showDialog(
      context: context,
      builder: (context) => LayoutBuilder(builder: (context, constraints) {
        final w = MediaQuery.of(context).size.width * 0.9;
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: w),
          child: AlertDialog(
        title: Text('${nouvelEtat ? "Ouvrir" : "Fermer"} la Cantine'),
        content: Text('Voulez-vous vraiment ${nouvelEtat ? "ouvrir" : "fermer"} la cantine maintenant ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cantine ${nouvelEtat ? "ouverte" : "fermée"} avec succès !'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(nouvelEtat ? 'Ouvrir' : 'Fermer'),
          ),
        ],
          ),
        );
      }),
    );
  }

  void _modifierHoraireJour(String jour) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminModifierHorairesEcran(),
      ),
    );
  }

  void _modifierTousLesHoraires() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminModifierHorairesEcran(),
      ),
    );
  }

  void _ajouterNouveauMenu() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminAjouterMenuEcran(),
      ),
    );
  }

  void _modifierMenu(Menu menu) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminAjouterMenuEcran(menuAModifier: menu),
      ),
    );
  }

  void _supprimerMenu(Menu menu) {
    showDialog(
      context: context,
      builder: (context) => LayoutBuilder(builder: (context, constraints) {
        final w = MediaQuery.of(context).size.width * 0.9;
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: w),
          child: AlertDialog(
        title: const Text('Supprimer le menu'),
        content: Text('Voulez-vous supprimer le menu "${menu.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _menus.removeWhere((m) => m.id == menu.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Menu supprimé avec succès !'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
          ),
        );
      }),
    );
  }

  void _definirMenuDuJour() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Définition menu du jour - Fonctionnalité en développement'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _fermetureUrgente() {
    showDialog(
      context: context,
      builder: (context) => LayoutBuilder(builder: (context, constraints) {
        final w = MediaQuery.of(context).size.width * 0.9;
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: w),
          child: AlertDialog(
        title: const Text('Fermeture d\'Urgence'),
        content: const Text('Cette action fermera immédiatement la cantine et enverra une notification à tous les utilisateurs.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fermeture d\'urgence activée ! Notifications envoyées.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirmer'),
          ),
        ],
          ),
        );
      }),
    );
  }

  void _mettreAJourPrix() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mise à jour des prix - Fonctionnalité en développement'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _genererRapport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Génération rapport d\'activité - Fonctionnalité en développement'),
        backgroundColor: Colors.green,
      ),
    );
  }
} 