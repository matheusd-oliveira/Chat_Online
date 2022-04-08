import 'package:chat_online/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();

  runApp(
    MaterialApp(
      home: HomePage(),
    ),
  );
  FirebaseFirestore.instance.collection('mensagens').doc('msg1').set(
    {
      'texto': 'olá, tudo bem Matheus?',
      'from': 'davi',
      'read': 'false',
    },
  );
}
