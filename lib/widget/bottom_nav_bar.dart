import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:temukerja_application/main_page/profile_screen.dart';
import 'package:temukerja_application/main_page/Jobs/uploadjob_screen.dart';

import '../main_page/companylist_screen.dart';
import '../main_page/Jobs/joblist_screen.dart';


// ignore: must_be_immutable
class BottomNavBar extends StatelessWidget {

  int indexNum = 0;

  BottomNavBar({super.key, required this.indexNum});

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: indexNum,
      items: const [
        Icon(Icons.work, size: 20, color: Colors.black,),
        Icon(Icons.home_work, size: 20, color: Colors.black,),
        Icon(Icons.add, size: 20, color: Colors.black,),
        Icon(Icons.person_pin, size: 20, color: Colors.black,),
      ],
      color: Colors.grey,
      backgroundColor: Colors.white,
      buttonBackgroundColor: Colors.white,
      height: 50,
      animationDuration: const Duration(
        milliseconds: 1000,
      ),
      animationCurve: Curves.easeInOutCubicEmphasized,
      onTap: (index){
        if(index == 0){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const JobListScreen()));
        }
        else if(index == 1){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CompanyListScreen()));
        }
        else if(index == 2){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UploadJob()));
        }
        else if(index == 3){
          final FirebaseAuth auth = FirebaseAuth.instance;
          final User? user = auth.currentUser;
          final String uid = user!.uid;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Profile(userID: uid,)));
        }
      },
    );
  }
}
