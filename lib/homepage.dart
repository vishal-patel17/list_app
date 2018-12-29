import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './loginpage.dart';
import './shopping_list.dart';
import './task_list.dart';
import './group_shopping_list.dart';

class HomePage extends StatefulWidget {
  final FirebaseUser user;
  final GoogleSignIn googleSignIn;
  final GoogleSignInAccount googleSignInAccount;
  HomePage({Key key, this.user, this.googleSignIn, this.googleSignInAccount})
      : super(key: key);

  @override
  HomePageState createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listOfRegisteredUsers();
    listOfSharedUsers();
  }

  final List<String> registeredUsersEmail = [];
  String sharedUsersEmail;
  String _enteredEmail;
  bool _isSharedListCreated = false;

  Stream<QuerySnapshot> listOfRegisteredUsers() {
    Stream<QuerySnapshot> snapshots =
        Firestore.instance.collection('users').snapshots();
    snapshots.listen((data) {
      data.documents.forEach((doc) {
        setState(() {
          registeredUsersEmail.add(doc['email']);
        });
      });
    });
    return snapshots;
  }

  Stream<QuerySnapshot> listOfSharedUsers() {
    Stream<QuerySnapshot> snapshots =
        Firestore.instance.collection(widget.user.email + '_shared').snapshots();
    snapshots.listen((data) {
      data.documents.forEach((doc) {
        setState(() {
          this.sharedUsersEmail = (doc['email']);
        });
      });
    });
    return snapshots;
  }

  @override
  Widget build(BuildContext context) {
    if (this.sharedUsersEmail!=null) {
      setState(() {
        this._isSharedListCreated = true;
      });
    }
    //print(sharedUsers);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              this
                  .widget
                  .googleSignIn
                  .signOut()
                  .then((GoogleSignInAccount gSa) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              });
            },
          )
        ], title: Text("Welcome ${widget.user.email}")),
        body: Center(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 18.0),
              child: ListView(
                //shrinkWrap: true,
                children: <Widget>[
                  RaisedButton(
                    child: Text('Shopping List'),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => new ShoppingList(
                                  googleSignIn: this.widget.googleSignIn,
                                  user: this.widget.user,
                                ))),
                  ),
                  RaisedButton(
                    child: Text('Task List'),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => new TaskList(
                              googleSignIn: this.widget.googleSignIn,
                              user: this.widget.user),
                        )),
                  ),
                  RaisedButton(
                      child: Text('Create Sharing List'),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                    "Enter registered email of the person"),
                                content: TextField(
                                  autofocus: true,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (String value) {
                                    setState(() {
                                      this._enteredEmail = value;
                                    });
                                  },
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('Add'),
                                    onPressed: () {
                                      if (this
                                          .registeredUsersEmail
                                          .contains(this._enteredEmail)) {
                                        setState(() {
                                          this._isSharedListCreated = true;
                                        });

                                        Firestore.instance
                                            .collection(widget.user.email + '_shared')
                                            .add({
                                          'email': this._enteredEmail,
                                        });

                                        Firestore.instance
                                            .collection(this._enteredEmail + '_shared')
                                            .add({
                                          'email': widget.user.email,
                                        });

                                        Firestore.instance
                                            .collection(this._enteredEmail)
                                            .add({
                                          'email': this._enteredEmail,
                                          'shares_with': widget.user.email,
                                        });

                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                ],
                              );
                            });
                      }),
                  SizedBox(height: 20.0),
                  this._isSharedListCreated
                      ? Card(
                          child: ListTile(
                            title: Text("Shared list"),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          new GroupShoppingList(
                                            googleSignIn:
                                                this.widget.googleSignIn,
                                            user: this.widget.user,
                                            shareEmail: this.sharedUsersEmail,
                                          )));
                            },
                          ),
                        )
                      : Card(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
