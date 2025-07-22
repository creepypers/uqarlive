import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/livre.dart';
import '../../domain/entities/association.dart';
import '../../domain/repositories/livres_repository.dart';
import '../../domain/repositories/associations_repository.dart';
import 'marketplace_ecran.dart';
import 'details_livre_ecran.dart';
import 'cantine_ecran.dart';
import 'associations_ecran.dart';
import 'details_association_ecran.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import '../widgets/widget_carte.dart';
import '../widgets/widget_collection.dart';
import '../services/navigation_service.dart';
import '../utils/associations_utils.dart';

// UI Design: Page d'accueil UqarLive avec AppBar, sections échange de livres/assos/cantine et navbar
class AccueilEcran extends StatefulWidget {
  const AccueilEcran({super.key});

  @override
  State<AccueilEcran> createState() => _AccueilEcranState();
}

class _AccueilEcranState extends State<AccueilEcran> {
  // Repositories
  late final LivresRepository _livresRepository;
  late final AssociationsRepository _associationsRepository;
  
  // États des données
  List<Livre> _livresRecents = [];
  List<Association> _associationsPopulaires = [];
  bool _chargementLivres = false;
  bool _chargementAssociations = false;

  @override
  void initState() {
    super.initState();
    _initialiserRepositories();
    _chargerLivresRecents();
    _chargerAssociationsPopulaires();
  }

  void _initialiserRepositories() {
    // UI Design: Injection de dépendances via ServiceLocator - Clean Architecture
    _livresRepository = ServiceLocator.obtenirService<LivresRepository>();
    _associationsRepository = ServiceLocator.obtenirService<AssociationsRepository>();
  }

  Future<void> _chargerLivresRecents() async {
    setState(() {
      _chargementLivres = true;
    });

    try {
      final livres = await _livresRepository.obtenirTousLesLivres();
      setState(() {
        _livresRecents = livres.take(5).toList(); // Prendre les 5 premiers
        _chargementLivres = false;
      });
    } catch (e) {
      setState(() {
        _chargementLivres = false;
      });
      print('Erreur lors du chargement des livres: $e');
    }
  }

  Future<void> _chargerAssociationsPopulaires() async {
    setState(() {
      _chargementAssociations = true;
    });

    try {
      final associations = await _associationsRepository.obtenirAssociationsPopulaires(limite: 4);
      setState(() {
        _associationsPopulaires = associations;
        _chargementAssociations = false;
      });
    } catch (e) {
      setState(() {
        _chargementAssociations = false;
      });
      print('Erreur lors du chargement des associations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: WidgetBarreAppPersonnalisee(
        titre: 'Bienvenue',
        sousTitre: 'Marie Dubois', // TODO: Récupérer le nom de l'utilisateur connecté
        widgetFin: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: CouleursApp.blanc.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.ac_unit,
                    color: CouleursApp.blanc,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '-5°C',
                        style: TextStyle(
                          color: CouleursApp.blanc,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rimouski',
                        style: TextStyle(
                          color: CouleursApp.blanc.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section échange de livres
                _construireSectionEchangeLivres(),
                const SizedBox(height: 24),
                
                // Section associations
                _construireSectionAssociations(),
                const SizedBox(height: 24),
                
                // Section cantine
                _construireSectionCantine(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavBarWidget(
        indexSelectionne: 2, // Accueil
        onTap: (index) => NavigationService.gererNavigationNavBar(context, index),
      ),
    );
  }

  // UI Design: Section échange de livres avec WidgetCollection optimisé
  Widget _construireSectionEchangeLivres() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Échange de Livres',
                  style: StylesTexteApp.titre.copyWith(fontSize: 22),
                ),
                Text(
                  'Livres universitaires récents',
                  style: TextStyle(
                    fontSize: 14,
                    color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                NavigationService.gererNavigationNavBar(context, 1); // Index 1 = Livres/Marketplace
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: CouleursApp.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: CouleursApp.accent.withValues(alpha: 0.3)),
                ),
              child: Text(
                'Voir tout',
                  style: TextStyle(
                    color: CouleursApp.accent,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        WidgetCollection<Livre>.listeHorizontale(
          elements: _livresRecents,
          enChargement: _chargementLivres,
          hauteur: 200, // UI Design: Augmente la hauteur pour s'assurer que les cartes sont visibles
          espacementHorizontal: 12, // UI Design: Espacement entre les cartes
          constructeurElement: (context, livre, index) {
            return WidgetCarte.livre(
              livre: livre,
              modeListe: true,
              largeur: 160, // UI Design: Légèrement plus large pour plus de lisibilité
              hauteur: 190, // UI Design: Augmente de 180 à 190 pour plus d'espace et éviter l'overflow
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DetailsLivreEcran(livre: livre),
                  ),
                );
              },
            );
          },
          messageEtatVide: 'Aucun livre récent disponible',
          iconeEtatVide: Icons.menu_book_outlined,
          padding: const EdgeInsets.symmetric(horizontal: 16), // UI Design: Padding pour éviter les débordements
        ),
      ],
    );
  }

  // UI Design: Section associations avec WidgetCollection
  Widget _construireSectionAssociations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Associations Étudiantes',
          style: StylesTexteApp.titre.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 4),
        Text(
          'Découvrez la vie étudiante à l\'UQAR',
          style: TextStyle(
            fontSize: 14,
            color: CouleursApp.texteFonce.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),
        WidgetCollection<Association>.listeHorizontale(
          elements: _associationsPopulaires,
          enChargement: _chargementAssociations,
          hauteur: 130, // UI Design: Augmente légèrement la hauteur de 120 à 130 pour éviter l'overflow
          espacementHorizontal: 12, // UI Design: Espacement entre les cartes
          constructeurElement: (context, association, index) {
            return WidgetCarte.association(
              nom: association.nom,
              description: association.description,
              icone: AssociationsUtils.obtenirIconeType(association.typeAssociation),
              couleurIcone: AssociationsUtils.obtenirCouleurType(association.typeAssociation),
              largeur: 140, // UI Design: Réduit légèrement la largeur de 150 à 140
              hauteur: 115, // UI Design: Réduit la hauteur de 120 à 115 pour plus de marge
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsAssociationEcran(association: association),
                  ),
                );
              },
            );
          },
          padding: const EdgeInsets.symmetric(horizontal: 16), // UI Design: Padding pour éviter les débordements
          messageEtatVide: 'Aucune association disponible',
          iconeEtatVide: Icons.groups_outlined,
        ),
      ],
    );
  }

  // UI Design: Section cantine avec WidgetCarte moderne
  Widget _construireSectionCantine() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
          'Cantine UQAR',
              style: StylesTexteApp.titre.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 4),
        Text(
          'Découvrez les menus du jour',
          style: TextStyle(
            fontSize: 14,
            color: CouleursApp.texteFonce.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            NavigationService.gererNavigationNavBar(context, 0); // Index 0 = Cantine
          },
          child: Container(
            padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [CouleursApp.accent, CouleursApp.accent.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
                  color: CouleursApp.accent.withValues(alpha: 0.3),
                  blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
            child: Row(
        children: [
                Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                          Icon(
                            Icons.restaurant_menu,
                            color: CouleursApp.blanc,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Menu du Jour',
                            style: TextStyle(
                              color: CouleursApp.blanc,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pâtes à la sauce marinara, salade césar, dessert du jour',
                        style: TextStyle(
                          color: CouleursApp.blanc.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: CouleursApp.blanc.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '12.99\$',
                              style: TextStyle(
                                color: CouleursApp.blanc,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                          const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                              'VÉG',
                        style: TextStyle(
                                color: CouleursApp.blanc,
                          fontSize: 10,
                                fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: CouleursApp.blanc,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 