// UI Design: Entité représentant un message dans le système de messagerie UqarLife
class Message {
  final String id;
  final String expediteurId;
  final String destinataireId;
  final String contenu;
  final DateTime dateEnvoi;
  final bool estLu;
  final String? typeMessage; // 'transaction', 'general', 'support'
  final String? referenceId; // ID de la transaction ou autre référence
  final String? pieceJointe; // URL ou chemin vers une pièce jointe

  const Message({
    required this.id,
    required this.expediteurId,
    required this.destinataireId,
    required this.contenu,
    required this.dateEnvoi,
    this.estLu = false,
    this.typeMessage,
    this.referenceId,
    this.pieceJointe,
  });

  // UI Design: Méthode de copie avec modifications
  Message copyWith({
    String? id,
    String? expediteurId,
    String? destinataireId,
    String? contenu,
    DateTime? dateEnvoi,
    bool? estLu,
    String? typeMessage,
    String? referenceId,
    String? pieceJointe,
  }) {
    return Message(
      id: id ?? this.id,
      expediteurId: expediteurId ?? this.expediteurId,
      destinataireId: destinataireId ?? this.destinataireId,
      contenu: contenu ?? this.contenu,
      dateEnvoi: dateEnvoi ?? this.dateEnvoi,
      estLu: estLu ?? this.estLu,
      typeMessage: typeMessage ?? this.typeMessage,
      referenceId: referenceId ?? this.referenceId,
      pieceJointe: pieceJointe ?? this.pieceJointe,
    );
  }

  // UI Design: Méthode pour marquer le message comme lu
  Message marquerCommeLu() {
    return copyWith(estLu: true);
  }

  // UI Design: Méthode pour vérifier si le message est récent (moins de 24h)
  bool get estRecent {
    final maintenant = DateTime.now();
    final difference = maintenant.difference(dateEnvoi);
    return difference.inHours < 24;
  }

  // UI Design: Méthode pour obtenir le temps écoulé depuis l'envoi
  String get tempsEcoule {
    final maintenant = DateTime.now();
    final difference = maintenant.difference(dateEnvoi);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'À l\'instant';
    }
  }

  @override
  String toString() {
    return 'Message(id: $id, expediteurId: $expediteurId, destinataireId: $destinataireId, contenu: $contenu, estLu: $estLu)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
