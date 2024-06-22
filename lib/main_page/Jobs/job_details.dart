import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:temukerja_application/service/global_methods.dart';
import 'package:temukerja_application/service/global_variables.dart';
import 'package:temukerja_application/widget/comments_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';


class JobDetailsScreen extends StatefulWidget {
  const JobDetailsScreen({super.key,
    required this.uploadedBy,
    required this.jobID,
  });

  final String uploadedBy;
  final String jobID;

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? authorName;
  String? userImageUrl;
  String? jobCategory;
  String? jobDesc;
  String? jobTitle;
  bool? recruitment;
  Timestamp? postedDateTimestamp;
  Timestamp? dueDateTimestamp;
  String? postedDate;
  String? dueDate;
  String? companyAddress ='';
  String? companyEmail ='';
  int applicants = 0;
  bool isDueDateAvailable = false;
  bool _isCommenting = false;
  final TextEditingController _commentController = TextEditingController();
  bool showComment = false;

  void getJobData() async{
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users')
        .doc(widget.uploadedBy)
        .get();

    // ignore: unnecessary_null_comparison
    if(userDoc == null){
      return;
    }
    else{
      setState(() {
        authorName = userDoc.get('name');
        userImageUrl = userDoc.get('userImage');
      });
    }
    final DocumentSnapshot jobDatabase = await FirebaseFirestore.instance.collection('jobs')
    .doc(widget.jobID).get();
    // ignore: unnecessary_null_comparison
    if(jobDatabase == null){
      return;
    }
    else{
      setState(() {
        jobTitle = jobDatabase.get('jobTitle');
        jobCategory = jobDatabase.get('jobCategory');
        jobDesc = jobDatabase.get('jobDesc');
        dueDateTimestamp = jobDatabase.get('DueDateTimestamp');
        companyEmail = jobDatabase.get('email');
        companyAddress = jobDatabase.get('address');
        recruitment = jobDatabase.get('recruitment');
        postedDateTimestamp = jobDatabase.get('createdAt');
        var postDate = postedDateTimestamp!.toDate();
        postedDate = '${postDate.day}-${postDate.month}-${postDate.year}';
        dueDate = jobDatabase.get('jobDueDate');
        applicants = jobDatabase.get('jobSeeker');
      });

      var date = dueDateTimestamp!.toDate();
      isDueDateAvailable = date.isAfter(DateTime.now());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getJobData();
  }

  applyForJob(){
    final Uri params = Uri(
      scheme: 'mailto',
      path: companyEmail,
      query: 'subject=Applying for $jobTitle&body=Hello, please attach CV or Certificate',
    );
    final url = params.toString();
    launchUrlString(url);
    addNewApplicant();
  }

  void addNewApplicant() async {
    var docRef = FirebaseFirestore.instance.collection('jobs')
        .doc(widget.jobID);
    docRef.update({
      'jobSeeker': applicants + 1,
    });
    Navigator.pop(context);
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
          title: const Text('Job Details',
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
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            jobTitle==null
                                ?
                                ''
                                :
                                jobTitle!,
                            maxLines: 3,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 3,
                                  color: Colors.grey,
                                ),
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    userImageUrl == null
                                        ?
                                        defaultProfileIconURL
                                        :
                                        userImageUrl!,
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(authorName == null ? '': authorName!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5,),
                                  Text(companyAddress!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5,),
                        const Divider(height: 1,),
                        const SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              applicants.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 7,),
                            const Text(
                              'Applicants',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 7,),
                            const Icon(
                              Icons.how_to_reg_sharp,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        FirebaseAuth.instance.currentUser!.uid != widget.uploadedBy
                        ?
                        Container()
                        :
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5,),
                            const Divider(height: 1,),
                            const SizedBox(height: 5,),
                            const Text(
                              'Recruitment',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 5,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: (){
                                    User? user = _auth.currentUser;
                                    final uid = user!.uid;
                                    if(uid == widget.uploadedBy){
                                      try{
                                        FirebaseFirestore.instance.collection('jobs')
                                            .doc(widget.jobID)
                                            .update({'recruitment': true});
                                      }catch(error){
                                        GlobalMethod.showErrorDialog(
                                            error: 'Action cannot be performed',
                                            ctx: context,
                                        );
                                      }
                                    }
                                    else{
                                      GlobalMethod.showErrorDialog(
                                        error: 'You cannot perform this action',
                                        ctx: context,
                                      );
                                    }
                                    getJobData();
                                  },
                                  child: const Text('ON',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Opacity(
                                  opacity: recruitment == true ? 1 : 0,
                                  child: const Icon(
                                    Icons.check_box,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 40,),
                                TextButton(
                                  onPressed: (){
                                    User? user = _auth.currentUser;
                                    final uid = user!.uid;
                                    if(uid == widget.uploadedBy){
                                      try{
                                        FirebaseFirestore.instance.collection('jobs')
                                            .doc(widget.jobID)
                                            .update({'recruitment': false});
                                      }catch(error){
                                        GlobalMethod.showErrorDialog(
                                          error: 'Action cannot be performed',
                                          ctx: context,
                                        );
                                      }
                                    }
                                    else{
                                      GlobalMethod.showErrorDialog(
                                        error: 'You cannot perform this action',
                                        ctx: context,
                                      );
                                    }
                                    getJobData();
                                  },
                                  child: const Text('OFF',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Opacity(
                                  opacity: recruitment == false ? 1 : 0,
                                  child: const Icon(
                                    Icons.check_box,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 5,),
                        const Divider(height: 1,),
                        const SizedBox(height: 5,),
                        const Text('Job Description',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Text(
                          jobDesc == null
                              ?
                              ''
                              :
                              jobDesc!,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        const SizedBox(height: 5,),
                        const Divider(height: 1,),
                        const SizedBox(height: 5,),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10,),
                        Center(
                          child: Text(
                            isDueDateAvailable
                            ?
                            'Actively Recruiting, Send CV/Resume'
                            :
                            'Job offer has expired',
                            style: TextStyle(
                              color: isDueDateAvailable
                                  ?
                                  Colors.green
                                  :
                                  Colors.red,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Center(
                          child: isDueDateAvailable ? MaterialButton(
                            onPressed: (){
                              applyForJob();
                            },
                            color: Colors.blueAccent,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                'Apply',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                          :
                          MaterialButton(
                            onPressed: (){},
                            color: Colors.redAccent,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                "Can't Apply",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Uploaded on:',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              postedDate == null
                              ?
                              ''
                              :
                              postedDate!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Due Date:',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              dueDate == null
                                  ?
                              ''
                                  :
                              dueDate!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5,),
                        const Divider(height: 1,),
                        const SizedBox(height: 5,),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black54,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(
                          milliseconds: 500,
                        ),
                        child: _isCommenting
                        ?
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 3,
                              child: TextField(
                                controller: _commentController,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                maxLength: 200,
                                keyboardType: TextInputType.text,
                                maxLines: 6,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.pink),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: MaterialButton(
                                      onPressed: ()async{
                                        if(_commentController.text.length < 7){
                                          GlobalMethod.showErrorDialog(error: 'Comment cant be less than 7 characters', ctx: context);
                                        }
                                        else{
                                          final generatedID = const Uuid().v4();
                                          await FirebaseFirestore.instance.collection('jobs').doc(widget.jobID).update({
                                            'jobComments':
                                                FieldValue.arrayUnion([{
                                                  'userID': FirebaseAuth.instance.currentUser!.uid,
                                                  'commentID': generatedID,
                                                  'name': name,
                                                  'userImage': userImage,
                                                  'commentBody': _commentController.text,
                                                  'time': Timestamp.now(),
                                                }]),
                                          });
                                          await Fluttertoast.showToast(
                                            msg: 'Your comment has been posted',
                                            toastLength: Toast.LENGTH_LONG,
                                            backgroundColor: Colors.grey,
                                            fontSize: 18,
                                          );
                                          _commentController.clear();
                                        }
                                        setState(() {
                                          _isCommenting = !_isCommenting;
                                          showComment = true;
                                        });
                                      },
                                      color: Colors.blueAccent,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Post',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: (){
                                      setState(() {
                                        _isCommenting = !_isCommenting;
                                        showComment = false;
                                      });
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                        :
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: (){
                                setState(() {
                                  _isCommenting = !_isCommenting;
                                });
                              },
                              icon: const Icon(
                                Icons.add_comment,
                                color: Colors.blueAccent,
                                size: 40,
                              ),
                            ),
                            const SizedBox(width: 10,),
                            IconButton(
                              onPressed: (){
                                setState(() {
                                  showComment = true;
                                });
                              },
                              icon: const Icon(
                                Icons.remove_red_eye_outlined,
                                color: Colors.blueAccent,
                                size: 40,
                              ),
                            ),
                            const SizedBox(width: 10,),
                            IconButton(
                              onPressed: (){
                                setState(() {
                                  showComment = false;
                                });
                              },
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.blueAccent,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                      showComment == false
                          ?
                      Container(

                      )
                          :
                      Padding(
                       padding: const EdgeInsets.all(16.0),
                        child: FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('jobs').doc(widget.jobID).get(),
                          builder: (context, snapshot){
                            if(snapshot.connectionState == ConnectionState.waiting){
                              return const Center(child: CircularProgressIndicator(),);
                            }
                            else{
                              if(snapshot.data == null){
                                const Center(child: Text('There is yet a comment'),);
                              }
                            }
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index){
                                return CommentWidget(
                                  commentID: snapshot.data!['jobComments'][index]['commentID'],
                                  commenterID: snapshot.data!['jobComments'][index]['userID'],
                                  commenterName: snapshot.data!['jobComments'][index]['name'],
                                  commentBody: snapshot.data!['jobComments'][index]['commentBody'],
                                  commenterImageURL: snapshot.data!['jobComments'][index]['userImage'],
                                );
                              },
                              separatorBuilder: (context, index){
                                return const Divider(
                                  thickness: 1,
                                  color: Colors.grey,
                                );
                              },
                              itemCount: snapshot.data!['jobComments'].length,
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
