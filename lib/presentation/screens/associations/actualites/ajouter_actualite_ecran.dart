// UI Design: Écran d'ajout/modification d'actualités pour les chefs d'association
import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../domain/entities/association.dart';
import '../../../../domain/entities/actualite.dart';
import '../../../widgets/widget_barre_app_personnalisee.dart';
import '../../../../domain/repositories/actualites_repository.dart';
import '../../../services/authentification_service.dart';

class AjouterActualiteEcran extends StatefulWidget {
  final Association association;
  final Actualite? actualiteAModifier; // UI Design: Support de la modification

  const AjouterActualiteEcran({
    Key? key,
    required this.association,
    this.actualiteAModifier,
  }) : super(key: key);

  @override
  State<AjouterActualiteEcran> createState() => _AjouterActualiteEcranState();
}

class _AjouterActualiteEcranState extends State<AjouterActualiteEcran> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contenuController = TextEditingController();
  String _priorite = 'normale';
  bool _estEpinglee = false;
  bool _chargement = false;
  bool _modeModification = false;
  late final ActualitesRepository _actualitesRepository;

  final List<String> _priorites = ['normale', 'importante', 'urgente'];
  late final AuthentificationService _authentificationService;

  @override
  void initState() {
    super.initState();
    _actualitesRepository = ServiceLocator.obtenirService<ActualitesRepository>();
    _authentificationService = ServiceLocator.obtenirService<AuthentificationService>();
    _modeModification = widget.actualiteAModifier != null;
    
    if (_modeModification) {
      _remplirFormulaire(widget.actualiteAModifier!);
    }
  }

  void _remplirFormulaire(Actualite actualite) {
    _titreController.text = actualite.titre;
    _descriptionController.text = actualite.description;
    _contenuController.text = actualite.contenu;
    _priorite = actualite.priorite;
    _estEpinglee = actualite.estEpinglee;
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _contenuController.dispose();
    super.dispose();
  }

  Future<void> _sauvegarderActualite() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _chargement = true;
    });

    try {
      final actualite = Actualite(
        id: _modeModification ? widget.actualiteAModifier!.id : 'actu_${DateTime.now().millisecondsSinceEpoch}',
        titre: _titreController.text.trim(),
        description: _descriptionController.text.trim(),
        contenu: _contenuController.text.trim(),
        associationId: widget.association.id,
        auteur: _authentificationService.utilisateurActuel != null 
            ? '${_authentificationService.utilisateurActuel!.prenom} ${_authentificationService.utilisateurActuel!.nom}'
            : 'Chef de l\'association',
        datePublication: _modeModification ? widget.actualiteAModifier!.datePublication : DateTime.now(),
        priorite: _priorite,
        estEpinglee: _estEpinglee,
        nombreVues: _modeModification ? widget.actualiteAModifier!.nombreVues : 0,
        nombreLikes: _modeModification ? widget.actualiteAModifier!.nombreLikes : 0,
        tags: _modeModification ? widget.actualiteAModifier!.tags : [],
      );

      bool succes = false;
      if (_modeModification) {
        succes = await _actualitesRepository.mettreAJourActualite(actualite);
      } else {
        final actualiteAjoutee = await _actualitesRepository.ajouterActualite(actualite);
        succes = actualiteAjoutee.id.isNotEmpty;
      }

      if (!succes) {
        throw Exception('Échec de l\'opération');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _modeModification 
                      ? 'Actualité modifiée avec succès !' 
                      : 'Actualité ajoutée avec succès !',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Erreur: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _chargement = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: WidgetBarreAppPersonnalisee(
        titre: 'Ajouter une actualité',
        sousTitre: 'Association: ${widget.association.nom}',
        afficherBoutonRetour: true,
        ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // UI Design: En-tête avec informations de l'association
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF005499).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.article,
                              color: Color(0xFF005499),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nouvelle actualité',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF005499),
                                  ),
                                ),
                                Text(
                                  'Association: ${widget.association.nom}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // UI Design: Formulaire d'ajout d'actualité
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations de l\'actualité',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005499),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Titre
                      TextFormField(
                        controller: _titreController,
                        decoration: InputDecoration(
                          labelText: 'Titre de l\'actualité',
                          hintText: 'Ex: Réunion de l\'association',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF005499),
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.title, color: Color(0xFF005499)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le titre est requis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Décrivez votre actualité...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF005499),
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.description, color: Color(0xFF005499)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La description est requise';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Priorité
                      DropdownButtonFormField<String>(
                        value: _priorite,
                        decoration: InputDecoration(
                          labelText: 'Priorité',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF005499),
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.priority_high, color: Color(0xFF005499)),
                        ),
                        items: _priorites.map((priorite) {
                          return DropdownMenuItem(
                            value: priorite,
                            child: Text(
                              priorite.substring(0, 1).toUpperCase() + priorite.substring(1),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _priorite = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Épingler l'actualité
                      CheckboxListTile(
                        title: const Text('Épingler cette actualité'),
                        subtitle: const Text('L\'actualité apparaîtra en haut de la liste'),
                        value: _estEpinglee,
                        activeColor: const Color(0xFF005499),
                        onChanged: (value) {
                          setState(() {
                            _estEpinglee = value!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // UI Design: Bouton de sauvegarde
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _chargement ? null : _sauvegarderActualite,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005499),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _chargement
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Publier l\'actualité',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
