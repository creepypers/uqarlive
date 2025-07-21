import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/association.dart';
import '../../domain/repositories/associations_repository.dart';
import '../../data/repositories/associations_repository_impl.dart';
import '../../data/datasources/associations_datasource_local.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import '../widgets/widget_carte.dart';
import '../widgets/widget_collection.dart';
import '../widgets/widget_section_statistiques.dart';
import '../services/navigation_service.dart';
import '../utils/associations_utils.dart';
import 'details_association_ecran.dart';

// UI Design: Page associations étudiantes UQAR avec filtres et design moderne
class AssociationsEcran extends StatefulWidget {
  const AssociationsEcran({Key? key}) : super(key: key);

  @override
  State<AssociationsEcran> createState() => _AssociationsEcranState();
}

class _AssociationsEcranState extends State<AssociationsEcran> {
  // Repository pour accéder aux données des associations
  late final AssociationsRepository _associationsRepository;
  List<Association> _toutesLesAssociations = [];
  List<Association> _associationsPopulaires = [];
  List<String> _typesAssociations = [];
  String _typeSelectionne = 'toutes';
  bool _chargementAssociations = false;
  String _recherche = '';
  bool _modeRecherche = false;
  final TextEditingController _controleurRecherche = TextEditingController();

  final Map<String, String> _nomsTypes = {
    'toutes': 'Toutes',
    'etudiante': 'Étudiantes',
    'culturelle': 'Culturelles',
    'sportive': 'Sportives',
    'academique': 'Académiques',
  };

  @override
  void initState() {
    super.initState();
    _initialiserRepository();
    _chargerAssociations();
  }

  @override
  void dispose() {
    _controleurRecherche.dispose();
    super.dispose();
  }

  void _initialiserRepository() {
    final datasourceLocal = AssociationsDatasourceLocal();
    _associationsRepository = AssociationsRepositoryImpl(datasourceLocal);
  }

  Future<void> _chargerAssociations() async {
    setState(() {
      _chargementAssociations = true;
    });

    try {
      final results = await Future.wait([
        _associationsRepository.obtenirToutesLesAssociations(),
        _associationsRepository.obtenirAssociationsPopulaires(limite: 4),
        _associationsRepository.obtenirTypesAssociations(),
      ]);

      setState(() {
        _toutesLesAssociations = results[0] as List<Association>;
        _associationsPopulaires = results[1] as List<Association>;
        _typesAssociations = results[2] as List<String>;
        _chargementAssociations = false;
      });

      // UI Design: Debug - Afficher les données chargées
      print('✅ Associations chargées: ${_toutesLesAssociations.length}');
      print('✅ Associations populaires: ${_associationsPopulaires.length}');
      print('✅ Types disponibles: $_typesAssociations');
      
      // FIXE : Afficher le contenu des associations pour debugging
      for (var assoc in _toutesLesAssociations) {
        print('🏛️ Association: ${assoc.nom} (${assoc.typeAssociation})');
      }
      
    } catch (e) {
      setState(() {
        _chargementAssociations = false;
      });
      print('❌ Erreur lors du chargement des associations: $e');
    }
  }

  Future<void> _filtrerAssociations() async {
    setState(() {
      _chargementAssociations = true;
    });

    try {
      List<Association> associations;
      
      if (_recherche.isNotEmpty && _recherche.trim() != '') {
        associations = await _associationsRepository.rechercherAssociations(_recherche);
        print('🔍 Recherche "$_recherche": ${associations.length} résultats');
      } else if (_typeSelectionne != 'toutes') {
        associations = await _associationsRepository.obtenirAssociationsParType(_typeSelectionne);
        print('🏷️ Filtre type "$_typeSelectionne": ${associations.length} résultats');
      } else {
        associations = await _associationsRepository.obtenirToutesLesAssociations();
        print('📂 Toutes les associations: ${associations.length} résultats');
      }

      setState(() {
        _toutesLesAssociations = associations;
        _chargementAssociations = false;
      });
    } catch (e) {
      setState(() {
        _chargementAssociations = false;
      });
      print('❌ Erreur lors du filtrage des associations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: WidgetBarreAppPersonnalisee(
        titre: 'Associations Étudiantes',
        sousTitre: 'Découvrez la vie étudiante UQAR',
        widgetFin: IconButton(
          icon: Icon(
            _modeRecherche ? Icons.search_off : Icons.search,
            color: CouleursApp.blanc,
          ),
          onPressed: _basculerRecherche,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section statistiques
              _construireSectionStatistiques(),
              const SizedBox(height: 16),
              
              // Section associations populaires
              if (_associationsPopulaires.isNotEmpty) ...[
                _construireSectionPopulaires(),
                const SizedBox(height: 24),
              ],
              
              // Filtres
              _construireFiltres(),
              const SizedBox(height: 16),
              
              // Grille des associations
              _construireGrilleAssociations(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBarWidget(
        indexSelectionne: 3, // Associations
        onTap: (index) => NavigationService.gererNavigationNavBar(context, index),
      ),
    );
  }

  // UI Design: Section avec statistiques des associations - NOUVEAU WIDGET RÉUTILISABLE
  Widget _construireSectionStatistiques() {
    final totalAssociations = _toutesLesAssociations.length;
    final totalMembres = _toutesLesAssociations.fold(0, (sum, assoc) => sum + assoc.nombreMembres);
    final associationsActives = _toutesLesAssociations.where((a) => a.estActive).length;

    return WidgetSectionStatistiques.associations(
      titre: 'Vie Étudiante UQAR',
      statistiques: [
        ElementStatistique(
          valeur: '$totalAssociations',
          label: 'Associations',
        ),
        ElementStatistique(
          valeur: '${(totalMembres / 1000).toStringAsFixed(1)}k',
          label: 'Membres',
        ),
        ElementStatistique(
          valeur: '$associationsActives',
          label: 'Actives',
        ),
      ],
    );
  }

  // UI Design: Section associations populaires avec WidgetCollection
  Widget _construireSectionPopulaires() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.trending_up,
                color: CouleursApp.principal,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Les Plus Populaires',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        WidgetCollection<Association>.listeHorizontale(
          elements: _associationsPopulaires,
          hauteur: 100,
          constructeurElement: (context, association, index) {
            return WidgetCarte.association(
              nom: association.nom,
              description: '${association.nombreMembresFormatte} membres',
              icone: AssociationsUtils.obtenirIconeType(association.typeAssociation),
              couleurIcone: AssociationsUtils.obtenirCouleurType(association.typeAssociation),
              largeur: 300,
              hauteur: 80,
              modeHorizontal: true,
              onTap: () => _ouvrirDetailsAssociation(association),
            );
          },
          padding: const EdgeInsets.symmetric(horizontal: 16),
          messageEtatVide: 'Aucune association populaire',
          iconeEtatVide: Icons.trending_up_outlined,
        ),
      ],
    );
  }

  // UI Design: Filtres pour les associations
  Widget _construireFiltres() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_modeRecherche) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CouleursApp.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CouleursApp.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: CouleursApp.accent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controleurRecherche,
                      decoration: InputDecoration(
                        hintText: 'Rechercher une association...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: CouleursApp.texteFonce.withValues(alpha: 0.6)),
                      ),
                      style: TextStyle(color: CouleursApp.texteFonce),
                      onChanged: (valeur) {
                        setState(() {
                          _recherche = valeur;
                        });
                        _filtrerAssociations();
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.clear, color: CouleursApp.accent),
                    onPressed: () {
                      _controleurRecherche.clear();
                      setState(() {
                        _recherche = '';
                      });
                      _filtrerAssociations();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'Types d\'associations',
            style: StylesTexteApp.titre.copyWith(
              fontWeight: FontWeight.w600,
              color: CouleursApp.texteFonce,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _typesAssociations.map((type) {
              final estSelectionne = type == _typeSelectionne;
              return FilterChip(
                label: Text(_nomsTypes[type] ?? type),
                selected: estSelectionne,
                onSelected: (selected) {
                  setState(() {
                    _typeSelectionne = type;
                  });
                  _filtrerAssociations();
                },
                backgroundColor: CouleursApp.fond,
                selectedColor: CouleursApp.accent.withValues(alpha: 0.2),
                checkmarkColor: CouleursApp.accent,
                labelStyle: TextStyle(
                  color: estSelectionne ? CouleursApp.accent : CouleursApp.texteFonce,
                  fontWeight: estSelectionne ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: estSelectionne ? CouleursApp.accent : Colors.grey.shade300,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // UI Design: Liste verticale des associations avec cartes cliquables
  Widget _construireGrilleAssociations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.groups,
                color: CouleursApp.principal,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Toutes les Associations',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
              const Spacer(),
              Text(
                '${_toutesLesAssociations.length}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CouleursApp.accent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Liste verticale scrollable
        WidgetCollection<Association>.listeVerticale(
          elements: _toutesLesAssociations,
          enChargement: _chargementAssociations,
          reduireHauteur: true, // Éviter conflit de scroll avec SingleChildScrollView
          constructeurElement: (context, association, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12), // Espacement entre cartes
              child: WidgetCarte.association(
                nom: association.nom,
                description: association.description,
                icone: AssociationsUtils.obtenirIconeType(association.typeAssociation),
                couleurIcone: AssociationsUtils.obtenirCouleurType(association.typeAssociation),
                largeur: double.infinity, // Prend toute la largeur
                hauteur: 80, // Hauteur fixe horizontale
                modeHorizontal: true, // Mode horizontal pour cartes rectangulaires
                onTap: () => _ouvrirDetailsAssociation(association), // Cliquable
              ),
            );
          },
          padding: const EdgeInsets.symmetric(horizontal: 16),
          messageEtatVide: _recherche.isNotEmpty && _recherche.trim() != ''
            ? 'Aucune association trouvée pour "$_recherche"'
            : 'Aucune association disponible',
          iconeEtatVide: _recherche.isNotEmpty && _recherche.trim() != ''
            ? Icons.search_off_outlined 
            : Icons.groups_outlined,
        ),
      ],
    );
  }

  // Méthodes utilitaires
  void _basculerRecherche() {
    setState(() {
      _modeRecherche = !_modeRecherche;
      if (!_modeRecherche) {
        _recherche = '';
        _controleurRecherche.clear();
      }
    });
    // UI Design: Filtrer après basculement pour rafraîchir la liste
    if (!_modeRecherche) {
      _filtrerAssociations();
    }
  }

  void _ouvrirDetailsAssociation(Association association) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsAssociationEcran(association: association),
      ),
    );
  }
} 