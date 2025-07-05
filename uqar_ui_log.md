# 📋 UqarLife - Journal des modifications UI

## 🎯 Suivi des écrans et composants

### ✅ Écrans créés/modifiés :
- [x] Écran de connexion (`connexion_ecran.dart`)
- [x] Écran d'inscription (`inscription_ecran.dart`)
- [x] Écran de chargement (`ecran_chargement.dart`)

### 🎨 Composants thématiques :
- [x] Thème UQAR (`app_theme.dart`)
- [x] Couleurs officielles UQAR
- [x] Styles de texte cohérents
- [x] Décorations pour formulaires

---

## 📅 Historique des modifications

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

### **Dégradé personnalisé** :
- **Début** : `#B794F6` (violet clair)
- **Milieu** : `#9F7AEA` (violet moyen)
- **Fin** : `#00A1E4` (bleu UQAR)

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