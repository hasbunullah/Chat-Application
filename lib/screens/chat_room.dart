import 'package:chat_application/main.dart';
import 'package:chat_application/screens/messegeModel.dart';
import 'package:chat_application/screens/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chatRoom_model.dart';

class chat_room extends StatefulWidget {

      UserModel targetUser;
      chatRoomModel chatroom;
      UserModel userModel;

  chat_room({required this.targetUser, required this.chatroom, required this.userModel});



  @override
  State<chat_room> createState() => _chat_roomState();
}

class _chat_roomState extends State<chat_room> {

  TextEditingController messegeController=  TextEditingController();
  late messageModel MessageModel;

   sendMessage()async {

     String mesg= messegeController.text.trim();
     messegeController.clear();

     if(mesg != '')
       {

         MessageModel= messageModel(
             messegeId: uuid.v1(),
             sender: widget.userModel.uid,
             text: mesg,
             seen: false,
             createdOn: null);


         FirebaseFirestore.instance.collection('chatroom').doc(widget.chatroom.chatRoomId).collection('messages').doc(MessageModel.messegeId).set({
           'messageId': MessageModel.messegeId,
           'sender': MessageModel.sender,
           'text': MessageModel.text,
           'seen': MessageModel.seen,
           'createdOn': DateTime.now(),

         },
         );

         widget.chatroom.lastMessage= mesg;

         FirebaseFirestore.instance.collection('chatroom').doc(widget.chatroom.chatRoomId).update({
           'lastMessage': widget.chatroom.lastMessage,
         });

       }

     print('Messege Send');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        automaticallyImplyLeading: false,
          title: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.targetUser.profilePic.toString()),
            ),
            title: Text('${widget.targetUser.fullName}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),),
          ),
      ),

      body: SafeArea(child: Container(

        child: Column(
          children: [
            Expanded(child: Container(
              
              margin: EdgeInsets.symmetric(horizontal: 5),
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('chatroom').doc(widget.chatroom.chatRoomId).collection('messages').orderBy('createdOn', descending: true).snapshots(),
                  builder: (context, snapshots){

                    if(snapshots.connectionState== ConnectionState.active){

                      if(snapshots.hasData)
                        {
                          QuerySnapshot dataSnapshot= snapshots.data as QuerySnapshot;
                          return ListView.builder(
                            reverse: true,
                              itemCount: dataSnapshot.docs.length,
                              itemBuilder: (context, index)
                          {
                            messageModel messege= messageModel(messegeId: dataSnapshot.docs[index]['messageId'], sender: dataSnapshot.docs[index]['sender'].toString(), text: dataSnapshot.docs[index]['text'], seen: dataSnapshot.docs[index]['seen'], createdOn: null);


                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: (messege.sender== widget.userModel.uid)? MainAxisAlignment.end: MainAxisAlignment.start,
                                children: [
                                  Container(

                                    decoration: BoxDecoration(

                                      borderRadius: BorderRadius.circular(5),
                                      color: (messege.sender== widget.userModel.uid? Colors.blue: Colors.grey),

                                    ),
                                     //    margin: EdgeInsets.symmetric(vertical: 5),

                                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                      child: Text(messege.text.toString())),
                                ],
                              ),
                            );


                          });
                        }
                      else if(snapshots.hasError){
                         return Center(child: Text('Something bad'),);
                      }
                      else{
                        return Center(child: Text('say Hy'),);
                      }
                    }
                      else{
                        return Center(child: CircularProgressIndicator());
                    }
                  }
                    ),
            )),

            Container(
              padding: EdgeInsets.only(left: 10),
              color: Colors.grey[200],
              child: Row(
              children: [
                Flexible(
                  child: TextFormField(
                    controller: messegeController,
                    decoration: InputDecoration(
                      hintText: "Enter Your Message",
                      suffixIcon: InkWell(child: Icon(Icons.send),
                      onTap: (){
                        sendMessage();
                      },
                      ),
                    ),

                ),),
              ],
            ),)
          ],

        ),
      ),
      ),
    );
  }
}
