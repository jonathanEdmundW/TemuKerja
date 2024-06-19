import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:temukerja_application/service/global_methods.dart';
import 'package:uuid/uuid.dart';

import '../../service/global_variables.dart';
import '../../widget/bottom_nav_bar.dart';

class UploadJob extends StatefulWidget {
  const UploadJob({super.key});
  @override
  State<UploadJob> createState() => _UploadJobState();
}

class _UploadJobState extends State<UploadJob> {

  final TextEditingController _jobCategoryTextController = TextEditingController(text: 'Select job category');
  final TextEditingController _jobTitleController = TextEditingController(text: '');
  final TextEditingController _jobDescController = TextEditingController(text: '');
  final TextEditingController _jobDueDateController = TextEditingController(text: 'Assign due date');

  final _uploadFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  DateTime? picked;
  Timestamp? dueDateTimestamp;

  String? _getHint({required String hint}){
    if (hint == 'JobTitle') {
      return 'Insert job title';
    }
    else if(hint == 'JobDesc'){return 'Insert job description';}
    else if(hint == 'JobDueDate'){return 'Assign job due date';}
    return 'Error';
  }

  @override
  // ignore: must_call_super
  void dispose(){
    _jobCategoryTextController.dispose();
    _jobDueDateController.dispose();
    _jobTitleController.dispose();
    _jobDescController.dispose();
    super.dispose();
  }

   Widget _textTitles({required String label}){
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
   }

   Widget _textFormFields({
     required String valueKey,
     required TextEditingController controller,
     required bool enabled,
     required Function func,
     required int maxLength,
   }){
     return Padding(
       padding: const EdgeInsets.all(5.0),
       child: InkWell(
         onTap: (){
           func();
         },
         child: TextFormField(
           validator: (value)
           {
             if(value!.isEmpty)
             {
               return 'Value is missing';
             }
             return null;
           },
           controller: controller,
           enabled: enabled,
           key: ValueKey(valueKey),
           style: const TextStyle(
             color: Colors.white
           ),
           maxLines: valueKey == 'JobDesc' ? 3 : 1,
           maxLength: valueKey == 'JobCategory' || valueKey ==  'JobDueDate' ? null : maxLength,
           keyboardType: TextInputType.text,
           decoration: InputDecoration(
             filled: true,
             fillColor: Colors.transparent,
             hintText: _getHint(hint: valueKey),
             hintStyle: const TextStyle(
               color: Colors.white,
               fontWeight: FontWeight.normal,
             ),
             enabledBorder: const OutlineInputBorder(
               borderSide: BorderSide(color: Colors.white, width: 1),
             ),
             disabledBorder: const OutlineInputBorder(
               borderSide: BorderSide(color: Colors.white, width: 1),
             ),
             focusedBorder: const UnderlineInputBorder(
               borderSide: BorderSide(color: Colors.white, width: 1),
             ),
             errorBorder: const UnderlineInputBorder(
                 borderSide: BorderSide(color: Colors.red, width: 2)
             ),
             counterStyle: const TextStyle(
               color: Colors.white
             ),
           ),
         ),
       ),
     );
   }

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
                        _jobCategoryTextController.text = Persistent.jobCategoryList[index];
                      });
                      Navigator.pop(context);
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
                  child: const Text('Cancel', style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),),
              ),
            ],
          );
        }
    );
   }

   void _pickDateDialog() async {
    picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(
          const Duration(days: 0)
        ),
        lastDate: DateTime(2100),
    );

    if(picked != null){
      setState(() {
        _jobDueDateController.text = '${picked!.day}/${picked!.month}/${picked!.year}';
        dueDateTimestamp = Timestamp.fromMicrosecondsSinceEpoch(picked!.microsecondsSinceEpoch);
      });
    }
   }

   void _uploadForm() async{
    final jobID = const Uuid().v4();
    User? user = FirebaseAuth.instance.currentUser;
    final uid = user!.uid;
    final isValid = _uploadFormKey.currentState!.validate();


    if(isValid){
      if(_jobDueDateController.text == 'Assign job due date' ||  _jobCategoryTextController.text == 'Select job category'){
        GlobalMethod.showErrorDialog(
            error: 'Please fill in the boxes!',
            ctx: context,
        );
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try{
        await FirebaseFirestore.instance.collection('jobs').doc(jobID).set({
          'jobID': jobID,
          'uploadedBy': uid,
          'email': user.email,
          'jobTitle': _jobTitleController.text,
          'jobDesc': _jobDescController.text,
          'jobCategory': _jobCategoryTextController.text,
          'jobDueDate': _jobDueDateController.text,
          'DueDateTimestamp': dueDateTimestamp,
          'jobComments': [],
          'recruitment': true,
          'createdAt': Timestamp.now(),
          'name': name,
          'userImage': userImage,
          'address': address,
          'jobSeeker': 0,
        });
        await Fluttertoast.showToast(
          msg: 'Submission Complete',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0,
        );
        _jobTitleController.clear();
        _jobDescController.clear();
        setState(() {
          _jobCategoryTextController.text = 'Select job category';
          _jobDueDateController.text = 'Assign job due date';
        });
      }catch(error){
        setState(() {
          _isLoading = false;
        });
        GlobalMethod.showErrorDialog(
            error: error.toString(),
            // ignore: use_build_context_synchronously
            ctx: context,
        );
      }
      finally{
        setState(() {
          _isLoading = false;
        });
      }
    }
    else{
      // ignore: avoid_print
      print('Its not valid');
    }
   }

  void getData() async{
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      name = userDoc.get('name');
      userImage = userDoc.get('userImage');
        address = userDoc.get('companyAddress');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
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
          title: const Text('Upload Job',
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
              icon: const Icon(Icons.logout, size: 35, color: Colors.white,),
              tooltip: 'Go back to login menu',
              onPressed: () {
                GlobalMethod.logout(context: context);
              },
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(indexNum: 2,),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.black12,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20,),
                    // Align
                    const Divider(
                      thickness: 1,
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Job Registration Form',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _uploadFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _textTitles(label: 'Job Due Date: '),
                            _textFormFields(
                              valueKey: 'JobDueDate',
                              controller: _jobDueDateController,
                              enabled: false,
                              func: (){
                                _pickDateDialog();
                              },
                              maxLength: 100,
                            ),
                            _textTitles(label: 'Job Category: '),
                            _textFormFields(
                                valueKey: 'JobCategory',
                                controller: _jobCategoryTextController,
                                enabled: false,
                                func: (){
                                  _showTaskCategoriesDialog(size: size);
                                },
                                maxLength: 100,
                            ),
                            _textTitles(label: 'Job Title: '),
                            _textFormFields(
                                valueKey: 'JobTitle',
                                controller: _jobTitleController,
                                enabled: true,
                                func: (){},
                                maxLength: 40,
                            ),
                            _textTitles(label: 'Job Description: '),
                            _textFormFields(
                              valueKey: 'JobDesc',
                              controller: _jobDescController,
                              enabled: true,
                              func: (){},
                              maxLength: 100,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 0),
                        child:
                        _isLoading
                            ? const Center(
                                child: SizedBox(
                                width: 70,
                                height: 70,
                                child: CircularProgressIndicator(),
                                ),
                            )
                            : MaterialButton(
                                onPressed: (){
                                  _uploadForm();
                                },
                                color: Colors.black,
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                      'Submit',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
