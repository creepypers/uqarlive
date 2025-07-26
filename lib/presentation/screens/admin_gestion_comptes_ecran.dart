// UI Design: Écran de gestion des comptes utilisateurs pour les administrateurs
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/utilisateur.dart';
import '../../domain/repositories/utilisateurs_repository.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import '../widgets/widget_collection.dart';

class AdminGestionComptesEcran extends StatefulWidget {
  const AdminGestionComptesEcran({super.key});

  @override
  State<AdminGestionComptesEcran> createState() => _AdminGestionComptesEcranState();
}

class _AdminGestionComptesEcranState extends State<AdminGestionComptesEcran> {
  late UtilisateursRepository _utilisateursRepository;
  List<Utilisateur> _utilisateurs = [];
  List<Utilisateur> _utilisateursFiltres = [];
  bool _chargementEnCours = true;
  String _filtreRecherche = '';
  String _filtreStatut = 'tous'; // tous, actifs, inactifs

  final TextEditingController _controleurRecherche = TextEditingController();

  @override
  void initState() {
    super.initState();
    _utilisateursRepository = ServiceLocator.obtenirService<UtilisateursRepository>();
    _chargerUtilisateurs();
  }

  Future<void> _chargerUtilisateurs() async {
    try {
      setState(() => _chargementEnCours = true);
      
      final utilisateurs = await _utilisateursRepository.obtenirTousLesUtilisateurs();
      
      setState(() {
        _utilisateurs = utilisateurs;
        _appliquerFiltres();
        _chargementEnCours = false;
      });
    } catch (e) {
      setState(() => _chargementEnCours = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _appliquerFiltres() {
    _utilisateursFiltres = _utilisateurs.where((utilisateur) {
      // Filtre par recherche
      final rechercheOk = _filtreRecherche.isEmpty ||
          utilisateur.nom.toLowerCase().contains(_filtreRecherche.toLowerCase()) ||
          utilisateur.prenom.toLowerCase().contains(_filtreRecherche.toLowerCase()) ||
          utilisateur.email.toLowerCase().contains(_filtreRecherche.toLowerCase()) ||
          utilisateur.codeEtudiant.toLowerCase().contains(_filtreRecherche.toLowerCase());

      // Filtre par statut
      final statutOk = _filtreStatut == 'tous' ||
          (_filtreStatut == 'actifs' && utilisateur.estActif) ||
          (_filtreStatut == 'inactifs' && !utilisateur.estActif);

      return rechercheOk && statutOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: WidgetBarreAppPersonnalisee(
        titre: 'Gestion des Comptes',
        sousTitre: '${_utilisateursFiltres.length} utilisateur(s)',
        afficherBoutonRetour: true,
      ),
      body: Column(
        children: [
          _construireBarreRecherche(),
          _construireFiltres(),
          Expanded(
            child: _chargementEnCours
                ? const Center(child: CircularProgressIndicator())
                : _construireListeUtilisateurs(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _afficherModalNouvelUtilisateur,
        backgroundColor: CouleursApp.principal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _construireBarreRecherche() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controleurRecherche,
        decoration: InputDecoration(
          hintText: 'Rechercher par nom, email ou code étudiant...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _filtreRecherche.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controleurRecherche.clear();
                    setState(() {
                      _filtreRecherche = '';
                      _appliquerFiltres();
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: CouleursApp.principal.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: CouleursApp.principal, width: 2),
          ),
        ),
        onChanged: (valeur) {
          setState(() {
            _filtreRecherche = valeur;
            _appliquerFiltres();
          });
        },
      ),
    );
  }

  Widget _construireFiltres() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Statut:',
            style: StylesTexteApp.moyenTitre,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                _construireFiltreStatut('tous', 'Tous'),
                const SizedBox(width: 8),
                _construireFiltreStatut('actifs', 'Actifs'),
                const SizedBox(width: 8),
                _construireFiltreStatut('inactifs', 'Suspendus'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireFiltreStatut(String valeur, String libelle) {
    final estSelectionne = _filtreStatut == valeur;
    return FilterChip(
      label: Text(libelle),
      selected: estSelectionne,
      onSelected: (selectionne) {
        setState(() {
          _filtreStatut = valeur;
          _appliquerFiltres();
        });
      },
      selectedColor: CouleursApp.principal.withValues(alpha: 0.2),
      checkmarkColor: CouleursApp.principal,
    );
  }

  Widget _construireListeUtilisateurs() {
    return WidgetCollection.listeVerticale(
      elements: _utilisateursFiltres,
      constructeurElement: (context, utilisateur, index) => _construireCarteUtilisateur(utilisateur),
      espacementVertical: 12,
      messageEtatVide: 'Aucun utilisateur trouvé',
      iconeEtatVide: Icons.people_outline,
      padding: const EdgeInsets.all(16),
    );
  }

  Widget _construireCarteUtilisateur(Utilisateur utilisateur) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: utilisateur.estActif 
                      ? CouleursApp.principal 
                      : CouleursApp.gris,
                  child: Text(
                    '${utilisateur.prenom[0]}${utilisateur.nom[0]}',
                    style: StylesTexteApp.moyenBlanc.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${utilisateur.prenom} ${utilisateur.nom}',
                        style: StylesTexteApp.moyenTitre,
                      ),
                      Text(
                        utilisateur.email,
                        style: StylesTexteApp.corpsGris,
                      ),
                      Text(
                        '${utilisateur.programme} • ${utilisateur.codeEtudiant}',
                        style: StylesTexteApp.petitGris,
                      ),
                    ],
                  ),
                ),
                _construireBadgeType(utilisateur.typeUtilisateur),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _construireInfoUtilisateur(
                    'Inscription',
                    _formaterDate(utilisateur.dateInscription),
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _construireInfoUtilisateur(
                    'Dernière connexion',
                    utilisateur.derniereConnexion != null
                        ? _formaterDate(utilisateur.derniereConnexion!)
                        : 'Jamais',
                    Icons.access_time,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _construireBoutonAction(
                  'Modifier',
                  Icons.edit,
                  CouleursApp.accent,
                  () => _modifierUtilisateur(utilisateur),
                ),
                _construireBoutonAction(
                  utilisateur.estActif ? 'Suspendre' : 'Activer',
                  utilisateur.estActif ? Icons.block : Icons.check_circle,
                  utilisateur.estActif ? Colors.orange : Colors.green,
                  () => _changerStatutUtilisateur(utilisateur),
                ),
                if (utilisateur.typeUtilisateur != TypeUtilisateur.administrateur)
                  _construireBoutonAction(
                    'Supprimer',
                    Icons.delete,
                    Colors.red,
                    () => _supprimerUtilisateur(utilisateur),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireBadgeType(TypeUtilisateur type) {
    Color couleur;
    String libelle;
    
    switch (type) {
      case TypeUtilisateur.administrateur:
        couleur = Colors.red;
        libelle = 'Admin';
        break;
      case TypeUtilisateur.moderateur:
        couleur = Colors.orange;
        libelle = 'Modérateur';
        break;
      case TypeUtilisateur.etudiant:
        couleur = CouleursApp.principal;
        libelle = 'Étudiant';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: couleur,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        libelle,
        style: StylesTexteApp.petitBlanc.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _construireInfoUtilisateur(String titre, String valeur, IconData icone) {
    return Row(
      children: [
        Icon(icone, size: 16, color: CouleursApp.gris),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titre,
                style: StylesTexteApp.petitGris,
              ),
              Text(
                valeur,
                style: StylesTexteApp.petitCorps,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _construireBoutonAction(
    String libelle,
    IconData icone,
    Color couleur,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icone, size: 16),
      label: Text(libelle),
      style: ElevatedButton.styleFrom(
        backgroundColor: couleur,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _modifierUtilisateur(Utilisateur utilisateur) {
    // TODO: Implémenter l'édition d'utilisateur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Modification de ${utilisateur.prenom} ${utilisateur.nom}'),
        backgroundColor: CouleursApp.accent,
      ),
    );
  }

  void _changerStatutUtilisateur(Utilisateur utilisateur) async {
    final nouvelEtat = !utilisateur.estActif;
    final action = nouvelEtat ? 'activer' : 'suspendre';
    
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer l\'action'),
        content: Text('Voulez-vous $action le compte de ${utilisateur.prenom} ${utilisateur.nom} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: nouvelEtat ? Colors.green : Colors.orange,
            ),
            child: Text(nouvelEtat ? 'Activer' : 'Suspendre'),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      try {
        final succes = await _utilisateursRepository.changerStatutUtilisateur(
          utilisateur.id,
          nouvelEtat,
        );
        
        if (succes) {
          await _chargerUtilisateurs();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Compte ${nouvelEtat ? "activé" : "suspendu"} avec succès !',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
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
      }
    }
  }

  void _supprimerUtilisateur(Utilisateur utilisateur) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer définitivement le compte de ${utilisateur.prenom} ${utilisateur.nom} ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      try {
        final succes = await _utilisateursRepository.supprimerUtilisateur(utilisateur.id);
        
        if (succes) {
          await _chargerUtilisateurs();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Compte supprimé avec succès !'),
                backgroundColor: Colors.green,
              ),
            );
          }
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
      }
    }
  }

  void _afficherModalNouvelUtilisateur() {
    // TODO: Implémenter la création d'utilisateur
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Création d\'utilisateur - fonctionnalité en développement'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  String _formaterDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _controleurRecherche.dispose();
    super.dispose();
  }
} 