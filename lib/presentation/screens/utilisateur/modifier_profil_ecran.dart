import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/utilisateur.dart';
import '../../../domain/repositories/utilisateurs_repository.dart';
import '../../../presentation/widgets/navbar_widget.dart';
import '../../../presentation/widgets/widget_barre_app_personnalisee.dart';
import '../../../presentation/services/navigation_service.dart';


// UI Design: Page de modification du profil utilisateur avec formulaires complets
class ModifierProfilEcran extends StatefulWidget {
  final Utilisateur? utilisateur;
  final bool modeAdmin; // UI Design: Mode admin permet de modifier le code permanent
  
  const ModifierProfilEcran({super.key, this.utilisateur, this.modeAdmin = false});

  @override
  State<ModifierProfilEcran> createState() => _ModifierProfilEcranState();
}

class _ModifierProfilEcranState extends State<ModifierProfilEcran> {
  final _formKey = GlobalKey<FormState>();
  late final UtilisateursRepository _utilisateursRepository;

  
  // Contrôleurs pour les champs de texte
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _codePermanentController = TextEditingController();
  final _programmeController = TextEditingController();
  final _motDePasseController = TextEditingController();
  final _confirmerMotDePasseController = TextEditingController();
  
  bool _isLoading = false;
  bool _afficherMotDePasse = false;
  bool _afficherConfirmationMotDePasse = false;
  TypeUtilisateur _typeUtilisateurSelectionne = TypeUtilisateur.etudiant;


  @override
  void initState() {
    super.initState();
    _initialiserRepositories();
    _chargerDonneesProfil();
  }

  void _initialiserRepositories() {
    _utilisateursRepository = ServiceLocator.obtenirService<UtilisateursRepository>();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _codePermanentController.dispose();
    _programmeController.dispose();
    _motDePasseController.dispose();
    _confirmerMotDePasseController.dispose();
    super.dispose();
  }

  void _chargerDonneesProfil() {
    // UI Design: Charger les données selon le mode (création ou modification)
    if (widget.utilisateur != null) {
      // Mode modification : charger les données de l'utilisateur sélectionné
      final user = widget.utilisateur!;
      _nomController.text = user.nom;
      _prenomController.text = user.prenom;
      _emailController.text = user.email;
      _telephoneController.text = user.telephone;
      _codePermanentController.text = user.codeEtudiant;
      _programmeController.text = user.programme;
      _typeUtilisateurSelectionne = user.typeUtilisateur;
      // UI Design: Les privilèges sont déterminés automatiquement par le type
    } else {
      // Mode création : champs vides pour nouvel utilisateur
      _nomController.clear();
      _prenomController.clear();
      _emailController.clear();
      _telephoneController.clear();
      _codePermanentController.clear();
      _programmeController.clear();
      _motDePasseController.clear();
      _confirmerMotDePasseController.clear();
      _typeUtilisateurSelectionne = TypeUtilisateur.etudiant;
      // UI Design: Pas de privilèges spécifiques pour les nouveaux utilisateurs
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
        titre: widget.utilisateur != null ? 'Modifier le profil' : 'Créer un utilisateur',
        sousTitre: widget.utilisateur != null ? 'Mise à jour des informations' : 'Création d\'un nouvel utilisateur',
        afficherProfil: false,
        widgetFin: IconButton(
          icon: Icon(Icons.arrow_back, color: CouleursApp.blanc, size: screenWidth * 0.06), // UI Design: Taille adaptative
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: viewInsets.bottom + padding.bottom + screenHeight * 0.025, // UI Design: Padding adaptatif pour éviter les débordements
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04), // UI Design: Padding adaptatif
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section informations personnelles
                  _construireSectionInfosPersonnelles(),
                  SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
                  
                  // Section informations académiques
                  _construireSectionInfosAcademiques(),
                  SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
                  
                  // Section sécurité (mot de passe) - seulement en mode création ou admin
                  if (widget.utilisateur == null || widget.modeAdmin) ...[
                    _construireSectionSecurite(),
                    SizedBox(height: screenHeight * 0.03), // UI Design: Espacement adaptatif
                  ],
                  
                  // Section administration - seulement en mode admin
                  if (widget.modeAdmin) ...[
                    _construireSectionAdministration(),
                    SizedBox(height: screenHeight * 0.04), // UI Design: Espacement adaptatif
                  ] else
                    SizedBox(height: screenHeight * 0.01),
                  
                  // Boutons d'action
                  _construireBoutonsAction(),
                  SizedBox(height: screenHeight * 0.025), // UI Design: Espacement adaptatif
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavBarWidget(
        indexSelectionne: 4, // Profil
        onTap: (index) => NavigationService.gererNavigationNavBar(context, index),
      ),
    );
  }

  // UI Design: Section informations personnelles
  Widget _construireSectionInfosPersonnelles() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
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
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: CouleursApp.principal,
                size: screenWidth * 0.06, // UI Design: Taille adaptative
              ),
              SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Text(
                'Informations personnelles',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                ),
                overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.025), // UI Design: Espacement adaptatif
          
          // Nom et Prénom
          Row(
            children: [
              Expanded(
                child: _construireChampTexte(
                  controller: _nomController,
                  label: 'Nom',
                  icone: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le nom est requis';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: screenWidth * 0.04), // UI Design: Espacement adaptatif
              Expanded(
                child: _construireChampTexte(
                  controller: _prenomController,
                  label: 'Prénom',
                  icone: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le prénom est requis';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
          
          // Email
          _construireChampTexte(
            controller: _emailController,
            label: 'Adresse e-mail',
            icone: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'L\'e-mail est requis';
              }
              if (!value.contains('@uqar.ca')) {
                return 'Utilisez votre adresse UQAR (@uqar.ca)';
              }
              return null;
            },
          ),
          SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
          
          // Téléphone
          _construireChampTexte(
            controller: _telephoneController,
            label: 'Numéro de téléphone',
            icone: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!RegExp(r'^\d{3}-\d{3}-\d{4}$').hasMatch(value)) {
                  return 'Format: 418-555-0123';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // UI Design: Section informations académiques
  Widget _construireSectionInfosAcademiques() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
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
          Row(
            children: [
              Icon(
                Icons.school,
                color: CouleursApp.accent,
                size: screenWidth * 0.06, // UI Design: Taille adaptative
              ),
              SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Text(
                'Informations académiques',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                ),
                overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.025), // UI Design: Espacement adaptatif
          
          // Code permanent - modifiable par les admins
          _construireChampTexte(
            controller: _codePermanentController,
            label: 'Code permanent',
            icone: Icons.badge,
            enabled: widget.modeAdmin || widget.utilisateur == null, // UI Design: Modifiable par les admins
            helperText: widget.modeAdmin ? 'Modifiable par les administrateurs' : null,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le code permanent est requis';
              }
              if (value.length < 4) {
                return 'Le code permanent doit contenir au moins 4 caractères';
              }
              return null;
            },
          ),
          SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
          
          // Programme d'études
          _construireChampTexte(
            controller: _programmeController,
            label: 'Programme d\'études',
            icone: Icons.book,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le programme est requis';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // UI Design: Boutons d'action
  Widget _construireBoutonsAction() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Column(
      children: [
        // Bouton sauvegarder
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sauvegarderProfil,
            style: ElevatedButton.styleFrom(
              backgroundColor: CouleursApp.principal,
              foregroundColor: CouleursApp.blanc,
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02), // UI Design: Padding adaptatif
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
            child: _isLoading
                ? SizedBox(
                    height: screenWidth * 0.05, // UI Design: Taille adaptative
                    width: screenWidth * 0.05, // UI Design: Taille adaptative
                    child: const CircularProgressIndicator(
                      color: CouleursApp.blanc,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, size: screenWidth * 0.05), // UI Design: Taille adaptative
                      SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
                      Text(
                        'Sauvegarder les modifications',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04, // UI Design: Taille adaptative
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                        maxLines: 1,
                      ),
                    ],
                  ),
          ),
        ),
        SizedBox(height: screenHeight * 0.015), // UI Design: Espacement adaptatif
        
        // Bouton annuler
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: CouleursApp.principal,
              side: const BorderSide(color: CouleursApp.principal),
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02), // UI Design: Padding adaptatif
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel, size: screenWidth * 0.05), // UI Design: Taille adaptative
                SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
                Text(
                  'Annuler',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04, // UI Design: Taille adaptative
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // UI Design: Section sécurité (mot de passe)
  Widget _construireSectionSecurite() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: Colors.orange,
                size: screenWidth * 0.06, // UI Design: Taille adaptative
              ),
              SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Text(
                'Sécurité',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                ),
                overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.025), // UI Design: Espacement adaptatif
          
          // Mot de passe
          _construireChampTexte(
            controller: _motDePasseController,
            label: widget.utilisateur == null ? 'Mot de passe' : 'Nouveau mot de passe',
            icone: Icons.lock,
            obscureText: !_afficherMotDePasse,
            suffixIcon: IconButton(
              icon: Icon(
                _afficherMotDePasse ? Icons.visibility_off : Icons.visibility,
                color: CouleursApp.principal,
              ),
              onPressed: () => setState(() => _afficherMotDePasse = !_afficherMotDePasse),
            ),
            validator: (value) {
              if (widget.utilisateur == null && (value == null || value.isEmpty)) {
                return 'Le mot de passe est requis pour un nouveau compte';
              }
              if (value != null && value.isNotEmpty && value.length < 6) {
                return 'Le mot de passe doit contenir au moins 6 caractères';
              }
              return null;
            },
          ),
          SizedBox(height: screenHeight * 0.02), // UI Design: Espacement adaptatif
          
          // Confirmation mot de passe
          _construireChampTexte(
            controller: _confirmerMotDePasseController,
            label: 'Confirmer le mot de passe',
            icone: Icons.lock_outline,
            obscureText: !_afficherConfirmationMotDePasse,
            suffixIcon: IconButton(
              icon: Icon(
                _afficherConfirmationMotDePasse ? Icons.visibility_off : Icons.visibility,
                color: CouleursApp.principal,
              ),
              onPressed: () => setState(() => _afficherConfirmationMotDePasse = !_afficherConfirmationMotDePasse),
            ),
            validator: (value) {
              if (_motDePasseController.text.isNotEmpty) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez confirmer le mot de passe';
                }
                if (value != _motDePasseController.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // UI Design: Section administration (privilèges et type)
  Widget _construireSectionAdministration() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05), // UI Design: Padding adaptatif
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                color: Colors.red,
                size: screenWidth * 0.06, // UI Design: Taille adaptative
              ),
              SizedBox(width: screenWidth * 0.02), // UI Design: Espacement adaptatif
              Text(
                'Administration',
                style: StylesTexteApp.titre.copyWith(
                  fontSize: screenWidth * 0.045, // UI Design: Taille adaptative
                ),
                overflow: TextOverflow.ellipsis, // UI Design: Éviter le débordement de texte
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.025), // UI Design: Espacement adaptatif
          
          // Type d'utilisateur
          Text(
            'Type d\'utilisateur',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w600,
              color: CouleursApp.texteFonce,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
            decoration: BoxDecoration(
              border: Border.all(color: CouleursApp.principal.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TypeUtilisateur>(
                value: _typeUtilisateurSelectionne,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: CouleursApp.principal),
                style: TextStyle(fontSize: screenWidth * 0.04, color: CouleursApp.texteFonce),
                items: TypeUtilisateur.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(
                          type == TypeUtilisateur.administrateur ? Icons.admin_panel_settings : Icons.school,
                          color: type == TypeUtilisateur.administrateur ? Colors.red : CouleursApp.principal,
                          size: screenWidth * 0.05,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(type == TypeUtilisateur.administrateur ? 'Administrateur' : 'Étudiant'),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (TypeUtilisateur? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _typeUtilisateurSelectionne = newValue;
                      // UI Design: Promotion simple admin/étudiant
                    });
                  }
                },
              ),
            ),
          ),

        ],
      ),
    );
  }



  // Helper: Construire un champ de texte
  Widget _construireChampTexte({
    required TextEditingController controller,
    required String label,
    required IconData icone,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
    String? helperText,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
      obscureText: obscureText,
      style: TextStyle(fontSize: screenWidth * 0.04), // UI Design: Taille adaptative
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: screenWidth * 0.04), // UI Design: Taille adaptative
        helperText: helperText,
        helperStyle: TextStyle(fontSize: screenWidth * 0.032, color: CouleursApp.accent),
        prefixIcon: Icon(icone, color: enabled ? CouleursApp.principal : Colors.grey, size: screenWidth * 0.05), // UI Design: Taille adaptative
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: CouleursApp.principal.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: CouleursApp.principal.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CouleursApp.principal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        filled: true,
        fillColor: enabled ? CouleursApp.blanc : Colors.grey.withValues(alpha: 0.1),
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, // UI Design: Padding adaptatif
          vertical: screenWidth * 0.03, // UI Design: Padding adaptatif
        ),
      ),
    );
  }

  // Actions

  void _sauvegarderProfil() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (widget.utilisateur == null) {
          // UI Design: Création d'un nouvel utilisateur
          await _creerNouvelUtilisateur();
        } else {
          // UI Design: Modification d'un utilisateur existant
          await _modifierUtilisateurExistant();
        }

        setState(() {
          _isLoading = false;
        });

        // Afficher confirmation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.utilisateur == null 
                        ? 'Utilisateur créé avec succès !' 
                        : 'Profil mis à jour avec succès !',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );

          // Retourner à l'écran précédent avec succès
          Navigator.pop(context, true);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        // Afficher erreur
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Erreur lors de la sauvegarde: $e'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  Future<void> _creerNouvelUtilisateur() async {
    // UI Design: Créer un nouvel utilisateur avec toutes les informations
    final nouvelUtilisateur = Utilisateur(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      email: _emailController.text.trim(),
      telephone: _telephoneController.text.trim(),
      codeEtudiant: _codePermanentController.text.trim(),
      programme: _programmeController.text.trim(),
      niveauEtude: 'Baccalauréat', // UI Design: Valeur par défaut pour nouveau utilisateur
      typeUtilisateur: _typeUtilisateurSelectionne,
      privileges: _typeUtilisateurSelectionne == TypeUtilisateur.administrateur ? ['admin'] : [],
      estActif: true,
      dateInscription: DateTime.now(),
    );

    final succes = await _utilisateursRepository.creerUtilisateur(nouvelUtilisateur, _motDePasseController.text.isNotEmpty ? _motDePasseController.text : 'motdepasse123');
    if (!succes) {
      throw Exception('Impossible de créer l\'utilisateur');
    }

    // UI Design: Le compte d'authentification sera créé automatiquement par le système
  }

  Future<void> _modifierUtilisateurExistant() async {
    // UI Design: Modifier l'utilisateur existant
    final utilisateurModifie = widget.utilisateur!.copyWith(
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      email: _emailController.text.trim(),
      telephone: _telephoneController.text.trim(),
      codeEtudiant: _codePermanentController.text.trim(),
      programme: _programmeController.text.trim(),
      typeUtilisateur: widget.modeAdmin ? _typeUtilisateurSelectionne : widget.utilisateur!.typeUtilisateur,
      privileges: widget.modeAdmin ? (_typeUtilisateurSelectionne == TypeUtilisateur.administrateur ? ['admin'] : []) : widget.utilisateur!.privileges,
    );

    final succes = await _utilisateursRepository.modifierUtilisateur(utilisateurModifie);
    if (!succes) {
      throw Exception('Impossible de modifier l\'utilisateur');
    }

    // UI Design: La modification du mot de passe sera gérée par le système d'authentification
  }
} 