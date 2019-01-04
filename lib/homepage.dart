import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './loginpage.dart';
import './shopping_list.dart';
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
  String _newList;
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

  void createSharedList(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Enter registered email of the person"),
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
                  if (this.sharedUsersEmailList.contains(this._enteredEmail)) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                                "${this._enteredEmail} already shares a list!"),
                            content:
                                Text('Please enter another registered email'),
                            actions: <Widget>[
                              FlatButton(
                                child: Icon(Icons.close),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          );
                        });
                  } else if (this
                      .registeredUsersEmail
                      .contains(this._enteredEmail)) {
                    setState(() {
                      this._isSharedListCreated = true;
                    });

                    Firestore.instance.collection('shared_list').add({
                      'email': this._enteredEmail,
                    });

                    Firestore.instance.collection('shared_list').add({
                      'email': widget.user.email,
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

                    Firestore.instance.collection(this._enteredEmail).add({
                      'email': this._enteredEmail,
                      'shares_with': widget.user.email,
                    });

                    Navigator.pop(context);
                    setState(() {
                      this._isButtonDisabled = true;
                    });
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                                "${this._enteredEmail} is not registered!"),
                            content: Text('Please enter a registered email'),
                            actions: <Widget>[
                              FlatButton(
                                child: Icon(Icons.close),
                                onPressed: () => Navigator.of(context).pop(),
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
  }

  void deleteSharedList(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Delete shared list?"),
            content: Text('All items inside the list will be deleted as well'),
            actions: <Widget>[
              FlatButton(
                  child: Icon(Icons.delete),
                  onPressed: () {
                    Firestore.instance
                        .collection(widget.user.email + '_shared')
                        .getDocuments()
                        .then((snapshot) {
                      for (DocumentSnapshot ds in snapshot.documents) {
                        ds.reference.delete();
                      }
                    });

                    Firestore.instance
                        .collection(this.sharedUsersEmail + '_shared')
                        .getDocuments()
                        .then((snapshot) {
                      for (DocumentSnapshot ds in snapshot.documents) {
                        ds.reference.delete();
                      }
                    });

                    Firestore.instance
                        .collection(widget.user.email)
                        .getDocuments()
                        .then((snapshot) {
                      for (DocumentSnapshot ds in snapshot.documents) {
                        ds.reference.delete();
                      }
                    });

                    Firestore.instance
                        .collection(this.sharedUsersEmail)
                        .getDocuments()
                        .then((snapshot) {
                      for (DocumentSnapshot ds in snapshot.documents) {
                        ds.reference.delete();
                      }
                    });

                    Firestore.instance
                        .collection(widget.user.email +
                            this.sharedUsersEmail +
                            '_shoppingList')
                        .getDocuments()
                        .then((snapshot) {
                      for (DocumentSnapshot ds in snapshot.documents) {
                        ds.reference.delete();
                      }
                    });

                    Firestore.instance
                        .collection(this.sharedUsersEmail +
                            widget.user.email +
                            '_shoppingList')
                        .getDocuments()
                        .then((snapshot) {
                      for (DocumentSnapshot ds in snapshot.documents) {
                        ds.reference.delete();
                      }
                    });

                    Firestore.instance
                        .collection(widget.user.email +
                            this.sharedUsersEmail +
                            '_taskList')
                        .getDocuments()
                        .then((snapshot) {
                      for (DocumentSnapshot ds in snapshot.documents) {
                        ds.reference.delete();
                      }
                    });

                    Firestore.instance
                        .collection(this.sharedUsersEmail +
                            widget.user.email +
                            '_taskList')
                        .getDocuments()
                        .then((snapshot) {
                      for (DocumentSnapshot ds in snapshot.documents) {
                        ds.reference.delete();
                      }
                    });

                    Firestore.instance
                        .collection('shared_list')
                        .getDocuments()
                        .then((snapshot) {
                      for (DocumentSnapshot ds in snapshot.documents) {
                        if (ds.data['email'] == widget.user.email)
                          ds.reference.delete();
                      }
                    });

                    Firestore.instance
                        .collection('shared_list')
                        .getDocuments()
                        .then((snapshot) {
                      for (DocumentSnapshot ds in snapshot.documents) {
                        if (ds.data['email'] == this.sharedUsersEmail)
                          ds.reference.delete();
                      }
                    });
                    this.refreshPage();
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }

  Widget personalList(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Enter name"),
                  content: TextField(
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.text,
                    onChanged: (String value) {
                      setState(() {
                        this._newList = value;
                      });
                    },
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Icon(Icons.add),
                      onPressed: () {
                        Firestore.instance
                            .collection(widget.user.email + '_list')
                            .add({
                          'list': this._newList,
                        });

                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Icon(Icons.cancel),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
        },
      ),
      body: RefreshIndicator(
        onRefresh: refreshPage,
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection(widget.user.email + '_list')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
              default:
                return snapshot.data.documents.length > 0
                    ? ListView(
                        children: snapshot.data.documents
                            .map((DocumentSnapshot document) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              elevation: 8.0,
                              margin: new EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 6.0),
                              child: Container(
                                decoration: BoxDecoration(color: Colors.white),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 30.0, vertical: 50.0),
                                  trailing: Icon(Icons.keyboard_arrow_right,
                                      color: Colors.grey, size: 30.0),
                                  title: Text(
                                    document['list'],
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  subtitle: Row(
                                    children: <Widget>[
                                      Icon(Icons.linear_scale, color: Colors.red),
                                      Text(" Meta Data ", style: TextStyle(color: Colors.black))
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                new ShoppingList(
                                                  googleSignIn:
                                                      this.widget.googleSignIn,
                                                  user: this.widget.user,
                                                  list: document['list'],
                                                )));
                                  },
                                  onLongPress: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Delete " +
                                                document['list'] +
                                                " ?"),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Icon(Icons.done),
                                                onPressed: () {
                                                  Firestore.instance
                                                      .collection(
                                                          widget.user.email +
                                                              '_' +
                                                              document['list'])
                                                      .document(
                                                          document.documentID)
                                                      .delete();

                                                  Firestore.instance
                                                      .collection(
                                                          widget.user.email +
                                                              '_list')
                                                      .document(
                                                          document.documentID)
                                                      .delete();

                                                  Navigator.pop(context);
                                                },
                                              ),
                                              FlatButton(
                                                child: Icon(Icons.cancel),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        });
                                  },
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : Firestore.instance
                        .collection(widget.user.email + '_list')
                        .add({
                        'list': 'Task list',
                      }).then((value) {
                        Firestore.instance
                            .collection(widget.user.email + '_list')
                            .add({
                          'list': 'Shopping list',
                        });
                      });
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (this.sharedUsersEmail != null) {
      setState(() {
        this._isSharedListCreated = true;
        this._isButtonDisabled = true;
      });
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        //backgroundColor: Colors.transparent,
        appBar: AppBar(
          //elevation: 0.0,
          //backgroundColor: Colors.green,
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
                }),
          ],
          title: Text("Welcome ${widget.user.email}"),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.person),
              ),
              Tab(
                icon: Icon(Icons.group),
              ),
            ],
            labelColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            indicatorColor: Colors.white,
          ),
        ),
        body: TabBarView(children: [
          //Page 1
          personalList(context),

          //Page 2

          Scaffold(
            floatingActionButton: this._isSharedListCreated
                ? FloatingActionButton(
                    heroTag: 'fbtn_chat',
                    child: Icon(Icons.chat),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => GroupChat())),
                  )
                : null,
            body: RefreshIndicator(
              onRefresh: refreshPage,
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _isButtonDisabled
                        ? SizedBox(height: 20.0)
                        : RaisedButton(
                            child: Text('Create Sharing List'),
                            onPressed: () => createSharedList(context)),
                  ),
                  this._isSharedListCreated
                      ? ListView(
                          shrinkWrap: true,
                          children: <Widget>[
                            Card(
                              child: ListTile(
                                title: Text("Shared Shopping List"),
                                subtitle: Text("with ${this.sharedUsersEmail}"),
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
                                onLongPress: () => deleteSharedList(context),
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Card(
                              child: ListTile(
                                title: Text("Shared Task List"),
                                subtitle: Text("with ${this.sharedUsersEmail}"),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            new GroupTaskList(
                                              googleSignIn:
                                                  this.widget.googleSignIn,
                                              user: this.widget.user,
                                              shareEmail: this.sharedUsersEmail,
                                            ),
                                      ));
                                },
                                onLongPress: () => deleteSharedList(context),
                              ),
                            ),
                          ],
                        )
                      : Card(),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
