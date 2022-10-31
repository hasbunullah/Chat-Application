import 'package:chat_application/screens/first_screen.dart';
import 'package:chat_application/screens/home.dart';
import 'package:chat_application/screens/priofile_Screen.dart';
import 'package:chat_application/screens/signUp_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid= Uuid();

void main() async {
 WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp();
  runApp(const mainscreen());
}

class mainscreen extends StatelessWidget {
  const mainscreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FirebaseAuth.instance.currentUser==null? first_screen(): homeScreen(),
     );
  }
}
