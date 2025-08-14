// UI Design: Écran pour afficher toutes les actualités et événements
import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/actualite.dart';

import '../../../domain/repositories/actualites_repository.dart';
import '../../../domain/repositories/associations_repository.dart';

import '../../widgets/widget_barre_app_personnalisee.dart';

class ActualitesEcran extends StatefulWidget {
  const ActualitesEcran({super.key});

  @override
  State<ActualitesEcran> createState() => _ActualitesEcranState();
}

class _ActualitesEcranState extends State<ActualitesEcran>
    with SingleTickerProviderStateMixin {
  late final ActualitesRepository _actualitesRepository;
  late final AssociationsRepository _associationsRepository;
  late TabController _tabController;

  List<Actualite> _toutesActualites = [];
  List<Actualite> _actualitesEpinglees = [];
  List<Actualite> _actualitesNormales = [];
  bool _chargement = true;
  String _filtrePriorite = 'toutes';
  final Map<String, String> _nomsAssociations = {}; // Cache des noms d'associations

  @override
  void initState() {
    super.initState();
    _initialiserServices();
    _tabController = TabController(length: 3, vsync: this);
    _chargerActualites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initialiserServices() {
    _actualitesRepository = ServiceLocator.obtenirService<ActualitesRepository>();
    _associationsRepository = ServiceLocator.obtenirService<AssociationsRepository>();
  }

  Future<void> _chargerActualites() async {
    setState(() => _chargement = true);

    try {
      // Charger les actualités et les associations en parallèle
      final futures = await Future.wait([
        _actualitesRepository.obtenirActualites(),
        _actualitesRepository.obtenirActualitesEpinglees(),
        _associationsRepository.obtenirAssociationsPopulaires(limite: 50),
      ]);

      final actualites = futures[0] as List<Actualite>;
      final actualitesEpinglees = futures[1] as List<Actualite>;
      final associations = futures[2] as List;

      // Construire le cache des noms d'associations
      _nomsAssociations.clear();
      _nomsAssociations['admin_general'] = 'UQAR - Administration';
      for (final association in associations) {
        _nomsAssociations[association.id] = association.nom;
      }

      setState(() {
        _toutesActualites = actualites;
        _actualitesEpinglees = actualitesEpinglees;
        _actualitesNormales = actualites.where((a) => !a.estEpinglee).toList();
        _chargement = false;
      });
    } catch (e) {
      setState(() => _chargement = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des actualités: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: const WidgetBarreAppPersonnalisee(
        titre: 'Actualités',
        sousTitre: 'Toutes les nouvelles de l\'UQAR',
        afficherBoutonRetour: true,
      ),
      body: Column(
        children: [
          // Filtre par priorité
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Row(
              children: [
                Text(
                  'Filtrer par priorité:',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                    color: CouleursApp.texteFonce,
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _construireBoutonFiltre('toutes', 'Toutes'),
                        SizedBox(width: screenWidth * 0.02),
                        _construireBoutonFiltre('urgente', 'Urgentes'),
                        SizedBox(width: screenWidth * 0.02),
                        _construireBoutonFiltre('importante', 'Importantes'),
                        SizedBox(width: screenWidth * 0.02),
                        _construireBoutonFiltre('normale', 'Normales'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Onglets
          Container(
            color: CouleursApp.blanc,
            child: TabBar(
              controller: _tabController,
              labelColor: CouleursApp.principal,
              unselectedLabelColor: CouleursApp.texteFonce.withValues(alpha: 0.6),
              indicatorColor: CouleursApp.principal,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Toutes'),
                Tab(text: 'Épinglées'),
                Tab(text: 'Récentes'),
              ],
            ),
          ),
          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _construireListeActualites(_obtenirActualitesFiltrees(_toutesActualites)),
                _construireListeActualites(_actualitesEpinglees),
                _construireListeActualites(_actualitesNormales),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireBoutonFiltre(String valeur, String libelle) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final estSelectionne = _filtrePriorite == valeur;

    return GestureDetector(
      onTap: () {
        setState(() {
          _filtrePriorite = valeur;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: screenWidth * 0.02,
        ),
        decoration: BoxDecoration(
          color: estSelectionne 
            ? CouleursApp.principal 
            : CouleursApp.principal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: CouleursApp.principal,
            width: 1,
          ),
        ),
        child: Text(
          libelle,
          style: TextStyle(
            color: estSelectionne ? CouleursApp.blanc : CouleursApp.principal,
            fontSize: screenWidth * 0.03,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  List<Actualite> _obtenirActualitesFiltrees(List<Actualite> actualites) {
    if (_filtrePriorite == 'toutes') {
      return actualites;
    }
    return actualites.where((a) => a.priorite == _filtrePriorite).toList();
  }

  Widget _construireListeActualites(List<Actualite> actualites) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    if (_chargement) {
      return const Center(
        child: CircularProgressIndicator(
          color: CouleursApp.principal,
        ),
      );
    }

    if (actualites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.newspaper_outlined,
              size: screenWidth * 0.2,
              color: CouleursApp.texteFonce.withValues(alpha: 0.3),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Aucune actualité trouvée',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: CouleursApp.texteFonce.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'Les nouvelles actualités apparaîtront ici',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: CouleursApp.texteFonce.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _chargerActualites,
      color: CouleursApp.principal,
      child: ListView.builder(
        padding: EdgeInsets.all(screenWidth * 0.04),
        itemCount: actualites.length,
        itemBuilder: (context, index) {
          final actualite = actualites[index];
          return _construireCarteActualite(actualite);
        },
      ),
    );
  }

  Widget _construireCarteActualite(Actualite actualite) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        border: actualite.priorite == 'urgente'
          ? Border.all(color: Colors.red, width: 2)
          : actualite.priorite == 'importante' 
            ? Border.all(color: Colors.orange, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec badge et épingle
            Row(
              children: [
                // Badge priorité
                if (actualite.priorite == 'urgente') ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.025,
                      vertical: screenWidth * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'URGENT',
                      style: TextStyle(
                        color: CouleursApp.blanc,
                        fontSize: screenWidth * 0.028,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                ] else if (actualite.priorite == 'importante') ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.025,
                      vertical: screenWidth * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'IMPORTANT',
                      style: TextStyle(
                        color: CouleursApp.blanc,
                        fontSize: screenWidth * 0.028,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                ],
                // Badge épinglé
                if (actualite.estEpinglee) ...[
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.015),
                    decoration: BoxDecoration(
                      color: CouleursApp.principal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.push_pin,
                      color: CouleursApp.principal,
                      size: screenWidth * 0.035,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                ],
                const Spacer(),
                // Date
                Text(
                  _formaterDateActualite(actualite.datePublication),
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.015),
            // Titre
            Text(
              actualite.titre,
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: CouleursApp.texteFonce,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: screenHeight * 0.01),
            // Description
            Text(
              actualite.description,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: CouleursApp.texteFonce.withValues(alpha: 0.8),
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: screenHeight * 0.015),
            // Pied avec association et auteur
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.025,
                    vertical: screenWidth * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: CouleursApp.principal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _obtenirNomAssociation(actualite.associationId),
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: CouleursApp.principal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  '•',
                  style: TextStyle(
                    color: CouleursApp.texteFonce.withValues(alpha: 0.4),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Text(
                    'Par ${actualite.auteur}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formaterDateActualite(DateTime datePublication) {
    final maintenant = DateTime.now();
    final difference = maintenant.difference(datePublication);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      final semaines = (difference.inDays / 7).floor();
      return semaines == 1 ? 'Il y a 1 semaine' : 'Il y a $semaines semaines';
    } else {
      return '${datePublication.day}/${datePublication.month}/${datePublication.year}';
    }
  }

  String _obtenirNomAssociation(String associationId) {
    // Utiliser le cache des noms d'associations
    return _nomsAssociations[associationId] ?? 'Association';
  }
}
