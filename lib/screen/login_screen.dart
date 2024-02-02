import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:survey_app/data/colors.dart';
import 'package:survey_app/screen/home_screen.dart';
import 'package:survey_app/screen/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var _passwordVisible = false;
  var _isEmailValid = false;
  var _isPasswordValid = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future signIn() async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .then((value) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            )).then((value) => Navigator.pop(context)));
  }

  void validatePassword(String value) {
    RegExp regex =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    if (value.isEmpty) {
      _isPasswordValid = false;
    } else {
      if (!regex.hasMatch(value)) {
        _isPasswordValid = false;
      } else {
        _isPasswordValid = true;
      }
    }
  }

  void validateEmail(String email) {
    _isEmailValid = EmailValidator.validate(email);
  }

  void validationMessage(bool email, bool password) {
    if (_isEmailValid == true && _isPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.amber,
        content: Text("Success"),
      ));
    } else if (_isEmailValid == true && _isPasswordValid == false) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Password Fail"),
      ));
    } else if (_isEmailValid == false && _isPasswordValid == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Email Fail"),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: colorDeepBlue,
        content: Text("All Fail"),
      ));
    }
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
                onPressed: signIn,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 15)),
                child: const Text("Login"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()))
                      .then((value) => Navigator.pop(context));
                },
                child: const Text(
                  "Click for register",
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
