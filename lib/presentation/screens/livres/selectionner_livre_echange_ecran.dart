import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/livre.dart';
import '../../../presentation/widgets/widget_barre_app_personnalisee.dart';


class SelectionnerLivreEchangeEcran extends StatelessWidget {
  final List<Livre> livres;
  final Livre livreACible; // Le livre que l'utilisateur veut obtenir

  const SelectionnerLivreEchangeEcran({
    super.key,
    required this.livres,
    required this.livreACible,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;
    
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      resizeToAvoidBottomInset: true,
              appBar: const WidgetBarreAppPersonnalisee(
          titre: 'Échange de Livres',
          sousTitre: 'Choisir un Livre',
          afficherBoutonRetour: true,
          afficherProfil: false,
        ),
      body: SafeArea(
        child: Column(
          children: [
            // En-tête avec informations sur l'échange
            _construireEnTeteEchange(screenWidth, screenHeight),
            
            // Liste des livres disponibles
            Expanded(
              child: _construireListeLivres(screenWidth, screenHeight),
            ),
            
            // Actions en bas
            _construireActionsFinales(context, screenWidth, screenHeight, viewInsets, padding),
          ],
        ),
      ),
    );
  }

  
  Widget _construireEnTeteEchange(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: CouleursApp.principal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icône d'échange simple
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.swap_horiz,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          SizedBox(width: screenWidth * 0.04),
          
          // Informations échange simplifiées
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Échange avec',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  livreACible.titre,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  
  Widget _construireListeLivres(double screenWidth, double screenHeight) {
    if (livres.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.library_books_outlined,
                size: 80,
                color: CouleursApp.gris,
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                'Aucun livre disponible',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w600,
                  color: CouleursApp.texteFonce,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Ajoutez des livres dans votre collection pour pouvoir les échanger.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: CouleursApp.gris,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre section simplifié
          Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.02),
            child: Text(
              'Vos livres (${livres.length})',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600,
                color: CouleursApp.texteFonce,
              ),
            ),
          ),
          
          // Liste des livres
          Expanded(
            child: ListView.separated(
              itemCount: livres.length,
              separatorBuilder: (context, index) => SizedBox(height: screenHeight * 0.02),
              itemBuilder: (context, index) {
                final livre = livres[index];
                return _construireCarteLivreSimple(livre, screenWidth, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _construireCarteLivreSimple(Livre livre, double screenWidth, BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Retourner le livre sélectionné et fermer la page
          Navigator.of(context).pop(livre);
        },
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Row(
            children: [
              // Icône du livre simple
              Container(
                width: 50,
                height: 70,
                decoration: BoxDecoration(
                  color: CouleursApp.principal,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              
              SizedBox(width: screenWidth * 0.04),
              
              // Informations essentielles du livre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      livre.titre,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                        color: CouleursApp.texteFonce,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: screenWidth * 0.02),
                    
                    // Auteur
                    Text(
                      livre.auteur,
                      style: TextStyle(
                        fontSize: screenWidth * 0.038,
                        color: CouleursApp.gris,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: screenWidth * 0.02),
                    
                    // Matière et état sur la même ligne
                    Row(
                      children: [
                        // Matière
                        Text(
                          livre.matiere,
                          style: TextStyle(
                            fontSize: screenWidth * 0.033,
                            color: CouleursApp.principal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: screenWidth * 0.033,
                            color: CouleursApp.gris,
                          ),
                        ),
                        
                        // État
                        Text(
                          livre.etatLivre,
                          style: TextStyle(
                            fontSize: screenWidth * 0.033,
                            color: _obtenirCouleurEtat(livre.etatLivre),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Flèche simple
              const Icon(
                Icons.arrow_forward_ios,
                color: CouleursApp.gris,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Obtenir la couleur selon l'état du livre
  Color _obtenirCouleurEtat(String etat) {
    switch (etat.toLowerCase()) {
      case 'comme neuf':
        return Colors.green;
      case 'très bon état':
        return Colors.blue;
      case 'bon état':
        return Colors.orange;
      case 'état correct':
        return Colors.amber[700]!;
      default:
        return CouleursApp.gris;
    }
  }

  
  Widget _construireActionsFinales(BuildContext context, double screenWidth, double screenHeight, EdgeInsets viewInsets, EdgeInsets padding) {
    return Container(
      padding: EdgeInsets.only(
        left: screenWidth * 0.04,
        right: screenWidth * 0.04,
        top: screenHeight * 0.015,
        bottom: viewInsets.bottom + padding.bottom + screenHeight * 0.02,
      ),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Instruction simple
          Text(
            'Touchez un livre pour proposer l\'échange',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.038,
              color: CouleursApp.gris,
              fontWeight: FontWeight.w400,
            ),
          ),
          
          SizedBox(height: screenHeight * 0.02),
          
          // Bouton annuler centré
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Annuler',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
