// UI Design: Écran d'ajout d'événement avec gestion de date/heure et validation
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/evenement.dart';

class AdminAjouterEvenementEcran extends StatefulWidget {
  final Evenement? evenementAModifier;

  const AdminAjouterEvenementEcran({
    super.key,
    this.evenementAModifier,
  });

  @override
  State<AdminAjouterEvenementEcran> createState() => _AdminAjouterEvenementEcranState();
}

class _AdminAjouterEvenementEcranState extends State<AdminAjouterEvenementEcran> {
  final GlobalKey<FormState> _cleFormulaire = GlobalKey<FormState>();
  
  // Contrôleurs de texte
  final TextEditingController _controleurTitre = TextEditingController();
  final TextEditingController _controleurDescription = TextEditingController();
  final TextEditingController _controleurLieu = TextEditingController();
  final TextEditingController _controleurOrganisateur = TextEditingController();
  final TextEditingController _controleurPrix = TextEditingController();
  final TextEditingController _controleurCapaciteMax = TextEditingController();
  
  // Variables d'état
  DateTime _dateDebut = DateTime.now().add(const Duration(days: 1));
  DateTime _dateFin = DateTime.now().add(const Duration(days: 1, hours: 2));
  TimeOfDay _heureDebut = TimeOfDay.now();
  TimeOfDay _heureFin = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 2);
  bool _estGratuit = true;
  bool _inscriptionRequise = false;
  bool _enChargement = false;
  
  // Types d'événements
  final List<Map<String, String>> _typesEvenements = const [
    {'valeur': 'conference', 'libelle': 'Conférence'},
    {'valeur': 'atelier', 'libelle': 'Atelier'},
    {'valeur': 'social', 'libelle': 'Événement social'},
    {'valeur': 'sportif', 'libelle': 'Événement sportif'},
    {'valeur': 'culturel', 'libelle': 'Événement culturel'},
    {'valeur': 'academique', 'libelle': 'Événement académique'},
    {'valeur': 'autre', 'libelle': 'Autre'},
  ];
  String _typeSelectionne = 'conference';
  bool _modeModification = false;

  @override
  void initState() {
    super.initState();
    _modeModification = widget.evenementAModifier != null;
    
    if (_modeModification) {
      _remplirFormulaire(widget.evenementAModifier!);
    }
  }

  void _remplirFormulaire(Evenement evenement) {
    _controleurTitre.text = evenement.titre;
    _controleurDescription.text = evenement.description;
    _controleurLieu.text = evenement.lieu;
    _controleurOrganisateur.text = evenement.organisateur;
    _controleurPrix.text = evenement.prix?.toString() ?? '';
    _controleurCapaciteMax.text = evenement.capaciteMaximale?.toString() ?? '';
    
    // Définir les dates et heures
    _dateDebut = DateTime(evenement.dateDebut.year, evenement.dateDebut.month, evenement.dateDebut.day);
    _dateFin = DateTime(evenement.dateFin.year, evenement.dateFin.month, evenement.dateFin.day);
    _heureDebut = TimeOfDay.fromDateTime(evenement.dateDebut);
    _heureFin = TimeOfDay.fromDateTime(evenement.dateFin);
    
    // Définir les options
    _estGratuit = evenement.estGratuit;
    _inscriptionRequise = evenement.inscriptionRequise;
    
    // Vérifier si le type existe
    final typeExiste = _typesEvenements.any((type) => type['valeur'] == evenement.typeEvenement);
    _typeSelectionne = typeExiste ? evenement.typeEvenement : 'conference';
  }

  @override
  void dispose() {
    _controleurTitre.dispose();
    _controleurDescription.dispose();
    _controleurLieu.dispose();
    _controleurOrganisateur.dispose();
    _controleurPrix.dispose();
    _controleurCapaciteMax.dispose();
    super.dispose();
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
      appBar: AppBar(
        backgroundColor: CouleursApp.principal,
        foregroundColor: CouleursApp.blanc,
        title: Text(
          _modeModification ? 'Modifier Événement' : 'Ajouter Événement',
          style: TextStyle(fontSize: screenWidth * 0.045), // UI Design: Taille adaptative
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: _enChargement
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                left: screenWidth * 0.04, // UI Design: Padding adaptatif
                right: screenWidth * 0.04,
                top: screenHeight * 0.02,
                bottom: viewInsets.bottom + padding.bottom + screenHeight * 0.025, // UI Design: Padding adaptatif pour éviter les débordements
              ),
            child: Form(
              key: _cleFormulaire,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _construireSectionInformationsGenerales(),
                  const SizedBox(height: 24),
                  _construireSectionDateHeure(),
                  const SizedBox(height: 24),
                  _construireSectionInscription(),
                  const SizedBox(height: 32),
                  _construireBoutonsAction(),
                ],
              ),
            ),
          ),
      ),
    );
  }

  // UI Design: Section des informations générales
  Widget _construireSectionInformationsGenerales() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations générales',
              style: StylesTexteApp.grandTitre,
            ),
            const SizedBox(height: 16),
            
            // Titre
            TextFormField(
              controller: _controleurTitre,
              decoration: InputDecoration(
                labelText: 'Titre de l\'événement *',
                hintText: 'Ex: Conférence sur l\'intelligence artificielle',
                prefixIcon: const Icon(Icons.event, color: CouleursApp.principal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CouleursApp.principal, width: 2),
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
            
            // Type d'événement
            DropdownButtonFormField<String>(
              value: _typeSelectionne,
              decoration: InputDecoration(
                labelText: 'Type d\'événement *',
                prefixIcon: const Icon(Icons.category, color: CouleursApp.principal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CouleursApp.principal, width: 2),
                ),
              ),
              items: _typesEvenements.map((type) => DropdownMenuItem(
                value: type['valeur'],
                child: Text(type['libelle']!),
              )).toList(),
              onChanged: (valeur) {
                setState(() {
                  _typeSelectionne = valeur!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _controleurDescription,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description *',
                hintText: 'Décrivez l\'événement, les objectifs et le programme...',
                prefixIcon: const Icon(Icons.description, color: CouleursApp.principal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CouleursApp.principal, width: 2),
                ),
              ),
              validator: (valeur) {
                if (valeur == null || valeur.trim().isEmpty) {
                  return 'La description est obligatoire';
                }
                if (valeur.trim().length < 20) {
                  return 'La description doit contenir au moins 20 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Lieu
            TextFormField(
              controller: _controleurLieu,
              decoration: InputDecoration(
                labelText: 'Lieu *',
                hintText: 'Ex: Salle A-101, Pavillon principal',
                prefixIcon: const Icon(Icons.location_on, color: CouleursApp.principal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CouleursApp.principal, width: 2),
                ),
              ),
              validator: (valeur) {
                if (valeur == null || valeur.trim().isEmpty) {
                  return 'Le lieu est obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Organisateur
            TextFormField(
              controller: _controleurOrganisateur,
              decoration: InputDecoration(
                labelText: 'Organisateur *',
                hintText: 'Ex: Association des étudiants en informatique',
                prefixIcon: const Icon(Icons.person, color: CouleursApp.principal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CouleursApp.principal, width: 2),
                ),
              ),
              validator: (valeur) {
                if (valeur == null || valeur.trim().isEmpty) {
                  return 'L\'organisateur est obligatoire';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // UI Design: Section date et heure
  Widget _construireSectionDateHeure() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Date et heure',
              style: StylesTexteApp.grandTitre,
            ),
            const SizedBox(height: 16),
            
            // Date de début
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectionnerDate(true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date de début',
                        prefixIcon: const Icon(Icons.calendar_today, color: CouleursApp.principal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '${_dateDebut.day}/${_dateDebut.month}/${_dateDebut.year}',
                        style: StylesTexteApp.corpsNormal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectionnerHeure(true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Heure de début',
                        prefixIcon: const Icon(Icons.access_time, color: CouleursApp.principal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _heureDebut.format(context),
                        style: StylesTexteApp.corpsNormal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Date de fin
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectionnerDate(false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date de fin',
                        prefixIcon: const Icon(Icons.calendar_today, color: CouleursApp.principal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '${_dateFin.day}/${_dateFin.month}/${_dateFin.year}',
                        style: StylesTexteApp.corpsNormal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectionnerHeure(false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Heure de fin',
                        prefixIcon: const Icon(Icons.access_time, color: CouleursApp.principal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _heureFin.format(context),
                        style: StylesTexteApp.corpsNormal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // UI Design: Section inscription et prix
  Widget _construireSectionInscription() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inscription et participation',
              style: StylesTexteApp.grandTitre,
            ),
            const SizedBox(height: 16),
            
            // Inscription requise
            SwitchListTile(
              title: const Text(
                'Inscription requise',
                style: StylesTexteApp.moyenTitre,
              ),
              subtitle: Text(
                _inscriptionRequise 
                  ? 'Les participants doivent s\'inscrire à l\'avance'
                  : 'Événement libre d\'accès',
                style: StylesTexteApp.corpsGris,
              ),
              value: _inscriptionRequise,
              onChanged: (valeur) {
                setState(() {
                  _inscriptionRequise = valeur;
                });
              },
              activeColor: CouleursApp.principal,
            ),
            
            if (_inscriptionRequise) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _controleurCapaciteMax,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Capacité maximale',
                  hintText: 'Ex: 50',
                  prefixIcon: const Icon(Icons.people, color: CouleursApp.principal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: CouleursApp.principal, width: 2),
                  ),
                ),
                validator: (valeur) {
                  if (_inscriptionRequise && (valeur == null || valeur.isEmpty)) {
                    return 'La capacité maximale est requise pour les événements avec inscription';
                  }
                  if (valeur != null && valeur.isNotEmpty) {
                    final capacite = int.tryParse(valeur);
                    if (capacite == null || capacite <= 0) {
                      return 'La capacité doit être un nombre positif';
                    }
                  }
                  return null;
                },
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Événement gratuit
            SwitchListTile(
              title: const Text(
                'Événement gratuit',
                style: StylesTexteApp.moyenTitre,
              ),
              subtitle: Text(
                _estGratuit 
                  ? 'Aucun frais pour participer'
                  : 'Frais de participation requis',
                style: StylesTexteApp.corpsGris,
              ),
              value: _estGratuit,
              onChanged: (valeur) {
                setState(() {
                  _estGratuit = valeur;
                });
              },
              activeColor: CouleursApp.principal,
            ),
            
            if (!_estGratuit) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _controleurPrix,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Prix de participation',
                  hintText: 'Ex: 15.00',
                  prefixIcon: const Icon(Icons.attach_money, color: CouleursApp.principal),
                  suffixText: 'CAD',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: CouleursApp.principal, width: 2),
                  ),
                ),
                validator: (valeur) {
                  if (!_estGratuit && (valeur == null || valeur.isEmpty)) {
                    return 'Le prix est requis pour les événements payants';
                  }
                  if (valeur != null && valeur.isNotEmpty) {
                    final prix = double.tryParse(valeur);
                    if (prix == null || prix < 0) {
                      return 'Le prix doit être un nombre positif';
                    }
                  }
                  return null;
                },
              ),
            ],
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
              side: const BorderSide(color: CouleursApp.principal),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Annuler',
              style: StylesTexteApp.lienPrincipal,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _enregistrerEvenement,
            style: ElevatedButton.styleFrom(
              backgroundColor: CouleursApp.principal,
              foregroundColor: CouleursApp.blanc,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              _modeModification ? 'Modifier Événement' : 'Créer Événement',
              style: StylesTexteApp.bouton,
            ),
          ),
        ),
      ],
    );
  }

  // Méthodes de gestion
  Future<void> _selectionnerDate(bool estDebut) async {
    final dateSelectionnee = await showDatePicker(
      context: context,
      initialDate: estDebut ? _dateDebut : _dateFin,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (dateSelectionnee != null) {
      setState(() {
        if (estDebut) {
          _dateDebut = dateSelectionnee;
          // Assurer que la date de fin n'est pas avant la date de début
          if (_dateFin.isBefore(_dateDebut)) {
            _dateFin = _dateDebut;
          }
        } else {
          _dateFin = dateSelectionnee;
        }
      });
    }
  }

  Future<void> _selectionnerHeure(bool estDebut) async {
    final heureSelectionnee = await showTimePicker(
      context: context,
      initialTime: estDebut ? _heureDebut : _heureFin,
    );

    if (heureSelectionnee != null) {
      setState(() {
        if (estDebut) {
          _heureDebut = heureSelectionnee;
        } else {
          _heureFin = heureSelectionnee;
        }
      });
    }
  }

  Future<void> _enregistrerEvenement() async {
    if (!_cleFormulaire.currentState!.validate()) {
      return;
    }

    // Validation des dates
    final dateTimeDebut = DateTime(
      _dateDebut.year,
      _dateDebut.month,
      _dateDebut.day,
      _heureDebut.hour,
      _heureDebut.minute,
    );
    
    final dateTimeFin = DateTime(
      _dateFin.year,
      _dateFin.month,
      _dateFin.day,
      _heureFin.hour,
      _heureFin.minute,
    );

    if (dateTimeFin.isBefore(dateTimeDebut)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de fin doit être après la date de début'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _enChargement = true);

    try {
      final evenement = Evenement(
        id: _modeModification ? widget.evenementAModifier!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        titre: _controleurTitre.text.trim(),
        description: _controleurDescription.text.trim(),
        typeEvenement: _typeSelectionne,
        lieu: _controleurLieu.text.trim(),
        organisateur: _controleurOrganisateur.text.trim(),
        dateDebut: dateTimeDebut,
        dateFin: dateTimeFin,
        estGratuit: _estGratuit,
        prix: _estGratuit ? null : double.tryParse(_controleurPrix.text.trim()),
        inscriptionRequise: _inscriptionRequise,
        capaciteMaximale: _controleurCapaciteMax.text.trim().isEmpty ? null : int.tryParse(_controleurCapaciteMax.text.trim()),
        nombreInscrits: _modeModification ? widget.evenementAModifier!.nombreInscrits : 0,
        dateCreation: _modeModification ? widget.evenementAModifier!.dateCreation : DateTime.now(),
      );

      // TODO: Implémenter la sauvegarde dans le repository
      if (_modeModification) {
        // await _evenementsRepository.mettreAJourEvenement(evenement);
      } else {
        // await _evenementsRepository.ajouterEvenement(evenement);
      }

      await Future.delayed(const Duration(seconds: 1)); // Simulation

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_modeModification ? 'Événement modifié avec succès !' : 'Événement créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_modeModification ? 'Erreur lors de la modification: $e' : 'Erreur lors de la création: $e'),
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