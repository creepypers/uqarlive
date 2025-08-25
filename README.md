# 🎓 UQAR Live - Application Mobile Étudiante

## 📱 Description

**UQAR Live** est une application mobile Flutter moderne et intuitive conçue pour la communauté étudiante de l'Université du Québec à Rimouski (UQAR). Elle centralise tous les services essentiels dont les étudiants ont besoin au quotidien.
link video presentation https://youtu.be/4MYa2c9ddGw
## ✨ Fonctionnalités Principales

### 🏠 **Accueil & Navigation**
- Dashboard personnalisé avec informations en temps réel
- Navigation intuitive entre toutes les sections
- Interface adaptative et responsive

### 📚 **Gestion des Livres**
- Marketplace d'échange et de vente de livres
- Gestion de votre bibliothèque personnelle
- Système de transactions sécurisé
- Recherche avancée par matière, année, état

### 🍽️ **Cantine & Menus**
- Consultation des menus du jour
- Horaires des repas
- Gestion des menus par l'administration

### 👥 **Associations Étudiantes**
- Découverte des associations UQAR
- Inscription aux événements
- Gestion des adhésions
- Actualités des associations

### 📅 **Événements & Actualités**
- Calendrier des événements étudiants
- Inscription aux activités
- Actualités en temps réel
- Système de notifications

### 💬 **Messagerie**
- Communication entre étudiants
- Gestion des contacts
- Conversations privées et de groupe

### 🏢 **Réservation de Salles**
- Réservation des salles d'étude
- Gestion des créneaux disponibles
- Système de validation

### 👤 **Profil Utilisateur**
- Gestion du profil étudiant
- Historique des activités
- Statistiques personnelles
- Authentification sécurisée

## 🛠️ Architecture Technique

### **Clean Architecture**
- **Domain Layer** : Entités et cas d'usage métier
- **Data Layer** : Sources de données et repositories
- **Presentation Layer** : Interface utilisateur et services

### **Technologies Utilisées**
- **Frontend** : Flutter 3.x
- **Langage** : Dart
- **État** : Gestion d'état native Flutter
- **Navigation** : Navigation personnalisée
- **Stockage** : Sources de données locales

### **Structure du Projet**
```
lib/
├── core/           # Configuration et utilitaires
├── data/           # Couche données
├── domain/         # Couche métier
└── presentation/   # Interface utilisateur
```

## 🚀 Installation & Configuration

### **Prérequis**
- Flutter SDK 3.x
- Dart SDK 3.x
- Android Studio / VS Code
- Émulateur Android ou appareil physique

### **Installation**
```bash
# Cloner le projet
git clone [URL_DU_REPO]
cd uqarlive

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

### **Configuration**
1. Assurez-vous que Flutter est correctement installé
2. Vérifiez la configuration avec `flutter doctor`
3. Lancez l'application sur votre appareil cible

## 👥 Comptes de Démonstration

### **Étudiants**
- **Alexandre Martin** : `alexandre.martin@uqar.ca` / `alex123`
- **Sophie Dubois** : `sophie.dubois@uqar.ca` / `sophie123`
- **Marc Tremblay** : `marc.tremblay@uqar.ca` / `marc123`

### **Administration**
- **Admin** : `admin@uqar.ca` / `admin123`
- **Modérateur** : `moderateur@uqar.ca` / `mod123`

## 🎨 Design & UX

### **Thème UQAR**
- Couleurs officielles : `#005499`, `#00A1E4`, `#F8F9FA`
- Interface moderne et épurée
- Design responsive et adaptatif
- Navigation intuitive

### **Composants Réutilisables**
- Widgets personnalisés pour la cohérence
- Système de cartes unifié
- Barres de navigation personnalisées
- Composants de statistiques

## 🔒 Sécurité & Authentification

- Système d'authentification sécurisé
- Gestion des sessions utilisateur
- Validation des permissions
- Protection des données personnelles

## 📊 Fonctionnalités Administratives

### **Gestion des Comptes**
- Création et modification de comptes
- Gestion des rôles et permissions
- Surveillance des activités

### **Gestion du Contenu**
- Administration des menus de cantine
- Gestion des associations
- Modération des actualités
- Supervision des événements

## 🧪 Tests & Qualité

### **Analyse du Code**
```bash
# Vérification de la qualité du code
flutter analyze

# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test/
```

### **Standards de Qualité**
- Code documenté et commenté
- Respect des conventions Flutter
- Architecture propre et maintenable
- Gestion d'erreurs robuste

## 📱 Compatibilité

- **Android** : API 21+ (Android 5.0+)
- **iOS** : iOS 11.0+
- **Responsive** : Adaptation automatique aux différentes tailles d'écran

## 🤝 Contribution

### **Guidelines de Développement**
1. Respecter l'architecture Clean Architecture
2. Suivre les conventions de nommage Dart/Flutter
3. Tester les nouvelles fonctionnalités
4. Documenter le code ajouté

### **Processus de Contribution**
1. Fork du projet
2. Création d'une branche feature
3. Développement et tests
4. Pull Request avec description détaillée


---

**UQAR Live** - Connecter, Partager, Vivre l'expérience étudiante UQAR ! 🎓✨
