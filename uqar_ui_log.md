# 📋 UqarLive - Journal des modifications UI

## 🎯 Suivi des écrans et composants

### ✅ Écrans créés/modifiés :
- [x] Écran de connexion (`connexion_ecran.dart`)
- [x] Écran d'inscription (`inscription_ecran.dart`)
- [x] Écran de chargement (`ecran_chargement.dart`)
- [x] **Écran d'accueil (`accueil_ecran.dart`)** - NOUVEAU
- [x] **Écran marketplace (`marketplace_ecran.dart`)** - NOUVEAU

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

---

## 📅 Historique des modifications

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