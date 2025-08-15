// UI Design: Écran de gestion de la cantine pour les administrateurs
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/menu.dart';
import '../../../domain/repositories/menus_repository.dart';
import '../../../domain/repositories/horaires_repository.dart';
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
  late HorairesRepository _horairesRepository;
  List<Menu> _menus = [];
  Map<String, Map<String, String>> _horaires = {};
  bool _chargementEnCours = true;
  String? _menuDuJourId; // UI Design: Menu du jour sélectionné

  @override
  void initState() {
    super.initState();
    _menusRepository = ServiceLocator.obtenirService<MenusRepository>();
    _horairesRepository = ServiceLocator.obtenirService<HorairesRepository>();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    try {
      setState(() => _chargementEnCours = true);
      
      // Charger menus, horaires et menu du jour en parallèle
      final futures = await Future.wait<dynamic>([
        _menusRepository.obtenirTousLesMenus(),
        _horairesRepository.obtenirTousLesHorairesCantine(),
        _menusRepository.obtenirMenuDuJourActuel(),
      ]);
      
      setState(() {
        _menus = futures[0] as List<Menu>;
        _horaires = _convertirHorairesEnString(futures[1] as Map<String, Map<String, TimeOfDay>>);
        _menuDuJourId = futures[2] as String?;
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
                    _construireGestionMenuDuJour(),
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

  // UI Design: Gestion moderne du menu du jour avec design premium
  Widget _construireGestionMenuDuJour() {
    Menu? menuDuJour;
    
    // UI Design: Rechercher le menu du jour sélectionné
    if (_menuDuJourId != null && _menuDuJourId!.isNotEmpty) {
      try {
        menuDuJour = _menus.firstWhere((menu) => menu.id == _menuDuJourId);
      } catch (e) {
        // Menu du jour non trouvé
        menuDuJour = null;
      }
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withValues(alpha: 0.05),
            Colors.deepOrange.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: menuDuJour != null ? Colors.orange.withValues(alpha: 0.3) : CouleursApp.gris.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            // En-tête premium avec badges
        Row(
          children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.star,
                    color: Colors.white,
                    size: screenWidth * 0.06,
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
            Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Menu du Jour Spécial',
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                color: CouleursApp.texteFonce,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
            Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                              vertical: screenWidth * 0.008,
                            ),
              decoration: BoxDecoration(
                              color: menuDuJour != null ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: menuDuJour != null ? Colors.green.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3),
                              ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                                Icon(
                                  menuDuJour != null ? Icons.check_circle : Icons.radio_button_unchecked,
                                  size: screenWidth * 0.03,
                                  color: menuDuJour != null ? Colors.green : Colors.grey,
                                ),
                                SizedBox(width: screenWidth * 0.008),
                  Text(
                                  menuDuJour != null ? 'ACTIF' : 'INACTIF',
                    style: TextStyle(
                                    fontSize: screenWidth * 0.025,
                      fontWeight: FontWeight.bold,
                                    color: menuDuJour != null ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        menuDuJour != null 
                          ? 'Menu recommandé par notre chef'
                          : 'Aucun menu spécial défini',
                        style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          color: menuDuJour != null ? Colors.orange.shade700 : CouleursApp.gris,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.025),

            if (menuDuJour != null) ...[
              // Carte du menu actuel - Design premium
        Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.2),
                  ),
            boxShadow: [
              BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                children: [
                  Container(
                      width: screenWidth * 0.15,
                      height: screenWidth * 0.15,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                        Icons.restaurant_menu,
                        color: Colors.orange.shade700,
                        size: screenWidth * 0.07,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            menuDuJour.nom,
                            style: TextStyle(
                              fontSize: screenWidth * 0.042,
                            fontWeight: FontWeight.bold,
                              color: CouleursApp.texteFonce,
                          ),
                            maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                          SizedBox(height: screenHeight * 0.005),
                        Text(
                            menuDuJour.description,
                            style: TextStyle(
                              fontSize: screenWidth * 0.032,
                              color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: screenHeight * 0.008),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.02,
                                  vertical: screenWidth * 0.008,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  ' 24${menuDuJour.prix.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.03,
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              if (menuDuJour.estVegetarien) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.015,
                                    vertical: screenWidth * 0.006,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    menuDuJour.estVegan ? 'VEGAN' : 'VÉGÉ',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.025,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ] else ...[
              // État vide avec design moderne
              Container(
                padding: EdgeInsets.all(screenWidth * 0.06),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: CouleursApp.gris.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                children: [
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.restaurant_menu_outlined,
                        color: Colors.grey.withValues(alpha: 0.6),
                        size: screenWidth * 0.08,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Text(
                      'Aucun menu du jour défini',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.008),
                    Text(
                      'Modifiez un menu et utilisez\n"Ajouter au Menu du Jour"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        color: CouleursApp.texteFonce.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],

            // Actions
            if (menuDuJour != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                      onPressed: _retirerMenuDuJour,
                      icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Retirer le Menu du Jour'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                        shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ] else ...[
              // Bouton d'aide pour définir un menu
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue.shade600,
                      size: screenWidth * 0.05,
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Text(
                        'Astuce : Modifiez un menu existant puis cliquez sur "Ajouter au Menu du Jour" pour le définir comme menu spécial.',
                        style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
          ],
        ),
      ),
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
            const Expanded( // UI Design: Utiliser Expanded pour le titre
              child: Text(
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
            const Expanded(
              child: Text(
                'Menus Disponibles',
                style: StylesTexteApp.grandTitre,
              ),
            ),
            Row(
              children: [
                Text(
                  '${_menus.length} menu(s)',
                  style: StylesTexteApp.corpsGris,
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _actualiserMenus,
                  icon: const Icon(
                    Icons.refresh,
                    color: CouleursApp.accent,
                  ),
                  tooltip: 'Actualiser la liste',
                ),
              ],
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
                  onPressed: () => _dupliquerMenu(menu),
                  icon: const Icon(Icons.copy, color: Colors.orange, size: 20),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  tooltip: 'Dupliquer',
                ),
                IconButton(
                  onPressed: () => _modifierMenu(menu),
                  icon: const Icon(Icons.edit, color: CouleursApp.accent, size: 20),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  tooltip: 'Modifier',
                ),
                IconButton(
                  onPressed: () => _supprimerMenu(menu),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  tooltip: 'Supprimer',
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
      // Note: Cette méthode devrait être async pour gérer les appels au repository
      // Pour l'instant, retourner une valeur par défaut
      return 'Ferme à 18:00';
    }
    
    // Si la cantine est fermée, trouver la prochaine ouverture
    final joursSemaine = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final indexJourActuel = joursSemaine.indexOf(jourActuel);
    
    // Chercher le prochain jour d'ouverture
    for (int i = 1; i <= 7; i++) {
      final indexProchainJour = (indexJourActuel + i) % 7;
      final prochainJour = joursSemaine[indexProchainJour];
      
      // Note: Cette méthode devrait être async pour gérer les appels au repository
      // Pour l'instant, retourner une valeur par défaut
      if (prochainJour == 'Lundi') {
        return 'Lundi à 08:00'; // UI Design: Simplifier pour l'affichage
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

  void _modifierHoraireJour(String jour) async {
    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminModifierHorairesEcran(jourInitial: jour),
      ),
    );
    
    // UI Design: Recharger les données si modification réussie
    if (resultat == true) {
      await _chargerDonnees();
    }
  }

  void _modifierTousLesHoraires() async {
    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminModifierHorairesEcran(),
      ),
    );
    
    // UI Design: Recharger les données si modification réussie
    if (resultat == true) {
      await _chargerDonnees();
    }
  }

  void _ajouterNouveauMenu() async {
    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminAjouterMenuEcran(),
      ),
    );
    
    // Si un menu a été ajouté, recharger les données
    if (resultat == true) {
      await _chargerDonnees();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menu ajouté avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _modifierMenu(Menu menu) async {
    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminAjouterMenuEcran(menuAModifier: menu),
      ),
    );
    
    // Si un menu a été modifié ou ajouté au menu du jour, recharger les données
    if (resultat == true || resultat == 'menu_du_jour_ajoute') {
      await _chargerDonnees();
      if (mounted) {
        if (resultat == 'menu_du_jour_ajoute') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Menu défini comme menu du jour !'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menu modifié avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        }
      }
    }
  }

  void _supprimerMenu(Menu menu) {
    showDialog(
      context: context,
      builder: (context) => LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          
          return AlertDialog(
            backgroundColor: CouleursApp.blanc,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            titlePadding: EdgeInsets.fromLTRB(
              screenWidth * 0.05,
              screenHeight * 0.025,
              screenWidth * 0.05,
              screenHeight * 0.01,
            ),
            contentPadding: EdgeInsets.fromLTRB(
              screenWidth * 0.05,
              0,
              screenWidth * 0.05,
              screenHeight * 0.02,
            ),
            actionsPadding: EdgeInsets.fromLTRB(
              screenWidth * 0.05,
              0,
              screenWidth * 0.05,
              screenHeight * 0.02,
            ),
            title: Row(
              children: [
                Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                  size: screenWidth * 0.06,
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Text(
                    'Supprimer le menu',
                    style: StylesTexteApp.moyenTitre.copyWith(
                      color: Colors.red,
                      fontSize: screenWidth * 0.045,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: screenWidth * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voulez-vous supprimer le menu :',
                    style: StylesTexteApp.corpsNormal.copyWith(
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: CouleursApp.principal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: CouleursApp.principal.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '"${menu.nom}"',
                      style: StylesTexteApp.corpsNormal.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.04,
                        color: CouleursApp.principal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.red,
                          size: screenWidth * 0.05,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Text(
                            'Cette action est irréversible',
                            style: StylesTexteApp.petitGris.copyWith(
                              color: Colors.red[700],
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: CouleursApp.gris.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            color: CouleursApp.gris,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          
                          try {
                            // Utiliser le repository pour supprimer le menu
                            final succes = await _menusRepository.supprimerMenu(menu.id);
                            
                            if (succes) {
                              await _chargerDonnees(); // Recharger les données
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Menu supprimé avec succès !'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Erreur lors de la suppression du menu'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Supprimer',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }



  // UI Design: Actualiser la liste des menus
  Future<void> _actualiserMenus() async {
    await _chargerDonnees();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Liste des menus actualisée'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // UI Design: Dupliquer un menu existant
  void _dupliquerMenu(Menu menu) async {
    try {
      // Créer une copie du menu avec un nouvel ID et un nom modifié
      final menuDuplique = Menu(
        id: 'menu_${DateTime.now().millisecondsSinceEpoch}',
        nom: '${menu.nom} (Copie)',
        description: menu.description,
        prix: menu.prix,
        estDisponible: menu.estDisponible,
        ingredients: menu.ingredients,
        allergenes: menu.allergenes,
        categorie: menu.categorie,
        calories: menu.calories,
        estVegetarien: menu.estVegetarien,
        estVegan: menu.estVegan,
        imageUrl: menu.imageUrl,
        dateAjout: DateTime.now(), // Nouvelle date pour la copie
        nutritionInfo: menu.nutritionInfo,
        note: menu.note,
      );

      // Ajouter le menu dupliqué via le repository
      await _menusRepository.ajouterMenu(menuDuplique);
      
      // Recharger les données
      await _chargerDonnees();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Menu "${menu.nom}" dupliqué avec succès !'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Modifier',
              onPressed: () => _modifierMenu(menuDuplique),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la duplication: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  // UI Design: Retirer le menu du jour via le repository
  void _retirerMenuDuJour() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.clear, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text(
              'Retirer le Menu du Jour',
              style: StylesTexteApp.moyenTitre,
            ),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir retirer le menu du jour actuel ? '
          'Les clients ne verront plus de menu spécial aujourd\'hui.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Retirer le menu du jour via le repository
                await _menusRepository.definirMenuDuJour('');
                
                if (mounted) {
              Navigator.pop(context);
                }
                
                // Recharger les données
                await _chargerDonnees();
                
                if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Menu du jour retiré avec succès'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors du retrait: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Retirer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
} 