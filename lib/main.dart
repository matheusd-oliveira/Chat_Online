import 'dart:async';

import 'package:chat_online/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
      title: 'Chat Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        iconTheme: IconThemeData(
          color: Colors.blue,
        ),
      ),
      home: ChatScreen(),
    ),
  );

// Criando dados no banco de dados
  // FirebaseFirestore.instance
  //     .collection('mensagens')
  //     .doc('msg1')
  //     .collection('arquivos')
  //     .doc()
  //     .set(
  //   {'arqname': 'foto.png'},
  // );

// lendo dados no banco de dados de um dado
  // DocumentSnapshot snapshot = await FirebaseFirestore.instance
  //     .collection('mensagens')
  //     .doc('B16KLhqc0We8koSkNpXP')
  //     .get();

// Lendo dados no banco de dados de todos os documentos
  // QuerySnapshot snapshot2 =
  //     await FirebaseFirestore.instance.collection('mensagens').get();
  // snapshot2.docs.forEach((d) {
  //   d.reference.update({'lido': true});
  // });

// Saber se os dados foram atualizados automaticamente
  // await FirebaseFirestore.instance.collection('mensagens').snapshots().listen((dado) {
  //   dado.docs.forEach((d) {
  //      debugPrint(d.data as String);
  //   });
  // });
}
