import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/widget_barre_app_personnalisee.dart';
import '../widgets/widget_carte.dart';
import '../widgets/widget_collection.dart';
import '../services/navigation_service.dart';
import '../../core/di/service_locator.dart';
import '../../domain/repositories/livres_repository.dart';
import '../../domain/entities/livre.dart';
import '../../domain/entities/utilisateur.dart';
import '../services/authentification_service.dart';

// UI Design: Écran de gestion des livres personnels de l'utilisateur
class GererLivresEcran extends StatefulWidget {
  const GererLivresEcran({super.key});

  @override
  State<GererLivresEcran> createState() => _GererLivresEcranState();
}

class _GererLivresEcranState extends State<GererLivresEcran> {
  late LivresRepository _livresRepository;
  late AuthentificationService _authentificationService;
  Utilisateur? _utilisateurActuel;
  List<Livre> _mesLivres = [];
  bool _isLoading = true;
  String _filtreActuel = 'tous'; // 'tous', 'disponibles', 'en_cours', 'echanges'

  @override
  void initState() {
    super.initState();
    _livresRepository = ServiceLocator.obtenirService<LivresRepository>();
    _authentificationService = ServiceLocator.obtenirService<AuthentificationService>();
    _utilisateurActuel = _authentificationService.utilisateurActuel;
    _chargerMesLivres();
  }

  Future<void> _chargerMesLivres() async {
    setState(() => _isLoading = true);
    
    try {
      if (_utilisateurActuel == null) {
        // UI Design: Essayer de recharger l'utilisateur depuis le service
        await _authentificationService.chargerUtilisateurActuel();
        _utilisateurActuel = _authentificationService.utilisateurActuel;
        
        // UI Design: Si toujours null, simuler la connexion d'Alexandre Martin pour les tests
        if (_utilisateurActuel == null) {
          final utilisateurConnecte = await _authentificationService.authentifier('alexandre.martin@uqar.ca', 'alex123');
          _utilisateurActuel = utilisateurConnecte;
        }
      }
      
      if (_utilisateurActuel != null) {
        // UI Design: Utiliser le proprietaireId pour filtrer les livres de l'utilisateur connecté
        _mesLivres = await _livresRepository.obtenirLivresParProprietaire(_utilisateurActuel!.id);
      } else {
        _mesLivres = [];
        _afficherErreur('Impossible de charger l\'utilisateur. Veuillez vous reconnecter.');
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _afficherErreur('Erreur lors du chargement des livres: $e');
    }
  }

  List<Livre> get _livresFiltres {
    List<Livre> resultat;
    switch (_filtreActuel) {
      case 'disponibles':
        resultat = _mesLivres.where((livre) => livre.estDisponible).toList();
        break;
      case 'en_cours':
        resultat = _mesLivres.where((livre) => !livre.estDisponible).toList();
        break;
      case 'echanges':
        // Simuler des livres échangés (on pourrait avoir un statut dans l'entité)
        resultat = _mesLivres.take(2).toList(); // Prendre les 2 premiers comme exemple
        break;
      default:
        resultat = _mesLivres;
    }
    
    return resultat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: WidgetBarreAppPersonnalisee(
        titre: 'Gérer mes livres',
        sousTitre: _utilisateurActuel != null 
            ? '${_mesLivres.length} livres au total'
            : 'Chargement...',
        afficherProfil: false,
        widgetFin: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: CouleursApp.blanc),
              onPressed: () => Navigator.pop(context),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: CouleursApp.blanc),
              onPressed: _ajouterNouveauLivre,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filtres de gestion
            _construireFiltresGestion(),
            const SizedBox(height: 16),
            
            // Liste des livres
            Expanded(
              child: WidgetCollection<Livre>.listeVerticale(
                elements: _livresFiltres,
                enChargement: _isLoading,
                constructeurElement: (context, livre, index) => WidgetCarte.livre(
                  livre: livre,
                  onTap: () => _gererLivre(livre),
                ),
                espacementVertical: 8,
                messageEtatVide: 'Aucun livre trouvé\nAjoutez votre premier livre !',
                iconeEtatVide: Icons.menu_book_outlined,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavBarWidget(
        indexSelectionne: 2, // Profil
        onTap: (index) => NavigationService.gererNavigationNavBar(context, index),
      ),
    );
  }

  // UI Design: Filtres de gestion des livres
  Widget _construireFiltresGestion() {
    return Container(
      height: 40,
      margin: const EdgeInsets.all(16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _construireBoutonFiltre('tous', 'Tous (${_mesLivres.length})'),
          const SizedBox(width: 8),
          _construireBoutonFiltre(
            'disponibles', 
            'Disponibles (${_mesLivres.where((l) => l.estDisponible).length})'
          ),
          const SizedBox(width: 8),
          _construireBoutonFiltre(
            'en_cours', 
            'En échange (${_mesLivres.where((l) => !l.estDisponible).length})'
          ),
          const SizedBox(width: 8),
          _construireBoutonFiltre('echanges', 'Historique (2)'),
        ],
      ),
    );
  }

  Widget _construireBoutonFiltre(String filtre, String label) {
    final estActif = _filtreActuel == filtre;
    return GestureDetector(
      onTap: () => setState(() => _filtreActuel = filtre),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: estActif ? CouleursApp.principal : CouleursApp.blanc,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: estActif ? CouleursApp.principal : CouleursApp.principal.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: estActif ? CouleursApp.blanc : CouleursApp.principal,
            fontWeight: estActif ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // UI Design: Listes prédéfinies pour UQAR
  static const List<String> _matieres = [
    'Informatique',
    'Mathématiques',
    'Génie Civil', 
    'Génie Électrique',
    'Administration',
    'Psychologie',
    'Sciences de l\'Éducation',
    'Histoire',
    'Français',
    'Anglais',
    'Chimie',
    'Biologie',
    'Physique',
    'Sciences Sociales',
    'Philosophie',
    'Géographie',
  ];

  static const List<String> _anneesEtude = [
    '1ère année - Baccalauréat',
    '2ème année - Baccalauréat', 
    '3ème année - Baccalauréat',
    '4ème année - Baccalauréat',
    '1ère année - Maîtrise',
    '2ème année - Maîtrise',
    'Doctorat',
    'Certificat',
    'Formation continue',
  ];

  // Actions
  void _ajouterNouveauLivre() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _construireModalAjoutLivre(),
    );
  }

  // UI Design: Modal optimisé pour éviter le problème de clavier qui se ferme
  Widget _construireModalAjoutLivre() {
    return _ModalAjoutLivre(
      utilisateurActuel: _utilisateurActuel,
      onLivreAjoute: (livre) {
                      setState(() {
          _mesLivres.add(livre);
        });

        
        // Afficher message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Livre "${livre.titre}" ajouté avec succès !'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(
              label: 'Voir',
              textColor: Colors.white,
                          onPressed: () {
                setState(() => _filtreActuel = 'tous');
              },
            ),
          ),
        );
      },
    );
  }

  void _gererLivre(Livre livre) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _construireModalGestionLivre(livre),
    );
  }

  Widget _construireModalGestionLivre(Livre livre) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            livre.titre,
            style: StylesTexteApp.titre.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Par ${livre.auteur}',
            style: TextStyle(
              fontSize: 14,
              color: CouleursApp.texteFonce.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          
          // Actions disponibles
          ListTile(
            leading: const Icon(Icons.edit, color: CouleursApp.principal),
            title: const Text('Modifier les détails'),
            onTap: () {
              Navigator.pop(context);
              _modifierLivre(livre);
            },
          ),
          ListTile(
            leading: Icon(
              livre.estDisponible ? Icons.pause : Icons.play_arrow,
              color: CouleursApp.accent,
            ),
            title: Text(livre.estDisponible ? 'Suspendre l\'échange' : 'Remettre en échange'),
            onTap: () {
              Navigator.pop(context);
              _basculerDisponibilite(livre);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Supprimer le livre'),
            onTap: () {
              Navigator.pop(context);
              _supprimerLivre(livre);
            },
          ),
        ],
      ),
    );
  }

  void _modifierLivre(Livre livre) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _construireModalModificationLivre(livre),
    );
  }

  // UI Design: Modal pour modifier un livre existant
  Widget _construireModalModificationLivre(Livre livre) {
    return _ModalModificationLivre(
      livre: livre,
      utilisateurActuel: _utilisateurActuel,
      onLivreModifie: (livreModifie) {
        setState(() {
          final index = _mesLivres.indexWhere((l) => l.id == livre.id);
          if (index != -1) {
            _mesLivres[index] = livreModifie;
          }
        });
        
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
            content: Text('Livre "${livreModifie.titre}" modifié avec succès !'),
            backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
        );
      },
    );
  }

  Future<void> _basculerDisponibilite(Livre livre) async {
    try {
      final succes = livre.estDisponible 
          ? await _livresRepository.marquerLivreEchange(livre.id)
          : await _livresRepository.marquerLivreDisponible(livre.id);
      
      if (succes) {
        setState(() {
          final index = _mesLivres.indexWhere((l) => l.id == livre.id);
          if (index != -1) {
            _mesLivres[index] = livre.copyWith(estDisponible: !livre.estDisponible);
          }
        });
        
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          livre.estDisponible 
              ? 'Livre suspendu des échanges'
              : 'Livre remis en échange'
        ),
        backgroundColor: livre.estDisponible ? Colors.orange : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
      } else {
        _afficherErreur('Erreur lors de la modification');
      }
    } catch (e) {
      _afficherErreur('Erreur inattendue: $e');
    }
  }

  void _supprimerLivre(Livre livre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le livre'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${livre.titre}" ?\\n\\nCette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final succes = await _livresRepository.supprimerLivre(livre.id);
                
                if (succes) {
                  setState(() {
                    _mesLivres.removeWhere((l) => l.id == livre.id);
                  });
                  
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                      content: Text('"${livre.titre}" supprimé avec succès'),
                      backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
                } else {
                  _afficherErreur('Erreur lors de la suppression');
                }
              } catch (e) {
                _afficherErreur('Erreur inattendue: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: CouleursApp.blanc)),
          ),
        ],
      ),
    );
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


}

// UI Design: Widget modal séparé pour éviter le problème de clavier qui se ferme
class _ModalAjoutLivre extends StatefulWidget {
  final Function(Livre) onLivreAjoute;
  final Utilisateur? utilisateurActuel;

  const _ModalAjoutLivre({
    required this.onLivreAjoute,
    required this.utilisateurActuel,
  });

  @override
  State<_ModalAjoutLivre> createState() => _ModalAjoutLivreState();
}

class _ModalAjoutLivreState extends State<_ModalAjoutLivre> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _auteurController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _editionController = TextEditingController();
  final _coursController = TextEditingController();
  final _prixController = TextEditingController();
  
  late LivresRepository _livresRepository;
  
  String? _matiereSelectionnee;
  String? _anneeSelectionnee;
  String _etatSelectionne = 'Excellent';
  bool _enVente = false;
  bool _sauvegardeEnCours = false;

  @override
  void initState() {
    super.initState();
    _livresRepository = ServiceLocator.obtenirService<LivresRepository>();
  }

  @override
  void dispose() {
    _titreController.dispose();
    _auteurController.dispose();
    _descriptionController.dispose();
    _editionController.dispose();
    _coursController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Row(
                      children: [
                        const Icon(Icons.add_circle, color: CouleursApp.principal, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Ajouter un nouveau livre',
                          style: StylesTexteApp.titre.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Champ Titre (requis)
                    TextFormField(
                      controller: _titreController,
                      decoration: InputDecoration(
                        labelText: 'Titre du livre *',
                        hintText: 'Ex: Calcul différentiel et intégral',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.book, color: CouleursApp.principal),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Le titre est requis';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Champ Auteur (requis)
                    TextFormField(
                      controller: _auteurController,
                      decoration: InputDecoration(
                        labelText: 'Auteur *',
                        hintText: 'Ex: Jean Dupont',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.person, color: CouleursApp.principal),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'L\'auteur est requis';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Dropdown Matière (requis)
                    DropdownButtonFormField<String>(
                      value: _matiereSelectionnee,
                      decoration: InputDecoration(
                        labelText: 'Matière *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.school, color: CouleursApp.principal),
                      ),
                      hint: const Text('Sélectionnez une matière'),
                      items: _GererLivresEcranState._matieres
                          .map((matiere) => DropdownMenuItem(
                                value: matiere,
                                child: Text(matiere),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _matiereSelectionnee = value),
                      validator: (value) {
                        if (value == null) return 'La matière est requise';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Dropdown Année d'étude (requis)
                    DropdownButtonFormField<String>(
                      value: _anneeSelectionnee,
                      decoration: InputDecoration(
                        labelText: 'Année d\'étude *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.grade, color: CouleursApp.principal),
                      ),
                      hint: const Text('Sélectionnez une année'),
                      items: _GererLivresEcranState._anneesEtude
                          .map((annee) => DropdownMenuItem(
                                value: annee,
                                child: Text(annee),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _anneeSelectionnee = value),
                      validator: (value) {
                        if (value == null) return 'L\'année d\'étude est requise';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Dropdown État (requis)
                    DropdownButtonFormField<String>(
                      value: _etatSelectionne,
                      decoration: InputDecoration(
                        labelText: 'État du livre *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.star, color: CouleursApp.principal),
                      ),
                      items: ['Excellent', 'Très bon', 'Bon', 'Acceptable']
                          .map((etat) => DropdownMenuItem(
                                value: etat,
                                child: Text(etat),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _etatSelectionne = value!),
                    ),
                    const SizedBox(height: 16),
                    
                    // Champ Description (optionnel)
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description (optionnel)',
                        hintText: 'Décrivez l\'état, les annotations...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.description, color: CouleursApp.principal),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Champ Édition (optionnel)
                    TextFormField(
                      controller: _editionController,
                      decoration: InputDecoration(
                        labelText: 'Édition (optionnel)',
                        hintText: 'Ex: 3ème édition',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.edit, color: CouleursApp.principal),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Champ Cours associé (optionnel)
                    TextFormField(
                      controller: _coursController,
                      decoration: InputDecoration(
                        labelText: 'Cours associé (optionnel)',
                        hintText: 'Ex: MAT101 - Calcul I',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.class_, color: CouleursApp.principal),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Option Mettre en vente
                    Row(
                      children: [
                        Switch(
                          value: _enVente,
                          onChanged: (v) => setState(() => _enVente = v),
                          activeColor: CouleursApp.accent,
                        ),
                        const SizedBox(width: 8),
                        const Text('Mettre en vente', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    if (_enVente) ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _prixController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Prix (€) *',
                          hintText: 'Ex: 12.50',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.euro, color: CouleursApp.accent),
                        ),
                        validator: (value) {
                          if (!_enVente) return null;
                          if (value == null || value.isEmpty) return 'Le prix est requis';
                          final parsed = double.tryParse(value.replaceAll(',', '.'));
                          if (parsed == null || parsed < 0.01) return 'Prix invalide';
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    
                    // Note informative
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CouleursApp.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: CouleursApp.accent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: CouleursApp.accent, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Votre livre sera automatiquement disponible pour échange.',
                              style: TextStyle(
                                fontSize: 12,
                                color: CouleursApp.texteFonce.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Boutons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Annuler'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _sauvegardeEnCours ? null : _sauvegarderLivre,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CouleursApp.accent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _sauvegardeEnCours
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(CouleursApp.blanc),
                                    ),
                                  )
                                : const Text(
                              'Ajouter le livre',
                              style: TextStyle(
                                color: CouleursApp.blanc,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _sauvegarderLivre() async {
    if (_formKey.currentState!.validate() && widget.utilisateurActuel != null) {
      setState(() => _sauvegardeEnCours = true);
      
      try {
      final prix = _enVente && _prixController.text.isNotEmpty
        ? double.tryParse(_prixController.text.replaceAll(',', '.'))
        : null;
      final nouveauLivre = Livre(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titre: _titreController.text,
        auteur: _auteurController.text,
        matiere: _matiereSelectionnee!,
        anneeEtude: _anneeSelectionnee!,
        etatLivre: _etatSelectionne,
        proprietaire: '${widget.utilisateurActuel!.prenom} ${widget.utilisateurActuel!.nom}',
        proprietaireId: widget.utilisateurActuel!.id, // UI Design: Lier à l'utilisateur connecté
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        edition: _editionController.text.isNotEmpty ? _editionController.text : null,
        coursAssocies: _coursController.text.isNotEmpty ? _coursController.text : null,
        estDisponible: true,
        dateAjout: DateTime.now(),
        prix: prix,
      );

      // UI Design: Sauvegarder le livre via le repository
      final succes = await _livresRepository.ajouterLivre(nouveauLivre);
      
      if (succes) {
      widget.onLivreAjoute(nouveauLivre);
      Navigator.pop(context);
      } else {
        setState(() => _sauvegardeEnCours = false);
        _afficherErreur('Erreur lors de l\'ajout du livre');
      }
    } catch (e) {
      setState(() => _sauvegardeEnCours = false);
      _afficherErreur('Erreur inattendue: $e');
    }
    }
  }
}

// UI Design: Widget modal pour modifier un livre existant
class _ModalModificationLivre extends StatefulWidget {
  final Livre livre;
  final Function(Livre) onLivreModifie;
  final Utilisateur? utilisateurActuel;

  const _ModalModificationLivre({
    required this.livre,
    required this.onLivreModifie,
    required this.utilisateurActuel,
  });

  @override
  State<_ModalModificationLivre> createState() => _ModalModificationLivreState();
}

class _ModalModificationLivreState extends State<_ModalModificationLivre> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titreController;
  late final TextEditingController _auteurController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _editionController;
  late final TextEditingController _coursController;
  late final TextEditingController _prixController;
  
  late LivresRepository _livresRepository;
  
  late String? _matiereSelectionnee;
  late String? _anneeSelectionnee;
  late String _etatSelectionne;
  late bool _enVente;
  bool _sauvegardeEnCours = false;

  static const List<String> _matieres = [
    'Mathématiques', 'Informatique', 'Physique', 'Chimie', 'Biologie',
    'Histoire', 'Géographie', 'Français', 'Anglais', 'Philosophie',
    'Économie', 'Gestion', 'Droit', 'Psychologie', 'Sociologie'
  ];

  static const List<String> _anneesEtude = [
    '1ère année', '2ème année', '3ème année', '4ème année', '5ème année'
  ];

  @override
  void initState() {
    super.initState();
    _livresRepository = ServiceLocator.obtenirService<LivresRepository>();
    
    // UI Design: Pré-remplir les champs avec les données du livre existant
    _titreController = TextEditingController(text: widget.livre.titre);
    _auteurController = TextEditingController(text: widget.livre.auteur);
    _descriptionController = TextEditingController(text: widget.livre.description ?? '');
    _editionController = TextEditingController(text: widget.livre.edition ?? '');
    _coursController = TextEditingController(text: widget.livre.coursAssocies ?? '');
    _prixController = TextEditingController(text: widget.livre.prix?.toString() ?? '');
    
    _matiereSelectionnee = widget.livre.matiere;
    _anneeSelectionnee = widget.livre.anneeEtude;
    _etatSelectionne = widget.livre.etatLivre;
    _enVente = widget.livre.prix != null;
  }

  @override
  void dispose() {
    _titreController.dispose();
    _auteurController.dispose();
    _descriptionController.dispose();
    _editionController.dispose();
    _coursController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CouleursApp.fond,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              children: [
                // En-tête
                Row(
                  children: [
                    const Icon(Icons.edit, color: CouleursApp.principal, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Modifier le livre',
                      style: StylesTexteApp.titre.copyWith(fontSize: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Champs obligatoires
                Text(
                  'Informations de base',
                  style: StylesTexteApp.titre.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _titreController,
                  decoration: InputDecoration(
                    labelText: 'Titre du livre *',
                    hintText: 'Ex: Calcul différentiel et intégral',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.book, color: CouleursApp.principal),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le titre est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _auteurController,
                  decoration: InputDecoration(
                    labelText: 'Auteur *',
                    hintText: 'Ex: Jean Dupont',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person, color: CouleursApp.principal),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'L\'auteur est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _matiereSelectionnee,
                  decoration: InputDecoration(
                    labelText: 'Matière *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.school, color: CouleursApp.principal),
                  ),
                  hint: const Text('Sélectionnez une matière'),
                  items: _matieres.map((matiere) => DropdownMenuItem(
                    value: matiere,
                    child: Text(matiere),
                  )).toList(),
                  onChanged: (value) => setState(() => _matiereSelectionnee = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La matière est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _anneeSelectionnee,
                  decoration: InputDecoration(
                    labelText: 'Année d\'étude *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.grade, color: CouleursApp.principal),
                  ),
                  hint: const Text('Sélectionnez une année'),
                  items: _anneesEtude.map((annee) => DropdownMenuItem(
                    value: annee,
                    child: Text(annee),
                  )).toList(),
                  onChanged: (value) => setState(() => _anneeSelectionnee = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'L\'année d\'étude est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _etatSelectionne,
                  decoration: InputDecoration(
                    labelText: 'État du livre *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.star, color: CouleursApp.principal),
                  ),
                  items: ['Excellent', 'Très bon', 'Bon', 'Acceptable']
                      .map((etat) => DropdownMenuItem(
                            value: etat,
                            child: Text(etat),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _etatSelectionne = value!),
                ),
                const SizedBox(height: 24),

                // Champs optionnels
                Text(
                  'Informations supplémentaires',
                  style: StylesTexteApp.titre.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description (optionnel)',
                    hintText: 'Décrivez l\'état, les annotations...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.description, color: CouleursApp.principal),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _editionController,
                  decoration: InputDecoration(
                    labelText: 'Édition (optionnel)',
                    hintText: 'Ex: 3ème édition',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.edit, color: CouleursApp.principal),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _coursController,
                  decoration: InputDecoration(
                    labelText: 'Cours associés (optionnel)',
                    hintText: 'Ex: MAT101 - Calcul I',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.class_, color: CouleursApp.principal),
                  ),
                ),
                const SizedBox(height: 20),

                // Option vente
                Row(
                  children: [
                    Checkbox(
                      value: _enVente,
                      onChanged: (value) => setState(() {
                        _enVente = value ?? false;
                        if (!_enVente) _prixController.clear();
                      }),
                    ),
                    const SizedBox(width: 8),
                    const Text('Mettre en vente', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),

                if (_enVente) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _prixController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Prix (€) *',
                      hintText: 'Ex: 12.50',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.euro, color: CouleursApp.accent),
                    ),
                    validator: (value) {
                      if (_enVente && (value == null || value.isEmpty)) {
                        return 'Le prix est obligatoire si le livre est en vente';
                      }
                      if (_enVente && double.tryParse(value!.replaceAll(',', '.')) == null) {
                        return 'Le prix doit être un nombre valide';
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 20),

                // Conseil
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CouleursApp.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: CouleursApp.accent, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Assurez-vous que les informations sont exactes pour faciliter les échanges.',
                          style: TextStyle(fontSize: 12, color: CouleursApp.texteFonce),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _sauvegardeEnCours ? null : _sauvegarderModifications,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CouleursApp.accent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _sauvegardeEnCours
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(CouleursApp.blanc),
                                ),
                              )
                            : const Text(
                                'Sauvegarder',
                                style: TextStyle(
                                  color: CouleursApp.blanc,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _sauvegarderModifications() async {
    if (_formKey.currentState!.validate() && widget.utilisateurActuel != null) {
      setState(() => _sauvegardeEnCours = true);
      
      try {
        final prix = _enVente && _prixController.text.isNotEmpty
            ? double.tryParse(_prixController.text.replaceAll(',', '.'))
            : null;
            
        final livreModifie = widget.livre.copyWith(
          titre: _titreController.text,
          auteur: _auteurController.text,
          matiere: _matiereSelectionnee!,
          anneeEtude: _anneeSelectionnee!,
          etatLivre: _etatSelectionne,
          description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
          edition: _editionController.text.isNotEmpty ? _editionController.text : null,
          coursAssocies: _coursController.text.isNotEmpty ? _coursController.text : null,
          prix: prix,
        );

        // UI Design: Sauvegarder les modifications via le repository
        final succes = await _livresRepository.modifierLivre(livreModifie);
        
        if (succes) {
          widget.onLivreModifie(livreModifie);
          Navigator.pop(context);
        } else {
          setState(() => _sauvegardeEnCours = false);
          _afficherErreur('Erreur lors de la modification du livre');
        }
      } catch (e) {
        setState(() => _sauvegardeEnCours = false);
        _afficherErreur('Erreur inattendue: $e');
      }
    }
  }
} 