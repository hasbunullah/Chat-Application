class chatRoomModel{

  String? chatRoomId;
  Map<String, dynamic>? participents;
  String lastMessage;

  chatRoomModel({required this.chatRoomId,required this.participents,required this.lastMessage});
}