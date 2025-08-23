import 'package:flutter/material.dart';
import '../../../widgets/widget_barre_app_personnalisee.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/evenement_types.dart';
import '../../../../domain/entities/association.dart';
import '../../../../domain/entities/evenement.dart';
import '../../../../domain/usercases/evenements_repository.dart';
class AjouterEvenementEcran extends StatefulWidget {
  final Association association;
  final Evenement? evenementAModifier; 
  const AjouterEvenementEcran({
    Key? key,
    required this.association,
    this.evenementAModifier,
  }) : super(key: key);
  @override
  State<AjouterEvenementEcran> createState() => _AjouterEvenementEcranState();
}
class _AjouterEvenementEcranState extends State<AjouterEvenementEcran> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lieuController = TextEditingController();
  final _organisateurController = TextEditingController();
  final _prixController = TextEditingController();
  DateTime _dateDebut = DateTime.now();
  DateTime _dateFin = DateTime.now().add(const Duration(hours: 2));
  String _typeEvenement = 'reunion';
  int _capaciteMaximale = 50;
  double _prix = 0.0;
  bool _inscriptionRequise = false;
  bool _chargement = false;
  bool _modeModification = false;
  late final EvenementsRepository _evenementsRepository;
  @override
  void initState() {
    super.initState();
    _evenementsRepository = ServiceLocator.obtenirService<EvenementsRepository>();
    _modeModification = widget.evenementAModifier != null;
    if (_modeModification) {
      _remplirFormulaire(widget.evenementAModifier!);
    }
  }
  void _remplirFormulaire(Evenement evenement) {
    _titreController.text = evenement.titre;
    _descriptionController.text = evenement.description;
    _lieuController.text = evenement.lieu;
    _organisateurController.text = evenement.organisateur;
    _prixController.text = evenement.prix?.toString() ?? '0';
    _dateDebut = evenement.dateDebut;
    _dateFin = evenement.dateFin;
    _typeEvenement = evenement.typeEvenement;
    _prix = evenement.prix ?? 0.0;
    _inscriptionRequise = evenement.inscriptionRequise;
  }
  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _lieuController.dispose();
    _organisateurController.dispose();
    _prixController.dispose();
    super.dispose();
  }
  Future<void> _selectionnerDate(BuildContext context, bool estDateDebut) async {
    final DateTime? dateSelectionnee = await showDatePicker(
      context: context,
      initialDate: estDateDebut ? _dateDebut : _dateFin,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF005499),
            ),
          ),
          child: child!,
        );
      },
    );
    if (dateSelectionnee != null) {
      setState(() {
        if (estDateDebut) {
          _dateDebut = dateSelectionnee;
          if (_dateFin.isBefore(_dateDebut)) {
            _dateFin = _dateDebut.add(const Duration(hours: 2));
          }
        } else {
          _dateFin = dateSelectionnee;
        }
      });
    }
  }
  Future<void> _selectionnerHeure(BuildContext context, bool estDateDebut) async {
    final TimeOfDay? heureSelectionnee = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(estDateDebut ? _dateDebut : _dateFin),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF005499),
            ),
          ),
          child: child!,
        );
      },
    );
    if (heureSelectionnee != null) {
      setState(() {
        if (estDateDebut) {
          _dateDebut = DateTime(
            _dateDebut.year,
            _dateDebut.month,
            _dateDebut.day,
            heureSelectionnee.hour,
            heureSelectionnee.minute,
          );
        } else {
          _dateFin = DateTime(
            _dateFin.year,
            _dateFin.month,
            _dateFin.day,
            heureSelectionnee.hour,
            heureSelectionnee.minute,
          );
        }
      });
    }
  }
  Future<void> _sauvegarderEvenement() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _chargement = true;
    });
    try {
      final evenement = Evenement(
        id: _modeModification ? widget.evenementAModifier!.id : 'evt_${DateTime.now().millisecondsSinceEpoch}',
        titre: _titreController.text.trim(),
        description: _descriptionController.text.trim(),
        lieu: _lieuController.text.trim(),
        organisateur: _organisateurController.text.trim(),
        associationId: widget.association.id,
        dateDebut: _dateDebut,
        dateFin: _dateFin,
        typeEvenement: _typeEvenement,
        dateCreation: _modeModification ? widget.evenementAModifier!.dateCreation : DateTime.now(),
        prix: _prix,
        inscriptionRequise: _inscriptionRequise,
      );
      bool succes = false;
      if (_modeModification) {
        succes = await _evenementsRepository.mettreAJourEvenement(evenement);
      } else {
        succes = await _evenementsRepository.ajouterEvenement(evenement);
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
                      ? 'Événement modifié avec succès !' 
                      : 'Événement créé avec succès !',
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
  String _formaterDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  String _formaterHeure(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetBarreAppPersonnalisee(
        titre: 'Créer un événement',
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
                              Icons.event,
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
                                  'Nouvel événement',
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
                        'Informations de l\'événement',
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
                          labelText: 'Titre de l\'événement',
                          hintText: 'Ex: Réunion mensuelle',
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
                      // Type d'événement
                      DropdownButtonFormField<String>(
                        value: _typeEvenement,
                        decoration: InputDecoration(
                          labelText: 'Type d\'événement',
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
                          prefixIcon: const Icon(Icons.category, color: Color(0xFF005499)),
                        ),
                        items: EvenementTypes.types.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              EvenementTypes.obtenirNomType(type),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _typeEvenement = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Décrivez votre événement...',
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
                      const SizedBox(height: 16),
                      // Lieu
                      TextFormField(
                        controller: _lieuController,
                        decoration: InputDecoration(
                          labelText: 'Lieu',
                          hintText: 'Ex: Salle A-101',
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
                          prefixIcon: const Icon(Icons.location_on, color: Color(0xFF005499)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le lieu est requis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Organisateur
                      TextFormField(
                        controller: _organisateurController,
                        decoration: InputDecoration(
                          labelText: 'Organisateur',
                          hintText: 'Nom de l\'organisateur',
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
                          prefixIcon: const Icon(Icons.person, color: Color(0xFF005499)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'L\'organisateur est requis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Date et heure de début
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Date de début',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF005499),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectionnerDate(context, true),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFF005499)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today, color: Color(0xFF005499)),
                                        const SizedBox(width: 8),
                                        Text(_formaterDate(_dateDebut)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Heure de début',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF005499),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectionnerHeure(context, true),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFF005499)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.access_time, color: Color(0xFF005499)),
                                        const SizedBox(width: 8),
                                        Text(_formaterHeure(_dateDebut)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Date et heure de fin
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Date de fin',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF005499),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectionnerDate(context, false),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFF005499)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today, color: Color(0xFF005499)),
                                        const SizedBox(width: 8),
                                        Text(_formaterDate(_dateFin)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Heure de fin',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF005499),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectionnerHeure(context, false),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFF005499)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.access_time, color: Color(0xFF005499)),
                                        const SizedBox(width: 8),
                                        Text(_formaterHeure(_dateFin)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Capacité maximale
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Capacité maximale',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF005499),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: _capaciteMaximale.toDouble(),
                                  min: 1,
                                  max: 200,
                                  divisions: 199,
                                  activeColor: const Color(0xFF005499),
                                  onChanged: (value) {
                                    setState(() {
                                      _capaciteMaximale = value.round();
                                    });
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF005499),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$_capaciteMaximale',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _chargement ? null : _sauvegarderEvenement,
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
                            'Créer l\'événement',
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