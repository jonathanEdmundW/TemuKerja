// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:temukerja_application/job/joblist_screen.dart';

import 'intro/login_page/login_screen.dart';

class UserState extends StatefulWidget {
  const UserState({super.key});

  @override
  State<UserState> createState() => _UserStateState();
}

class _UserStateState extends State<UserState> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, userSnapshot){
        if(userSnapshot.data == null){
          print('User is not logged in yet');
          return const Login();
        } else if (userSnapshot.hasData){
          print('User is already logged in');
          return const JobListScreen();
        } else if (userSnapshot.hasError){
          return const Scaffold(
            body: Center(
              child: Text('An error has been occured, please try again'),
            ),
          );
        } else if (userSnapshot.connectionState == ConnectionState.waiting){
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return const Scaffold(
          body: Center(
            child: Text('Something went wrong'),
          ),
        );
      },
    );
  }
}
