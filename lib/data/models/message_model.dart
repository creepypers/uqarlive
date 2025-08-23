import '../../domain/entities/message.dart';
class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.expediteurId,
    required super.destinataireId,
    required super.contenu,
    required super.dateEnvoi,
    super.estLu,
    super.typeMessage,
    super.referenceId,
    super.pieceJointe,
  });
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      expediteurId: map['expediteurId'] ?? '',
      destinataireId: map['destinataireId'] ?? '',
      contenu: map['contenu'] ?? '',
      dateEnvoi: DateTime.parse(map['dateEnvoi']),
      estLu: map['estLu'] ?? false,
      typeMessage: map['typeMessage'],
      referenceId: map['referenceId'],
      pieceJointe: map['pieceJointe'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expediteurId': expediteurId,
      'destinataireId': destinataireId,
      'contenu': contenu,
      'dateEnvoi': dateEnvoi.toIso8601String(),
      'estLu': estLu,
      'typeMessage': typeMessage,
      'referenceId': referenceId,
      'pieceJointe': pieceJointe,
    };
  }
  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      expediteurId: message.expediteurId,
      destinataireId: message.destinataireId,
      contenu: message.contenu,
      dateEnvoi: message.dateEnvoi,
      estLu: message.estLu,
      typeMessage: message.typeMessage,
      referenceId: message.referenceId,
      pieceJointe: message.pieceJointe,
    );
  }
  Message toEntity() {
    return Message(
      id: id,
      expediteurId: expediteurId,
      destinataireId: destinataireId,
      contenu: contenu,
      dateEnvoi: dateEnvoi,
      estLu: estLu,
      typeMessage: typeMessage,
      referenceId: referenceId,
      pieceJointe: pieceJointe,
    );
  }
}