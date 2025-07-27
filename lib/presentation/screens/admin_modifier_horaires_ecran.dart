import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/widget_barre_app_navigation_admin.dart';

// UI Design: Écran de modification des horaires d'ouverture de la cantine
class AdminModifierHorairesEcran extends StatefulWidget {
  const AdminModifierHorairesEcran({super.key});

  @override
  State<AdminModifierHorairesEcran> createState() => _AdminModifierHorairesEcranState();
}

class _AdminModifierHorairesEcranState extends State<AdminModifierHorairesEcran> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Horaires par défaut
  Map<String, Map<String, dynamic>> _horaires = {
    'lundi': {
      'ouvert': true,
      'debut': '08:00',
      'fin': '18:00',
    },
    'mardi': {
      'ouvert': true,
      'debut': '08:00',
      'fin': '18:00',
    },
    'mercredi': {
      'ouvert': true,
      'debut': '08:00',
      'fin': '18:00',
    },
    'jeudi': {
      'ouvert': true,
      'debut': '08:00',
      'fin': '18:00',
    },
    'vendredi': {
      'ouvert': true,
      'debut': '08:00',
      'fin': '18:00',
    },
    'samedi': {
      'ouvert': false,
      'debut': '10:00',
      'fin': '16:00',
    },
    'dimanche': {
      'ouvert': false,
      'debut': '10:00',
      'fin': '16:00',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: WidgetBarreAppNavigationAdmin(
        titre: 'Modifier les Horaires',
        sousTitre: 'Horaires d\'ouverture de la cantine',
        sectionActive: 'cantine',
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
                  // Section d'information
                  _construireSectionInformation(),
                  const SizedBox(height: 24),
                  
                  // Horaires par jour
                  _construireSectionHoraires(),
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
    );
  }

  // UI Design: Section d'information
  Widget _construireSectionInformation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.schedule,
              color: Colors.blue,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Horaires d\'ouverture',
                  style: StylesTexteApp.moyenTitre.copyWith(color: Colors.blue),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configurez les horaires d\'ouverture de la cantine pour chaque jour de la semaine',
                  style: StylesTexteApp.corpsGris,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Section des horaires
  Widget _construireSectionHoraires() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horaires par jour',
          style: StylesTexteApp.grandTitre,
        ),
        const SizedBox(height: 16),
        
        ..._horaires.entries.map((entry) => _construireJourHoraires(entry.key, entry.value)),
      ],
    );
  }

  // UI Design: Horaires pour un jour
  Widget _construireJourHoraires(String jour, Map<String, dynamic> horaires) {
    final nomJour = _obtenirNomJour(jour);
    final estOuvert = horaires['ouvert'] as bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(24),
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
          // En-tête du jour
          Row(
            children: [
              Icon(
                _obtenirIconeJour(jour),
                color: CouleursApp.principal,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                nomJour,
                style: StylesTexteApp.moyenTitre,
              ),
              const Spacer(),
              Switch(
                value: estOuvert,
                onChanged: (valeur) {
                  setState(() {
                    _horaires[jour]!['ouvert'] = valeur;
                  });
                },
                activeColor: CouleursApp.principal,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Horaires
          if (estOuvert) ...[
            Row(
              children: [
                Expanded(
                  child: _construireChampHeure(
                    label: 'Ouverture',
                    valeur: horaires['debut'] as String,
                    onChanged: (valeur) {
                      setState(() {
                        _horaires[jour]!['debut'] = valeur;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _construireChampHeure(
                    label: 'Fermeture',
                    valeur: horaires['fin'] as String,
                    onChanged: (valeur) {
                      setState(() {
                        _horaires[jour]!['fin'] = valeur;
                      });
                    },
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.block, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Fermé ce jour',
                    style: StylesTexteApp.corpsGris,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // UI Design: Champ de sélection d'heure
  Widget _construireChampHeure({
    required String label,
    required String valeur,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: StylesTexteApp.petitTitre,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: CouleursApp.principal.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(16),
            color: CouleursApp.blanc,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: valeur,
              isExpanded: true,
              items: _genererOptionsHeures().map((heure) => DropdownMenuItem(
                value: heure,
                child: Text(heure),
              )).toList(),
              onChanged: (valeur) {
                if (valeur != null) {
                  onChanged(valeur);
                }
              },
            ),
          ),
        ),
      ],
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
            onPressed: _isLoading ? null : _sauvegarderHoraires,
            style: ElevatedButton.styleFrom(
              backgroundColor: CouleursApp.principal,
              foregroundColor: CouleursApp.blanc,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
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
                        'Sauvegarder les horaires',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Bouton réinitialiser
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isLoading ? null : _reinitialiserHoraires,
            style: OutlinedButton.styleFrom(
              foregroundColor: CouleursApp.principal,
              side: BorderSide(color: CouleursApp.principal, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Réinitialiser',
                  style: const TextStyle(
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

  // Helpers
  String _obtenirNomJour(String jour) {
    switch (jour) {
      case 'lundi': return 'Lundi';
      case 'mardi': return 'Mardi';
      case 'mercredi': return 'Mercredi';
      case 'jeudi': return 'Jeudi';
      case 'vendredi': return 'Vendredi';
      case 'samedi': return 'Samedi';
      case 'dimanche': return 'Dimanche';
      default: return jour;
    }
  }

  IconData _obtenirIconeJour(String jour) {
    switch (jour) {
      case 'lundi': return Icons.calendar_today;
      case 'mardi': return Icons.calendar_today;
      case 'mercredi': return Icons.calendar_today;
      case 'jeudi': return Icons.calendar_today;
      case 'vendredi': return Icons.calendar_today;
      case 'samedi': return Icons.weekend;
      case 'dimanche': return Icons.weekend;
      default: return Icons.calendar_today;
    }
  }

  List<String> _genererOptionsHeures() {
    List<String> heures = [];
    for (int heure = 0; heure < 24; heure++) {
      for (int minute = 0; minute < 60; minute += 30) {
        heures.add('${heure.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
      }
    }
    return heures;
  }

  // Actions
  void _sauvegarderHoraires() async {
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
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Horaires sauvegardés avec succès !'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

    // Retourner à l'écran précédent
    Navigator.pop(context);
  }

  void _reinitialiserHoraires() {
    setState(() {
      _horaires = {
        'lundi': {'ouvert': true, 'debut': '08:00', 'fin': '18:00'},
        'mardi': {'ouvert': true, 'debut': '08:00', 'fin': '18:00'},
        'mercredi': {'ouvert': true, 'debut': '08:00', 'fin': '18:00'},
        'jeudi': {'ouvert': true, 'debut': '08:00', 'fin': '18:00'},
        'vendredi': {'ouvert': true, 'debut': '08:00', 'fin': '18:00'},
        'samedi': {'ouvert': false, 'debut': '10:00', 'fin': '16:00'},
        'dimanche': {'ouvert': false, 'debut': '10:00', 'fin': '16:00'},
      };
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Horaires réinitialisés'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
} 