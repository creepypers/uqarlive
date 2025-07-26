# 📋 Architecture Log - UqarLive

## 🏗️ Clean Architecture Implementation

### ✅ Layers Implemented
- [x] **Domain Layer** (`lib/domain/`)
  - [x] Entities: `Association`, `Livre`, `Menu`, `Salle`, `Actualite`, `Utilisateur`
  - [x] Repositories (interfaces): `AssociationsRepository`, `LivresRepository`, `MenusRepository`, `SallesRepository`, `ActualitesRepository`, `UtilisateursRepository`

- [x] **Data Layer** (`lib/data/`)
  - [x] Models: `AssociationModel`, `LivreModel`, `MenuModel`, `SalleModel`, `ActualiteModel`, `UtilisateurModel`
  - [x] Repository Implementations: All repositories implemented
  - [x] Data Sources: Local simulation datasources

- [x] **Presentation Layer** (`lib/presentation/`)
  - [x] Screens: 13+ screens implemented
  - [x] Widgets: Reusable UI components
  - [x] Services: Navigation service

### 📁 Files Added/Changed

#### Domain Layer
- ✅ `domain/entities/association.dart`
- ✅ `domain/entities/livre.dart` 
- ✅ `domain/entities/menu.dart`
- ✅ `domain/entities/salle.dart`
- ✅ `domain/entities/actualite.dart` - [2025-01-XX] Nouvelle entité pour actualités
- ✅ `domain/entities/utilisateur.dart` - [2025-01-XX] Entité utilisateur avec rôles
- ✅ `domain/repositories/associations_repository.dart`
- ✅ `domain/repositories/livres_repository.dart`
- ✅ `domain/repositories/menus_repository.dart`
- ✅ `domain/repositories/salles_repository.dart`
- ✅ `domain/repositories/actualites_repository.dart` - [2025-01-XX]
- ✅ `domain/repositories/utilisateurs_repository.dart` - [2025-01-XX]

#### Data Layer
- ✅ `data/models/association_model.dart`
- ✅ `data/models/livre_model.dart`
- ✅ `data/models/menu_model.dart`
- ✅ `data/models/salle_model.dart`
- ✅ `data/models/actualite_model.dart` - [2025-01-XX]
- ✅ `data/models/utilisateur_model.dart` - [2025-01-XX]
- ✅ `data/repositories/associations_repository_impl.dart`
- ✅ `data/repositories/livres_repository_impl.dart`
- ✅ `data/repositories/menus_repository_impl.dart`
- ✅ `data/repositories/salles_repository_impl.dart`
- ✅ `data/repositories/actualites_repository_impl.dart` - [2025-01-XX]
- ✅ `data/repositories/utilisateurs_repository_impl.dart` - [2025-01-XX]
- ✅ `data/datasources/associations_datasource_local.dart`
- ✅ `data/datasources/livres_datasource_local.dart`
- ✅ `data/datasources/menus_datasource_local.dart`
- ✅ `data/datasources/salles_datasource_local.dart`
- ✅ `data/datasources/actualites_datasource_local.dart` - [2025-01-XX]
- ✅ `data/datasources/utilisateurs_datasource_local.dart` - [2025-01-XX]
- 🔄 `data/datasources/horaires_datasource_local.dart` - [2025-01-XX] **UNIFIÉ**
- 🔄 `data/datasources/evenements_datasource_local.dart` - [2025-01-XX] **UNIFIÉ**

#### Presentation Layer
- ✅ `presentation/screens/` - Multiple screens implemented
- ✅ `presentation/widgets/` - Reusable widgets
- ✅ `presentation/services/navigation_service.dart`

### 🔄 Design Decisions

#### [2025-01-XX] **UNIFICATION DES DATASOURCES**
**Problème** : Trop de petits datasources spécialisés créaient de la fragmentation.

**Solution** : Unification en 2 datasources principaux :

1. **`HorairesDatasourceLocal`** - Gère TOUS les horaires :
   - ✅ Horaires cantine (ouverture/fermeture)
   - ✅ Heures disponibles salles (8h-19h)
   - ✅ Réservations salles
   - ✅ Configuration globale horaires
   - ✅ Statut en temps réel

2. **`EvenementsDatasourceLocal`** - Gère TOUS les événements :
   - ✅ Événements associations
   - ✅ Événements accueil
   - ✅ Actualités associations
   - ✅ Recherche/filtrage unifié
   - ✅ Statistiques globales

**Bénéfices** :
- 🎯 **Centralisation** : Une seule source par domaine
- 🔄 **Réutilisabilité** : Méthodes communes accessibles
- 🧹 **Simplification** : Moins de fichiers à maintenir
- 📊 **Cohérence** : Logique unifiée pour données similaires

**Fichiers supprimés** :
- ❌ `horaires_cantine_datasource_local.dart`
- ❌ `heures_disponibles_datasource_local.dart`  
- ❌ `actualites_accueil_datasource_local.dart`
- ❌ `evenements_associations_datasource_local.dart`

**Fichiers mis à jour** :
- 🔄 `admin_gestion_cantine_ecran.dart` - Utilise `HorairesDatasourceLocal`

#### [2025-01-XX] Architecture Actualités Complète
- **Entité** : `Actualite` avec priorités, tags, épinglage
- **Repository** : Interface complète avec recherche et filtrage
- **Datasource** : 8 actualités simulées avec métadonnées riches
- **UI** : Intégration dans accueil avec badges URGENT

#### [2025-01-XX] Système Utilisateurs et Administration
- **Entité** : `Utilisateur` avec types (admin, modérateur, étudiant)
- **Privilèges** : Système de privilèges granulaires
- **Authentication** : Connexion avec redirection basée sur rôle
- **Admin Dashboard** : Interface complète pour administrateurs

#### [2025-01-XX] Optimisation UI avec Widgets Existants
- **Réutilisation** : `WidgetSectionStatistiques`, `WidgetCollection`, `WidgetCarte`
- **Cohérence** : UI uniforme à travers l'application
- **Performance** : Éviter la duplication de code UI

### 🎯 TODOs et Assumptions

#### Architecture
- [ ] **API Integration** : Remplacer datasources locaux par API REST
- [ ] **State Management** : Intégrer BLoC ou Provider pour état global
- [ ] **Database** : Implémenter persistance locale (SQLite)
- [ ] **Testing** : Tests unitaires pour chaque couche
- [ ] **Error Handling** : Gestion d'erreurs uniforme
- [ ] **Caching** : Système de cache intelligent

#### Données
- [x] **Simulation Complete** : Toutes les entités ont des données de test
- [ ] **Validation** : Validation des données d'entrée
- [ ] **Pagination** : Support pagination pour grandes listes
- [ ] **Sync** : Synchronisation données locales/serveur

#### UI/UX
- [x] **Theme Unifié** : Respect couleurs UQAR partout
- [x] **Widgets Réutilisables** : Composants standardisés
- [ ] **Responsive** : Adaptation mobile/tablette
- [ ] **Accessibility** : Support accessibilité

#### Sécurité
- [ ] **Authentication** : JWT ou OAuth
- [ ] **Authorization** : Vérification permissions côté serveur  
- [ ] **Encryption** : Chiffrement données sensibles

### 📊 Project Statistics
- **Total Files**: 50+ fichiers dans `lib/`
- **Entities**: 6 entités principales
- **Repositories**: 6 interfaces + implémentations
- **Screens**: 15+ écrans fonctionnels
- **Widgets**: 8+ widgets réutilisables
- **Datasources**: 8+ sources de données simulées

### 🚀 Next Steps Priority
1. **Tests** : Implémenter tests unitaires/intégration
2. **API** : Connecter à un backend réel
3. **Performance** : Optimiser chargement et navigation
4. **Deploy** : Configuration CI/CD et déploiement 