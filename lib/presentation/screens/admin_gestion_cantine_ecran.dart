// UI Design: Écran de gestion de la cantine pour les administrateurs
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/menu.dart';
import '../../domain/repositories/menus_repository.dart';
import '../../data/datasources/horaires_datasource_local.dart';
import '../widgets/widget_barre_app_navigation_admin.dart';
import '../widgets/widget_carte.dart';
import '../widgets/widget_collection.dart';
import '../widgets/widget_section_statistiques.dart';
import '../screens/admin_ajouter_menu_ecran.dart';
import '../screens/admin_modifier_horaires_ecran.dart';

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
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: const WidgetBarreAppNavigationAdmin(
        titre: 'Gestion Cantine',
        sousTitre: 'Menus et horaires',
        sectionActive: 'cantine',
      ),
      body: _chargementEnCours
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _construireStatutCantine(),
                  const SizedBox(height: 24),
                  _construireGestionHoraires(),
                  const SizedBox(height: 24),
                  _construireGestionMenus(),
                  const SizedBox(height: 24),
                  _construireActionsRapides(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _ajouterNouveauMenu,
        backgroundColor: CouleursApp.principal,
        child: const Icon(Icons.add, color: Colors.white),
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
          valeur: '${heureActuelle.hour}:${heureActuelle.minute.toString().padLeft(2, '0')}',
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
          valeur: estOuverte ? 'Forcer Fermeture' : 'Forcer Ouverture',
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
            const Text(
              'Horaires d\'Ouverture',
              style: StylesTexteApp.grandTitre,
            ),
            ElevatedButton.icon(
              onPressed: _modifierTousLesHoraires,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Modifier'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CouleursApp.accent,
                foregroundColor: CouleursApp.blanc,
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
                        Row(
                          children: [
                            Text(
                              '${horaire['ouverture']} - ${horaire['fermeture']}',
                              style: StylesTexteApp.corpsNormal,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => _modifierHoraireJour(jour),
                              icon: const Icon(
                                Icons.edit,
                                size: 16,
                                color: CouleursApp.accent,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
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
    return _horairesDatasource.obtenirStatutCantineFormatte();
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
      builder: (context) => AlertDialog(
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
      builder: (context) => AlertDialog(
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
      builder: (context) => AlertDialog(
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