# UqarLife UI Log

## Écrans mis à jour
- [x] Connexion (connexion_ecran.dart) - Créé avec design dégradé violet/bleu
- [x] Écran de chargement (ecran_chargement.dart) - Fond noir avec animation

## Composants créés
- [x] Champs de texte personnalisés avec validation
- [x] Bouton principal stylisé avec thème UQAR
- [x] Illustrations de feuilles stylisées (placeholder)
- [x] Logo UqarLive avec icône école et texte "UQAR"
- [x] Écran de chargement animé avec fond noir

## Décisions de theming et widgets réutilisés
- Palette UQAR appliquée (voir app_theme.dart)
- Styles de texte centralisés
- Boutons arrondis et cohérents
- Dégradé violet/bleu pour correspondre au design de l'image
- Champs de texte avec ombres douces et coins arrondis
- Validation des formulaires avec messages en français
- Utilisation d'icônes Material pour les champs

## Écrans implémentés
- ConnexionEcran : Écran de connexion avec formulaire complet
  - Champs : nom d'utilisateur, mot de passe (en français)
  - Actions : connexion, mot de passe oublié, créer compte (en français)
  - Design : dégradé violet/bleu, illustrations de feuilles
  - Titre : "Connexion" au lieu de "Login"
  - Bouton : "Se connecter" au lieu de "Login"
  - Placeholders : "Nom d'utilisateur" et "Mot de passe"
  - Lien : "Mot de passe oublié?" et "Créer un compte"
- Logo et nom "UqarLive" centrés dans la section supérieure
- Logo avec icône école et texte "UQAR" sur fond blanc
- EcranChargement : Écran de démarrage avec fond noir
  - Logo UqarLive animé avec effet de fondu
  - Nom de l'application "UqarLive" en grand
  - Sous-titre "Université du Québec à Rimouski"
  - Indicateur de chargement circulaire
  - Navigation automatique vers l'écran de connexion après 3 secondes

## TODOs UI
- [ ] Ajouter l'écran d'inscription
- [ ] Ajouter les placeholders pour images/icônes manquantes
- [ ] Tester l'accessibilité des couleurs 

## Traductions appliquées
- Titre : Login → Connexion
- Champs : Username → Nom d'utilisateur, Password → Mot de passe
- Bouton : Login → Se connecter
- Liens : Forgot Password? → Mot de passe oublié?, Create Account → Créer un compte
- Messages de validation en français
- Nom de l'application : UqarLife → UqarLive
- Ajout du nom "UqarLive" sur l'écran de connexion
- Création du logo avec icône école et texte "UQAR"
- Écran de chargement avec fond noir au démarrage 