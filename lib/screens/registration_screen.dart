import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat_flutterapp/rounded_button.dart';
import 'package:flash_chat_flutterapp/constants.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'r';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late String email;
  late String password;
  late String confirmPassword;
  bool visibility1 = false;
  bool progressSpinner = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      color: Colors.blue,
      progressIndicator: const CircularProgressIndicator(),
      inAsyncCall: progressSpinner,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
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
              const SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                onChanged: (value) {
                  confirmPassword = value;
                },
                decoration: kInputDecoration.copyWith(
                  hintText: 'Enter your password again',
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Visibility(
                visible: visibility1,
                child: Container(
                  child: const Text(
                    'Password mismatch!!!',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: visibility1,
                child: const SizedBox(
                  height: 24.0,
                ),
              ),
              RoundedButton(
                text: 'Register',
                colour: Colors.blueAccent,
                onTapped: () async {
                  setState(() {
                    progressSpinner = true;
                  });
                  if (password != confirmPassword) {
                    setState(() {
                      visibility1 = true;
                    });
                  } else {
                    try {
                      final newUser =
                          await _auth.createUserWithEmailAndPassword(
                              email: email, password: password);
                      if (newUser != null) {
                        Navigator.pushNamed(context, ChatScreen.id);
                      }
                    } catch (e) {
                      print(e);
                    }
                  }
                  setState(() {
                    progressSpinner = false;
                    visibility1 = false;
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
