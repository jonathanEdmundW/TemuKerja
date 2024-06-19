import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:temukerja_application/service/global_methods.dart';
import 'package:temukerja_application/widget/job_widget.dart';
import 'package:temukerja_application/widget/search_bar.dart';

import '../../widget/bottom_nav_bar.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {

  String? jobCategoryFilter;


  _showTaskCategoriesDialog({required Size size}){
    showDialog(
        context: context,
        builder: (ctx){
          return AlertDialog(
            backgroundColor: Colors.black,
            title: const Text(
              'Job Category',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            // ignore: sized_box_for_whitespace
            content: Container(
              width: size.width * 0.9,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: Persistent.jobCategoryList.length,
                itemBuilder: (ctx, index){
                  return InkWell(
                    onTap: (){
                      setState(() {
                        jobCategoryFilter = Persistent.jobCategoryList[index];
                      });
                      Navigator.canPop(context) ? Navigator.pop(context) : null;
                      // ignore: avoid_print
                      print(
                        'JobCategoryList[index], ${Persistent.jobCategoryList[index]}'
                      );
                    } ,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_right_alt_outlined,
                          color: Colors.grey,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            Persistent.jobCategoryList[index],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text('Close', style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),),
              ),
              TextButton(
                onPressed: (){
                  setState(() {
                    jobCategoryFilter = null;
                  });
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text('Clear Filter', style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),),
              ),
            ],
          );
        }
    );
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
        appBar: AppBar(
          title: const Text('Main Menu',
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
          leading: IconButton(
            onPressed: () {
              _showTaskCategoriesDialog(size: size);
            },
            icon: const Icon(Icons.filter_list_rounded, color: Colors.black54,size: 40,),
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
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('jobs')
                .where('jobCategory', isEqualTo: jobCategoryFilter)
                .where('recruitment', isEqualTo: true)
                .orderBy('createdAt', descending: false)
                .snapshots(),
            builder: (context, AsyncSnapshot snapshot){
              if(snapshot.connectionState == ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator(),);
              }
              else if (snapshot.connectionState == ConnectionState.active){
                if(snapshot.data?.docs.isNotEmpty == true){
                  return ListView.builder(
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (BuildContext context, int index){
                        return JobWidget(
                            jobTitle: snapshot.data?.docs[index]['jobTitle'],
                            jobDesc: snapshot.data?.docs[index]['jobDesc'],
                            jobID: snapshot.data?.docs[index]['jobID'],
                            uploadedBy: snapshot.data?.docs[index]['uploadedBy'],
                            userImage: snapshot.data?.docs[index]['userImage'],
                            name: snapshot.data?.docs[index]['name'],
                            recruitment: snapshot.data?.docs[index]['recruitment'],
                            email: snapshot.data?.docs[index]['email'],
                            address: snapshot.data?.docs[index]['address'],
                        );
                      },
                  );
                }
                else{
                  return const Center(
                    child: Text('There is no jobs'),
                  );
                }
              }
              return const Center(
                child: Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              );
            }
          ),
        // body: IconButton(
        //   onPressed: (){
        //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const SearchBarWidget()));
        //   },
        //   icon: const Icon(Icons.search_outlined, color: Colors.white,),
        // ),
        bottomNavigationBar: BottomNavBar(indexNum: 0,),
      ),
    );
  }
}
