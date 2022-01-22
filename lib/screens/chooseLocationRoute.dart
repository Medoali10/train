//ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:train2/services//flags.dart';
import 'package:flutter/material.dart';

class ChooseLocationRoute extends StatelessWidget {

  User? user = FirebaseAuth.instance.currentUser;

  void update(int index) async {
    final DocumentReference<Map<String, dynamic>> snap = FirebaseFirestore
        .instance.collection('users').doc(user?.uid);
    snap.update({
      "index": index
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff181227),
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(Icons.arrow_back,
          color: Colors.black,),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        title: const Text('Choose location',
        style: TextStyle(
            color: Colors.black
        ),),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: Flags.list.length,
        itemBuilder: (builder, index) =>
            Container(
              height: 100,
              width: 300,
              child: Card(
                elevation: 8,
                shadowColor: Colors.black,
                margin: EdgeInsets.all(20),
                child: ListTile(
                    onTap: () {
                      update(index);
                      Navigator.of(context).pop();
                    },
                    title: Text(
                      Flags.list[index]['name'] as String,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black
                      ),
                    ),
                    trailing: Icon(
                      Icons.navigate_next_rounded,
                      color: Theme
                          .of(context)
                          .iconTheme
                          .color,
                    )),
              ),
            ),
      ),
    );
  }
}



