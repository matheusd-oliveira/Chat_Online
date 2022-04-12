// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:chat_online/chat_message.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
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

      setState(() {
        _isLoading = true;
      });

      TaskSnapshot taskSnapshot = await task;
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = url;

      setState(() {
        _isLoading = false;
      });
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
        centerTitle: true,
        title: Text(_currentUser != null
            ? 'Olá, ${_currentUser!.displayName}'
            : 'Chat App'),
        elevation: 0,
        actions: [
          // Deslogar do app com snackBar notificando
          _currentUser != null
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    _scaffoldKey.currentState?.showSnackBar(
                      SnackBar(content: Text('Você saiu com sucesso!')),
                    );
                  },
                )
              : Container(),
        ],
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
                      return ChatMessage(
                        documents[index].data() as Map<String, dynamic>,
                        documents[index]['uid'] == _currentUser?.uid,
                      );
                    },
                  );
              }
            },
          ),
        ),
        _isLoading ? LinearProgressIndicator() : Container(),
        TextComposer(_sendFirebase),
      ]),
    );
  }
}
