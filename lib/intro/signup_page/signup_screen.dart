// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:temukerja_application/service/global_methods.dart';
// import 'package:temukerja_application/intro/login_page/login_screen.dart';

import '../../service/global_variables.dart';
import '../login_page/login_screen.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin {

  late Animation<double> _animation;
  late AnimationController _animationController;

  final _signupFormKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? imageFile;
  bool _obscureText = true;
  bool _isLoading = false;
  String? imageUrl;

  final FocusNode _passFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneNumFocusNode = FocusNode();
  final FocusNode _positionCPNumFocusNode = FocusNode();
  final TextEditingController _nameTextController = TextEditingController(text: '');
  final TextEditingController _emailTextController = TextEditingController(text: '');
  final TextEditingController _passTextController = TextEditingController(text: '');
  final TextEditingController _phoneTextController = TextEditingController(text: '');
  final TextEditingController _addressTextController = TextEditingController(text: '');

  @override
  void dispose() {
    _animationController.dispose();
    _nameTextController.dispose();
    _emailTextController.dispose();
    _passTextController.dispose();
    _phoneTextController.dispose();
    _passFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneNumFocusNode.dispose();
    _positionCPNumFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {

    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.linear)
      ..addListener(() {
        setState(() {

        });
      })..addStatusListener((animationStatus) {
        if(animationStatus == AnimationStatus.completed){
          _animationController.reset();
          _animationController.forward();
        }
      });
    _animationController.forward();
    super.initState();
  }

  void _showImageDialog(){
    showDialog(
        context: context,
        builder: (context)
        {
          return AlertDialog(
            title: const Text('Please choose an option'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: (){
                    _getFromCamera();
                  },
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.camera,
                          color: Colors.purple,
                        ),
                      ),
                      Text(
                        'Camera',
                        style: TextStyle(
                          color: Colors.purple,
                        ),
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: (){
                    _getFromGallery();
                  },
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.image,
                          color: Colors.purple,
                        ),
                      ),
                      Text(
                        'Gallery',
                        style: TextStyle(
                          color: Colors.purple,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  void _getFromCamera() async{
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromGallery() async{
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _cropImage(filePath) async{
    CroppedFile? croppedImage = await ImageCropper().cropImage(sourcePath: filePath, maxHeight: 1080, maxWidth: 1080);
    if (croppedImage != null){
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void _submitFormOnSignUp() async{
    final isValid = _signupFormKey.currentState!.validate();
    if(isValid){
      if(imageFile == null) {
        GlobalMethod.showErrorDialog(error: 'Please pick an image', ctx: context);
        return;
      }
      setState(() {
        _isLoading = true;
      });

      try{
        await _auth.createUserWithEmailAndPassword(
            email: _emailTextController.text.trim().toLowerCase(),
            password: _passTextController.text.trim(),
        );
        final User? user = _auth.currentUser;
        final uid = user!.uid;
        final ref = FirebaseStorage.instance.ref().child('userImages').child('$uid.jpg');
        await ref.putFile(imageFile!);
        imageUrl = await ref.getDownloadURL();
        FirebaseFirestore.instance.collection('users').doc(uid).set({
          'id': uid,
          'name': _nameTextController.text,
          'email': _emailTextController.text,
          'userImage': imageUrl,
          'phoneNumber': _phoneTextController.text,
          'companyAddress': _addressTextController.text,
          'createdAt': Timestamp.now(),
        });
        await Fluttertoast.showToast(
          msg: 'Account has been activated, please login',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0,
        );
        Navigator.canPop(context) ? Navigator.of(context) : null;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Login()));
      }catch (error){
        setState(() {
          _isLoading = false;
        });
        GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: signUpUrlImage,
            placeholder: (context, url) => Image.asset(
              'assets/images/office_building_2.jpg',
              fit: BoxFit.fill,
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: FractionalOffset(_animation.value, 0),
          ),
          Container(
            color: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
              child: ListView(
                children: [
                  Form(
                    key: _signupFormKey,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: ()
                          {
                            _showImageDialog();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: size.width * 0.24,
                              height: size.width * 0.24,
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                border: Border.all(width: 3,color: Colors.cyan,),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: imageFile == null
                                  ? const Icon(Icons.camera_enhance_sharp, color: Colors.cyan, size: 45,)
                                  : Image.file(imageFile!, fit: BoxFit.fill,),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20,),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_emailFocusNode),
                          keyboardType: TextInputType.name,
                          controller: _nameTextController,
                          validator: (value)
                          {
                            if(value!.isEmpty)
                            {
                              return 'Please enter a valid name';
                            }
                            else
                            {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Full name / Company name',
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red)
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_passFocusNode),
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailTextController,
                          validator: (value)
                          {
                            if(value!.isEmpty || !value.contains('@'))
                            {
                              return 'Please enter a valid email address';
                            }
                            else
                            {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Email address',
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red)
                            ),
                          ),
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_phoneNumFocusNode),
                          keyboardType: TextInputType.visiblePassword,
                          controller: _passTextController,
                          obscureText: !_obscureText,
                          validator: (value)
                          {
                            if(value!.isEmpty) {
                              return 'Please enter a password';
                            }
                            else if(value.length < 7) {
                              return 'Password must be at least 8 characters';
                            }
                            else {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              onTap: ()
                              {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              child: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white
                              ),
                            ),
                            hintText: 'Password',
                            hintStyle: const TextStyle(color: Colors.white),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red)
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_positionCPNumFocusNode),
                          keyboardType: TextInputType.phone,
                          controller: _phoneTextController,
                          validator: (value)
                          {
                            if(value!.isEmpty || value.length < 12)
                            {
                              return 'Please enter a valid phone number';
                            }
                            else
                            {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Phone number',
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red)
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_positionCPNumFocusNode),
                          keyboardType: TextInputType.text,
                          controller: _addressTextController,
                          validator: (value)
                          {
                            if(value!.isEmpty)
                            {
                              return 'Please enter a valid company address';
                            }
                            else
                            {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Company Address',
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red)
                            ),
                          ),
                        ),
                        const SizedBox(height: 25,),
                        _isLoading
                        ?
                        const Center(
                          child: SizedBox(
                            width: 70,
                            height: 70,
                            child: CircularProgressIndicator(

                            ),
                          ),
                        )
                        :
                        MaterialButton(
                          onPressed: (){
                            _submitFormOnSignUp();
                          },
                          color: Colors.cyan,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Sign-up',
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
                        const SizedBox(height: 40,),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Already have an account?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const TextSpan(text: '    '),
                                TextSpan(
                                  recognizer: TapGestureRecognizer()..onTap = () => Navigator.canPop(context) ? Navigator.pop(context) : null,
                                  text: 'Login',
                                  style: const TextStyle(
                                    color: Colors.cyanAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

