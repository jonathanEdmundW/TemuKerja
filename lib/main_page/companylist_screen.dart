import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:temukerja_application/service/global_methods.dart';
import 'package:temukerja_application/widget/companylist_widget.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {

  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = '';

  Widget _buildSearchField(){
    return TextField(
      controller: _searchQueryController,
      autocorrect: true,
      decoration: const InputDecoration(
        hintText: 'Search for companies here',
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
      const SizedBox(width: 5,),
      IconButton(
        icon: const Icon(Icons.logout, size: 35, color: Colors.black,),
        tooltip: 'Go back to login menu',
        onPressed: () {
          GlobalMethod.logout(context: context);
        },
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
          automaticallyImplyLeading: false,
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
            stream: FirebaseFirestore.instance.collection('users')
                .where('name', isGreaterThanOrEqualTo: searchQuery)
                .snapshots(),
            builder: (context, AsyncSnapshot snapshot){
              if(snapshot.connectionState == ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator(),);
              }
              else if (snapshot.connectionState == ConnectionState.active){
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index){
                      return CompanyListWidget(
                        userID: snapshot.data!.docs[index]['id'],
                        userName: snapshot.data!.docs[index]['name'],
                        userEmail: snapshot.data!.docs[index]['email'],
                        userImageURL: snapshot.data!.docs[index]['userImage'],
                        phoneNumber: snapshot.data!.docs[index]['phoneNumber'],
                      );
                    },
                  );
                } else{
                  return const Center(
                    child: Text('There is no companies'),
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
      ),
    );
  }
}
