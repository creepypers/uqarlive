import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/horaires_datasource_local.dart';
import '../widgets/widget_barre_app_navigation_admin.dart';

class AdminModifierHorairesEcran extends StatefulWidget {
  const AdminModifierHorairesEcran({super.key});

  @override
  State<AdminModifierHorairesEcran> createState() => _AdminModifierHorairesEcranState();
}

class _AdminModifierHorairesEcranState extends State<AdminModifierHorairesEcran> {
  final _horairesDatasource = HorairesDatasourceLocal();
  String _jourSelectionne = 'Lundi';
  bool _isLoading = false;
  late Map<String, TimeOfDay> _horairesJourSelectionne;

  @override
  void initState() {
    super.initState();
    _horairesJourSelectionne = _horairesDatasource.obtenirHorairesCantine(_jourSelectionne);
  }

  Future<void> _sauvegarderHoraires() async {
    setState(() => _isLoading = true);

    try {
      await _horairesDatasource.mettreAJourHorairesCantine(
        _jourSelectionne,
        _horairesJourSelectionne['ouverture']!,
        _horairesJourSelectionne['fermeture']!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: CouleursApp.blanc),
                const SizedBox(width: 8),
                Text('Horaires mis à jour pour $_jourSelectionne'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: CouleursApp.blanc),
                SizedBox(width: 8),
                Text('Erreur lors de la mise à jour des horaires'),
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
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectionnerHeure(String type) async {
    final heureInitiale = _horairesJourSelectionne[type]!;
    
    final heureSelectionnee = await showTimePicker(
      context: context,
      initialTime: heureInitiale,
      helpText: type == 'ouverture' ? 'Heure d\'ouverture' : 'Heure de fermeture',
      cancelText: 'ANNULER',
      confirmText: 'OK',
      hourLabelText: 'Heure',
      minuteLabelText: 'Minute',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: CouleursApp.principal,
              onPrimary: CouleursApp.blanc,
              surface: CouleursApp.blanc,
              onSurface: CouleursApp.principal,
            ),
          ),
          child: child!,
        );
      },
    );

    if (heureSelectionnee != null) {
      setState(() {
        _horairesJourSelectionne = {
          ..._horairesJourSelectionne,
          type: heureSelectionnee,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: const WidgetBarreAppNavigationAdmin(
        titre: 'Modifier les Horaires',
        sousTitre: 'Gestion des horaires de la cantine',
        sectionActive: 'cantine',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _construireSectionInformation(),
                  const SizedBox(height: 24),
                  _construireSectionHoraires(),
                  const SizedBox(height: 32),
              _construireBoutonsSauvegarde(),
                ],
          ),
        ),
      ),
    );
  }

  Widget _construireSectionInformation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CouleursApp.principal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: CouleursApp.principal.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CouleursApp.principal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.access_time,
              color: CouleursApp.principal,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestion des Horaires',
                  style: StylesTexteApp.moyenTitre.copyWith(
                    color: CouleursApp.principal,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Modifiez les horaires d\'ouverture et de fermeture de la cantine',
                  style: StylesTexteApp.corpsGris,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireSectionHoraires() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sélectionner un jour',
            style: StylesTexteApp.petitTitre,
          ),
          const SizedBox(height: 16),
          
          // Sélecteur de jour
          DropdownButtonFormField<String>(
            value: _jourSelectionne,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calendar_today, color: CouleursApp.principal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: CouleursApp.principal.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: CouleursApp.principal.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: CouleursApp.principal, width: 2),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'Lundi', child: Text('Lundi')),
              DropdownMenuItem(value: 'Mardi', child: Text('Mardi')),
              DropdownMenuItem(value: 'Mercredi', child: Text('Mercredi')),
              DropdownMenuItem(value: 'Jeudi', child: Text('Jeudi')),
              DropdownMenuItem(value: 'Vendredi', child: Text('Vendredi')),
              DropdownMenuItem(value: 'Samedi', child: Text('Samedi')),
              DropdownMenuItem(value: 'Dimanche', child: Text('Dimanche')),
            ],
            onChanged: (jour) {
              if (jour != null) {
                setState(() {
                  _jourSelectionne = jour;
                  _horairesJourSelectionne = _horairesDatasource.obtenirHorairesCantine(jour);
                });
              }
            },
          ),
          const SizedBox(height: 24),
          
          // Horaires
          const Text(
            'Horaires',
            style: StylesTexteApp.petitTitre,
          ),
          const SizedBox(height: 16),
          
          // Heure d'ouverture
          ListTile(
            title: const Text('Heure d\'ouverture'),
            subtitle: Text(
              _formatterHeure(_horairesJourSelectionne['ouverture']!),
              style: const TextStyle(color: CouleursApp.principal, fontWeight: FontWeight.bold),
            ),
            leading: const Icon(Icons.wb_sunny, color: CouleursApp.principal),
            trailing: const Icon(Icons.edit, color: CouleursApp.principal),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: CouleursApp.principal.withOpacity(0.3)),
            ),
            onTap: () => _selectionnerHeure('ouverture'),
          ),
          const SizedBox(height: 12),
          
          // Heure de fermeture
          ListTile(
            title: const Text('Heure de fermeture'),
            subtitle: Text(
              _formatterHeure(_horairesJourSelectionne['fermeture']!),
              style: const TextStyle(color: CouleursApp.principal, fontWeight: FontWeight.bold),
            ),
            leading: const Icon(Icons.nights_stay, color: CouleursApp.principal),
            trailing: const Icon(Icons.edit, color: CouleursApp.principal),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: CouleursApp.principal.withOpacity(0.3)),
            ),
            onTap: () => _selectionnerHeure('fermeture'),
          ),
        ],
      ),
    );
  }

  Widget _construireBoutonsSauvegarde() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sauvegarderHoraires,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: CouleursApp.blanc,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: CouleursApp.blanc,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, size: 20),
                      SizedBox(width: 8),
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
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: CouleursApp.principal,
              side: const BorderSide(color: CouleursApp.principal, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel, size: 20),
                SizedBox(width: 8),
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

  String _formatterHeure(TimeOfDay heure) {
    final minute = heure.minute.toString().padLeft(2, '0');
    return '${heure.hour}h$minute';
  }
} 