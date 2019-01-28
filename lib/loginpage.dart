import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flare_flutter/flare_actor.dart";
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

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
  String _repassword;

  bool _isObscured = true;
  Color _eyeButtonColor = Colors.grey;
  final _formKey = GlobalKey<FormState>();
  var passKey = GlobalKey<FormFieldState>();
  var emailKey = GlobalKey<FormFieldState>();

  String _userName;
  final _signUpformKey = GlobalKey<FormState>();

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

    setState(() {
      this._isLoading = false;
    });
    return user;
  }

  void signOut() {
    googleSignIn.signOut();
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
        this.fbUser = user;
      });
    }
    return user;
  }

  void routeToHomepage(user) {
    var route = new MaterialPageRoute(
      builder: (BuildContext context) => new HomePage(
            user: user,
            googleSignIn: googleSignIn,
            googleSignInAccount: this.googleSignInAccount,
            //userName: this._userName,
          ),
    );
    Navigator.of(context).pushReplacement(route);
  }

  Padding buildTitleLine() {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 38.0,
          height: 1.5,
          color: Colors.black,
        ),
      ),
    );
  }

  TextFormField buildUsernameTextField() {
    return TextFormField(
      onSaved: (usernameInput) => _userName = usernameInput,
      validator: (usernameInput) {
        if (usernameInput.isEmpty) {
          return 'Please enter an Username.';
        }
      },
      decoration: InputDecoration(
          labelText: 'Username', icon: Icon(Icons.person, color: Colors.grey)),
    );
  }

  TextFormField buildEmailTextField() {
    return TextFormField(
      key: emailKey,
      keyboardType: TextInputType.emailAddress,
      onSaved: (emailInput) => _email = emailInput,
      validator: (emailInput) {
        if (emailInput.isEmpty) {
          return 'Please enter an email';
        }
        Pattern pattern =
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
        RegExp regex = new RegExp(pattern);
        if (!regex.hasMatch(emailInput)) return 'Enter Valid Email';
      },
      decoration: InputDecoration(
        labelText: 'Email Address',
        icon: Icon(Icons.mail, color: Colors.grey),
      ),
    );
  }

  TextFormField buildSignupEmailTextField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      onSaved: (emailInput) => _email = emailInput,
      validator: (emailInput) {
        if (emailInput.isEmpty) {
          return 'Please enter an email';
        }
        Pattern pattern =
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
        RegExp regex = new RegExp(pattern);
        if (!regex.hasMatch(emailInput)) return 'Enter Valid Email';
      },
      decoration: InputDecoration(
          labelText: 'Email Address',
          icon: Icon(Icons.mail, color: Colors.grey)),
    );
  }

  TextFormField buildPasswordInput(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.text,
      onSaved: (passwordInput) => _password = passwordInput,
      validator: (passwordInput) {
        if (passwordInput.isEmpty) {
          return 'Please enter a password.';
        }
        if (passwordInput.length < 6) {
          return 'Password too short.';
        }
      },
      decoration: InputDecoration(
        labelText: 'Password',
        icon: Icon(Icons.lock, color: Colors.grey),
        suffixIcon: IconButton(
          onPressed: () {
            if (_isObscured) {
              setState(() {
                _isObscured = false;
                _eyeButtonColor = Theme.of(context).primaryColor;
              });
            } else {
              setState(() {
                _isObscured = true;
                _eyeButtonColor = Colors.grey;
              });
            }
          },
          icon: Icon(
            Icons.remove_red_eye,
            color: _eyeButtonColor,
          ),
        ),
      ),
      obscureText: _isObscured,
    );
  }

  TextFormField buildSignupPasswordInput(BuildContext context) {
    return TextFormField(
      key: passKey,
      keyboardType: TextInputType.text,
      onSaved: (passwordInput) => _password = passwordInput,
      validator: (passwordInput) {
        if (passwordInput.isEmpty) {
          return 'Please enter a password.';
        }
        if (passwordInput.length < 6) {
          return 'Password too short.';
        }
      },
      decoration: InputDecoration(
        labelText: 'Password',
        icon: Icon(Icons.lock, color: Colors.grey),
        suffixIcon: IconButton(
          onPressed: () {
            if (_isObscured) {
              setState(() {
                _isObscured = false;
                _eyeButtonColor = Theme.of(context).primaryColor;
              });
            } else {
              setState(() {
                _isObscured = true;
                _eyeButtonColor = Colors.grey;
              });
            }
          },
          icon: Icon(
            Icons.remove_red_eye,
            color: _eyeButtonColor,
          ),
        ),
      ),
      obscureText: _isObscured,
    );
  }

  TextFormField buildReenterPasswordInput(BuildContext context) {
    return TextFormField(
      onSaved: (repasswordInput) => _repassword = repasswordInput,
      validator: (repasswordInput) {
        var password = passKey.currentState.value;
        if (repasswordInput.isEmpty) {
          return 'Enter a matching password!';
        }
        if (repasswordInput != password) {
          return 'Password Does not match!';
        }
      },
      decoration: InputDecoration(
        labelText: 'Re-enter Password',
        icon: Icon(Icons.lock, color: Colors.grey),
        suffixIcon: IconButton(
          onPressed: () {
            if (_isObscured) {
              setState(() {
                _isObscured = false;
                _eyeButtonColor = Theme.of(context).primaryColor;
              });
            } else {
              setState(() {
                _isObscured = true;
                _eyeButtonColor = Colors.grey;
              });
            }
          },
          icon: Icon(
            Icons.remove_red_eye,
            color: _eyeButtonColor,
          ),
        ),
      ),
      obscureText: _isObscured,
    );
  }

  Padding buildPasswordText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: () {
            emailKey.currentState.validate()
                ? showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                            "Send password reset mail to ${emailKey.currentState.value}?"),
                        actions: <Widget>[
                          FlatButton(
                              onPressed: () {
                                FirebaseAuth.instance.sendPasswordResetEmail(
                                    email: emailKey.currentState.value);
                                Navigator.of(context).pop();
                              },
                              child: Text('Submit')),
                          FlatButton(
                            child: Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        ],
                      );
                    })
                : null;
          },
          child: Text(
            'Forgot Password?',
            style: TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Align buildLoginButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 50.0,
        width: 270.0,
        child: FlatButton(
          onPressed: () {
            if (_formKey.currentState.validate()) {
              _formKey.currentState.save();
              setState(() {
                this._isLoading = true;
              });
              FirebaseAuth.instance
                  .signInWithEmailAndPassword(
                      email: this._email, password: this._password)
                  .then((FirebaseUser user) {
                Navigator.of(context).pop();
                routeToHomepage(user);
              }).catchError((e) {
                setState(() {
                  this._isLoading = false;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Error: ${e.toString()}"),
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
            }
          },
          color: Colors.blue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          child: Text(
            'LOGIN',
            style: Theme.of(context).primaryTextTheme.button,
          ),
        ),
      ),
    );
  }

  Align buildSignUpButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 50.0,
        width: 270.0,
        child: FlatButton(
          onPressed: () {
            if (_signUpformKey.currentState.validate()) {
              //Only gets here if the fields pass
              _signUpformKey.currentState.save();
              setState(() {
                this._isLoading = true;
              });
              FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                      email: this._email, password: this._password)
                  .then((FirebaseUser user) {
                Firestore.instance.collection('/users').add({
                  'email': user.email,
                  'uid': user.uid,
                }).then((value) {
                  Firestore.instance.collection(user.email).add({
                    'username': this._userName,
                  });
                  Navigator.of(context).pop();
                  routeToHomepage(user);
                }).catchError((e) {
                  setState(() {
                    this._isLoading = false;
                  });
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Error: ${e.toString()}"),
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
              });
            }
          },
          color: Colors.blue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          child: Text(
            'SIGNUP',
            style: Theme.of(context).primaryTextTheme.button,
          ),
        ),
      ),
    );
  }

  Align buildOrText() {
    return Align(
      alignment: Alignment.center,
      child: Text(
        'or login with',
        style: TextStyle(fontSize: 12.0, color: Colors.grey),
      ),
    );
  }

  Align buildSignUpText() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: () {},
        child: RichText(
          text: TextSpan(
              text: 'Don\'t have an account?',
              style: TextStyle(fontSize: 12.0, color: Colors.grey),
              children: <TextSpan>[
                TextSpan(
                    text: ' SIGN UP',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: Colors.black)),
              ]),
        ),
      ),
    );
  }

  Form loginForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22.0, 0.0, 22.0, 22.0),
        children: <Widget>[
          SizedBox(height: kToolbarHeight),
          buildEmailTextField(),
          SizedBox(
            height: 30.0,
          ),
          buildPasswordInput(context),
          buildPasswordText(context),
          SizedBox(
            height: 70.0,
          ),
          buildLoginButton(context),
          SizedBox(
            height: 30.0,
          ),
          buildOrText(),
          SizedBox(
            height: 30.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GoogleSignInButton(onPressed: () {
                signIn().then((FirebaseUser user) {
                  setState(() {
                    this.fbUser = user;
                  });
                  Firestore.instance.collection('/users').add({
                    'email': user.email,
                    'uid': user.uid,
                  });
                  routeToHomepage(this.fbUser);
                }).catchError((e) => print(e));
              }),
            ],
          ),
        ],
      ),
    );
  }

  Form signUpForm() {
    return Form(
      key: _signUpformKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22.0, 0.0, 22.0, 22.0),
        children: <Widget>[
          SizedBox(height: kToolbarHeight),
          buildUsernameTextField(),
          SizedBox(
            height: 40.0,
          ),
          buildSignupEmailTextField(),
          SizedBox(
            height: 40.0,
          ),
          buildSignupPasswordInput(context),
          SizedBox(
            height: 40.0,
          ),
          buildReenterPasswordInput(context),
          SizedBox(
            height: 70.0,
          ),
          buildSignUpButton(context),
        ],
      ),
    );
  }

  Widget showLogin(BuildContext context) {
    return DefaultTabController(
      //debugShowCheckedModeBanner: false,
      length: 2,
      child: Scaffold(
        //backgroundColor: Colors.deepPurple,
        appBar: AppBar(
          //backgroundColor: Colors.transparent,
          //elevation: 0.0,
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
            loginForm(),
            signUpForm(),
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
        //userName: this._userName,
      );
    } else {
      return _isLoading
          ? Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            )
          : showLogin(context);
    }
  }
}
