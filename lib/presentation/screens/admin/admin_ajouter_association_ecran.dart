
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/utils/association_types.dart';
import '../../../core/utils/utilisateurs_utils.dart';
import '../../../domain/entities/association.dart';
import '../../../domain/entities/utilisateur.dart';
import '../../../domain/usercases/associations_repository.dart';
import '../../../presentation/widgets/widget_barre_app_navigation_admin.dart';

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
  
  final TextEditingController _controleurLocalisation = TextEditingController();
  final TextEditingController _controleurHoraires = TextEditingController();
  
  // Variables d'état
  bool _estActive = true;
  bool _enChargement = false;
  bool _chargementUtilisateurs = false;
  bool _modeModification = false;
  final List<String> _activites = ['Activités à définir']; 
  
  // Liste des utilisateurs disponibles pour être chef d'association
  List<Utilisateur> _utilisateursDisponibles = [];
  String _chefSelectionne = 'etud_001'; // Alexandre Martin par défaut
  
  // Catégories d'associations
  String _categorieSelectionnee = 'academique';

  @override
  void initState() {
    super.initState();
    _associationsRepository = ServiceLocator.obtenirService<AssociationsRepository>();
    _modeModification = widget.associationAModifier != null;
    
    if (_modeModification) {
      _remplirFormulaire(widget.associationAModifier!);
    }
    
    // Charger les utilisateurs disponibles
    _chargerUtilisateurs();
  }

  @override
  void dispose() {
    _controleurNom.dispose();
    _controleurDescription.dispose();
    _controleurEmail.dispose();
    _controleurTelephone.dispose();
    _controleurSiteWeb.dispose();
    _controleurBudget.dispose();

    _controleurLocalisation.dispose();
    _controleurHoraires.dispose();
    super.dispose();
  }

  Future<void> _chargerUtilisateurs() async {
    setState(() {
      _chargementUtilisateurs = true;
    });
    
    try {
      final etudiantsActifs = await UtilisateursUtils.obtenirEtudiantsActifs();
      
      setState(() {
        _utilisateursDisponibles = etudiantsActifs;
        _chargementUtilisateurs = false;
        // Si aucun utilisateur n'est chargé, utiliser le premier disponible
        if (_utilisateursDisponibles.isNotEmpty && _chefSelectionne.isEmpty) {
          _chefSelectionne = _utilisateursDisponibles.first.id;
        }
      });
    } catch (e) {
      // En cas d'erreur, garder la liste vide
      setState(() {
        _utilisateursDisponibles = [];
        _chargementUtilisateurs = false;
      });
    }
  }

  void _remplirFormulaire(Association association) {
    _controleurNom.text = association.nom;
    _controleurDescription.text = association.description;
    _controleurEmail.text = association.email ?? '';
    _controleurTelephone.text = association.telephone ?? '';
    _controleurSiteWeb.text = association.siteWeb ?? '';
    _controleurBudget.text = association.cotisationAnnuelle?.toString() ?? '';
    _chefSelectionne = association.chefId ?? 'etud_001';
    _controleurLocalisation.text = association.localisation ?? '';
    _controleurHoraires.text = association.horairesBureau ?? '';
    _estActive = association.estActive;
    
    // Vérifier si la catégorie existe
    final categorieExiste = AssociationTypes.typesCreation.contains(association.typeAssociation);
    _categorieSelectionnee = categorieExiste ? association.typeAssociation : 'academique';
  }

  @override
  Widget build(BuildContext context) {
    
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;
    
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      resizeToAvoidBottomInset: true, 
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
                left: screenWidth * 0.04, 
                right: screenWidth * 0.04,
                top: screenHeight * 0.02,
                bottom: viewInsets.bottom + padding.bottom + screenHeight * 0.025, 
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
              items: AssociationTypes.typesCreation.map((categorie) => DropdownMenuItem(
                value: categorie,
                child: Text(AssociationTypes.obtenirNomType(categorie)),
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
            
                        // Chef de l'association
            DropdownButtonFormField<String>(
              value: _chefSelectionne,
              isExpanded: true, 
              decoration: InputDecoration(
                labelText: 'Chef de l\'association *',
                prefixIcon: const Icon(Icons.person, color: CouleursApp.principal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CouleursApp.principal, width: 2),
                ),
              ),
              items: _chargementUtilisateurs 
                ? [const DropdownMenuItem(
                    value: null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Chargement...'),
                      ],
                    ),
                  )]
                : _utilisateursDisponibles.isEmpty
                  ? [const DropdownMenuItem(
                      value: null,
                      child: Text('Aucun utilisateur disponible'),
                    )]
                  : _utilisateursDisponibles.map((utilisateur) => DropdownMenuItem(
                      value: utilisateur.id,
                      child: Text('${utilisateur.prenom} ${utilisateur.nom}'),
                    )).toList(),
              onChanged: _chargementUtilisateurs ? null : (valeur) {
                setState(() {
                  _chefSelectionne = valeur!;
                });
              },
              validator: (valeur) {
                if (valeur == null || valeur.isEmpty) {
                  return 'Veuillez sélectionner un chef d\'association';
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
            
            // Localisation
            TextFormField(
              controller: _controleurLocalisation,
              decoration: InputDecoration(
                labelText: 'Localisation',
                hintText: 'Ex: Local J-215, Pavillon des Sciences',
                prefixIcon: const Icon(Icons.location_on, color: CouleursApp.principal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CouleursApp.principal, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Horaires de bureau
            TextFormField(
              controller: _controleurHoraires,
              decoration: InputDecoration(
                labelText: 'Horaires de bureau',
                hintText: 'Ex: Lun-Ven: 9h-16h, Mar-Jeu: 14h-18h',
                prefixIcon: const Icon(Icons.schedule, color: CouleursApp.principal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CouleursApp.principal, width: 2),
                ),
              ),
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
            const SizedBox(height: 24),
            
            // Section Activités
            const Text(
              'Activités de l\'association',
              style: StylesTexteApp.grandTitre,
            ),
            const SizedBox(height: 8),
            const Text(
              'Listez les principales activités que votre association organise',
              style: StylesTexteApp.corpsGris,
            ),
            const SizedBox(height: 16),
            
            // Liste des activités
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: CouleursApp.principal.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CouleursApp.principal.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.list, color: CouleursApp.principal),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Activités',
                            style: StylesTexteApp.moyenTitre,
                          ),
                        ),
                        IconButton(
                          onPressed: _ajouterActivite,
                          icon: const Icon(Icons.add, color: CouleursApp.principal),
                          tooltip: 'Ajouter une activité',
                        ),
                      ],
                    ),
                  ),
                  if (_activites.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Aucune activité ajoutée',
                        style: StylesTexteApp.corpsGris,
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _activites.length,
                      separatorBuilder: (context, index) => Divider(
                        color: CouleursApp.principal.withValues(alpha: 0.2),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final activite = _activites[index];
                        return ListTile(
                          leading: const Icon(Icons.play_arrow, color: CouleursApp.accent),
                          title: Text(
                            activite,
                            style: StylesTexteApp.corpsNormal,
                          ),
                          trailing: IconButton(
                            onPressed: () => _supprimerActivite(index),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Supprimer cette activité',
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
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
        chefId: _chefSelectionne, 
        email: _controleurEmail.text.trim().isEmpty ? null : _controleurEmail.text.trim(),
        telephone: _controleurTelephone.text.trim().isEmpty ? null : _controleurTelephone.text.trim(),
        siteWeb: _controleurSiteWeb.text.trim().isEmpty ? null : _controleurSiteWeb.text.trim(),
        localisation: _controleurLocalisation.text.trim().isEmpty ? null : _controleurLocalisation.text.trim(),
        horairesBureau: _controleurHoraires.text.trim().isEmpty ? null : _controleurHoraires.text.trim(),
        cotisationAnnuelle: _controleurBudget.text.trim().isEmpty ? null : double.parse(_controleurBudget.text.trim()),
        activites: _activites, 
        estActive: _estActive,
        dateCreation: _modeModification ? widget.associationAModifier!.dateCreation : DateTime.now(),
        membresActifs: _modeModification ? widget.associationAModifier!.membresActifs : [],
      );

      
      bool succes = false;
      if (_modeModification) {
        succes = await _associationsRepository.mettreAJourAssociation(association);
      } else {
        succes = await _associationsRepository.ajouterAssociation(association);
      }

      if (!succes) {
        throw Exception('Échec de l\'opération');
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

  
  void _ajouterActivite() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controleurActivite = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Nouvelle Activité'),
          content: TextField(
            controller: controleurActivite,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nom de l\'activité',
              hintText: 'Ex: Conférences tech, Ateliers de programmation...',
              border: OutlineInputBorder(),
            ),
            maxLines: 1,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final activite = controleurActivite.text.trim();
                if (activite.isNotEmpty && !_activites.contains(activite)) {
                  setState(() {
                    _activites.add(activite);
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Activité "$activite" ajoutée'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (_activites.contains(activite)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cette activité existe déjà'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: CouleursApp.principal),
              child: const Text('Ajouter', style: TextStyle(color: CouleursApp.blanc)),
            ),
          ],
        );
      },
    );
  }

  
  void _supprimerActivite(int index) {
    if (index >= 0 && index < _activites.length) {
      final activite = _activites[index];
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Supprimer l\'activité'),
          content: Text('Voulez-vous vraiment supprimer "$activite" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _activites.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Activité "$activite" supprimée'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }
} 
