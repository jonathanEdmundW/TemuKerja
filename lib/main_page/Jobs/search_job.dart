import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:temukerja_application/main_page/Jobs/joblist_screen.dart';
import 'package:temukerja_application/widget/bottom_nav_bar.dart';
import 'package:temukerja_application/widget/job_widget.dart';


class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {

  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = '';


  Widget _buildSearchField(){
    return TextField(
      controller: _searchQueryController,
      autocorrect: true,
      decoration: const InputDecoration(
        hintText: 'Search for jobs here',
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Colors.black,
        ),
      ),
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16
      ),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions(){
    return <Widget>[
      IconButton(
          onPressed: (){
            _clearSearchQuery();
          },
          icon: const Icon(Icons.clear),
      ),
    ];
  }

  void _clearSearchQuery(){
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery('');
    });
  }

  void updateSearchQuery(String newQuery){
    setState(() {
      searchQuery = newQuery;
      // ignore: avoid_print
      print(searchQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.grey,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const JobListScreen()));
            },
          ),
          title: _buildSearchField(),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Colors.white54,
            ),
          ),
          scrolledUnderElevation: 4.0,
          shadowColor: Theme.of(context).shadowColor,
          actions: _buildActions(),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('jobs')
            .where('jobTitle', isGreaterThanOrEqualTo: searchQuery)
            .where('recruitment', isEqualTo: true)
            .snapshots(),
            builder: (context, AsyncSnapshot snapshot){
              if(snapshot.connectionState == ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator(),);
              }
              else if (snapshot.connectionState == ConnectionState.active){
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  // Filter results client-side to include only jobs with jobTitle containing searchQuery
                  var filteredDocs = snapshot.data!.docs.where((doc) {
                    return doc['jobTitle'].toString().toLowerCase().contains(
                        searchQuery.toLowerCase());
                  }).toList();

                  if (filteredDocs.isNotEmpty) {
                    return ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (BuildContext context, int index) {
                        var jobData = filteredDocs[index].data();
                        return JobWidget(
                          jobTitle: jobData['jobTitle'],
                          jobDesc: jobData['jobDesc'],
                          jobID: jobData['jobID'],
                          uploadedBy: jobData['uploadedBy'],
                          userImage: jobData['userImage'],
                          name: jobData['name'],
                          recruitment: jobData['recruitment'],
                          email: jobData['email'],
                          address: jobData['address'],
                        );
                      },
                    );
                  }
                } else{
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
        bottomNavigationBar: BottomNavBar(indexNum: 1,),
      ),
    );
  }
}
