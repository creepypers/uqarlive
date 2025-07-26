import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../screens/profil_ecran.dart';

// UI Design: Barre d'application personnalisée réutilisable avec design UQAR
class WidgetBarreAppPersonnalisee extends StatelessWidget implements PreferredSizeWidget {
  final String titre;
  final String sousTitre;
  final Widget? widgetFin;
  final VoidCallback? onTapFin;
  final IconData? iconeFin;
  final double hauteurBarre;
  final bool afficherProfil;
  final bool afficherBoutonRetour;

  const WidgetBarreAppPersonnalisee({
    super.key,
    required this.titre,
    required this.sousTitre,
    this.widgetFin,
    this.onTapFin,
    this.iconeFin = Icons.search,
    this.hauteurBarre = 80,
    this.afficherProfil = true,
    this.afficherBoutonRetour = false,
  });

  @override
  Widget build(BuildContext context) {
    // UI Design: AppBar UQAR modernisée avec hiérarchie visuelle, dégradé, ombre et bordure
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CouleursApp.principal,
            CouleursApp.accent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.18),
            width: 1.2,
          ),
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: hauteurBarre,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
        ),
      ),
        leading: afficherBoutonRetour ? IconButton(
          icon: Icon(Icons.arrow_back, color: CouleursApp.blanc),
          onPressed: () => Navigator.of(context).pop(),
        ) : afficherProfil ? Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
        child: GestureDetector(
          onTap: () => _ouvrirProfil(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  CouleursApp.blanc.withValues(alpha: 0.3),
                  CouleursApp.blanc.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                'MD', // Initiales Marie Dubois
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: CouleursApp.blanc,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ) : null,
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Section titre
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: TextStyle(
                        color: CouleursApp.blanc.withOpacity(0.85),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                    ),
                  ),
                    const SizedBox(height: 3),
                  Text(
                    sousTitre,
                    style: TextStyle(
                      color: CouleursApp.blanc,
                        fontSize: 22,
                      fontWeight: FontWeight.bold,
                        letterSpacing: 0.1,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                    ),
                  ),
                ],
              ),
            ),
            // Section boutons droite
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widgetFin != null)
                  widgetFin!
                else if (onTapFin != null)
                  GestureDetector(
                    onTap: onTapFin,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: CouleursApp.blanc.withOpacity(0.15),
                          shape: BoxShape.circle,
                      ),
                      child: Icon(
                        iconeFin,
                        color: CouleursApp.blanc,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(hauteurBarre);

  // Navigation vers le profil
  void _ouvrirProfil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilEcran()),
    );
  }
} 