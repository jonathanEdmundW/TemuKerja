import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../service/global_methods.dart';
import '../service/global_variables.dart';
import '../widget/bottom_nav_bar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key,
    required this.userID,
  });

  final String userID;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  String? name;
  String email = '';
  String phoneNumber = '';
  String imageURL = '';
  String joinedAt = '';
  bool _isLoading = false;
  bool _isSameUser = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void getUserData() async {
    try{
      _isLoading = true;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userID)
      .get();
      // ignore: unnecessary_null_comparison
      if(userDoc == null){
        return;
      }
      else{
        setState(() {
          name = userDoc.get('name');
          email = userDoc.get('email');
          phoneNumber = userDoc.get('phoneNumber');
          imageURL = userDoc.get('userImage');
          Timestamp joinedAtTimestamp = userDoc.get('createdAt');
          var joinedDate = joinedAtTimestamp.toDate();
          joinedAt = '${joinedDate.day}/${joinedDate.month}/${joinedDate.year}';
        });
        User? user = _auth.currentUser;
        final String uid = user!.uid;
        setState(() {
          _isSameUser = (uid == widget.userID);
        });
      }
    }catch(error){
      setState(() {
        _isLoading = false;
      });
      // ignore: use_build_context_synchronously
      GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
    } finally {
      _isLoading = false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  Widget userInfo({required IconData icon, required String content}){
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            content,
            style: const TextStyle(
              color: Colors.white54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _contactBy({required Color color, required Function func, required IconData icon}){
    return CircleAvatar(
      backgroundColor: color,
      radius: 25,
      child: CircleAvatar(
        radius: 23,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(
            icon,
            color: color,
          ),
          onPressed: (){
            func();
          },
        ),
      ),
    );
  }

  void _openWhatsAppChat() async {
    var url = 'https://wa.me/$phoneNumber?text=HelloWorld';
    launchUrlString(url);
  }

  void _mailTo() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Write subject here. body=Details go in here.',
    );
    final url = params.toString();
    await launchUrlString(url);
  }

  void _callPhone() async {
    var url = 'tel://$phoneNumber';
    launchUrlString(url);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.grey,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: _isLoading
            ?
              const Center(child: CircularProgressIndicator(),)
            :
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Stack(
                    children: [
                      Card(
                        color: Colors.white10,
                        margin: const EdgeInsets.all(30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 100,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  name == null
                                      ?
                                        'Name here'
                                      :
                                        name!,
                                  style: const TextStyle(color: Colors.white, fontSize: 24),
                                ),
                              ),
                              const SizedBox(height: 15,),
                              const Divider(
                                thickness: 1,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 30,),
                              const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                    'Account Information',
                                    style: TextStyle(color: Colors.white, fontSize: 24),
                                ),
                              ),
                              const SizedBox(height: 5,),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: userInfo(icon: Icons.email, content: email),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: userInfo(icon: Icons.phone, content: phoneNumber),
                              ),
                              const SizedBox(height: 15,),
                              const Divider(
                                thickness: 1,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 5,),
                              _isSameUser
                              ?
                                  Container()
                              :
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _contactBy(color: Colors.purple, func: (){ _callPhone();}, icon: Icons.phone),
                                      _contactBy(color: Colors.green, func: (){ _openWhatsAppChat();}, icon: FontAwesome.whatsapp),
                                      _contactBy(color: Colors.deepOrange, func: (){ _mailTo();}, icon: Icons.email),
                                    ],
                                  ),
                              const SizedBox(height: 5,),
                              !_isSameUser
                              ?
                                  Container()
                              :
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: MaterialButton(
                                        onPressed: (){
                                          GlobalMethod.logout(context: context);
                                        },
                                        color: Colors.black,
                                        elevation: 8,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 13),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Text(
                                              //   'Logout',
                                              //   style: TextStyle(
                                              //     fontSize: 28,
                                              //     fontWeight: FontWeight.bold,
                                              //     color: Colors.white
                                              //   ),
                                              // ),
                                              // SizedBox(width: 8,),
                                              Icon(Icons.logout, color: Colors.white,),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Divider(
                                    thickness: 1,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 5,),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: size.width * 0.26,
                            height: size.width * 0.26,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 8,
                                color: Theme.of(context).scaffoldBackgroundColor,
                              ),
                              image: DecorationImage(
                                image: NetworkImage(
                                  // ignore: prefer_if_null_operators, unnecessary_null_comparison
                                  imageURL == null
                                      ?
                                      defaultProfileIconURL
                                      :
                                      imageURL,
                                ),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ),
        // appBar: AppBar(
        //   title: const Text('Profile',
        //     style: TextStyle(
        //       fontWeight: FontWeight.bold,
        //       color: Colors.white,
        //       fontSize: 20,
        //     ),
        //   ),
        //   centerTitle: true,
        //   elevation: 0.0,
        //   flexibleSpace: Container(
        //     decoration: const BoxDecoration(
        //       color: Colors.grey,
        //     ),
        //   ),
        //   actions: <Widget>[
        //     IconButton(
        //       icon: const Icon(Icons.logout, size: 35, color: Colors.black,),
        //       tooltip: 'Go back to login menu',
        //       onPressed: () {
        //         GlobalMethod.logout(context: context);
        //       },
        //     ),
        //   ],
        // ),
        bottomNavigationBar: BottomNavBar(indexNum: 3,),
      ),
    );
  }
}
