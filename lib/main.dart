import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './loginpage.dart';
import './homepage.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => Page1(),
        '/homepage': (context) => HomePage(),
      },
      debugShowCheckedModeBanner: false,
//      home: Scaffold(
//        appBar: AppBar(
//          title: Text('Login'),
//        ),
//        //body: LoginPage()
//      ),
    );
  }
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LoginPage();
  }
}
