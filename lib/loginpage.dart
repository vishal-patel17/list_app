import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flare_flutter/flare_actor.dart";
import 'package:flutter_signin_button/flutter_signin_button.dart';

import './homepage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    currentSignedInGoogleUser();
    signedIn();
    currentSignedInFBUser();
  }

  bool _isSignedIn = false;
  bool _isLoading = false;
  FirebaseUser fbUser;
  GoogleSignInAccount account1;
  String _email;
  String _password;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  GoogleSignInAccount googleSignInAccount;
  GoogleSignInAuthentication gSA;
  FirebaseUser user;

  Future<FirebaseUser> signIn() async {
    setState(() {
      this._isLoading = true;
    });
    googleSignInAccount = await googleSignIn.signIn();
    gSA = await googleSignInAccount.authentication;

    user = await _auth.signInWithGoogle(
        idToken: gSA.idToken, accessToken: gSA.accessToken);
    setState(() {
      this.fbUser = user;
    });

    print("User name: ${user.displayName}");
    setState(() {
      this._isLoading = false;
    });
    return user;
  }

  void signOut() {
    googleSignIn.signOut();
    print('User Signed out!');
  }

  Future<bool> signedIn() async {
    bool value = await googleSignIn.isSignedIn();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (value == true) {
      setState(() {
        this._isSignedIn = true;
      });
    } else if (user.email.length > 0) {
      setState(() {
        this._isSignedIn = true;
      });
    } else {
      setState(() {
        this._isSignedIn = false;
      });
    }
    return this._isSignedIn;
  }

  Future<GoogleSignInAccount> currentSignedInGoogleUser() async {
    GoogleSignInAccount gSI = await googleSignIn.signInSilently();
    setState(() {
      this.account1 = gSI;
    });
    return gSI;
  }

  Future<FirebaseUser> currentSignedInFBUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user.email.length > 0) {
      setState(() {
        this._isSignedIn = true;
      });
    }
    setState(() {
      this.fbUser = user;
    });
    return user;
  }

  void routeToHomepage(user) {
    var route = new MaterialPageRoute(
      builder: (BuildContext context) => new HomePage(
            user: user,
            googleSignIn: googleSignIn,
            googleSignInAccount: this.googleSignInAccount,
          ),
    );
    Navigator.of(context).pushReplacement(route);
  }

  Widget _homeAnimation() {
    return new Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 98.0,
        child: Image.asset("assets/flutter_icon.png"),
      ),
    );
  }

  Widget showLogin(BuildContext context) {
    return DefaultTabController(
      //debugShowCheckedModeBanner: false,
      length: 2,
      child: Scaffold(
        //backgroundColor: Colors.white70,
        appBar: AppBar(
          //backgroundColor: Colors.transparent,
          elevation: 0.0,
          bottom: TabBar(
            tabs: [
              Tab(
                text: "Login",
              ),
              Tab(
                text: "Signup",
              ),
            ],
            labelColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            indicatorColor: Colors.white,
          ),
          //title: Text('Welcome to List'),
        ),
        body: TabBarView(
          children: [
            Container(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10.0, bottom: 10.0),
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      //_homeAnimation(),
                      TextField(
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (String value) {
                          setState(() {
                            this._email = value;
                          });
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0)),
                        ),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        onChanged: (String value) {
                          setState(() {
                            this._password = value;
                          });
                        },
                      ),
                      SizedBox(height: 10.0),
                      SignInButton(
                        Buttons.Email,
                        onPressed: () {
                          FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: this._email, password: this._password)
                              .then((FirebaseUser user) {
                            Navigator.of(context).pop();
                            routeToHomepage(user);
                          }).catchError((e) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Error: $e"),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('Try again'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                });
                          });
                        },
                      ),
                      SizedBox(height: 10.0),
                      SignInButton(
                        Buttons.Google,
                        onPressed: () => signIn().then((FirebaseUser user) {
                              setState(() {
                                this.fbUser = user;
                              });
                              Firestore.instance.collection('/users').add({
                                'email': user.email,
                                'uid': user.uid,
                              });
                              routeToHomepage(this.fbUser);
                            }).catchError((e) => print(e)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Page 2
            Container(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10.0, bottom: 10.0),
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      //_homeAnimation(),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Email',
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (String value) {
                          setState(() {
                            this._email = value;
                          });
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Password',
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0)),
                        ),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        onChanged: (String value) {
                          setState(() {
                            this._password = value;
                          });
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Re-enter Password',
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0)),
                        ),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        onChanged: (String value) {
                          setState(() {
                            //this._password = value;
                          });
                        },
                      ),
                      SizedBox(height: 10.0),
                      RaisedButton(
                        child: Text(
                          'Signup',
                          style: TextStyle(color: Colors.white),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: Colors.lightBlueAccent,
                        padding: EdgeInsets.all(12.0),
                        onPressed: () {
                          FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: this._email, password: this._password)
                              .then((FirebaseUser user) {
                            Firestore.instance.collection('/users').add({
                              'email': user.email,
                              'uid': user.uid,
                            }).then((value) {
                              Navigator.of(context).pop();
                              routeToHomepage(user);
                            }).catchError((e) {
                              print(e);
                            });
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isSignedIn) {
      return HomePage(
        user: this.fbUser,
        googleSignIn: this.googleSignIn,
        googleSignInAccount: this.account1,
      );
    } else {
      return _isLoading
          ? MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CircularProgressIndicator(),
//                      RaisedButton(
//                        child: Text('Go back to login screen'),
//                        onPressed: () => Navigator.push(
//                            context,
//                            MaterialPageRoute(
//                                builder: (BuildContext context) =>
//                                    new LoginPage())),
//                      ),
                    ],
                  ),
                ),
              ),
            )
          : showLogin(context);
    }
  }
}
