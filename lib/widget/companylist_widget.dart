import 'package:flutter/material.dart';
import 'package:temukerja_application/main_page/profile_screen.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../service/global_variables.dart';

class CompanyListWidget extends StatefulWidget {
  const CompanyListWidget({super.key,
    required this.userID,
    required this.userName,
    required this.userEmail,
    required this.phoneNumber,
    required this.userImageURL,
  });

  final String userID;
  final String userName;
  final String userEmail;
  final String phoneNumber;
  final String userImageURL;

  @override
  State<CompanyListWidget> createState() => _CompanyListWidget();
}

class _CompanyListWidget extends State<CompanyListWidget> {

  void _mailTo() async {

    var mailURL = 'mailto: ${widget.userEmail}';
    // ignore: avoid_print
    print('widget.userEmail ${widget.userEmail}');

    if(await canLaunchUrlString(mailURL)){
      await launchUrlString(mailURL);
    } else {
      // ignore: avoid_print
      print('error');
      throw 'Error Occured';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: ListTile(
        onTap: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Profile(userID: widget.userID)));
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.only(right: 12),
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(
                width: 1,
              ),
            ),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 20,
            child: Image.network(
                // ignore: unnecessary_null_comparison, prefer_if_null_operators
                widget.userImageURL == null
                ?
                  defaultProfileIconURL
                :
                  widget.userImageURL
            ),
          ),
        ),
        title: Text(
          widget.userName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Visit Profile',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.mail_outline,
            size: 30,
            color: Colors.grey,
          ),
          onPressed: (){
            _mailTo();
          },
        ),
      ),
    );
  }
}
