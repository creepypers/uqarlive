// UI Design: Écran d'ajout d'association avec formulaire complet et validation
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/association.dart';
import '../../domain/repositories/associations_repository.dart';
import '../widgets/widget_barre_app_navigation_admin.dart';

class AdminAjouterAssociationEcran extends StatefulWidget {
  final Association? associationAModifier;

  const AdminAjouterAssociationEcran({
    super.key,
    this.associationAModifier,
  });

  @override
  State<AdminAjouterAssociationEcran> createState() => _AdminAjouterAssociationEcranState();
}

class _AdminAjouterAssociationEcranState extends State<AdminAjouterAssociationEcran> {
  final GlobalKey<FormState> _cleFormulaire = GlobalKey<FormState>();
  late AssociationsRepository _associationsRepository;
  
  // Contrôleurs de texte
  final TextEditingController _controleurNom = TextEditingController();
  final TextEditingController _controleurDescription = TextEditingController();
  final TextEditingController _controleurEmail = TextEditingController();
  final TextEditingController _controleurTelephone = TextEditingController();
  final TextEditingController _controleurSiteWeb = TextEditingController();
  final TextEditingController _controleurBudget = TextEditingController();
  
  // Variables d'état
  bool _estActive = true;
  bool _enChargement = false;
  bool _modeModification = false;
  
  // Catégories d'associations
  final List<Map<String, String>> _categories = const [
    {'valeur': 'academique', 'libelle': 'Académique'},
    {'valeur': 'culturelle', 'libelle': 'Culturelle'},
    {'valeur': 'sportive', 'libelle': 'Sportive'},
    {'valeur': 'sociale', 'libelle': 'Sociale'},
    {'valeur': 'technologie', 'libelle': 'Technologie'},
    {'valeur': 'environnement', 'libelle': 'Environnement'},
    {'valeur': 'autre', 'libelle': 'Autre'},
  ];
  String _categorieSelectionnee = 'academique';

  @override
  void initState() {
    super.initState();
    _associationsRepository = ServiceLocator.obtenirService<AssociationsRepository>();
    _modeModification = widget.associationAModifier != null;
    
    if (_modeModification) {
      _remplirFormulaire(widget.associationAModifier!);
    }
  }

  @override
  void dispose() {
    _controleurNom.dispose();
    _controleurDescription.dispose();
    _controleurEmail.dispose();
    _controleurTelephone.dispose();
    _controleurSiteWeb.dispose();
    _controleurBudget.dispose();
    super.dispose();
  }

  void _remplirFormulaire(Association association) {
    _controleurNom.text = association.nom;
    _controleurDescription.text = association.description;
    _controleurEmail.text = association.email ?? '';
    _controleurTelephone.text = association.telephone ?? '';
    _controleurSiteWeb.text = association.siteWeb ?? '';
    _controleurBudget.text = association.cotisationAnnuelle?.toString() ?? '';
    _estActive = association.estActive;
    
    // Vérifier si la catégorie existe
    final categorieExiste = _categories.any((cat) => cat['valeur'] == association.typeAssociation);
    _categorieSelectionnee = categorieExiste ? association.typeAssociation : 'academique';
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
      appBar: WidgetBarreAppNavigationAdmin(
        titre: _modeModification ? 'Modifier Association' : 'Ajouter Association',
        sousTitre: _modeModification 
          ? 'Modifier les informations de l\'association'
          : 'Créer une nouvelle association étudiante',
        sectionActive: 'associations',
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
                  _construireSectionContact(),
                  const SizedBox(height: 24),
                  _construireSectionParametres(),
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
              'Informations Générales',
              style: StylesTexteApp.grandTitre,
            ),
            const SizedBox(height: 16),
            
            // Nom de l'association
            TextFormField(
              controller: _controleurNom,
              decoration: InputDecoration(
                labelText: 'Nom de l\'association *',
                hintText: 'Ex: Association des étudiants en informatique',
                prefixIcon: const Icon(Icons.groups, color: CouleursApp.principal),
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
                  return 'Le nom est obligatoire';
                }
                if (valeur.trim().length < 3) {
                  return 'Le nom doit contenir au moins 3 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Catégorie
            DropdownButtonFormField<String>(
              value: _categorieSelectionnee,
              decoration: InputDecoration(
                labelText: 'Catégorie *',
                prefixIcon: const Icon(Icons.category, color: CouleursApp.principal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CouleursApp.principal, width: 2),
                ),
              ),
              items: _categories.map((categorie) => DropdownMenuItem(
                value: categorie['valeur'],
                child: Text(categorie['libelle']!),
              )).toList(),
              onChanged: (valeur) {
                setState(() {
                  _categorieSelectionnee = valeur!;
                });
              },
              validator: (valeur) {
                if (valeur == null || valeur.isEmpty) {
                  return 'Veuillez sélectionner une catégorie';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _controleurDescription,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description *',
                hintText: 'Décrivez les objectifs et activités de l\'association...',
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
          ],
        ),
      ),
    );
  }

  // UI Design: Section des informations de contact
  Widget _construireSectionContact() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations de Contact',
              style: StylesTexteApp.grandTitre,
            ),
            const SizedBox(height: 16),
            
            // Email
            TextFormField(
              controller: _controleurEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email *',
                hintText: 'contact@association.ca',
                prefixIcon: const Icon(Icons.email, color: CouleursApp.principal),
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
                  return 'L\'email est obligatoire';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(valeur)) {
                  return 'Format d\'email invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Téléphone
            TextFormField(
              controller: _controleurTelephone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Téléphone *',
                hintText: '(418) 555-0123',
                prefixIcon: const Icon(Icons.phone, color: CouleursApp.principal),
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
                  return 'Le téléphone est obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Site web (optionnel)
            TextFormField(
              controller: _controleurSiteWeb,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: 'Site Web (optionnel)',
                hintText: 'https://www.association.ca',
                prefixIcon: const Icon(Icons.web, color: CouleursApp.principal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CouleursApp.principal, width: 2),
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
            const Text(
              'Paramètres',
              style: StylesTexteApp.grandTitre,
            ),
            const SizedBox(height: 16),
            
            // Budget (optionnel)
            TextFormField(
              controller: _controleurBudget,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cotisation annuelle (optionnel)',
                hintText: 'Ex: 5000',
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
                                  if (valeur != null && valeur.isNotEmpty) {
                    final cotisation = double.tryParse(valeur);
                    if (cotisation == null || cotisation < 0) {
                      return 'La cotisation doit être un nombre positif';
                    }
                  }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Statut actif
            SwitchListTile(
              title: const Text(
                'Association active',
                style: StylesTexteApp.moyenTitre,
              ),
              subtitle: Text(
                _estActive 
                  ? 'L\'association est visible et peut organiser des événements'
                  : 'L\'association est désactivée et non visible',
                style: StylesTexteApp.corpsGris,
              ),
              value: _estActive,
              onChanged: (valeur) {
                setState(() {
                  _estActive = valeur;
                });
              },
              activeColor: CouleursApp.principal,
            ),
          ],
        ),
      ),
    );
  }

  // UI Design: Boutons d'action avec design UQAR
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
            onPressed: _enregistrerAssociation,
            style: ElevatedButton.styleFrom(
              backgroundColor: CouleursApp.principal,
              foregroundColor: CouleursApp.blanc,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              _modeModification ? 'Modifier' : 'Créer',
              style: StylesTexteApp.bouton,
            ),
          ),
        ),
      ],
    );
  }

  // Méthodes de gestion
  Future<void> _enregistrerAssociation() async {
    if (!_cleFormulaire.currentState!.validate()) {
      return;
    }

    setState(() => _enChargement = true);

    try {
      final association = Association(
        id: _modeModification ? widget.associationAModifier!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        nom: _controleurNom.text.trim(),
        description: _controleurDescription.text.trim(),
        typeAssociation: _categorieSelectionnee,
        email: _controleurEmail.text.trim().isEmpty ? null : _controleurEmail.text.trim(),
        telephone: _controleurTelephone.text.trim().isEmpty ? null : _controleurTelephone.text.trim(),
        siteWeb: _controleurSiteWeb.text.trim().isEmpty ? null : _controleurSiteWeb.text.trim(),
        cotisationAnnuelle: _controleurBudget.text.trim().isEmpty ? null : double.parse(_controleurBudget.text.trim()),
        activites: const ['Activités à définir'], // TODO: Permettre la saisie d'activités
        estActive: _estActive,
        dateCreation: _modeModification ? widget.associationAModifier!.dateCreation : DateTime.now(),
        nombreMembres: _modeModification ? widget.associationAModifier!.nombreMembres : 0,
      );

      // TODO: Implémenter les méthodes d'ajout et modification dans le repository
      if (_modeModification) {
        // await _associationsRepository.mettreAJourAssociation(association);
      } else {
        // await _associationsRepository.ajouterAssociation(association);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _modeModification 
                ? 'Association modifiée avec succès !'
                : 'Association créée avec succès !',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retourner true pour indiquer le succès
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