import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupShoppingList extends StatefulWidget {
  final GoogleSignIn googleSignIn;
  final FirebaseUser user;
  final String shareEmail;
  GroupShoppingList({Key key, this.googleSignIn, this.user, this.shareEmail})
      : super(key: key);
  _GroupShoppingListState createState() => _GroupShoppingListState();
}

class _GroupShoppingListState extends State<GroupShoppingList> {
  //FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  void initState() {
    super.initState();
    listOfSharedUsers();
  }

  String item;
  String sharedUsersEmail;

  Stream<QuerySnapshot> listOfSharedUsers() {
    Stream<QuerySnapshot> snapshots =
        Firestore.instance.collection(widget.user.email).snapshots();
    snapshots.listen((data) {
      data.documents.forEach((doc) {
        setState(() {
          this.sharedUsersEmail = (doc['shares_with']);
        });
      });
    });
    return snapshots;
  }

  @override
  Widget build(BuildContext context) {
    return this.sharedUsersEmail != null
        ? MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              appBar: AppBar(
                title: Text("Shopping List"),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Enter an item to purchase"),
                          content: TextField(
                            autofocus: true,
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.text,
                            onChanged: (String value) {
                              setState(() {
                                this.item = value;
                              });
                            },
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Icon(Icons.add_shopping_cart),
                              onPressed: () {
                                Firestore.instance.runTransaction(
                                    (Transaction transaction) async {
                                  CollectionReference reference = Firestore
                                      .instance
                                      .collection(this.sharedUsersEmail +
                                          widget.user.email +
                                          '_shoppingList');
                                  await reference.add({"name": item});
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
                child: Icon(Icons.add_shopping_cart),
              ),
              body: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection(
                        this.sharedUsersEmail + widget.user.email + '_shoppingList')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError)
                    return Text('Error: ${snapshot.error}');
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                                child: FlareActor(
                              "assets/Loading_cart.flr",
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                              animation: "cart_loading",
                            ))
                          ],
                        ),
                      );
                    default:
                      return ListView(
                        children: snapshot.data.documents
                            .map((DocumentSnapshot document) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: ListTile(
                                title: Text(
                                  document['name'],
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Purchased " +
                                              document['name'] +
                                              " ?"),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Icon(Icons.done),
                                              onPressed: () {
                                                Firestore.instance
                                                    .collection(
                                                        this.sharedUsersEmail +
                                                            widget.user.email +
                                                            '_shoppingList')
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
                          );
                        }).toList(),
                      );
                  }
                },
              ),
            ),
          )
        : MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              appBar: AppBar(
                title: Text("Shopping List"),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Enter an item to purchase"),
                          content: TextField(
                            autofocus: true,
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.text,
                            onChanged: (String value) {
                              setState(() {
                                this.item = value;
                              });
                            },
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Icon(Icons.add_shopping_cart),
                              onPressed: () {
                                Firestore.instance.runTransaction(
                                    (Transaction transaction) async {
                                  CollectionReference reference = Firestore
                                      .instance
                                      .collection(widget.user.email +
                                          widget.shareEmail +
                                          '_shoppingList');
                                  await reference.add({"name": item});
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
                child: Icon(Icons.add_shopping_cart),
              ),
              body: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection(
                        widget.user.email + widget.shareEmail + '_shoppingList')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError)
                    return Text('Error: ${snapshot.error}');
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                                child: FlareActor(
                              "assets/Loading_cart.flr",
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                              animation: "cart_loading",
                            ))
                          ],
                        ),
                      );
                    default:
                      return ListView(
                        children: snapshot.data.documents
                            .map((DocumentSnapshot document) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: ListTile(
                                title: Text(
                                  document['name'],
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Purchased " +
                                              document['name'] +
                                              " ?"),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Icon(Icons.done),
                                              onPressed: () {
                                                Firestore.instance
                                                    .collection(
                                                        widget.user.email +
                                                            widget.shareEmail +
                                                            '_shoppingList')
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
                          );
                        }).toList(),
                      );
                  }
                },
              ),
            ),
          );
  }
}
