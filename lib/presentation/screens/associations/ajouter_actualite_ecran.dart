// UI Design: Écran d'ajout d'actualités pour les chefs d'association
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/actualite.dart';
import '../../../domain/entities/association.dart';
import '../../../presentation/services/actualites_service.dart';

class AjouterActualiteEcran extends StatefulWidget {
  final Association association;

  const AjouterActualiteEcran({
    Key? key,
    required this.association,
  }) : super(key: key);

  @override
  State<AjouterActualiteEcran> createState() => _AjouterActualiteEcranState();
}

class _AjouterActualiteEcranState extends State<AjouterActualiteEcran> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priorite = 'normale';
  bool _estEpinglee = false;
  bool _chargement = false;
  late final ActualitesService _actualitesService;

  final List<String> _priorites = ['normale', 'importante', 'urgente'];

  @override
  void initState() {
    super.initState();
    _actualitesService = ActualitesService();
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _sauvegarderActualite() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _chargement = true;
    });

    try {
      // Utilisation du service pour créer l'actualité
      await _actualitesService.creerActualite(
        titre: _titreController.text.trim(),
        description: _descriptionController.text.trim(),
        nomAssociation: widget.association.nom,
        auteur: 'Chef de l\'association', // TODO: Récupérer l'utilisateur connecté
        priorite: _priorite,
        estEpinglee: _estEpinglee,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Actualité ajoutée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une actualité'),
        backgroundColor: const Color(0xFF005499),
        foregroundColor: Colors.white,
        elevation: 0,
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
                        color: Colors.black.withOpacity(0.08),
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
                              color: const Color(0xFF005499).withOpacity(0.1),
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
                        color: Colors.black.withOpacity(0.08),
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
