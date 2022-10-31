import 'package:chat_application/main.dart';
import 'package:chat_application/screens/chatRoom_model.dart';
import 'package:chat_application/screens/chat_room.dart';
import 'package:chat_application/screens/first_screen.dart';
import 'package:chat_application/screens/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class homeScreen extends StatefulWidget {



  homeScreen({Key? key}) : super(key: key);

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {


  UserModel myModel= UserModel(uid: FirebaseAuth.instance.currentUser!.uid, fullName: '', email: FirebaseAuth.instance.currentUser!.email, profilePic: '');
  getChatRoomModel(UserModel targetUser , UserModel my ) async {

   QuerySnapshot snapshot=await FirebaseFirestore.instance.collection('chatroom').where("participents.${my.uid}",isEqualTo: true).where("participents.${targetUser.uid}",isEqualTo: true).get();
   chatRoomModel Chatmodel;
    if(snapshot.docs.length == 0)
    {

      Chatmodel= chatRoomModel(chatRoomId: uuid.v1(), participents: {
        targetUser.uid.toString(): true,
        my.uid.toString(): true,
      }, lastMessage: '');

      await FirebaseFirestore.instance.collection("chatroom").doc(Chatmodel.chatRoomId).set(
          {
            'chatRoomId': Chatmodel.chatRoomId,
            'lastMessage': '',
            'participents': Chatmodel.participents,
            'lastMessage': Chatmodel.lastMessage,

          });
      
      print('Chat Room Created');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> chat_room(targetUser: targetUser, chatroom:Chatmodel  , userModel: myModel))
      );
    }
    else{
      Chatmodel=chatRoomModel(chatRoomId: snapshot.docs[0]['chatRoomId'], participents: snapshot.docs[0]['participents'], lastMessage: snapshot.docs[0]['lastMessage']);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> chat_room(targetUser: targetUser, chatroom:Chatmodel  , userModel: myModel)));
  }
  }


  TextEditingController searchController= TextEditingController();
  @override
  Widget build(BuildContext context) {

    void alertBox(){
      showDialog(context: context, builder: (context){
        return AlertDialog(
          title: Text('Search User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: searchController,
                decoration: InputDecoration(
                 prefixIcon: Icon(Icons.email),
                  hintText: "Search By gmail",

                ),
              ),
              SizedBox(height: 40,),

              InkWell(
                onTap: ()async{
                  if(searchController.text==FirebaseAuth.instance.currentUser!.email)
                    {
                      print('same User ');

                    }
                  else{
                  QuerySnapshot querysnap =  await FirebaseFirestore.instance.collection('users').where("email", isEqualTo: searchController.text).get();

                  if(querysnap.docs!=null){
                  if(querysnap.docs.length==0){
                  print('User Not found');
                  }


                   else {
                  UserModel targetUser= UserModel(uid: querysnap.docs[0]['uid'], email: querysnap.docs[0]['email'], fullName: querysnap.docs[0]['Name'], profilePic: querysnap.docs[0]['url']);


                  Navigator.pop(context);

                  showDialog(context: context, builder: (context) {
                  return AlertDialog(
                  title: Text('Here is your partner'),
                  content: Card(
                  child: ListTile(
                  onTap: () {
                     getChatRoomModel(targetUser, myModel );
                  },

                  title: Text(querysnap.docs[0]['email']),
                  leading: CircleAvatar(backgroundImage: NetworkImage(
                      targetUser.profilePic!),),
                  shape: RoundedRectangleBorder(
                  side: BorderSide(
                  color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  ),
                  ),
                  ),
                  );
                  });
                  }
                  }

                  else{

                  print('nothing found');

                  }

                  }

                },
                child: CircleAvatar(
                  child: Text('Search'),
                  radius: 30,
                ),
              ),
            ],
          ),

        );
      });
    }

    return SafeArea(
      child: Container(
        child: Scaffold(
          appBar: AppBar(
          centerTitle: true,
          title: Text('Home Screen'),

          actions: [
            IconButton(onPressed:(){

               FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> first_screen()));
            }
            , icon: Icon(Icons.logout)),


            IconButton(onPressed:(){
              alertBox();
            }
                , icon: Icon(Icons.search))
          ],
        ),
          body: Container(
            child: StreamBuilder(
               stream: FirebaseFirestore.instance.collection('chatroom').where("participents.${myModel.uid}", isEqualTo: true).snapshots(),
              builder: (context, snapshots){

                 if(snapshots.connectionState== ConnectionState.active){
                   if(snapshots.hasData){

                       QuerySnapshot chatRoomSnapshot= snapshots.data as QuerySnapshot;
                       return ListView.builder(

                         itemCount: chatRoomSnapshot.docs.length,
                         itemBuilder: (context, index){

                         chatRoomModel chatRoom= chatRoomModel(chatRoomId: chatRoomSnapshot.docs[index]['chatRoomId'], participents: chatRoomSnapshot.docs[index]['participents'], lastMessage: chatRoomSnapshot.docs[index]['lastMessage']);
                        List<String> participants=chatRoom.participents!.keys.toList();


                        return FutureBuilder(
                          future: FirebaseFirestore.instance.collection('users').doc(participants[0]!=FirebaseAuth.instance.currentUser!.uid? participants[0]: participants[1]).get(),
                          builder: (context,snapshot) {
                            //print(snapshot.data);

                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasData) {
                                DocumentSnapshot documentSnapshot = snapshot
                                    .data! as DocumentSnapshot;
                                Map<String, dynamic> map = documentSnapshot
                                    .data() as Map<String, dynamic>;

                                if (map.length != 0) {
                                  UserModel target = UserModel(uid: map['uid'],
                                      email: map['email'],
                                      fullName: map['Name'],
                                      profilePic: map['url']);


                                  return ListTile(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) =>
                                              chat_room(targetUser: target,
                                                  chatroom: chatRoom,
                                                  userModel: myModel)));
                                    },
                                    title: Text(map['Name']),
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          map['url'].toString()),

                                    ),
                                    subtitle: Text(chatRoom.lastMessage),
                                  );
                                }
                                else {
                                  return Container();
                                }
                              }
                              else {
                                return Container();
                              }


                              // Map<String,dynamic> targetperson = snapshot.data as Map<String,dynamic>;
                              return CircularProgressIndicator();
                            }
                            else{
                              return Container();
                            }
                          });

                         },

                       );
                   }
                   else if(snapshots.hasError){
                     return Center(
                       child: Text(snapshots.error.toString()),);

                   }
                   else {
                     return Center(child: Text('No chat'),);
                   }


                 }
                 else{

                   return Center(
                     child: CircularProgressIndicator(),
                   );
                 }
              },

            ),
          ),
        ),
      ),
    );
  }
}
