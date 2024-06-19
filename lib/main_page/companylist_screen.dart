import 'package:flutter/material.dart';
import 'package:temukerja_application/service/global_methods.dart';

import '../widget/bottom_nav_bar.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.grey,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Company List',
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
        bottomNavigationBar: BottomNavBar(indexNum: 1,),
      ),
    );
  }
}
