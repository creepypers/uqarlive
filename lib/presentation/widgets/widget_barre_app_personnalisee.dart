import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// UI Design: Barre d'application personnalisée réutilisable avec design UQAR
class WidgetBarreAppPersonnalisee extends StatelessWidget implements PreferredSizeWidget {
  final String titre;
  final String sousTitre;
  final Widget? widgetFin;
  final VoidCallback? onTapFin;
  final IconData? iconeFin;
  final double hauteurBarre;

  const WidgetBarreAppPersonnalisee({
    super.key,
    required this.titre,
    required this.sousTitre,
    this.widgetFin,
    this.onTapFin,
    this.iconeFin = Icons.search,
    this.hauteurBarre = 80,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: CouleursApp.principal,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: hauteurBarre,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
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
                      color: CouleursApp.blanc.withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sousTitre,
                    style: TextStyle(
                      color: CouleursApp.blanc,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Widget ou bouton de fin
            if (widgetFin != null)
              widgetFin!
            else if (onTapFin != null)
              GestureDetector(
                onTap: onTapFin,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: CouleursApp.blanc.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
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
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(hauteurBarre);
} 