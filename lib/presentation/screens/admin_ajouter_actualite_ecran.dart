// UI Design: Écran d'ajout d'actualité avec validation et respect des règles UQAR
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/actualite.dart';
import '../../domain/repositories/actualites_repository.dart';
import '../widgets/widget_barre_app_navigation_admin.dart';

class AdminAjouterActualiteEcran extends StatefulWidget {
  final Actualite? actualiteAModifier;

  const AdminAjouterActualiteEcran({
    super.key,
    this.actualiteAModifier,
  });

  @override
  State<AdminAjouterActualiteEcran> createState() => _AdminAjouterActualiteEcranState();
}

class _AdminAjouterActualiteEcranState extends State<AdminAjouterActualiteEcran> {
  final GlobalKey<FormState> _cleFormulaire = GlobalKey<FormState>();
  late ActualitesRepository _actualitesRepository;
  
  // Contrôleurs de texte
  final TextEditingController _controleurTitre = TextEditingController();
  final TextEditingController _controleurContenu = TextEditingController();
  final TextEditingController _controleurTags = TextEditingController();
  
  // Variables d'état
  bool _estEpinglee = false;
  bool _enChargement = false;
  bool _modeModification = false;
  DateTime _datePublication = DateTime.now();
  
  // Priorités
  final List<Map<String, dynamic>> _priorites = const [
    {'valeur': 'basse', 'libelle': 'Basse', 'couleur': Colors.green},
    {'valeur': 'normale', 'libelle': 'Normale', 'couleur': Colors.blue},
    {'valeur': 'haute', 'libelle': 'Haute', 'couleur': Colors.orange},
    {'valeur': 'urgente', 'libelle': 'Urgente', 'couleur': Colors.red},
  ];
  String _prioriteSelectionnee = 'normale';

  @override
  void initState() {
    super.initState();
    _actualitesRepository = ServiceLocator.obtenirService<ActualitesRepository>();
    _modeModification = widget.actualiteAModifier != null;
    
    if (_modeModification) {
      _remplirFormulaire(widget.actualiteAModifier!);
    }
  }

  @override
  void dispose() {
    _controleurTitre.dispose();
    _controleurContenu.dispose();
    _controleurTags.dispose();
    super.dispose();
  }

  void _remplirFormulaire(Actualite actualite) {
    _controleurTitre.text = actualite.titre;
    _controleurContenu.text = actualite.contenu;
    _controleurTags.text = actualite.tags.join(', ');
    _estEpinglee = actualite.estEpinglee;
    _datePublication = actualite.datePublication;
    
    // Vérifier si la priorité existe
    final prioriteExiste = _priorites.any((p) => p['valeur'] == actualite.priorite);
    _prioriteSelectionnee = prioriteExiste ? actualite.priorite : 'normale';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: WidgetBarreAppNavigationAdmin(
        titre: _modeModification ? 'Modifier Actualité' : 'Ajouter Actualité',
        sousTitre: _modeModification 
          ? 'Modifier l\'actualité sélectionnée'
          : 'Créer une nouvelle actualité d\'association',
        sectionActive: 'associations',
      ),
      body: _enChargement
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _cleFormulaire,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _construireSectionContenu(),
                  const SizedBox(height: 24),
                  _construireSectionParametres(),
                  const SizedBox(height: 32),
                  _construireBoutonsAction(),
                ],
              ),
            ),
          ),
    );
  }

  // UI Design: Section du contenu principal
  Widget _construireSectionContenu() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contenu de l\'actualité',
              style: StylesTexteApp.grandTitre,
            ),
            const SizedBox(height: 16),
            
            // Titre
            TextFormField(
              controller: _controleurTitre,
              decoration: InputDecoration(
                labelText: 'Titre *',
                hintText: 'Ex: Nouvelle activité de l\'association',
                prefixIcon: Icon(Icons.title, color: CouleursApp.principal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: CouleursApp.principal, width: 2),
                ),
              ),
              validator: (valeur) {
                if (valeur == null || valeur.trim().isEmpty) {
                  return 'Le titre est obligatoire';
                }
                if (valeur.trim().length < 5) {
                  return 'Le titre doit contenir au moins 5 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Contenu
            TextFormField(
              controller: _controleurContenu,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Contenu *',
                hintText: 'Rédigez le contenu détaillé de l\'actualité...',
                prefixIcon: Icon(Icons.article, color: CouleursApp.principal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: CouleursApp.principal, width: 2),
                ),
              ),
              validator: (valeur) {
                if (valeur == null || valeur.trim().isEmpty) {
                  return 'Le contenu est obligatoire';
                }
                if (valeur.trim().length < 20) {
                  return 'Le contenu doit contenir au moins 20 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Tags
            TextFormField(
              controller: _controleurTags,
              decoration: InputDecoration(
                labelText: 'Tags (optionnel)',
                hintText: 'Ex: événement, culture, sport (séparés par des virgules)',
                prefixIcon: Icon(Icons.tag, color: CouleursApp.principal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: CouleursApp.principal, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI Design: Section des paramètres
  Widget _construireSectionParametres() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paramètres de publication',
              style: StylesTexteApp.grandTitre,
            ),
            const SizedBox(height: 16),
            
            // Priorité
            DropdownButtonFormField<String>(
              value: _prioriteSelectionnee,
              decoration: InputDecoration(
                labelText: 'Priorité *',
                prefixIcon: Icon(Icons.priority_high, color: CouleursApp.principal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: CouleursApp.principal, width: 2),
                ),
              ),
              items: _priorites.map((priorite) => DropdownMenuItem<String>(
                value: priorite['valeur'] as String,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: priorite['couleur'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(priorite['libelle'] as String),
                  ],
                ),
              )).toList(),
              onChanged: (valeur) {
                setState(() {
                  _prioriteSelectionnee = valeur!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Date de publication
            InkWell(
              onTap: _selectionnerDatePublication,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date de publication',
                  prefixIcon: Icon(Icons.calendar_today, color: CouleursApp.principal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: CouleursApp.principal, width: 2),
                  ),
                ),
                child: Text(
                  '${_datePublication.day}/${_datePublication.month}/${_datePublication.year}',
                  style: StylesTexteApp.corpsNormal,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Épingler l'actualité
            SwitchListTile(
              title: Text(
                'Épingler l\'actualité',
                style: StylesTexteApp.moyenTitre,
              ),
              subtitle: Text(
                _estEpinglee 
                  ? 'L\'actualité sera affichée en haut de la liste'
                  : 'L\'actualité sera affichée dans l\'ordre chronologique',
                style: StylesTexteApp.corpsGris,
              ),
              value: _estEpinglee,
              onChanged: (valeur) {
                setState(() {
                  _estEpinglee = valeur;
                });
              },
              activeColor: CouleursApp.principal,
            ),
          ],
        ),
      ),
    );
  }

  // UI Design: Boutons d'action
  Widget _construireBoutonsAction() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: CouleursApp.principal),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Annuler',
              style: StylesTexteApp.lienPrincipal,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _enregistrerActualite,
            style: ElevatedButton.styleFrom(
              backgroundColor: CouleursApp.principal,
              foregroundColor: CouleursApp.blanc,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              _modeModification ? 'Modifier' : 'Publier',
              style: StylesTexteApp.bouton,
            ),
          ),
        ),
      ],
    );
  }

  // Méthodes de gestion
  Future<void> _selectionnerDatePublication() async {
    final dateSelectionnee = await showDatePicker(
      context: context,
      initialDate: _datePublication,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (dateSelectionnee != null) {
      setState(() {
        _datePublication = dateSelectionnee;
      });
    }
  }

  Future<void> _enregistrerActualite() async {
    if (!_cleFormulaire.currentState!.validate()) {
      return;
    }

    setState(() => _enChargement = true);

    try {
      // Parser les tags
      final tags = _controleurTags.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final actualite = Actualite(
        id: _modeModification ? widget.actualiteAModifier!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        titre: _controleurTitre.text.trim(),
        description: _controleurContenu.text.trim().length > 100 
            ? _controleurContenu.text.trim().substring(0, 100) + '...'
            : _controleurContenu.text.trim(),
        contenu: _controleurContenu.text.trim(),
        nomAssociation: 'Administration UQAR',
        auteur: 'Administrateur',
        datePublication: _datePublication,
        priorite: _prioriteSelectionnee,
        tags: tags,
        estEpinglee: _estEpinglee,
        nombreVues: _modeModification ? widget.actualiteAModifier!.nombreVues : 0,
        nombreLikes: _modeModification ? widget.actualiteAModifier!.nombreLikes : 0,
      );

      // TODO: Implémenter les méthodes d'ajout et modification dans le repository
      if (_modeModification) {
        // await _actualitesRepository.mettreAJourActualite(actualite);
        print('Modification actualité: ${actualite.titre}');
      } else {
        // await _actualitesRepository.ajouterActualite(actualite);
        print('Ajout actualité: ${actualite.titre}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _modeModification 
                ? 'Actualité modifiée avec succès !'
                : 'Actualité publiée avec succès !',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'enregistrement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _enChargement = false);
      }
    }
  }
} 