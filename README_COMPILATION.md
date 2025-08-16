# 📚 Rapport Technique UqarLive - Guide de Compilation

## 🎯 Vue d'Ensemble

Ce dossier contient le rapport technique complet de l'application UqarLive, rédigé en LaTeX et organisé en plusieurs fichiers pour faciliter la maintenance et la compilation.

## 📁 Structure des Fichiers

```
rapport_technique_complet.tex          # Fichier principal (point d'entrée)
rapport_technique_uqarlive.tex         # Sections 1-3 : Vue d'ensemble, Identité visuelle, Architecture
rapport_technique_uqarlive_suite1.tex  # Sections 4-6 : Domain et Entités, Cas d'Usage, Repositories et Services
rapport_technique_uqarlive_suite2.tex  # Sections 7-9 : Écrans et Widgets, Qualité UI/UX, Gestion des Données
rapport_technique_uqarlive_finale.tex  # Sections 10-11 : Tests et Qualité, Documentation et Conclusion
README_COMPILATION.md                  # Ce fichier de guide
```

## 🖼️ Images Requises

Le rapport fait référence aux images suivantes qui doivent être placées dans le dossier `uqarlife/` :

- `uqarlifelogo.jpg` - Logo de l'application UqarLive
- `Architecture.png` - Diagramme d'architecture Clean Architecture
- `Class.png` - Diagramme de classes des entités métier
- `Relationnal.png` - Modèle relationnel de la base de données
- `Usercases.png` - Diagramme des cas d'usage
- `stucture.png` - Structure générale de l'interface utilisateur
- `ArchiModel.png` - Modèle d'architecture (optionnel)

## 🛠️ Prérequis

### Installation de LaTeX

#### Windows
1. Télécharger et installer [MiKTeX](https://miktex.org/download)
2. Ou installer [TeX Live](https://www.tug.org/texlive/)

#### macOS
1. Installer [MacTeX](https://www.tug.org/mactex/)
2. Ou utiliser Homebrew : `brew install --cask mactex`

#### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install texlive-full
sudo apt-get install texlive-lang-french
```

### Éditeur Recommandé
- **TeXstudio** (gratuit, multiplateforme)
- **Overleaf** (en ligne, collaboration)
- **VS Code** avec extension LaTeX Workshop

## 🔧 Compilation

### Méthode 1 : Compilation Directe (Recommandée)

1. **Ouvrir le fichier principal** : `rapport_technique_complet.tex`
2. **Compiler avec LaTeX** :
   - Première compilation : `pdflatex`
   - Deuxième compilation : `pdflatex` (pour la table des matières)
   - Optionnel : `bibtex` si des références bibliographiques sont ajoutées

### Méthode 2 : Compilation par Sections

Si vous souhaitez compiler uniquement certaines sections :

1. **Section Architecture** : Compiler `rapport_technique_uqarlive.tex`
2. **Section Domain** : Compiler `rapport_technique_uqarlive_suite1.tex`
3. **Section UI/UX** : Compiler `rapport_technique_uqarlive_suite2.tex`

### Méthode 3 : Compilation en Ligne

Utiliser [Overleaf](https://www.overleaf.com/) :
1. Créer un nouveau projet
2. Uploader tous les fichiers `.tex`
3. Placer les images dans le dossier `uqarlife/`
4. Compiler avec le bouton "Recompile"

## 📋 Commandes de Compilation

### Terminal/Commande
```bash
# Compilation complète
pdflatex rapport_technique_complet.tex
pdflatex rapport_technique_complet.tex

# Ou en une seule commande
pdflatex -interaction=nonstopmode rapport_technique_complet.tex
```

### Avec Makefile (si disponible)
```bash
make rapport
# ou
make clean && make rapport
```

## ⚠️ Résolution des Problèmes

### Erreur "Image not found"
- Vérifier que le dossier `uqarlife/` contient toutes les images
- Vérifier les chemins relatifs dans les fichiers `.tex`

### Erreur "Package not found"
- Installer les packages manquants via le gestionnaire de packages LaTeX
- Ou utiliser une distribution LaTeX complète

### Erreur de compilation
- Vérifier la syntaxe LaTeX
- Compiler plusieurs fois pour résoudre les références croisées

## 🎨 Personnalisation

### Modifier les Couleurs UQAR
Dans le fichier principal, modifier les définitions de couleurs :
```latex
\definecolor{uqarBlue}{HTML}{005499}      # Bleu principal
\definecolor{uqarSkyBlue}{HTML}{00A1E4}   # Bleu ciel
\definecolor{uqarLightGray}{HTML}{F8F9FA} # Gris clair
\definecolor{uqarDarkGray}{HTML}{2C2C2C}  # Gris foncé
```

### Ajouter de Nouvelles Sections
1. Créer un nouveau fichier `.tex` pour la section
2. L'inclure dans le fichier principal avec `\input{nom_fichier}`
3. Ajouter l'entrée dans la table des matières

### Modifier l'En-tête
Dans le fichier principal, modifier :
```latex
\fancyhead[C]{UqarLive - Rapport Technique}  # Titre de l'en-tête
\fancyhead[L]{\includegraphics[height=1cm]{uqarlife/uqarlifelogo.jpg}}  # Logo
```

## 📊 Résultat Final

Le rapport compilé contiendra :
- **Page de titre** avec logo UQAR
- **Table des matières** complète
- **11 sections** détaillées avec images
- **Annexes** techniques complètes
- **Conclusion** et recommandations

## 🔗 Ressources Utiles

- [Documentation LaTeX](https://www.latex-project.org/help/documentation/)
- [Guide LaTeX en français](https://www.grappa.univ-lille3.fr/~torre/LaTeX.php)
- [Overleaf Documentation](https://www.overleaf.com/learn)
- [TeXstudio Documentation](https://www.texstudio.org/)

## 📞 Support

Pour toute question concernant :
- **Compilation LaTeX** : Consulter la documentation officielle
- **Contenu technique** : Contacter l'équipe de développement UqarLive
- **Structure du rapport** : Vérifier ce README et les commentaires dans les fichiers

---

**Note** : Ce rapport est optimisé pour une compilation avec `pdflatex` et utilise les packages standard de LaTeX. Assurez-vous d'avoir une distribution LaTeX complète installée pour éviter les problèmes de packages manquants.
