import '../../core/di/service_locator.dart';
import '../../domain/entities/utilisateur.dart';
import '../../domain/repositories/actualites_repository.dart';
import '../../domain/repositories/associations_repository.dart';
import '../../domain/repositories/evenements_repository.dart';
import '../../domain/repositories/livres_repository.dart';
import '../../domain/repositories/menus_repository.dart';
import '../../domain/repositories/salles_repository.dart';
import '../../domain/repositories/utilisateurs_repository.dart';

// UI Design: Service centralisé pour toutes les statistiques de l'application
class StatistiquesService {
  // Repositories
  late final ActualitesRepository _actualitesRepository;
  late final AssociationsRepository _associationsRepository;
  late final EvenementsRepository _evenementsRepository;
  late final LivresRepository _livresRepository;
  late final MenusRepository _menusRepository;
  late final SallesRepository _sallesRepository;
  late final UtilisateursRepository _utilisateursRepository;

  StatistiquesService() {
    _actualitesRepository = ServiceLocator.obtenirService<ActualitesRepository>();
    _associationsRepository = ServiceLocator.obtenirService<AssociationsRepository>();
    _evenementsRepository = ServiceLocator.obtenirService<EvenementsRepository>();
    _livresRepository = ServiceLocator.obtenirService<LivresRepository>();
    _menusRepository = ServiceLocator.obtenirService<MenusRepository>();
    _sallesRepository = ServiceLocator.obtenirService<SallesRepository>();
    _utilisateursRepository = ServiceLocator.obtenirService<UtilisateursRepository>();
  }

  // UI Design: Statistiques globales de l'application
  Future<StatistiquesGlobales> obtenirStatistiquesGlobales() async {
    try {
      final results = await Future.wait([
        _utilisateursRepository.obtenirTousLesUtilisateurs(),
        _associationsRepository.obtenirToutesLesAssociations(),
        _actualitesRepository.obtenirActualites(),
        _evenementsRepository.obtenirEvenements(),
        _livresRepository.obtenirTousLesLivres(),
        _menusRepository.obtenirTousLesMenus(),
        _sallesRepository.obtenirToutesLesSalles(),
      ]);

      final utilisateurs = results[0] as List<dynamic>;
      final associations = results[1] as List<dynamic>;
      final actualites = results[2] as List<dynamic>;
      final evenements = results[3] as List<dynamic>;
      final livres = results[4] as List<dynamic>;
      final menus = results[5] as List<dynamic>;
      final salles = results[6] as List<dynamic>;

      return StatistiquesGlobales(
        // Utilisateurs
        totalUtilisateurs: utilisateurs.length,
        utilisateursActifs: utilisateurs.where((u) => u.estActif).length,
        utilisateursSuspendu: utilisateurs.where((u) => !u.estActif).length,
        administrateurs: utilisateurs.where((u) => u.typeUtilisateur == TypeUtilisateur.administrateur).length,
        etudiants: utilisateurs.where((u) => u.typeUtilisateur == TypeUtilisateur.etudiant).length,

        // Associations
        totalAssociations: associations.length,
        associationsActives: associations.where((a) => a.estActive).length,
        associationsInactives: associations.where((a) => !a.estActive).length,
        membresTotal: associations.fold<int>(0, (sum, a) => sum + ((a as dynamic).nombreMembres as num).toInt()),

        // Actualités
        totalActualites: actualites.length,
        actualitesEpinglees: actualites.where((a) => a.estEpinglee).length,
        actualitesUrgentes: actualites.where((a) => a.priorite == 'urgente').length,
        vuesMoyennes: actualites.isEmpty ? 0 : actualites.fold<int>(0, (sum, a) => sum + ((a as dynamic).nombreVues as num).toInt()) / actualites.length,

        // Événements
        totalEvenements: evenements.length,
        evenementsAVenir: evenements.where((e) => e.estAVenir).length,
        evenementsEnCours: evenements.where((e) => e.estEnCours).length,
        evenementsTermines: evenements.where((e) => e.estTermine).length,
        evenementsGratuits: evenements.where((e) => e.estGratuit).length,
        evenementsPayants: evenements.where((e) => !e.estGratuit).length,
        inscriptionsTotal: evenements.fold<int>(0, (sum, e) => sum + ((e as dynamic).nombreInscrits as num).toInt()),

        // Livres
        totalLivres: livres.length,
        livresDisponibles: livres.where((l) => l.estDisponible).length,
        livresEmpruntes: livres.where((l) => !l.estDisponible).length,
        livresRecents: livres.where((l) => DateTime.now().difference(l.dateAjout).inDays <= 30).length,

        // Cantine
        totalMenus: menus.length,
        menusJour: menus.where((m) => m.estMenuDuJour).length,
        menusDisponibles: menus.where((m) => m.estDisponible).length,
        prixMoyen: menus.isEmpty ? 0 : menus.fold(0.0, (sum, m) => sum + m.prix) / menus.length,

        // Salles
        totalSalles: salles.length,
        sallesDisponibles: salles.where((s) => s.estDisponible).length,
        sallesOccupees: salles.where((s) => !s.estDisponible).length,
        capaciteTotal: salles.fold<int>(0, (sum, s) => sum + ((s as dynamic).capaciteMax as num).toInt()),
      );
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques: $e');
    }
  }

  // UI Design: Statistiques détaillées pour le dashboard
  Future<StatistiquesDashboard> obtenirStatistiquesDashboard() async {
    final stats = await obtenirStatistiquesGlobales();
    final actualites = await _actualitesRepository.obtenirActualites();
    final evenements = await _evenementsRepository.obtenirEvenements();
    final utilisateurs = await _utilisateursRepository.obtenirTousLesUtilisateurs();

    return StatistiquesDashboard(
      statistiquesGlobales: stats,
      
      // Tendances hebdomadaires (simulation basée sur les données)
      nouvellesInscriptionsHebdo: _calculerTendanceHebdomadaire(utilisateurs.length),
      nouvellesActualitesHebdo: _calculerTendanceHebdomadaire(actualites.length),
      nouveauxEvenementsHebdo: _calculerTendanceHebdomadaire(evenements.length),
      
      // Activité récente
      actualitesRecentes: actualites.take(3).toList(),
      evenementsProchains: evenements.where((e) => e.estAVenir).take(3).toList(),
      derniersUtilisateurs: utilisateurs.take(5).toList(),
      
      // Performance
      tauxActiviteUtilisateurs: stats.totalUtilisateurs > 0 ? stats.utilisateursActifs / stats.totalUtilisateurs : 0,
      tauxOccupationSalles: stats.totalSalles > 0 ? stats.sallesOccupees / stats.totalSalles : 0,
      tauxParticipationEvenements: stats.totalEvenements > 0 && stats.inscriptionsTotal > 0 
          ? stats.inscriptionsTotal / (stats.totalEvenements * 50) : 0, // Estimation capacité moyenne 50
    );
  }

  // UI Design: Calcul simple de tendance basé sur le volume total
  int _calculerTendanceHebdomadaire(int total) {
    // Simulation d'une tendance hebdomadaire (5-15% du total)
    return (total * 0.1).round();
  }
}

// UI Design: Modèle pour les statistiques globales
class StatistiquesGlobales {
  // Utilisateurs
  final int totalUtilisateurs;
  final int utilisateursActifs;
  final int utilisateursSuspendu;
  final int administrateurs;
  final int etudiants;

  // Associations
  final int totalAssociations;
  final int associationsActives;
  final int associationsInactives;
  final int membresTotal;

  // Actualités
  final int totalActualites;
  final int actualitesEpinglees;
  final int actualitesUrgentes;
  final double vuesMoyennes;

  // Événements
  final int totalEvenements;
  final int evenementsAVenir;
  final int evenementsEnCours;
  final int evenementsTermines;
  final int evenementsGratuits;
  final int evenementsPayants;
  final int inscriptionsTotal;

  // Livres
  final int totalLivres;
  final int livresDisponibles;
  final int livresEmpruntes;
  final int livresRecents;

  // Cantine
  final int totalMenus;
  final int menusJour;
  final int menusDisponibles;
  final double prixMoyen;

  // Salles
  final int totalSalles;
  final int sallesDisponibles;
  final int sallesOccupees;
  final int capaciteTotal;

  const StatistiquesGlobales({
    required this.totalUtilisateurs,
    required this.utilisateursActifs,
    required this.utilisateursSuspendu,
    required this.administrateurs,
    required this.etudiants,
    required this.totalAssociations,
    required this.associationsActives,
    required this.associationsInactives,
    required this.membresTotal,
    required this.totalActualites,
    required this.actualitesEpinglees,
    required this.actualitesUrgentes,
    required this.vuesMoyennes,
    required this.totalEvenements,
    required this.evenementsAVenir,
    required this.evenementsEnCours,
    required this.evenementsTermines,
    required this.evenementsGratuits,
    required this.evenementsPayants,
    required this.inscriptionsTotal,
    required this.totalLivres,
    required this.livresDisponibles,
    required this.livresEmpruntes,
    required this.livresRecents,
    required this.totalMenus,
    required this.menusJour,
    required this.menusDisponibles,
    required this.prixMoyen,
    required this.totalSalles,
    required this.sallesDisponibles,
    required this.sallesOccupees,
    required this.capaciteTotal,
  });
}

// UI Design: Modèle pour les statistiques du dashboard
class StatistiquesDashboard {
  final StatistiquesGlobales statistiquesGlobales;
  
  // Tendances
  final int nouvellesInscriptionsHebdo;
  final int nouvellesActualitesHebdo;
  final int nouveauxEvenementsHebdo;
  
  // Activité récente
  final List<dynamic> actualitesRecentes;
  final List<dynamic> evenementsProchains;
  final List<dynamic> derniersUtilisateurs;
  
  // Performance
  final double tauxActiviteUtilisateurs;
  final double tauxOccupationSalles;
  final double tauxParticipationEvenements;

  const StatistiquesDashboard({
    required this.statistiquesGlobales,
    required this.nouvellesInscriptionsHebdo,
    required this.nouvellesActualitesHebdo,
    required this.nouveauxEvenementsHebdo,
    required this.actualitesRecentes,
    required this.evenementsProchains,
    required this.derniersUtilisateurs,
    required this.tauxActiviteUtilisateurs,
    required this.tauxOccupationSalles,
    required this.tauxParticipationEvenements,
  });
} 