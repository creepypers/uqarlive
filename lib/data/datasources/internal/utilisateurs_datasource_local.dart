import '../../models/utilisateur_model.dart';
import '../../../domain/entities/utilisateur.dart';
class UtilisateursDatasourceLocal {
  UtilisateurModel? _utilisateurActuel;
  final List<UtilisateurModel> _utilisateurs = [
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
      associationsMembre: [], 
      motDePasse: 'admin123', 
    ),
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
      typeUtilisateur: TypeUtilisateur.administrateur,
      privileges: [
        PrivilegesUtilisateur.gestionActualites,
        PrivilegesUtilisateur.moderationContenu,
      ],
      derniereConnexion: DateTime.now().subtract(const Duration(hours: 1)),
      associationsMembre: [], 
      motDePasse: 'mod123', 
    ),
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
      associationsMembre: ['asso_001', 'asso_004', '5'], 
      motDePasse: 'alex123', 
    ),
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
      associationsMembre: ['asso_001', 'asso_002', 'asso_004', '6'], 
      motDePasse: 'sophie123', 
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
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 1)),
      associationsMembre: ['asso_001', 'asso_003', 'asso_004'], 
      motDePasse: 'marc123', 
    ),
    UtilisateurModel(
      id: 'etud_004',
      nom: 'Dubois',
      prenom: 'Marie',
      email: 'marie.dubois@uqar.ca',
      codeEtudiant: 'DUBM87654321',
      programme: 'Biologie',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-6666',
      dateInscription: DateTime.now().subtract(const Duration(days: 150)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 3)),
      associationsMembre: ['asso_001', 'asso_004'], 
      motDePasse: 'marie123', 
    ),
    UtilisateurModel(
      id: 'etud_005',
      nom: 'Roy',
      prenom: 'Catherine',
      email: 'catherine.roy@uqar.ca',
      codeEtudiant: 'ROYC11111111',
      programme: 'Génie',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-7777',
      dateInscription: DateTime.now().subtract(const Duration(days: 180)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 5)),
      associationsMembre: ['asso_001', 'asso_004'], 
      motDePasse: 'catherine123', 
    ),
    UtilisateurModel(
      id: 'etud_006',
      nom: 'Côté',
      prenom: 'Martin',
      email: 'martin.cote@uqar.ca',
      codeEtudiant: 'COTM22222222',
      programme: 'Communication',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-8888',
      dateInscription: DateTime.now().subtract(const Duration(days: 120)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 2)),
      associationsMembre: ['asso_002', 'asso_004'], 
      motDePasse: 'martin123', 
    ),
    UtilisateurModel(
      id: 'etud_007',
      nom: 'Bouchard',
      prenom: 'Julie',
      email: 'julie.bouchard@uqar.ca',
      codeEtudiant: 'BOUJ33333333',
      programme: 'Arts',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-9999',
      dateInscription: DateTime.now().subtract(const Duration(days: 90)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 1)),
      associationsMembre: ['asso_002', 'asso_004'], 
      motDePasse: 'julie123', 
    ),
    UtilisateurModel(
      id: 'etud_008',
      nom: 'Morin',
      prenom: 'Gabriel',
      email: 'gabriel.morin@uqar.ca',
      codeEtudiant: 'MORG44444444',
      programme: 'Sciences',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-0000',
      dateInscription: DateTime.now().subtract(const Duration(days: 60)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(hours: 12)),
      associationsMembre: ['asso_002', 'asso_004'], 
      motDePasse: 'gabriel123', 
    ),
    UtilisateurModel(
      id: 'etud_009',
      nom: 'Beaulieu',
      prenom: 'Juliette',
      email: 'juliette.beaulieu@uqar.ca',
      codeEtudiant: 'BEAJ55555555',
      programme: 'Théâtre',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-1112',
      dateInscription: DateTime.now().subtract(const Duration(days: 200)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 4)),
      associationsMembre: ['asso_003'], 
      motDePasse: 'juliette123', 
    ),
    UtilisateurModel(
      id: 'etud_010',
      nom: 'Santos',
      prenom: 'Maria',
      email: 'maria.santos@uqar.ca',
      codeEtudiant: 'SANM66666666',
      programme: 'Relations internationales',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-2223',
      dateInscription: DateTime.now().subtract(const Duration(days: 150)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 2)),
      associationsMembre: ['asso_003', '7'], 
      motDePasse: 'maria123', 
    ),
    UtilisateurModel(
      id: 'etud_011',
      nom: 'Dufour',
      prenom: 'Isabelle',
      email: 'isabelle.dufour@uqar.ca',
      codeEtudiant: 'DUFI77777777',
      programme: 'Lettres',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-3334',
      dateInscription: DateTime.now().subtract(const Duration(days: 180)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 3)),
      associationsMembre: ['asso_003', '8'], 
      motDePasse: 'isabelle123', 
    ),
    UtilisateurModel(
      id: 'etud_012',
      nom: 'Giguère',
      prenom: 'Laurence',
      email: 'laurence.giguere@uqar.ca',
      codeEtudiant: 'GIGL88888888',
      programme: 'Sciences de l\'environnement',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-4445',
      dateInscription: DateTime.now().subtract(const Duration(days: 100)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 1)),
      associationsMembre: ['asso_003'], 
      motDePasse: 'laurence123', 
    ),
    UtilisateurModel(
      id: 'etud_013',
      nom: 'Michaud',
      prenom: 'Vincent',
      email: 'vincent.michaud@uqar.ca',
      codeEtudiant: 'MICV99999999',
      programme: 'Arts dramatiques',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-5556',
      dateInscription: DateTime.now().subtract(const Duration(days: 160)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 2)),
      associationsMembre: ['5'], 
      motDePasse: 'vincent123', 
    ),
    UtilisateurModel(
      id: 'etud_014',
      nom: 'Côté',
      prenom: 'Thomas',
      email: 'thomas.cote@uqar.ca',
      codeEtudiant: 'COTT00000000',
      programme: 'Arts dramatiques',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-6667',
      dateInscription: DateTime.now().subtract(const Duration(days: 140)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 1)),
      associationsMembre: ['5'], 
      motDePasse: 'thomas123', 
    ),
    UtilisateurModel(
      id: 'etud_015',
      nom: 'Morin',
      prenom: 'Gabriel',
      email: 'gabriel.morin@uqar.ca',
      codeEtudiant: 'MORG11111111',
      programme: 'Sciences de l\'environnement',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-7778',
      dateInscription: DateTime.now().subtract(const Duration(days: 120)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 2)),
      associationsMembre: ['6'], 
      motDePasse: 'gabriel2_123', 
    ),
    UtilisateurModel(
      id: 'etud_016',
      nom: 'Giguère',
      prenom: 'Laurence',
      email: 'laurence.giguere@uqar.ca',
      codeEtudiant: 'GIGL22222222',
      programme: 'Sciences de l\'environnement',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-8889',
      dateInscription: DateTime.now().subtract(const Duration(days: 100)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 1)),
      associationsMembre: ['6'], 
      motDePasse: 'laurence2_123', 
    ),
    UtilisateurModel(
      id: 'etud_017',
      nom: 'Bouchard',
      prenom: 'Marc-André',
      email: 'marc-andre.bouchard@uqar.ca',
      codeEtudiant: 'BOUM33333333',
      programme: 'Sciences de l\'environnement',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-9990',
      dateInscription: DateTime.now().subtract(const Duration(days: 80)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 1)),
      associationsMembre: ['6'], 
      motDePasse: 'marcandre123', 
    ),
    UtilisateurModel(
      id: 'etud_018',
      nom: 'Michaud',
      prenom: 'Vincent',
      email: 'vincent.michaud@uqar.ca',
      codeEtudiant: 'MICV44444444',
      programme: 'Sciences de l\'environnement',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-0001',
      dateInscription: DateTime.now().subtract(const Duration(days: 60)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(hours: 6)),
      associationsMembre: ['6'], 
      motDePasse: 'vincent2_123', 
    ),
    UtilisateurModel(
      id: 'etud_019',
      nom: 'Ben Ali',
      prenom: 'Ahmed',
      email: 'ahmed.benali@uqar.ca',
      codeEtudiant: 'BENA55555555',
      programme: 'Études internationales',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-1113',
      dateInscription: DateTime.now().subtract(const Duration(days: 220)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 3)),
      associationsMembre: ['7'], 
      motDePasse: 'ahmed123', 
    ),
    UtilisateurModel(
      id: 'etud_020',
      nom: 'Santos',
      prenom: 'Maria',
      email: 'maria.santos@uqar.ca',
      codeEtudiant: 'SANM66666666',
      programme: 'Études internationales',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-2224',
      dateInscription: DateTime.now().subtract(const Duration(days: 200)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 2)),
      associationsMembre: ['7'], 
      motDePasse: 'maria2_123', 
    ),
    UtilisateurModel(
      id: 'etud_021',
      nom: 'Garcia',
      prenom: 'Carlos',
      email: 'carlos.garcia@uqar.ca',
      codeEtudiant: 'GARC77777777',
      programme: 'Études internationales',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-3335',
      dateInscription: DateTime.now().subtract(const Duration(days: 180)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 1)),
      associationsMembre: ['7'], 
      motDePasse: 'carlos123', 
    ),
    UtilisateurModel(
      id: 'etud_022',
      nom: 'Kim',
      prenom: 'Ji-Yeon',
      email: 'ji-yeon.kim@uqar.ca',
      codeEtudiant: 'KIMJ88888888',
      programme: 'Études internationales',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-4446',
      dateInscription: DateTime.now().subtract(const Duration(days: 160)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 1)),
      associationsMembre: ['7'], 
      motDePasse: 'jiyeon123', 
    ),
    UtilisateurModel(
      id: 'etud_023',
      nom: 'Patel',
      prenom: 'Priya',
      email: 'priya.patel@uqar.ca',
      codeEtudiant: 'PATP99999999',
      programme: 'Études internationales',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-5557',
      dateInscription: DateTime.now().subtract(const Duration(days: 140)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 2)),
      associationsMembre: ['7'], 
      motDePasse: 'priya123', 
    ),
    UtilisateurModel(
      id: 'etud_024',
      nom: 'Dufour',
      prenom: 'Isabelle',
      email: 'isabelle.dufour@uqar.ca',
      codeEtudiant: 'DUFI00000000',
      programme: 'Lettres',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-6668',
      dateInscription: DateTime.now().subtract(const Duration(days: 240)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 4)),
      associationsMembre: ['8'], 
      motDePasse: 'isabelle2_123', 
    ),
    UtilisateurModel(
      id: 'etud_025',
      nom: 'Bouchard',
      prenom: 'Marc-André',
      email: 'marc-andre.bouchard@uqar.ca',
      codeEtudiant: 'BOUM11111111',
      programme: 'Lettres',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-7779',
      dateInscription: DateTime.now().subtract(const Duration(days: 220)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 3)),
      associationsMembre: ['8'], 
      motDePasse: 'marcandre2_123', 
    ),
    UtilisateurModel(
      id: 'etud_026',
      nom: 'Lavoie',
      prenom: 'Marie',
      email: 'marie.lavoie@uqar.ca',
      codeEtudiant: 'LAVM22222222',
      programme: 'Lettres',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-8880',
      dateInscription: DateTime.now().subtract(const Duration(days: 200)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 2)),
      associationsMembre: ['8'], 
      motDePasse: 'marie2_123', 
    ),
    UtilisateurModel(
      id: 'etud_027',
      nom: 'Gagnon',
      prenom: 'Sophie',
      email: 'sophie.gagnon@uqar.ca',
      codeEtudiant: 'GAGS33333333',
      programme: 'Lettres',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-9991',
      dateInscription: DateTime.now().subtract(const Duration(days: 180)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(days: 1)),
      associationsMembre: ['8'], 
      motDePasse: 'sophie2_123', 
    ),
    UtilisateurModel(
      id: 'etud_028',
      nom: 'Roy',
      prenom: 'Catherine',
      email: 'catherine.roy@uqar.ca',
      codeEtudiant: 'ROYC44444444',
      programme: 'Lettres',
      niveauEtude: 'Baccalauréat',
      telephone: '418-724-0002',
      dateInscription: DateTime.now().subtract(const Duration(days: 160)),
      estActif: true,
      typeUtilisateur: TypeUtilisateur.etudiant,
      privileges: [],
      derniereConnexion: DateTime.now().subtract(const Duration(hours: 8)),
      associationsMembre: ['8'], 
      motDePasse: 'catherine2_123', 
    ),
  ];
  Future<UtilisateurModel?> authentifierUtilisateur(String email, String motDePasse) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulation délai réseau
    try {
      final utilisateur = _utilisateurs.firstWhere(
        (u) => u.email == email,
        orElse: () => throw Exception('Utilisateur non trouvé'),
      );
      if (utilisateur.motDePasse == motDePasse && utilisateur.estActif) {
        _utilisateurActuel = utilisateur;
        await mettreAJourDerniereConnexion(utilisateur.id);
        return utilisateur;
      }
    } catch (e) {
      // Utilisateur non trouvé ou mot de passe incorrect
    }
    return null;
  }
  Future<UtilisateurModel?> obtenirUtilisateurActuel() async {
    // Retourner l'utilisateur actuellement connecté (null si personne n'est connecté)
    return _utilisateurActuel;
  }
  Future<void> deconnecterUtilisateur() async {
    _utilisateurActuel = null;
  }
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
    // _motsDePasse[utilisateur.email] = motDePasse; // This line is removed as per the new_code
    return true;
  }
  Future<Map<String, int>> obtenirStatistiquesUtilisateurs() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'total': _utilisateurs.length,
      'actifs': _utilisateurs.where((u) => u.estActif).length,
      'inactifs': _utilisateurs.where((u) => !u.estActif).length,
      'administrateurs': _utilisateurs.where((u) => u.typeUtilisateur == TypeUtilisateur.administrateur).length,
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