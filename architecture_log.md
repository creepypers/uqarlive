# Architecture Log UqarLive

## Checklist des couches Clean Architecture
- [x] `lib/domain` (entités, repositories abstraits)
- [x] `lib/data` (datasources, modèles, repositories implémentés)
- [x] `lib/presentation` (UI, widgets, écrans, blocs)
- [x] `lib/core` (thème, utilitaires)

## Actions
- **[YYYY-MM-DD HH:MM]** Initialisation de la structure des dossiers Clean Architecture.
- **[YYYY-MM-DD HH:MM]** Création de ce fichier de log.
- **[2025-07-05 12:13]** Création effective des dossiers :
  - lib/domain/entities
  - lib/domain/repositories
  - lib/data/models
  - lib/data/repositories
  - lib/data/datasources
  - lib/presentation/widgets
  - lib/presentation/screens
  - lib/presentation/bloc
  - lib/core/theme
- **[2025-07-05 12:15]** Refactorisation de main.dart :
  - Suppression du code de démonstration Flutter par défaut
  - Intégration du thème UQAR centralisé
  - Configuration de l'écran de connexion comme page d'accueil
- **[2025-07-05 12:15]** Création de l'écran de connexion :
  - lib/presentation/screens/connexion_ecran.dart
  - Respect du design de l'image fournie
  - Utilisation des couleurs et styles UQAR
  - Noms de variables et fonctions en français
- **[2025-07-05 12:17]** Formatage du code avec dart format
- **[2025-07-05 12:17]** Analyse du code réussie sans erreurs
- **[2025-07-05 12:25]** Ajout du logo et écran de chargement :
  - Logo UqarLive avec icône école et texte "UQAR"
  - Écran de chargement avec fond noir et animation
  - Navigation automatique vers l'écran de connexion
  - Nom "UqarLive" affiché sur l'écran de connexion
- **[2025-07-05 12:30]** Création de l'écran d'inscription :
  - lib/presentation/screens/inscription_ecran.dart
  - Formulaire complet avec validation avancée
  - Navigation bidirectionnelle avec l'écran de connexion
  - Design cohérent avec l'écran de connexion
  - Validation email, longueur mots de passe, correspondance
- **[2025-07-05 12:35]** Amélioration de l'écran d'inscription :
  - Ajout des champs : Prénom, Nom, Code permanent
  - Validation du code permanent (format ABCD12345678)
  - Validation des noms (minimum 2 caractères)
  - Formulaire étendu avec 7 champs au total
- **[2025-07-05 12:40]** Résolution du problème d'overflow :
  - Division de l'écran d'inscription en 2 pages
  - Implémentation de PageView avec navigation fluide
  - Validation progressive par page
  - Indicateurs visuels de progression
  - Amélioration de l'UX avec aide contextuelle
- **[2025-07-05 12:45]** Configuration AppBar transparente :
  - Ajout d'AppBarTheme dans le thème global
  - AppBar transparente sur tous les écrans
  - Suppression de l'élévation et des ombres
  - Configuration du style de barre d'état
- **[2025-01-XX 20:00]** Création de l'entité Livre pour l'échange universitaire :
  - lib/domain/entities/livre.dart
  - Propriétés spécifiques aux livres universitaires
  - Métadonnées pour cours, ISBN, édition
  - Gestion disponibilité et date d'ajout
  - Méthodes copyWith, toString, equals, hashCode
  - Respect des principes Clean Architecture (couche domain)
- **[2025-01-XX 20:30]** Migration complète vers Clean Architecture pour les livres :
  - lib/data/datasources/livres_datasource_local.dart
  - lib/data/models/livre_model.dart
  - lib/domain/repositories/livres_repository.dart
  - lib/data/repositories/livres_repository_impl.dart
  - Migration du marketplace vers l'architecture Clean
  - Suppression des données hardcodées de la couche présentation
  - Ajout de la gestion d'état et du chargement
  - Filtrage dynamique via repository

## Fichiers ajoutés
- `lib/domain/`
- `lib/data/`
- `lib/presentation/`
- `lib/core/theme/app_theme.dart`
- `architecture_log.md`
- `uqar_ui_log.md`
- `lib/presentation/screens/connexion_ecran.dart`
- `lib/presentation/screens/ecran_chargement.dart`
- `lib/presentation/screens/inscription_ecran.dart`
- `lib/presentation/screens/accueil_ecran.dart`
- `lib/presentation/screens/marketplace_ecran.dart`
- `lib/domain/entities/livre.dart`
- `lib/data/datasources/livres_datasource_local.dart`
- `lib/data/models/livre_model.dart`
- `lib/domain/repositories/livres_repository.dart`
- `lib/data/repositories/livres_repository_impl.dart`

## Fichiers modifiés
- `lib/main.dart` - Refactorisation pour Clean Architecture et thème UQAR
- `lib/presentation/screens/connexion_ecran.dart` - Ajout du logo et nom UqarLive
- `lib/core/theme/app_theme.dart` - Correction de withOpacity deprecated
- `lib/presentation/screens/connexion_ecran.dart` - Navigation vers l'écran d'inscription
- `lib/main.dart` - Configuration AppBar transparente dans le thème global
- `lib/presentation/screens/marketplace_ecran.dart` - Spécialisation vers échange de livres

## Décisions de conception
- Respect strict de la séparation des couches.
- Utilisation de noms de variables et fonctions en français.
- Centralisation du thème dans `app_theme.dart`.
- L'écran de connexion est défini comme page d'accueil de l'application.
- Utilisation d'un dégradé violet/bleu pour correspondre au design fourni.
- Validation des champs avec messages d'erreur en français.
- **Spécialisation marketplace** : L'application se concentre uniquement sur l'échange de livres universitaires entre étudiants de l'UQAR.
- **Entité Livre** : Contient toutes les propriétés nécessaires pour gérer les livres universitaires (cours, matière, année, état, etc.).

## TODOs
- [ ] Compléter les entités et repositories du domaine.
- [ ] Implémenter les datasources et modèles.
- [ ] Créer les écrans de connexion et d'inscription.
- [ ] Ajouter la gestion d'état (bloc/provider).
- [x] Créer le repository abstrait pour les livres
- [x] Implémenter le datasource pour les livres
- [x] Ajouter la gestion d'état pour les livres (bloc/provider)
- [ ] Créer l'écran de détail d'un livre
- [ ] Implémenter la fonctionnalité de recherche de livres
- [ ] Ajouter la gestion des profils utilisateurs
- [ ] Créer l'écran de publication d'un livre
- [ ] Implémenter la persistance des données (base de données locale)
- [ ] Ajouter la synchronisation avec un backend

## Hypothèses
- L'application cible la charte graphique UQAR.
- Les noms de variables et fonctions seront en français.
- L'application s'appelle "UqarLive" (pas "UqarLife").
- **L'application est spécialisée uniquement dans l'échange de livres universitaires** (pas de vente, pas d'autres produits).

## Résumé des actions accomplies
✅ Structure Clean Architecture créée
✅ Thème UQAR centralisé dans app_theme.dart
✅ Écran de connexion implémenté avec design fidèle à l'image
✅ Noms de variables et fonctions en français
✅ Code formaté et analysé sans erreurs
✅ Logs d'architecture et UI créés et maintenus
✅ Écran d'inscription créé
✅ Écran d'inscription amélioré
✅ Problèmes résolus
✅ Configuration AppBar transparente
✅ Écran d'accueil créé avec navigation complète
✅ Marketplace créé puis spécialisé pour l'échange de livres
✅ Entité Livre créée dans la couche domain
✅ Migration complète vers Clean Architecture pour les livres

## Prochaines étapes recommandées
1. Créer le repository abstrait pour les livres dans domain/repositories/
2. Implémenter le datasource pour les livres dans data/datasources/
3. Créer le modèle Livre dans data/models/
4. Implémenter le repository des livres dans data/repositories/
5. Ajouter la gestion d'état (bloc/provider) pour les livres
6. Créer l'écran de détail d'un livre
7. Implémenter la fonctionnalité de recherche de livres
8. Ajouter la gestion des profils utilisateurs
9. Créer l'écran de publication d'un livre
10. Tester l'application sur émulateur/appareil 