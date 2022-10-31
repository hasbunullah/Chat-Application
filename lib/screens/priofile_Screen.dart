import 'dart:io';
import 'package:chat_application/screens/first_screen.dart';
import 'package:chat_application/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class profile_Screen extends StatefulWidget {
  const profile_Screen({Key? key}) : super(key: key);

  @override
  State<profile_Screen> createState() => _profile_ScreenState();
}

class _profile_ScreenState extends State<profile_Screen> {

  File? imageFile;
  @override
  Widget build(BuildContext context) {

    TextEditingController fullnamecontroller= TextEditingController();
    void cropImage(XFile file) async{
      CroppedFile? croppedimage =  await ImageCropper().cropImage(sourcePath: file.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 20,
      );
      if(croppedimage!=null)
        {
          setState((){
             imageFile = File(croppedimage.path);
          });
        }


    }

 void selectImage(ImageSource source) async{
  XFile? pickedfile= await ImagePicker().pickImage(source: source);

  if(pickedfile!= null)
    {
      cropImage(pickedfile);
    }
 }

    void UploadData()   async {

      UploadTask uploadTask= FirebaseStorage.instance.ref("profilepic").child(FirebaseAuth.instance.currentUser!.uid).putFile(imageFile!);
      TaskSnapshot snapshot= await uploadTask;

      String imageUrl= await snapshot.ref.getDownloadURL();
      String fullname= fullnamecontroller.text;

      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set(
        {
          'email':FirebaseAuth.instance.currentUser!.email,
          'uid':FirebaseAuth.instance.currentUser!.uid,
          'url': imageUrl,
          'Name': fullname,
        }
      );
      }


    void check (){
      if(fullnamecontroller.text== '' && imageFile==null)
        {
          print('Please Fill the required Field');
        }
      else
        {
         UploadData();
        }
 }

    void showphotoOption(){
      showDialog(context: context, builder: (context){
        return AlertDialog(
          title: Text('Select image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              ListTile(

                onTap: (){
                  Navigator.pop(context);
                  selectImage(ImageSource.gallery);
                },
                leading: Icon(Icons.photo_album),
                title: Text('select from Gallery'),

              ),
              ListTile(
                onTap: (){
                  Navigator.pop(context);
                  selectImage(ImageSource.camera);
                },
                leading: Icon(Icons.camera_alt),
                title: Text('Take on Camera'),

              ),
            ],
          ),
        );
      });
    }
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Complete Profile'),
      ),

    body: SingleChildScrollView(
      child: Column(
          children: [
            SizedBox(height: 20,),
            CupertinoButton(
              onPressed: (){
                  showphotoOption();
              },
              child: Center(
                child: Container(
          child: CircleAvatar(
            backgroundImage:( imageFile!=null)? FileImage(imageFile!):null,
          radius: 50,
        child: (imageFile==null)? Icon(Icons.person): null,
      ),
      ),
              ),
            ),
            SizedBox(height: 10,),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: TextField(
                controller: fullnamecontroller,
                decoration: InputDecoration(
                  labelText: "Full Name",

                ),
              ),
            ),

            SizedBox(height: 20,),
            
            Container(
              child: CupertinoButton(
                onPressed: (){
                  check();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> first_screen()));
                }, child: Text('Submit'),
              color: Colors.blue,
              ),
            )
        ],
      ),
    ),
    ));
  }
}
