// UI Design: Source de données locale pour les utilisateurs (simulation)
import '../models/utilisateur_model.dart';
import '../../domain/entities/utilisateur.dart';

class UtilisateursDatasourceLocal {
  // UI Design: Utilisateur actuellement connecté
  UtilisateurModel? _utilisateurActuel;

  // UI Design: Données simulées des utilisateurs
  final List<UtilisateurModel> _utilisateurs = [
    // UI Design: Administrateur principal
    UtilisateurModel(
      id: 'admin_001',
      nom: 'Tremblay',
      prenom: 'Marie-Claude',
      email: 'admin@uqar.ca',
      codeEtudiant: 'ADMIN001',
      programme: 'Administration',
      niveauEtude: 'Maîtrise',
      telephone: '418-724-1111',
      dateInscription: DateTime.now().subtract(const Duration(days: 365)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.administrateur,
      privileges: [
        PrivilegesUtilisateur.gestionComptes,
        PrivilegesUtilisateur.gestionCantine,
        PrivilegesUtilisateur.gestionActualites,
        PrivilegesUtilisateur.gestionAssociations,
        PrivilegesUtilisateur.gestionSalles,
        PrivilegesUtilisateur.gestionLivres,
        PrivilegesUtilisateur.moderationContenu,
        PrivilegesUtilisateur.statistiques,
      ],
      derniereConnexion: DateTime.now().subtract(const Duration(hours: 2)),
    ),

    // UI Design: Modérateur
    UtilisateurModel(
      id: 'mod_001',
      nom: 'Leblanc',
      prenom: 'Pierre',
      email: 'moderateur@uqar.ca',
      codeEtudiant: 'MOD001',
      programme: 'Informatique',
      niveauEtude: 'Doctorat',
      telephone: '418-724-2222',
      dateInscription: DateTime.now().subtract(const Duration(days: 200)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.moderateur,
      privileges: [
        PrivilegesUtilisateur.gestionActualites,
        PrivilegesUtilisateur.moderationContenu,
      ],
      derniereConnexion: DateTime.now().subtract(const Duration(hours: 1)),
    ),

    // UI Design: Étudiant normal (celui actuellement connecté)
    UtilisateurModel(
      id: 'etud_001',
      nom: 'Martin',
      prenom: 'Alexandre',
      email: 'alexandre.martin@uqar.ca',
      codeEtudiant: 'DUBM12345678',
      programme: 'Informatique',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-3333',
      dateInscription: DateTime.now().subtract(const Duration(days: 90)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(minutes: 30)),
    ),

    // UI Design: Autres étudiants pour les tests
    UtilisateurModel(
      id: 'etud_002',
      nom: 'Gagnon',
      prenom: 'Sophie',
      email: 'sophie.gagnon@uqar.ca',
      codeEtudiant: 'GAGS87654321',
      programme: 'Biologie',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-4444',
      dateInscription: DateTime.now().subtract(const Duration(days: 120)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 2)),
    ),

    UtilisateurModel(
      id: 'etud_003',
      nom: 'Lavoie',
      prenom: 'Marc',
      email: 'marc.lavoie@uqar.ca',
      codeEtudiant: 'LAVM11111111',
      programme: 'Génie',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-5555',
      dateInscription: DateTime.now().subtract(const Duration(days: 60)),
      estActif: false, // Compte suspendu pour les tests
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  // UI Design: Mots de passe simulés (en production, utiliser un système sécurisé)
  final Map<String, String> _motsDePasse = {
    'admin@uqar.ca': 'admin123',
    'moderateur@uqar.ca': 'mod123',
    'alexandre.martin@uqar.ca': 'alex123',
    'sophie.gagnon@uqar.ca': 'sophie123',
    'marc.lavoie@uqar.ca': 'marc123',
  };

  // UI Design: Authentification
  Future<UtilisateurModel?> authentifierUtilisateur(String email, String motDePasse) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulation délai réseau
    
    if (_motsDePasse[email] == motDePasse) {
      final utilisateur = _utilisateurs.firstWhere(
        (u) => u.email == email,
        orElse: () => throw Exception('Utilisateur non trouvé'),
      );
      
      if (utilisateur.estActif) {
        _utilisateurActuel = utilisateur;
        await mettreAJourDerniereConnexion(utilisateur.id);
        return utilisateur;
      }
    }
    return null;
  }

  Future<UtilisateurModel?> obtenirUtilisateurActuel() async {
    return _utilisateurActuel;
  }

  Future<void> deconnecterUtilisateur() async {
    _utilisateurActuel = null;
  }

  // UI Design: Gestion des utilisateurs
  Future<List<UtilisateurModel>> obtenirTousLesUtilisateurs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_utilisateurs);
  }

  Future<List<UtilisateurModel>> rechercherUtilisateurs(String terme) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final termeLower = terme.toLowerCase();
    return _utilisateurs.where((u) =>
      u.nom.toLowerCase().contains(termeLower) ||
      u.prenom.toLowerCase().contains(termeLower) ||
      u.email.toLowerCase().contains(termeLower) ||
      u.codeEtudiant.toLowerCase().contains(termeLower) ||
      u.programme.toLowerCase().contains(termeLower)
    ).toList();
  }

  Future<UtilisateurModel?> obtenirUtilisateurParId(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _utilisateurs.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<UtilisateurModel?> obtenirUtilisateurParCodeEtudiant(String codeEtudiant) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _utilisateurs.firstWhere((u) => u.codeEtudiant == codeEtudiant);
    } catch (e) {
      return null;
    }
  }

  Future<bool> modifierUtilisateur(UtilisateurModel utilisateur) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _utilisateurs.indexWhere((u) => u.id == utilisateur.id);
    if (index != -1) {
      _utilisateurs[index] = utilisateur;
      return true;
    }
    return false;
  }

  Future<bool> changerStatutUtilisateur(String id, bool estActif) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _utilisateurs.indexWhere((u) => u.id == id);
    if (index != -1) {
      _utilisateurs[index] = _utilisateurs[index].copyWith(estActif: estActif);
      return true;
    }
    return false;
  }

  Future<bool> attribuerPrivileges(String id, List<String> privileges) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _utilisateurs.indexWhere((u) => u.id == id);
    if (index != -1) {
      _utilisateurs[index] = _utilisateurs[index].copyWith(privileges: privileges);
      return true;
    }
    return false;
  }

  Future<bool> supprimerUtilisateur(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _utilisateurs.indexWhere((u) => u.id == id);
    if (index != -1) {
      _utilisateurs.removeAt(index);
      return true;
    }
    return false;
  }

  Future<bool> creerUtilisateur(UtilisateurModel utilisateur, String motDePasse) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _utilisateurs.add(utilisateur);
    _motsDePasse[utilisateur.email] = motDePasse;
    return true;
  }

  // UI Design: Statistiques
  Future<Map<String, int>> obtenirStatistiquesUtilisateurs() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'total': _utilisateurs.length,
      'actifs': _utilisateurs.where((u) => u.estActif).length,
      'inactifs': _utilisateurs.where((u) => !u.estActif).length,
      'administrateurs': _utilisateurs.where((u) => u.typeUtilisateur == TypeUtilisateur.administrateur).length,
      'moderateurs': _utilisateurs.where((u) => u.typeUtilisateur == TypeUtilisateur.moderateur).length,
      'etudiants': _utilisateurs.where((u) => u.typeUtilisateur == TypeUtilisateur.etudiant).length,
    };
  }

  Future<List<UtilisateurModel>> obtenirUtilisateursRecents(int limite) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final utilisateursTries = List<UtilisateurModel>.from(_utilisateurs);
    utilisateursTries.sort((a, b) => b.dateInscription.compareTo(a.dateInscription));
    return utilisateursTries.take(limite).toList();
  }

  Future<List<UtilisateurModel>> obtenirUtilisateursActifs() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _utilisateurs.where((u) => u.estActif).toList();
  }

  Future<void> mettreAJourDerniereConnexion(String id) async {
    final index = _utilisateurs.indexWhere((u) => u.id == id);
    if (index != -1) {
      _utilisateurs[index] = _utilisateurs[index].copyWith(
        derniereConnexion: DateTime.now(),
      );
    }
  }

  Future<List<UtilisateurModel>> obtenirUtilisateursConnectes() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final maintenant = DateTime.now();
    final seuilConnexion = maintenant.subtract(const Duration(hours: 24));
    
    return _utilisateurs.where((u) => 
      u.derniereConnexion != null && 
      u.derniereConnexion!.isAfter(seuilConnexion)
    ).toList();
  }
} 