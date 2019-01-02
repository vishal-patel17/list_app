import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './loginpage.dart';
import './shopping_list.dart';
import './task_list.dart';
import './group_shopping_list.dart';
import './group_task_list.dart';
import './group_chat.dart';

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
    super.initState();
    listOfRegisteredUsers();
    listOfSharedUsers();
    getSharedUsersEmail();
  }

  final List<String> registeredUsersEmail = [];
  final List<String> sharedUsersEmailList = [];
  String sharedUsersEmail;
  String _enteredEmail;
  bool _isSharedListCreated = false;
  bool _isButtonDisabled = false;

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
    Stream<QuerySnapshot> snapshots = Firestore.instance
        .collection(widget.user.email + '_shared')
        .snapshots();
    snapshots.listen((data) {
      data.documents.forEach((doc) {
        setState(() {
          this.sharedUsersEmail = (doc['email']);
        });
      });
    });
    return snapshots;
  }

  Stream<QuerySnapshot> getSharedUsersEmail() {
    Stream<QuerySnapshot> snapshots =
        Firestore.instance.collection('shared_list').snapshots();
    snapshots.listen((data) {
      data.documents.forEach((doc) {
        setState(() {
          this.sharedUsersEmailList.add(doc['email']);
        });
      });
    });
    return snapshots;
  }

  Future<Null> refreshPage() async {
    await Future.delayed(Duration(seconds: 1));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => HomePage(
                googleSignIn: widget.googleSignIn,
                user: widget.user,
                googleSignInAccount: widget.googleSignInAccount,
              )),
    );

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (this.sharedUsersEmail != null) {
      setState(() {
        this._isSharedListCreated = true;
        this._isButtonDisabled = true;
      });
    }
    //print(sharedUsers);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
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
            ),
          ],
          title: Text("Lists"),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Center(child: Text("${widget.user.displayName!=null? widget.user.displayName: widget.user.email}")),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: this._isSharedListCreated
            ? FloatingActionButton(
                child: Icon(Icons.chat),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => new GroupChat())),
              )
            : null,
        body: RefreshIndicator(
          onRefresh: refreshPage,
          child: Center(
            child: Container(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, top: 18.0),
                child: ListView(
                  //shrinkWrap: true,
                  children: <Widget>[
                    RaisedButton(
                      child: Text('Shopping List'),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new ShoppingList(
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
                    _isButtonDisabled
                        ? SizedBox(height: 20.0)
                        : RaisedButton(
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
                                        keyboardType:
                                            TextInputType.emailAddress,
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
                                                .sharedUsersEmailList
                                                .contains(this._enteredEmail)) {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          "${this._enteredEmail} already shares a list!"),
                                                      content: Text(
                                                          'Please enter another registered email'),
                                                      actions: <Widget>[
                                                        FlatButton(
                                                          child:
                                                              Icon(Icons.close),
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            } else if (this
                                                .registeredUsersEmail
                                                .contains(this._enteredEmail)) {
                                              setState(() {
                                                this._isSharedListCreated =
                                                    true;
                                              });

                                              Firestore.instance
                                                  .collection('shared_list')
                                                  .add({
                                                'email': this._enteredEmail,
                                              });

                                              Firestore.instance
                                                  .collection('shared_list')
                                                  .add({
                                                'email': widget.user.email,
                                              });

                                              Firestore.instance
                                                  .collection(
                                                      widget.user.email +
                                                          '_shared')
                                                  .add({
                                                'email': this._enteredEmail,
                                              });

                                              Firestore.instance
                                                  .collection(
                                                      this._enteredEmail +
                                                          '_shared')
                                                  .add({
                                                'email': widget.user.email,
                                              });

                                              Firestore.instance
                                                  .collection(
                                                      this._enteredEmail)
                                                  .add({
                                                'email': this._enteredEmail,
                                                'shares_with':
                                                    widget.user.email,
                                              });

                                              Navigator.pop(context);
                                              setState(() {
                                                this._isButtonDisabled = true;
                                              });
                                            } else {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          "${this._enteredEmail} is not registered!"),
                                                      content: Text(
                                                          'Please enter a registered email'),
                                                      actions: <Widget>[
                                                        FlatButton(
                                                          child:
                                                              Icon(Icons.close),
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            }
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            }),
                    SizedBox(height: 20.0),
                    this._isSharedListCreated
                        ? ListView(
                            shrinkWrap: true,
                            children: <Widget>[
                              Card(
                                child: ListTile(
                                  title: Text("Shared Shopping List"),
                                  subtitle:
                                      Text("with ${this.sharedUsersEmail}"),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                new GroupShoppingList(
                                                  googleSignIn:
                                                      this.widget.googleSignIn,
                                                  user: this.widget.user,
                                                  shareEmail:
                                                      this.sharedUsersEmail,
                                                )));
                                  },
                                  onLongPress: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Delete shared list?"),
                                            content: Text(
                                                'All items inside the list will be deleted as well'),
                                            actions: <Widget>[
                                              FlatButton(
                                                  child: Icon(Icons.delete),
                                                  onPressed: () {
                                                    Firestore.instance
                                                        .collection(
                                                            widget.user.email +
                                                                '_shared')
                                                        .getDocuments()
                                                        .then((snapshot) {
                                                      for (DocumentSnapshot ds
                                                          in snapshot
                                                              .documents) {
                                                        ds.reference.delete();
                                                      }
                                                    });

                                                    Firestore.instance
                                                        .collection(
                                                            this.sharedUsersEmail +
                                                                '_shared')
                                                        .getDocuments()
                                                        .then((snapshot) {
                                                      for (DocumentSnapshot ds
                                                          in snapshot
                                                              .documents) {
                                                        ds.reference.delete();
                                                      }
                                                    });

                                                    Firestore.instance
                                                        .collection(
                                                            widget.user.email)
                                                        .getDocuments()
                                                        .then((snapshot) {
                                                      for (DocumentSnapshot ds
                                                          in snapshot
                                                              .documents) {
                                                        ds.reference.delete();
                                                      }
                                                    });

                                                    Firestore.instance
                                                        .collection(this
                                                            .sharedUsersEmail)
                                                        .getDocuments()
                                                        .then((snapshot) {
                                                      for (DocumentSnapshot ds
                                                          in snapshot
                                                              .documents) {
                                                        ds.reference.delete();
                                                      }
                                                    });

                                                    Firestore.instance
                                                        .collection(widget
                                                                .user.email +
                                                            this.sharedUsersEmail +
                                                            '_shoppingList')
                                                        .getDocuments()
                                                        .then((snapshot) {
                                                      for (DocumentSnapshot ds
                                                          in snapshot
                                                              .documents) {
                                                        ds.reference.delete();
                                                      }
                                                    });

                                                    Firestore.instance
                                                        .collection(this
                                                                .sharedUsersEmail +
                                                            widget.user.email +
                                                            '_shoppingList')
                                                        .getDocuments()
                                                        .then((snapshot) {
                                                      for (DocumentSnapshot ds
                                                          in snapshot
                                                              .documents) {
                                                        ds.reference.delete();
                                                      }
                                                    });

                                                    Firestore.instance
                                                        .collection(widget
                                                                .user.email +
                                                            this.sharedUsersEmail +
                                                            '_taskList')
                                                        .getDocuments()
                                                        .then((snapshot) {
                                                      for (DocumentSnapshot ds
                                                          in snapshot
                                                              .documents) {
                                                        ds.reference.delete();
                                                      }
                                                    });

                                                    Firestore.instance
                                                        .collection(this
                                                                .sharedUsersEmail +
                                                            widget.user.email +
                                                            '_taskList')
                                                        .getDocuments()
                                                        .then((snapshot) {
                                                      for (DocumentSnapshot ds
                                                          in snapshot
                                                              .documents) {
                                                        ds.reference.delete();
                                                      }
                                                    });

                                                    Firestore.instance
                                                        .collection(
                                                            'shared_list')
                                                        .getDocuments()
                                                        .then((snapshot) {
                                                      for (DocumentSnapshot ds
                                                          in snapshot
                                                              .documents) {
                                                        if (ds.data['email'] ==
                                                            widget.user.email)
                                                          ds.reference.delete();
                                                      }
                                                    });

                                                    Firestore.instance
                                                        .collection(
                                                            'shared_list')
                                                        .getDocuments()
                                                        .then((snapshot) {
                                                      for (DocumentSnapshot ds
                                                          in snapshot
                                                              .documents) {
                                                        if (ds.data['email'] ==
                                                            this.sharedUsersEmail)
                                                          ds.reference.delete();
                                                      }
                                                    });
                                                    this.refreshPage();
                                                    Navigator.of(context).pop();
                                                  }),
                                            ],
                                          );
                                        });
                                  },
                                ),
                              ),
                              Card(
                                child: ListTile(
                                  title: Text("Shared Task List"),
                                  subtitle:
                                      Text("with ${this.sharedUsersEmail}"),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                new GroupTaskList(
                                                  googleSignIn:
                                                      this.widget.googleSignIn,
                                                  user: this.widget.user,
                                                  shareEmail:
                                                      this.sharedUsersEmail,
                                                )));
                                  },
                                ),
                              ),
                              SizedBox(height: 20.0),
                            ],
                          )
                        : Card(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
