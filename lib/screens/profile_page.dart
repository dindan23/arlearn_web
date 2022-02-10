import 'dart:io';

import 'package:arlearn_web/model/firebase_file.dart';
import 'package:arlearn_web/screens/filegallery_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:arlearn_web/screens/login_page.dart';
import 'package:arlearn_web/utils/fire_auth.dart';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:arlearn_web/firebase_api.dart';
import 'package:arlearn_web/model/firebase_file.dart';

String nowUser = '';

class ProfilePage extends StatefulWidget {
  final User user;


  const ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isSendingVerification = false;
  bool _isSigningOut = false;
  File? file;
  late User _currentUser;


  @override
  void initState() {
    _currentUser = widget.user;
    super.initState();
    nowUser = _currentUser.uid;
    late Future<List<FirebaseFile>> futureFiles;
    futureFiles = FirebaseApi.listAll('UserUpload/$nowUser/');
  }

  @override
  Widget build(BuildContext context) {
    final fileName = file != null ? basename(file!.path) : 'No File Selected';
  
      
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            ElevatedButton(
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyGallery()),
              );
              }, child: Text('GALLERY'),

                
            ),
            SizedBox(height: 16.0),

            ElevatedButton(
            onPressed: selectFile, child: Text('UPLOAD FILE'),
            ),

            SizedBox(height: 16.0),
           /*
            //
            //
            //
            ElevatedButton(
              onPressed: , child: Text('FILE GALLERY'),
            ),
            //
            //
            //
            */
            SizedBox(height: 16.0),

            Text(
              'NAME: ${_currentUser.displayName}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 16.0),
            Text(
              'EMAIL: ${_currentUser.email}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 16.0),
            _currentUser.emailVerified
                ? Text(
                    'Email verified',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(color: Colors.green),
                  )
                : Text(
                    'Email not verified',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(color: Colors.red),
                  ),
            SizedBox(height: 16.0),
            _isSendingVerification
                ? CircularProgressIndicator()
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _isSendingVerification = true;
                          });
                          await _currentUser.sendEmailVerification();
                          setState(() {
                            _isSendingVerification = false;
                          });
                        },
                        child: Text('Verify email'),
                      ),
                      SizedBox(width: 8.0),
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () async {
                          User? user = await FireAuth.refreshUser(_currentUser);

                          if (user != null) {
                            setState(() {
                              _currentUser = user;
                            });
                          }
                        },
                      ),
                    ],
                  ),
            SizedBox(height: 16.0),
            _isSigningOut
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isSigningOut = true;
                      });
                      await FirebaseAuth.instance.signOut();
                      setState(() {
                        _isSigningOut = false;
                      });
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                    child: Text('Sign out'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),





          ],
        ),
      ),
    );
  }

  void selectFile() async {
    final result = await FilePicker.platform.pickFiles(
        allowMultiple: false, type: FileType.any);

    if (result != null && result.files.isNotEmpty) {
      final fileBytes = result.files.first.bytes;
      final fileName = result.files.first.name;
/*
    if(result == null) return;
    final path = result.files.single.path!;
    setState(() => file = File(path));

 */
      await FirebaseStorage.instance.ref('UserUpload/$nowUser/$fileName').putData(
          fileBytes!);
    }
  }





}



