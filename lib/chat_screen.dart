import 'dart:io';

import 'package:chat_online/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Criando objeto do Google para entrar na conta
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // Criando Key para snackbar
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Criando função para pegar o usuario

  User? _currentUser;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      _currentUser = user;
    });
  }

  Future<User?> _getUser() async {
    if (_currentUser != null) return _currentUser;
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;
      return user;
    } catch (error) {
      return null;
    }
  }

  void _sendFirebase({String? text, PickedFile? imgFile}) async {
    final User? user = await _getUser();

    if (user == null) {
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Não foi possível fazer o login. Tente Novamente!'),
          backgroundColor: Colors.red,
        ),
      );
    }
    Map<String, dynamic> data = {
      'uid': user?.uid,
      'senderName': user?.displayName,
      'senderPhotoUrl': user?.photoURL,
      'time': Timestamp.now(),
    };

    if (imgFile != null) {
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(File(imgFile.path));
      TaskSnapshot taskSnapshot = await task;
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = url;
    }
    if (text != null) {
      data['text'] = text;
    }
    FirebaseFirestore.instance.collection('mensagens').add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Olá'),
        elevation: 0,
      ),
      body: Column(children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('mensagens').snapshots(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                default:
                  List<DocumentSnapshot> documents =
                      snapshot.data!.docs.reversed.toList();
                  return ListView.builder(
                    itemCount: documents.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(documents[index].data['text']),
                      );
                    },
                  );
              }
            },
          ),
        ),
        TextComposer(_sendFirebase),
      ]),
    );
  }
}
