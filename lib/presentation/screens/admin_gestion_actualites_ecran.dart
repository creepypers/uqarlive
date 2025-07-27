// UI Design: Écran de gestion des actualités et événements pour les administrateurs
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/actualite.dart';
import '../../domain/repositories/actualites_repository.dart';
import '../widgets/widget_barre_app_navigation_admin.dart';
import '../widgets/widget_collection.dart';
import '../widgets/widget_section_statistiques.dart';


class AdminGestionActualitesEcran extends StatefulWidget {
  const AdminGestionActualitesEcran({super.key});

  @override
  State<AdminGestionActualitesEcran> createState() => _AdminGestionActualitesEcranState();
}

class _AdminGestionActualitesEcranState extends State<AdminGestionActualitesEcran> {
  late ActualitesRepository _actualitesRepository;
  List<Actualite> _actualites = [];
  List<Actualite> _actualitesFiltrees = [];
  bool _chargementEnCours = true;
  String _filtreRecherche = '';
  String _filtrePriorite = 'toutes'; // toutes, haute, normale, basse

  final TextEditingController _controleurRecherche = TextEditingController();

  @override
  void initState() {
    super.initState();
    _actualitesRepository = ServiceLocator.obtenirService<ActualitesRepository>();
    _chargerActualites();
  }

  Future<void> _chargerActualites() async {
    try {
      setState(() => _chargementEnCours = true);
      
      final actualites = await _actualitesRepository.obtenirToutesLesActualites();
      
      setState(() {
        _actualites = actualites;
        _appliquerFiltres();
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

  void _appliquerFiltres() {
    _actualitesFiltrees = _actualites.where((actualite) {
      // Filtre par recherche
      final rechercheOk = _filtreRecherche.isEmpty ||
          actualite.titre.toLowerCase().contains(_filtreRecherche.toLowerCase()) ||
          actualite.nomAssociation.toLowerCase().contains(_filtreRecherche.toLowerCase()) ||
          actualite.description.toLowerCase().contains(_filtreRecherche.toLowerCase());

      // Filtre par priorité
      final prioriteOk = _filtrePriorite == 'toutes' ||
          actualite.priorite == _filtrePriorite;

      return rechercheOk && prioriteOk;
    }).toList();

    // Tri par date de publication (plus récent en premier)
    _actualitesFiltrees.sort((a, b) => b.datePublication.compareTo(a.datePublication));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: WidgetBarreAppNavigationAdmin(
        titre: 'Gestion Actualités',
        sousTitre: '${_actualitesFiltrees.length} actualité(s)',
        sectionActive: 'actualites',
      ),
      body: Column(
        children: [
          _construireBarreRecherche(),
          _construireFiltres(),
          _construireStatistiques(),
          Expanded(
            child: _chargementEnCours
                ? const Center(child: CircularProgressIndicator())
                : _construireListeActualites(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _ajouterNouvelleActualite,
        backgroundColor: CouleursApp.principal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _construireBarreRecherche() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controleurRecherche,
        decoration: InputDecoration(
          hintText: 'Rechercher par titre, association ou contenu...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _filtreRecherche.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controleurRecherche.clear();
                    setState(() {
                      _filtreRecherche = '';
                      _appliquerFiltres();
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: CouleursApp.principal.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: CouleursApp.principal, width: 2),
          ),
        ),
        onChanged: (valeur) {
          setState(() {
            _filtreRecherche = valeur;
            _appliquerFiltres();
          });
        },
      ),
    );
  }

  Widget _construireFiltres() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Priorité:',
            style: StylesTexteApp.moyenTitre,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _construireFiltrePriorite('toutes', 'Toutes'),
                  const SizedBox(width: 8),
                  _construireFiltrePriorite('haute', 'Urgente'),
                  const SizedBox(width: 8),
                  _construireFiltrePriorite('normale', 'Normale'),
                  const SizedBox(width: 8),
                  _construireFiltrePriorite('basse', 'Basse'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireFiltrePriorite(String valeur, String libelle) {
    final estSelectionne = _filtrePriorite == valeur;
    Color couleur = CouleursApp.principal;
    
    if (valeur == 'haute') couleur = Colors.red;
    if (valeur == 'normale') couleur = CouleursApp.accent;
    if (valeur == 'basse') couleur = CouleursApp.gris;
    
    return FilterChip(
      label: Text(libelle),
      selected: estSelectionne,
      onSelected: (selectionne) {
        setState(() {
          _filtrePriorite = valeur;
          _appliquerFiltres();
        });
      },
      selectedColor: couleur.withValues(alpha: 0.2),
      checkmarkColor: couleur,
    );
  }

  Widget _construireStatistiques() {
    final epinglees = _actualites.where((a) => a.estEpinglee).length;
    final evenements = _actualites.where((a) => a.estEvenement).length;
    final urgentes = _actualites.where((a) => a.priorite == 'haute').length;
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: WidgetSectionStatistiques.associations(
        titre: 'Statistiques Actualités',
        statistiques: [
          ElementStatistique(
            valeur: _actualites.length.toString(),
            label: 'Total',
            icone: Icons.article,
            couleurIcone: CouleursApp.blanc,
          ),
          ElementStatistique(
            valeur: epinglees.toString(),
            label: 'Épinglées',
            icone: Icons.push_pin,
            couleurIcone: CouleursApp.blanc,
          ),
          ElementStatistique(
            valeur: evenements.toString(),
            label: 'Événements',
            icone: Icons.event,
            couleurIcone: CouleursApp.blanc,
          ),
          ElementStatistique(
            valeur: urgentes.toString(),
            label: 'Urgentes',
            icone: Icons.priority_high,
            couleurIcone: CouleursApp.blanc,
          ),
        ],
      ),
    );
  }

  Widget _construireListeActualites() {
    return WidgetCollection.listeVerticale(
      elements: _actualitesFiltrees,
      constructeurElement: (context, actualite, index) => _construireCarteActualite(actualite),
      espacementVertical: 16,
      messageEtatVide: 'Aucune actualité trouvée',
      iconeEtatVide: Icons.article_outlined,
      padding: const EdgeInsets.all(16),
    );
  }

  Widget _construireCarteActualite(Actualite actualite) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Entête avec priorité et association (badge épinglé déplacé)
            Row(
              children: [
                _construireBadgePriorite(actualite.priorite),
                const Spacer(),
                Flexible(
                  child: Text(
                    actualite.nomAssociation,
                    style: StylesTexteApp.corpsGris,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Titre et description
            Text(
              actualite.titre,
              style: StylesTexteApp.moyenTitre.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              actualite.description,
              style: StylesTexteApp.corpsGris,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 12),
            
            // Informations sur l'événement si applicable
            if (actualite.estEvenement && actualite.dateEvenement != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CouleursApp.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event, color: CouleursApp.accent, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Événement: ${_formaterDate(actualite.dateEvenement!)}',
                      style: StylesTexteApp.petitCorps.copyWith(color: CouleursApp.accent),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 12),
            
            // Statistiques et badge épinglé
            Row(
              children: [
                _construireStatMini(Icons.visibility, actualite.nombreVues.toString()),
                const SizedBox(width: 16),
                _construireStatMini(Icons.favorite, actualite.nombreLikes.toString()),
                const SizedBox(width: 16),
                if (actualite.estEpinglee) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.push_pin, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'ÉPINGLÉ',
                          style: StylesTexteApp.petitBlanc.copyWith(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Text(
                  'Publié le ${_formaterDate(actualite.datePublication)}',
                  style: StylesTexteApp.petitGris,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _construireBoutonAction(
                  'Modifier',
                  Icons.edit,
                  CouleursApp.accent,
                  () => _modifierActualite(actualite),
                ),
                _construireBoutonAction(
                  actualite.estEpinglee ? 'Désépingler' : 'Épingler',
                  actualite.estEpinglee ? Icons.push_pin : Icons.push_pin_outlined,
                  Colors.amber,
                  () => _basculerEpinglage(actualite),
                ),
                _construireBoutonAction(
                  'Supprimer',
                  Icons.delete,
                  Colors.red,
                  () => _supprimerActualite(actualite),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireBadgePriorite(String priorite) {
    Color couleur;
    String libelle;
    
    switch (priorite) {
      case 'haute':
        couleur = Colors.red;
        libelle = 'URGENT';
        break;
      case 'normale':
        couleur = CouleursApp.accent;
        libelle = 'NORMAL';
        break;
      case 'basse':
        couleur = CouleursApp.gris;
        libelle = 'INFO';
        break;
      default:
        couleur = CouleursApp.principal;
        libelle = 'AUTRE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: couleur,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        libelle,
        style: StylesTexteApp.petitBlanc.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _construireStatMini(IconData icone, String valeur) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 14, color: CouleursApp.gris),
        const SizedBox(width: 4),
        Text(
          valeur,
          style: StylesTexteApp.petitGris,
        ),
      ],
    );
  }

  Widget _construireBoutonAction(
    String libelle,
    IconData icone,
    Color couleur,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icone, size: 16),
      label: Text(libelle),
      style: ElevatedButton.styleFrom(
        backgroundColor: couleur,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  // UI Design: Actions de gestion
  void _ajouterNouvelleActualite() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Création d\'actualité - Fonctionnalité en développement'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _modifierActualite(Actualite actualite) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Modification "${actualite.titre}"'),
        backgroundColor: CouleursApp.accent,
      ),
    );
  }

  void _basculerEpinglage(Actualite actualite) async {
    final nouvelEtat = !actualite.estEpinglee;
    
    // Simulation de la mise à jour
    setState(() {
      final index = _actualites.indexWhere((a) => a.id == actualite.id);
      if (index != -1) {
        _actualites[index] = actualite.copyWith(estEpinglee: nouvelEtat);
        _appliquerFiltres();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Actualité ${nouvelEtat ? "épinglée" : "désépinglée"} !',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _supprimerActualite(Actualite actualite) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'actualité'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'actualité "${actualite.titre}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      setState(() {
        _actualites.removeWhere((a) => a.id == actualite.id);
        _appliquerFiltres();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Actualité supprimée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  String _formaterDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _controleurRecherche.dispose();
    super.dispose();
  }
} 