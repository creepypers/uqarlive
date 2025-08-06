import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/livre.dart';
import '../../domain/entities/association.dart';
import '../../domain/entities/utilisateur.dart';
import '../../domain/repositories/livres_repository.dart';
import '../../domain/repositories/associations_repository.dart';
import '../services/authentification_service.dart';
import 'details_livre_ecran.dart';
import 'associations_ecran.dart';
import 'details_association_ecran.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import '../widgets/widget_carte.dart';
import '../widgets/widget_collection.dart';
import '../services/navigation_service.dart';

// UI Design: Page d'accueil UqarLive avec AppBar, sections échange de livres/assos/cantine et navbar
class AccueilEcran extends StatefulWidget {
  const AccueilEcran({super.key});

  @override
  State<AccueilEcran> createState() => _AccueilEcranState();
}

class _AccueilEcranState extends State<AccueilEcran> {
  // Services et Repositories
  late final LivresRepository _livresRepository;
  late final AssociationsRepository _associationsRepository;
  late final AuthentificationService _authentificationService;
  
  // États des données
  Utilisateur? _utilisateurActuel;
  List<Livre> _mesLivres = [];
  List<Livre> _livresEnVente = [];
  List<Association> _mesAssociations = [];
  bool _chargementLivres = false;
  bool _chargementLivresVente = false;
  bool _chargementAssociations = false;
  bool _chargementUtilisateur = true;

  @override
  void initState() {
    super.initState();
    _initialiserRepositories();
    _chargerDonneesUtilisateur();
  }

  Future<void> _chargerDonneesUtilisateur() async {
    setState(() => _chargementUtilisateur = true);
    
    try {
      await _authentificationService.chargerUtilisateurActuel();
      _utilisateurActuel = _authentificationService.utilisateurActuel;
      
      if (_utilisateurActuel != null) {
        await Future.wait([
          _chargerMesLivres(),
          _chargerLivresEnVente(),
          _chargerMesAssociations(),
        ]);
      }
    } catch (e) {
      // Gérer l'erreur
    } finally {
      setState(() => _chargementUtilisateur = false);
    }
  }

  void _initialiserRepositories() {
    // UI Design: Injection de dépendances via ServiceLocator - Clean Architecture
    _livresRepository = ServiceLocator.obtenirService<LivresRepository>();
    _associationsRepository = ServiceLocator.obtenirService<AssociationsRepository>();
    _authentificationService = ServiceLocator.obtenirService<AuthentificationService>();
  }

  Future<void> _chargerMesLivres() async {
    if (_utilisateurActuel == null) return;
    
    setState(() => _chargementLivres = true);

    try {
      final tousLesLivres = await _livresRepository.obtenirTousLesLivres();
      setState(() {
        // UI Design: Filtrer pour obtenir les livres de l'utilisateur connecté
        _mesLivres = tousLesLivres
            .where((livre) => livre.proprietaireId == _utilisateurActuel!.id)
            .take(5)
            .toList();
        _chargementLivres = false;
      });
    } catch (e) {
      setState(() => _chargementLivres = false);
    }
  }

  Future<void> _chargerLivresEnVente() async {
    setState(() => _chargementLivresVente = true);

    try {
      final tousLesLivres = await _livresRepository.obtenirTousLesLivres();
      setState(() {
        // UI Design: Filtrer pour obtenir seulement les livres en vente
        _livresEnVente = tousLesLivres
            .where((livre) => livre.prix != null && livre.prix! > 0 && livre.estDisponible)
            .take(6)
            .toList();
        _chargementLivresVente = false;
      });
    } catch (e) {
      setState(() => _chargementLivresVente = false);
    }
  }

  Future<void> _chargerMesAssociations() async {
    if (_utilisateurActuel == null) return;
    
    setState(() => _chargementAssociations = true);

    try {
      // UI Design: Pour l'instant, simulation des associations de l'utilisateur
      final toutesLesAssociations = await _associationsRepository.obtenirAssociationsPopulaires(limite: 10);
      setState(() {
        // Simuler que l'utilisateur fait partie de quelques associations
        _mesAssociations = toutesLesAssociations.take(3).toList();
        _chargementAssociations = false;
      });
    } catch (e) {
      setState(() => _chargementAssociations = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI Design: Affichage du chargement si les données utilisateur ne sont pas encore chargées
    if (_chargementUtilisateur || _utilisateurActuel == null) {
      return const Scaffold(
        backgroundColor: CouleursApp.fond,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: WidgetBarreAppPersonnalisee(
        titre: 'Bienvenue',
        sousTitre: _utilisateurActuel != null 
            ? '${_utilisateurActuel!.prenom} ${_utilisateurActuel!.nom}'
            : 'Utilisateur',
        utilisateurConnecte: _utilisateurActuel,
        widgetFin: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: CouleursApp.blanc.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.ac_unit,
                    color: CouleursApp.blanc,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
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
                // Section actualités des assos
                _construireSectionActualites(),
                const SizedBox(height: 24),
                
                // Section mes livres
                _construireSectionMesLivres(),
                const SizedBox(height: 24),
                
                // Section mes associations
                _construireSectionMesAssociations(),
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

  // UI Design: Section mes livres avec WidgetCollection optimisé
  Widget _construireSectionMesLivres() {
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
                  'Mes Livres',
                  style: StylesTexteApp.titre.copyWith(fontSize: 22),
                ),
                Text(
                  'Vos livres universitaires',
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
              child: const Text(
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
          elements: _mesLivres,
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
          messageEtatVide: 'Vous n\'avez pas encore ajouté de livres',
          iconeEtatVide: Icons.menu_book_outlined,
          padding: const EdgeInsets.symmetric(horizontal: 16), // UI Design: Padding pour éviter les débordements
        ),
      ],
    );
  }

  // UI Design: Section livres en vente avec WidgetCollection
  Widget _construireSectionLivresEnVente() {
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
                  'Livres en Vente',
                  style: StylesTexteApp.titre.copyWith(fontSize: 22),
                ),
                Text(
                  'Livres disponibles à l\'achat',
                  style: TextStyle(
                    fontSize: 14,
                    color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                NavigationService.gererNavigationNavBar(context, 1); // Index 1 = Marketplace
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CouleursApp.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Voir tout',
                      style: TextStyle(
                        color: CouleursApp.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: CouleursApp.accent,
                      size: 12,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        WidgetCollection<Livre>.listeHorizontale(
          elements: _livresEnVente,
          enChargement: _chargementLivresVente,
          hauteur: 200,
          constructeurElement: (context, livre, index) => SizedBox(
            width: 140,
            child: WidgetCarte.livre(
              livre: livre,
              modeListe: true,
              hauteur: 185,
              largeur: 140,
              onTap: () => _naviguerVersDetailsLivre(livre),
            ),
          ),
          messageEtatVide: 'Aucun livre en vente pour le moment',
          iconeEtatVide: Icons.sell_outlined,
        ),
      ],
    );
  }

  // UI Design: Section mes associations avec design moderne
  Widget _construireSectionMesAssociations() {
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
                  'Mes Associations',
                  style: StylesTexteApp.titre.copyWith(fontSize: 22),
                ),
                Text(
                  'Vos associations et clubs',
                  style: TextStyle(
                    fontSize: 14,
                    color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AssociationsEcran(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: CouleursApp.principal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: CouleursApp.principal.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'Explorer',
                  style: TextStyle(
                    color: CouleursApp.principal,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _chargementAssociations
            ? const Center(child: CircularProgressIndicator())
            : _mesAssociations.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.groups_outlined,
                          size: 60,
                          color: CouleursApp.principal.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune association',
                          style: StylesTexteApp.moyenTitre.copyWith(
                            color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rejoignez des associations pour enrichir votre expérience étudiante',
                          style: StylesTexteApp.corpsNormal.copyWith(
                            color: CouleursApp.texteFonce.withValues(alpha: 0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _mesAssociations.length,
                      itemBuilder: (context, index) {
                        final association = _mesAssociations[index];
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: CouleursApp.blanc,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: CouleursApp.principal.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsAssociationEcran(association: association),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: CouleursApp.principal.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.groups,
                                          color: CouleursApp.principal,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Membre',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    association.nom,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: CouleursApp.texteFonce,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    association.typeAssociation.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: CouleursApp.principal,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ],
    );
  }

  // UI Design: Section actualités des associations avec design moderne
  Widget _construireSectionActualites() {
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
                  'Actualités',
                  style: StylesTexteApp.titre.copyWith(fontSize: 22),
                ),
                Text(
                  'Nouvelles de vos associations',
          style: TextStyle(
            fontSize: 14,
            color: CouleursApp.texteFonce.withValues(alpha: 0.6),
          ),
        ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AssociationsEcran(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: CouleursApp.principal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: CouleursApp.principal.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    color: CouleursApp.principal,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // UI Design: Liste horizontale d'actualités simulées
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3, // Afficher 3 actualités sur l'accueil
            itemBuilder: (context, index) {
              final actualites = [
                {
                  'titre': 'Tournoi Gaming Inter-Programmes',
                  'association': 'Étudiants Informatique',
                  'date': '25 Jan',
                  'priorite': 'haute',
                },
                {
                  'titre': 'Atelier Gestion du Stress',
                  'association': 'AGEUQAR',
                  'date': '24 Jan',
                  'priorite': 'haute',
                },
                {
                  'titre': 'Collecte Banque Alimentaire',
                  'association': 'Association Humanitaire',
                  'date': 'En cours',
                  'priorite': 'normale',
                },
              ];
              
              final actualite = actualites[index];
              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: CouleursApp.blanc,
                  borderRadius: BorderRadius.circular(12),
                  border: actualite['priorite'] == 'haute' 
                    ? Border.all(color: CouleursApp.principal, width: 2)
                    : null,
                  boxShadow: [
                    BoxShadow(
                      color: CouleursApp.principal.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge priorité si haute
                      if (actualite['priorite'] == 'haute') ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'URGENT',
                            style: TextStyle(
                              color: CouleursApp.blanc,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      // Titre
                      Text(
                        actualite['titre']!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: CouleursApp.texteFonce,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      // Association et date
                      Text(
                        actualite['association']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CouleursApp.principal,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        actualite['date']!,
                        style: TextStyle(
                          fontSize: 11,
                          color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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
                const Row(
                  children: [
                          Icon(
                            Icons.restaurant_menu,
                            color: CouleursApp.blanc,
                            size: 24,
                          ),
                          SizedBox(width: 8),
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
                            child: const Text(
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
                      child: const Text(
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
                const Icon(
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

  // UI Design: Navigation vers les détails d'un livre
  void _naviguerVersDetailsLivre(Livre livre) {
    Navigator.pushNamed(
      context,
      '/details_livre',
      arguments: livre,
    );
  }
} 