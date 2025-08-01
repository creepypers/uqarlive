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
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: WidgetBarreAppPersonnalisee(
        titre: widget.utilisateur != null ? 'Modifier le profil' : 'Créer un utilisateur',
        sousTitre: widget.utilisateur != null ? 'Mise à jour des informations' : 'Création d\'un nouvel utilisateur',
        afficherProfil: false,
        widgetFin: IconButton(
          icon: Icon(Icons.arrow_back, color: CouleursApp.blanc),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section informations personnelles
                  _construireSectionInfosPersonnelles(),
                  const SizedBox(height: 24),
                  
                  // Section informations académiques
                  _construireSectionInfosAcademiques(),
                  const SizedBox(height: 32),
                  
                  // Boutons d'action
                  _construireBoutonsAction(),
                  const SizedBox(height: 20),
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
    return Container(
      padding: const EdgeInsets.all(20),
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
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Informations personnelles',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
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
              const SizedBox(width: 16),
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
          const SizedBox(height: 16),
          
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
          const SizedBox(height: 16),
          
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
    return Container(
      padding: const EdgeInsets.all(20),
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
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Informations académiques',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
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
          const SizedBox(height: 16),
          
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: CouleursApp.blanc,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Sauvegarder les modifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Bouton annuler
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: CouleursApp.principal,
              side: BorderSide(color: CouleursApp.principal),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Annuler',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icone, color: enabled ? CouleursApp.principal : Colors.grey),
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
          borderSide: BorderSide(color: CouleursApp.principal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        filled: true,
        fillColor: enabled ? CouleursApp.blanc : Colors.grey.withValues(alpha: 0.1),
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
          content: Text('Profil mis à jour avec succès !'),
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