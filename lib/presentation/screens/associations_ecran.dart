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
  const AssociationsEcran({super.key});

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
      
    } catch (e) {
      setState(() {
        _chargementAssociations = false;
      });
      
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
        
      } else if (_typeSelectionne != 'toutes') {
        associations = await _associationsRepository.obtenirAssociationsParType(_typeSelectionne);
        
      } else {
        associations = await _associationsRepository.obtenirToutesLesAssociations();
        
      }

      setState(() {
        _toutesLesAssociations = associations;
        _chargementAssociations = false;
      });
    } catch (e) {
      setState(() {
        _chargementAssociations = false;
      });
      
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
      appBar: WidgetBarreAppPersonnalisee(
        titre: 'Associations Étudiantes',
        sousTitre: 'Découvrez la vie étudiante UQAR',
        widgetFin: IconButton(
          icon: Icon(
            _modeRecherche ? Icons.search_off : Icons.search,
            color: CouleursApp.blanc,
            size: screenWidth * 0.06, // UI Design: Taille adaptative
          ),
          onPressed: _basculerRecherche,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: viewInsets.bottom + padding.bottom + screenHeight * 0.025, // UI Design: Padding adaptatif pour éviter les débordements
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section statistiques
              _construireSectionStatistiques(),
              SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
              
              // Section associations populaires
              if (_associationsPopulaires.isNotEmpty) ...[
                _construireSectionPopulaires(),
                SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
              ],
              
              // Section actualités récentes
              _construireSectionActualitesRecentes(),
              SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
              
              // Filtres
              _construireFiltres(),
              SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
              
              // Grille des associations
              _construireGrilleAssociations(),
              SizedBox(height: screenHeight * 0.025), // UI Design: Espacement adaptatif
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

  // UI Design: Section statistiques de vie étudiante UQAR modernisée
  Widget _construireSectionStatistiques() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    final totalAssociations = _toutesLesAssociations.length;
    final totalMembres = _toutesLesAssociations.fold(0, (sum, assoc) => sum + assoc.nombreMembres);
    final associationsActives = _toutesLesAssociations.where((a) => a.estActive).length;
    final tauxActivite = totalAssociations > 0 ? (associationsActives / totalAssociations * 100).round() : 0;

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec titre et icône
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.025),
                decoration: BoxDecoration(
                  color: CouleursApp.principal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.school,
                  color: CouleursApp.principal,
                  size: screenWidth * 0.06,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vie Étudiante UQAR',
                      style: StylesTexteApp.titre.copyWith(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.w700,
                        color: CouleursApp.texteFonce,
                      ),
                    ),
                    Text(
                      'Statistiques de la communauté',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.025),
          
          // Grille de statistiques modernes
          Row(
            children: [
              Expanded(
                child: _construireCarteStatistiqueModerne(
                  'Associations',
                  totalAssociations.toString(),
                  Icons.groups,
                  CouleursApp.principal,
                  'Total des associations',
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: _construireCarteStatistiqueModerne(
                  'Membres',
                  '${(totalMembres / 1000).toStringAsFixed(1)}k',
                  Icons.people,
                  CouleursApp.accent,
                  'Étudiants impliqués',
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            children: [
              Expanded(
                child: _construireCarteStatistiqueModerne(
                  'Actives',
                  associationsActives.toString(),
                  Icons.check_circle,
                  Colors.green,
                  'Associations actives',
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: _construireCarteStatistiqueModerne(
                  'Taux',
                  '$tauxActivite%',
                  Icons.trending_up,
                  Colors.orange,
                  'Taux d\'activité',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UI Design: Carte statistique moderne avec animations
  Widget _construireCarteStatistiqueModerne(String titre, String valeur, IconData icone, Color couleur, String description) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            couleur.withValues(alpha: 0.1),
            couleur.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: couleur.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: couleur.withValues(alpha: 0.1),
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
              Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: couleur.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icone,
                  color: couleur,
                  size: screenWidth * 0.05,
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: Text(
                  titre,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            valeur,
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: couleur,
            ),
          ),
          SizedBox(height: screenWidth * 0.01),
          Text(
            description,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: CouleursApp.texteFonce.withValues(alpha: 0.5),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // UI Design: Section associations populaires avec WidgetCollection
  Widget _construireSectionPopulaires() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Padding adaptatif
          child: Row(
            children: [
              Icon(
                Icons.trending_up,
                color: CouleursApp.principal,
                size: screenWidth * 0.06, // UI Design: Taille adaptative
              ),
              SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Text(
                'Les Plus Populaires',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                ),
                overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.015), // UI Design: Espacement adaptatif
        WidgetCollection<Association>.listeHorizontale(
          elements: _associationsPopulaires,
          hauteur: screenHeight * 0.12, // UI Design: Hauteur adaptative
          constructeurElement: (context, association, index) {
            return WidgetCarte.association(
              nom: association.nom,
              description: '${association.nombreMembresFormatte} membres',
              icone: AssociationsUtils.obtenirIconeType(association.typeAssociation),
              couleurIcone: AssociationsUtils.obtenirCouleurType(association.typeAssociation),
              largeur: screenWidth * 0.75, // UI Design: Largeur adaptative
              hauteur: screenHeight * 0.1, // UI Design: Hauteur adaptative
              modeHorizontal: true,
              onTap: () => _ouvrirDetailsAssociation(association),
            );
          },
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Padding adaptatif
          messageEtatVide: 'Aucune association populaire',
          iconeEtatVide: Icons.trending_up_outlined,
        ),
      ],
    );
  }

  // UI Design: Filtres pour les associations
  Widget _construireFiltres() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Padding adaptatif
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_modeRecherche) ...[
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03), // UI Design: Padding adaptatif
              decoration: BoxDecoration(
                color: CouleursApp.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CouleursApp.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: CouleursApp.accent, size: screenWidth * 0.05), // UI Design: Taille adaptative
                  SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
                  Expanded(
                    child: TextField(
                      controller: _controleurRecherche,
                      style: TextStyle(fontSize: screenWidth * 0.04), // UI Design: Taille adaptative
                      decoration: InputDecoration(
                        hintText: 'Rechercher une association...',
                        hintStyle: TextStyle(
                          color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                          fontSize: screenWidth * 0.04, // UI Design: Taille adaptative
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (valeur) {
                        setState(() {
                          _recherche = valeur;
                        });
                        _filtrerAssociations();
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.clear, color: CouleursApp.accent, size: screenWidth * 0.05), // UI Design: Taille adaptative
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
            SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
          ],
          Text(
            'Types d\'associations',
            style: StylesTexteApp.titre.copyWith(
              fontWeight: FontWeight.w600,
              color: CouleursApp.texteFonce,
              fontSize: screenWidth * 0.04, // UI Design: Taille adaptative
            ),
            overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
            maxLines: 1,
          ),
          SizedBox(height: screenHeight * 0.015), // UI Design: Espacement adaptatif
          Wrap(
            spacing: screenWidth * 0.02, // UI Design: Espacement adaptatif
            runSpacing: screenWidth * 0.02, // UI Design: Espacement adaptatif
            children: _typesAssociations.map((type) {
              final estSelectionne = type == _typeSelectionne;
              return FilterChip(
                label: Text(
                  _nomsTypes[type] ?? type,
                  style: TextStyle(fontSize: screenWidth * 0.035), // UI Design: Taille adaptative
                ),
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
                  fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Padding adaptatif
          child: Row(
            children: [
              Icon(
                Icons.groups,
                color: CouleursApp.principal,
                size: screenWidth * 0.06, // UI Design: Taille adaptative
              ),
              SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Expanded(
                child: Text(
                  'Toutes les Associations',
                  style: StylesTexteApp.titre.copyWith(
                    fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                  ),
                  overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                  maxLines: 1,
                ),
              ),
              Text(
                '${_toutesLesAssociations.length}',
                style: TextStyle(
                  fontSize: screenWidth * 0.04, // UI Design: Taille adaptative
                  fontWeight: FontWeight.w600,
                  color: CouleursApp.accent,
                ),
                overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.015), // UI Design: Espacement adaptatif
        
        // Liste verticale scrollable
        WidgetCollection<Association>.listeVerticale(
          elements: _toutesLesAssociations,
          enChargement: _chargementAssociations,
          reduireHauteur: true, // Éviter conflit de scroll avec SingleChildScrollView
          constructeurElement: (context, association, index) {
            return Container(
              margin: EdgeInsets.only(bottom: screenHeight * 0.015), // UI Design: Espacement adaptatif
              child: WidgetCarte.association(
                nom: association.nom,
                description: association.description,
                icone: AssociationsUtils.obtenirIconeType(association.typeAssociation),
                couleurIcone: AssociationsUtils.obtenirCouleurType(association.typeAssociation),
                largeur: double.infinity, // Prend toute la largeur
                hauteur: screenHeight * 0.1, // UI Design: Hauteur adaptative
                modeHorizontal: true, // Mode horizontal pour cartes rectangulaires
                onTap: () => _ouvrirDetailsAssociation(association), // Cliquable
              ),
            );
          },
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Padding adaptatif
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

  // UI Design: Section actualités récentes de toutes les associations
  Widget _construireSectionActualitesRecentes() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    final actualitesRecentes = _obtenirActualitesRecentes();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Padding adaptatif
          child: Row(
            children: [
              Icon(
                Icons.newspaper,
                color: CouleursApp.accent,
                size: screenWidth * 0.06, // UI Design: Taille adaptative
              ),
              SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Expanded(
                child: Text(
                  'Actualités Récentes',
                  style: StylesTexteApp.titre.copyWith(
                    fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                  ),
                  overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                  maxLines: 1,
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Toutes les actualités - À venir'),
                      backgroundColor: CouleursApp.accent,
                    ),
                  );
                },
                child: Text(
                  'Voir tout',
                  style: TextStyle(
                    color: CouleursApp.accent,
                    fontSize: screenWidth * 0.035, // UI Design: Taille adaptative
                  ),
                  overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.015), // UI Design: Espacement adaptatif
        SizedBox(
          height: screenHeight * 0.22, // UI Design: Hauteur adaptative
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // UI Design: Padding adaptatif
            itemCount: actualitesRecentes.length,
            itemBuilder: (context, index) {
              final actualite = actualitesRecentes[index];
              return Container(
                width: screenWidth * 0.75, // UI Design: Largeur adaptative
                margin: EdgeInsets.only(right: screenWidth * 0.04), // UI Design: Marge adaptative
                padding: EdgeInsets.all(screenWidth * 0.04), // UI Design: Padding adaptatif
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
                    // En-tête avec association et date
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02, // UI Design: Padding adaptatif
                            vertical: screenWidth * 0.01,
                          ),
                          decoration: BoxDecoration(
                            color: _obtenirCouleurAssociation(actualite['associationId']!).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            actualite['association']!,
                            style: TextStyle(
                              fontSize: screenWidth * 0.028, // UI Design: Taille adaptative
                              fontWeight: FontWeight.w600,
                              color: _obtenirCouleurAssociation(actualite['associationId']!),
                            ),
                            overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                            maxLines: 1,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          actualite['date']!,
                          style: TextStyle(
                            fontSize: screenWidth * 0.028, // UI Design: Taille adaptative
                            color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                          ),
                          overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                          maxLines: 1,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.015), // UI Design: Espacement adaptatif
                    
                    // Titre
                    Text(
                      actualite['titre']!,
                      style: TextStyle(
                        fontSize: screenWidth * 0.038, // UI Design: Taille adaptative
                        fontWeight: FontWeight.bold,
                        color: CouleursApp.texteFonce,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: screenHeight * 0.01), // UI Design: Espacement adaptatif
                    
                    // Description
                    Expanded(
                      child: Text(
                        actualite['description']!,
                        style: TextStyle(
                          fontSize: screenWidth * 0.033, // UI Design: Taille adaptative
                          color: CouleursApp.texteFonce.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Bouton voir plus
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Navigation vers l'association concernée
                          try {
                            final association = _toutesLesAssociations.firstWhere(
                              (a) => a.id == actualite['associationId'],
                            );
                            _ouvrirDetailsAssociation(association);
                          } catch (e) {
                            // Association non trouvée, afficher un message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Association non trouvée'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03, // UI Design: Padding adaptatif
                            vertical: screenWidth * 0.01,
                          ),
                        ),
                        child: Text(
                          'Voir plus',
                          style: TextStyle(
                            color: _obtenirCouleurAssociation(actualite['associationId']!),
                            fontSize: screenWidth * 0.03, // UI Design: Taille adaptative
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Obtenir les actualités récentes de toutes les associations
  List<Map<String, String>> _obtenirActualitesRecentes() {
    return [
      {
        'associationId': '1',
        'association': 'AÉUQAR',
        'date': '15 jan',
        'titre': 'Nouvelle assurance dentaire étendue',
        'description': 'Couverture dentaire améliorée pour tous les membres avec nouveaux avantages orthodontiques et remboursements élargis.'
      },
      {
        'associationId': '2',
        'association': 'Radio UQAR',
        'date': '12 jan',
        'titre': 'Nouveau studio d\'enregistrement',
        'description': 'Équipement professionnel installé pour améliorer la qualité des émissions étudiantes et podcasts.'
      },
      {
        'associationId': '3',
        'association': 'Sport UQAR',
        'date': '14 jan',
        'titre': 'Tournoi inter-universitaire',
        'description': 'Inscription ouverte pour le championnat provincial de volleyball en mars. Places limitées.'
      },
      {
        'associationId': '4',
        'association': 'Génie UQAR',
        'date': '13 jan',
        'titre': 'Génie Olympiques 2025',
        'description': 'Compétition annuelle d\'ingénierie avec défis techniques et prix pour les meilleures équipes.'
      },
    ];
  }

  // Obtenir couleur selon ID association
  Color _obtenirCouleurAssociation(String associationId) {
    try {
      final association = _toutesLesAssociations.firstWhere(
        (a) => a.id == associationId,
      );
      return AssociationsUtils.obtenirCouleurType(association.typeAssociation);
    } catch (e) {
      return CouleursApp.principal;
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