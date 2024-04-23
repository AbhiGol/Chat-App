import 'package:firebase/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
// Text Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordsController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isvisible = true;

// Firebase Database Reference
  final firestore = FirebaseFirestore.instance;

  get data => null;

// For Sign Up method
  void signup(BuildContext context) async {
    final auth = AuthService();

    try {
      auth
          .signUp(_emailController.text, _passwordController.text,
              _usernameController.text)
          .then((value) => Navigator.pushNamed(context, '/home'));
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        margin:
            const EdgeInsets.only(top: 238, bottom: 238, left: 50, right: 50),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              offset: Offset(
                2.0,
                3.0,
              ),
              blurRadius: 2.0,
              spreadRadius: 1.0,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(0.0, 0.0),
              blurRadius: 0.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 15, left: 20, right: 20),
                decoration: BoxDecoration(
                    //color: Colors.amber,
                    borderRadius: BorderRadius.circular(25)),
                child: TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    label: Text("User Name"),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your username";
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 15, left: 20, right: 20),
                decoration: BoxDecoration(
                    //color: Colors.amber,
                    borderRadius: BorderRadius.circular(25)),
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    label: Text("Email"),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "please enter an email";
                    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 15, left: 20, right: 20),
                decoration: BoxDecoration(
                    //color: Colors.amber,
                    borderRadius: BorderRadius.circular(25)),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    label: const Text("Password"),
                    suffixIcon: IconButton(
                      icon: Icon(
                          isvisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          isvisible = !isvisible;
                        });
                      },
                    ),
                  ),
                  obscureText: isvisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a password.";
                    } else if (value.length < 6) {
                      return "Please enter password at least 6 characters.";
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 15, left: 20, right: 20),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(25)),
                child: TextFormField(
                  controller: _confirmpasswordsController,
                  decoration: InputDecoration(
                    label: const Text("Confirm Password"),
                    suffixIcon: IconButton(
                      icon: Icon(
                          isvisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          isvisible = !isvisible;
                        });
                      },
                    ),
                  ),
                  obscureText: isvisible,
                  validator: (value) {
                    if (_passwordController.text !=
                        _confirmpasswordsController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
              ),
              GestureDetector(
                child: Container(
                  width: 270,
                  height: 50,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 30),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.amber),
                  child: const Text("Sign Up", style: TextStyle(fontSize: 20)),
                ),
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Sign Up Successfull")));
                    signup(context);
                  }
                },
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: TextButton(
                  child: const Text(
                    "Already have an account? Login here.",
                    style: TextStyle(fontSize: 17),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
