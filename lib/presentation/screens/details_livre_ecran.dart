import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/livre.dart';

// UI Design: Page de détails d'un livre avec design UQAR et informations complètes
class DetailsLivreEcran extends StatefulWidget {
  final Livre livre;

  const DetailsLivreEcran({
    super.key,
    required this.livre,
  });

  @override
  State<DetailsLivreEcran> createState() => _DetailsLivreEcranState();
}

class _DetailsLivreEcranState extends State<DetailsLivreEcran> {
  bool _isFavoris = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: CustomScrollView(
        slivers: [
          _construireSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _construireInformationsPrincipales(),
                  const SizedBox(height: 24),
                  _construireInformationsAcademiques(),
                  const SizedBox(height: 24),
                  _construireInformationsProprietaire(),
                  const SizedBox(height: 24),
                  if (widget.livre.description != null) ...[
                    _construireDescription(),
                    const SizedBox(height: 24),
                  ],
                  if (widget.livre.edition != null) ...[
                    _construireInformationsTechniques(),
                    const SizedBox(height: 32),
                  ],
                  _construireBoutonEchange(),
                  if (widget.livre.prix != null) ...[
                    const SizedBox(height: 16),
                    _construireBoutonAcheter(),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: SliverAppBar avec image du livre et actions
  Widget _construireSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: CouleursApp.principal,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CouleursApp.blanc.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back,
            color: CouleursApp.principal,
            size: 20,
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CouleursApp.blanc.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isFavoris ? Icons.favorite : Icons.favorite_border,
              color: _isFavoris ? Colors.red : CouleursApp.principal,
              size: 20,
            ),
          ),
          onPressed: () {
            setState(() {
              _isFavoris = !_isFavoris;
            });
          },
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CouleursApp.principal,
                CouleursApp.accent,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Image du livre ou placeholder
              Center(
                child: Container(
                  width: 180,
                  height: 240,
                  margin: const EdgeInsets.only(top: 60, bottom: 20),
                  decoration: BoxDecoration(
                    color: CouleursApp.blanc,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.menu_book,
                        size: 80,
                        color: CouleursApp.accent,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          widget.livre.titre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: CouleursApp.texteFonce,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Badge échange
              Positioned(
                top: 100,
                right: 40,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'ÉCHANGE',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UI Design: Informations principales du livre
  Widget _construireInformationsPrincipales() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.livre.titre,
            style: StylesTexteApp.titre.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            'Par ${widget.livre.auteur}',
            style: TextStyle(
              fontSize: 16,
              color: CouleursApp.texteFonce.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _construireChipInfo(
                icone: Icons.school,
                texte: widget.livre.matiere,
                couleur: CouleursApp.principal,
              ),
              const SizedBox(width: 12),
              _construireChipInfo(
                icone: Icons.calendar_today,
                texte: widget.livre.anneeEtude,
                couleur: CouleursApp.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UI Design: Informations académiques
  Widget _construireInformationsAcademiques() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.school,
                color: CouleursApp.principal,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Informations Académiques',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _construireLigneInfo('Matière', widget.livre.matiere),
          _construireLigneInfo('Année d\'études', widget.livre.anneeEtude),
          _construireLigneInfo('État du livre', widget.livre.etatLivre),
          if (widget.livre.codeCours != null)
            _construireLigneInfo('Code de cours', widget.livre.codeCours!),
        ],
      ),
    );
  }

  // UI Design: Informations du propriétaire
  Widget _construireInformationsProprietaire() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person,
                color: CouleursApp.principal,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Propriétaire',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: CouleursApp.accent.withValues(alpha: 0.2),
                child: Text(
                  widget.livre.proprietaire.split(' ').map((n) => n[0]).join(),
                  style: const TextStyle(
                    color: CouleursApp.principal,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.livre.proprietaire,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CouleursApp.texteFonce,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '4.8 (12 échanges)',
                          style: TextStyle(
                            fontSize: 14,
                            color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _contacterProprietaire(),
                icon: const Icon(
                  Icons.message,
                  color: CouleursApp.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UI Design: Description du livre
  Widget _construireDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.description,
                color: CouleursApp.principal,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Description',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.livre.description!,
            style: const TextStyle(
              fontSize: 14,
              color: CouleursApp.texteFonce,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // UI Design: Informations techniques (ISBN, édition)
  Widget _construireInformationsTechniques() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.principal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: CouleursApp.principal,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Informations Techniques',
                style: StylesTexteApp.titre.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.livre.edition != null)
            _construireLigneInfo('Édition', widget.livre.edition!),
        ],
      ),
    );
  }

  // UI Design: Bouton d'échange principal
  Widget _construireBoutonEchange() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _proposerEchange(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz, size: 24),
            SizedBox(width: 8),
            Text(
              'Proposer un échange',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widgets utilitaires
  Widget _construireChipInfo({
    required IconData icone,
    required String texte,
    required Color couleur,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: couleur.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 16, color: couleur),
          const SizedBox(width: 6),
          Text(
            texte,
            style: TextStyle(
              fontSize: 12,
              color: couleur,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireLigneInfo(String label, String valeur) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: CouleursApp.texteFonce.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valeur,
              style: const TextStyle(
                fontSize: 14,
                color: CouleursApp.texteFonce,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Actions
  void _proposerEchange() {
    // TODO: Implémenter la logique d'échange
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Échange proposé pour "${widget.livre.titre}"'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _contacterProprietaire() {
    // TODO: Implémenter la messagerie
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Message envoyé à ${widget.livre.proprietaire}'),
        backgroundColor: CouleursApp.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _construireBoutonAcheter() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _acheterLivre(),
        icon: const Icon(Icons.shopping_cart, size: 22),
        style: ElevatedButton.styleFrom(
          backgroundColor: CouleursApp.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        label: Text(
          'Acheter - ${widget.livre.prix?.toStringAsFixed(2) ?? ''} €',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _acheterLivre() {
    // UI Design: Message de confirmation d'achat
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Achat de "${widget.livre.titre}" pour ${widget.livre.prix?.toStringAsFixed(2) ?? ''} € effectué !'),
        backgroundColor: CouleursApp.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
} 