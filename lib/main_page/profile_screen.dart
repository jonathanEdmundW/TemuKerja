import 'package:flutter/material.dart';
import 'package:temukerja_application/service/global_methods.dart';

import '../widget/bottom_nav_bar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.grey,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Colors.grey,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.logout, size: 35, color: Colors.black,),
              tooltip: 'Go back to login menu',
              onPressed: () {
                GlobalMethod.logout(context: context);
              },
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(indexNum: 3,),
      ),
    );
  }
}
