import 'package:chat_application/screens/home.dart';
import 'package:chat_application/screens/priofile_Screen.dart';
import 'package:chat_application/screens/signUp_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class first_screen extends StatefulWidget {
  const first_screen({Key? key}) : super(key: key);

  @override
  State<first_screen> createState() => _first_screenState();
}

class _first_screenState extends State<first_screen> {

  TextEditingController emailcontroller= TextEditingController();
  TextEditingController passworcontroller= TextEditingController();

  void check() async{

    UserCredential? credential;
    if(emailcontroller.text!= '' && passworcontroller.text!= '')
      {
        String email= emailcontroller.text;
        String password = passworcontroller.text;
          try{
            credential= await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
          }
          catch(ex){
            print(ex.toString());
          }
          if(credential!=null)
            {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => homeScreen()));

            }

      }
  }




  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 200),
                child: Center(child: Text("Chat App ",
                  style: TextStyle(fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 30),))),
             SizedBox(height: 20,),
             Container(
               margin: EdgeInsets.symmetric(
                 horizontal: 30,
               ),
               child: TextField(
                 controller: emailcontroller,
                 decoration: InputDecoration(
                   labelText: "Email Address"
                 ),
               ),
             ),

            SizedBox(height: 10,),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: TextField(
                controller: passworcontroller,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Password",

                ),
              ),
            ),

            SizedBox(height: 20,),

            CupertinoButton(child: Text('Login', style: TextStyle(color: Colors.white),),
                onPressed:(){
                         check();
            }, color: Colors.blue,),

          ],
        ),
      ),
   bottomNavigationBar: Container(
     child: Row(
       mainAxisAlignment: MainAxisAlignment.center,
       children: [
         Text("Don't Have an Account?", style: TextStyle(),),
         CupertinoButton(child: Text('Sign up', style: TextStyle(color: Colors.blue),),
           onPressed:(){
              Navigator.push(context, MaterialPageRoute(builder: (context) => signUp()));
           },),

       ],

     ),
     
   ),
    ));
  }
}
