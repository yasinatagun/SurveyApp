// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:survey_app/data/user.dart';
import 'package:survey_app/screen/home_screen.dart';
import 'package:survey_app/screen/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var nameController = TextEditingController();
  var _passwordVisible = false;
  var _isEmailValid = false;

  var db = FirebaseFirestore.instance;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void validateEmail(String email) {
    _isEmailValid = EmailValidator.validate(email);
  }

  Future signUp() async {
    validateEmail(emailController.text);
    if (_isEmailValid && nameController.text.isNotEmpty) {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          )
          .then((value) {
            var user = SurveyUser(
                name: nameController.text, email: emailController.text);
            saveToDatabase(user.name, user.email);
          })
          .then((value) => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const HomeScreen())))
          .then((value) => Navigator.pop(context));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Color.fromARGB(255, 32, 3, 114),
        content: Text("Not Correct Email Adress"),
      ));
    }
  }

  Future<void> saveToDatabase(String name, String email) async {
    var userMap = {
      "name": name,
      "email": email,
    };
    db.collection("users").doc(email).set(userMap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigoAccent.shade100,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                keyboardType: TextInputType.text,
                controller: nameController,
                obscureText: false, //This will obscure text dynamically
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  labelText: 'Name',
                  hintText: 'Enter your name',
                  // Here is key idea
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Based on passwordVisible state choose the icon
                      Icons.person,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                obscureText: false, //This will obscure text dynamically
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,

                  labelText: 'Email',
                  hintText: 'Enter your email',
                  // Here is key idea
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Based on passwordVisible state choose the icon
                      Icons.email,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                controller: passwordController,
                obscureText:
                    !_passwordVisible, //This will obscure text dynamically
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  // Here is key idea
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Based on passwordVisible state choose the icon
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      // Update the state i.e. toogle the state of passwordVisible variable
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              ElevatedButton(
                onPressed: () {
                  signUp();
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 15)),
                child: const Text("Register"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  ).then((value) => Navigator.pop(context));
                },
                child: const Text(
                  "Already have an account? Click",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
