import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:temukerja_application/user_state.dart';

class GlobalMethod
{
  static void showErrorDialog({required String error, required BuildContext ctx})
  {
    showDialog(
        context: ctx,
        builder: (context)
        {
          return AlertDialog(
            title: const Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.logout,
                    color: Colors.grey,
                    size: 35,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Error Occured',
                  ),
                ),
              ],
            ),
            content: Text(
              error,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.red
                  ),
                ),
              ),
            ],
          );
        }
    );
  }

  static void logout({required context}){
    final FirebaseAuth auth = FirebaseAuth.instance;

    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          backgroundColor: Colors.black54,
          title: const Row(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.logout,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Sign out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Do you want to log out?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.canPop(context) ? Navigator.pop(context) : null;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserState()));
              },
              child: const Text('No', style: TextStyle(color: Colors.green, fontSize: 20),),
            ),
            TextButton(
              onPressed: (){
                auth.signOut();
                Navigator.canPop(context) ? Navigator.pop(context) : null;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserState()));
              },
              child: const Text('Yes', style: TextStyle(color: Colors.green, fontSize: 20),),
            ),
          ],
        );
      },
    );
  }
}

class Persistent{
  static List<String> jobCategoryList = [
    'Information Technology',
    'Business and Marketing',
    'Education and Training',
    'Healthcare',
    'Labor',
    'Design',
    'Etc',
  ];
}