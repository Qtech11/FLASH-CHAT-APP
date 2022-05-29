import 'package:flash_chat_flutterapp/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat_flutterapp/rounded_button.dart';
import 'package:flash_chat_flutterapp/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'l';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool visibility = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  String errorText = 'Invalid username or password';
  bool progressSpinner = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: progressSpinner,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: SizedBox(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              const SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  email = value;
                },
                decoration: kInputDecoration.copyWith(
                  hintText: 'Enter your email',
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
                decoration: kInputDecoration.copyWith(
                  hintText: 'Enter your password',
                ),
              ),
              Visibility(
                visible: visibility,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Text(
                    errorText,
                    style: TextStyle(color: Colors.red, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              RoundedButton(
                text: 'Log In',
                colour: Colors.lightBlueAccent,
                onTapped: () async {
                  setState(() {
                    progressSpinner = true;
                    visibility = false;
                  });
                  try {
                    final user = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    if (user != null) {
                      Navigator.pushNamed(context, ChatScreen.id);
                    }
                  } catch (e) {
                    print(e);
                    setState(() {
                      visibility = true;
                    });
                  }
                  setState(() {
                    progressSpinner = false;
                    //visibility = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
