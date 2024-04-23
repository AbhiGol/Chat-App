import 'package:firebase/pages/home.dart';
import 'package:firebase/pages/login.dart';
import 'package:firebase/pages/sign_up.dart';
import 'package:firebase/pages/status.dart';
import 'package:flutter/material.dart';

class Routes extends StatelessWidget {
  const Routes({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior()
          .copyWith(scrollbars: false, overscroll: false),
      initialRoute: '/login',
      routes: {
        '/signup': (context) => const SignUp(),
        '/login': (context) => const Login(),
        '/home': (context) => const Home(),
        '/status': (context) => const StatusPage(),

        //'/chatpage': (context) => const ChatPage(),
      },
    );
  }
}
