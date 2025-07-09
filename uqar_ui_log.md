# 📋 UqarLive - Journal des modifications UI

## 🎯 Suivi des écrans et composants

### ✅ Écrans créés/modifiés :
- [x] Écran de connexion (`connexion_ecran.dart`)
- [x] Écran d'inscription (`inscription_ecran.dart`)
- [x] Écran de chargement (`ecran_chargement.dart`)
- [x] **Écran d'accueil (`accueil_ecran.dart`)** - NOUVEAU
- [x] **Écran marketplace (`marketplace_ecran.dart`)** - NOUVEAU
- [x] **Écran échange de livres (`marketplace_ecran.dart`)** - SPÉCIALISÉ

### 🎨 Composants thématiques :
- [x] Thème UQAR (`app_theme.dart`)
- [x] Couleurs officielles UQAR
- [x] Styles de texte cohérents
- [x] Décorations pour formulaires
- [x] AppBar personnalisé avec bienvenue utilisateur
- [x] Widget météo intégré à l'AppBar
- [x] Navbar avec focus renforcé sur Accueil
- [x] **Filtres marketplace avec chips et dropdowns**
- [x] **Grille responsive d'items marketplace**
- [x] **Statistiques avec compteurs visuels**
- [x] **Cartes items avec badges d'état**
- [x] **Entité Livre pour échange universitaire**
- [x] **Filtres spécialisés : matière, année, état du livre**
- [x] **Cartes livres avec auteur, cours, badge échange**

---

## 📅 Historique des modifications

### **2024-01-XX - 20:45 - Correction overflow cartes de livres**
**Action** : Résolution du problème d'overflow de 17 pixels dans l'affichage des livres de mathématiques
**Détails** : 
- **Ratio d'aspect** : Augmenté de 0.75 à 0.8 pour plus de hauteur dans les cartes
- **Paddings optimisés** : Réduit de 12px à 10px pour économiser l'espace
- **Tailles de police** : Légèrement réduites (13→12px, 11→10px, 10→9px)
- **Espacements** : Réduit entre textes de 4px à 3px
- **MainAxisSize** : Ajouté `MainAxisSize.min` pour éviter l'overflow vertical
- **Overflow protection** : Ajouté `maxLines` et `overflow` sur tous les textes
- **Layout horizontal** : Ajouté `Flexible` sur le nom du propriétaire

**Problème résolu** :
- **Bottom overflow** de 17 pixels dans les cartes de livres
- **Titres longs** de mathématiques ("Calcul Différentiel et Intégral") s'affichent correctement
- **Affichage responsive** pour tous les types de livres

**Optimisations UI** :
- **Meilleure utilisation de l'espace** avec ratio d'aspect optimisé
- **Textes adaptés** aux contraintes de taille des cartes
- **Protection overflow** complète (vertical et horizontal)

### **2024-01-XX - 20:30 - Migration vers Clean Architecture pour les livres**
**Action** : Déplacement des données des livres vers la couche data selon Clean Architecture
**Détails** : 
- **Datasource local** : Création `livres_datasource_local.dart` avec 10 livres universitaires
- **Modèle Livre** : Création `livre_model.dart` avec conversions Map/Entity
- **Repository abstrait** : Création `livres_repository.dart` avec toutes les méthodes nécessaires
- **Repository implémenté** : Création `livres_repository_impl.dart` avec logique métier
- **Marketplace migré** : Suppression des données hardcodées de la couche présentation
- **Gestion d'état** : Ajout du chargement et de la gestion d'erreurs

**Architecture Clean** :
- **Domain** : Entité Livre + Repository abstrait (pas de dépendances externes)
- **Data** : Datasource + Modèle + Repository implémenté (dépend de domain)
- **Presentation** : Marketplace utilise le repository (dépend de domain)

**Fonctionnalités ajoutées** :
- **Chargement async** : Indicateur de chargement pendant récupération des données
- **Gestion d'erreurs** : Try/catch avec messages d'erreur
- **État vide** : Affichage "Aucun livre trouvé" quand filtres ne retournent rien
- **Filtrage dynamique** : Recharge automatique des données à chaque changement de filtre

**Données enrichies** :
- **Métadonnées complètes** : ISBN, édition, description pour chaque livre
- **Dates d'ajout** : Suivi temporel des livres ajoutés
- **Mots-clés** : Système de tags pour recherche avancée
- **Cours associés** : Codes de cours universitaires (MAT-1000, PHY-1001, etc.)

**Suppression** :
- Méthodes `_obtenirTousLesLivres()`, `_obtenirLivresFiltres()` du marketplace
- Données hardcodées dans la couche présentation
- Logique de filtrage dans l'UI (déplacée vers repository)

### **2024-01-XX - 20:00 - Spécialisation marketplace → échange de livres universitaires**
**Action** : Transformation complète du marketplace générique en plateforme d'échange de livres
**Détails** : 
- **Entité Livre** : Création `lib/domain/entities/livre.dart` avec propriétés universitaires
- **AppBar spécialisée** : "Échange de Livres - Livres Universitaires" 
- **Filtres adaptés** : Matières (Math, Physique, Chimie, etc.) + Année d'étude + État livre
- **Statistiques ciblées** : 127 livres disponibles, 68 échanges, 45 étudiants actifs
- **Navigation** : "Marketplace" → "Livres" avec icône `menu_book`

**Entité Livre** :
- Propriétés : `titre`, `auteur`, `matiere`, `anneeEtude`, `etatLivre`, `proprietaire`
- Métadonnées : `isbn`, `edition`, `coursAssocies`, `description`, `motsClefs`
- Gestion : `dateAjout`, `estDisponible`, `imageUrl`

**Filtres spécialisés** :
- **Matières** : 11 matières universitaires (Math, Physique, Chimie, Bio, Info, Génie, Éco, Droit, Lettres, Histoire)
- **Années d'étude** : 1ère, 2ème, 3ème année, Maîtrise, Doctorat
- **État du livre** : Excellent, Très bon, Bon, Acceptable

**Cartes livres** :
- **Design** : Badge "ÉCHANGE" vert permanent, badge d'état coloré
- **Contenu** : Titre, auteur, matière, propriétaire, année d'étude
- **Cours** : Code de cours associé (ex: MAT-1000, PHY-1001)
- **Icône** : `menu_book` uniforme pour tous les livres

**Livres disponibles** :
- Calcul Différentiel (Stewart) - Math 1ère
- Physique Générale (Serway) - Physique 1ère
- Chimie Organique (Clayden) - Chimie 2ème
- Programmation Java (Deitel) - Info 2ème
- Économie (Varian) - Éco 2ème
- Biologie Moléculaire (Watson) - Bio 3ème
- Résistance Matériaux (Beer) - Génie 2ème
- Histoire Québec (Lacoursière) - Histoire 1ère
- Droit Constitutionnel (Brun) - Droit 1ère
- Littérature Française (Lagarde) - Lettres 1ère

**Suppression** :
- Toutes les catégories non-livres (Électronique, Vêtements, Sport, etc.)
- Système de prix/vente (100% échange)
- Badges prix remplacés par badges échange

### **2024-01-XX - 19:30 - Création page marketplace complète**
**Action** : Développement de la page marketplace avec filtres et grille d'items
**Détails** : 
- **AppBar personnalisée** : "Marketplace - Livres & Échanges" avec bouton recherche
- **Section filtres** : Chips catégories + dropdowns état/prix
- **Statistiques** : Compteurs articles disponibles, échanges, vendeurs actifs
- **Grille responsive** : 2 colonnes avec 8 items variés (livres, électronique, vêtements, etc.)
- **Navigation fonctionnelle** : Depuis accueil vers marketplace et retour

**Fonctionnalités** :
- **Filtrage dynamique** : Par catégorie (Tous, Livres, Électronique, Vêtements, Fournitures, Sport)
- **Filtres avancés** : État (Neuf, Très bon, Bon, Acceptable) et Prix
- **Badges visuels** : Couleurs selon état, badges "Échange" vs prix
- **Cartes items** : Images d'icônes, prix, vendeur, état avec design cohérent UQAR

**Items marketplace** :
- Physique Université (45€), MacBook Pro (800€), Calculatrice (Échange)
- Manteau North Face (120€), Notes Math (15€), Raquette Tennis (35€)
- Sac à dos (25€), Chimie Organique (Échange)

**Navigation mise à jour** :
- Accueil → Marketplace (push/replace)
- Bouton "Voir tout" marketplace fonctionnel
- NavBar avec focus marketplace + icône personnalisée

### **2024-01-XX - 19:20 - Simplification AppBar avec bienvenue utilisateur**
**Action** : Suppression des boutons AppBar + ajout section bienvenue avec température
**Détails** : 
- **Suppression totale** : Tous les boutons d'action (marketplace, bibliothèque, cantine, associations, profil)
- **Section bienvenue** : Message personnalisé "Bienvenue [Nom Utilisateur]"
- **Température intégrée** : Widget météo compact (-5°C Rimouski) avec icône neige
- **Hauteur AppBar** : Augmentée à 80px pour accommoder le nouveau contenu
- **Design épuré** : Interface plus clean, navigation via navbar uniquement

**Nouvelle structure AppBar** :
- Gauche : "Bienvenue" + nom utilisateur (Marie Dubois)
- Droite : Température avec fond semi-transparent et icône météo
- Style : Bordures arrondies conservées, fond bleu UQAR

**Code supprimé** :
- Fonction `_construireSectionMeteo()` (météo déplacée dans AppBar)
- Section météo du body principal
- Tous les IconButton et actions de l'AppBar

### **2024-01-XX - 19:15 - Focus renforcé sur le bouton Accueil**
**Action** : Amélioration visuelle du bouton Accueil pour le mettre davantage en évidence
**Détails** : 
- **Icône personnalisée** : Création de `_construireIconeAccueil()` avec effet de halo
- **Halo de focus** : Cercle blanc semi-transparent (35px) quand sélectionné
- **Taille dynamique** : Icône plus grande quand sélectionnée (26px vs 24px)
- **Styles de texte** : Labels avec ombre et tailles différenciées
- **Typographie** : Bold + ombre pour sélectionné, medium pour non-sélectionné

**Effets visuels** :
- Halo blanc `alpha: 0.2` autour de l'icône Accueil active
- Ombre portée sur les labels sélectionnés
- Transition de taille d'icône pour retour visuel

### **2024-01-XX - 19:10 - Échange position Accueil et Cantine dans navbar**
**Action** : Modification de l'ordre des boutons dans la navigation inférieure
**Détails** : 
- **Ancien ordre** : Accueil, Marketplace, Cantine, Assos, Profil
- **Nouvel ordre** : Cantine, Marketplace, Accueil, Assos, Profil
- **Index sélectionné** : Mise à jour de 0 → 2 (Accueil maintenant en 3ème position)
- **Navigation** : Ajustement de la fonction `_gererNavigationNavBar` selon nouveaux index

**Changements techniques** :
- BottomNavigationBarItem échangés (positions 0 ↔ 2)
- `_indexSelectionne` mis à jour pour rester sur Accueil
- Logique de navigation ajustée pour nouveaux index

### **2024-01-XX - 19:05 - Application couleurs UQAR sur page inscription**
**Action** : Extension des couleurs UQAR à la page d'inscription
**Détails** : 
- **Dégradé inscription** : Remplacement violet par dégradé bleu UQAR
  - Ancien : Violet clair → Violet moyen → Bleu UQAR
  - Nouveau : Bleu ciel transparent → Bleu ciel → Bleu foncé UQAR
- **Commentaire design** : Mise à jour "violet/bleu" → "bleu UQAR"
- **Cohérence totale** : Toutes les pages utilisent maintenant les couleurs officielles

**Résultat** : Application 100% conforme à l'identité visuelle UQAR

### **2024-01-XX - 19:00 - Application couleurs UQAR et AppBar roundy**
**Action** : Correction nom app + AppBar arrondi + respect couleurs UQAR
**Détails** : 
- **Nom application** : "UqarLife" → "UqarLive" (correction)
- **AppBar roundy** : Ajout `RoundedRectangleBorder` avec bordures 25px en bas
- **Couleurs UQAR** : Remplacement dégradé violet par dégradé bleu UQAR
  - Ancien : Violet clair → Violet moyen → Bleu UQAR
  - Nouveau : Bleu ciel transparent → Bleu ciel → Bleu foncé UQAR
- **Cohérence** : Même dégradé sur page connexion et navbar accueil

**Changements appliqués** :
- AppBar avec `borderRadius: 25px` (bas)
- Dégradé 100% couleurs officielles UQAR (#00A1E4 → #005499)
- Identité visuelle cohérente sur toute l'application

### **2024-01-XX - 18:45 - Correction overflow section cantine**
**Problème** : RenderFlex overflow de 15 pixels sur les cartes menu cantine
**Solution** : Augmentation de la hauteur de la section cantine de 200px → 220px
**Détails** : 
- Calcul du contenu total : icône (80px) + padding (32px) + textes (~108px) = ~220px
- Correction immédiate de l'overflow sans affecter la mise en page
- Cartes menu maintenant parfaitement ajustées

### **2024-01-XX - 18:30 - Création page d'accueil complète**
**Action** : Implémentation de la page d'accueil UqarLife avec toutes les fonctionnalités demandées
**Détails** : 
- **AppBar UQAR** : 4 icônes (marketplace, bibliothèque, cantine, associations) + profil circulaire
- **Section Météo** : Dégradé UQAR avec infos météo Rimouski (-5°C, neigeux)
- **Marketplace** : Scrolling horizontal avec 5 items (livres, calculatrice, notes, laptop, sac)
- **Associations** : Scrolling horizontal avec 4 associations et nombres de membres
- **Cantine** : Scrolling horizontal avec 3 menus, prix et disponibilité
- **NavBar** : Même dégradé que page connexion avec 5 onglets
- **Navigation** : Connexion redirige maintenant vers l'accueil

**Composants créés** :
- AppBar avec icônes thématiques et profil
- Cartes marketplace avec images d'icônes et prix
- Cartes associations avec indicateurs de couleur
- Cartes menus avec statut disponibilité
- NavBar avec dégradé violet/bleu cohérent

### **2024-01-XX - 17:00 - Application background divisé à l'inscription**
**Action** : Même structure de background pour l'écran d'inscription
**Détails** : 
- Background divisé en 2 parties : 2/3 dégradé, 1/3 blanc
- Architecture `Stack` avec background `Column` et contenu superposé
- Cohérence visuelle avec l'écran de connexion
- Formulaire paginé s'adapte au nouveau background

**Proportions** : 
- Dégradé : `flex: 2` (≈ 67% de l'écran)
- Blanc : `flex: 1` (≈ 33% de l'écran)

### **2024-01-XX - 16:55 - Ajustement proportions dégradé connexion**
**Action** : Dégradé occupe 2/3 du background, blanc 1/3
**Détails** : 
- Changement des proportions : dégradé `flex: 2`, blanc `flex: 1`
- Plus d'impact visuel pour l'identité UQAR
- Proportion 2/3 - 1/3 plus équilibrée

### **2024-01-XX - 16:50 - Background divisé en 2 parties**
**Action** : Division explicite du background en 2 zones
**Détails** : 
- Architecture `Stack` avec background `Column`
- Partie supérieure : dégradé violet/bleu UQAR
- Partie inférieure : blanc
- Contenu superposé par-dessus le background

### **2024-01-XX - 16:45 - Correction bande bleue en bas**
**Problème** : Le dégradé bleu était visible en bas de l'écran sous le formulaire
**Solution** : 
- Modifié l'architecture de `Stack` vers `Column` avec sections `Expanded`
- Limité le dégradé à la section supérieure uniquement (flex: 2)
- Changé le fond du Scaffold vers `CouleursApp.blanc`
- Supprimé le padding du bas du formulaire

**Résultat** : Le dégradé reste dans la partie logo, le formulaire blanc couvre entièrement le bas

### **2024-01-XX - 16:30 - Architecture finale fusion sur dégradé**
**Changement** : Retour à l'architecture `Stack` avec effet de fusion
**Détails** : 
- Dégradé full-screen en arrière-plan
- Formulaire superposé avec `margin: EdgeInsets.only(top: 30)`
- Bordures arrondies (50px) qui se fondent sur le dégradé
- Effet "flottant" avec ombre douce

### **2024-01-XX - 16:15 - Augmentation bordures arrondies**
**Changement** : Bordures de 30px → 50px pour plus d'effet "roundy"
**Détails** : 
- Changement couleur fond formulaire (`CouleursApp.fond` → `CouleursApp.blanc`)
- Ajout d'une ombre (`boxShadow`) avec offset négatif
- Bordures plus visibles grâce au contraste blanc/dégradé

### **2024-01-XX - 16:00 - Extension dégradé jusqu'en haut**
**Changement** : Élimination de la zone blanche en haut
**Détails** : 
- Déplacement du `SafeArea` à l'intérieur du conteneur dégradé
- Configuration `SafeArea(bottom: false)` pour respecter la barre de statut
- Dégradé s'étend maintenant jusqu'en haut de l'écran

### **2024-01-XX - 15:45 - Ajustement proportions**
**Changement** : Modification des ratios flex pour plus d'espace aux formulaires
**Détails** : 
- Logo : `flex: 2` (~29% de l'écran)
- Formulaire : `flex: 5` (~71% de l'écran)
- Formulaires prennent maintenant toute la partie du bas

### **2024-01-XX - 15:30 - Problème superposition résolu**
**Changement** : Architecture `Column` → `Stack` pour superposition
**Détails** : 
- Formulaire maintenant superposé sur le dégradé
- Effet "carte flottante" avec bordures arrondies
- Plus de carte séparée, fusion directe avec le dégradé

### **2024-01-XX - 15:15 - Repositionnement bordures arrondies**
**Changement** : Déplacement des bordures du dégradé vers les formulaires
**Détails** : 
- Suppression des `borderRadius` du conteneur dégradé
- Application des bordures arrondies (30px) aux conteneurs de formulaires
- Effet plus propre et cohérent

### **2024-01-XX - 15:00 - Suppression zone blanche en haut**
**Changement** : Élimination du `SafeArea` global
**Détails** : 
- Suppression du `SafeArea` qui causait la zone blanche
- Repositionnement pour que le dégradé s'étende jusqu'en haut
- Dégradé maintenant full-screen

### **2024-01-XX - 14:45 - Écran d'inscription paginé**
**Fonctionnalité** : Formulaire d'inscription en 2 pages
**Détails** : 
- Page 1 : Informations personnelles (nom, prénom, email, téléphone)
- Page 2 : Création du compte (nom d'utilisateur, mot de passe, confirmation)
- Navigation fluide entre les pages avec validation

### **2024-01-XX - 14:30 - Écran de connexion UQAR**
**Fonctionnalité** : Écran de connexion avec thème UQAR
**Détails** : 
- Dégradé violet → bleu UQAR en arrière-plan
- Logo UQAR stylisé avec icône école
- Formulaire simple (nom d'utilisateur, mot de passe)
- Illustrations de feuilles stylisées en arrière-plan

### **2024-01-XX - 14:15 - Thème UQAR implémenté**
**Fonctionnalité** : Création du thème officiel UQAR
**Détails** : 
- Couleurs : #005499 (principal), #00A1E4 (accent), #F8F9FA (fond)
- Dégradé personnalisé : Violet clair → Violet moyen → Bleu UQAR
- Styles de texte cohérents
- Décorations pour boutons et champs

---

## 🎨 Décisions de design

### **Palette de couleurs UQAR** :
- **Principal** : `#005499` (bleu foncé UQAR)
- **Accent** : `#00A1E4` (bleu clair UQAR)  
- **Fond** : `#F8F9FA` (gris très clair)
- **Texte** : `#2C2C2C` (gris foncé)

### **Dégradé UQAR** :
- **Début** : `#00A1E4` avec transparence (bleu ciel UQAR)
- **Milieu** : `#00A1E4` (bleu ciel UQAR)
- **Fin** : `#005499` (bleu foncé UQAR)

### **Architecture background (Version actuelle)** :
- **Dégradé** : 2/3 de l'écran (≈ 67%)
- **Blanc** : 1/3 de l'écran (≈ 33%)
- **Structure** : Stack avec background Column et contenu superposé

### **Bordures et espacements** :
- **Formulaires** : 50px de rayon (effet "roundy")
- **Champs** : 20px de rayon
- **Padding** : 32px pour les conteneurs
- **Marges** : 30px pour l'effet de fusion

### **Composants réutilisables** :
- Logo UQAR stylisé avec icône école
- Champs de texte avec validation
- Boutons avec style UQAR
- Illustrations de feuilles pour la décoration

---

## 📝 TODO

- [ ] Ajouter animations de transition
- [ ] Implémenter la logique de connexion
- [ ] Ajouter gestion d'erreurs
- [ ] Tests d'accessibilité
- [ ] Optimisation des performances 

## 📅 15 Janvier 2025 - Session 4: Refactorisation NavBar

### ✅ Refactorisation architecture
- **NavBar Widget Réutilisable** (`navbar_widget.dart`)
- **Service Navigation Centralisé** (`navigation_service.dart`)

### 🏗️ Architecture améliorée
- **Composant NavBar réutilisable**: Extraction du code dupliqué en widget séparé
- **Service navigation centralisé**: Logique de navigation unifiée pour toute l'app
- **Suppression duplication**: Élimination de +150 lignes de code dupliqué
- **Maintenabilité améliorée**: Un seul endroit pour modifier la NavBar

### 🎨 Composants créés/mis à jour

#### NavBar Widget (`navbar_widget.dart`)
- **Widget réutilisable**: Accepte `indexSelectionne` et `onTap` callback
- **Design UQAR cohérent**: Gradient, couleurs et styles uniformes
- **Icône Accueil spéciale**: Halo de focus conservé pour l'accueil
- **5 onglets**: Cantine, Livres, Accueil, Assos, Profil

#### Service Navigation (`navigation_service.dart`)
- **Navigation centralisée**: Méthode `gererNavigationNavBar()` unique
- **Gestion intelligente**: Évite navigation vers page courante
- **Feedback utilisateur**: SnackBar pour pages non implémentées (Assos, Profil)
- **Navigation cohérente**: `pushReplacement` pour éviter accumulation de routes
- **Index automatique**: Détection automatique de la page courante

#### Pages mises à jour
- **Page d'Accueil**: Suppression de 80+ lignes de code NavBar dupliqué
- **Marketplace**: Suppression de 80+ lignes de code NavBar dupliqué  
- **Cantine**: Suppression de 80+ lignes de code NavBar dupliqué
- **Variables obsolètes**: Suppression `_indexSelectionne` dans toutes les pages

### 🔧 Améliorations techniques
- ✅ **DRY Principle**: Don't Repeat Yourself - code NavBar centralisé
- ✅ **Single Responsibility**: Chaque widget a une responsabilité claire
- ✅ **Maintenabilité**: Modifications NavBar à un seul endroit
- ✅ **Consistance**: Design et comportement identiques partout
- ✅ **Performance**: Moins de code dupliqué = app plus légère
- ✅ **Extensibilité**: Ajout facile de nouvelles pages

### 📊 Métriques d'amélioration
- **-240 lignes** : Code dupliqué supprimé
- **+1 widget** : Composant réutilisable NavBar
- **+1 service** : Navigation centralisée
- **100%** : Couverture navigation entre pages principales
- **0** : Duplication de logique NavBar

---

## 📅 15 Janvier 2025 - Session 3: Page Cantine Complète

### ✅ Nouveaux écrans créés
- **Page Cantine** (`cantine_ecran.dart`)

### 🏗️ Architecture ajoutée
- **Entité Menu** (`menu.dart`): Entité complète pour les menus de cantine
- **Repository Menus** (`menus_repository.dart`): Interface pour gestion des menus
- **Datasource Menus** (`menus_datasource_local.dart`): 12 menus réalistes avec données complètes
- **Modèle Menu** (`menu_model.dart`): Conversion Map/entité
- **Repository Implementation** (`menus_repository_impl.dart`): Implémentation Clean Architecture

### 🎨 Composants créés/mis à jour

#### Page Cantine (`cantine_ecran.dart`)
- **AppBar**: Avec titre, retour et actions (filtre végétarien, recherche)
- **Section Infos**: Horaires, places, paiement, WiFi avec design moderne
- **Menus du Jour**: Scroll horizontal avec cartes spéciales gradient
- **Menus Populaires**: Section avec notes et badges spéciaux
- **Filtres Catégories**: Chips sélectionnables (menus, plats, snacks, desserts, boissons)
- **Grille Menus**: GridView responsive avec cartes détaillées
- **Navigation**: NavBar cohérent et retour vers accueil

#### Navigation mise à jour
- **Page d'Accueil**: Import et navigation vers `CantineEcran`
- **Bouton cantine**: Navigation fonctionnelle depuis l'accueil

### 🎯 Features cantine
- **12 menus réalistes**: Menus étudiant, végétarien, express, plats, snacks, desserts, boissons
- **Données complètes**: Prix, ingrédients, allergènes, calories, notes, badges
- **Filtrage intelligent**: Par catégorie, végétarien/vegan, disponibilité
- **Badges dynamiques**: VEGAN, VÉGÉ, ÉPUISÉ, POPULAIRE avec couleurs appropriées
- **Design responsive**: GridView adaptable et protection overflow
- **Clean Architecture**: Repository pattern avec datasource local

### 🎨 Design Patterns utilisés
- **Cards sectionnées**: Infos, menus du jour, populaires, grille standard
- **Gradient containers**: Section infos et menus du jour avec dégradés UQAR
- **Badges intelligents**: Système automatique selon propriétés du menu
- **Icônes catégories**: Mapping icônes spécifiques par type de menu
- **Scroll horizontal**: Pour menus du jour et populaires
- **Filtres visuels**: Toggle végétarien avec feedback visuel

### 🔧 Fonctionnalités implémentées
- ✅ **Navigation complète**: Depuis accueil vers cantine fonctionnelle
- ✅ **Filtrage avancé**: Catégories + filtre végétarien
- ✅ **Données riches**: 12 menus avec infos nutritionnelles
- ✅ **UI responsive**: GridView + protection overflow
- ✅ **Clean Architecture**: Séparation couches et testabilité
- ✅ **Design cohérent**: 100% UQAR theme et navigation

---

## 📅 15 Janvier 2025 - Session 2: Page Détails Livre

### ✅ Nouveaux écrans créés
- **Page Détails Livre** (`details_livre_ecran.dart`)

### 🏗️ Architecture améliorée
- **Entité Livre** (`livre.dart`): Ajout du getter `codeCours` (alias pour `coursAssocies`)

### 🎨 Composants créés/mis à jour

#### Page Détails Livre (`details_livre_ecran.dart`)
- **SliverAppBar**: Avec image livre placeholder et actions (retour, favoris)
- **Informations Principales**: Titre, auteur, matière et année avec chips stylisés
- **Informations Académiques**: Matière, année d'études, état du livre, code de cours
- **Informations Propriétaire**: Avatar, nom, rating et bouton message
- **Description**: Section conditionnelle pour description détaillée
- **Informations Techniques**: ISBN et édition si disponibles
- **Bouton Échange**: Bouton principal vert pour proposer un échange
- **Navigation**: GestureDetector sur cartes de livre (marketplace + accueil)

#### Marketplace & Accueil (mise à jour)
- **Navigation ajoutée**: Tap sur carte → Détails livre
- **Import**: Ajout de `details_livre_ecran.dart`
- **GestureDetector**: Enveloppe les cartes pour la navigation

### 🎯 Design Patterns utilisés
- **SliverAppBar**: Pour scroll naturel avec header image
- **Chips**: Badges matière/année avec couleurs UQAR
- **Cards sectionnées**: Informations groupées logiquement
- **Avatar circulaire**: Propriétaire avec initiales
- **Boutons d'action**: Message et échange bien visibles
- **Consistent theming**: Réutilisation complète theme UQAR

### 🔧 Fonctionnalités implémentées
- ✅ **Navigation fluide**: Tap carte → Détails complets
- ✅ **Affichage conditionnel**: Description et ISBN si disponibles
- ✅ **Actions utilisateur**: Favoris, message, proposer échange
- ✅ **Feedback visuel**: SnackBar pour confirmations actions
- ✅ **Protection overflow**: Layout responsive et ellipsis
- ✅ **Getter codeCours**: Accès simplifié aux codes de cours (MAT-1000, PHY-1001, etc.)

---

## 📅 15 Janvier 2025 - Session 1: Configuration Clean Architecture et Marketplace

### ✅ Écrans mis à jour
- **Marketplace** → **Échange de Livres**
- **Page d'Accueil** → **Intégration Clean Architecture**

### 🏗️ Architecture créée
- `lib/domain/entities/livre.dart` - Entité Livre
- `lib/domain/repositories/livres_repository.dart` - Repository abstrait
- `lib/data/models/livre_model.dart` - Modèle de données
- `lib/data/datasources/livres_datasource_local.dart` - Source de données (avec codes cours universitaires)
- `lib/data/repositories/livres_repository_impl.dart` - Implémentation repository

### 🎨 Composants créés/réutilisés

#### Page d'Accueil (`accueil_ecran.dart`)
- **Section Échange de Livres**: Remplace la section marketplace générique
  - Utilise Clean Architecture avec repository
  - Affiche les livres réels avec métadonnées universitaires
  - Cards optimisées avec badges "ÉCHANGE"
  - Navigation cohérente vers marketplace
- **Section Associations**: Conservée avec styles UQAR
- **Section Cantine**: Optimisée contre l'overflow
  - Taille augmentée à 200px de hauteur
  - Textes réduits et Expanded widgets ajoutés
  - Maxlines adapté pour flexibilité
- **Navigation Bar**: 
  - Icône changée de `storefront` à `menu_book`
  - Label changé de "Marketplace" à "Livres"
  - Design gradient conservé

#### Marketplace (`marketplace_ecran.dart`)
- **Spécialisation Livres**: Transformation complète d'un marketplace générique
- **Données universitaires**: 10 livres avec métadonnées (ISBN, cours, éditions)
- **Filtres académiques**: 11 matières + années d'étude + états
- **Statistics**: 127 livres, 68 échanges, 45 étudiants actifs
- **Cards livres**: Badges permanents "ÉCHANGE", overflow fix

### 🎯 Décisions de thème
- **Couleurs UQAR**: Bleu principal `#005499`, accent `#00A1E4`, fond `#F8F9FA`
- **Typographie**: Réutilisation `StylesTexteApp` et `CouleursApp`
- **Composants**: Shadows, borders radius, gradient navbar conservés
- **Overflow protection**: Expanded, Flexible, maxLines systématiques

### 🔧 Problèmes résolus
- ✅ **Overflow 17px Math books**: Fix avec layout optimisé
- ✅ **Données hardcodées**: Migration vers Clean Architecture
- ✅ **Navigation incohérente**: Mise à jour Marketplace → Livres
- ✅ **Manque badges échange**: Ajout systematic "ÉCHANGE"

### 📋 TODOs Architecture
- [ ] Créer les cas d'usage (use cases) dans `domain/usecases/`
- [ ] Ajouter injection de dépendances (GetIt/Provider)
- [ ] Implémenter la persistence locale (Hive/SQLite)
- [ ] Ajouter API REST pour synchronisation serveur
- [ ] Tests unitaires pour chaque couche

### 📋 TODOs UI
- [x] **Créer écrans détail livre** ✅ Complété
- [x] **Ajouter getter codeCours** ✅ Complété
- [x] **Créer page cantine complète** ✅ Complété
- [x] **Refactoriser NavBar réutilisable** ✅ Complété
- [ ] Implémenter filtres avancés
- [ ] Ajouter système notifications échanges
- [ ] Créer profil utilisateur
- [ ] Page associations et cantine dédiées 