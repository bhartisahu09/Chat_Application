import 'package:chatapp/pages/signin.dart';
import 'package:chatapp/pages/home.dart';
import 'package:chatapp/service/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: FutureBuilder(
      //   future: AuthMethods().getcurrentUser(),
      //   builder: (context, AsyncSnapshot<dynamic> snapshot){
      //     if(snapshot.hasData){
      //       return Home();
      //     }else{
      //       return SignUp();
      //     }
      // })
      home: SignIn(),
    );
  }
}
