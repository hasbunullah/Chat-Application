import 'package:chat_application/screens/first_screen.dart';
import 'package:chat_application/screens/priofile_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class signUp extends StatefulWidget {
  const signUp({Key? key}) : super(key: key);

  @override
  State<signUp> createState() => _signUpState();
}

class _signUpState extends State<signUp> {

  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController confirmpasswordcontroller = TextEditingController();
  void check() async{

    UserCredential? credential;
    if (emailcontroller.text != '' && passwordcontroller.text != '' && confirmpasswordcontroller.text!='') {
      if(passwordcontroller.text== confirmpasswordcontroller.text)
        {

          try{

            credential =  await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailcontroller.text, password: passwordcontroller.text);

          } catch(e){
            print(e.toString());
          }
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => profile_Screen()));
        }

     if(credential!=null)
       {
         String uid= credential.user!.uid;
        await FirebaseFirestore.instance.collection("users").doc(uid).set(
          {
            'uid': uid,
            'email': credential.user!.email,
          }
        );

       }
    }
    else {
      print('Fill the required data');
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
                    controller: passwordcontroller,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",

                    ),
                  ),
                ),

                SizedBox(height: 10,),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 30,
                  ),
                  child: TextField(
                    controller: confirmpasswordcontroller,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",


                    ),
                  ),
                ),

                SizedBox(height: 20,),

                CupertinoButton(child: Text('Sign Up', style: TextStyle(color: Colors.white),),
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
                Text("Already have an Account?", style: TextStyle(),),
                CupertinoButton(child: Text('Login', style: TextStyle(color: Colors.blue),),
                  onPressed:(){
                    Navigator.pop(context);
                  },),
              ],
            ),
          ),
        ));
  }
}
