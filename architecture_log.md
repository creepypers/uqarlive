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

## Fichiers ajoutés
- `lib/domain/`
- `lib/data/`
- `lib/presentation/`
- `lib/core/theme/app_theme.dart`
- `architecture_log.md`
- `uqar_ui_log.md`
- `lib/presentation/screens/connexion_ecran.dart`

## Fichiers modifiés
- `lib/main.dart` - Refactorisation pour Clean Architecture et thème UQAR
- `lib/presentation/screens/ecran_chargement.dart`

## Décisions de conception
- Respect strict de la séparation des couches.
- Utilisation de noms de variables et fonctions en français.
- Centralisation du thème dans `app_theme.dart`.
- L'écran de connexion est défini comme page d'accueil de l'application.
- Utilisation d'un dégradé violet/bleu pour correspondre au design fourni.
- Validation des champs avec messages d'erreur en français.

## TODOs
- [ ] Compléter les entités et repositories du domaine.
- [ ] Implémenter les datasources et modèles.
- [ ] Créer les écrans de connexion et d'inscription.
- [ ] Ajouter la gestion d'état (bloc/provider).

## Hypothèses
- L'application cible la charte graphique UQAR.
- Les noms de variables et fonctions seront en français.
- L'application s'appelle "UqarLive" (pas "UqarLife").

## Résumé des actions accomplies
✅ Structure Clean Architecture créée
✅ Thème UQAR centralisé dans app_theme.dart
✅ Écran de connexion implémenté avec design fidèle à l'image
✅ Noms de variables et fonctions en français
✅ Code formaté et analysé sans erreurs
✅ Logs d'architecture et UI créés et maintenus

## Prochaines étapes recommandées
1. Créer l'écran d'inscription (inscription_ecran.dart)
2. Implémenter les entités utilisateur dans domain/entities/
3. Créer les repositories abstraits dans domain/repositories/
4. Implémenter les datasources et repositories dans data/
5. Ajouter la gestion d'état (bloc/provider)
6. Tester l'application sur émulateur/appareil
- **[2025-07-05 12:25]** Ajout du logo et écran de chargement :
  - Logo UqarLive avec icône école et texte "UQAR"
  - Écran de chargement avec fond noir et animation
  - Navigation automatique vers l'écran de connexion
  - Nom "UqarLive" affiché sur l'écran de connexion 