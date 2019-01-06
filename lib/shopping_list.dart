import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShoppingList extends StatefulWidget {
  final GoogleSignIn googleSignIn;
  final FirebaseUser user;
  final String list;
  ShoppingList({Key key, this.googleSignIn, this.user, this.list})
      : super(key: key);
  _ShoppingListState createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  //FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  void initState() {
    super.initState();

    getItemCount();
  }

  String item;

  Future<Null> refreshPage() async {
    await Future.delayed(Duration(seconds: 1));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => ShoppingList(
                googleSignIn: widget.googleSignIn,
                user: widget.user,
                list: widget.list,
              )),
    );

    return null;
  }

  String _count;

  Future<QuerySnapshot> getItemCount() async {
    QuerySnapshot snapshots = await Firestore.instance
        .collection(widget.user.email + '_' + widget.list)
        .getDocuments();

    setState(() {
      this._count = snapshots.documents.length.toString();
    });

    return snapshots;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        //backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        appBar: AppBar(
          //elevation: 0.1,
          //backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          title:
              Text(widget.list + this._count, style: TextStyle(fontSize: 25.0)),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("New ${widget.list}"),
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
                        child: Text('Add'),
                        onPressed: () {
                          Firestore.instance
                              .runTransaction((Transaction transaction) async {
                            CollectionReference reference = Firestore.instance
                                .collection(
                                    widget.user.email + '_' + widget.list);
                            await reference.add({"name": item});
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                });
          },
          child: Icon(Icons.add),
        ),
        body: RefreshIndicator(
          onRefresh: refreshPage,
          child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection(widget.user.email + '_' + widget.list)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
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
                          elevation: 10.0,
                          margin: new EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                          child: ListTile(
                            leading: Container(
                              padding: EdgeInsets.only(right: 12.0),
                              decoration: new BoxDecoration(
                                  border: new Border(
                                      right: new BorderSide(
                                          width: 1.0, color: Colors.black12))),
                              child: Icon(Icons.list, color: Colors.black),
                            ),
                            title: Text(
                              document['name'],
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            trailing: IconButton(
                                icon: Icon(Icons.done,
                                    color: Colors.black, size: 30.0),
                                onPressed: () {
                                  Firestore.instance
                                      .collection(
                                          widget.user.email + '_' + widget.list)
                                      .document(document.documentID)
                                      .delete();
                                }),
                            onLongPress: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                          "Delete " + document['name'] + " ?"),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Icon(Icons.done),
                                          onPressed: () {
                                            Firestore.instance
                                                .collection(widget.user.email +
                                                    '_' +
                                                    widget.list)
                                                .document(document.documentID)
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
      ),
    );
  }
}
