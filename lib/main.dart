import 'package:chat_online/home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseConfig.platformOptions);
  runApp(
    MaterialApp(
      home: HomePage(),
    ),
  );
  Firestore.instance
      .collection('col')
      .document('doc')
      .setData({'texto': 'matheus'});
}
