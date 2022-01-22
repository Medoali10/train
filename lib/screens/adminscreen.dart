import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:train2/services/flags.dart';

import 'chooseLocationRoute.dart';


var cat = [] ;

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int currentLocIndex = 0;
  bool clicked = false;
  User? user = FirebaseAuth.instance.currentUser;
  late int size;
  late String rn = Flags.list[currentLocIndex]['name'] as String;
  int waiting = 0;
  bool empty = false;



  void delete() async {
    CollectionReference wait = FirebaseFirestore.instance.collection('$rn');
    final DocumentReference<Map<String, dynamic>> snap = FirebaseFirestore
        .instance.collection('users').doc(user?.uid);
    wait.doc("waiting").get().then((value) {
      int now  = (value.data() as dynamic)["num"];
      now--;
      wait.doc('waiting')
          .update({'num': now})
          .then((value) => print("value Updated"))
          .catchError((error) => print("Failed to update user: $error"));
      wait.doc('users')
          .update({
        '$size': FieldValue.delete(),
      },)
          .then((value) => print("value Updated"))
          .catchError((error) => print("Failed to update user: $error"));
    });
  }

  void fetch() async {
    final DocumentSnapshot snap = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    final DocumentSnapshot rec = await FirebaseFirestore.instance.collection('$rn').doc("waiting").get();
    if(snap.exists) {
      currentLocIndex = (snap.data() as dynamic)['index'];
      rn = Flags.list[currentLocIndex]['name'] as String;
      waiting = (rec.data() as dynamic)["num"];
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch();
    DocumentReference<Map<String, dynamic>> reference = FirebaseFirestore.instance.collection('users').doc(user!.uid);
    reference.snapshots().listen((querySnapshot) {
      setState(() {
        currentLocIndex = (querySnapshot.data() as dynamic)["index"];
        rn = Flags.list[currentLocIndex]['name'] as String;
      });
      DocumentReference<Map<String, dynamic>> ref = FirebaseFirestore.instance.collection('$rn').doc("waiting");
      ref.snapshots().listen((querySnapshot) {
        setState(() {
          waiting = (querySnapshot.data() as dynamic)["num"];
        });
        CollectionReference rem = FirebaseFirestore.instance.collection('$rn');
        setState(() {
          rem.doc("users").get().then((value) {
            if(value.exists){
              setState(() {
                cat = (value.data() as dynamic).values.toList();
              });
            }
          });
        });
      });

    });

  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xff181227),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: Icon(
                Icons.home, color: Colors.black),
            title: const Text('Project name',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w700)),
            actions: [
              IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Container(
                              color: Colors.white,
                              height: 100,
                              child: Stack(
                                overflow: Overflow.visible,
                                children: <Widget>[
                                  Positioned(
                                    right: -40.0,
                                    top: -40.0,
                                    child: InkResponse(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: CircleAvatar(
                                        child: Icon(Icons.close,
                                          color: Colors.black,),
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          Text("About"),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            ),
                          );
                        });
                  },
                  icon: const Icon(Icons.help, color: Colors.black))
            ],
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(4),
                  height: 100,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 6,
                      color: const Color(0xffF5F5F6),
                      shape:
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Builder(builder: (context) {
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.transfer_within_a_station,
                                size: 40,
                                color: Colors.black,
                              ),
                              Text(
                                Flags.list[currentLocIndex]['name'] as String,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 28,
                                    color: Colors.black
                                ),
                              ),
                              IconButton(
                                  icon: Icon(
                                    Icons.navigate_next_outlined,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (builder) =>
                                                ChooseLocationRoute()));}
                              ),
                            ]

                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      Text('Waiting: ' + "$waiting",
                          style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 20,
                              color: Colors.white)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Users',
                          style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 20,
                              color: Colors.white)),
                    ],
                  ),
                ),
                 SizedBox(
                  height: 24,
                ),
                SizedBox(
                  height: 600,
                  child: ListView.builder(
          itemCount: cat.length,
          itemBuilder: (context, index) {
            return Container(
              height: 100,
              width: 300,
              child: Card(
                child: ListTile(
                  leading: Text(
                        cat[index],
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.black)
                  ),
                ),
                elevation: 8,
                shadowColor: Colors.black,
                margin: EdgeInsets.all(20),
              ),
            );
          }
      )
     ),
              ],
            ),
          ),
        ));
  }
}