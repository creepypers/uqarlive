import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/utilisateur.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import '../services/navigation_service.dart';

// UI Design: Page de modification du profil utilisateur avec formulaires complets
class ModifierProfilEcran extends StatefulWidget {
  final Utilisateur? utilisateur;
  
  const ModifierProfilEcran({super.key, this.utilisateur});

  @override
  State<ModifierProfilEcran> createState() => _ModifierProfilEcranState();
}

class _ModifierProfilEcranState extends State<ModifierProfilEcran> {
  final _formKey = GlobalKey<FormState>();
  
  // Contrôleurs pour les champs de texte
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _codePermanentController = TextEditingController();
  final _programmeController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chargerDonneesProfil();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _codePermanentController.dispose();
    _programmeController.dispose();
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
    } else {
      // Mode création : champs vides pour nouvel utilisateur
      _nomController.clear();
      _prenomController.clear();
      _emailController.clear();
      _telephoneController.clear();
      _codePermanentController.clear();
      _programmeController.clear();
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
                  SizedBox(height: screenHeight * 0.04), // UI Design: Espacement adaptatif
                  
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
          
          // Code permanent
          _construireChampTexte(
            controller: _codePermanentController,
            label: 'Code permanent',
            icone: Icons.badge,
            enabled: false, // Non modifiable
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le code permanent est requis';
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

  // Helper: Construire un champ de texte
  Widget _construireChampTexte({
    required TextEditingController controller,
    required String label,
    required IconData icone,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
      style: TextStyle(fontSize: screenWidth * 0.04), // UI Design: Taille adaptative
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: screenWidth * 0.04), // UI Design: Taille adaptative
        prefixIcon: Icon(icone, color: enabled ? CouleursApp.principal : Colors.grey, size: screenWidth * 0.05), // UI Design: Taille adaptative
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

      // Simuler la sauvegarde
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // Afficher confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil mis à jour avec succès !'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Retourner à l'écran profil
      Navigator.pop(context);
    }
  }
} 