class messageModel{
  String messegeId;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdOn;

  messageModel(
      {required this.messegeId,required this.sender,required this.text,required this.seen,required this.createdOn});
}