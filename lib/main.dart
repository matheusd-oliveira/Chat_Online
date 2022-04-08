import 'package:chat_online/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
      home: HomePage(),
    ),
  );
  FirebaseFirestore.instance
      .collection('mensagens')
      .doc('msg1')
      .collection('arquivos')
      .doc()  
      .set(
    {'arqname': 'foto.png'},
  );
}
