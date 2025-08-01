import 'package:flutter/material.dart';

abstract class HorairesRepository {
  // Obtenir les horaires pour un jour spécifique
  Map<String, TimeOfDay> obtenirHorairesCantine(String jour);
  
  // Obtenir tous les horaires de la cantine
  Map<String, Map<String, TimeOfDay>> obtenirTousLesHorairesCantine();
  
  // Mettre à jour les horaires
  Future<void> mettreAJourHorairesCantine(
    String jour,
    TimeOfDay heureOuverture,
    TimeOfDay heureFermeture,
  );
  
  // Vérifier si la cantine est ouverte
  bool estCantineOuverte({DateTime? dateVerification});
  
  // Obtenir le statut formaté
  String obtenirStatutCantineFormatte();
} 