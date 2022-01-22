import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:train2/services/flags.dart';
import '/screens/chooseLocationRoute.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentLocIndex = 0;
  bool clicked = false;
  User? user = FirebaseAuth.instance.currentUser;
  late int _counter;
  late int size;
  late String rn;
  late Timer _timer;
  late Duration clockTimer;
  void _startTimer() async {
    final DocumentSnapshot snap = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    setState(() {
      size = snap['num'];
    });
    rn = Flags.list[currentLocIndex]['name'] as String;
    CollectionReference wait = FirebaseFirestore.instance.collection('$rn');
        wait.doc("waiting").get().then((value) {
          int now  = (value.data() as dynamic)["num"];
          now++;
          wait.doc('waiting')
              .update({'num': now})
              .then((value) => print("value Updated"))
              .catchError((error) => print("Failed to update user: $error"));
          wait.doc('users')
              .set({
                '$size': user!.email,
              },
                SetOptions(merge: true),
              )
              .then((value) => print("value Updated"))
              .catchError((error) => print("Failed to update user: $error"));
        });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_counter > 0) {
        setState(() {
          _counter--;
          clockTimer = Duration(seconds: _counter);
        });
      } else {
        _timer.cancel();
        setState(() {
          clicked = false;
        });
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
    });
  }

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
    if(snap.exists) {
      currentLocIndex = (snap.data() as dynamic)['index'];
      _counter = 300 * (currentLocIndex + 1);
      clockTimer = Duration(seconds: _counter);
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
          _counter = 300 * (currentLocIndex + 1);
          clockTimer = Duration(seconds: _counter);
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
            physics:  BouncingScrollPhysics(),
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
                                  onPressed: clicked? () {} : () {
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
                SizedBox(
                  height: 100,
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: clicked? () {} : () {
                    setState(() {
                      _counter = 300 * (currentLocIndex + 1);
                      clockTimer = Duration(seconds: _counter);
                      clicked = true;
                    });
                    _startTimer();
                  },
                    child: Container(
                      height: 70,
                      width: 100,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100.0),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x80000000),
                              blurRadius: 12.0,
                              offset: Offset(0.0, 5.0),
                            ),
                          ],
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xff33ccff),
                              Colors.blue,
                            ],
                          )),
                      child: Center(
                        child: Text(
                          'Wait',
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ),
                ),
                SizedBox(
                  height: 20,
                ),
                clicked? InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    setState(() {
                      _timer.cancel();
                      _counter = 300 * (currentLocIndex + 1);
                      clockTimer = Duration(seconds: _counter);
                      clicked = false;
                    });
                    delete();
                  },
                  child: Container(
                    height: 70,
                    width: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.0),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x80000000),
                            blurRadius: 12.0,
                            offset: Offset(0.0, 5.0),
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.red,
                            Colors.redAccent,
                          ],
                        )),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  ),
                ) : SizedBox(
                  height: 100,
                ),
                SizedBox(
                  height: 50,
                ),
               clicked? Container(
                  margin: const EdgeInsets.all(4),
                  height: 200,
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.train,
                                size: 80,
                                color: Colors.black,
                              ),
                              Flexible(
                                child: Text(
                                  "The train is currently in Nasr and it will arrive in",
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black
                                  ),
                                ),
                              ),
                              Text(
                                '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                            ]

                        );
                      }),
                    ),
                  ),
                ) : SizedBox(),

              ],
            ),
          ),
        ));
  }
}



